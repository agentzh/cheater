# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();
no_diff;

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



=== TEST 3: integer and null
--- src
table users (
    id integer;
)

5 users;
--- out
users
      id
      249901
      NULL
      77303
      192194
      373904



=== TEST 4: integer w/o null
--- src
table users (
    id integer not null;
)

5 users;
--- out
users
      id
      -329172
      249901
      -403629
      370465
      77303

