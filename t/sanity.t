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



=== TEST 5: text column
--- src
table users (
    id serial;
    name text;
)

6 users;
--- out
users
      id      name
      170828  %Fx})Bo"&
      577303  opE/_b
      749901  t*Ea.S(oC@~kVLY
      785799  6?]Z);
      870465  @TbE%2Y5$s(y~&67
      96371   NULL



=== TEST 6: text column not null
--- src
table users (
    id serial;
    name text not null;
)

6 users;
--- out
users
      id      name
      170828  &%xB}7S$)y"oF
      577303  Nz27e'
      749901  *SVCH@cX~YELk.
      785799  6Fq+S2;]zR)/
      870465  y%i~e
      96371   k1K'cIT0%*



=== TEST 7: enum simple texts
--- src
table users (
    name text {'abc','bcd','c'} not null;
)

6 users;
--- out
users
      name
      abc
      c
      abc
      c
      bcd
      c



=== TEST 8: enum unique
--- src
table users (
    name text {'abc','bcd','c','d'} not null unique;
)

4 users;
--- out
users
      name
      abc
      c
      d
      bcd



=== TEST 9: regex
--- src
table users (
    name text /[a-z]{3}\d{2}/ not null unique;
)

4 users;
--- out
users
      name
      wpu38
      tgk85
      cok98
      ylu09



=== TEST 10: empty domain
--- src
table users (
    name text {} unique;
)

4 users;
--- out
users
      name
      NULL
      NULL
      NULL
      NULL



=== TEST 11: int range
--- src
table users (
    name text 1..3 unique;
)

4 users;
--- out
users
      name
      1
      3
      2
      NULL



=== TEST 12: real range
--- src
table users (
    name text 1.0..3.0 unique;
)

4 users;
--- out
users
      name
      1.19274
      2.57160
      2.74781
      1.70746

