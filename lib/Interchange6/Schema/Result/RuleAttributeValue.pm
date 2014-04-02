use utf8;
package Interchange6::Schema::Result::RuleAttributeValue;

=head1 NAME

Interchange6::Schema::Result::RuleAttributeValue

=cut

use strict;
use warnings;

use base 'DBIx::Class::Core';

=head1 TABLE: C<rules_attributes_values>

=cut

__PACKAGE__->table("rules_attributes_values");

=head1 ACCESSORS

=head2 rule_attributes_values_id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 rule_attributes_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=head2 attribute_values_id

  data_type: 'integer'
  is_foreign_key: 1
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "rule_attributes_values_id",
  { 
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
  },
  "rule_attributes_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0},
  "attribute_values_id",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0},
);

=head1 PRIMARY KEY

=over 4

=item * L</rule_attributes_values_id>

=back

=cut

__PACKAGE__->set_primary_key("rule_attributes_values_id");

=head1 RELATIONS

=head2 RuleAttribute

Type: belongs_to

Related object: L<Interchange6::Schema::Result::RuleAttribute>

=cut

__PACKAGE__->belongs_to(
  "RuleAttribute",
  "Interchange6::Schema::Result::RuleAttribute",
  { rule_attributes_id => "rule_attributes_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

=head2 AttributeValue

Type: belongs_to

Related object: L<Interchange6::Schema::Result::AttributeValue>

=cut

__PACKAGE__->belongs_to(
  "AttributeValue",
  "Interchange6::Schema::Result::AttributeValue",
  { attribute_values_id => "attribute_values_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" },
);

1;
