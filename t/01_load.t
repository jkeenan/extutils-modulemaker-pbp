# t/01_load.t
use strict;
use warnings;
use Test::More 
# tests => 2;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::PBP' );
# use Data::Dumper;

my ($obj1, $obj2);

$obj1 = ExtUtils::ModuleMaker::PBP->new(
    NAME         => 'First::Module',
    BUILD_SYSTEM => 'Module::Build',
);
isa_ok($obj1, 'ExtUtils::ModuleMaker::PBP');
ok( $obj1->complete_build(), "call complete build");


$obj2 = ExtUtils::ModuleMaker::PBP->new(
    NAME         => 'Second::Module',
    BUILD_SYSTEM => 'ExtUtils::MakeMaker',
    EXTRA_MODULES => [ 
        { NAME => "Second::Module::Jump" },
        { NAME => "Second::Module::Hand" },
        { NAME => "Second::Module::Hand::Rose" },
    ],
);
isa_ok($obj2, 'ExtUtils::ModuleMaker::PBP');
ok( $obj2->complete_build(), "call complete build");

#warn $obj2->dump_keys_except(
#    qw{ USAGE_MESSAGE LicenseParts COMPOSITE }
#);


__END__





