package List::Flat;
use 5.008001;
use strict;
use warnings;

our $VERSION = 0.001_001;

use Exporter 5.57 'import';
our @EXPORT_OK = qw/flat flat_fast/;

# if PERL_LIST_FLAT_IMPLEMENTATION environment variable is set to 'PP',
# or $List::Flat::IMPLEMENTATION is set to 'PP', uses the pure-perl
# versions of is_plain_arrayref and flat_fast().
# Otherwise, uses Ref::Util and List::Flatten::XS if they can be
# successfully loaded.

BEGIN {
    my $impl
      = $ENV{PERL_LIST_FLAT_IMPLEMENTATION}
      || our $IMPLEMENTATION
      || 'XS';

    if ( $impl ne 'PP' && eval { require List::Flatten::XS; 1 } ) {
        *flat_fast = \&_flat_fast_xs;
    }
    else {
        *flat_fast = \&_flat_fast_pp;
    }

    if ( $impl ne 'PP' && eval { require Ref::Util; 1 } ) {
        Ref::Util->import('is_plain_arrayref');
    }
    else {
        *is_plain_arrayref = sub { ref($_[0]) eq 'ARRAY' };
    }

} ## tidy end: BEGIN

sub flat {

    my @results;
    my @seens;

    # this uses @_ as the queue of items to process.
    # An item is plucked off the queue. If it's not an array ref,
    # put it in @results.

    # If it is an array ref, check to see if it's the same as any
    # of the arrayrefs we are currently in the middle of processing.
    # If it is, don't do anything -- skip to the next one.
    # If it isn't, put all the items it contains back on the @_ queue.
    # Also, for each of the items, push a reference into @seens
    # that contains references to all the arrayrefs we are currently
    # in the middle of processing, plus this arrayref.
    # Note that @seens will be empty at the top level, so we must
    # handle both when it is empty and when it is not.

    while (@_) {

        if ( is_plain_arrayref( my $element = shift @_ ) ) {
            if ( !defined( my $seen_r = shift @seens ) ) {
                unshift @_, @{$element};
                unshift @seens, ( ( [$element] ) x scalar @{$element} );
            }
            elsif ( !grep { $element == $_ } @$seen_r ) {
                # until the recursion gets very deep, the overhead in calling
                # List::Util::none seems to be taking more time than the
                # additional comparisons required by grep
                unshift @_, @{$element};
                unshift @seens,
                  ( ( [ @$seen_r, $element ] ) x scalar @{$element} );
            }
        }
        else {
            shift @seens;
            push @results, $element;
        }

    } ## tidy end: while (@_)

    return wantarray ? @results : \@results;

} ## tidy end: sub flat

sub _flat_fast_pp {

    # this uses @_ as the queue of items to process.
    # An item is plucked off the queue. If it's not an array ref,
    # put it in @results.
    # If it is an array ref, put its contents back in the queue.

    # Mark Jason Dominus calls this the "agenda method" of turning
    # a recursive function into an iterative one.

    my @results;

    while (@_) {

        if ( is_plain_arrayref( my $element = shift @_ ) ) {
            unshift @_, @{$element};
        }
        else {
            push @results, $element;
        }

    }

    return wantarray ? @results : \@results;

} ## tidy end: sub _flat_fast_pp

sub _flat_fast_xs {
    List::Flatten::XS::flatten( \@_ );
}

1;

__END__

=encoding utf-8

=head1 NAME

List::Flat - Functions to flatten a structure of array references

=head1 VERSION

This documentation refers to version 0.001_001

=head1 SYNOPSIS

    use List::Flat(qw/flat flat_fast/);
    
    my @list = ( 1, [ 2, 3, [ 4 ], 5 ] , 6 );
    
    my @newlist = flat_fast(@list);
    # ( 1, 2, 3, 4, 5, 6 )

    push @list, [ \@list, 7, 8, 9 ];
    my @newerlist = flat(@list);
    # ( 1, 2, 3, 4, 5, 6, 7, 8, 9 )

=head1 DESCRIPTION

List::Flat is a module with functions to flatten a deep structure
of array references into a single flat list.

=head1 FUNCTIONS

=over

