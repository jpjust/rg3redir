package RG3Redir::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

RG3Redir::Controller::Root - Root Controller for RG3Redir

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;
}

=head2 auto

Check if there is a user and, if not, forward to login page

=cut

sub auto : Private {
	my ($self, $c) = @_;
	
	if ($c->controller eq $c->controller('Login')) {
		return 1;
	}
	
	if (!$c->user_exists) {
		$c->log->debug('***Root::auto User not found, forwarding to /login');
		$c->response->redirect($c->uri_for('/login'));
		return 0;
	}
	
	return 1;
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
