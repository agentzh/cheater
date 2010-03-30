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

my $data = run_view shopflow => 24;
#warn json($data);

write_php 'view-shopflow.php',
    {
        data => json(run_view shopflow => 24),
        when => {
            day => regex('[02468]$'),
        }
    },
    {
        data => json(run_view shopflow => 24),

    };

write_php 'batch-shopflow.php',
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

