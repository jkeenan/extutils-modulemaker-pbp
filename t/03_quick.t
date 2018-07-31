# t/03_quick.t
use strict;
use warnings;
use Test::More tests => 60;
use Carp;
use Cwd;
use File::Spec;
use File::Temp qw(tempdir);
use_ok( 'ExtUtils::ModuleMaker::PBP' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
) );
use_ok( 'ExtUtils::ModuleMaker::MockHomeDir' );

my ($home_dir, $personal_defaults_dir) = prepare_mockdirs();
local $ENV{HOME} = $home_dir;


note("Case 1: No personal defaults file");

{
    my $cwd = cwd();

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ###########################################################################

    my $mod;

    my @components = qw| Sample Module |;
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);
    ok($mod  = ExtUtils::ModuleMaker::PBP->new ( NAME => $module_name),
        "call ExtUtils::ModuleMaker::PBP->new for $dist_name");

    ok( $mod->complete_build(), 'call complete_build()' );

    ########################################################################

    ok(chdir "Sample-Module",
        "cd Sample-Module");

    for (qw/Changes MANIFEST Makefile.PL LICENSE README lib t/) {
        ok (-e, "$_ exists");
    }
    for (qw/scripts Todo/) {
        ok (! -e, "$_ does not exist");
    }

    ########################################################################

    my $filetext;
    {
        local *FILE;
        ok(open (FILE, 'LICENSE'),
            "reading 'LICENSE'");
        $filetext = do {local $/; <FILE>};
        close FILE;
    }

    ok($filetext =~ m/Terms of Perl itself/,
        "correct LICENSE generated");

    ########################################################################

    # tests of inheritability of constructor
    # note:  attributes must not be thought of as inherited because
    # constructor freshly repopulates data structure with default values

    my ($modparent, $modchild, $modgrandchild);

    ok($modparent  = ExtUtils::ModuleMaker::PBP->new(
        NAME => 'Sample::Module',
        ABSTRACT => 'The quick brown fox'
    ), "call ExtUtils::ModuleMaker::PBP->new for Sample-Module");
    isa_ok($modparent, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modparent->{NAME}, 'Sample::Module', "NAME is correct");
    is($modparent->{ABSTRACT}, 'The quick brown fox', "ABSTRACT is correct");

    $modchild = $modparent->new(
        NAME     => 'Alpha::Beta',
        ABSTRACT => 'The quick brown fox'
    );
    isa_ok($modchild, "ExtUtils::ModuleMaker", "constructor is inheritable");
    is($modchild->{NAME}, 'Alpha::Beta', "new NAME is correct");
    is($modchild->{ABSTRACT}, 'The quick brown fox', 
        "ABSTRACT was correctly inherited");

    ok($modgrandchild  = $modchild->new(
        NAME => 'Gamma::Delta',
        ABSTRACT => 'The quick brown vixen'
    ), "call ExtUtils::ModuleMaker::PBP->new for Sample-Module");
    isa_ok($modgrandchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modgrandchild->{NAME}, 'Gamma::Delta', "NAME is correct");
    is($modgrandchild->{ABSTRACT}, 'The quick brown vixen', 
        "explicitly coded ABSTRACT is correct");

    ########################################################################

    ok(chdir $cwd, "Changed back to original directory");
}

note("Case 2: Personal defaults file present");

my $personal_defaults_file = ExtUtils::ModuleMaker::MockHomeDir::personal_defaults_file();
ok(-f $personal_defaults_file, "Able to create file $personal_defaults_file for testing");

{
    my $cwd = cwd();

    my $tdir = tempdir( CLEANUP => 1);
    ok(chdir $tdir, 'changed to temp directory for testing');

    ###########################################################################

    my $mod;

    my @components = qw| Sample Module |;
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);
    my $path_str = File::Spec->catdir(@components);
    ok($mod  = ExtUtils::ModuleMaker::PBP->new ( NAME => $module_name),
        "call ExtUtils::ModuleMaker::PBP->new for $dist_name");

    ok( $mod->complete_build(), 'call complete_build()' );

    ok(chdir "Sample-Module",
        "cd Sample-Module");

    for (qw/Changes MANIFEST Makefile.PL LICENSE README lib t/) {
        ok (-e, "$_ exists");
    }
    for (qw/scripts Todo/) {
        ok (! -e, "$_ does not exist");
    }

    ########################################################################

    my $filetext;
    {
        local *FILE;
        ok(open (FILE, 'LICENSE'),
            "reading 'LICENSE'");
        $filetext = do {local $/; <FILE>};
        close FILE;
    }

    ok($filetext =~ m/Terms of Perl itself/,
        "correct LICENSE generated");

    ########################################################################

    # tests of inheritability of constructor
    # note:  attributes must not be thought of as inherited because
    # constructor freshly repopulates data structure with default values

    my ($modparent, $modchild, $modgrandchild);

    ok($modparent  = ExtUtils::ModuleMaker::PBP->new(
        NAME => 'Sample::Module',
        ABSTRACT => 'The quick brown fox'
    ), "call ExtUtils::ModuleMaker::PBP->new for Sample-Module");
    isa_ok($modparent, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modparent->{NAME}, 'Sample::Module', "NAME is correct");
    is($modparent->{ABSTRACT}, 'The quick brown fox', "ABSTRACT is correct");

    $modchild = $modparent->new(
        NAME     => 'Alpha::Beta',
        ABSTRACT => 'The quick brown fox'
    );
    isa_ok($modchild, "ExtUtils::ModuleMaker", "constructor is inheritable");
    is($modchild->{NAME}, 'Alpha::Beta', "new NAME is correct");
    is($modchild->{ABSTRACT}, 'The quick brown fox', 
        "ABSTRACT was correctly inherited");

    ok($modgrandchild  = $modchild->new(
        NAME => 'Gamma::Delta',
        ABSTRACT => 'The quick brown vixen'
    ), "call ExtUtils::ModuleMaker::PBP->new for Sample-Module");
    isa_ok($modgrandchild, "ExtUtils::ModuleMaker", "object is an EU::MM object");
    is($modgrandchild->{NAME}, 'Gamma::Delta', "NAME is correct");
    is($modgrandchild->{ABSTRACT}, 'The quick brown vixen', 
        "explicitly coded ABSTRACT is correct");

    ########################################################################

    ok(chdir $cwd, "Changed back to original directory");
}

