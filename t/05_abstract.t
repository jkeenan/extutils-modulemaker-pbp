# t/05_abstract.t
use strict;
local $^W = 1;
use Test::More 
tests =>  35;
# qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker::PBP' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Utility', qw( 
        _preexists_mmkr_directory
        _make_mmkr_directory
        _restore_mmkr_dir_status
    )
);
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        _process_personal_defaults_file 
        _reprocess_personal_defaults_file 
    )
);

my $odir = cwd();

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with Perl 5.6", 
        (35 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use ExtUtils::ModuleMaker::Auxiliary qw(
        read_file_string
        six_file_tests
    );

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ########################################################################

    my $mmkr_dir_ref = _preexists_mmkr_directory();
    my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
    ok( $mmkr_dir, "personal defaults directory now present on system");

    my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
    my $pers_def_ref = 
        _process_personal_defaults_file( $mmkr_dir, $pers_file );

    my $mod;
    my $testmod = 'Beta';

    ok( 
        $mod = ExtUtils::ModuleMaker::PBP->new( 
            NAME           => "Alpha::$testmod",
            ABSTRACT       => 'Test of the capacities of EU::MM',
            CHANGES_IN_POD => 1,
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => 'PTBLUSTER',
            ORGANIZATION   => 'Peanut Gallery',
            WEBSITE        => 'http://www.anonymous.com/~phineas',
            EMAIL          => 'phineas@anonymous.com',
        ),
        "call ExtUtils::ModuleMaker::PBP->new for Alpha-$testmod"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );

    ok(  -d, "directory $_ exists" ) for ( qw/lib t/);
    ok(! -d, "directory $_ does not exist" ) for ( qw/scripts/);

    ok(  -f $_, "file $_ exists") for (qw/LICENSE Makefile.PL MANIFEST README/);
    ok(! -f $_, "$_ file correctly not created") for (qw/Todo Changes/);

    my ($filetext);
    ok($filetext = read_file_string('Makefile.PL'),
        'Able to read Makefile.PL');
    ok($filetext =~ m|AUTHOR\s+=>\s+.Phineas\sT.\sBluster|,
        'Makefile.PL contains correct author');
    ok($filetext =~ m|AUTHOR.*<phineas\@anonymous\.com>|,
        'Makefile.PL contains correct e-mail');

    six_file_tests(8, $testmod); # first arg is # entries in MANIFEST

    _reprocess_personal_defaults_file($pers_def_ref);

    ok(chdir $odir, 'changed back to original directory after testing');

    ok( _restore_mmkr_dir_status($mmkr_dir_ref),
        "original presence/absence of .modulemaker directory restored");

} # end SKIP block

