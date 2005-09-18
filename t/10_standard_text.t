# t/10_standard_text.t
# tests of importation of standard text from
# lib/ExtUtils/Modulemaker/Defaults.pm
use strict;
local $^W = 1;
use Test::More 
tests =>   36;
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

SKIP: {
    eval { require 5.006_001 };
    skip "tests require File::Temp, core with 5.6", 
        (36 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use ExtUtils::ModuleMaker::Auxiliary qw(
        read_file_string
        read_file_array
    );

    my $odir = cwd();
    my ($tdir, $mod, $testmod, $filetext, @makefilelines, @pmfilelines,
        @readmelines);

    ########################################################################

    {   
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        $testmod = 'Beta';
        
        ok( $mod = ExtUtils::ModuleMaker::PBP->new( 
                NAME           => "Alpha::$testmod",
            ),
            "call ExtUtils::ModuleMaker::PBP->new for Alpha-$testmod"
        );
        
        ok( $mod->complete_build(), 'call complete_build()' );

        ok( -d qq{Alpha-$testmod}, "compact top-level directory exists" );
        ok( chdir "Alpha-$testmod", "cd Alpha-$testmod" );

        ok(  -d, "directory $_ exists" ) for ( qw/lib t/);
        ok(! -d, "directory $_ does not exist" ) for ( qw/scripts/);
        ok( -f, "file $_ exists" )
            for ( qw/Changes LICENSE Makefile.PL MANIFEST README/);
        ok(! -f 'Todo', "Todo correctly not created");

        ok( -f, "file $_ exists" )
            for ( "lib/Alpha/${testmod}.pm", "t/00.load.t" );
        
        ok($filetext = read_file_string('Makefile.PL'),
            'Able to read Makefile.PL');
        ok(@pmfilelines = read_file_array("lib/Alpha/${testmod}.pm"),
            'Able to read module into array');

        # test of README text
        ok(@readmelines = read_file_array('README'),
            'Able to read README into array');
        is( (grep {/The README is used to introduce/} @readmelines),
            1,
            "README has correct introductory explanation");
        is( (grep {/^INSTALLATION/} @readmelines),
            1,
            "README has INSTALLATION section");
        is( (grep {/^\s+(perl Makefile\.PL|make( (test|install))?)/} 
            @readmelines), 
            4, 
            "README has appropriate build instructions for MakeMaker");
        is( (grep {/^\s+(perl Build\.PL|\.\/Build( (test|install))?)/} 
            @readmelines), 
            4, 
            "README has appropriate build instructions for Module::Build");

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $odir, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }
 
} # end SKIP block

