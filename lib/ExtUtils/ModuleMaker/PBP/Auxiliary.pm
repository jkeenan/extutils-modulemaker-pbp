package ExtUtils::ModuleMaker::PBP::Auxiliary;
# Contains test subroutines for distribution with ExtUtils::ModuleMaker::PBP
use strict;
use warnings;
our ( $VERSION, @ISA, @EXPORT_OK );
$VERSION = '0.09';
require Exporter;
@ISA         = qw(Exporter);
@EXPORT_OK   = qw(
    check_MakefilePL 
    five_file_tests
); 
use File::Spec;
use Test::More ();
#*ok = *Test::More::ok;
#*is = *Test::More::is;
#*like = *Test::More::like;
#*copy = *File::Copy::copy;
#*move = *File::Copy::move;
use ExtUtils::ModuleMaker::Auxiliary qw(
    read_file_array
    read_file_string
);

=head1 NAME

ExtUtils::ModuleMaker::PBP::Auxiliary - Subroutines for testing ExtUtils::ModuleMaker::PBP

=head1 DESCRIPTION

This package contains subroutines used in one or more F<t/*.t> files in
ExtUtils::ModuleMaker::PBP's test suite.

=head1 SUBROUTINES

=head2 C<check_MakefilePL()>

    Function:   Verify that content of Makefile.PL was created correctly.
    Argument:   Two arguments:
                1.  A string holding the directory in which the Makefile.PL
                    should have been created.
                2.  A reference to an array holding strings each of which is a
                    prediction as to content of particular lines in Makefile.PL.
    Returns:    n/a.
    Used:       To see whether Makefile.PL created by complete_build() has
                correct entries.  Runs 1 Test::More test which checks NAME,
                VERSION_FROM, AUTHOR and ABSTRACT.  

=cut

sub check_MakefilePL {
    my ($topdir, $predictref) = @_;
    my @pred = @$predictref;

    my $mkfl = File::Spec->catfile( $topdir, q{Makefile.PL} );
    local *MAK;
    open MAK, $mkfl or die "Unable to open Makefile.PL: $!";
    my $bigstr = read_file_string($mkfl);
    Test::More::like($bigstr, qr/
            NAME.+($pred[0]).+
            AUTHOR.+($pred[1]).+
            ($pred[2]).+
            VERSION_FROM.+($pred[3]).+
            ABSTRACT_FROM.+($pred[4])
        /sx, "Makefile.PL has predicted values");
}

=head2 C<five_file_tests()>

    Function:   Verify that content of MANIFEST and lib/*.pm were created
                correctly.
    Argument:   Two arguments:
                1.  A number predicting the number of entries in the MANIFEST.
                2.  A reference to an array holding the components of the module's name, e.g.:
                    [ qw( Alpha Beta Gamma ) ].
    Returns:    n/a.
    Used:       To see whether MANIFEST and lib/*.pm have correct text.
                Runs 5 Test::More tests:
                1.  Number of entries in MANIFEST.
                2.  Applies read_file_string to the stem.pm file.
                3.  Determine whether stem.pm's POD contains module name and
                    abstract.
                4.  Determine whether POD contains a HISTORY head.
                5.  Determine whether POD contains correct author information.

=cut

sub five_file_tests {
    my ($manifest_entries, $components) = @_;
    my $module_name = join('::' => @{$components});
    my $dist_name = join('-' => @{$components});
    my $path_str = File::Spec->catdir('lib', @{$components});

    my @filetext = read_file_array(File::Spec->catfile($dist_name, 'MANIFEST'));
    Test::More::is(scalar(@filetext), $manifest_entries,
        'Correct number of entries in MANIFEST');

    my $module = File::Spec->catfile(
        $dist_name,
        'lib',
        @{$components}[0 .. ($#$components - 1)],
        "$components->[-1].pm",
    );
    my $str;
    Test::More::ok($str = read_file_string($module),
        "Able to read $module");
    Test::More::ok($str =~ m|$module_name\s-\sTest\sof\sthe\scapacities\sof\sEU::MM|,
        'POD contains module name and abstract');
    Test::More::ok($str =~ m|=head1\sHISTORY|,
        'POD contains history head');
    Test::More::ok($str =~ m|
            Phineas\sT\.\sBluster\n
            \s+CPAN\sID:\s+PTBLUSTER\n
            \s+Peanut\sGallery\n
            \s+phineas\@anonymous\.com\n
            \s+http:\/\/www\.anonymous\.com\/~phineas
            |xs,
        'POD contains correct author info');
}

1;

