package Cheater::Eval;

use 5.010000;
use Moose;

#use Smart::Comments;
use Date::Calc qw( Localtime );
use Data::Random qw(
    rand_chars
    rand_date rand_time rand_datetime
);
use Parse::RandGen::Regexp ();
use Scalar::Util qw( looks_like_number );

sub get_today ();

our $NowDate = 'now';
our $NowDatetime = 'now';

has 'ast' => (is => 'ro', isa => 'Cheater::AST');
has '_samples' => (is => 'ro', isa => 'HashRef');
has '_cols_visited' => (is => 'ro', isa => 'HashRef');

sub pick_elems ($$$);

sub gen_txt_col ($$$$$$$);
sub gen_num_col ($$$$$$);
sub gen_domain_val ($);

sub gen_int ($);
sub gen_real ($);

sub BUILD {
    my $self = shift;
    $self->{_samples} = {};
    $self->{_cols_visited} = {};
}

sub go {
    my $self = shift;
    my $ast = $self->ast;
    my $goals = $ast->goals;
    ### $goals

    my %computed;
    for my $goal (sort keys %$goals) {
        $computed{$goal} = $self->gen_goal($goal);
    }

    return \%computed;
}

sub rand_regex ($) {
    my $regex = shift;
    Parse::RandGen::Regexp->new(qr/$regex/)->pick();
}

sub gen_goal {
    my ($self, $table) = @_;
    my $ast = $self->ast;

    my $goals = $ast->goals;
    my $tables = $ast->tables;

    my $rows = $goals->{$table};

    my @cols_data;
    my $tb_spec = $tables->{$table} or
        die "Table $table not defined.\n";

    for my $col (@$tb_spec) {
        #say "col: ", $col->[0];
        my $name = $col->[0];
        push @cols_data, $self->gen_column($table, $name);
    }

    return \@cols_data;
}

