# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();
no_diff;

run_tests;

__DATA__

=== TEST 1: real and null
--- src
table users (
    id real;
)

5 users;
--- out
users
      id
      249901.980484964
      NULL
      77303.5067951077
      192194.15345864
      373904.076861809



=== TEST 2: real w/o null
--- src
table users (
    id real not null;
)

5 users;
--- out
users
      id
      -329171.96389371
      249901.980484964
      -403628.344376433
      370465.227027076
      77303.5067951077



=== TEST 3: enum simple reals
--- src
table users (
    name real {1, 3, 5, 7} not null;
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



=== TEST 4: enum simple nums
--- src
table users (
    name real {-3.1,-1,1.5,3} not null;
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



=== TEST 5: enum (mixture)
--- src
table users (
    name real {18, -9.1, /[a-c]{3}/, 1..2} not null;
)

8 users;
--- out
users
     name
      18
      0
      -9.1
      2
      -9.1
      -9.1
      0
      0



=== TEST 6: enum unique
--- src
table users (
    name real {'abc','bcd','c','d'} not null;
)

4 users;
--- out
users
      name
      0
      0
      0
      0



=== TEST 7: regex
--- src
table users (
    name real /\d{1}\.\d{2}/ not null unique;
)

4 users;
--- out
users
      name
      8.38
      7.85
      1.98
      9.09



=== TEST 8: empty domain enum
--- src
table users (
    name real {} unique;
)

4 users;
--- out
users
      name
      NULL
      NULL
      NULL
      NULL



=== TEST 9: int range
--- src
table users (
    name real 1..3 unique;
)

4 users;
--- out
users
      name
      1
      3
      2
      NULL



=== TEST 10: real range
--- src
table users (
    name real 1.0..3.0 unique;
)

4 users;
--- out
users
      name
      1.19274
      2.57160
      2.74781
      1.70746



=== TEST 11: int range (negative numbers)
--- src
table users (
    name real -3..-1 unique;
)

4 users;
--- out
users
      name
      -3
      -1
      -2
      NULL



=== TEST 12: real range (negative numbers)
--- src
table users (
    name real -2.0..-1.5 unique;
)

4 users;
--- out
users
      name
      -1.95181
      -1.60710
      -1.56305
      -1.82314

