use strict;
use warnings;

use Data::Dumper;

#use Test::Most 'die', tests => 103;
use Test::Most 'die';
use Test::MockTime qw(:all);

use Interchange6::Schema;
use Interchange6::Schema::Populate::CountryLocale;
use Interchange6::Schema::Populate::StateLocale;
use Interchange6::Schema::Populate::Zone;
use DateTime;
use DBICx::TestDatabase;

my ( %countries, %states, %zones, %rules, %groups, $rset, $data );

my $dt = DateTime->now;

my $schema = DBICx::TestDatabase->new('Interchange6::Schema');

my $rs_rule  = $schema->resultset('Rule');
my $rs_group = $schema->resultset('RuleGroup');

# populate stuff

my $pop_countries = Interchange6::Schema::Populate::CountryLocale->new->records;
my $pop_states    = Interchange6::Schema::Populate::StateLocale->new->records;
my $pop_zones     = Interchange6::Schema::Populate::Zone->new->records;

lives_ok( sub { $schema->populate( Country => $pop_countries ) },
    "populate countries" );

lives_ok( sub { $schema->populate( State => $pop_states ) },
    "populate states" );

lives_ok( sub { $schema->populate( Zone => $pop_zones ) }, "populate zones" );

# put countries, states and zones into hashes to save lots of lookups later

$rset = $schema->resultset('Country')->search( {} );
while ( my $res = $rset->next ) {
    $countries{ $res->country_iso_code } = $res;
}

$rset = $schema->resultset('State')->search( {} );
while ( my $res = $rset->next ) {
    $states{ $res->country_iso_code . "_" . $res->state_iso_code } = $res;
}

$rset = $schema->resultset('Zone')->search( {} );
while ( my $res = $rset->next ) {
    $zones{ $res->zone } = $res;
}

# let's create some rules!

lives_ok( sub {
    $groups{tax} = $rs_group->create({
        name => 'tax',
        title => 'Tax',
    })},
    "create rule group: tax"
);

$data = [
    {
        group => 'tax',
        priority => 200,
        name => 'Malta VAT Reduced',
        description => 'Local sales in Malta that are subject to reduced VAT',
        object => [
            [ { name => 'name'  }, 'CartProduct' ],
            [ { name => 'field' }, 'subtotal' ],
        ],
        action => [
            [ { name => 'type' }, 'result' ],
            [ { name => 'name' }, 'Tax' ],
            [ { name => 'method' }, 'calculate' ],
        ],
        condition => [
            [
                [ { name => 'type'     }, 'result' ],
                [ { name => 'operator' }, 'equals' ],
                [ { name => 'value'    }, 'true' ],
            ],
            [
                [ { name => 'type'     }, 'char' ],
                [ { name => 'operator' }, 'equals' ],
                [ { name => 'value'    }, 'book' ],
                [ { name => 'input'    }, '{$args->product_type}' ],
            ],
        ],
        result => [
            [
                [ { name => 'name'   }, 'Zone' ],
                [ { name => 'field'  }, 'zone' ],
                [ { name => 'value'  }, 'MT' ],
                [ { name => 'method' }, 'has_country' ],
                [ { name => 'input'  }, '$args->{supplier_country}' ],
            ],
            [
                [ { name => 'name'   }, 'Zone' ],
                [ { name => 'field'  }, 'zone' ],
                [ { name => 'value'  }, 'MT' ],
                [ { name => 'method' }, 'has_country' ],
                [ { name => 'input'  }, '$args->{customer_country}' ],
            ],
        ],
    },
];

done_testing;

__END__

$data = {
    name          => 'Malta sale',
    customer_zone => $zones{Malta},
    supplier_zone => $zones{Malta},
    product_type  => 'book',
    tax_code      => 'MT VAT Reduced',
    last_rule     => 1,
    priority      => 200,
};

