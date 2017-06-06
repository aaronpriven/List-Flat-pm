use strict;
use Test::More 0.98;

use_ok $_ for qw(
    List::Flat
);

ok( ! __PACKAGE__->can( 'flat' ),
    'module should not export flat() by default' );

ok( ! __PACKAGE__->can( 'flatx' ),
    'module should not export flatx() by default' );
    
package Flat;

List::Flat->import('flat');

main::ok( __PACKAGE__->can( 'flat' ),
    'module should export flat() on request' );
    
    main::ok( ! __PACKAGE__->can( 'flatx' ),
    'module should not export flatx() when flat() requested' );

package Flatx;

List::Flat->import('flatx');

main::ok( __PACKAGE__->can( 'flatx' ),
    'module should export flatx() on request' );
    
main::ok( ! __PACKAGE__->can( 'flat' ),
    'module should not export flat() when flatx() requested' );
    
package Both;

List::Flat->import(qw/flat flatx/);

main::ok( ( __PACKAGE__->can( 'flatx') and __PACKAGE__->can('flat')) ,
    'module should export both flat() and flatx() when requested' );

package main;

done_testing;

