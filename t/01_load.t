# t/01_load.t
use strict;
use warnings;
use Test::More tests =>  7;
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::PBP' );
use_ok( 'ExtUtils::ModuleMaker::MockHomeDir' );

my ($realhome, $subdir, $mmkr_dir_ref);

ok( $realhome = File::HomeDir->my_home(),
    "\$HOME or home-equivalent directory found on system");

$subdir = '.modulemaker';
$mmkr_dir_ref = ExtUtils::ModuleMaker::_get_subhome_directory_status($subdir);
(-d $mmkr_dir_ref->{abs})
    ? pass("Directory $mmkr_dir_ref->{abs} found on this system")
    : pass("Directory $mmkr_dir_ref->{abs} not found on this system");

my ($home_dir, $personal_defaults_dir);
$home_dir = ExtUtils::ModuleMaker::MockHomeDir::home_dir();
ok(-d $home_dir, "Directory $home_dir created to mock home directory");
$personal_defaults_dir = ExtUtils::ModuleMaker::MockHomeDir::personal_defaults_dir();
ok(-d $personal_defaults_dir, "Able to create directory $personal_defaults_dir for testing");
