# $Id: Makefile.PL,v 1.4 2004/07/04 17:04:17 comdog Exp $
use ExtUtils::MakeMaker;

require 5.006;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'	       => 'SourceCode::LineCounter::Perl',
	'ABSTRACT'     => 'This is what the module does',
	'VERSION_FROM' => 'lib/SourceCode/LineCounter/Perl.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More'   => '0',
		'Test::Output' => '0',
		},

	clean  => { FILES    => q|SourceCode-LineCounter-Perl-*| },

	);
