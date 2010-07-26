package Cheater::Parser::Util;

use strict;
use warnings;
use Exporter qw( import );

our @EXPORT_OK = qw(
    parse_included_file
);

sub parse_included_file ($$) {
    my ($file, $lineno) = @_;
    open my $in, $file or
        die "Failed to include file $file: $!\n";
    my $src = do { local $/; <$in> };
    close $in;

    my $parser = Cheater::Parser->new;
    my $parse_tree = $parser->spec($src) or
        die "ERROR: line $lineno: Failed to parse the included file $file\n";

    return $parse_tree;
}

1;
