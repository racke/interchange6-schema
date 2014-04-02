use utf8;
package Interchange6::Schema::Result::RuleAttribute;

=head1 NAME

Interchange6::Schema::Result::RuleAttribute

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<rule_attributes>

=cut

__PACKAGE__->table("rule_attributes");

=head1 ACCESSORS

=head2 rule_attributes_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 rules_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 attributes_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "rule_attributes_id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "rules_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "attributes_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</rule_attributes_id>

=back

=cut

__PACKAGE__->set_primary_key("rule_attributes_id");

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

=head2 Attribute

Type: belongs_to

Related object: L<Interchange6::Schema::Result::Attribute>

=cut

__PACKAGE__->belongs_to(
  "Attribute",
  "Interchange6::Schema::Result::Attribute",
  { attributes_id => "attributes_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 RuleAttributeValue

Type: belongs_to

Related object: L<Interchange6::Schema::Result::RuleAttributeValue>

=cut

__PACKAGE__->has_many(
  "RuleAttributeValue",
  "Interchange6::Schema::Result::RuleAttributeValue",
  { "foreign.rule_attributes_id" => "self.rule_attributes_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);


1;
