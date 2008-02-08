package RG3RedirDB::RedirURL;

use base qw/DBIx::Class/;  

# Load required DBIC stuff
__PACKAGE__->load_components(qw/PK::Auto Core/);
# Set the table name
__PACKAGE__->table('redirurl');
# Set columns in table
__PACKAGE__->add_columns(qw/id uid id_dominio de para acessos data_criacao data_umod titulo descricao keywords/);
# Set the primary key for the table
__PACKAGE__->set_primary_key(qw/id/);

# Add some attributes
__PACKAGE__->resultset_attributes({order_by => 'de'});

#
# Set relationships:
#

# belongs_to():
#   args:
#     1) Name of relationship, DBIC will create accessor with this name
#     2) Name of the model class referenced by this relationship
#     3) Column name in *this* table
__PACKAGE__->belongs_to(usuario => 'RG3RedirDB::Usuarios', 'uid');
__PACKAGE__->belongs_to(dominio => 'RG3RedirDB::Dominios', 'id_dominio');

1;
