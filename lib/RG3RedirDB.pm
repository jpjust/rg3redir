package RG3RedirDB;

=head1 NAME 

RG3RedirDB - DBIC Schema Class

=cut

# Our schema needs to inherit from 'DBIx::Class::Schema'
use base qw/DBIx::Class::Schema/;

# Need to load the DB Model classes here.
# You can use this syntax if you want:
#    __PACKAGE__->load_classes(qw/Book BookAuthor Author/);
# Also, if you simply want to load all of the classes in a directory
# of the same name as your schema class (as we do here) you can use:
#    __PACKAGE__->load_classes(qw//);
# But the variation below is more flexible in that it can be used to 
# load from multiple namespaces.
__PACKAGE__->load_classes({
	RG3RedirDB => [qw/
		Usuarios
		Dominios
		RedirURL
		Grupos
		Motivos
	/]
});

1;
