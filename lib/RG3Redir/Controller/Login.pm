package RG3Redir::Controller::Login;

use strict;
use warnings;
use base 'Catalyst::Controller';
use FindBin;
use lib "$FindBin::Bin/../..";
use EasyCat;
use POSIX qw(strftime);

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

=head2 go_redir

Efetuar o redirecionamento.

=cut

sub go_redir : Local {
	my ($self, $c) = @_;
	
	my ($url, $porta) = split(/:/, $c->req->header('Host'));
	my ($parte_redir, $parte_dominio) = split(/\./, $url, 2);
	
	my $dominio = $c->model('RG3RedirDB::Dominios')->search({nome => $parte_dominio})->first;
	if ($dominio) {
		my $redir = $c->model('RG3RedirDB::RedirURL')->search({id_dominio => $dominio->id, de => $parte_redir})->first;
		if ($redir) {
			$c->response->content_type('text/html');
			$c->response->write(&get_frame($redir->para, '', '', ''));
		} else {
			$c->response->redirect('http://www.rg3.net/errodom');
		}
	}
	
	$c->finalize;
}

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
