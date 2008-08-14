#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';

my $class = "SourceCode::LineCounter::Perl";
my @methods = qw( 
	_is_code code
	);

use_ok( $class );
can_ok( $class, @methods );

my $counter = $class->new;
isa_ok( $counter, $class );
can_ok( $counter, @methods );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that should be code, no comments 
{
is( $counter->code, 0, "No code lines yet" );

my @tests = (
	'my $x = 0;',
	'foreach my $test ( qw#a b c# ) { 1; }',
	);

foreach my $line ( @tests )
	{
	ok( $counter->_is_code( \$line ), "_is_code works for code lines" );
	}

is( $counter->code,  scalar @tests, "Right number of code lines so far" );
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that should be code, with comments 
{
my $start_count = $counter->code;

is( $counter->comment, 0, "No comment lines yet" );

my @tests = (
	'my $x = 0; # fooey',
	'1; # test',
	);

foreach my $line ( @tests )
	{
	ok( $counter->_is_comment( \$line ), "_is_comment works for code lines with comments" ); 
	ok( $counter->_is_code( \$line ),    "_is_code works for code lines with comments" );
	}

is( $counter->code,    $start_count + @tests, "Right number of code lines so far"    );
is( $counter->comment, scalar @tests, "Right number of comment lines so far" );
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that shouldn't be code, with comments 
{
my $start_count   = $counter->code;
my $comment_count = $counter->comment;

my @tests = (
	'  # fooey',
	);

foreach my $line ( @tests )
	{
	ok( $counter->_is_comment( \$line ), "_is_comment works for code lines with comments" ); 
	ok( ! $counter->_is_code( \$line ),    "_is_code fails for lines with just comments" );
	}

is( $counter->code,    $start_count, "Right number of code lines so far"    );
is( $counter->comment, $comment_count + @tests, "Right number of comment lines so far" );
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that look like code, but in pod
{
my $start_count = $counter->code;

$counter->_mark_in_pod;
ok( $counter->_in_pod, "We're in pod territory now" );

my @tests = (
	'my $x = 0; # fooey',
	'1; # test',
	);

foreach my $line ( @tests )
	{
	ok( ! $counter->_is_code( \$line ), "_is_comment fails for code lines in pod" ); 
	}

is( $counter->code,    $start_count, "Number of code lines does not change in pod"    );
}