use strict;
use warnings;
package Mojo::UserAgent::Role::LinkedIn;

our $VERSION = 'v0.1.0';

1;

__END__

=encoding utf8

=head1 NAME

Mojo::UserAgent::Role::LinkedIn - A LinkedIn role for Mojo::UserAgent

=head1 SYNOPSIS

  use Mojo::UserAgent;

  my $linkedin = Mojo::UserAgent
    ->with_roles('+LinkedIn::API')
    ->new(
      access_token => '...',
      api_version  => '202502',
    );

=head1 DESCRIPTION

This module is a placeholder for the LinkedIn role for L<Mojo::UserAgent>.

=head1 SEE ALSO

L<Mojo::UserAgent>, L<Mojo::UserAgent::Role::LinkedIn::API>
