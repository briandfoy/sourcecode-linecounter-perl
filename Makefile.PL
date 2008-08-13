# $Id: Makefile.PL,v 1.4 2004/07/04 17:04:17 comdog Exp $
use ExtUtils::MakeMaker;

require 5.006;

eval "use Test::Manifest 1.14";

WriteMakefile(
	'NAME'	       => 'SourceCode::LineCounter::Perl',
	'ABSTRACT'     => 'This is what the module does',
	'VERSION_FROM' => 'lib/Perl.pm',
	'LICENSE'      => 'perl',
	'AUTHOR'       => 'brian d foy <bdfoy@cpan.org>',
	
	'PREREQ_PM'    => { 
		'Test::More' => '0',
		},

	'PM'           => {
		'lib/Perl.pm'         => '$(INST_LIBDIR)/Perl.pm',
		},

	'MAN3PODS'     => {
		'lib/Perl.pm' => '$(INST_MAN3DIR)/SourceCode::LineCounter::Perl.3',
		},

	clean  => { FILES    => q|SourceCode-LineCounter-Perl-*| },

	);
