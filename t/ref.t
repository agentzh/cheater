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
table dogs (
    id serial 1..50;
    age integer not null;
)
table cats (
    id serial;
    friend references dogs.id;
)
3 dogs;
6 cats;
--- out
cats
      id      friend
      96371   38
      170828  18
      577303  19
      749901  38
      785799  38
      870465  19
dogs
      id      age
      18      215538
      19      -416996
      38      -44175



=== TEST 2: datetime
--- src
table dogs (
    id serial 1..50;
    grades text /[A-E]/ not null;
)
table cats (
    id serial;
    friend_grades references dogs.grades;
)
3 dogs;
6 cats;
--- out
cats
      id      friend_grades
      96371   C
      170828  D
      577303  B
      749901  D
      785799  B
      870465  B
dogs
      id      grades
      9       D
      14      B
      48      C

