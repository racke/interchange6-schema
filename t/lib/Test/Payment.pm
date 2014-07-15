package Test::Payment;

use Test::Exception;
use Test::More;
use Test::Roo::Role;

test 'payment tests' => sub {
    my $self = shift;

    my $schema = $self->schema;

    lives_ok(
        sub {
            $schema->resultset("User")->create({
                    username => 'Some user',
                    password => 'tryme',
                })
        }, "Create user"
    );

    lives_ok(
        sub {
            $schema->resultset("Session")->create({
                    sessions_id => '123412341234',
                    session_data => '',
                })
        }, "Create session"
    );

    my %insertion = (
        payment_mode   => 'PayPal',
        payment_action => 'charge',
        status         => 'request',
        sessions_id    => '123412341234',
        amount         => '10.00',
        payment_fee    => 1.00,
        users_id       => '1',
    );

    my $payment;
    lives_ok(
        sub {
            $payment =
              $schema->resultset('PaymentOrder')->create( \%insertion );
        },
        "Insert payment into db"
    );

    ok( $payment->payment_fee == 1 );

};

1;