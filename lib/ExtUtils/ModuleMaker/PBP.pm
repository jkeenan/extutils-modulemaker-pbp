package ExtUtils::ModuleMaker::PBP;
use strict;
use warnings;
our ( $VERSION );
$VERSION = '0.01';
use base qw( ExtUtils::ModuleMaker );
use ExtUtils::ModuleMaker::Licenses::Standard qw(
    Get_Standard_License
    Verify_Standard_License
);
use ExtUtils::ModuleMaker::Licenses::Local qw(
    Get_Local_License
    Verify_Local_License
);
use File::Path;
use Carp;

=head1 NAME

ExtUtils::ModuleMaker::PBP - Create a Perl extension in the style of Damian Conway's Perl Best Practices

=head1 SYNOPSIS

    use ExtUtils::ModuleMaker::PBP;

    $mod = ExtUtils::ModuleMaker::PBP->new(
        NAME => 'Sample::Module' 
    );

    $mod->complete_build();

    $mod->dump_keys(qw|
        ...  # key provided as argument to constructor
        ...  # same
    |);

    $mod->dump_keys_except(qw|
        ...  # key provided as argument to constructor
        ...  # same
    |);

    $license = $mod->get_license();

    $mod->make_selections_defaults();

=head1 VERSION

This document references version 0.01 of ExtUtils::ModuleMaker::PBP, released
to CPAN on September 5, 2005.

=head1 DESCRIPTION

ExtUtils::ModuleMaker::PBP subclasses Perl extension ExtUtils::ModuleMaker.
If you are not already familiar with ExtUtils::ModuleMaker, you should read
its documentation I<now>.

The methods described below supersede the similarly named methods in
ExtUtils::ModuleMaker::StandardText.pm.  When used as described herein, they
will create a CPAN-ready Perl distribution the content of whose files reflects
programming practices recommended by Damian Conway in his book I<Perl Best
Practices> (O'Reilly, 2005) L<http://www.oreilly.com/catalog/perlbp/>.

=head1 METHODS

=head2 Methods Called within C<complete_build()>

=head3 C<text_Buildfile()>

  Usage     : $self->text_Buildfile() within complete_build() 
  Purpose   : Composes text for a Buildfile for Module::Build
  Returns   : String holding text for Buildfile
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass,
              e.g., respond to improvements in Module::Build
  Comment   : References $self keys NAME and LICENSE

=cut

sub text_Buildfile {
    my $self = shift;

    my $add_to_cleanup    = $self->{NAME} . q{-*};
    my $text_of_Buildfile = <<END_OF_BUILDFILE;
use strict;
use warnings;
use Module::Build;

my \$builder = Module::Build->new( 
    module_name         => '$self->{NAME}',
    license             => '$self->{LICENSE}',
    dist_author         => '$self->{AUTHOR} <$self->{EMAIL}>',
    dist_version_from   => '$self->{FILE}',
    requires            => {
        'Test::More' => 0,
        'version'    => 0,
    },
    add-to-cleanup      => [ '$add_to_cleanup' ],
    );
    
\$builder->create_build_script();
END_OF_BUILDFILE
    return $text_of_Buildfile;
}
# add-to-cleanup      => [ '${self->{NAME}}-*' ],

=head3 C<text_Changes()>

  Usage     : $self->text_Changes($only_in_pod) within complete_build; 
              block_pod()
  Purpose   : Composes text for Changes file
  Returns   : String holding text for Changes file
  Argument  : $only_in_pod:  True value to get only a HISTORY section for POD
                             False value to get whole Changes file
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass
  Comment   : Accesses $self keys NAME, VERSION, timestamp, eumm_version

=cut

sub text_Changes {
    my ( $self, $only_in_pod ) = @_;
    my $text_of_Changes;
    
    my $text_of_Changes_core = <<END_OF_CHANGES;
$self->{VERSION} $self->{timestamp}
    - Initial release.  Created by ExtUtils::ModuleMaker $self->{eumm_version}.

END_OF_CHANGES

    unless ($only_in_pod) {
        $text_of_Changes = <<EOF;
Revision history for $self->{NAME}

$text_of_Changes_core
EOF
    }
    else {
        $text_of_Changes = $text_of_Changes_core;
    }

    return $text_of_Changes;
}

=head3 C<text_Makefile()>

  Usage     : $self->text_Makefile() within complete_build()
  Purpose   : Build Makefile
  Returns   : String holding text of Makefile
  Argument  : n/a
  Throws    : n/a
  Comment   : This method is a likely candidate for alteration in a subclass

=cut

sub text_Makefile {
    my $self = shift;
    my $Makefile_format = q~
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME            => '%s',
    AUTHOR          => '%s <%s>',
    VERSION_FROM    => '%s',
    ABSTRACT_FROM   => '%s',
    PL_FILES        => {},
    PREREQ_PM    => {
        'Test::More'    => 0,
        'version'       => 0,
    },
    dist            => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean           => { FILES => '%s-*' },
);
~;
    my $text_of_Makefile = sprintf $Makefile_format,
        map { my $s = $_; $s =~ s{'}{\\'}g; $s; }
            $self->{NAME},
            $self->{AUTHOR},
            $self->{EMAIL},
            $self->{FILE},
            $self->{FILE},
            $self->{FILE};
    return $text_of_Makefile;
}


