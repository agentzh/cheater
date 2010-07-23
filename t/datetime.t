# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();
no_diff;

run_tests;

__DATA__

=== TEST 1: datetime
--- src
table cats (
    birthday datetime;
)

5 cats;
--- out
cats
      birthday
      2011-04-23 11:08:20
      NULL
      2011-02-19 07:02:02
      2011-04-02 08:14:00
      2011-06-07 20:22:24



=== TEST 2: datetime (not null)
--- src
table cats (
    birthday datetime not null;
)

5 cats;
--- out
cats
      birthday
      2010-09-23 12:33:12
      2011-04-23 11:08:20
      2010-08-27 06:31:43
      2011-06-06 14:09:59
      2011-02-19 07:02:02



=== TEST 3: datetime (not null, asc)
--- src
table cats (
    birthday datetime asc not null;
)

5 cats;
--- out
cats
      birthday
      2010-08-27 06:31:43
      2010-09-23 12:33:12
      2011-02-19 07:02:02
      2011-04-23 11:08:20
      2011-06-06 14:09:59



=== TEST 4: datetime (not null, desc)
--- src
table cats (
    birthday datetime desc not null;
)

5 cats;
--- out
cats
      birthday
      2011-06-06 14:09:59
      2011-04-23 11:08:20
      2011-02-19 07:02:02
      2010-09-23 12:33:12
      2010-08-27 06:31:43

