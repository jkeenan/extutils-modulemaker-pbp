# -*- perl -*-

# t/001_load.t - check module loading and create testing directory

use Test::More 
# tests => 2;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::PBP' );
use Data::Dumper;


my $obj = ExtUtils::ModuleMaker->new(
    NAME        => 'First::Module',
    ALT_BUILD   => 'ExtUtils::ModuleMaker::PBP',
    BUILD_SYSTEM => 'Module::Build',
);
isa_ok($obj, 'ExtUtils::ModuleMaker');

warn $obj->dump_keys_except(
    qw{ USAGE_MESSAGE LicenseParts COMPOSITE }
);

ok( $obj->complete_build(), "call complete build");


