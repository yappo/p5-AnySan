package AnySan::Provider::IRC;
use strict;
use warnings;
use base 'AnySan::Provider';
our @EXPORT = qw(irc);
use AnySan;
use AnySan::Receive;
use AnyEvent::IRC::Client;
use AnyEvent::IRC::Util qw/mk_msg/;
use Encode;

sub irc {
    my($host, %config) = @_;

    my $self = __PACKAGE__->new(
        client => undef,
        config => \%config,
    );
    $self->{config}{wait_queue_size} ||= 100;

    my $port         = $config{port}     || 6667;
    my $nickname     = $config{nickname};
    my $instance_key = $config{key}      || "$host:$port";
    $self->{config}{interval} ||= 2;
    $self->{config}{interval} = 2 unless $self->{config}{interval} =~ /\A[0-9]+\z/;

    my %recive_commands = map {
        uc($_) => 1,
    } @{ $config{recive_commands} || [ 'PRIVMSG' ] };

    my @channels = keys %{ $config{channels} };

    my $con = AnyEvent::IRC::Client->new;
    $self->{client} = $con;

    $con->reg_cb(
        connect =>sub {
            my ($con, $err) = @_;
            if (defined $err) {
                warn "connect error: $err\n";
                return;
            }
        }
    );

    $con->reg_cb (
        'irc_*' => sub {
            my(undef, $param) = @_;
            return if $param->{command} =~ /\A[0-9]+\z/;
            return unless $recive_commands{uc($param->{command})};
            my($channel, $message) = @{ $param->{params} };
            my($nickname, ) = split '!', ($param->{prefix} || '');

            my $receive; $receive = AnySan::Receive->new(
                provider      => 'irc',
                event         => 'privmsg',
                message       => $message,
                nickname      => $config{nickname},
                from_nickname => $nickname,
                attribute     => {
                    channel    => $channel,
                    command    => $param->{command},
                    raw_params => $param,
                },
                cb            => sub { $self->event_callback($receive, @_) },
            );
            AnySan->broadcast_message($receive);
        }
    );

    # connect server
    $con->connect ($host, $port, {
        nick     => $nickname,
        password => $config{password},
    });

    # join channels
    for my $channel (@channels) {
        my $conf = $config{channels}->{$channel};
        warn "join channel: $channel";
        $self->join_channel( $channel, $conf->{key} );
    }

    return $self;
}


sub event_callback {
    my($self, $receive, $type, @args) = @_;

    if ($type eq 'reply') {
        my $cmd = $receive->attribute('send_command') || 'NOTICE';
        my $send = '';
        my $msg = $args[0];
        $msg = encode( utf8 => $msg ) if Encode::is_utf8($msg);
        if ($receive->nickname eq $receive->attribute('channel')) {
            $send = mk_msg undef, $cmd => $receive->from_nickname, $msg;
        } else {
            $send = mk_msg undef, $cmd => $receive->attribute('channel'), $msg;
        }
        $self->_send_raw($send);
    }
}

my $LAST_SEND_TIME = 0;
my @SEND_QUEUE;
my $SEND_TIMER;
sub _run {
    my($self, $cb) = @_;
    if (scalar(@SEND_QUEUE) >= $self->{config}{wait_queue_size}) {
        return;
    }
    if (time() - $LAST_SEND_TIME <= 0 || $SEND_TIMER) {
        $SEND_TIMER ||= AnyEvent->timer(
            after    => 1,
            interval => $self->{config}{interval},
            cb       => sub {
                (shift @SEND_QUEUE)->();
                $LAST_SEND_TIME = time();
                $SEND_TIMER = undef unless @SEND_QUEUE;
            },
        );
        push @SEND_QUEUE, $cb;
        return;
    }
    $cb->();
    $LAST_SEND_TIME = time();
}

sub _send_raw {
    my($self, $send, %args) = @_;
    $self->_run(sub {
        $self->{client}->send_raw($send);
    });
}

sub send_message {
    my($self, $message, %args) = @_;
    $self->_run(sub {
        my $type = $args{privmsg} ? 'PRIVMSG' : 'NOTICE';
        $self->{client}->send_chan(
            $args{channel},
            $type,
            $args{channel},
            $message,
        );
    });
}

sub join_channel {
    my($self, $channel, $key) = @_;
    $self->{client}->send_srv( JOIN => $channel, $key );
}

sub leave_channel {
    my($self, $channel) = @_;
    $self->{client}->send_srv( PART => $channel );
}

1;
__END__

=head1 NAME

AnySan::Provider::IRC - AnySan provide IRC protocol

=head1 SYNOPSIS

  use AnySan;
  use AnySan::Provider::IRC;

  my $irc = irc
      'chat.example.net', # irc servername *required
      port     => 6667, # default is 6667
      password => 'server_password',
      key      => 'example1', # you can write, unique key *required
      nickname => 'AnySan1',  # irc nickname *required
      recive_commands => [ 'PRIVMSG', 'NOTICE' ], # default is [ 'PRIVMSG' ]
      interval        => 2, # default is 2(sec), defence of Excess Flood
      wait_queue_size => 100, # default is 100, for send message buffer size
      channels => {
          '#anysan1' => {},
          '#anysan2' => {
              key => 'channel_key',
          },
      };

  $irc->send_message('irc message', channel => '#irc_channel');
  $irc->send_message('irc message', channel => '#irc_channel', privmsg => 'PRIVMSG');

  $irc->join_channel('#channel');
  $irc->join_channel('#channel', 'channel_key');
  $irc->leave_channel('#channel');

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo <at> shibuya <döt> plE<gt>

=head1 SEE ALSO

L<AnySan>, L<AnyEvent::IRC::Client>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
