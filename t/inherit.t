# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();
no_diff;

run_tests;

__DATA__

=== TEST 1: int ref
--- src
table dogs (
    id serial 1..50;
    age integer not null;
)
cats = dogs;
4 dogs;
4 cats;
--- out
cats
      id      age
      19      373904
      38      245095
      40      -53955
      44      -146272
dogs
      id      age
      5       -44175
      14      -390054
      29      45228
      39      -109314

