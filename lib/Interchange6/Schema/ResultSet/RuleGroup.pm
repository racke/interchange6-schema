use utf8;

package Interchange6::Schema::ResultSet::RuleGroup;

=head1 NAME

Interchange6::Schema::ResultSet::RuleGroup

=cut

=head1 SYNOPSIS

Provides extra accessor methods for L<Interchange6::Schema::Result::RuleGroup>

=cut

use strict;
use warnings;

use DateTime;

use base 'DBIx::Class::ResultSet';

=head1 METHODS

=head2 current_rule_group( $name )

Given a valid name will return the RuleGroup row for the current date

=cut

sub current_rule_group {
    my ( $self, $name ) = @_;

    my $schema = $self->result_source->schema;
    my $dtf    = $schema->storage->datetime_parser;
    my $dt     = DateTime->today;

    $schema->throw_exception("name not supplied") unless defined $name;

    my $rset = $self->search(
        {
            name       => $name,
            valid_from => { '<=', $dtf->format_datetime($dt) },
            valid_to   => [ undef, { '>=', $dtf->format_datetime($dt) } ],
        }
    );

    if ( $rset->count == 1 ) {
        return $rset->next;
    }
    else {
        $schema->throw_exception(
            "current_rule_group not found for name: " . $name );
    }
}

1;
