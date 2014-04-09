use utf8;
package Interchange6::Schema::Result::RuleGroup;

=head1 NAME

Interchange6::Schema::Result::RuleGroup;

=cut

use strict;
use warnings;
use DateTime;

use base 'DBIx::Class::Core';

# component load order is important so be careful here:
__PACKAGE__->load_components(
    qw(InflateColumn::DateTime TimeStamp
      +Interchange6::Schema::Component::Validation)
);

=head1 TABLE: C<rules>

=cut

__PACKAGE__->table("rule_groups");

=head1 ACCESSORS

=head2 rule_groups_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 title

  data_type: 'varchar'
  default_value: (empty string)
  is_nullable: 0
  size: 255

=head2 valid_from

  data_type: 'date'
  set_on_create: 1
  is_nullable: 0

=head2 valid_to

  data_type: 'date'
  is_nullable: 1

=head2 priority

  data_type: 'integer'
  default_value: 0
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 created

  data_type: 'datetime'
  set_on_create: 1
  is_nullable: 0

=head2 last_modified

  data_type: 'datetime'
  set_on_create: 1
  set_on_update: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "rule_groups_id",
  {
    data_type => "integer",
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "valid_from",
  { data_type => "date", set_on_create => 1, is_nullable => 0 },
  "valid_to",
  { data_type => "date", is_nullable => 1 },
  "active",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "created",
  { data_type => "datetime", set_on_create => 1, is_nullable => 0 },
  "last_modified",
  { data_type => "datetime", set_on_create => 1, set_on_update => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</rule_groups_id>

=back

=cut

__PACKAGE__->set_primary_key("rule_groups_id");

=head1 RELATIONS

=head2 RuleGroupline

Type: has_many

Related object: L<Interchange6::Schema::Result::RuleGroupline>

=cut

__PACKAGE__->has_many(
  "RuleGroupline",
  "Interchange6::Schema::Result::RuleGroupline",
  { "foreign.rule_groups_id" => "self.rule_groups_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head1 INHERITED METHODS

=head2 sqlt_deploy_hook

Called during table creation to add indexes on the following columns:

=over 4

=item * name

=item * valid_from

=item * valid_to

=back

=cut

sub sqlt_deploy_hook {
    my ( $self, $table ) = @_;

    $table->add_index( name => 'rule_groups_idx_name', fields => ['name'] );
    $table->add_index(
        name   => 'rule_groups_idx_valid_from',
        fields => ['valid_from']
    );
    $table->add_index(
        name   => 'rule_groups_idx_valid_to',
        fields => ['valid_to']
    );
}

=head2 validate

Validity checks that cannot be enforced using primary key, unique or other database methods using L<Interchange6::Schema::Component::Validation>. The validity checks enforce the following rules:

=over 4

=item * If both valid_from and valid_to are defined then valid_to must be a later date than valid_from.

=item * A single name may appear more than once in the table to allow for a rule change at a specific point in time but valid_from/valid_to date ranges must not overlap.

=back

=cut

sub validate {
    my $self   = shift;
    my $schema = $self->result_source->schema;
    my $dtf    = $schema->storage->datetime_parser;
    my $rset;

    # check that valid_to is later than valid_from (if it is defined)

    $self->valid_from->truncate( to => 'day' );

    if ( defined $self->valid_to ) {

        # remove time - we only want the date
        $self->valid_to->truncate( to => 'day' );

        unless ( $self->valid_to > $self->valid_from ) {
            $schema->throw_exception("valid_to is not later than valid_from");
        }
    }

    # grab our resultset

    $rset = $self->result_source->resultset;

    if ( $self->in_storage ) {

        # this is an update so we must exclude our existing record from
        # the resultset before range overlap checks are performed

        $rset = $rset->search(
            { rule_groups_id => { '!=', $self->rule_groups_id } }
        );
    }

    # multiple entries do not overlap dates

    if ( defined $self->valid_to ) {
        $rset = $rset->search(
            {
                name => $self->name,
                -or      => [
                    valid_from => {
                        -between => [
                            $dtf->format_datetime( $self->valid_from ),
                            $dtf->format_datetime( $self->valid_to ),
                        ]
                    },
                    valid_to => {
                        -between => [
                            $dtf->format_datetime( $self->valid_from ),
                            $dtf->format_datetime( $self->valid_to ),
                        ]
                    },
                ],
            }
        );

        if ( $rset->count > 0 ) {
            $schema->throw_exception('RuleGroup overlaps existing date range');
        }
    }
    else {
        $rset = $rset->search(
            {
                name => $self->name,
                -or      => [
                    {
                        valid_to => undef,
                        valid_from =>
                          { '<=', $dtf->format_datetime( $self->valid_from ) },
                    },
                    {
                        valid_to => { '!=', undef },
                        valid_to =>
                          { '>=', $dtf->format_datetime( $self->valid_from ) },
                    },
                ],
            }
        );
    }
    if ( $rset->count > 0 ) {
        $schema->throw_exception('RuleGroup overlaps existing date range');
    }
}

1;