sub gen_column {
    my ($self, $table, $col_name) = @_;

    #warn "gen column $table.$col_name...\n";

    my $samples = $self->_samples;
    my $cols_visited = $self->_cols_visited;

    my $ast = $self->ast;
    my $deps = $ast->deps;
    my $goals = $ast->goals;
    my $cols = $ast->cols;
    my $types = $ast->types;

    my $qcol = "$table.$col_name";

    if (defined $samples->{$qcol}) {
        return $samples->{$qcol};
    }

    if (my $dep = $cols_visited->{$qcol}) {
        die "ERROR: Found circular column references: $qcol references $dep but $dep somehow depends on $qcol.\n";
    }

    my $rows = $goals->{$table};

    my $spec = $cols->{$qcol} or
        die "Column spec not found for $qcol\n";

    my $type = $spec->{type} or
        die "Type not found for $qcol";

    my $attrs = $spec->{attrs};
    my $domain = $spec->{domain};

    if (my $dep = $deps->{$qcol}) {
        #warn "setting $qcol rely on $dep...\n";

        $cols_visited->{$qcol} = $dep;
        my ($dep_table, $dep_col_name) = split /\./, $dep, 2;
        if (! $cols->{$dep}) {
            die "ERROR: Column $qcol references non-existent column $dep.\n";
        }
        my $refs_data = $self->gen_column($dep_table, $dep_col_name);
        my $data = pick_elems($refs_data, $attrs, $rows);
        $samples->{$qcol} = $data;
        return $data;
    }

    given ($type) {
        when ('text') {
            my $data = gen_txt_col($table, $col_name, $domain, $attrs, $rows,
                sub { join '', rand_chars( set => 'all', min => 5, max => 16 );
                },
                undef,
            );
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('integer') {
            my $data = gen_num_col($table, $col_name, $domain, $attrs, $rows, 'i');
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('serial') {
            push @$attrs, 'serial';
            my $data = gen_num_col($table, $col_name, $domain, $attrs, $rows, 'i');
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('real') {
            #warn "HERE";
            my $data = gen_num_col($table, $col_name, $domain, $attrs, $rows, 'r');
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('date') {
            my $data = gen_txt_col($table, $col_name, $domain, $attrs, $rows,
                sub { rand_date(min => $NowDate) },
                qr/^\d{4}-\d{2}-\d{2}$/,
            );
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('time') {
            my $data = gen_txt_col($table, $col_name, $domain, $attrs, $rows,
                \&rand_time,
                qr/^\d{2}:\d{2}:\d{2}$/,
            );
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('datetime') {
            my $data = gen_txt_col($table, $col_name, $domain, $attrs, $rows,
                sub { rand_datetime(min => $NowDatetime); },
                qr/^\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}$/,
            );
            $samples->{$qcol} = $data;
            return $data;
        }
        default {
            die "Type $type not defined.\n";
            # TODO
            my $type_def = $types->{$type};
            if (! $type_def) {
                die "Type $type not defined for table $table column $col_name.\n";
            }

            my $data = gen_custom_type_col($table, $col_name, $attrs, $type_def, $domain, $rows);
            $samples->{$qcol} = $data;
            return $data;
        }
    }

    # impossible to reach here...
}

sub pick_elems ($$$) {
    my ($set, $attrs, $m) = @_;

    my $not_null;
    for (@$attrs) {
        if ($_ eq 'not null') {
            $not_null = 1;
            last;
        }
    }

    my $n = @$set;
    my @res;
    for (1..$m) {
        if (! $not_null) {
            if ((int rand 10) == 0) {
                push @res, undef;
                next;
            }
        }

        my $i = int rand $n;
        push @res, $set->[$i];
    }

    return \@res;
}

sub gen_int ($) {
    my $unsigned = shift;
    return $unsigned ? (int rand 1_000_000) :
        (int rand 1_000_000) - 500_000;
}

sub gen_real ($) {
    my $unsigned = shift;
    return $unsigned ? (rand 1_000_000) :
        (rand 1_000_000) - 500_000;
}

sub gen_num_col ($$$$$$) {
    my ($table, $col_name, $domain, $attrs, $n, $type) = @_;

    my ($unique, $asc, $desc, $not_null, $unsigned, $empty_domain);

    if ($domain && @$domain == 0) {
        $empty_domain = 1;
    }

    ### $domain
    ### $attrs
    #warn "type: $type\n";

    for (@$attrs) {
        if ($_ eq 'serial') {
            $unique = 1;
            $asc = 1;
            $not_null = 1;
            $unsigned = 1;
        }

        if ($_ eq 'not null') {
            $not_null = 1;
        }

        if ($_ eq 'unique') {
            $unique = 1;
        }

        if ($_ eq 'unsigned') {
            $unsigned = 1;
        }

        if ($_ eq 'asc') {
            $asc = 1;
        }

        if ($_ eq 'desc') {
            $desc = 1;
        }
    }

    if ($asc && $desc) {
        die "table $table, column $col_name: asc hates desc.\n";
    }

    if ($empty_domain && $not_null) {
        die "table $table, column $col_name: empty domain {} hates \"not null\".\n";
    }

    my @nums;
    my %hist;
    for (1..$n) {
        if ($unique) {
            my $i = 0;
            while (1) {
                if (++$i > 10_000) {
                    die "ERROR: Too many attempts failed for table $table, column $col_name.\n";
                }

                my $gen_null;
                if (!$not_null) {
                    $gen_null = (int rand 10) == 0;
                    if ($gen_null) {
                        push @nums, undef;
                        last;
                    }
                }

                if (! $gen_null) {
                    my $num;
                    if (defined $domain) {
                        $num = gen_domain_val($domain);
                        if (!defined $num) {
                            if ($not_null) {
                                die "table $table, column $col_name: not null hates {} domain.\n";
                            }

                            push @nums, $num;
                            last;
                        }

                        if (! looks_like_number($num)) {
                            die "table $table, column $col_name: \"$num\" does not look like a number.\n";
                        }

                        if ($type eq 'i') {
                            $num = int $num;
                        }
                    } else {
                        #warn "Type: $type";
                        $num = $type eq 'i' ? gen_int($unsigned) : gen_real($unsigned);
                    }

                    if (! $hist{$num}) {
                        push @nums, $num;
                        $hist{$num} = 1;
                        last;
                    }
                }
            }
            next;
        }

        my $gen_null;
        if (!$not_null) {
            $gen_null = (int rand 10) == 0;
            if ($gen_null) {
                push @nums, undef;
            }
        }

        if (! $gen_null) {
            my $num;
            if (defined $domain) {
                $num = gen_domain_val($domain);
                if (defined $num) {
                    if (! looks_like_number($num)) {

                        die "table $table, column $col_name: \"$num\" does not look like a number.\n";
                    }

                    $num = int $num if $type eq 'i';
                }
            } else {
                $num = $type eq 'i' ? gen_int($unsigned) : gen_real($unsigned);
            }

            push @nums, $num;
        }
    }

    if ($asc) {
        @nums = sort {
            my $aa = $a // 0;
            my $bb = $b // 0;
            $aa <=> $bb
        } @nums;

    } elsif ($desc) {
        @nums = sort {
            my $aa = $a // 0;
            my $bb = $b // 0;
            $bb <=> $aa
        } @nums;
    }

    return \@nums;
}

sub gen_txt_col ($$$$$$$) {
    my ($table, $col_name, $domain, $attrs, $n, $gen, $check) = @_;

    my ($unique, $asc, $desc, $not_null, $empty_domain);

    if ($domain && @$domain == 0) {
        $empty_domain = 1;
    }

    for (@$attrs) {
        if ($_ eq 'not null') {
            $not_null = 1;
        }

        if ($_ eq 'unique') {
            $unique = 1;
        }

        if ($_ eq 'asc') {
            $asc = 1;
        }

        if ($_ eq 'desc') {
            $desc = 1;
        }
    }

    if ($asc && $desc) {
        die "table $table, column $col_name: asc hates desc.\n";
    }

    if ($empty_domain && $not_null) {
        die "table $table, column $col_name: empty domain {} hates \"not null\".\n";
    }

    my @txts;
    my %hist;
    for (1..$n) {
        if ($unique) {
            my $i = 0;
            while (1) {
                if (++$i > 10_000) {
                    die "ERROR: Too many attempts failed for table $table, column $col_name.\n";
                }
                #warn "unique looping";
                my $gen_null;
                if (! $not_null) {
                    $gen_null = (int rand 10) == 0;
                    if ($gen_null) {
                        push @txts, undef;
                        last;
                    }
                }
                if (! $gen_null) {
                    my $txt;
                    if (defined $domain) {
                        $txt = gen_domain_val($domain);
                        if (!defined $txt) {
                            if ($not_null) {
                                die "table $table, column $col_name: not null hates {} domain.\n";
                            }

                            push @txts, $txt;
                            last;
                        }
                        if (defined $check and $txt !~ $check) {
                            die "table $table, column $col_name: Bad domain value \"$txt\" for the column type.\n";
                        }
                        #warn "txt: $txt";
                    } else {
                        $txt = $gen->();
                    }

                    if (! $hist{$txt}) {
                        push @txts, $txt;
                        $hist{$txt} = 1;
                        last;
                    }
                }
            }
            next;
        }

        my $gen_null;
        if (!$not_null) {
            $gen_null = (int rand 10) == 0;
            if ($gen_null) {
                push @txts, undef;
            }
        }

        if (! $gen_null) {
            my $txt;
            if (defined $domain) {
                $txt = gen_domain_val($domain);
                if (defined $txt and defined $check and $txt !~ $check) {
                    die "table $table, column $col_name: Bad domain value \"$txt\" for the column type.\n";
                }
            } else {
                $txt = $gen->();
            }
            push @txts, $txt;
        }
    } # for loop

    if ($asc) {
        @txts = sort {
            my $aa = $a // 'NULL';
            my $bb = $b // 'NULL';
            $aa cmp $bb
        } @txts;
    } elsif ($desc) {
        @txts = sort {
            my $aa = $a // 'NULL';
            my $bb = $b // 'NULL';
            $bb cmp $aa
        } @txts;
    }

    return \@txts;
}

sub gen_custom_type_col ($$$) {
}

sub to_string {
    my ($self, $computed) = @_;

    my $s = '';

    for my $table (sort keys %$computed) {
        $s .= "$table\n";
        $s .= $self->stringify_table($table, $computed->{$table});
    }

    return $s;
}

sub stringify_table {
    my ($self, $table, $cols) = @_;

    my $ast = $self->ast;
    my $tables = $ast->tables;

    ### $ast

    my $tb_spec = $tables->{$table} or
        die "Table $table not defined.\n";

    my $s = '';

    for my $col (@$tb_spec) {
        #say "col: ", $col->[0];
        my $name = $col->[0];
        $s .= "\t$name";
    }

    $s .= "\n";

    if (!@$cols) {
        return $s;
    }

    my $col = $cols->[0];
    my $nrows = @$col;

    my @rows;
    for my $i (0 .. $nrows - 1) {
        my @row;
        for my $col (@$cols) {
            my $val = $col->[$i] // 'NULL';
            $s .= "\t$val";
        }
        $s .= "\n";
        push @rows, \@row;
    }

    return $s;
}

sub gen_domain_val ($) {
    my $domain = shift;

    ### $domain

    if (@$domain == 0) {
        return undef;
    }

    my $i = int rand @$domain;
    my $atom = $domain->[$i];
    #warn "domain size: ", scalar(@$domain);
    #warn "ATOM: $i $atom\n";
    if (my $ref = ref $atom) {
        if ($ref eq 'Parse::RandGen::Regexp') {
            return $atom->pick;
        } elsif ($ref eq 'Regexp') {
            $atom = Parse::RandGen::Regexp->new($atom);
            return $atom->pick;
        } elsif ($ref eq 'ARRAY') {
            given ($atom->[0]) {
                when ('nrange') {
                    my $a = $atom->[1];
                    my $b = $atom->[2];

                    if ($b < $a) {
                        die "Bad range: $a .. $b: $b < $a\n";
                    }
                    if ($a =~ /^-?\d+$/ && $b =~ /^-?\d+$/) {
                        # pure integer
                        return int(rand($b - $a + 1)) + $a;
                    }

                    return sprintf "%.5lf", rand($b - $a) + $a;
                }
                when ('drange') {
                    my $a = $atom->[1];
                    my $b = $atom->[2];

                    if ($b lt $a) {
                        die "Bad date range: $a .. $b: $b is earlier than $a\n";
                    }

                    return rand_date( min => $a, max => $b );
                }
                when ('trange') {
                    my $a = $atom->[1];
                    my $b = $atom->[2];

                    if ($b lt $a) {
                        die "Bad time range: $a .. $b: $b is earlier than $a\n";
                    }

                    return rand_time( min => $a, max => $b);
                }
                when ('dtrange') {
                    my $a = $atom->[1];
                    my $b = $atom->[2];

                    if ($b lt $a) {
                        die "Bad datetime range: $a .. $b: $b is earlier than $a\n";
                    }

                    return rand_datetime( min => $a, max => $b);
                }
                default {
                    die "Unknown domain atom type: $atom->[0]";
                }
            }
        } else {
            die "Unkown domain atom ref: $ref";
        }
    }

    return $atom;
}

sub canonicalize_table {
    my ($self, $table, $cols) = @_;

    my $ast = $self->ast;
    my $tables = $ast->tables;

    my $tb_spec = $tables->{$table} or
        die "Table $table not defined.\n";

    my @col_names;

    for my $col (@$tb_spec) {
        #say "col: ", $col->[0];
        push @col_names, $col->[0];
    }

    my @rows = (\@col_names);

    if (!@$cols) {
        return \@rows;
    }

    my $col = $cols->[0];
    my $nrows = @$col;

    for my $i (0 .. $nrows - 1) {
        my @row;
        for my $col (@$cols) {
            push @row, $col->[$i];
        }
        push @rows, \@row;
    }

    return \@rows;
}

sub gen_table_schema {
    my ($self, $table) = @_;

    my $ast = $self->ast;
    my $deps = $ast->deps;
    my $tables = $ast->tables;
    my $cols = $ast->cols;

    my $tb_spec = $tables->{$table} or
        die "Table $table not defined.\n";

    my @col_defs;

    for my $col (@$tb_spec) {
        use Data::Dumper;

        my $name = $col->[0];
        my $qcol = "$table.$name";
        my $spec = $cols->{$qcol};
        my $type = $spec->{type};

        while ($type eq 'refs') {
            my $dep = $deps->{$qcol};

            my $col = $cols->{$dep};
            $type = $col->{type};
        }

        #say "type: $type";
        #say Dumper($spec);
        my @attrs = grep { $_ =~ /^(?:not null|unique)$/ } @{ $spec->{attrs} };

        push @col_defs, {
            name => $name,
            type => $type,
            attrs => \@attrs,
        }
    }

    return \@col_defs,
}

1;