=item B<flat()>

This function takes its arguments and returns either a list (in
list context) or an array reference (in scalar context) that is
flat, so there are no (non-blessed) array references in the result.

If there are any circular references -- an array reference that has
an entry that points to itself, or an entry that points to another
array reference that refers to the first array reference -- it will
not descend infinitely, and will skip those.

=item B<flat_fast()>

This function takes its arguments and returns either a list (in
list context) or an array reference (in scalar context) that is
flat, so there are no (non-blessed) array references in the result.

It does not check for circular references, and so will go into an infinite loop with something
like

 @a = ( 1, 2, 3);
 push @a, \@a;
 @b = flat_fast(\@a);

So don't do that. Use the C<flat()> function instead.

Upon loading, List::Flat looks to see if the CPAN module
L<List::Flattened::XS|List::Flattened::XS> is available, and if it
is, uses that for C<flat_fast()> (unless overridden; see L<CONFIGURATION AND
ENVIRONMENT|/CONFIGURATION AND ENVIRONMENT> below).  List::Flattened::XS
is much faster than the perl version, but even the perl version of
C<flat_fast()> is about twice as fast as C<flat()>.

=back

=head1 CONFIGURATION AND ENVIRONMENT

The flat_fast function will normally use List::Flattened::XS if it
is available to do the actual flattening, but if the environment
variable $PERL_LIST_FLAT_IMPLEMENTATION is set to 'PP', or the perl
variable List::Flat::IMPLEMENTATION is set to 'PP', it will use its
internal pure-perl implementation of B<fast_flat()>.

=head1 DEPENDENCIES

It has two optional dependencies. If they are not present, a pure
perl implementation is used instead.

=over

=item L<Ref::Util|Ref::Util>

=item L<List::Flattened::XS|List::Flattened::XS>

=back

=head1 SEE ALSO

There are several other modules on CPAN that do similar things.

=over

=item Array::DeepUtils

I have not tested this code, but it appears that its collapse()
routine does not handle circular references.  Also, it must be
passed an array reference rather than a list.

=item List::Flatten

List::Flatten flattens lists one level deep only, so

  1, 2, [ 3, [ 4 ] ]

is returned as 

  1, 2, 3, [ 4 ]

This may be useful in some circumstances.

=item List::Flatten::Recursive

The code from this module works well, but it seems to be somewhat
slower than List::Flat (in my testing; better testing welcome) 
due to its use of recursive subroutine calls
rather than using a queue of items to be processed.  Moreover, it
is reliant on Exporter::Simple, which does not pass tests on perls
newer than 5.10.

=item List::Flatten::XS

This is very fast and has the feature of being able to specify the 
level to which the array is flattened (so one can ask for the first and second
levels to be flat, but the third level preserved as references).

It is worth using if its limitations can be accepted. First,
obviously, like all XS modules it requires a C compiler to be
installed. Second, it cannot handle circular references. Third, it
must be passed an array refeernce rather than a list.

List::Fast uses this module to speed up flat_fast when it is available on the
local system.

=back

It is certainly possible that there are others.

=head1 ACKNOWLEDGEMENTS

Ryan C. Thompson's L<List::Flatten::Recursive|List::Flatten::Recursive> 
inspired the creation of the C<flat()> function.

Mark Jason Dominus's book L<Higher-Order Perl|http://hop.perl.plover.com> 
was and continues to be extremely helpful and informative.  

Kei Kamikawa's L<List::Flatten::XS|List::Flatten::XS> makes C<flat_fast()>
much, much faster.

=head1 BUGS AND LIMITATIONS

There is no XS version of the C<flat()> function.

If you bless something that's not an array reference into a class called
'ARRAY', the pure-perl versions will break. But why would you do that?

=head1 AUTHOR

Aaron Priven <apriven@actransit.org>

=head1 COPYRIGHT & LICENSE

Copyright 2017

This program is free software; you can redistribute it and/or modify it
under the terms of either:

=over 4

=item * the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or

=item * the Artistic License version 2.0.

=back

This program is distributed in the hope that it will be useful, but
WITHOUT  ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or  FITNESS FOR A PARTICULAR PURPOSE.

