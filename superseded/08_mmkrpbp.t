# t/08_mmkrpbp.t
use strict;
local $^W = 1;
use Test::More 
tests => 110;
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
        (110 - 4) if $@;
    use warnings;
    use_ok( 'File::Temp', qw| tempdir |);
    use ExtUtils::ModuleMaker::PBP::Auxiliary qw(
        check_MakefilePL 
    );

    # Simple tests of mmkrpbp utility in non-interactive mode

    my $cwd = cwd();
    my ($tdir, $topdir, @pred, $module_name, $pmfile, %pred, $filetext);

    {
        # test against Testing::Defaults

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/mmkrpbp" -In EU::MM::Testing::Defaults -a "Module abstract (<= 44 characters) goes here" -u "Hilton Stallone" -p RAMBO -o "Parliamentary Pictures" -w http://parliamentarypictures.com -e hiltons\@parliamentarypictures.com }), 
            "able to call mmkrpbp utility");

        $topdir = "EU-MM-Testing-Defaults"; 
        ok(  -d $topdir, "by default, compact top directory created");

        ok(  -d "$topdir/$_", "$_ directory created") for qw| lib t |;
        ok(! -d "$topdir/scripts", "scripts directory correctly not created");
        ok(  -f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README      |;
        ok(! -f "$topdir/Todo", "Todo file correctly not created");
        
        @pred = (
            "EU::MM::Testing::Defaults",
            "Hilton\\sStallone",
            "hiltons\@parliamentarypictures\.com",
            "lib\/EU\/MM\/Testing\/Defaults\.pm",
            "lib\/EU\/MM\/Testing\/Defaults\.pm",
        );

        check_MakefilePL($topdir, \@pred);
        ok(chdir $cwd, 'changed back to original directory after testing');

        _reprocess_personal_defaults_file($pers_def_ref);

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # suppress Personal::Defaults for duration of test
        # do not provide -t option
        # hence, you are testing against EU::MM::Defaults, which means you
        # must supply a NAME; you must also suppress interactive mode

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/mmkrpbp" -In My::Research::Module }), 
            "able to call mmkrpbp utility");

        $topdir = "My-Research-Module"; 
        ok(-d $topdir, "by default, compact top directory created");

        ok(  -d "$topdir/$_", "$_ directory created") for qw| lib t |;
        ok(! -d "$topdir/scripts", "scripts directory correctly not created");
        ok(  -f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README      |;
        ok(! -f "$topdir/Todo", "Todo file correctly not created");
        
        @pred = (
            "My::Research::Module",
            "A\.\\sU\.\\sThor",
            "a\.u\.thor\@a\.galaxy\.far\.far\.away",
            "lib\/My\/Research\/Module\.pm",
            "lib\/My\/Research\/Module\.pm",
        );

        check_MakefilePL($topdir, \@pred);

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # provide name; add in abstract

        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/mmkrpbp" -Icn XYZ::ABC -a \"This is very abstract.\"}),  #"
            "able to call mmkrpbp utility with abstract");

        $topdir = "XYZ-ABC"; 
        ok(-d $topdir, "compact top directory created");

        ok(  -d "$topdir/$_", "$_ directory created") for qw| lib t |;
        ok(! -d "$topdir/scripts", "scripts directory correctly not created");
        ok(  -f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README      |;
        ok(! -f "$topdir/Todo", "Todo file correctly not created");
        
        @pred = (
            "XYZ::ABC",
            "A\.\\sU\.\\sThor",
            "a\.u\.thor\@a\.galaxy\.far\.far\.away",
            "lib\/XYZ\/ABC\.pm",
            "lib\/XYZ\/ABC\.pm",
        );
        check_MakefilePL($topdir, \@pred);

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # provide name; add in abstract and author-name
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/mmkrpbp" -Icn XYZ::ABC -a \"This is very abstract.\" -u \"John Q Public\"}), #"
            "able to call mmkrpbp utility with abstract");

        $topdir = "XYZ-ABC"; 
        ok(-d $topdir, "compact top directory created");

        ok(  -d "$topdir/$_", "$_ directory created") for qw| lib t |;
        ok(! -d "$topdir/scripts", "scripts directory correctly not created");
        ok(  -f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README      |;
        ok(! -f "$topdir/Todo", "Todo file correctly not created");
        
        @pred = (
            "XYZ::ABC",
            "John\\sQ\\sPublic",
            "a\.u\.thor\@a\.galaxy\.far\.far\.away",
            "lib\/XYZ\/ABC\.pm",
            "lib\/XYZ\/ABC\.pm",
        );
        check_MakefilePL($topdir, \@pred);

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

    {
        # provide name and call for compact top-level directory
        # add in abstract and author-name and e-mail
        $tdir = tempdir( CLEANUP => 1);
        ok(chdir $tdir, 'changed to temp directory for testing');

        my $mmkr_dir_ref = _preexists_mmkr_directory();
        my $mmkr_dir = _make_mmkr_directory($mmkr_dir_ref);
        ok( $mmkr_dir, "personal defaults directory now present on system");

        my $pers_file = "ExtUtils/ModuleMaker/Personal/Defaults.pm";
        my $pers_def_ref = 
            _process_personal_defaults_file( $mmkr_dir, $pers_file );

        ok(! system(qq{$^X -I"$cwd/blib/lib" "$cwd/blib/script/mmkrpbp" -Icn XYZ::ABC -a \"This is very abstract.\" -u \"John Q Public\" -e jqpublic\@calamity.jane.net}),   #"
            "able to call mmkrpbp utility with abstract");

        $topdir = "XYZ-ABC"; 
        ok(-d $topdir, "compact top directory created");

        ok(  -d "$topdir/$_", "$_ directory created") for qw| lib t |;
        ok(! -d "$topdir/scripts", "scripts directory correctly not created");
        ok(  -f "$topdir/$_", "$_ file created")
            for qw| Changes LICENSE MANIFEST Makefile.PL README      |;
        ok(! -f "$topdir/Todo", "Todo file correctly not created");
        
        @pred = (
            "XYZ::ABC",
            "John\\sQ\\sPublic",
            "jqpublic\@calamity\.jane\.net",
            "lib\/XYZ\/ABC\.pm",
            "lib\/XYZ\/ABC\.pm",
        );
        check_MakefilePL($topdir, \@pred);

        _reprocess_personal_defaults_file($pers_def_ref);

        ok(chdir $cwd, 'changed back to original directory after testing');

        ok( _restore_mmkr_dir_status($mmkr_dir_ref),
            "original presence/absence of .modulemaker directory restored");

    }

} # end SKIP block

