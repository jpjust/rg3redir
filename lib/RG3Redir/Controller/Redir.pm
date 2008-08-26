package RG3Redir::Controller::Redir;

use strict;
use warnings;
use base 'Catalyst::Controller';
use POSIX qw(strftime);

=head1 NAME

RG3Redir::Controller::Redir - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index 

=cut

sub index : Private {
    my ($self, $c) = @_;
    $c->forward('lista');
}

=head2 lista

Exibe a página com a lista de redirecionamentos.

=cut

sub lista : Local {
	my ($self, $c) = @_;
	$c->stash->{urls} = [$c->model('RG3RedirDB::RedirURL')->search({uid => $c->user->uid})];
	#$c->stash->{mails} = [$c->model('RG3RedirDB::RedirMail')->search({uid => $c->user->uid})];
	$c->stash->{template} = 'redir/lista.tt2';
}

=head2 novo_url

Exibe a página para criação de novo redirecionamento de URL.

=cut

sub novo_url : Local {
	my ($self, $c) = @_;
	$c->stash->{dominios} = [$c->model('RG3RedirDB::Dominios')->all];
	$c->stash->{template} = 'redir/novo_url.tt2';
}

=head2 editar_url

Exibe a página para edirção de um redirecionamento de URL.

=cut

sub editar_url : Local {
	my ($self, $c, $id) = @_;
	$c->stash->{redir} = $c->model('RG3RedirDB::RedirURL')->search({uid => $c->user->uid, id => $id})->first;
	$c->stash->{dominios} = [$c->model('RG3RedirDB::Dominios')->all];
	$c->stash->{template} = 'redir/novo_url.tt2';
}

=head2 novo_url_do

Salva as alterações do redirecionamento.

=cut

sub novo_url_do : Local {
	my ($self, $c) = @_;

	# Parâmetros
	my $p = $c->request->params;
	
	# Permite apenas caracteres alfanuméricos, traços e underlines no nome do redirecionamento
	$p->{de} = undef if ($p->{de} !~ /^[a-zA-Z0-9_-]+$/);
	
	# Não permite tags HTML em nenhuma variável que irá para o código HTML do redirecionamento
	$p->{para}		= undef if ($p->{para} =~ /[\"<>]/);
	$p->{titulo}	= undef if ($p->{titulo} =~ /[\"<>]/);
	$p->{descricao}	= undef if ($p->{descricao} =~ /[\"<>]/);
	$p->{keywords}	= undef if ($p->{keywords} =~ /[\"<>]/);

	# Verifica se o redirecionamento já existe
	my $ver = $c->model('RG3RedirDB::RedirURL')->search({de => $p->{de}, id_dominio => $p->{dominio}})->first;
	if (($ver) && ($ver->id != $p->{id})) {
		$c->stash->{erro_redir} = 'O redirecionamento escolhido já está cadastrado. Por favor, escolha outro nome.';
		$c->stash->{redir} = $p;
		$c->forward('novo_url');
		return;
	}

	# Hash com alterações
	my $dados = {
		id			=> $p->{id} || -1,
		uid			=> $c->user->uid,
		de			=> $p->{de},
		id_dominio	=> $p->{dominio},
		para		=> $p->{para},
		titulo		=> $p->{titulo},
		descricao	=> $p->{descricao},
		keywords	=> $p->{keywords},
		data_umod	=> strftime "%Y-%m-%d %H:%M:%S", localtime,
	};
	
	# Valida formulário
	my $val = Data::FormValidator->check(
		$dados,
		{required => [qw(uid de id_dominio para)]}
	);
	
	if (!$val->success()) {
		$c->stash->{val} = $val;
		$c->stash->{redir} = $p;
		$c->forward('novo_url');
		return;
	}
	
	# Cria ou atualiza
	my $redir = $c->model('RG3RedirDB::RedirURL')->update_or_create($dados);
	
	# Volta para a página inicial
	$c->stash->{status_msg} = 'Redirecionamento criado/alterado com sucesso.';
	$c->forward('/redir/lista');
}

=head2 excluir_url

Apaga um redirecionamento de URL.

=cut

sub excluir_url : Local {
	my ($self, $c, $id) = @_;
	my $redir = $c->model('RG3RedirDB::RedirURL')->search({uid => $c->user->uid, id => $id})->first;
	if ($redir) {
		$redir->delete;
		$c->stash->{error_msg} = 'Redirecionamento excluído.';
	} else {
		$c->stash->{error_msg} = 'Redirecionamento não encontrado.';
	}
	$c->forward('lista');
}

=head2 novo_mail

Exibe a página para criação de novo redirecionamento de e-mail.

=cut

sub novo_mail : Local {
	my ($self, $c) = @_;
	$c->stash->{dominios} = [$c->model('RG3RedirDB::Dominios')->all];
	$c->stash->{template} = 'redir/novo_mail.tt2';
}

=head2 editar_mail

Exibe a página para edirção de um redirecionamento de e-mail.

=cut

sub editar_mail : Local {
	my ($self, $c, $id) = @_;
	$c->stash->{redir} = $c->model('RG3RedirDB::RedirMail')->search({uid => $c->user->uid, id => $id})->first;
	$c->stash->{dominios} = [$c->model('RG3RedirDB::Dominios')->all];
	$c->stash->{template} = 'redir/novo_mail.tt2';
}

=head2 novo_mail_do

Salva as alterações do redirecionamento.

=cut

sub novo_mail_do : Local {
	my ($self, $c) = @_;

	# Parâmetros
	my $p = $c->request->params;
	
	# Verifica se o redirecionamento já existe
	if ($c->model('RG3RedirDB::RedirMail')->search({de => $p->{de}, id_dominio => $p->{dominio}})->first) {
		$c->stash->{erro_redir} = 'O redirecionamento escolhido já está cadastrado. Por favor, escolha outro nome.';
		$c->stash->{redir} = $p;
		$c->forward('novo_mail');
		return;
	}

	# Hash com alterações
	my $dados = {
		id			=> $p->{id} || -1,
		uid			=> $c->user->uid,
		de			=> $p->{de},
		id_dominio	=> $p->{dominio},
		para		=> $p->{para},
		data_umod	=> strftime "%Y-%m-%d %H:%M:%S", localtime,
	};
	
	# Valida formulário
	my $val = Data::FormValidator->check(
		$dados,
		{required => [qw(uid de id_dominio para)]}
	);
	
	if (!$val->success()) {
		$c->stash->{val} = $val;
		$c->stash->{redir} = $p;
		$c->forward('novo_mail');
		return;
	}
	
	# Cria ou atualiza
	my $redir = $c->model('RG3RedirDB::RedirMail')->update_or_create($dados);
	
	# Volta para a página inicial
	$c->stash->{status_msg} = 'Redirecionamento criado/alterado com sucesso.';
	$c->forward('/redir/lista');
}

=head2 excluir_mail

Apaga um redirecionamento de e-mail.

=cut

sub excluir_mail : Local {
	my ($self, $c, $id) = @_;
	my $redir = $c->model('RG3RedirDB::RedirMail')->search({uid => $c->user->uid, id => $id})->first;
	if ($redir) {
		$redir->delete;
		$c->stash->{error_msg} = 'Redirecionamento excluído.';
	} else {
		$c->stash->{error_msg} = 'Redirecionamento não encontrado.';
	}
	$c->forward('lista');
}

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
