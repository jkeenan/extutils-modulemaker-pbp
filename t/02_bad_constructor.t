# t/02_bad constructor.t
use strict;
local $^W = 1;
use Test::More 
# tests => 113;
qw(no_plan);
use_ok( 'ExtUtils::ModuleMaker::PBP' );
use_ok( 'Cwd');
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
        failsafe
    )
);

SKIP: {
    eval { require 5.006_001 };
    skip "failsafe requires File::Temp, core with Perl 5.6", 
        (113 - 3) if $@;
    use warnings;
    my $caller = 'ExtUtils::ModuleMaker::PBP';

    ###########################################################################

    failsafe($caller, [ 'NAME' ], "^Must be hash or balanced list of key-value pairs:",
        "Constructor correctly failed due to odd number of arguments"
    );

#    failsafe($caller,  [ 'NAME' => 'Jim', 'ABSTRACT' ], 
#        "^Must be hash or balanced list of key-value pairs:",
#        "Constructor correctly failed due to odd number of arguments"
#    );
#
#    failsafe($caller,  [
#        'ABSTRACT' => 'The quick brown fox jumps over the lazy dog',
#    ], 
#        "^NAME is required",
#        "Constructor correctly failed due to lack of NAME for module"
#    );
#
#    failsafe($caller,  [
#        'NAME' => 'My::B!ad::Module',
#    ], 
#        "^Module NAME contains illegal characters",
#        "Constructor correctly failed due to illegal characters in module name"
#    );
#
#    failsafe($caller,  [
#        'NAME' => "My'BadModule",
#    ], 
#        "^Module NAME contains illegal characters",
#        "Perl 4-style single-quote path separators no longer supported"
#    );
#
#    failsafe($caller,  [
#        'NAME'     => 'ABC::XYZ',
#        'ABSTRACT' => '123456789012345678901234567890123456789012345',
#    ], 
#        "^ABSTRACTs are limited to 44 characters",
#        "Constructor correctly failed due to ABSTRACT > 44 characters"
#    );
#
#    failsafe($caller,  [
#        'NAME'     => 'ABC::DEF',
#        'AUTHOR'   => 'James E Keenan',
#        'CPANID'   => 'ABCDEFGHIJ',
#    ], 
#        "^CPAN IDs are 3-9 characters",
#        "Constructor correctly failed due to CPANID > 9 characters"
#    );
#
#    failsafe($caller,  [
#        'NAME'     => 'ABC::XYZ',
#        'AUTHOR'   => 'James E Keenan',
#        'CPANID'   => 'AB',
#    ], 
#        "^CPAN IDs are 3-9 characters",
#        "Constructor correctly failed due to CPANID < 3 characters"
#    );
#
#    failsafe($caller,  [
#        'NAME'     => 'ABC::XYZ',
#        'AUTHOR'   => 'James E Keenan',
#        'EMAIL'    => 'jkeenancpan.org',
#    ], 
#        "^EMAIL addresses need to have an at sign",
#        "Constructor correctly failed; e-mail must have '\@' sign"
#    );
#
#    failsafe($caller,  [
#        'NAME'     => 'ABC::XYZ',
#        'AUTHOR'   => 'James E Keenan',
#        'WEBSITE'   => 'ftp://ftp.perl.org',
#    ], 
#        "^WEBSITEs should start with an \"http:\" or \"https:\"",
#        "Constructor correctly failed; websites start 'http' or 'https'"
#    );
#
#    failsafe($caller,  [
#        'NAME'     => 'ABC::XYZ',
#        'LICENSE'  => 'dka;fkkj3o9jflvbkja0 lkasd;ldfkJKD38kdd;llk45',
#    ], 
#        "^LICENSE is not recognized",
#        "Constructor correctly failed due to unrecognized LICENSE"
#    );

} # end SKIP block

