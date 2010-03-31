#!/usr/bin/env perl

use strict;
use warnings;

use Cheater;

my $page_size = 25;
my $pages = 8;

view catflow =>
    cols => {
        cat => regex('(衬杉分类|限时(三|五|六|七)折区){1,3}'),
        pv => line(0, 16000),
        uv => line(0, 16000),
        in => line(0, 2000),
        out => line(0, 2000),
    },
    ensure => sub {
        my $r = shift;
        $r->{uv} <= $r->{pv};
    };

my $data = run_view catflow => $page_size * $pages;
#warn json($data);

my @cases;

# my ($cat, $days, $offset, $limit, $sort, $dir) = @_;

for my $page (0..($pages - 1)) {
    my $offset = $page * $page_size;

    push @cases, gen_case(empty(), regex('.'), $offset, $page_size, 'pv', 'asc');
}

write_php 'view-catflow.php', @cases;

sub gen_case {
    my ($cat, $days, $offset, $limit, $sort, $dir) = @_;
    my $sign = $dir eq 'asc' ? 1 : -1;

    @$data = sort { $sign * ($a->{$sort} <=> $b->{$sort}) } @$data;

    my @rows = @{$data}[$offset..($offset + $limit)];

    return {
        data => json(\@rows),
        when => {
            days => $days,
            offset => $offset,
            limit => $limit,
            cat => $cat,
            dir => $dir,
            sort => $sort,
        },
    };
}

