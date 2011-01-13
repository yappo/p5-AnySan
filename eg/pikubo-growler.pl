#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use utf8;

use AnyEvent;
use Cocoa::EventLoop;
use Cocoa::Growl ':all';

use AnySan;
use AnySan::Provider::Twitter;
use Config::Pit;

my $config = pit_get("pikubo-growler", require => {
    consumer_key    => 'your twitter consumer_key',
    consumer_secret => 'your twitter consumer_secret',
    token           => 'your twitter access_token',
    token_secret    => 'your twitter access_token_secret',
});

growl_register(
    app           => 'Pikubo Growler',
    icon          => 'http://pikubo.jp/favicon.ico',
    notifications => [qw( PhotoGrowler )],
);

my $twitter = twitter
    %{ $config },
    method   => 'filter',
    track    => 'pikubo',
    ;

AnySan->register_listener(
    pikubo => {
        event => 'timeline',
        cb => sub {
            my $receive = shift;
            return unless $receive->message;
            return unless $receive->message =~ m{(http://pikubo.me/([a-zA-Z0-9\-_]+))};
            my($url, $id) = ($1, $2);
            my $img_url = "http://pikubo.me/q/$id";

            growl_notify(
                name        => 'PhotoGrowler',
                title       => $receive->from_nickname,
                description => $receive->message,
                icon        => $img_url,
                on_click    => sub { system 'open', $url }
            );
        },
    },
);

AnySan->run;
