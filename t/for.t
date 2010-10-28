# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();

no_diff;

run_tests;

__DATA__

=== TEST 1: date
--- src
table cats (
    birthday date for '生日';
)

5 cats;
--- out
cats
      birthday
      2011-07-29
      NULL
      2011-05-27
      2011-07-08
      2011-09-12

