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
    'chat.example.net',
    key      => 'example2',
    nickname => 'AnySan2',
    channels => {
        '#anysan1' => {},
        '#anysan2' => {},
    };

my $timer; $timer = AnyEvent->timer(
    interval => 55,
    cb => sub {
        for (qw( #anysan1 #anysan2 )) {
            $irc->send_chan( $_, "NOTICE", $_, "??" );
            $irc2->send_chan( $_, "NOTICE", $_, "????" );
        }
    }
);

AnySan->register_listener(
    yappo => {
        cb => sub {
            my $msg = shift;
            return unless $msg =~ /^!yappo/;
            return 'yes!';
        },
    },
);

AnySan->run;
