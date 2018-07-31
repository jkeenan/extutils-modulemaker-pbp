# t/04_compact.t
use strict;
local $^W = 1;
use Test::More tests => 16;
use_ok( 'ExtUtils::ModuleMaker::PBP' );
use_ok( 'ExtUtils::ModuleMaker::Auxiliary', qw(
    prepare_mockdirs
    basic_file_and_directory_tests
    license_text_test
) );

{
    my $mod;

    ok($mod  = ExtUtils::ModuleMaker::PBP->new
    			( 
    				NAME		=> 'Sample::Module::Foo',
    				LICENSE		=> 'looselips',
    			 ),
    	"call ExtUtils::ModuleMaker::PBP->new for Sample-Module-Foo");
    	
    ok( $mod->complete_build(), 'call complete_build()' );

    ########################################################################

    ok(chdir 'Sample-Module-Foo',
    	"cd Sample-Module-Foo");

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

    ok($filetext =~ m/Loose lips sink ships/,
    	"correct LICENSE generated");
}

