package AnySan::Provider::IRC;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = qw(irc);
use AnySan;
use AnySan::Receive;
use AnyEvent::IRC::Client;
use AnyEvent::IRC::Util qw/mk_msg/;
use Encode;

my %connections;

sub irc {
    my($host, %config) = @_;

    my $port         = $config{port}     || 6667;
    my $nickname     = $config{nickname};
    my $instance_key = $config{key}      || "$host:$port";

    my @channels = keys %{ $config{channels} };

    my $con = AnyEvent::IRC::Client->new;
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
            my($channel, $message) = @{ $param->{params} };
            my($nickname, ) = split '!', ($param->{prefix} || '');


            if ($param->{command} ne 'PRIVMSG' ||$param->{command} ne 'NOTICE') {
                my $receive; $receive = AnySan::Receive->new(
                    provider      => 'irc',
                    event         => 'privmsg',
                    message       => $message,
                    nickname      => $config{nickname},
                    from_nickname => $nickname,
                    attribute     => {
                        channel => $channel,
                    },
                    cb            => sub { event_callback($receive, $con, @_) },
                );
                AnySan->broadcast_message($receive);
            } else {
                AnySan->broadcast_message();
            }
        }
    );

    # connect server
    $con->connect ($host, $port, { nick => $nickname });

    # join channels
    for my $channel (@channels) {
        my $conf = $config{channels}->{$channel};
        warn "join channel: $channel";
        $con->send_srv( JOIN => $channel, $conf->{key} );
    }

    $connections{$instance_key} = $con;
}


sub event_callback {
    my($receive, $con, $type, @args) = @_;

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
        $con->send_raw($send);
    }
}

1;
__END__
