package AnySan::Provider::Twitter;
use strict;
use warnings;
use base 'AnySan::Provider';
our @EXPORT = qw(twitter);
use AnySan;
use AnySan::Receive;
use AnyEvent::Twitter;
use AnyEvent::Twitter::Stream;

sub twitter {
    my(%config) = @_;

    my $self = __PACKAGE__->new(
        client => undef,
        config => \%config,
    );

    my $poster = AnyEvent::Twitter->new(
        consumer_key        => $config{consumer_key},
        consumer_secret     => $config{consumer_secret},
        access_token        => $config{token},
        access_token_secret => $config{token_secret},
    );
    $self->{poster} = $poster;

    if ($config{method} ne 'none') {
        my %opts = (
            consumer_key    => $config{consumer_key},
            consumer_secret => $config{consumer_secret},
            token           => $config{token},
            token_secret    => $config{token_secret},
            method          => $config{method} || 'userstream',
        );
        for my $param (qw/track follow locations/) {
            $opts{$param} = $config{$param} if defined $config{$param};
        }

        my $listener = AnyEvent::Twitter::Stream->new(
            %opts,
            on_tweet => sub {
                my $tweet = shift;
                my $receive; $receive = AnySan::Receive->new(
                    provider      => 'twitter',
                    event         => 'timeline',
                    message       => $tweet->{text},
                    nickname      => $config{nickname},
                    from_nickname => $tweet->{user}->{screen_name},
                    attribute     => {
                        geo        => $tweet->{geo},
                        icon_url   => $tweet->{user}->{profile_image_url},
                        created_at => $tweet->{created_at},
                        obj        => $tweet,
                    },
                    cb            => sub { $self->event_callback($receive, @_) },
                );
                AnySan->broadcast_message($receive);
            },
            timeout => $config{timeout},
        );
        $self->{listener} = $listener;
    }

    return $self;
}

sub event_callback {
    my($self, $receive, $type, @args) = @_;

    if ($type eq 'reply') {
        $self->{poster}->request(
            api    => 'statuses/update',
            method => 'POST',
            params => {
                status => $args[0],
            },
            sub {}
        );
    }
}

sub send_message {
    my($self, $message, %args) = @_;

    $self->{poster}->request(
        api    => 'statuses/update',
        method => 'POST',
        params => {
            status => $message,
            %{ $args{params} || +{} },
        },
        sub {}
    );
}

1;
__END__

=head1 NAME

AnySan::Provider::Twitter - AnySan provide Twitter

=head1 SYNOPSIS

  use AnySan;
  use AnySan::Provider::Twitter;

  my $twitter = twitter
      key      => 'example1', # you can write, unique key *required

      # AnyEvent::Twitter::Stream's options
      consumer_key     => 'twitter consumer_key', # *required
      consumer_secret  => 'twitter consumer_secret', # *required
      token            => 'twitter token', # *required
      token_secret     => 'twitter token_secret', # *required

      method           => 'filter', # default is 'userstream' *required
      track            => 'keyword',
      follow           => '....',
      locations        => '....',
      timeout          => $timeout,
  ;

  $irc->send_message('twitter message');
  $irc->send_message('twitter message', %AnyEvent_Twitter_requires_options);

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo <at> shibuya <döt> plE<gt>

=head1 SEE ALSO

L<AnySan>, L<AnyEvent::Twitter>, L<AnyEvent::Twitter::Stream>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