#=head3 C<create_base_directory>
#
#  Usage     : $self->create_base_directory within complete_build()
#  Purpose   : Create the directory where all the files will be created.
#  Returns   : $DIR = directory name where the files will live
#  Argument  : n/a
#  Comment   : $self keys Base_Dir, COMPACT, NAME.  Calls method check_dir.
#
#=cut
#
#sub create_base_directory {
#    my $self = shift;
#
#    $self->{Base_Dir} =
#      join( ( $self->{COMPACT} ) ? q{-} : q{/}, split( /::/, $self->{NAME} ) );
#
#    $self->check_dir( $self->{Base_Dir} );
#}
#
#=head3 C<check_dir()>
#
#  Usage     : check_dir( [ I<list of directories to be built> ] )
#              in complete_build; create_base_directory; create_pm_basics 
#  Purpose   : Creates directory(ies) requested.
#  Returns   : n/a
#  Argument  : Reference to an array holding list of directories to be created.
#  Comment   : Essentially a wrapper around File::Path::mkpath.  Will use
#              values in $self keys VERBOSE and PERMISSIONS to provide 
#              2nd and 3rd arguments to mkpath if requested.
#  Comment   : Adds to death message in event of failure.
#
#=cut
#
#sub check_dir {
#    my $self = shift;
#
#    return mkpath( \@_, $self->{VERBOSE}, $self->{PERMISSIONS} );
#    $self->death_message( [ "Can't create a directory: $!" ] );
#}
#
#=head3 C<print_file()>
#
#  Usage     : $self->print_file($filename, $filetext) within generate_pm_file()
#  Purpose   : Adds the file being created to MANIFEST, then prints text to new
#              file.  Logs file creation under verbose.  Adds info for
#              death_message in event of failure. 
#  Returns   : n/a
#  Argument  : 2 arguments: filename and text to be printed
#  Comment   : 
#
#=cut
#
#sub print_file {
#    my ( $self, $filename, $filetext ) = @_;
#
#    push( @{ $self->{MANIFEST} }, $filename )
#      unless ( $filename eq 'MANIFEST' );
##    $self->log_message("writing file '$filename'");
#    $self->log_message( qq{writing file '$filename'});
#
#    local *FILE;
#    open( FILE, ">$self->{Base_Dir}/$filename" )
#      or $self->death_message( [ qq{Could not write '$filename', $!} ] );
#    print FILE $filetext;
#    close FILE;
#}
#
#=head3 C<generate_pm_file>
#
#  Usage     : $self->generate_pm_file($module) within complete_build()
#  Purpose   : Create a pm file out of assembled components
#  Returns   : n/a
#  Argument  : $module: pointer to the module being built
#              (as there can be more than one module built by EU::MM);
#              for the primary module it is a pointer to $self
#  Comment   : 3 components:  create_pm_basics; compose_pm_file; print_file
#
#=cut
#
#sub generate_pm_file {
#    my ( $self, $module ) = @_;
#
#    $self->create_pm_basics($module);
#
#    my $text_of_pm_file = $self->compose_pm_file($module);
#
#    $self->print_file( $module->{FILE}, $text_of_pm_file );
#}
#
#=head2 Methods Called within C<complete_build()> as an Argument to C<print_file()>
#
#=head3 C<text_README()>
#
#  Usage     : $self->text_README() within complete_build()
#  Purpose   : Build README
#  Returns   : String holding text of README
#  Argument  : n/a
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass
#
#=cut
#
#sub text_README {
#    my $self = shift;
#    my %README_text = (
#        eumm_instructions => <<'END_OF_MAKE',
#perl Makefile.PL
#make
#make test
#make install
#END_OF_MAKE
#        mb_instructions => <<'END_OF_BUILD',
#perl Build.PL
#./Build
#./Build test
#./Build install
#END_OF_BUILD
#        readme_top => <<'END_OF_TOP',
#
#If this is still here it means the programmer was too lazy to create the readme file.
#
#You can create it now by using the command shown above from this directory.
#
#At the very least you should be able to use this set of instructions
#to install the module...
#
#END_OF_TOP
#        readme_bottom => <<'END_OF_BOTTOM',
#
#If you are on a windows box you should use 'nmake' rather than 'make'.
#END_OF_BOTTOM
#    );
#
#    my $pod2textline = "pod2text $self->{NAME}.pm > README\n";
#    my $build_instructions =
#        ( $self->{BUILD_SYSTEM} eq 'ExtUtils::MakeMaker' )
#            ? $README_text{eumm_instructions}
#            : $README_text{mb_instructions};
#    return $pod2textline . 
#        $README_text{readme_top} .
#        $build_instructions .
#        $README_text{readme_bottom};
#}
#
#=head3 C<text_Todo()>
#
#  Usage     : $self->text_Todo() within complete_build()
#  Purpose   : Composes text for Todo file
#  Returns   : String with text of Todo file
#  Argument  : n/a
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass
#  Comment   : References $self key NAME
#
#=cut
#
#sub text_Todo {
#    my $self = shift;
#
#    my $text = <<EOF;
#TODO list for Perl module $self->{NAME}
#
#- Nothing yet
#
#
#EOF
#
#    return $text;
#}
#
#=head3 C<text_test()>
#
#  Usage     : $self->text_test within complete_build($testnum, $module)
#  Purpose   : Composes text for a test for each pm file being requested in
#              call to EU::MM
#  Returns   : String holding complete text for a test file.
#  Argument  : Two arguments: $testnum and $module
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass
#              Will make a test with or without a checking for method new.
#
#=cut
#
#sub text_test {
#    my ( $self, $testnum, $module ) = @_;
#
#    my $name    = $self->module_value( $module, 'NAME' );
#    my $neednew = $self->module_value( $module, 'NEED_NEW_METHOD' );
#
#    my $text_of_test_file;
#    if ($neednew) {
#        my $name = $module->{NAME};
#
#        $text_of_test_file = <<EOF;
## -*- perl -*-
#
## $testnum - check module loading and create testing directory
#
#use Test::More tests => 2;
#
#BEGIN { use_ok( '$name' ); }
#
#my \$object = ${name}->new ();
#isa_ok (\$object, '$name');
#
#
#EOF
#
#    }
#    else {
#
#        $text_of_test_file = <<EOF;
## -*- perl -*-
#
## $testnum - check module loading and create testing directory
#
#use Test::More tests => 1;
#
#BEGIN { use_ok( '$name' ); }
#
#
#EOF
#
#    }
#
#    return $text_of_test_file;
#}
#
#=head3 C<text_proxy_makefile()>
#
#  Usage     : $self->text_proxy_makefile() within complete_build()
#  Purpose   : Composes text for proxy makefile
#  Returns   : String holding text for proxy makefile
#  Argument  : n/a
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass
#
#=cut
#
#sub text_proxy_makefile {
#    my $self = shift;
#
#    # This comes directly from the docs for Module::Build::Compat
#    my $text_of_proxy = <<'EOF';
#unless (eval "use Module::Build::Compat 0.02; 1" ) {
#  print "This module requires Module::Build to install itself.\n";
#
#  require ExtUtils::MakeMaker;
#  my $yn = ExtUtils::MakeMaker::prompt
#    ('  Install Module::Build from CPAN?', 'y');
#
#  if ($yn =~ /^y/i) {
#    require Cwd;
#    require File::Spec;
#    require CPAN;
#
#    # Save this 'cause CPAN will chdir all over the place.
#    my $cwd = Cwd::cwd();
#    my $makefile = File::Spec->rel2abs($0);
#
#    CPAN::Shell->install('Module::Build::Compat');
#
#    chdir $cwd or die "Cannot chdir() back to $cwd: $!";
#    exec $^X, $makefile, @ARGV;  # Redo now that we have Module::Build
#  } else {
#    warn " *** Cannot install without Module::Build.  Exiting ...\n";
#    exit 1;
#  }
#}
#Module::Build::Compat->run_build_pl(args => \@ARGV);
#Module::Build::Compat->write_makefile();
#EOF
#
#    return $text_of_proxy;
#}
#
#
#=head2 Methods Called within C<generate_pm_file()>
#
#=head3 C<create_pm_basics>
#
#  Usage     : $self->create_pm_basics($module) within generate_pm_file()
#  Purpose   : Conducts check on directory 
#  Returns   : For a given pm file, sets the FILE key: directory/file 
#  Argument  : $module: pointer to the module being built
#              (as there can be more than one module built by EU::MM);
#              for the primary module it is a pointer to $self
#  Comment   : References $self keys NAME, Base_Dir, and FILE.  
#              Calls method check_dir.
#
#=cut
#
#sub create_pm_basics {
#    my ( $self, $module ) = @_;
#    my @layers = split( /::/, $module->{NAME} );
#    my $file   = pop(@layers);
#    my $dir    = join( '/', 'lib', @layers );
#
#    $self->check_dir("$self->{Base_Dir}/$dir");
#    $module->{FILE} = "$dir/$file.pm";
#}
#
#=head3 C<compose_pm_file()>
#
#  Usage     : $self->compose_pm_file($module) within generate_pm_file()
#  Purpose   : Composes a string holding all elements for a pm file
#  Returns   : String holding text for a pm file
#  Argument  : $module: pointer to the module being built
#              (as there can be more than one module built by EU::MM);
#              for the primary module it is a pointer to $self
#  Comment   : [Method name is inaccurate; it's not building a 'page' but
#              rather the text for a pm file.
#
#=cut
#
#sub compose_pm_file {
#    my $self = shift;
#    my $module = shift;
#      
#    my $text_of_pm_file = $self->block_begin($module);
#
#    $text_of_pm_file .= (
#         (
#            (
#                 ( $self->module_value( $module, 'NEED_POD' ) )
#              && ( $self->module_value( $module, 'NEED_NEW_METHOD' ) )
#            )
#            ? $self->block_subroutine_header($module)
#         : q{}
#     )
#    );
#
#    $text_of_pm_file .= (
#        ( $self->module_value( $module, 'NEED_NEW_METHOD' ) )
#        ? $self->block_new_method()
#        : q{}
#    );
#
#    $text_of_pm_file .= (
#         ( $self->module_value( $module, 'NEED_POD' ) )
#         ? $self->block_pod($module)
#         : q{}
#    );
#
#    $text_of_pm_file .= $self->block_final_one();
#    return ($module, $text_of_pm_file);
#}
#
#
#=head2 Methods Called within C<compose_pm_file()>
#
#=head3 C<block_begin()>
#
#  Usage     : $self->block_begin($module) within compose_pm_file()
#  Purpose   : Composes the standard code for top of a Perl pm file
#  Returns   : String holding code for top of pm file
#  Argument  : $module: pointer to the module being built
#              (as there can be more than one module built by EU::MM);
#              for the primary module it is a pointer to $self
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass,
#              e.g., you don't need Exporter-related code if you're building 
#              an OO-module.
#  Comment   : References $self keys NAME and (indirectly) VERSION
#
#=cut
#
#sub block_begin {
#    my ( $self, $module ) = @_;
#    my $version = $self->module_value( $module, 'VERSION' );
#    my $package_line  = "package $module->{NAME};\n";
#    my $strict_line   = "use strict;\n";
#    my $warnings_line = "use warnings;\n";  # not included in standard version
#    my $begin_block   = <<"END_OF_BEGIN";
#
#BEGIN {
#    use Exporter ();
#    use vars qw(\$VERSION \@ISA \@EXPORT \@EXPORT_OK \%EXPORT_TAGS);
#    \$VERSION     = '$version';
#    \@ISA         = qw(Exporter);
#    #Give a hoot don't pollute, do not export more than needed by default
#    \@EXPORT      = qw();
#    \@EXPORT_OK   = qw();
#    \%EXPORT_TAGS = ();
#}
#
#END_OF_BEGIN
#    my $text = 
#        $package_line . 
#        $strict_line . 
#        # $warnings_line . 
#        $begin_block;
#    return $text;
#}
#
#=head3 C<module_value()>
#
#  Usage     : $self->module_value($module, @keys) 
#              within block_begin(), text_test(),
#              compose_pm_file(),  block_pod()
#  Purpose   : When writing POD sections, you have to 'escape' 
#              the POD markers to prevent the compiler from treating 
#              them as real POD.  This method 'unescapes' them and puts header
#              and closer around individual POD headings within pm file.
#  Arguments : First is pointer to module being formed.  Second is an array
#              whose members are the section(s) of the POD being written. 
#  Comment   : [The method's name is very opaque and not self-documenting.
#              Function of the code is not easily evident.  Rename?  Refactor?]
#
#=cut
#
#sub module_value {
#    my ( $self, $module, @keys ) = @_;
#
#    if ( scalar(@keys) == 1 ) {
#        return ( $module->{ $keys[0] } )
#          if ( exists( ( $module->{ $keys[0] } ) ) );
#        return ( $self->{ $keys[0] } );
#    }
#    else { # only alternative currently possible is @keys == 2
#        return ( $module->{ $keys[0] }{ $keys[1] } )
#          if ( exists( ( $module->{ $keys[0] }{ $keys[1] } ) ) );
#        return ( $self->{ $keys[0] }{ $keys[1] } );
#    }
#}
#
#=head3 C<block_pod()>
#
#  Usage     : $self->block_pod($module) inside compose_pm_file()
#  Purpose   : Compose the main POD section within a pm file
#  Returns   : String holding main POD section
#  Argument  : $module: pointer to the module being built
#              (as there can be more than one module built by EU::MM);
#              for the primary module it is a pointer to $self
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass
#  Comment   : In StandardText formulation, contains the following components:
#              warning about stub documentation needing editing
#              pod wrapper top
#              NAME - ABSTRACT
#              SYNOPSIS
#              DESCRIPTION
#              USAGE
#              BUGS
#              SUPPORT
#              HISTORY (as requested)
#              AUTHOR
#              COPYRIGHT
#              SEE ALSO
#              pod wrapper bottom
#
#=cut
#
#sub block_pod {
#    my ( $self, $module ) = @_;
#
#    my $name             = $self->module_value( $module, 'NAME' );
#    my $abstract         = $self->module_value( $module, 'ABSTRACT' );
#    my $synopsis         = qq{  use $name;\n  blah blah blah\n};
#    my $description      = <<END_OF_DESC;
#Stub documentation for this module was created by ExtUtils::ModuleMaker.
#It looks like the author of the extension was negligent enough
#to leave the stub unedited.
#
#Blah blah blah.
#END_OF_DESC
#    my $author_composite = $self->module_value( $module, 'COMPOSITE' );
#    my $copyright        = $self->module_value( $module, 'LicenseParts', 'COPYRIGHT');
#    my $see_also         = q{perl(1).};
#
#    my $text_of_pod = join(
#        q{},
#        $self->pod_section( NAME => $name . 
#            ( (defined $abstract) ? qq{ - $abstract} : q{} )
#        ),
#        $self->pod_section( SYNOPSIS    => $synopsis ),
#        $self->pod_section( DESCRIPTION => $description ),
#        $self->pod_section( USAGE       => q{} ),
#        $self->pod_section( BUGS        => q{} ),
#        $self->pod_section( SUPPORT     => q{} ),
#        (
#            ( $self->{CHANGES_IN_POD} )
#            ? $self->pod_section(
#                HISTORY => $self->text_Changes('only pod')
#              )
#            : q{}
#        ),
#        $self->pod_section( AUTHOR     => $author_composite),
#        $self->pod_section( COPYRIGHT  => $copyright),
#        $self->pod_section( 'SEE ALSO' => $see_also),
#    );
#
#    return $self->pod_wrapper($text_of_pod);
#}
#
#=head3 C<block_subroutine_header()>
#
#  Usage     : $self->block_subroutine_header($module) within compose_pm_file()
#  Purpose   : Composes an inline comment for pm file (much like this inline
#              comment) which documents purpose of a subroutine
#  Returns   : String containing text for inline comment
#  Argument  : $module: pointer to the module being built
#              (as there can be more than one module built by EU::MM);
#              for the primary module it is a pointer to $self
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass
#              E.g., some may prefer this info to appear in POD rather than
#              inline comments.
#
#=cut
#
#sub block_subroutine_header {
#    my ( $self, $module ) = @_;
#    my $text_of_subroutine_pod = <<EOFBLOCK;
#
##################### subroutine header begin ####################
#
# ====head2 sample_function
#
# Usage     : How to use this function/method
# Purpose   : What it does
# Returns   : What it returns
# Argument  : What it wants to know
# Throws    : Exceptions and other anomolies
# Comment   : This is a sample subroutine header.
#           : It is polite to include more pod and fewer comments.
#
#See Also   : 
#
# ====cut
#
##################### subroutine header end ####################
#
#EOFBLOCK
#
#    $text_of_subroutine_pod =~ s/\n ====/\n=/g;
#    return $text_of_subroutine_pod;
#}
#
#=head3 C<block_new_method()>
#
#  Usage     : $self->block_new_method() within compose_pm_file()
#  Purpose   : Build 'new()' method as part of a pm file
#  Returns   : String holding sub new.
#  Argument  : $module: pointer to the module being built
#              (as there can be more than one module built by EU::MM);
#              for the primary module it is a pointer to $self
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass,
#              e.g., pass a single hash-ref to new() instead of a list of
#              parameters.
#
#=cut
#
#sub block_new_method {
#    my $self = shift;
#    return <<'EOFBLOCK';
#
#sub new
#{
#    my ($class, %parameters) = @_;
#
#    my $self = bless ({}, ref ($class) || $class);
#
#    return $self;
#}
#
#EOFBLOCK
#}
#
#=head3 C<block_final_one()>
#
#  Usage     : $self->block_final_one() within compose_pm_file()
#  Purpose   : Compose code and comment that conclude a pm file and guarantee
#              that the module returns a true value
#  Returns   : String containing code and comment concluding a pm file
#  Argument  : $module: pointer to the module being built
#              (as there can be more than one module built by EU::MM);
#              for the primary module it is a pointer to $self
#  Throws    : n/a
#  Comment   : This method is a likely candidate for alteration in a subclass,
#              e.g., some may not want the comment line included.
#
#=cut
#
#sub block_final_one {
#    my $self = shift;
#    return <<EOFBLOCK;
#
#1;
## The preceding line will help the module return a true value
#
#EOFBLOCK
#}
#
#=head2 All Other Methods
#
#=head3 C<death_message()>
#
#  Usage     : $self->death_message( [ I<list of error messages> ] ) 
#              in validate_values; check_dir; print_file
#  Purpose   : Croaks with error message composed from elements in the list
#              passed by reference as argument
#  Returns   : [ To come. ]
#  Argument  : Reference to an array holding list of error messages accumulated
#  Comment   : Different functioning in modulemaker interactive mode
#
#=cut
#
#sub death_message {
#    my $self = shift;
#    my $errorref = shift;
#    my @errors = @{$errorref};
#
#    croak( join "\n", @errors, q{}, $self->{USAGE_MESSAGE} )
#      unless $self->{INTERACTIVE};
#    my %err = map {$_, 1} @errors;
#    delete $err{'NAME is required'} if $err{'NAME is required'};
#    @errors = keys %err;
#    if (@errors) {
#        print( join "\n", 
#            'Oops, there are the following errors:', @errors, q{} );
#        return 1;
#    } else {
#        return;
#    }
#}
#
#=head3 C<log_message()>
#
#  Usage     : $self->log_message( $message ) in print_file; 
#  Purpose   : Prints log_message (currently, to STDOUT) if $self->{VERBOSE}
#  Returns   : n/a
#  Argument  : Scalar holding message to be logged
#  Comment   : 
#
#=cut
#
#sub log_message {
#    my ( $self, $message ) = @_;
#    print "$message\n" if $self->{VERBOSE};
#}
#
#=head3 C<pod_section()>
#
#  Usage     : $self->pod_section($heading, $content) within 
#              block_pod()
#  Purpose   : When writing POD sections, you have to 'escape' 
#              the POD markers to prevent the compiler from treating 
#              them as real POD.  This method 'unescapes' them and puts header
#              and closer around individual POD headings within pm file.
#  Arguments : Variables holding POD section name and text of POD section.
#
#=cut
#
#sub pod_section {
#    my ( $self, $heading, $content ) = @_;
#    my $text_of_pod_section = <<END_OF_SECTION;
#
# ====head1 $heading
#
#$content
#END_OF_SECTION
#
#    $text_of_pod_section =~ s/\n ====/\n=/g;
#    return $text_of_pod_section;
#}
#
#=head3 C<pod_wrapper()>
#
#  Usage     : $self->pod_wrapper($string) within block_pod()
#  Purpose   : When writing POD sections, you have to 'escape' 
#              the POD markers to prevent the compiler from treating 
#              them as real POD.  This method 'unescapes' them and puts header
#              and closer around main POD block in pm file, along with warning
#              about stub documentation.
#  Argument  : String holding text of POD which has been built up 
#              within block_pod().
#  Comment   : $head and $tail inside pod_wrapper() are optional and, in a 
#              subclass, could be redefined as empty strings;
#              but $cutline is mandatory as it supplies the last =cut
#
#=cut
#
#sub pod_wrapper {
#    my ( $self, $podtext ) = @_;
#    my $head = <<'END_OF_HEAD';
#
##################### main pod documentation begin ###################
### Below is the stub of documentation for your module. 
### You better edit it!
#
#END_OF_HEAD
#    my $cutline = <<'END_OF_CUT';
#
# ====cut
#
#END_OF_CUT
#    my $tail = <<'END_OF_TAIL';
##################### main pod documentation end ###################
#
#END_OF_TAIL
#
#    $cutline =~ s/\n ====/\n=/g;
#    return join( q{}, 
#        $head,     # optional
#        $podtext,  # required 
#        $cutline,  # required 
#        $tail      # optional
#    );
#

=head1 PREREQUISITES

ExtUtils::ModuleMaker, version 0.39 or later.
L<http://search.cpan.org/dist/ExtUtils-ModuleMaker/>.

1;
# The preceding line will help the module return a true value

