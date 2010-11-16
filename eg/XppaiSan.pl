#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';

use AnySan;
use AnySan::Provider::IRC;


my $irc = irc
    'chat.example.net',
    key      => 'example1',
    nickname => 'AnySan1',
    channels => {
        '#anysan1' => {},
        '#anysan2' => {},
    };

my $irc2 = irc
    'chat.xample.net',
    key      => 'example2',
    nickname => 'AnySan2',
    channels => {
        '#anysan1' => {},
        '#anysan2' => {},
    };

my $timer; $timer = AnyEvent->timer(
    interval => 55,
    cb => sub {
        for ('#anysan1', '#anysan2' ) {
            $irc->send_message( '??', channel => $_ );
            $irc2->send_message( '????', channel => $_ );
        }
    }
);

AnySan->register_listener(
    yappo => {
        cb => sub {
            my $receive = shift;
            return unless $receive->message =~ /^!yappo/;
            $receive->send_reply('poppo---!');
            return 'yes!';
        },
    },
);

AnySan->run;
