package Interchange6::Schema::Base::Message;

=head1 NAME

Interchange6::Schema::Base::Message

=cut

use strict;
use warnings;

use base 'DBIx::Class';
use Sub::Quote qw/quote_sub/;

=head1 DESCRIPTION

The Message base class is consumed by classes with message relationships like L<Interchange6::Schema::Result::OrderComment> in order to provide convenience accessors to L<Interchange6::Schema::Result::Message>. This class also pushes overloaded delete and update methods into the consuming class.

FIXME: We should probably also overload insert if we're going to go crazy like this.

=head1 SYNOPSIS

Create a link table between Foo and Message for foo messages which can also have extra accessors. The link table must have a relation named 'message' to connect it to the Message class and also an appropriate relation with the calling class:

    package FooMessage;

    use base qw(DBIx::Class::Core Interchange6::Schema::Base::Message);

    __PACKAGE__->table("foo_messages");

    __PACKAGE__->add_columns(
        "messages_id",
        { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
        "foos_id",
        { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
        "additional_accessor",
        { data_type => "text", is_nullable => 1 },
    );

    __PACKAGE__->set_primary_key( "messages_id", "foos_id" );

    __PACKAGE__->belongs_to(
        "message",
        "Interchange6::Schema::Result::Message",
        "messages_id",
    );

    __PACKAGE__->belongs_to(
        "foo",
        "Interchange6::Schema::Result::Foo",
        "foos_id",
    );

The Message class needs to have a might_have relationship with FooMessage:

    package Message;

    __PACKAGE__->might_have(
        'foo_message',
        'Interchange6::Schema::Result::FooMessage',
        'messages_id',
    );

And the calling Foo class (if there is such a thing) should have an appropriate relationship:

    package Foo;

    __PACKAGE__->has_many(
        'foo_messages',
        'Interchange6::Schema::Result::FooMessage',
        'foos_id',
    );

=cut;

my $caller = caller(2);

# install accessors in calling method for each accessor in Message
# FIXME: should do this in a better way with accessors pulled from Message

my @message_accessors = qw(title uri content author recommend public approved
  approved_by created last_modified);

foreach my $accessor (@message_accessors) {

    my $code = q{
        my ( $self, $value ) = @_;
        if ( @_ > 1 ) {
            $self->message->$col($value);
        }
        else {
            $self->message->$col;
        }
    };
    quote_sub "${caller}::$accessor", $code, { '$col' => \$accessor };
}

# update method in caller should also call update on Message
# FIXME: should we really be doing all of this method overloading?

my $update_code = q{
    my ($self, $args) = @_;

    my $guard = $self->result_source->schema->txn_scope_guard;

    if ( @_ > 1 ) {
        $self->throw_exception("argument to update must be a hashref")
            unless ref($args) eq 'HASH';

        foreach my $key ( keys %$args ) {
            if ( grep { $_ eq $key } @ma ) {
                $self->$key($args->{$key});
                delete $args->{$key};
            }
        }
    }
    $self->message->update;
    $self->next::method($args);
    $guard->commit;
};
quote_sub "${caller}::update", $update_code, { '@ma' => \@message_accessors };

# delete method in caller should also call delete on Message

my $delete_code = q{
    my $self = shift;
    my $guard = $self->result_source->schema->txn_scope_guard;
    $self->message->delete;
    $self->next::method;
    $guard->commit;
};
quote_sub "${caller}::delete", $delete_code;

=head1 ACCESSORS

Convenience accessors exist for all accessors in L<Interchange::Schema::Result::Message> except for the PK.

In addition we overload the L</delete> and L</update> result methods in the consuming class.

I<NOTE:> These overloaded methods operate only on Row objects and not on ResultSets.

=head2 delete

Calling C<delete> on a row in the consuming class will also delete the related L<Message|Interchange6::Schema::Result::Message> row.

=head2 update

When called without arguments this causes update to be called on the row from the consuming class and also on the related <Message|Interchange6::Schema::Result::Message> row.

When called with a hashref of columns to be updated this allows use of a flat hashref which will update columns of the row in the consuming class and also of the  related <Message|Interchange6::Schema::Result::Message> row without the need for multicreate-style hash. For example:

  $result->update({ foo => 30, content => "some content" });

rather then having to remember which column is in the consuming class and which is in message:
  
  $result->update({ foo => 30, message => { content => "some content" } });

The updates are performed within transactions so either both succeed or both fail.

=cut

1;
