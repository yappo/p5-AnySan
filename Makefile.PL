use inc::Module::Install;
name 'AnySan';
all_from 'lib/AnySan.pm';

requires 'AnyEvent';
requires 'AnyEvent::IRC';
requires 'AnyEvent::Twitter';
requires 'AnyEvent::Twitter::Stream';
requires 'AnyEvent::FriendFeed::Realtime';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
WriteAll;
