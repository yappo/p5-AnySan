#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use utf8;

use AnySan;
use AnySan::Provider::Twitter;
use Config::Pit;

my $username = shift;

my $config = pit_get("example.com", require => {
    consumer_key    => 'your twitter consumer_key',
    consumer_secret => 'your twitter consumer_secret',
    token           => 'your twitter access_token',
    token_secret    => 'your twitter access_token_secret',
});

my $twitter = twitter
    %{ $config },
    method          => 'userstream',
    ;

AnySan->register_listener(
    acotie => {
        event => 'timeline',
        cb => sub {
            my $receive = shift;
            return unless $receive->message;
            return unless $receive->message =~ /^\@$username\s*(.+)$/;
            $receive->send_reply(sprintf '@%s txh %s', $receive->from_nickname, $1);
        },
    },
);

AnySan->run;
