#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';

use AnyEvent::MPRPC;
use AnySan;
use AnySan::Provider::IRC;

my $irc = irc
    'chat.freenode.net',
    key      => 'example1',
    nickname => 'AnySan1',
    channels => {
        '#danthebot' => {},
    };

my $server = mprpc_server '127.0.0.1', '4423';
$server->reg_cb(
    send => sub {
        my ($res_cv, $args) = @_;
        $irc->send_message(
            $args->{message},
            channel => $args->{channel},
        );

        $res_cv->result('sent'); # return to client
    },
);

AnySan->run;
