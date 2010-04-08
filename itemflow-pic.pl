#!/usr/bin/env perl

use strict;
use warnings;

use POSIX qw( ceil );
use Cheater;
use List::Util qw( max );

# _60x60.jpg
# _160x160.jpg

my @pic_urls = qw(
    http://img05.taobaocdn.com/bao/uploaded/i5/T1dsJwXeVJXXagg.U7_065941.jpg
    http://img02.taobaocdn.com/bao/uploaded/i2/T1GO0wXexHXXbIItcV_020144.jpg
    http://img02.taobaocdn.com/bao/uploaded/i2/T1QKVtXjNuXXaNADvb_095329.jpg
    http://img02.taobaocdn.com/bao/uploaded/i2/T1PYlnXodhXXX_WM36_062015.jpg
    http://img08.taobaocdn.com/bao/uploaded/i8/T1YBNvXdJdXXb2KJg9_073040.jpg
    http://img02.taobaocdn.com/bao/uploaded/i2/T1xKJwXhVgXXbXH4ZZ_032555.jpg
);

my @cases;
for my $i (1..10) {
    my $data = [{ pic => $pic_urls[$i] }];
    push @cases, {
        data => json($data),
        when => {
            index => $i,
        },
    }
}

write_php 'view-itemflow-pic.php', @cases;

