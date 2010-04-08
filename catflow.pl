#!/usr/bin/env perl

use strict;
use warnings;

use POSIX qw( ceil );
use Cheater;
use List::Util qw( max );

my $page_size = 25;

view catflow =>
    cols => {
        cat => regex('((衬杉|彩电|冰箱|手表|闹钟|电脑|眼镜|图书)分类|限时(三|五|六|七)折区){1,4}'),
        url => regex('http://cat\.taobao\.com/item/\d{3,6}'),
        pv => seq(range(0, 16000), 0, empty(), range(0, 16000)),
        uv => seq(range(0, 16000), 0, empty(), range(0, 16000)),
        in => seq(range(0, 16000), 0, empty(), range(0, 2000)),
        out => seq(range(0, 16000), 0, empty(), range(0, 2000)),
    },
    ensure => sub {
        my $r = shift;
        return !defined $r->{uv} || !defined $r->{pv}
            || $r->{uv} <= $r->{pv};
    };

my ($data, @cases);

my $first_time = 1;

for my $d ('[02468]', '[13579]') {
    my $pages = ! $first_time ? 0.3 : 8;

    if ($first_time) {
        $first_time = 0;
    }

    for my $cat (empty(), regex('\S')) {
        gen_cases($pages, $cat, regex("$d\$"));
    }
}

write_php 'view-catflow.php', @cases;

sub gen_cases {
    my ($pages, $cat, $days) = @_;

    my $n = int($page_size * $pages);

    $data = run_view catflow => $n;
    #warn json($data);

    # my ($cat, $days, $offset, $limit, $sort, $dir) = @_;

    my $total_pages = ceil($pages);
    for my $page (0..($total_pages - 1)) {
        my $offset = $page * $page_size;

        my $limit;

        if ($page == $total_pages - 1) {
            $limit = $n - $offset;
        } else {
            $limit = $page_size;
        }

        for my $dir (qw(asc desc)) {
            for my $col (qw(pv uv in out)) {
                push @cases, gen_case($cat, $days, $offset, $limit, $col, $dir);
            }
        }
    }

    # count=1&max=$col

    for my $col (qw( pv uv in out )) {
        push @cases,
            gen_case($cat, $days, undef, undef, undef, undef, 1, $col);
    }
}

sub gen_case {
    my ($cat, $days, $offset, $limit, $sort, $dir, $count, $max) = @_;

    if ($count || $max) {
        my $info = {};

        if ($count) {
            $info->{count} = scalar(@$data);
        }

        if ($max) {
            $info->{max} = max map { $_->{$max} || 0 } @$data;
        }

        return {
            data => json([$info]),
            when => {
                days => $days,
                cat => $cat,
                count => $count,
                max_of => $max,
            },
        };
    }

    my $sign = $dir eq 'asc' ? 1 : -1;

    @$data = sort {
        my $va = $a->{$sort} || 0;
        my $vb = $b->{$sort} || 0;
        $sign * ($va <=> $vb)
    } @$data;

    my @rows = @{$data}[$offset..($offset + $limit - 1)];

    return {
        data => json(\@rows),
        when => {
            days => $days,
            offset => $offset,
            limit => $page_size,
            cat => $cat,
            dir => $dir,
            sort => $sort,
        },
    };
}

