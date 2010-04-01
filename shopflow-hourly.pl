#!/usr/bin/env perl

use strict;
use warnings;

use Cheater;

view shopflow =>
    cols => {
        hour => seq(0..23),
        pv => line(0, 16000),
        uv => line(0, 16000),
    },
    ensure => sub {
        my $r = shift;
        $r->{uv} <= $r->{pv};
    };

#warn json($data);

my @cases;

for my $digit (0..9) {
    push @cases, gen_case($digit);
}

write_php 'view-shopflow-hourly.php', @cases;

write_php 'batch-shopflow-hourly.php',
    {
        data => json([
            run_view(shopflow => 24),
            run_view(shopflow => 24),
        ]),
        when => {
            days => regex('[02468]$'),
        }
    },
    {
        data => json([
            run_view(shopflow => 24),
            run_view(shopflow => 24),
        ]),
    };

sub gen_case {
    my $d = shift;
    my $data = run_view shopflow => 24;
    return {
        data => json($data),
        when => {
            day => regex("$d\$"),
        }
    };
}

