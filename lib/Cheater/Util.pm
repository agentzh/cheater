package Cheater::Util;

use strict;
use warnings;

use base 'Exporter';

our @EXPORT_OK = qw(
    quote_sql_str
);

sub quote_sql_str {
    my $val = shift;
    if (!defined $val) {
        return 'NULL';
    }
    if ($val =~ /^\d+$/) {
        return $val;
    }
    $val =~ s/\r/\\r/g;
    $val =~ s/\n/\\n/g;
    $val =~ s/\\/\\\\/g;
    $val =~ s/'/\\'/g;
    $val =~ s/"/\\"/g;
    $val =~ s/\032/\\$&/g;
    return qq{'$val'};
}

1;
