#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use utf8;

use AnySan::Provider::Twitter;
use Config::Pit;

my $username = shift;

my $config = pit_get('zenrabot', require => {
    consumer_key    => 'your twitter consumer_key',
    consumer_secret => 'your twitter consumer_secret',
    token           => 'your twitter access_token',
    token_secret    => 'your twitter access_token_secret',
});

my $twitter = twitter
    %{ $config },
    method          => 'userstream',
    ;

my $timer; $timer = AnyEvent->timer(
    after => 10,
    cb => sub {
        $twitter->send_message('#yapcasia test: ' . time);
    }
);

AnySan->register_listener(
    zenrart => {
        event => 'timeline',
        cb => sub {
            my $receive = shift;
            return unless $receive->message;
            return unless $receive->message =~ /全裸/;
            return if $receive->message =~ /^RT /;
            $receive->send_replay(sprintf 'RT @%s: %s', $receive->from_nickname, $receive->message);
        },
    },
);

AnySan->run;
