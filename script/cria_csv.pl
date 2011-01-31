#!/usr/bin/perl -w

use FindBin;
use lib "$FindBin::Bin/../lib";
use RG3RedirDB;
use RG3Redir::Model::RG3RedirDB;

# Conecta no banco de dados
my $schema = RG3RedirDB->connect(
	RG3Redir::Model::RG3RedirDB->config->{connect_info}[0],
	RG3Redir::Model::RG3RedirDB->config->{connect_info}[1],
	RG3Redir::Model::RG3RedirDB->config->{connect_info}[2],
	RG3Redir::Model::RG3RedirDB->config->{connect_info}[3]
);

# Cabeçalho do arquivo
print "Dominio,Destino,Ultima atualizacao,Acessos\n";

# Abre cada domínio e seus redirecionamentos
foreach my $dominio ($schema->resultset('Dominios')->all) {
	foreach my $redir ($schema->resultset('RedirURL')->search({id_dominio => $dominio->id})) {
		print $redir->de . '.' . $dominio->nome . ',';
		print $redir->para . ',';
		print $redir->data_umod . ',';
		print $redir->acessos . "\n";
	}
}
