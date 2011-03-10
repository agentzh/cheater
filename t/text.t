# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();
no_diff;

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
      96371   %Fx})Bo"&
      170828  opE/_b
      577303  t*Ea.S(oC@~kVLY
      749901  6?]Z);
      785799  @TbE%2Y5$s(y~&67
      870465  NULL



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
      96371   &%xB}7S$)y"oF
      170828  Nz27e'
      577303  *SVCH@cX~YELk.
      749901  6Fq+S2;]zR)/
      785799  y%i~e
      870465  k1K'cIT0%*



=== TEST 3: asc sorted text column
--- src
table foo (
    title text {'hello', 'hel', 'abc', 2, 12} asc;
)

10 foo;
--- out
foo
      title
      12
      12
      2
      2
      2
      2
      NULL
      abc
      abc
      hel



=== TEST 4: desc sorted text column
--- src
table foo (
    title text {'hello', 'hel', 'abc', 2, 12} desc;
)

10 foo;
--- out
foo
      title
      hel
      abc
      abc
      NULL
      2
      2
      2
      2
      12
      12



=== TEST 5: enum simple texts
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



=== TEST 6: enum simple nums
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



=== TEST 7: enum (mixture)
--- src
table users (
    name text {18, -9.1, /[a-c]{3}/, 1..2} not null unique;
)

8 users;
--- out
users
     name
     18
     bcc
     -9.1
     2
     ccb
     abb
     aaa
     1



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



=== TEST 10: empty domain enum
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



=== TEST 13: int range (negative numbers)
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



=== TEST 14: real range (negative numbers)
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



=== TEST 9: regex with escaped dashes
--- src
table users (
    name text /http:\/\/[a-z]{3}\d{2}/ not null unique;
    age integer /\d{4}/ not null;
)

4 users;
--- out
users
      name    age
      http://wpu38    1584
      http://tgk85    1772
      http://cok98    9564
      http://ylu09    4619

