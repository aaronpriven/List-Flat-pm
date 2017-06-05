# NAME

List::Flat - Functions to flatten a structure of array references

# VERSION

This documentation refers to version 0.001\_001

# SYNOPSIS

    use List::Flat(qw/flat flat_fast/);
    
    my @list = ( 1, [ 2, 3, [ 4 ], 5 ] , 6 );
    
    my @newlist = flat_fast(@list);
    # ( 1, 2, 3, 4, 5, 6 )

    push @list, [ \@list, 7, 8, 9 ];
    my @newerlist = flat(@list);
    # ( 1, 2, 3, 4, 5, 6, 7, 8, 9 )

# DESCRIPTION

List::Flat is a module with functions to flatten a deep structure
of array references into a single flat list.

# FUNCTIONS

- **flat()**

    This function takes its arguments and returns either a list (in
    list context) or an array reference (in scalar context) that is
    flat, so there are no (non-blessed) array references in the result.

    If there are any circular references -- an array reference that has
    an entry that points to itself, or an entry that points to another
    array reference that refers to the first array reference -- it will
    not descend infinitely, and will skip those.

- **flat\_fast()**

    This function takes its arguments and returns either a list (in
    list context) or an array reference (in scalar context) that is
    flat, so there are no (non-blessed) array references in the result.

    It does not check for circular references, and so will go into an infinite loop with something
    like

        @a = ( 1, 2, 3);
        push @a, \@a;
        @b = flat_fast(\@a);

    So don't do that. Use the `flat()` function instead.

    Upon loading, List::Flat looks to see if the CPAN module
    [List::Flattened::XS](https://metacpan.org/pod/List::Flattened::XS) is available, and if it
    is, uses that for `flat_fast()` (unless overridden; see [CONFIGURATION AND
    ENVIRONMENT](#configuration-and-environment) below).  List::Flattened::XS
    is much faster than the perl version, but even the perl version of
    `flat_fast()` is about twice as fast as `flat()`.

# CONFIGURATION AND ENVIRONMENT

The flat\_fast function will normally use List::Flattened::XS if it
is available to do the actual flattening, but if the environment
variable $PERL\_LIST\_FLAT\_IMPLEMENTATION is set to 'PP', or the perl
variable List::Flat::IMPLEMENTATION is set to 'PP', it will use its
internal pure-perl implementation of **fast\_flat()**.

# DEPENDENCIES

It has two optional dependencies. If they are not present, a pure
perl implementation is used instead.

- [Ref::Util](https://metacpan.org/pod/Ref::Util)
- [List::Flattened::XS](https://metacpan.org/pod/List::Flattened::XS)

# SEE ALSO

There are several other modules on CPAN that do similar things.

- Array::DeepUtils

    I have not tested this code, but it appears that its collapse()
    routine does not handle circular references.  Also, it must be
    passed an array reference rather than a list.

- List::Flatten

    List::Flatten flattens lists one level deep only, so

        1, 2, [ 3, [ 4 ] ]

    is returned as 

        1, 2, 3, [ 4 ]

    This may be useful in some circumstances.

- List::Flatten::Recursive

    The code from this module works well, but it seems to be somewhat
    slower than List::Flat (in my testing; better testing welcome) 
    due to its use of recursive subroutine calls
    rather than using a queue of items to be processed.  Moreover, it
    is reliant on Exporter::Simple, which does not pass tests on perls
    newer than 5.10.

- List::Flatten::XS

    This is very fast and has the feature of being able to specify the 
    level to which the array is flattened (so one can ask for the first and second
    levels to be flat, but the third level preserved as references).

    It is worth using if its limitations can be accepted. First,
    obviously, like all XS modules it requires a C compiler to be
    installed. Second, it cannot handle circular references. Third, it
    must be passed an array refeernce rather than a list.

    List::Fast uses this module to speed up flat\_fast when it is available on the
    local system.

It is certainly possible that there are others.

# ACKNOWLEDGEMENTS

Ryan C. Thompson's [List::Flatten::Recursive](https://metacpan.org/pod/List::Flatten::Recursive) 
inspired the creation of the `flat()` function.

Mark Jason Dominus's book [Higher-Order Perl](http://hop.perl.plover.com) 
was and continues to be extremely helpful and informative.  

Kei Kamikawa's [List::Flatten::XS](https://metacpan.org/pod/List::Flatten::XS) makes `flat_fast()`
much, much faster.

# BUGS AND LIMITATIONS

There is no XS version of the `flat()` function.

If you bless something that's not an array reference into a class called
'ARRAY', the pure-perl versions will break. But why would you do that?

# AUTHOR

Aaron Priven <apriven@actransit.org>

# COPYRIGHT & LICENSE

Copyright 2017

This program is free software; you can redistribute it and/or modify it
under the terms of either:

- the GNU General Public License as published by the Free
Software Foundation; either version 1, or (at your option) any
later version, or
- the Artistic License version 2.0.

This program is distributed in the hope that it will be useful, but
WITHOUT  ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or  FITNESS FOR A PARTICULAR PURPOSE.
