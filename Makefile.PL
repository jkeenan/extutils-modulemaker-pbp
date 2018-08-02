use ExtUtils::MakeMaker;
require 5.006001;

my $mm_ver = ExtUtils::MakeMaker->VERSION;

my %Makefile_Args = (
    NAME         => 'ExtUtils::ModuleMaker::PBP',
    VERSION_FROM => 'lib/ExtUtils/ModuleMaker/PBP.pm',
    AUTHOR       => 'James E Keenan (jkeenan@cpan.org)',
    ABSTRACT     => "Create a Perl extension in the style of Damian Conway's Perl Best Practices",
    EXE_FILES    => [ 'scripts/mmkrpbp' ],
    PREREQ_PM    => {
        'Data::Dumper'      => 0, # in the Perl core
        #'Getopt::Std'       => 0, # in the Perl core
        'Getopt::Long'      => 0, # in the Perl core
        'File::Basename'    => 0, # in the Perl core
        'File::Path'        => 2.15, # in the Perl core
        'File::Spec'        => 0, # in the Perl core
        'File::Temp'        => 0, # in the Perl core
        ($^O =~ /Win32/ ? ('Win32' => 0) : ()),
        'File::HomeDir'     => 0.86,
        'ExtUtils::ModuleMaker'    => 0.63,
    },
    ( $mm_ver < 6.63_03 ? 'BUILD_REQUIRES' : 'TEST_REQUIRES' ) => {
        'Capture::Tiny' => 0,
        'IO::Capture'   => 0,
        'Test::More'    => 0.44,
        'File::Copy::Recursive::Reduced' => 0.006,
        'Module::Build' => 0,
    },
    LICENSE      => "perl",
    ($mm_ver < 6.46 ? () : (META_MERGE => {
        'meta-spec' => { version => 2 },
        dynamic_config => 1,
        resources => {
            homepage => 'http://thenceforward.net/perl/modules/ExtUtils-ModuleMaker-PBP/',
            repository => {
                url => 'https://github.com/jkeenan/extutils-modulemaker.git',
                web => 'https://github.com/jkeenan/extutils-modulemaker',
                type => 'git',
            },
            bugtracker => {
                web => 'https://rt.cpan.org/Public/Dist/Display.html?Name=ExtUtils-ModuleMaker-PBP',
            },
        },
    })),
    test        => { TESTS => join q{ }, map {glob} qw( t/*.t t/*/*.t ) },
);

WriteMakefile(%Makefile_Args);
