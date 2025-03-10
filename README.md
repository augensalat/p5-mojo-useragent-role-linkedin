# NAME

Mojo::UserAgent::Role::LinkedIn - A LinkedIn role for Mojo::UserAgent

# VERSION

version v0.1.0

# SYNOPSIS

    use Mojo::UserAgent;

    my $linkedin = Mojo::UserAgent
      ->with_roles('+LinkedIn::API', '+LinkedIn::Restli2')
      ->new(
        access_token => '...',
        api_version  => '202502',
      );

# DESCRIPTION

[Mojo::UserAgent::Role::LinkedIn](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3ARole%3A%3ALinkedIn) extends [Mojo::UserAgent](https://metacpan.org/pod/Mojo%3A%3AUserAgent) for the LinkedIn
API with the help of Perl OO roles.

# SEE ALSO

[Mojo::UserAgent](https://metacpan.org/pod/Mojo%3A%3AUserAgent),
[Mojo::UserAgent::Role::LinkedIn::API](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3ARole%3A%3ALinkedIn%3A%3AAPI),
[Mojo::UserAgent::Role::LinkedIn::Restli2](https://metacpan.org/pod/Mojo%3A%3AUserAgent%3A%3ARole%3A%3ALinkedIn%3A%3ARestli2)
