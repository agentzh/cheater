#!/usr/bin/env perl

use strict;
use warnings;

use Cheater;
use Data::Dumper;

view shopflow =>
    cols => {
        day => seq(map { "2010-04-$_" } "01".."30"),
        pv => range(0, 16000),
        uv => seq(
            range(0,16000),
            range(0, 16000),
            empty(),
            range(0,16000),
            0,
            range(0, 16000),
        ),
    },
    ensure => sub {
        my $r = shift;
        !defined $r->{uv} or
        !defined $r->{pv} or
        $r->{uv} <= $r->{pv};
    };

#warn json($data);

my @cases;

for my $digit (0..9) {
    push @cases, gen_view_case($digit);
}

write_php 'view-shopflow-daily.php', @cases;

@cases = ();

for my $digit (0..9) {
    push @cases, gen_batch_case($digit);
}

write_php 'batch-shopflow-daily.php', @cases;

sub gen_view_case {
    my $d = shift;
    my $data = run_view shopflow => 30;

    #die Dumper($data);

    return {
        data => json($data),
        when => {
            days => regex("$d\$"),
        }
    };
}

sub gen_batch_case {
    my $d = shift;
    return {
        data => json([
            run_view(shopflow => 31),
            run_view(shopflow => 30),
        ]),
        when => {
            days => regex("$d\$"),
        }
    };
}

