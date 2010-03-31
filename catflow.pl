#!/usr/bin/env perl

use strict;
use warnings;

use Cheater;
use List::Util qw( max );

my $page_size = 25;
my $pages = 8;

view catflow =>
    cols => {
        cat => regex('((衬杉|彩电|冰箱|手表|闹钟|电脑|眼镜|图书)分类|限时(三|五|六|七)折区){1,4}'),
        pv => line(0, 16000),
        uv => line(0, 16000),
        in => line(0, 2000),
        out => line(0, 2000),
    },
    ensure => sub {
        my $r = shift;
        $r->{uv} <= $r->{pv};
    };

my ($data, @cases);

gen_cases(empty());
gen_cases(regex('\S'));

write_php 'view-catflow.php', @cases;

sub gen_cases {
    my $cat = shift;

    $data = run_view catflow => $page_size * $pages;
    #warn json($data);

    # my ($cat, $days, $offset, $limit, $sort, $dir) = @_;

    for my $page (0..($pages - 1)) {
        my $offset = $page * $page_size;

        for my $dir (qw(asc desc)) {
            for my $col (qw(pv uv in out)) {
                push @cases, gen_case($cat, regex('.'), $offset, $page_size, $col, $dir);
            }
        }
    }

    # count=1&max=$col

    for my $col (qw( pv uv in out )) {
        push @cases,
            gen_case($cat, regex('.'), undef, undef, undef, undef, 1, $col);
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
            $info->{max} = max map { $_->{$max} } @$data;
        }

        return {
            data => json([$info]),
            when => {
                days => $days,
                cat => $cat,
                count => $count,
                max => $max,
            },
        };
    }

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

