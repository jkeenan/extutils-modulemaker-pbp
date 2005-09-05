

use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    NAME         => 'ExtUtils::ModuleMaker::PBP',
    VERSION_FROM => 'lib/ExtUtils/ModuleMaker/PBP.pm', # finds \$VERSION
    AUTHOR       => 'James E Keenan (jkeenan@cpan.org)',
    ABSTRACT     => 'Create a Perl extension in the style of Damian Conway\'s \"Perl Best Practices\"',
    PREREQ_PM    => {
                     'Test::Simple' => 0.44,
                    },
);
