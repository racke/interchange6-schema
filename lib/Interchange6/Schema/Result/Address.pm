use utf8;
package Interchange6::Schema::Result::Address;

=head1 NAME

Interchange6::Schema::Result::Address

=cut

use Interchange6::Schema::Candy -components =>
  [qw(InflateColumn::DateTime TimeStamp)];

=head1 ACCESSORS

=head2 addresses_id

Primary key.

=cut

primary_column addresses_id => {
    data_type         => "integer",
    is_auto_increment => 1,
    sequence          => "addresses_addresses_id_seq",
};

=head2 users_id

Foreign key constraint on L<Interchange6::Schema::Result::User/users_id>
via L</user> relationship.

=cut

column users_id => {
    data_type      => "integer",
    is_foreign_key => 1,
};

=head2 type

Address L</type> for such things as "billing" or "shipping". Defaults to
empty string.

=cut

column type => {
    data_type     => "varchar",
    default_value => "",
    size          => 16,
};

=head2 archived

Boolean indicating that address has been archived and so should no longer
appear in normal address listings.

=cut

column archived => {
    data_type     => "boolean",
    default_value => 0,
};

=head2 first_name

First name of person associated with address. Defaults to empty string.

=cut

column first_name => {
    data_type     => "varchar",
    default_value => "",
    size          => 255,
};

=head2 last_name

Last name of person associated with address. Defaults to empty string.

=cut

column last_name => {
    data_type     => "varchar",
    default_value => "",
    size          => 255,
};

=head2 company

Company name associated with address. Defaults to empty string.

=cut

column company => {
    data_type     => "varchar",
    default_value => "",
    size          => 255,
};

=head2 address

First line of address. Defaults to empty string.

=cut

column address => {
    data_type     => "varchar",
    default_value => "",
    size          => 255,
};

=head2 address_2

Second line of address. Defaults to empty string.

=cut

column address_2 => {
    data_type     => "varchar",
    default_value => "",
    size          => 255,
};

=head2 postal_code

Postal/zip code. Defaults to empty string.

=cut

column postal_code => {
    data_type     => "varchar",
    default_value => "",
    size          => 255,
};

=head2 city

City/town name. Defaults to empty string.

=cut

column city => {
    data_type     => "varchar",
    default_value => "",
    size          => 255,
};

=head2 phone

Telephone number. Defaults to empty string.

=cut

column phone => {
    data_type     => "varchar",
    default_value => "",
    size          => 32,
};

=head2 states_id

Foreign key constraint on L<Interchange6::Schema::Result::State/states_id>
via L</state> relationship. NULL values are allowed.

=cut

column states_id => {
    data_type      => "integer",
    is_foreign_key => 1,
    is_nullable    => 1,
};

=head2 country_iso_code

Two character country ISO code. Foreign key constraint on
L<Interchange6::Schema::Result::Country/country_iso_code> via L</country>
relationship.

=cut

column country_iso_code => {
    data_type      => "char",
    is_foreign_key => 1,
    size           => 2,
};

=head2 created

Date and time when this record was created returned as L<DateTime> object.
Value is auto-set on insert.

=cut

column created => {
    data_type     => "datetime",
    set_on_create => 1,
};

=head2 last_modified

Date and time when this record was last modified returned as L<DateTime> object.
Value is auto-set on insert and update.

=cut

column last_modified => {
    data_type     => "datetime",
    set_on_create => 1,
    set_on_update => 1,
};

=head1 RELATIONS

=head2 orderlines_shipping

Type: has_many

Related object: L<Interchange6::Schema::Result::OrderlinesShipping>

=cut

has_many
  orderlines_shipping => "Interchange6::Schema::Result::OrderlinesShipping",
  { "foreign.addresses_id" => "self.addresses_id" },
  { cascade_copy           => 0, cascade_delete => 0 };

=head2 orders

Type: has_many

Related object: L<Interchange6::Schema::Result::Order>

=cut

has_many
  orders => "Interchange6::Schema::Result::Order",
  { "foreign.billing_addresses_id" => "self.addresses_id" },
  { cascade_copy                   => 0, cascade_delete => 0 };

=head2 user

Type: belongs_to

Related object: L<Interchange6::Schema::Result::User>

=cut

belongs_to
  user => "Interchange6::Schema::Result::User",
  { users_id      => "users_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" };

=head2 state

Type: belongs_to

Related object: L<Interchange6::Schema::Result::State>

=cut

belongs_to
  state => "Interchange6::Schema::Result::State",
  { states_id     => "states_id" },
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" };

=head2 country

Type: belongs_to

Related object: L<Interchange6::Schema::Result::Country>

=cut

belongs_to
  country => "Interchange6::Schema::Result::Country",
  "country_iso_code",
  { is_deferrable => 1, on_delete => "CASCADE", on_update => "CASCADE" };

=head2 orderlines

Type: many_to_many

Composing rels: L</orderlines_shipping> -> orderline

=cut

many_to_many orderlines => "orderlines_shipping", "orderline";

1;
