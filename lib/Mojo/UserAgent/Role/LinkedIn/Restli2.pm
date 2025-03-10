package Mojo::UserAgent::Role::LinkedIn::Restli2;

use Mojo::Base -role;
use Mojo::JSON 'encode_json';
use Mojo::Util 'url_escape';

has protocol_version => '2.0.0';

around new => sub {
    my $orig = shift;
    my $self = $orig->(@_);

    $self->transactor->add_generator(
        restli2 => sub {
            my ($transactor, $tx, $data) = @_;
            my $req = $tx->req;
            my $headers = $req->headers;
            my $method = uc $req->method;

            if ($method eq 'GET' || $method eq 'HEAD') {
                $req->url->query->parse(_query_string($data));
            }
            else {
                $headers->content_type('application/json') unless $headers->content_type;
                $req->body(encode_json $data);
            }

            $headers->header('X-Restli-Protocol-Version' => $self->protocol_version);

            return $tx;
        }
    );

    return $self;
};

sub _query_string {
    my $data = shift;

    return join '&', map { "$_=" . _r2_encode($data->{$_}) } keys %$data;
}

sub _r2_encode {
    my $val = shift;

    # TODO: sort is actually only here for unit tests, so improve test and remove sort
    return '(' . join(',', map { url_escape($_) . ':' . _r2_encode($val->{$_}) } sort keys %$val) . ')'
        if ref $val eq 'HASH';

    return 'List(' . join(',', map { _r2_encode($_) } @$val) . ')'
        if ref $val eq 'ARRAY';

    return url_escape $val;
}

sub _r2_reduced_encode {
    my $val = shift;

    # TODO: sort is actually only here for unit tests, so improve test and remove sort
    return '(' . join(',', map { _reduced_escape($_) . ':' . _r2_encode($val->{$_}) } sort keys %$val) . ')'
        if ref $val eq 'HASH';

    return 'List(' . join(',', map { _r2_encode($_) } @$val) . ')'
        if ref $val eq 'ARRAY';

    return _reduced_escape($val);
}

sub _reduced_escape {
    my $val = shift;

    return $val =~ s/([,\(\)':])/sprintf('%%%02X', ord $1)/egr;
}

1;

__END__

=head1 NAME

Mojo::UserAgent::Role::LinkedIn::Restli2

=head1 SYNOPSIS

  use Mojo::UserAgent;

  my $linkedin = Mojo::UserAgent->with_roles('+LinkedIn::Restli2')->new;

  $linkedin->get(
    'https://api.linkedin.com/rest/organizationalEntityShareStatistics',
    restli2 => {
      q => 'organizationalEntity',
      organizationalEntity => 'urn:li:organization:2414183',
      shares => ['urn:li:share:1234567', 'urn:li:share:7654321'],
      ugcPosts => ['urn:li:ugcPost:1234567', 'urn:li:ugcPost:7654321'],
    },
  );

=head1 DESCRIPTION

This role adds the content generator C<restli2> to a L<Mojo::UserAgent> class.
The generator implements the LinkedIn Rest.li protocol 2.0 for HTTP requests.

For GET and HEAD requests, the query string is built from the data structure passed
to the generator. The example in the SYNOPSIS would result in the following query
string (line feeds added for readability):

  organizationalEntity=urn%3Ali%3Aorganization%3A2414183&
  q=organizationalEntity&
  shares=List(urn%3Ali%3Ashare%3A1234567,urn%3Ali%3Ashare%3A7654321)&
  ugcPosts=List(urn%3Ali%3AugcPost%3A1234567,urn%3Ali%3AugcPost%3A7654321)

For all other request methods, the data structure is serialized
to JSON and set as the request body.


=head1 ATTRIBUTES

=head2 protocol_version

  $ua->protocol_version('2.0.0');

The version of the Rest.li protocol to use. Defaults to '2.0.0'.

=head1 SEE ALSO

L<https://linkedin.github.io/rest.li/spec/protocol>,
L<Mojo::UserAgent/GENERATORS>
