package AnySan::Provider::FriendFeed;
use strict;
use warnings;
use base 'AnySan::Provider';
our @EXPORT = qw(friend_feed);
use AnySan;
use AnySan::Receive;
use AnyEvent::FriendFeed::Realtime;

sub friend_feed {
    my(%config) = @_;

    my $self = __PACKAGE__->new(
        client => undef,
        config => \%config,
    );

    my $client = AnyEvent::FriendFeed::Realtime->new(
        username   => $config{user},
        remote_key => $config{remote_key},
        request    => $config{request},
        on_entry   => sub {
            my $entry = shift;
            my $receive; $receive = AnySan::Receive->new(
                provider      => 'friend_feed',
                event         => 'entry',
                message       => $entry->{body},
                nickname      => $config{nickname} || '',
                from_nickname => $entry->{from}->{name},
                attribute     => {
                    id         => $entry->{id},
                    url        => $entry->{url},
                    geo        => $entry->{geo},
                    icon_url   => $entry->{thumbnails}->[0]->{url},
                    created_at => $entry->{date},
                },
                cb            => sub { $self->event_callback($receive, @_) },
            );
            AnySan->broadcast_message($receive);
        }
    );
    $self->{client} = $client;

    return $self;
}

sub event_callback {
    my($self, $receive, $type, @args) = @_;

    if ($type eq 'reply') {
        warn 'send_replay is not suportted.';
    }
}

sub send_message {
    warn 'send_message is not suportted.';
}

1;
