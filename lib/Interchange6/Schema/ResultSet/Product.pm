use utf8;

package Interchange6::Schema::ResultSet::Product;

=head1 NAME

Interchange6::Schema::ResultSet::Product

=cut

=head1 SYNOPSIS

Provides extra accessor methods for L<Interchange6::Schema::Result::Product>

=cut

use strict;
use warnings;

use parent 'Interchange6::Schema::ResultSet';

=head1 METHODS

See also L<DBIx::Class::Helper::ResultSet::Shortcut> which is loaded by this
result set.

=head2 active

Returns all rows where L<Interchange6::Schema::Result::Product/active> is true.

=cut

sub active {
    return $_[0]->search({ $_[0]->me.'active' => 1 });
}

=head2 listing

This is just a shortcut for:

  $self->columns( [ 'sku', 'name', 'uri', 'price', 'short_description' ] )
      ->with_average_rating->with_quantity_in_stock->with_selling_price
      ->with_variant_count;

=cut

sub listing {
    return
      shift->columns( [ 'sku', 'name', 'uri', 'price', 'short_description' ] )
      ->with_average_rating->with_quantity_in_stock->with_selling_price
      ->with_variant_count;
}

=head2 with_average_rating

Adds C<average_rating> column which is available to order_by clauses and
whose value can be retrieved via
L<Interchange6::Schema::Result::Product/average_rating>.

This is the average rating across all public and approved product reviews or
undef if there are no reviews. Product reviews are only related to canonical
products so for variants the value returned is that of the canonical product.

=cut

sub with_average_rating {
    my $self = shift;

    my $me = $self->me;

    return $self->search(
        undef,
        {
            '+select' => [
                {
                    coalesce => [

                        $self->correlate('canonical')
                          ->related_resultset('_product_reviews')
                          ->search_related(
                            'message',
                            { 'message.approved' => 1, 'message.public' => 1 }
                          )->get_column('rating')->func_rs('avg')->as_query,

                        $self->correlate('_product_reviews')
                          ->search_related(
                            'message',
                            { 'message.approved' => 1, 'message.public' => 1 }
                          )->get_column('rating')->func_rs('avg')->as_query,

                      ],
                    -as => 'average_rating'
                }
            ],
            '+as' => ['average_rating'],
        }
    );
}

=head2 with_inventory

=cut

sub with_inventory {
    return shift->search(
        undef,
        {
            prefetch => 'inventory'
        }
    );
}

=head2 with_price_modifiers

=cut

sub with_price_modifiers {
    return shift->search(
        undef,
        {
            prefetch => 'price_modifiers'
        }
    );
}

=head2 with_quantity_in_stock

=cut

sub with_quantity_in_stock {

    return shift->search(
        undef,
        {
            '+columns' => [ { quantity_in_stock => 'inventory.quantity' } ],
            join  => 'inventory',
        }
    );
}

=head2 with_selling_price

The lowest of L<Interchange6::Schema::Result::PriceModifier/price> and L<Interchange6::Schema::Result::Product/price>

For products with variants this is the lowest variant price with or without modifiers.

=cut

sub with_selling_price {
    my ( $self, $args ) = @_;

    if ( defined($args) ) {
        $self->throw_exception(
            "argument to listing must be a hash reference")
          unless ref($args) eq "HASH";
    }

    my $schema = $self->result_source->schema;

    $args->{quantity} = 1 unless defined $args->{quantity};

    my $roles_id = undef;
    my @roles_cond = ( undef );

    if ( $args->{users_id} ) {

        my $subquery =
          $schema->resultset('UserRole')
          ->search( { "role.users_id" => { '=' => \"?" } },
            { alias => 'role' } )->get_column('roles_id')->as_query;

        push @roles_cond, { -in => $subquery };
    }

    if ( $args->{roles} ) {

        $self->throw_exception(
            "Argument roles to selling price must be an array reference")
          unless ref( $args->{roles} ) eq 'ARRAY';

        my $subquery =
          $schema->resultset('Role')
          ->search( { "role.name" => { -in => \@{$args->{roles}} } },
            { alias => 'role' } )->get_column('roles_id')->as_query;

        push @roles_cond, { -in => $subquery };
    }

    my $today = $schema->format_datetime(DateTime->today);

    return $self->search(
        undef,
        {
            '+select' => [
                {
                    coalesce => [
                        $self->correlate('variants')->search_related(
                            'price_modifiers',
                            {
                                'start_date' => [ undef, { '<=', $today } ],
                                'end_date'   => [ undef, { '>=', $today } ],
                                'quantity' => $args->{quantity},
                                'roles_id' => \@roles_cond,
                            }
                          )->get_column('price')->min_rs->as_query,
                        $self->correlate('price_modifiers')->search(
                            {
                                'start_date' => [ undef, { '<=', $today } ],
                                'end_date'   => [ undef, { '>=', $today } ],
                                'quantity' => $args->{quantity},
                                'roles_id' => \@roles_cond,
                            }
                        )->get_column('price')->min_rs->as_query,
                    ],
                    -as => 'selling_price'
                }
            ],
            '+as' => ['selling_price'],
        }
    );
}

=head2 with_variant_count

Adds column C<variant_count> which is a count of variants of each product.

=cut

sub with_variant_count {
    my $self = shift;
    return $self->search(
        undef,
        {
            '+columns' => {
                variant_count =>
                  $self->correlate('variants')->count_rs->as_query
            }
        }
    );
}

1;
