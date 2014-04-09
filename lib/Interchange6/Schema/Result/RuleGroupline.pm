use utf8;
package Interchange6::Schema::Result::RuleGroupline;

=head1 NAME

Interchange6::Schema::Result::RuleGroupline

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<rule_grouplines>

=cut

__PACKAGE__->table("rule_grouplines");

=head1 ACCESSORS

=head2 rule_grouplines_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 rule_groups_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 rules_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 priority

  data_type: 'integer'
  is_nullable: 0
  default: 0

=cut

__PACKAGE__->add_columns(
  "rule_grouplines_id",
  {
    data_type => "integer",
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "rule_groups_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "rules_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "priority",
  { data_type => "integer", is_nullable => 0, default => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</rule_groups_id>

=back

=cut

__PACKAGE__->set_primary_key("rule_grouplines_id");

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

=head2 RuleGroup

Type: belongs_to

Related object: L<Interchange6::Schema::Result::RuleGroup>

=cut

__PACKAGE__->belongs_to(
  "RuleGroup",
  "Interchange6::Schema::Result::RuleGroup",
  { rule_groups_id => "rule_groups_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 RuleAttribute

Type: has_many

Related object: L<Interchange6::Schema::Result::RuleAttribute>

=cut

__PACKAGE__->has_many(
  "RuleAttribute",
  "Interchange6::Schema::Result::RuleAttribute",
  { "foreign.rules_id" => "self.rules_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head1 INHERITED METHODS

=head2 sqlt_deploy_hook

Called during table creation to add indexes on the following columns:

=over 4

=item * priority

=back

=cut

sub sqlt_deploy_hook {
    my ( $self, $table ) = @_;

    $table->add_index(
        name => 'rule_grouplines_idx_priority',
        fields => ['priority']
    );
}

1;
