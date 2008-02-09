package RG3RedirDB::Usuarios;

use base qw/DBIx::Class/;  

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('usuarios');
# Set columns in table
__PACKAGE__->add_columns(qw/uid id_grupo login senha email ativado data_cadastro data_uacesso ip_cadastro ip_uacesso/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/uid/);

#
# Set relationships:
#

__PACKAGE__->belongs_to(grupo => 'RG3RedirDB::Grupos', 'id_grupo');

# has_many():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *foreign* table
__PACKAGE__->has_many(urls => 'RG3RedirDB::RedirURL', 'id_dominio');
__PACKAGE__->has_many(mails => 'RG3RedirDB::RedirMail', 'id_dominio');

1;
