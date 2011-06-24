package Cheater;

use Cheater::Parser;
use Cheater::AST;
use Cheater::Eval;

our $VERSION = '0.08';

1;
__END__

=head1 NAME

Cheater - Generate random database based on rules

=head1 DESCRIPTION

Cheater is a tool that can generate random database based on rules. It's being widely used
within the LineZing team of Taobao.com.

Compared to other similar tools, cheater has the following advantages:

=over

=item *

it can automatically handle the association and foreign key restrictions among
data tables, so it's the real "database instance generator".

=item *

It defines a SQL-like little language to specify the data model that we want to generate from.

=item *

It supports powerful C<{a, b, c}> discrete enumation sets, numerical/time/date interval syntax C<a..b>,
Perl regular expressions C</regex/>, constant values C<'string'>, C<1.32>, and etc, to describe the value
range of data table field.

=item *

It can generate JSON or SQL insert statements to ease importing to RDMBSes like MySQL/PostgreSQL.

=back

Below is a very simple example to demonstrate its basic usage.

First of all, we create a F<.cht> input file in our working directory (say, under F<~/work/>),
in order to describe the data model that we want to geneate data from. Assuming we have
a F<company.cht> file like this:

    # Empolyee table
    table employees (
        id serial;
        name text /[A-Z]a-z{2,5} [A-Z]a-z{2,7}/ not null unique;
        age integer 18..60 not null;
        tel text /1[35]8\d{8}/;
        birthday date;
        height real 1.50 .. 1.90 not null;
        grades text {'A','B','C','D','E'} not null;
        department references departments.id;
    )

    # Department table
    table departments (
        id serial;
        name text /\w{2,10}/ not null;
    )

    10 employees;
    2 departments;

Here we're using the little language (or DSL) defined by cheater itself. It's semantics
is self-explanatory. In particular, the last two lines state that we want to generate 10 rows
of data for the C<employees> table and 2 rows for the C<departments> table.

And then, we use the F<cht-compile> command to compile our F<company.cht> file to generate a
random database instance:

    $ cht-compile company.cht
    Wrote ./data/departments.schema.json
    Wrote ./data/departments.rows.json
    Wrote ./data/employees.schema.json
    Wrote ./data/employees.rows.json

We see that it generates two F<.json> data files for the C<departments> and C<employees> tables,
respectively. For example, the F<data/emplyees.rows.json> file on my machine resulting from
a particular run looks like this:

    $ cat data/employees.rows.json
    [["id","name","age","tel","birthday","height","grades","department"],
    ["7606","Kxhwcn Cflub",54,"15872171866","2011-04-01","1.67276","D","408862"],
    ["63649","Whf Iajgw",55,"13850771916",null,"1.65297","E","844615"],
    ["348161","Nnwe Obfkln",27,"15801601215","2011-03-06","1.69275","D","408862"],
    ["353404","Shgpak Xvqxw",28,"15816453097",null,"1.67796","A","408862"],
    ["445500","Bdt Mhepht",47,"13855517847",null,"1.89943","C","844615"],
    ["513515","Ipsa Mcbtk",25,"13874017694","2011-01-06","1.79534","A","844615"],
    ["658009","Lboe Etqo",27,null,"2011-04-14","1.85162","E","408862"],
    ["716899","Gey Elacflr",18,"15804516095","2011-02-27","1.75681","A","844615"],
    ["945911","Hsuz Qcmky",39,"13862516775","2011-05-31","1.75947","B","408862"],
    ["960643","Qbmbe Ijnbqsb",24,"15872418765","2011-04-11","1.78864","B","844615"]]

These are the "row data". On the other hand, F<./data/employees.schema.json> is the table structure
definition for the C<employees> table. It looks like this on my side:

    [{"attrs":[],"name":"id","type":"serial"},
    {"attrs":["not null","unique"],"name":"name","type":"text"},
    {"attrs":["not null"],"name":"age","type":"integer"},
    {"attrs":[],"name":"tel","type":"text"},
    {"attrs":[],"name":"birthday","type":"date"},
    {"attrs":["not null"],"name":"height","type":"real"},
    {"attrs":["not null"],"name":"grades","type":"text"},
    {"attrs":[],"name":"department","type":"serial"}]

We can generate SQL DDL statement files accepted by RDBMSes like MySQL or PostgreSQL from the
F<.schema.json> files like this:

    $ cht-schema2sql data/employees.schema.json
    Wrote ./sql/employees.schema.sql

The output F<.sql> file looks like this:

    $ cat ./sql/employees.schema.sql
    drop table if exists employees;
    create table employees (
        id serial primary key,
        name text not null unique,
        age integer not null,
        tel text,
        birthday date,
        height real not null,
        grades text not null,
        department serial
    );

If we want to eliminate the drop table statement in the resulting SQL file, we can
specify the C<-n> option while running the F<cht-schema2sql> utility. For instance,

    $ cht-schema2sql -n data/employees.schema.json
    Wrote ./sql/employees.schema.sql

At last, we can use the F<cht-rows2sql> command to convert those F<.rows.json> data files to
F<.sql> files that are ready for relation database systems to import the "row data".

    $ cht-rows2sql data/*.rows.json
    Wrote ./sql/departments.rows.sql
    Wrote ./sql/employees.rows.sql

The F<sql/departments.rows.sql> looks like this on my side:

    $ cat sql/departments.rows.sql
    insert into departments (id,name) values
    (408862,'dJRq7LCXL'),
    (844615,'G_m9Nkh3q');

To prevent the resulting data conflicts with extra unique key restrictions in the targeting
RDMBS table, we can use the C<-r> option to make F<cht-rows2sql> generate SQL replace statements
to work-around this:

    $ cht-rows2sql -r data/*.rows.json
    Wrote ./sql/departments.rows.sql
    Wrote ./sql/employees.rows.sql

Now we're ready to import the random data into database systems like MySQL!

    $ mysql -u monty test -p < sql/departments.rows.sql

For now, cheater is still in active development and lacking comprehensive documentation,
the most complete documentation is its (declarative) test suite:

L<http://github.com/agentzh/cheater/tree/master/t/>

Open one of those F<.t> files, you can see lots of declarative test cases.

=head1 INSTALLATION

    perl Makefile.PL
    make
    make test
    make install

SOURCE REPOSITORY
The source repository of this project is on GitHub:

L<http://github.com/agentzh/cheater/>

If you have found any bugs or feature request, feel free to create tickets on the GitHub issues page:

L<http://github.com/agentzh/cheater/issues>

=head1 AUTHOR

Zhang "agentzh" Yichun (章亦春) C<< <agentzh@gmail.com> >>

