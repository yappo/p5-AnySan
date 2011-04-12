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
use Encode;

my $config = pit_get("japan-earthquake-growler", require => {
    consumer_key    => 'your twitter consumer_key',
    consumer_secret => 'your twitter consumer_secret',
    token           => 'your twitter access_token',
    token_secret    => 'your twitter access_token_secret',
});

growl_register(
    app           => 'Japan EarthQuake Growler',
    notifications => [qw( JapanEarthQuakeGrowler )],
);

my $twitter = twitter
    %{ $config },
    method   => 'filter',
    follow   => '16052553', # 0000,11111,2222,3333,444
    ;

AnySan->register_listener(
    pikubo => {
        event => 'timeline',
        cb => sub {
            my $receive = shift;
            return unless $receive->message;
            my $msg = $receive->message;
            $msg = encode( utf8 => $msg ) if Encode::is_utf8($msg);
            printf "%s: %s\n", $receive->from_nickname, $msg;

            growl_notify(
                name        => 'JapanEarthQuakeGrowler',
                title       => $receive->from_nickname,
                description => $receive->message,
#                icon        => $img_url,
#                on_click    => sub { system 'open', $url }
            );
        },
    },
);

AnySan->run;
