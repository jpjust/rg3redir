package RG3Redir;

use strict;
use warnings;

use Catalyst::Runtime '5.70';

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use Catalyst qw/
	ConfigLoader
	Static::Simple
	
	Authentication
	Authentication::Store::DBIC
	Authentication::Credential::Password
	Authorization::Roles
	Authorization::ACL
	
	Session
	Session::Store::FastMmap
	Session::State::Cookie
	
	I18N
	Unicode
	/;

our $VERSION = '0.10';

# Configure the application. 
#
# Note that settings in RG3Redir.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
	name => 'RG3Redir'
);

# Start the application
__PACKAGE__->setup;

#sub begin : Private {
#	my ($self, $c) = @_;
#
#	my $locale = $c->request->param('locale');
#
#	$c->response->headers->push_header('Vary' => 'Accept-Language');
#	$c->languages($locale ? [ $locale ] : undef);
#}

=head1 NAME

RG3Redir - Catalyst based application

=head1 SYNOPSIS

    script/rg3redir_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<RG3Redir::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
