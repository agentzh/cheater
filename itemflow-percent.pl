#!/usr/bin/env perl

use strict;
use warnings;

use POSIX qw( ceil );
use Cheater;
use List::Util qw( max );

my $page_size = 18;

view(itemflow =>
    cols => {
        cat => regex('((衬杉|彩电|冰箱|手表|闹钟|电脑|眼镜|图书)分类|限时(三|五|六|七)折区){1,4}'),
        url => regex('http://cat\.taobao\.com/item/\d{3,6}'),
        pic_index => range(1, 10),
        name => regex('妖精|口袋|珍妮|小姐|古希腊|名媛|配水钻|胸饰|耸肩|俏|西服|咀嚼|星辰|小宫廷|配肩章|帅气|公主袖T'),
        focus => range(0, 100),
        pv => seq(range(0, 16000), 0, empty(), range(0, 16000)),
        uv => seq(range(0, 16000), 0, empty(), range(0, 16000)),
        avg_acc_time => regex('\d{1,3}'),
        in => seq(range(0, 2000), 0, empty(), range(0, 2000)),
        out => seq(range(0, 2000), 0, empty(), range(0, 2000)),
        bounce => seq(empty(), range(0, 100)),
    },
    ensure => sub {
        my $r = shift;
        return !defined $r->{uv} || !defined $r->{pv}
            || $r->{uv} <= $r->{pv};
    },
);

my ($data, @cases);

my $first_time = 1;

for my $d ('[13579]', '[02468]') {
    my $pages = $first_time ? 0.3 : 8;

    if ($first_time) {
        $first_time = 0;
    }

    for my $cat (empty(), regex('\S')) {
        for my $item (empty(), regex('\S')) {
            if (is_empty($cat) || is_empty($item)) {
                gen_cases($pages, $item, $cat, regex("$d\$"));
            }
        }
    }
}

write_php 'view-itemflow-percent.php', @cases;

sub gen_cases {
    my ($pages, $item, $cat, $days) = @_;

    my $n = int($page_size * $pages);

    $data = run_view itemflow => $n;
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
            for my $col (qw(focus avg_acc_time pv uv in out)) {
                push @cases, gen_case($item, $cat, $days, $offset, $limit, $col, $dir);
            }
        }
    }

    # count=1&max=$col

    #for my $col (qw( pv uv in out focus avg_acc_time )) {
    push @cases,
        gen_case($item, $cat, $days, undef, undef, undef, undef, 1, undef);
            #}
}

sub gen_case {
    my ($item, $cat, $days, $offset, $limit, $sort, $dir, $count, $max) = @_;

    if ($count || $max) {
        my $info = {};

        if ($count) {
            $info->{count} = scalar(@$data);
        }

        #if ($max) {
        #$info->{max} = max map { $_->{$max} || 0 } @$data;
        #}

        return {
            data => json([$info]),
            when => {
                days => $days,
                cat => $cat,
                count => $count,
                #max_of => $max,
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
            item => $item,
            dir => $dir,
            sort => $sort,
        },
    };
}

