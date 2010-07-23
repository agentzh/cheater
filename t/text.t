# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();
#no_diff;

run_tests;

__DATA__

=== TEST 1: text column
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



=== TEST 2: text column not null
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



=== TEST 3: enum simple texts
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



=== TEST 4: enum simple nums
--- src
table users (
    name text {-3.1,-1,1.5,3} not null;
)

8 users;
--- out
users
      name
      -3.1
      1.5
      -3.1
      3
      1.5
      3
      1.5
      -1



=== TEST 5: enum unique
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



=== TEST 6: regex
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



=== TEST 7: empty domain
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



=== TEST 8: int range
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



=== TEST 9: real range
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



=== TEST 10: int range (negative numbers)
--- src
table users (
    name text -3..-1 unique;
)

4 users;
--- out
users
      name
      -3
      -1
      -2
      NULL



=== TEST 11: real range (negative numbers)
--- src
table users (
    name text -2.0..-1.5 unique;
)

4 users;
--- out
users
      name
      -1.95181
      -1.60710
      -1.56305
      -1.82314

