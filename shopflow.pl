#!/usr/bin/env perl

use strict;
use warnings;

use Cheater;

view shopflow =>
    cols => {
        hour => is(0..23),
        uv => line(0, 16000),
        pv => line(0, 16000),
    },
    ensure => sub {
    };

my $data = run_view shopflow => 24;

write_php 'view-shopflow.php',
    json($data),
    when => {
        day => like('[02468]$'),
    };

write_php 'batch-shopflow.php',
    json([
        run_view shopflow => 24,
        run_view shopflow => 24,
    ),
    when => {
        days => like('[02468],'),
    };

