#!/usr/bin/env perl

use strict;
use warnings;

use POSIX qw( ceil );
use Cheater;
use List::Util qw( max );

my @days = map { "2010-04-$_" } ("01", "03".."30");

view(itemflow_trend =>
    cols => {
        pv => seq(range(0, 16000), 0, empty(), range(0, 16000)),
        uv => seq(range(0, 16000), 0, empty(), range(0, 16000)),
        day => seq(@days),
    },
    ensure => sub {
        my $r = shift;
        return !defined $r->{uv} || !defined $r->{pv}
            || $r->{uv} <= $r->{pv};
    },
);

my ($data, @cases);

for my $d (0..9) {
    my $data = run_view itemflow_trend => 29;
    push @cases, {
        data => json($data),
        when => {
            item_index => regex("$d\$"),
        }
    };
}

write_php 'view-itemflow-trend.php', @cases;

