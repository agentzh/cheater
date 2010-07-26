# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();
no_diff;

run_tests;

__DATA__

=== TEST 1: includes in parallel
--- src
include 't/tmp/dogs.cht';
include 't/tmp/cats.cht';

2 dogs;
2 cats;

--- user_files
>>> dogs.cht
table dogs (
    age integer;
)

>>> cats.cht
table cats (
    birthday date;
)

--- out
cats
      birthday
      2011-04-26
      NULL
dogs
      age
      77303
      192194



=== TEST 2: includes in series
--- src
include 't/tmp/dogs.cht';

2 dogs;
2 cats;

--- user_files
>>> dogs.cht
table dogs (
    age integer;
)

include 't/tmp/cats.cht';

>>> cats.cht
table cats (
    birthday date;
)

--- out
cats
      birthday
      2011-04-26
      NULL
dogs
      age
      77303
      192194

