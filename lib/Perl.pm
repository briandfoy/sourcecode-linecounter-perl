# $Id$
package SourceCode::LineCounter::Perl;
use strict;

use warnings;
no warnings;

use subs qw();
use vars qw($VERSION);

use Carp qw(carp);

$VERSION = '0.10_01';

=head1 NAME

SourceCode::LineCounter::Perl - Count lines in Perl source code

=head1 SYNOPSIS

	use SourceCode::LineCounter::Perl;

	my $counter    = SourceCode::LineCounter::Perl->new( 
		);

	$counter->count;
	
	my $total_lines   = $counter->total;
	
	my $pod_lines     = $counter->documentation;
	
	my $code_lines    = $counter->code;
	
	my $comment_lines = $counter->comment;

	my $comment_lines = $counter->blank;
	
	
=head1 DESCRIPTION

This module counts the lines in Perl source code and tries to classify
them as code lines, documentation lines, and blank lines.

Read a line

If it's a blank line, record it and move on to the next line

If it is the start of pod, mark that we are in pod, and count
it as a pod line and move on

If we are in pod and the line is blank, record it as a blank line
and a pod line, and move on.

If we are ending pod (with C<=cut>, record it as a pod line and 
move on.

If we are in pod and it is not blank, record it as a pod line and
move on.

If we are not in pod, guess if the line has a comment. If the
line has a comment, record it.

Removing comments, see if there is anything left. If there is,
record it as a code line.

Move on to the next line.

=cut

=over 4

=item new

=cut

sub new
	{
	my( $class, %hash ) = @_;
	
	my $self = bless {}, $class;
	$self->_init;
	
	$self;
	}
	
=item reset

Reset everything the object counted so you can use the same object
with another file.

=cut

sub reset
	{
	$_[0]->_init;	
	}
	
=item count( FILE )

=cut

sub count
	{
	my( $self, $file ) = @_;
	
	my $fh;
	unless( open $fh, "<", $file )
		{
		carp "Could not open file [$file]: $!";
		return;
		}
		
	$self->_clear_line_info;

	LINE: while( <$fh> )
		{
		$self->_set_current_line( \$_ );
		
		$self->_total( \$_ );
		$self->_is_blank( \$_ );
		
		foreach my $type ( qw( _start_pod _end_pod _pod_line ) )
			{
			$self->$type( \$_ ) && next LINE;
			}
			
		$self->_is_comment( \$_ );
		$self->_is_code( \$_ );
		}
		
	$self;
	}
	
sub _clear_line_info
	{
	$_[0]->{line_info} = {};
	}

sub _set_current_line
	{
	$_[0]->{line_info}{current_line} = \ $_[1];
	}
	
sub _init
	{
	my @attrs = qw(total blank documentation code comment);
	$_[0]->{$_} = 0 foreach @attrs;
	$_[0]->_clear_line_info;
	};
	
=item total

Returns the total number of lines in the file

=cut

sub total  { $_[0]->{total}   }

sub _total { ++ $_[0]->{total} }

=item documentation

Returns the total number of Pod lines in the file, including
and blank lines in Pod.

=cut

sub documentation { $_[0]->{documentation} }

sub _start_pod 
	{
	return if $_[0]->_in_pod;
	return unless ${$_[1]} =~ /^=\w+/;
	
	$_[0]->_mark_in_pod;
	
	$_[0]->{documentation}++;
	
	1;
	}

sub _end_pod
	{
	return unless $_[0]->_in_pod;
	return unless ${$_[1]} =~ /^=cut$/;
	
	$_[0]->_clear_in_pod;
	
	$_[0]->{documentation}++;

	1;
	}

sub _pod_line
	{
	return unless $_[0]->_in_pod;
	
	$_[0]->{documentation}++;
	}
	
sub  _mark_in_pod { $_[0]->{line_info}{in_pod}++   }
sub       _in_pod { $_[0]->{line_info}{in_pod}     }
sub _clear_in_pod { $_[0]->{line_info}{in_pod} = 0 }


=item code

Returns the number of non-blank lines, whether documentation
or code.

=cut

sub code { $_[0]->{code} }

sub _is_code 
	{
	my( $self, $line_ref ) = @_;
	
	return if grep { $self->{line_info}{$_} }
		qw(blank in_pod);
		
	( my $copy = $$line_ref ) =~ s/\s*#.*//;
	
	return unless length $copy;
	
	$self->{code}++;

	1;
	}

=item comment

The number of lines with comments. These are the things
that start with #. That might be lines that are all comments
or code lines that have comments.

=cut

sub comment { $_[0]->{comment} }

sub _is_comment 
	{
	return if $_[0]->_in_pod;
	return unless ${$_[1]} =~ m/#/;

	$_[0]->{line_info}{comment}++;
	$_[0]->{comment}++;
	
	1;
	}

=item blank

The number of blank lines. By default, these are lines that
match the regex qr/^\s*$/. You can change this in C<new()>
by specifying the C<line_ending> parameter. 

=cut

sub blank  { $_[0]->{blank} }

sub _is_blank 
	{
	return unless ${$_[1]} =~ m/^\s*$/;
	
	$_[0]->{line_info}{blank}++;
	$_[0]->{blank}++;
	
	1;
	}

=back

=head1 TO DO

* Generalized LineCounter that can dispatch to language
delegates.

=head1 SEE ALSO


=head1 SOURCE AVAILABILITY

This source is part of a SourceForge project which always has the
latest sources in CVS, as well as all of the previous releases.

	http://sourceforge.net/projects/brian-d-foy/

If, for some reason, I disappear from the world, one of the other
members of the project can shepherd this module appropriately.

=head1 AUTHOR

brian d foy, C<< <bdfoy@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2008, brian d foy, All Rights Reserved.

You may redistribute this under the same terms as Perl itself.

=cut

1;
