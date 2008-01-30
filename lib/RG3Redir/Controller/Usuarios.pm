package RG3Redir::Controller::Usuarios;

use strict;
use warnings;
use base 'Catalyst::Controller';
use Data::FormValidator;

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
	$c->stash->{error_msg} = 'Você não tem permissão para acessar este recurso.';
	$c->forward('inicio');
}

=head2 inicio

Exibe a página inicial.

=cut

sub inicio : Local {
	my ($self, $c) = @_;
	$c->stash->{usuario} = $c->user;
	$c->stash->{urls} = [$c->model('RG3RedirDB::RedirURL')->search({uid => $c->user->uid})];
	$c->stash->{mails} = [$c->model('RG3RedirDB::RedirMail')->search({uid => $c->user->uid})];
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
	
	# Hash com alterações
	my $dados = {
		email	=> $p->{email},
	};
	
	# Verifica as senhas
	if ($p->{pwd1} ne '') {
		if ($p->{pwd1} eq $p->{pwd2}) {
			$dados->{senha} = $p->{pwd1};
		} else {
			$c->stash->{error_msg} = 'As senhas digitadas não coincidem.';
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
	$c->stash->{status_msg} = 'Dados salvos com sucesso.';
	$c->forward('/usuarios/inicio');
}

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
