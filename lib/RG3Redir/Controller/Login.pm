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
<META http-equiv="content-type" content="text/html; charset=UTF-8">
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

=head2 mail_cadastro

Envia e-mail de cadastro

=cut

sub mail_cadastro : Private {
	my ($c, $to, $login, $senha) = @_;

	my $mail = "To: $to\n" .
		"From: rg3\@rg3.net\n" .
		$c->loc("Subject: RG3.Net registration\n\n") .
		$c->loc("Welcome to RG3.Net!\n\n") .
		$c->loc("Your account has been created. To activate it, go to http://www.rg3.net and log into your account using the username and password below.\n\n") .
		$c->loc("Username: [_1]\n", $login) .
		$c->loc("Password: [_1]\n\n", $senha) .
		$c->loc("We recommend you change this password as soon as you log into your account.\n\n") .
		$c->loc("Thank you for preferring RG3.Net.\n");

	open(SENDMAIL, '|/usr/sbin/sendmail -t -oi');
	print SENDMAIL $mail;
	close(SENDMAIL);
}

=head2 mail_resgate

Envia e-mail de resgate de senha

=cut

sub mail_resgate : Private {
	my ($c, $to, $login, $senha) = @_;
	
	my $mail = "To: $to\n" .
		"From: rg3\@rg3.net\n" .
		$c->loc("Subject: RG3.Net password recovery\n\n") .
		$c->loc("Hello, [_1].\n\n", $login) .
		$c->loc("As requested, a new password has been generated.\n\n") .
		$c->loc("Username: [_1]\n", $login) .
		$c->loc("Password: [_1]\n\n", $senha) .
		$c->loc("We recommend you change this password as soon as you log into your account.\n");

	open(SENDMAIL, '|/usr/sbin/sendmail -t -oi');
	print SENDMAIL $mail;
	close(SENDMAIL);
}

=head2 index 

=cut

sub index : Private {
	my ($self, $c) = @_;

	my $username = $c->request->params->{username} || "";
	my $password = $c->request->params->{password} || "";
	
	if ($username && $password) {
		if ($c->login($username, $password)) {
			
			# Verifica se a conta está bloqueada
			if ($c->user->bloqueado == 1) {
				$c->stash->{usuario} = $c->user;
				$c->stash->{template} = 'bloqueado.tt2';
				$c->logout;
				return;
			}
			
			# Atualiza último acesso
			my $usuario = $c->model('RG3RedirDB::Usuarios')->search({uid => $c->user->uid})->first;
			$c->stash->{ip_uacesso} = $usuario->ip_uacesso;
			$c->stash->{data_uacesso} = $usuario->data_uacesso;
			
			# Cria uma variável com o IP externo + IP interno (caso ele esteja acessando com um proxy)
			my $ip = $c->req->address;
			if ($c->request->header('X-Forwarded-For')) {
				$ip .= ' (' . $c->request->header('X-Forwarded-For') . ')';
			}
			
			$usuario->update({
				ativado			=> 1,
				ip_uacesso		=> $ip,
				data_uacesso	=> strftime "%Y-%m-%d %H:%M:%S", localtime
			});
			
			$c->forward('/usuarios/inicio');
			return;
		} else {
			$c->stash->{error_msg} = $c->loc("Authentication failure.");
		}
	}
	
	$c->stash->{template} = 'login.tt2';
}

=head2 termos

Exibe página com os Termos de uso do serviço.

=cut

sub termos : Local {
	my ($self, $c) = @_;
	$c->stash->{template} = 'termos.tt2';
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
		$c->stash->{erro_login} = $c->loc('The choosen username has already been taken. Please, choose another one.');
	}

	# Verifica se o e-mail já existe
	if ($c->model('RG3RedirDB::Usuarios')->search({email => $p->{email}})->first) {
		$c->stash->{erro_email} = $c->loc('The typed e-mail address has already been registered. Please, use another e-mail address.');
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
	&mail_cadastro($c, $usuario->email, $usuario->login, $senha[0]);
	
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
			# Verifica se a conta está bloqueada
			if ($redir->usuario->bloqueado == 1) {
				$c->stash->{usuario} = $redir->usuario;
				$c->stash->{template} = 'bloqueado.tt2';
				return;
			}
			
			# Contabiliza um acesso e faz o redirecionamento
			my $acessos = $redir->acessos;
			$acessos++;
			$redir->update({acessos => $acessos});
			$c->response->content_type('text/html');
			$c->response->write(&get_frame($redir->para, $redir->titulo, $redir->descricao, $redir->keywords));
			$c->response->redirect('');
			return;
		}
	}
	
	$c->response->redirect('http://www.rg3.net/');
}

=head2 esqueci

Mostra a página para recuperar a senha.

=cut

sub esqueci : Local {
	my ($self, $c) = @_;
	$c->stash->{dominios} = [$c->model('RG3RedirDB::Dominios')->all];
	$c->stash->{template} = 'esqueci.tt2';
}

=head2 resgate_login

Recupera a senha através do login.

=cut

sub resgate_login : Local {
	my ($self, $c) = @_;
	
	# Parâmetros
	my $p = $c->request->params;
	
	my $usuario = $c->model('RG3RedirDB::Usuarios')->search({login => $p->{login}})->first;
	if ($usuario) {
 		my @senha = rand_words;
 		$usuario->update({senha => md5_hex($senha[0])});
 		&mail_resgate($c, $usuario->email, $usuario->login, $senha[0]);
 		$c->stash->{usuario} = $usuario;
 		$c->stash->{template} = 'lembrei.tt2';
 	} else {
 		$c->stash->{template} = 'nao_lembrei.tt2';
 	}
}

=head2 resgate_email

Recupera a senha através do e-mail.

=cut

sub resgate_email : Local {
	my ($self, $c) = @_;
	
	# Parâmetros
	my $p = $c->request->params;
	
	my $usuario = $c->model('RG3RedirDB::Usuarios')->search({email => $p->{email}})->first;
	if ($usuario) {
 		my @senha = rand_words;
 		$usuario->update({senha => md5_hex($senha[0])});
 		&mail_resgate($c, $usuario->email, $usuario->login, $senha[0]);
 		$c->stash->{usuario} = $usuario;
 		$c->stash->{template} = 'lembrei.tt2';
 	} else {
 		$c->stash->{template} = 'nao_lembrei.tt2';
 	}
}

=head2 resgate_redir

Recupera a senha através de um redirecionamento.

=cut

sub resgate_redir : Local {
	my ($self, $c) = @_;
	
	# Parâmetros
	my $p = $c->request->params;
	
	my $redir = $c->model('RG3RedirDB::RedirURL')->search({de => $p->{redir}, id_dominio => $p->{dominio}})->first;
	if ($redir) {
 		my @senha = rand_words;
 		my $usuario = $redir->usuario;
 		$usuario->update({senha => md5_hex($senha[0])});
 		&mail_resgate($c, $usuario->email, $usuario->login, $senha[0]);
 		$c->stash->{usuario} = $usuario;
 		$c->stash->{template} = 'lembrei.tt2';
 	} else {
 		$c->stash->{template} = 'nao_lembrei.tt2';
 	}
}

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
