use inc::Module::Install;
name 'AnySan';
all_from 'lib/AnySan.pm';
readme_from 'lib/AnySan.pm';
readme_markdown_from 'lib/AnySan.pm';
githubmeta;

requires 'AnyEvent';
requires 'AnyEvent::IRC';
requires 'AnyEvent::Twitter';
requires 'AnyEvent::Twitter::Stream';
requires 'AnyEvent::FriendFeed::Realtime';

tests 't/*.t';
author_tests 'xt';

build_requires 'Test::More';
auto_set_repository;
WriteAll;
