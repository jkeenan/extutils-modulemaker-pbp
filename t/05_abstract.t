# t/05_abstract.t
use strict;
use warnings;
use Test::More qw(no_plan); # tests => 34;
use File::Spec;
use_ok( 'ExtUtils::ModuleMaker::PBP' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    read_file_string
    five_file_tests
) );

{
    my $mod;
    my $testmod = 'Beta';

    my @components = ( 'Alpha', $testmod );
    my $module_name = join('::' => @components);
    my $dist_name = join('-' => @components);

    ok( $mod = ExtUtils::ModuleMaker::PBP->new( 
            NAME           => $module_name,
            ABSTRACT       => 'Test of the capacities of EU::MM',
            CHANGES_IN_POD => 1,
            AUTHOR         => 'Phineas T. Bluster',
            CPANID         => 'PTBLUSTER',
            ORGANIZATION   => 'Peanut Gallery',
            WEBSITE        => 'http://www.anonymous.com/~phineas',
            EMAIL          => 'phineas@anonymous.com',
        ),
        "call ExtUtils::ModuleMaker::PBP->new for $dist_name"
    );

    ok( $mod->complete_build(), 'call complete_build()' );

    for my $f ( qw| MANIFEST Makefile.PL LICENSE README | ) {
        my $ff = File::Spec->catfile($dist_name, $f);
        ok (-e $ff, "$ff exists");
    }
    ok(! -f File::Spec->catfile($dist_name, 'Changes'),
        "Changes file not created");
    #for my $d ( qw| lib scripts t | ) {
    for my $d ( qw| lib t | ) {
        my $dd = File::Spec->catdir($dist_name, $d);
        ok(-d $dd, "Directory '$dd' exists");
    }   

    my ($filetext);
    ok($filetext = read_file_string(File::Spec->catfile($dist_name, 'Makefile.PL')),
        'Able to read Makefile.PL');
    ok($filetext =~ m|AUTHOR\s+=>\s+.Phineas\sT.\sBluster|,
        'Makefile.PL contains correct author') or diag($filetext);
    ok($filetext =~ m|AUTHOR.*phineas\@anonymous\.com|,
        'Makefile.PL contains correct e-mail') or diag($filetext);

    five_file_tests(8, \@components); # first arg is # entries in MANIFEST
}

