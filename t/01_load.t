# t/01_load.t
use strict;
use warnings;
use Test::More 
tests => 11;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker' );
use_ok( 'ExtUtils::ModuleMaker::PBP' );
use_ok( 'ExtUtils::ModuleMaker::Utility', qw|
    _get_home_directory
    _preexists_mmkr_directory
    _make_mmkr_directory
    _restore_mmkr_dir_status
| );
use_ok( 'File::Spec' );
use_ok( 'File::Copy' );
# use Data::Dumper;

my ($realhome);

ok( $realhome = _get_home_directory(), 
    "HOME or home-equivalent directory found on system");

my $mmkr_dir_ref = _preexists_mmkr_directory();
my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
ok( $mmkr_dir, "personal defaults directory found on system");

my ($vol, $dirs, $file) = File::Spec->splitpath( $mmkr_dir );
my $tempdir = File::Spec->catfile( $dirs, $file . '_temp' );
ok( move ($mmkr_dir, $tempdir), 
    "personal defaults directory temporarily renamed");
my $mod = ExtUtils::ModuleMaker::PBP->new( NAME => 'Alpha::Beta' );
isa_ok($mod, 'ExtUtils::ModuleMaker');
ok( move ($tempdir, $mmkr_dir), 
    "personal defaults directory restored");

ok( _restore_mmkr_dir_status($mmkr_dir_ref),
    "original presence/absence of .modulemaker directory restored");
