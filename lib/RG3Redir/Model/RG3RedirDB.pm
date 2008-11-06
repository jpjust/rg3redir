package RG3Redir::Model::RG3RedirDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'RG3RedirDB',
    connect_info => [
        'dbi:mysql:database=rg3;host=200.166.122.3',
        'rg3',
        'cUid64ZZpw',
        { AutoCommit => 1 },
    ],
);

=head1 NAME

RG3Redir::Model::RG3RedirDB - Catalyst DBIC Schema Model
=head1 SYNOPSIS

See L<RG3Redir>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<RG3RedirDB>

=head1 AUTHOR

Joao Paulo Just,,,

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
