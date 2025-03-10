use Mojo::Base -strict;
use Mojo::URL;
use Test::Fatal;
use Test::More;

our $ROLE = 'Mojo::UserAgent::Role::LinkedIn::API';
our $CLASS = 'Mojo::UserAgent';

use_ok $CLASS;

my $unit;

subtest $unit = api => sub {
    my $ua = $CLASS->with_roles($ROLE)->new;

    can_ok $ua, 'access_token' and
    like exception { $ua->access_token }, qr/\A\Qaccess_token is required\E/, 'right required failure';

    can_ok $ua, 'api_base_url' and
    is $ua->api_base_url, 'https://api.linkedin.com/rest', 'right default base url';

    can_ok $ua, 'api_version' and
    like exception { $ua->api_version }, qr/\A\Qapi_version is required\E/, 'right required failure';
};

subtest $unit = build_tx => sub {
    my $ua = $CLASS->with_roles($ROLE)->new(
        access_token => 'AQX5abc456',
        api_version  => '202502',
    );
    my $query = {q => 'author', author => 'urn:li:organization:2414183'};
    my $tx = $ua->build_tx(GET => '/posts', form => $query);

    is_deeply $tx->req->url,
        Mojo::URL->new('https://api.linkedin.com/rest/posts')->query($query),
        'right url';
    is $tx->req->headers->authorization, 'Bearer AQX5abc456', 'right authorization header';
    is $tx->req->headers->header('LinkedIn-Version'), '202502', 'right LinkedIn-Version header';
};

done_testing;
