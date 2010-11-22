#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';
use utf8;

use AnySan;
use AnySan::Provider::FriendFeed;

my $request = $ARGV[0] || '/feed/cpan';

my $friend_feed = friend_feed
    request => $request
    ;

AnySan->register_listener(
    feed => {
        event => 'entry',
        cb => sub {
            my $receive = shift;
            print $receive->message . "\n";
            print "\t" . $receive->attribute('url') . "\n";
            return;
        },
    },
);

AnySan->run;
