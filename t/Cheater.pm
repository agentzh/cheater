package t::Cheater;

use Test::Base -Base;

#use Smart::Comments;
use lib 'lib';
use Cheater;

#$::RD_HINT = 1;
#$::RD_TRACE = 1;

our @EXPORT = qw(
    run_test run_tests
);

our $RandSeed = 0;

sub rand_seed ($) {
    $RandSeed = shift;
}

sub bail_out (@) {
    Test::More::BAIL_OUT(@_);
}

sub run_test ($) {
    my $block = shift;
    my $name = $block->name;

    srand($RandSeed);

    my $parser = Cheater::Parser->new;

    my $src = $block->src or
        bail_out("$name - No --- src specified");

    (my $expected = $block->out) //
        bail_out("$name - No --- out specified");

    my $parse_tree = $parser->spec($src) or
        bail_out("$name - Failed to parse --- src due to grammatic errors");

    my $ast = Cheater::AST->new($parse_tree) or
        bail_out("$name - Cannot construct the AST");

    my $eval = Cheater::Eval->new(ast => $ast);

    my $computed = $eval->go or
        bail_out("$name - Failed to evaluate a random data base instance");

    my $got = $eval->to_string($computed);
    ### $got
    $got =~ s/ {2,}/\t/g;
    $expected =~ s/ {2,}/\t/g;
    is($got, $expected, "$name - output db ok");
}

sub run_tests () {
    for my $block (blocks()) {
        run_test($block);
    }
}

