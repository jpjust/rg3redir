use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'RG3Redir' }
BEGIN { use_ok 'RG3Redir::Controller::Logout' }

ok( request('/logout')->is_success, 'Request should succeed' );


