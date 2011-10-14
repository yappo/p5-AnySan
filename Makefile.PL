use inc::Module::Install;
name 'AnySan';
all_from 'lib/AnySan.pm';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
WriteAll;
