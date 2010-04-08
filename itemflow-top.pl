#!/usr/bin/env perl

use strict;
use warnings;

use POSIX qw( ceil );
use Cheater;
use List::Util qw( max );

view(itemflow_top =>
    cols => {
        name => regex('((衬杉|彩电|冰箱|手表|闹钟|电脑|眼镜|图书)分类|限时(三|五|六|七)折区){1,4}'),
        url => regex('http://cat\.taobao\.com/item/\d{3,6}'),
        item_index => range(1, 10),
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

my $data = run_view itemflow_top => 11;

my @cases;

for my $cat (empty(), regex('\S')) {
    for my $item (empty(), regex('\S')) {
        for my $col (qw( focus avg_acc_time uv pv in out )) {
            @$data = sort {
                my $va = $a->{$col} || 0;
                my $vb = $b->{$col} || 0;
                -($va <=> $vb)
            } @$data;

            push @cases, {
                data => json($data),
                when => {
                    days => regex('\d$'),
                    cat => $cat,
                    item => $item,
                    #dir => 'desc',
                    sort => $col,
                }
            };
        }
    }
}

write_php 'view-itemflow-top.php', @cases;

