package Cheater;

use strict;
use warnings;

use String::Random;
use JSON::Syck;

use Carp qw( croak );

use base 'Exporter';

our @EXPORT = qw(
    seq view is like line
    run_view write_php
    json
    regex
);

our %Views;

sub apply_pattern ($$$);
sub generate_row ($$$);

sub view ($$@) {
    my $name = shift;
    my %params = @_;

    for my $key (keys %params) {
        if ($key eq 'cols' || $key eq 'ensure') {
            next;
        }
        croak "Invalid key in view definition: $key";
    }

    $Views{$name} = \%params;
}

sub seq (@) {
    return ['seq', @_];
}

sub line ($$) {
    return ['line', @_];
}

sub run_view ($$) {
    my ($name, $n) = @_;

    my $view = $Views{$name};

    if (!defined $view) {
        croak "View \"$name\" not defined";
    }

    my $cols = $view->{cols};
    my $ensure = $view->{ensure};

    my $ctx = {};

    my @rows;
    for (1..$n) {
        my $row = generate_row($ctx, $cols, $ensure);
        unless ($ensure->($row)) {
            redo;
        }

        push @rows, $row;
    }

    return \@rows;
}

sub generate_row ($$$) {
    my ($ctx, $cols, $ensure) = @_;

    my $row = {};

    while (my ($col, $pat) = each %$cols) {
        $row->{$col} = apply_pattern($ctx, $col, $pat);
    }

    return $row;
}

sub apply_pattern ($$$) {
    my ($total_ctx, $col, $pat) = @_;

    my $ctx = ($total_ctx->{$col} ||= {});

    my @args = @$pat;
    my $op = shift @args;

    if ($op eq 'seq') {
        my $i = ($ctx->{i} ||= 0);

        #warn $i;

        $ctx->{i}++;

        if ($i >= @args) {
            return $args[-1];
        }

        my $val = $args[$i];

        if (ref $val) {
            my $sub_ctx = ($ctx->{ctx} ||= {});
            return apply_pattern($sub_ctx, $col, $val);
        }

        return $val;
    }

    if ($op eq 'line') {
        my ($from, $to) = @args;

        if (!defined $ctx->{prev}) {
            $ctx->{prev} = int(rand($to - $from) + $from);
        }

        my $k = 1 + (rand(0.3) - 0.15);

        my $cur = int($ctx->{prev} * $k);

        $ctx->{prev} = $cur;

        return $cur;
    }
}

sub write_php ($$@) {
}

sub json ($) {
    my $data = shift;
    JSON::Syck::Dump($data);
}

sub regex ($) {
    return ['regex', @_];
}

1;
