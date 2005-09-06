# t/01_load.t
use strict;
use warnings;
use Test::More 
# tests => 2;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::PBP' );
# use Data::Dumper;


my $obj = ExtUtils::ModuleMaker::PBP->new(
    NAME         => 'Second::Module',
    BUILD_SYSTEM => 'Module::Build',
);
isa_ok($obj, 'ExtUtils::ModuleMaker::PBP');

#warn $obj->dump_keys_except(
#    qw{ USAGE_MESSAGE LicenseParts COMPOSITE }
#);

ok( $obj->complete_build(), "call complete build");



