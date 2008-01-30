use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'RG3Redir' }
BEGIN { use_ok 'RG3Redir::Controller::Redir' }

ok( request('/redir')->is_success, 'Request should succeed' );


