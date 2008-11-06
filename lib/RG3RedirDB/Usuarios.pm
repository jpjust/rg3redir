package RG3RedirDB::Usuarios;

use base qw/DBIx::Class/;  

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('usuarios');
# Set columns in table
__PACKAGE__->add_columns(qw/uid id_grupo id_motivo_bloqueio login senha email ativado bloqueado data_cadastro data_uacesso ip_cadastro ip_uacesso/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uid/);

#
# Set relationships:
#

__PACKAGE__->belongs_to(grupo => 'RG3RedirDB::Grupos', 'id_grupo');
__PACKAGE__->belongs_to(motivo_bloqueio => 'RG3RedirDB::Motivos', 'id_motivo_bloqueio');

# has_many():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *foreign* table
__PACKAGE__->has_many(urls => 'RG3RedirDB::RedirURL', 'id_dominio');

1;
