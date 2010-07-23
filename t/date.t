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
    birthday date;
)

5 cats;
--- out
cats
      birthday
      2011-04-23
      NULL
      2011-02-19
      2011-04-02
      2011-06-07



=== TEST 2: date (not null)
--- src
table cats (
    birthday date not null;
)

5 cats;
--- out
cats
      birthday
      2010-09-23
      2011-04-23
      2010-08-27
      2011-06-06
      2011-02-19



=== TEST 3: date (not null, asc)
--- src
table cats (
    birthday date asc not null;
)

5 cats;
--- out
cats
      birthday
      2010-08-27
      2010-09-23
      2011-02-19
      2011-04-23
      2011-06-06



=== TEST 4: date (not null, desc)
--- src
table cats (
    birthday date desc not null;
)

5 cats;
--- out
cats
      birthday
      2011-06-06
      2011-04-23
      2011-02-19
      2010-09-23
      2010-08-27

