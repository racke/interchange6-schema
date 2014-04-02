use utf8;
package Interchange6::Schema::Result::Rule;

=head1 NAME

Interchange6::Schema::Result::Rule;

=cut

use strict;
use warnings;

use base qw(DBIx::Class::Core Interchange6::Schema::Base::Attribute);

=head1 TABLE: C<rules>

=cut

__PACKAGE__->table("rules");

=head1 DESCRIPTION

The rules table contains parameters for various rule types. 

Rules are broken into 4 parts.

=over

=item *

B<Object> The rule object defines the data object that the rule will effect.  Objects
require the following attributes (name, field).  A valid name is any result class.
A valid field would be any field which is directly part of that result class.

# Object: Cart object with field shipping
$myrule->add_attribute({ name => 'name'}, 'Cart');
$myrule->add_attribute({ name => 'field'}, 'shipping');

=item *

B<Action> The action of the rule designates what resulting action the rule will perform.
An example of an action is a discount.  The action is dependent on the critera of
the condition (see Condition). 

Actions require the following attributes (operator, function, type, value). 

operator: valid operator values are add, subtract, multiply, divide
function: valid type values are percentage, flat
type: valid types are numeric
value: a valid value is any numeric value

# Action: discount 100 percent
$myrule->add_attribute({ name => 'operator'}, 'subtract');
$myrule->add_attribute({ name => 'function'}, 'percentage');
$myrule->add_attribute({ name => 'type'}, 'numeric');
$myrule->add_attribute({ name => 'value'}, '100');

=item *

B<Condition> The condition which is required gives the action a critera to be met before
the action can be made.

Condition requires the following attributes (operator, type, value or if type = date either a valid_from and or valid_to date .

type: valid types are numeric, date, char, result
operator: valid operator values are greater_than_equals_to, less_than_equals_to, greater_than, less_than, equals, between, like, exist
response: The responce dictates the condition's response if the condition is met.  Valid values true:false

# A condition the depends on result
$myrule->add_attribute({ name => 'type', priority => '1'}, 'result');
$myrule->add_attribute({ name => 'operator', priority => '1'}, 'exists');
$myrule->add_attribute({ name => 'value', priority => '1'}, $priority); # this would be the priority of the result rule in this case 1
$myrule->add_attribute({ name => 'response', priority => '1'}, true);

# Numeric Condition with true value greater than or equal numeric value 50.00
$myrule->add_attribute({ name => 'type'}, 'numeric');
$myrule->add_attribute({ name => 'operator'}, 'greater_than_equal_to');
$myrule->add_attribute({ name => 'value'}, 50.00);
$myrule->add_attribute({ name => 'response'}, true);

=item *

B<Result> Adding a result class to a rule allows the data from that class to be used for
defining the rule.

A result requires the following attributes (name, field, value).

name: Valid name is any result class in the Schema
field: Valid field is any field that is valid in result class
value: Valid value is reference to a record in the 
input: Input is required if using a method.

# Result: Using a method to populate a result $class->method($args);
$myrule->add_attribute({ name => 'name', priority => '1'}, 'TaxZone');
$myrule->add_attribute({ name => 'method', priority => '1'}, 'has_country');
$myrule->add_attribute({ name => 'input', priority => '1'}, '$args->{supplier_country}');

# Result: Result class ShipmentDestination primary key
$myrule->add_attribute({ name => 'name', priority => '2'}, 'ShipmentDestination');
$myrule->add_attribute({ name => 'field', priority => '2'}, 'id');
$myrule->add_attribute({ name => 'value', priority => '2'}, '1');


=back

=cut

=head1 ACCESSORS

=head2 rules_id

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

=head2 description

  data_type: 'text'
  default_value: (empty string)
  is_nullable: 0

=head2 canonical_rules_id

  This field contains the rules_id of the master rule for which it is 
  dependent. If the field is blank it is assumed to be a master rule.

  data_type: 'integer'
  is_nullable: 1

=head2 strict

  If the master rule is flagged strict no other attributes can be created
  for this rule only attribute_values.

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default_value: true
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
  "rules_id",
 {
    data_type => "integer",
    is_auto_increment => 1,
    is_nullable => 0,
  },
  "name",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "title",
  { data_type => "varchar", default_value => "", is_nullable => 0, size => 255 },
  "description",
  { data_type => "text", default_value => "", is_nullable => 0 },
  "canonical_rules_id",
  { data_type => "integer", is_nullable => 1 },
  "strict",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
  "active",
  { data_type => "boolean", default_value => \"true", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</rules_id>

=back

=cut

__PACKAGE__->set_primary_key("rules_id");

=head1 METHODS

=head2 find_rule_components

If you input rule_group_id this method will return a hash which
has all of the components of the rule.

=cut

sub find_rule_components {
    my ($self, $rule_group_id) = @_;

    my $rule_groupline_rs =  $self->result_source->schema->resultset('Rule')->search_related('RuleGroupline',
                                                                        { rule_groups_id => $rule_group_id }
                                                                                            );

    my %rule_component;

    while (my $rule_groupline = $rule_groupline_rs->next) {
        my $rule_rs = $rule_groupline->search_related('Rule');
        while (my $rule = $rule_rs->next) {
            my $canonical_rs =  $rule->search_related('canonical');
            while (my $canonical = $canonical_rs->next) {
                my $rule_attribute_rs = $rule_groupline->search_related('RuleAttribute');
                while (my $rule_attribute = $rule_attribute_rs->next) {
                   my $attribute_rs = $rule_attribute->search_related('Attribute');
                   while (my $attribute = $attribute_rs->next) {
                        my $attr_name = $attribute->name;
                        my $attr_priority = $attribute->priority;
                        my $attribute_value = $rule->find_attribute_value({name => $attr_name, priority => $attr_priority}, {object => 1});
                        $rule_component{$attr_priority}{$canonical->name}{$attr_name} =  $attribute_value->value;
                        
                   }
               }
           }
        }
    }
    return \%rule_component;
}

    #TODO
    # search the object for the requires attributes (name, field, value) and make sure they have values.
    # the name attribute must be a result class test that is true
    # we need a method to test that a field exists in the designated class
    # we should get the definition of this field so we can give error if a rule for math is applied to a char etc
    # finally we compare the value of the defined Object field with the condition value using the condition operator
    # if it passes all this then we return ok to apply action if not we do no action.

=head2 validate_action

This method validates that the action is properly formated and sane

=cut

sub validate_action {
    my ($self, $object, $condition, $action) = @_;

    # search the action for the requires attributes and make sure they have values.

    # to be continued
}

=head1 RELATIONS

=head2 canonical

Type: belongs_to

Related object: L<Interchange6::Schema::Result::Rule>

=cut

__PACKAGE__->belongs_to(
    "canonical",
    "Interchange6::Schema::Result::Rule",
    {"foreign.rules_id" => "self.canonical_rules_id"},
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

=head2 Variant

Type: has_many

Related object: L<Interchange6::Schema::Result::Rule>

=cut

__PACKAGE__->has_many(
  "Variant",
  "Interchange6::Schema::Result::Rule",
  { "foreign.canonical_rules_id" => "self.rules_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

=head2 RuleGroupline

Type: has_many

Related object: L<Interchange6::Schema::Result::RuleGroupline>

=cut

__PACKAGE__->has_many(
  "RuleGroupline",
  "Interchange6::Schema::Result::RuleGroupline",
  { "foreign.rules_id" => "self.rules_id" },
  { cascade_copy => 0, cascade_delete => 0 },
);

1;
