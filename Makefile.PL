use inc::Module::Install;
name 'AnySan';
all_from 'lib/AnySan.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
use_test_base;
auto_include;
WriteAll;
