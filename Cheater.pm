package Cheater;

use strict;
use warnings;

use Clone qw( clone );
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
sub generate_php_condition ($);

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
        my $saved_ctx = clone($ctx);
        my $row = generate_row($ctx, $cols, $ensure);
        unless ($ensure->($row)) {
            $ctx = $saved_ctx;
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

        #my $k = 1 + (rand(0.5) - 0.25);

        my $cur = int(rand($to - $from) + $from);

        #$ctx->{prev} = $cur;

        return $cur;
    }
}

sub write_php ($$@) {
    my $file = shift;
    my @branches = @_;

    open my $out, ">$file" or
        die "Cannot open $file for writing: $!\n";

    print $out "<?php\n";

    print $out "header('Content-Type: application/json');\n";

    for my $branch (@branches) {
        my $data = delete $branch->{data};
        my $when = delete $branch->{when};

        if (%$branch) {
            croak "Unknown keys: ", join(', ', keys %$branch);
        }

        my $cond = generate_php_condition($when);

        if ($cond) {
            print $out "if ($cond) {\n";
        }

        print $out "    echo(", as_php_str($data), ");\n";
        print $out "    exit;\n";

        if ($cond) {
            print $out "}\n";
        }
    }

    print $out "?>\n";

    close $out;

    warn "Wrote $file\n";
}

sub generate_php_condition ($) {
    my $when = shift;
    my @prereqs;
    while (my ($arg, $pat) = each %$when) {
        my $var = '$_GET[' . as_php_str($arg) . ']';
        if (ref $pat) {
            my @args = @$pat;
            my $op = shift @args;
            if ($op eq 'regex') {
                my $regex = "/$args[0]/";
                push @prereqs, 'preg_match(' . as_php_str($regex) . ", $var)";

            }
        } else {
            push @prereqs, "$var == " . as_php_str($pat);
        }
    }

    return join ' && ', @prereqs;
}

sub json ($) {
    my $data = shift;
    JSON::Syck::Dump($data);
}

sub regex ($) {
    return ['regex', @_];
}

sub as_php_str ($) {
    my $s = shift;
    if (!defined $s) {
        return '';
    }

    $s =~ s/\\/\\\\/g;
    #$s =~ s/\$/\\\$/g;
    $s =~ s/\t/\\t/g;
    $s =~ s/\n/\\n/g;
    $s =~ s/\r/\\r/g;
    $s =~ s/'/\\'/g;
    "'$s'";
}

1;

