use Encode 'encode';
use Mojo::Base -strict;
use Mojo::ByteStream 'b';
use Mojo::Transaction::HTTP;
use Mojo::URL;
use Test::More;
use YAML::XS 'Load';

my $TEST_DATA = do {
    local $/;                  # slurp mode
    Load(encode('utf-8', <DATA>));  # wants utf8-octets
};

our $ROLE = 'Mojo::UserAgent::Role::LinkedIn::Restli2';
our $CLASS = 'Mojo::UserAgent';

use_ok $CLASS;

my $unit;

subtest $unit = restli2 => sub {
    my $ua = $CLASS->with_roles($ROLE)->new;

    can_ok $ua, 'protocol_version' and
    is $ua->protocol_version, '2.0.0', 'right protocol version';

    my $restli_generator = $ua->transactor->generators->{restli2};

    isa_ok $restli_generator, 'CODE', 'restli2 generator';

    my $tx = Mojo::Transaction::HTTP->new;
    $tx->req->method('GET');
    $tx->req->url(Mojo::URL->new('http://example.com'));

    my $result = $restli_generator->(undef, $tx, $TEST_DATA->{$unit}{test_data});

    isa_ok $result, ref($tx), 'right return type';
    is $tx->req->headers->header('X-Restli-Protocol-Version'), '2.0.0', 'right protocol version';
    is_deeply   # need to split and sort the result because hashes come at random order
        b($tx->req->url->query->to_string)->split('&')->sort->to_array,
        $TEST_DATA->{$unit}{expected_result},
        'right query string';
};

subtest $unit = build_tx => sub {
    my $ua = $CLASS->with_roles($ROLE)->new;
    my $url = 'https://api.linkedin.com/rest/organizationalEntityShareStatistics';
    my $tx = $ua->build_tx(GET => $url, restli2 => $TEST_DATA->{$unit}{test_data});
    my $req = $tx->req;

    is $req->headers->header('X-Restli-Protocol-Version'), '2.0.0', 'right protocol version';
    is_deeply   # need to split and sort the result because hashes come at random order
        b($req->url->query->to_string)->split('&')->sort->to_array,
        $TEST_DATA->{$unit}{expected_result},
        'right query string';
};

subtest $unit = _r2_encode => sub {
    my $code = $ROLE->can($unit);

    isa_ok $code, 'CODE', "${ROLE}::$unit";
    is $code->($TEST_DATA->{$unit}{test_data}),
        '(k1:v1,k2:value%20with%20spaces,k3:List(1,2,3),k4:value%3Awith%3Areserved%3Achar,k5:(k51:v51,k52:v52))',
        "right $unit";
};

subtest $unit = _reduced_escape => sub {
    my $code = $ROLE->can($unit);

    isa_ok $code, 'CODE', "${ROLE}::$unit";
    is $code->('value:with:reserved:char'), 'value%3Awith%3Areserved%3Achar', "right $unit";
    is $code->('value with spaces'), 'value with spaces', "right $unit";
    is $code->(q('You too, my "son" urn:li:person:666?')),
        qq(%27You too%2C my "son" urn%3Ali%3Aperson%3A666?%27), "right $unit";
};

done_testing;

__END__
---
restli2_test_data: &restli2_test_data {
    "k1": "v1",
    "k2": "value with spaces",
    "k3": [1, 2, 3],
    "k4": "value:with:reserved:char",
    "k5":
    {
        "k51": "v51",
        "k52": "v52"
    }
}

test_output:
    - k1:v1
    - k2:value%20with%20spaces
    - k3:List(1,2,3)
    - k4:value%3Awith%3Areserved%3Achar
    - k5:
        - k51:v51
        - k52:v52

restli2: &restli2
    test_data:
        {
            "q": "organizationalEntity",
            "organizationalEntity": "urn:li:organization:2414183",
            "shares": ["urn:li:share:1234567", "urn:li:share:7654321"],
            "ugcPosts": ["urn:li:ugcPost:1234567", "urn:li:ugcPost:7654321"]
        }
    expected_result:
        - organizationalEntity=urn%3Ali%3Aorganization%3A2414183
        - q=organizationalEntity
        - shares=List(urn%3Ali%3Ashare%3A1234567,urn%3Ali%3Ashare%3A7654321)
        - ugcPosts=List(urn%3Ali%3AugcPost%3A1234567,urn%3Ali%3AugcPost%3A7654321)

build_tx: *restli2

_r2_encode:
    test_data: *restli2_test_data
