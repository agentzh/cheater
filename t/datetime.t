# vi:ft=

use strict;
use warnings;

use t::Cheater;

$Cheater::Eval::NowDatetime = '2010-07-23 0:0:0';

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



=== TEST 5: datetime range domain
--- src
table cats (
    birthday datetime 2010-05-24  03:45:00..2010-06-05 18:46:05 not null;
)

5 cats;
--- out
cats
      birthday
      2010-06-02 14:59:02
      2010-06-04 03:31:00
      2010-06-03 01:51:41
      2010-05-28 19:29:34
      2010-06-02 13:31:38



=== TEST 6: datetime range domain (default :00)
--- src
table cats (
    birthday datetime 2010-05-24  03:45..2010-05-24 03:46 not null;
)

5 cats;
--- out
cats
      birthday
      2010-05-24 03:45:45
      2010-05-24 03:45:53
      2010-05-24 03:45:47
      2010-05-24 03:45:22
      2010-05-24 03:45:45



=== TEST 7: bad datetime from domain definition
--- src
table cats (
    birthday time 5..6;
)

3 cats;
--- err
table cats, column birthday: Bad domain value "5" for the column type.

