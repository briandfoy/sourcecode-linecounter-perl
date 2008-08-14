#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';

my $class = "SourceCode::LineCounter::Perl";
my @methods = qw( 
	_is_blank blank
	);

use_ok( $class );
can_ok( $class, @methods );

my $counter = $class->new;
isa_ok( $counter, $class );
can_ok( $counter, @methods );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that should be blank 
{
is( $counter->blank, 0, "No blank lines yet" );

my @tests = ( "\t", "   ", "\f", " \t ", "\n" );
foreach my $line ( @tests )
	{
	ok( $counter->_is_blank( \$line ), "_is_blank works for just whitespace" );
	}

is( $counter->blank, scalar @tests, "Right number of blank lines so far" );
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that shouldn't be blank
{
my $start_count = $counter->blank;

foreach my $line ( qw(Buster Mimi), "  Buster", "Mimi  " )
	{
	ok( ! $counter->_is_blank( \$line ), "_is_blank fails for non whitespace" );
	}

is( $counter->blank, $start_count, "Blank line count did not change" );
}

