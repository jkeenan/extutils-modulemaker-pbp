# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More tests => 2;

BEGIN { use_ok( 'ExtUtils::ModuleMaker::PBP' ); }

my $object = ExtUtils::ModuleMaker::PBP->new ();
isa_ok ($object, 'ExtUtils::ModuleMaker::PBP');


