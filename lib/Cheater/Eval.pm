package Cheater::Eval;

use 5.010001;
use Moose;

#use Smart::Comments;
use Data::Random qw( rand_chars );

has 'ast' => (is => 'ro', isa => 'Cheater::AST');
has '_samples' => (is => 'ro', isa => 'HashRef');
has '_cols_visited' => (is => 'ro', isa => 'HashRef');

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
        ### $goal
        $computed{$goal} = $self->gen_goal($goal);
    }

    return \%computed;
}

sub gen_goal {
    my ($self, $table) = @_;
    my $ast = $self->ast;

    my $goals = $ast->goals;
    my $tables = $ast->tables;

    my $rows = $goals->{$table};

    my @cols_data;
    my $tb_spec = $tables->{$table} or
        die "Cannot found table $table.\n";

    for my $col (@$tb_spec) {
        #say "col: ", $col->[0];
        my $name = $col->[0];
        push @cols_data, $self->gen_column($table, $name);
    }

    return \@cols_data;
}

sub gen_column {
    my ($self, $table, $col_name) = @_;

    my $samples = $self->_samples;
    my $cols_visited = $self->_cols_visited;

    my $ast = $self->ast;
    my $deps = $ast->deps;
    my $goals = $ast->goals;
    my $cols = $ast->cols;
    my $types = $ast->types;

    #### $col_name
    my $qcol = "$table.$col_name";

    if (defined $samples->{$qcol}) {
        return $samples->{$qcol};
    }

    if (my $dep = $cols_visited->{$qcol}) {
        die "ERROR: Found circular column references: $qcol references $dep but $dep somehow depends on $qcol.\n";
    }

    my $rows = $goals->{$table};

    if (my $dep = $deps->{$qcol}) {
        $cols_visited->{$qcol} = $dep;
        my ($dep_table, $dep_col_name) = split /\./, $dep, 2;
        if (! $cols->{$dep}) {
            die "ERROR: Column $qcol references non-existent column $dep.\n";
        }
        my $refs_data = $self->gen_column($dep_table, $dep_col_name);
        return pick_elems($refs_data, $rows);
    }

    my $spec = $cols->{$qcol} or
        die "Column spec not found for $qcol\n";
    #### $spec
    my $type = $spec->{type} or
        die "Type not found for $qcol";

    my $attrs = $spec->{attrs};

    given ($type) {
        when ('text') {
            my $data = gen_txt_col($attrs, $rows);
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('integer') {
            my $data = gen_int_col($attrs, $rows);
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('serial') {
            push @$attrs, 'serial';
            my $data = gen_int_col($attrs, $rows);
            $samples->{$qcol} = $data;
            return $data;
        }
        when ('number') {
            my $data = gen_num_col($attrs, $rows);
            $samples->{$qcol} = $data;
            return $data;
        }
        default {
            my $type_def = $types->{$type};
            if (! $type_def) {
                die "Type $type not defined for table $table column $col_name.\n";
            }

            my $data = gen_custom_type_col($attrs, $type_def, $rows);
            $samples->{$qcol} = $data;
            return $data;
        }
    }
}

sub pick_elems ($$) {
    my ($set, $m) = @_;
    my $n = @$set;
    my @res;
    for (1..$m) {
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

sub gen_int_col ($$) {
    my ($attrs, $n) = @_;

    my ($unique, $sort, $not_null, $unsigned);

    for (@$attrs) {
        if ($_ eq 'serial') {
            $unique = 1;
            $sort = 1;
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
    }

    my @nums;
    my %hist;
    for (1..$n) {
        if ($unique) {
            while (1) {
                my $gen_null;
                if (!$not_null) {
                    $gen_null = (int rand 10) == 0;
                    if ($gen_null) {
                        push @nums, undef;
                    }
                }
                if (!$gen_null) {
                    my $num = gen_int($unsigned);
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
            my $num = gen_int($unsigned);
            push @nums, $num;
        }
    }

    if ($sort) {
        @nums = sort @nums;
    }

    return \@nums;
}

sub gen_num_col ($$) {
    my ($attrs, $n) = @_;
}

sub gen_txt_col ($$) {
    my ($attrs, $n) = @_;

    my ($unique, $sort, $not_null);

    for (@$attrs) {
        if ($_ eq 'not null') {
            $not_null = 1;
        }

        if ($_ eq 'unique') {
            $unique = 1;
        }
    }

    my @txts;
    my %hist;
    for (1..$n) {
        if ($unique) {
            while (1) {
                my $gen_null;
                if (!$not_null) {
                    $gen_null = (int rand 10) == 0;
                    if ($gen_null) {
                        push @txts, undef;
                    }
                }
                if (!$gen_null) {
                    my $txt = join '',
                        rand_chars( set => 'all', min => 5, max => 16 );
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
            my $txt = join '',
                rand_chars( set => 'all', min => 5, max => 16 );
            push @txts, $txt;
        }
    }

    return \@txts;
}

sub gen_custom_type_col ($$$) {
}

sub to_string {
    my ($self, $computed) = @_;

    ### hi...
    ### $computed

    my $s = '';

    for my $table (sort keys %$computed) {
        $s .= "$table\n";
        $s .= $self->stringify_table($table, $computed->{$table});
    }

    ### $s
    return $s;
}

sub stringify_table {
    my ($self, $table, $cols) = @_;

    my $ast = $self->ast;
    my $tables = $ast->tables;

    my $tb_spec = $tables->{$table} or
        die "Cannot found table $table.\n";

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
            $s .= "\t$col->[$i]";
        }
        $s .= "\n";
        push @rows, \@row;
    }

    return $s;
}

1;
