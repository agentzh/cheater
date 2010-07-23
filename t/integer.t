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
      96371
      170828
      577303
      749901
      870465



=== TEST 3: simple asc
--- src
table users (
    id integer asc unique not null;
)

5 users;
--- out
users
   id
   -403629
   -329172
   77303
   249901
   370465



=== TEST 4: simple desc
--- src
table users (
    id integer desc unique not null;
)

5 users;
--- out
users
   id
   370465
   249901
   77303
   -329172
   -403629



=== TEST 5: integer and null
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



=== TEST 6: integer w/o null
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



=== TEST 7: enum simple integers
--- src
table users (
    name integer {1, 3, 5, 7} not null;
)

8 users;
--- out
users
      name
      1
      5
      1
      7
      5
      7
      5
      3



=== TEST 8: enum simple nums
--- src
table users (
    name integer {-3.1,-1,1.5,3} not null;
)

8 users;
--- out
users
      name
      -3
      1
      -3
      3
      1
      3
      1
      -1



=== TEST 9: enum (mixture)
--- src
table users (
    name integer {18, -9.1, /[a-c]{3}/, 1..2} not null;
)

8 users;
--- err
table users, column name: "bcc" does not look like a number.



=== TEST 10: enum unique
--- src
table users (
    name integer {'abc','bcd','c','d'} not null;
)

4 users;
--- err
table users, column name: "abc" does not look like a number.



=== TEST 11: regex
--- src
table users (
    name integer /\d{2}/ not null unique;
)

4 users;
--- out
users
      name
      85
      87
      23
      70



=== TEST 12: empty domain enum
--- src
table users (
    name integer {} unique;
)

4 users;
--- out
users
      name
      NULL
      NULL
      NULL
      NULL



=== TEST 13: int range
--- src
table users (
    name integer 1..3 unique;
)

4 users;
--- out
users
      name
      1
      3
      2
      NULL



=== TEST 14: real range
--- src
table users (
    name integer 1.0..3.0 unique;
)

4 users;
--- out
users
      name
      1
      2
      NULL
      NULL



=== TEST 15: int range (negative numbers)
--- src
table users (
    name integer -3..-1 unique;
)

4 users;
--- out
users
      name
      -3
      -1
      -2
      NULL



=== TEST 16: real range (negative numbers)
--- src
table users (
    name integer -2.0..-1.5 unique;
)

4 users;
--- out
users
      name
      -1
      NULL
      NULL
      NULL

