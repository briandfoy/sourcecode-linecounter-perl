#!/usr/bin/perl
use strict;
use warnings;

use Test::More 'no_plan';

my $class = "SourceCode::LineCounter::Perl";
my @methods = qw( 
	_is_comment comment
	);

use_ok( $class );
can_ok( $class, @methods );

my $counter = $class->new;
isa_ok( $counter, $class );
can_ok( $counter, @methods );

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that should be comments 
{
is( $counter->comment, 0, "No comment lines yet" );

my @tests = (
	'my $x = 0; # Set $x to z',
	' # this is a comment',
	'# this is a comment',
	'#',
	);

foreach my $line ( @tests )
	{
	ok( $counter->_is_comment( \$line ), "_is_comment works for true comments" );
	}

is( $counter->comment, scalar @tests, "Right number of comment lines so far" );
}


# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that shouldn't be comments
{
my $start_count = $counter->comment;

foreach my $line ( qw(Buster Mimi), "  Buster", "Mimi  " )
	{
	ok( ! $counter->_is_comment( \$line ), "_is_comment fails for non comment" );
	}

is( $counter->comment, $start_count, "Comment line count did not change" );
}

# # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# Test things that look like comments, but in pod
{
$counter->_mark_in_pod;
ok( $counter->_in_pod, "In pod after marking" );

my $start_count = $counter->comment;

my @tests = (
	'my $x = 0; # Set $x to z',
	' # this is a comment',
	'# this is a comment',
	'#',
	);

foreach my $line ( @tests )
	{
	ok( ! $counter->_is_comment( \$line ), "_is_comment fails for comment in pod" );
	}

is( $counter->comment, $start_count, "Comment line count did not change" );
}

