package AnySan::Provider::Twitter;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = qw(twitter);
use AnySan;
use AnySan::Receive;
use AnyEvent::Twitter;
use AnyEvent::Twitter::Stream;

use Net::Twitter::Lite;

sub twitter {
    my(%config) = @_;

    my $poster = Net::Twitter::Lite->new(
        consumer_key        => $config{consumer_key},
        consumer_secret     => $config{consumer_secret},
        access_token        => $config{token},
        access_token_secret => $config{token_secret},
    );

    my $listener = AnyEvent::Twitter::Stream->new(
        consumer_key    => $config{consumer_key},
        consumer_secret => $config{consumer_secret},
        token           => $config{token},
        token_secret    => $config{token_secret},
        method          => $config{method} || 'userstream',
        track           => $config{track}  || '',
        on_tweet => sub {
            my $tweet = shift;
            my $receive; $receive = AnySan::Receive->new(
                provider      => 'twitter',
                event         => 'timeline',
                message       => $tweet->{text},
                nickname      => $config{nickname},
                from_nickname => $tweet->{user}->{screen_name},
                attribute     => {
                    geo      => $tweet->{geo},
                    icon_url => $tweet->{user}->{profile_image_url},
                },
                cb            => sub { event_callback($receive, $poster, @_) },
            );
            AnySan->broadcast_message($receive);

        },
        timeout => $config{timeout} || 120,
    );
}

sub event_callback {
    my($receive, $poster, $type, @args) = @_;

    if ($type eq 'reply') {
        $poster->update({ status => $args[0] });
    }
}


1;
