package RG3Redir::Controller::Usuarios;

use strict;
use warnings;
use base 'Catalyst::Controller';
use FindBin;
use lib "$FindBin::Bin/../..";
use EasyCat;
use Data::FormValidator;
use Data::Validate::Email qw(is_email is_email_rfc822);
use Digest::MD5 qw(md5 md5_hex md5_base64);

=head1 NAME

RG3Redir::Controller::Usuarios - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ($self, $c) = @_;
	$c->forward('inicio');
}

=head2 access_denied

Handle Catalyst::Plugin::Authorization::ACL access denied exceptions

=cut

sub access_denied : Private {
	my ($self, $c) = @_;
	$c->stash->{error_msg} = $c->loc('You are not allowed to access this resource.');
	$c->forward('inicio');
}

=head2 inicio

Exibe a página inicial.

=cut

sub inicio : Local {
	my ($self, $c) = @_;
	$c->stash->{usuario} = $c->user;
	$c->stash->{urls} = [$c->model('RG3RedirDB::RedirURL')->search({uid => $c->user->uid})];
	$c->stash->{template} = 'usuarios/inicio.tt2';
}

=head2 editar

Exibe a página para alterar dados da conta.

=cut

sub editar : Local {
	my ($self, $c) = @_;
	$c->stash->{usuario} = $c->user;
	$c->stash->{template} = 'usuarios/editar.tt2';
}

=head2 editar_do

Salva as alterações da conta.

=cut

sub editar_do : Local {
	my ($self, $c) = @_;

	# Parâmetros
	my $p = $c->request->params;
	
	# Verifica se o e-mail é válido
	if (!is_email($p->{email})) {
		$p->{email} = undef;
	}

	# Verifica se o e-mail já existe
	my $ver = $c->model('RG3RedirDB::Usuarios')->search({email => $p->{email}})->first;
	if (($ver) && ($ver->uid != $c->user->uid)) {
		$c->stash->{error_msg} = $c->loc('The typed e-mail address has already been registered. Please, use another one to update your registry.');
		$c->forward('editar');
		return;
	}

	# Hash com alterações
	my $dados = {
		email	=> $p->{email},
	};
	
	# Verifica as senhas
	if ($p->{pwd1} ne '') {
		if ($p->{pwd1} eq $p->{pwd2}) {
			$dados->{senha} = md5_hex($p->{pwd1});
		} else {
			$c->stash->{error_msg} = $c->loc("The typed passwords don't match.");
			$c->forward('editar');
			return;
		}
	}

	# Valida formulário
	my $val = Data::FormValidator->check(
		$dados,
		{required => [qw(email)]}
	);
	
	if (!$val->success()) {
		$c->stash->{val} = $val;
		$c->forward('editar');
		return;
	}
	
	# Atualiza
	my $usuario = $c->model('RG3RedirDB::Usuarios')->search({uid => $c->user->uid})->first;
	$usuario->update($dados);
	
	# Volta para a página inicial
	$c->stash->{status_msg} = $c->loc('Data successfully saved.');
	$c->forward('/usuarios/inicio');
}

=head2 excluir

Exibe a página para excluir uma conta.

=cut

sub excluir : Local {
	my ($self, $c) = @_;
	$c->stash->{usuario} = $c->user;
	$c->stash->{redirs} = [$c->model('RG3RedirDB::RedirURL')->search({uid => $c->user->uid})];
	$c->stash->{template} = 'usuarios/excluir.tt2';
}

=head2 excluir_do

Exclui a conta do usuário.

=cut

sub excluir_do : Local {
	my ($self, $c) = @_;

	# Parâmetros
	my $p = $c->request->params;
	
	# Apaga os redirecionamentos do usuário
	$c->model('RG3RedirDB::RedirURL')->search({uid => $c->user->uid})->delete;
	
	# Apaga a conta do usuário
	$c->model('RG3RedirDB::Usuarios')->search({uid => $c->user->uid})->delete;
	
	# Efetua logout e vai embora
	$c->logout;
	$c->response->redirect($c->uri_for('/'));
}

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
