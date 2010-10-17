#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use utf8;

use AnyEvent::IRC::Server;
use AnySan::Provider::Twitter;
use Config::Pit;
use Encode;

my $channel = '#twitter';

my $config = pit_get('tig-for-anysan', require => {
    consumer_key    => 'your twitter consumer_key',
    consumer_secret => 'your twitter consumer_secret',
    token           => 'your twitter access_token',
    token_secret    => 'your twitter access_token_secret',
});

my $twitter = twitter
    %{ $config },
    method          => 'userstream',
    ;

my $ircd = AnyEvent::IRC::Server->new(
    port       => 6667,
    servername => '127.0.0.1',
);
$ircd->run();

$ircd->reg_cb(
    daemon_privmsg => sub {
        my ($irc, $nick, $chan, $text) = @_;
        $twitter->send_message(decode( utf8 => $text ));
    },
);

my %users;
AnySan->register_listener(
    tig => {
        event => 'timeline',
        cb => sub {
            my $receive = shift;
            return unless $receive->message;
            $users{$receive->from_nickname} ||= do {
                $ircd->daemon_cmd_join($receive->from_nickname, $channel, 'JOIN', dummyHandle->new);
                1;
            };
            $ircd->daemon_cmd_privmsg(
                $receive->from_nickname => $channel,
                encode( utf8 => $receive->message ),
            );
        },
    },
);

AnySan->run;

package
  dummyHandle;

sub new {
    bless {
        'nick' => '',
    }, shift;
}

sub push_write{}

