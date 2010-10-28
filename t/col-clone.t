# vi:ft=

use strict;
use warnings;

use t::Cheater;

plan tests => 1 * blocks();

$Cheater::Eval::NowDate = '2010-07-23';

no_diff;

run_tests;

__DATA__

=== TEST 1: date
--- src
table cats (
    birthday date;
    birthday2 = birthday;
)

5 cats;
--- out
cats
      birthday        birthday2
      2011-04-23      2011-04-23
      NULL    NULL
      2011-02-19      2011-02-19
      2011-04-02      2011-04-02
      2011-06-07      2011-06-07

