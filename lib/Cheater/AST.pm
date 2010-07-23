package Cheater::AST;

use 5.010001;
use Moose;

has 'goals' => (is => 'ro', isa => 'HashRef');
has 'cols' => (is => 'ro', isa => 'HashRef');
has 'deps' => (is => 'ro', isa => 'HashRef');
has 'types' => (is => 'ro', isa => 'HashRef');
has 'tables' => (is => 'ro', isa => 'HashRef');

around BUILDARGS => sub {
    my $orig = shift;
    my $class = shift;

    my $parse_tree = shift;

    #warn "BUILDARGS";

    my (%tables, %cols, %deps, %goals, %types);

    my %cols_visited;

    %types = (
        integer => ['core'],
        text    => ['core'],
        serial  => ['core'],
        real    => ['core'],
    );

    for my $stmt (@$parse_tree) {
        #say $stmt->[0];
        my $typ = $stmt->[0];

        given ($typ) {
            when ('type') {
                my $typname = $stmt->[1];
                my $def = $stmt->[2];
                $types{$typname} = $def;
            }
            when ('rows') {
                my $table = $stmt->[2];
                my $rows = $goals{$table};
                if ($rows) {
                    die "table $table was configured to generate $rows rows.\n";
                }
                $rows = $stmt->[1];
                $goals{$table} = $rows;
            }
            when ('table') {
                my $table_name  = $stmt->[1];
                my $table = $stmt->[2];
                $tables{$table_name} = $table;
                for my $col (@$table) {
                    #say "col: ", $col->[0];
                    my $name = $col->[0];
                    my $type = $col->[1];

                    if ($type eq 'refs') {
                        my $target = $col->[2];
                        $deps{"$table_name.$name"} =
                            $target->[0] . '.' . $target->[1];
                    } elsif (! $types{$type}) {
                        die "column type $type not defined.\n";
                    }

                    my $domain = $col->[2];
                    if (@$domain == 0) {
                        $domain = undef;
                    } else {
                        $domain = $domain->[0];
                    }

                    my $attrs = $col->[3];
                    $cols{"$table_name.$name"} = {
                        type => $type,
                        domain => $domain,
                        attrs => $attrs,
                    };
                }
            }
            default {
                warn "unknown statement type: $typ\n";
            }
        }
    }

    return {
        tables  => \%tables,
        cols    => \%cols,
        deps    => \%deps,
        goals   => \%goals,
        types   => \%types,
    };
};

1;
