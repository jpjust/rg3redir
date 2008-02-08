package RG3Redir::Controller::Login;

use strict;
use warnings;
use base 'Catalyst::Controller';
use FindBin;
use lib "$FindBin::Bin/../..";
use EasyCat;
use POSIX qw(strftime);
use Digest::MD5 qw(md5 md5_hex md5_base64);
use Data::Random qw(:all);
use Data::Validate::Email qw(is_email is_email_rfc822);

=head1 NAME

RG3Redir::Controller::Login - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 get_frame

Retorna HTML do frame de redirecionamento.

=cut

sub get_frame : Private {
	my ($destino, $titulo, $descricao, $palavras_chaves) = @_;
	
	my $html = <<HTML
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN"
	"http://www.w3.org/TR/html4/frameset.dtd">
<HTML>
<HEAD>
<TITLE>$titulo</TITLE>
</HEAD>
<LINK rel="shortcut icon" href="http://www.rg3.net/favicon.ico">
<META name="description" content="$descricao">
<META name="keywords" content="$palavras_chaves">
<FRAMESET frameborder="0" framespacing="0" border="0" rows="0, *">
	<FRAME>
	<FRAME src="$destino">
	<NOFRAMES>
		<META http-equiv="refresh" content="0; url=$destino">
		<A href="$destino">$destino</A>
	</NOFRAMES>
</FRAMESET>
</HTML>
HTML
;

	return $html;
}

=head2 get_mail

Retorna e-mail de cadastro

=cut

sub get_mail : Private {
	my ($to, $login, $senha) = @_;
	
	my $mail = <<__MAIL__
To: $to
From: rg3\@rg3.net
Subject: Cadastro RG3.Net concluido

Bem-vindo(a) a RG3.Net!

Seu conta foi criada em nosso banco de dados. Para efetivar seu cadastro,
acesse nosso site em http://www.rg3.net e entre na sua conta com os dados
abaixo.

Nome de usuario: $login
Senha: $senha

Recomendamos alterar sua senha logo apos acessar sua conta.

Obrigado por preferir a RG3.Net.
__MAIL__
;

	return $mail;
}

=head2 index 

=cut

sub index : Private {
	my ($self, $c) = @_;

	my $username = $c->request->params->{username} || "";
	my $password = $c->request->params->{password} || "";
	
	if ($username && $password) {
		if ($c->login($username, $password)) {
			
			# Atualiza último acesso
			my $usuario = $c->model('RG3RedirDB::Usuarios')->search({uid => $c->user->uid})->first;
			$c->stash->{ip_uacesso} = $usuario->ip_uacesso;
			$c->stash->{data_uacesso} = $usuario->data_uacesso;
			
			$usuario->update({
				ip_uacesso		=> $c->req->address,
				data_uacesso	=> strftime "%Y-%m-%d %H:%M:%S", localtime
			});
			
			$c->forward('/usuarios/inicio');
			return;
		} else {
			$c->stash->{error_msg} = "Usuário e/ou senha inválidos.";
		}
	}
	
	$c->stash->{template} = 'login.tt2';
}

=head2 criar

Exibe página para criar novo login.

=cut

sub criar : Local {
	my ($self, $c) = @_;
	$c->stash->{template} = 'novo_login.tt2';
}

=head2 novo_do

Efetua o cadastro do novo usuário.

=cut

sub novo_do : Local {
	my ($self, $c) = @_;
	
	# Parâmetros
	my $p = $c->request->params;

	# Verifica se o login já existe
	if ($c->model('RG3RedirDB::Usuarios')->search({login => $p->{login}})->first) {
		$c->stash->{erro_login} = 'O nome de usuário escolhido já está cadastrado. Por favor, escolha outro nome.';
	}

	# Verifica se o e-mail já existe
	if ($c->model('RG3RedirDB::Usuarios')->search({email => $p->{email}})->first) {
		$c->stash->{erro_email} = 'Este e-mail já está cadastrado. Por favor, use outro e-mail para efetuar o cadastro.';
	}

	if (($c->stash->{erro_login}) || ($c->stash->{erro_email})) {
		$c->stash->{usuario} = $p;
		$c->forward('criar');
		return;
	}

	# Verifica se o e-mail é válido
	if (!is_email($p->{email})) {
		$p->{email} = undef;
	}

	# Cria uma senha aleatória
 	my @senha = rand_words;

	# Hash com dados
	my $dados = {
		login		=> $p->{login},
		email		=> $p->{email},
		id_grupo	=> 2,
		ip_cadastro	=> $c->req->address,
		senha		=> md5_hex($senha[0]),
	};
	
	# Valida formulário
	my $val = Data::FormValidator->check(
		$dados,
		{required => [qw(login email)]}
	);
	
	if (!$val->success()) {
		$c->stash->{val} = $val;
		$c->stash->{usuario} = $p;
		$c->forward('criar');
		return;
	}
	
	# Cria ou atualiza
	my $usuario = $c->model('RG3RedirDB::Usuarios')->update_or_create($dados);
	
	# Envia e-mail com a senha
	$c->stash->{senha} = $senha[0];
	open(SENDMAIL, '|/usr/sbin/sendmail -t -oi');
	print SENDMAIL &get_mail($usuario->email, $usuario->login, $senha[0]);
	close(SENDMAIL);
	
	# Exibe a página de conclusão
	$c->stash->{usuario} = $usuario;
	$c->stash->{template} = 'novo_login_ok.tt2';
}

=head2 go_redir

Efetuar o redirecionamento.

=cut

sub go_redir : Local {
	my ($self, $c) = @_;
	my ($url, $porta) = split(/:/, $c->req->header('Host'));

	# Remove o "www." antes do endereço
	$url =~ s/^www\.//; 

	# Separa a parte do redirecionamento da parte do domínio
	my ($parte_redir, $parte_dominio) = split(/\./, $url, 2);
	
	# Procura o redirecionamento e executa a ação
	my $dominio = $c->model('RG3RedirDB::Dominios')->search({nome => $parte_dominio})->first;
	if ($dominio) {
		my $redir = $c->model('RG3RedirDB::RedirURL')->search({id_dominio => $dominio->id, de => $parte_redir})->first;
		if ($redir) {
			my $acessos = $redir->acessos;
			$acessos++;
			$redir->update({acessos => $acessos});
			$c->response->content_type('text/html');
			$c->response->write(&get_frame($redir->para, $redir->titulo, $redir->descricao, $redir->keywords));
			$c->response->redirect('');
			return 0;
		}
	}
	
	$c->response->redirect('http://www.rg3.net/errodom');
}

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
