use strict;
use lib '.';
use inc::Module::Install;

name                ('Cheater');
license             ('BSD');
author              ('Agent Zhang <agentzh@gmail.com>');
perl_version        ('5.010001');
all_from            ('lib/Cheater.pm');

requires            ('JSON::XS');
requires            ('File::Slurp');
requires            ('Date::Calc');
requires            ('Data::Random' => '0.12');
requires            ('Parse::RandGen::Regexp');
requires            ('Moose');
requires            ('Clone');
requires            ('Parse::RecDescent');

#build_requires      ('Test::Base' => '0.54');

use_test_base;

no_index( directory => qw< t inc doc share demo > );

install_script      ('bin/cht-compile');
install_script      ('bin/cht-rows2sql');
install_script      ('bin/cht-schema2sql');

auto_install();
repository 'http://github.com/agentzh/cheater';
WriteAll();

if ($^O =~ /Win32/i) {
    system("nmake -f mk") == 0 or die $!;
} else {
    system("make -f mk") == 0 or die $!;
}

