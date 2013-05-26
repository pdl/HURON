#!perl -T

use Test::More tests => 2;

BEGIN {
    use_ok( 'HURON' ) || print "Bail out!\n";
    use_ok( 'HURON::RecDescent' ) || print "Bail out!\n";
}

diag( "Testing HURON $HURON::VERSION, Perl $], $^X" );
