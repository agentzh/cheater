# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();
no_diff;

run_tests;

__DATA__

=== TEST 1: int ref
--- src
table dogs (
    id serial 1..50;
    age integer not null;
)
table cats (
    id serial;
    friend references dogs.id;
)
4 dogs;
7 cats;
--- out
cats
      id      friend
      96371   44
      170828  37
      577303  NULL
      692194  20
      749901  23
      785799  44
      870465  20
dogs
      id      age
      20      -224492
      23      -239639
      37      424094
      44      -64078



=== TEST 2: text ref
--- src
table dogs (
    id serial 1..50;
    grades text /[A-E]/ not null;
)
table cats (
    id serial;
    friend_grades references dogs.grades;
)
4 dogs;
8 cats;
--- out
cats
      id      friend_grades
      96371   B
      170828  B
      368766  D
      577303  D
      692194  B
      749901  NULL
      785799  B
      870465  D
dogs
      id      grades
      6       B
      16      D
      22      A
      27      B



=== TEST 3: text ref (not null on foreign keys)
--- src
table dogs (
    id serial 1..50;
    grades text /[A-E]/ not null;
)
table cats (
    id serial;
    friend_grades references dogs.grades not null;
)
4 dogs;
8 cats;
--- out
cats
      id      friend_grades
      96371   A
      170828  B
      368766  B
      577303  B
      692194  D
      749901  D
      785799  B
      870465  D
dogs
      id      grades
      7       B
      8       D
      44      A
      48      B



=== TEST 4: text refs in parallel
--- src
table dogs (
    id serial 1..50;
    grades text /[A-E]/ not null;
)
table cats (
    id serial;
    friend_grades references dogs.grades not null;
)
table birds (
    id serial;
    foo references dogs.grades not null;
);
4 dogs;
4 cats;
4 birds;
--- out
birds
      id      foo
      96371   B
      170828  B
      749901  D
      870465  B
cats
      id      friend_grades
      163189  B
      568585  B
      867719  A
      959066  B
dogs
      id      grades
      7       B
      8       B
      44      D
      48      A



=== TEST 5: text refs in series
--- src
table dogs (
    id serial 1..50;
    grades text /[A-E]/ not null;
)
table cats (
    id serial;
    friend_grades references dogs.grades not null;
)
table birds (
    id serial;
    foo references cats.friend_grades not null;
);
4 dogs;
4 cats;
4 birds;
--- out
birds
      id      foo
      96371   D
      170828  B
      749901  B
      870465  B
cats
      id      friend_grades
      260361  B
      275508  B
      435922  D
      924094  B
dogs
      id      grades
      7       B
      8       B
      44      D
      48      A



=== TEST 6: int ref
--- src
table dogs (
    id serial 1..50;
    self_id references dogs.id not null;
)
4 dogs;
--- out
dogs
      id      self_id
      19      44
      38      40
      40      38
      44      38

