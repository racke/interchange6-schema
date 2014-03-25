use utf8;
package Interchange6::Schema::Result::RuleGroupLine;

=head1 NAME

Interchange6::Schema::Result::RuleGroupLine

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<rule_group_lines>

=cut

__PACKAGE__->table("rule_group_lines");

=head1 ACCESSORS

=head2 rule_group_lines_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 rules_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "rule_group_lines_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "rules_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</rule_groups_id>

=back

=cut

__PACKAGE__->set_primary_key("rule_group_lines_id");

=head1 RELATIONS

=head2 Rule

Type: belongs_to

Related object: L<Interchange6::Schema::Result::Rule>

=cut

__PACKAGE__->belongs_to(
  "Rule",
  "Interchange6::Schema::Result::Rule",
  { rules_id => "rules_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

1;
