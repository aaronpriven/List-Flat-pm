
# tests to be attempted by all permutations of loading

deep_test_both( ['j'], ['j'], 'Flatten single scalar' );

deep_test_both( [qw/k l m n o p/], [qw/k l m n o p/], 'Flatten simple list' );

deep_test_both( [ [ [ [qw/q r/] ] ] ], [qw/q r/], 'Flatten nested arrayrefs' );

my @complex = ( qw/a b/, [ qw/c d/, [qw/e f/], 'g' ], 'h' );
my @flat_complex = (qw/a b c d e f g h/);

deep_test_both( \@complex, \@flat_complex, 'Flatten complex array' );

my @sublist       = (qw/w x y/);
my @repeated      = ( qw/z AA/, \@sublist, qw/BB/, \@sublist );
my @flat_repeated = (qw/z AA w x y BB w x y/);

deep_test_both( \@repeated, \@flat_repeated,
    'Flatten complex array with repeated sublists' );

my @circlist = (qw/CC DD EE/);
push @circlist, [@circlist];
my @test_circlist = flat(qw/CC DD EE/);
my @flat_circlist = (qw/CC DD EE/);

deep_test_flat( \@test_circlist, \@flat_circlist,
    'Flatten array with circular reference' );

require Scalar::Util;

my $blessed = bless [ 't', ['u'] ], 'Dummyclass';

my @blessed_list       = ( 's', $blessed, 'v' );
my @test_blessed_list  = flat(@blessed_list);
my @testx_blessed_list = flatx(@blessed_list);

is( Scalar::Util::blessed $blessed_list[1],
    Scalar::Util::blessed $test_blessed_list[1],
    "flat: Blessed member is not flattened"
);

is( Scalar::Util::blessed $blessed_list[1],
    Scalar::Util::blessed $testx_blessed_list[1],
    "flatx: Blessed member is not flattened"
);

sub deep_test_both {
    deep_test_flat(@_);
    deep_test_flatx(@_);
}

sub deep_test_flat {

    my @list        = @{ +shift };
    my @flat        = @{ +shift };
    my $description = shift;

    my @flattened_array     = flat(@list);
    my $flattened_scalarref = flat(@list);

    is_deeply( \@flat, \@flattened_array, "flat, list context: $description" );
    is_deeply( \@flat, $flattened_scalarref,
        "flat, scalar context: $description" );

    return;

}

sub deep_test_flatx {

    my @list        = @{ +shift };
    my @flat        = @{ +shift };
    my $description = shift;

    my @flattened_array     = flatx(@list);
    my $flattened_scalarref = flatx(@list);

    is_deeply( \@flat, \@flattened_array, "flatx, list context: $description" );
    is_deeply( \@flat, $flattened_scalarref,
        "flatx, scalar context: $description" );

    return;

}

1;
