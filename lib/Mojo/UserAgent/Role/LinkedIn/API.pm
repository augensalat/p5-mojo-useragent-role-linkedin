package Mojo::UserAgent::Role::LinkedIn::API;

use Carp 'croak';
use Mojo::Base -role;
use Mojo::URL;

has access_token => sub { croak 'access_token is required' };

has api_version => sub { croak 'api_version is required' };

has api_base_url => 'https://api.linkedin.com/rest';

around build_tx => sub {
    my ($orig, $self) = (shift, shift);
    my $tx = $orig->($self, @_);
    my $req = $tx->req;
    my $url = Mojo::URL->new($self->api_base_url);

    $url->path->trailing_slash(1)->merge($req->url->path->leading_slash(0));
    $url->query->merge($req->url->query);
    $req->url($url)
        ->headers
        ->authorization('Bearer ' . $self->access_token)
        ->header('LinkedIn-Version' => $self->api_version);

    return $tx;
};

1;

__END__

=encoding utf8

=head1 NAME

Mojo::UserAgent::Role::LinkedIn::API - A LinkedIn role for Mojo::UserAgent

=head1 SYNOPSIS

  use Mojo::UserAgent;

  my $linkedin = Mojo::UserAgent
    ->with_roles('+LinkedIn::API')
    ->new(
      access_token => 'AQX5...',
      api_version  => '202502',
    );

=head1 DESCRIPTION

This role turns a L<Mojo::UserAgent> class into a LinkedIn API client.

It augments L<Mojo::UserAgent/build_tx> to set the correct URL, headers and
authentication for LinkedIn API requests.

=head1 ATTRIBUTES

L<Mojo::UserAgent::Role::LinkedIn::API> implements the following attributes.

=head2 access_token

  my $access_token = $linkedin->access_token;
  $linkedin        = $linkedin->access_token('AQX5...');

The OAuth 2.0 access token to use for authentication. This attribute is required.

=head2 api_base_url

  my $api_base_url = $linkedin->api_base_url;
  $linkedin        = $linkedin->api_base_url('https://api.linkedin.com/rest');

The base URL for LinkedIn API requests. Defaults to 'https://api.linkedin.com/rest'.
Any HTTP request created with a L<Mojo::UserAgent> with the C<+LinkedIn::API> role
will be merged with this URL.

=head2 api_version

  my $api_version = $linkedin->api_version;
  $linkedin       = $linkedin->api_version('202502');

=head1 SEE ALSO

