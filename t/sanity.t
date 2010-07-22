# vi:ft=

use strict;
use warnings;
use t::Cheater;

plan tests => 1 * blocks();

run_tests;

__DATA__

=== TEST 1: no goals
--- src
table users (
    id serial;
)
--- out



=== TEST 2: simple
--- src
table users (
    id serial;
)

5 users;
--- out
users
       id
       170828
       577303
       749901
       870465
       96371

