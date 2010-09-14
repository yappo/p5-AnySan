#!/usr/bin/env perl
use strict;
use warnings;
use lib 'lib';

use AnySan;
use AnySan::Provider::Twitter;

my $twitter = twitter
    consumer_key    => '',
    consumer_secret => '',
    token           => '',
    token_secret    => '',
    method          => 'sample',
    ;
