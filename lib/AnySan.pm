package AnySan;
use strict;
use warnings;
our $VERSION = '0.01';

use AnyEvent;

my $condvar = AE::cv;

sub cv { $condvar }

sub run {
    $condvar->recv;
}


my @hooks = ();
sub register_listener {
    my($class, $name, $args) = @_;
    $args->{event} ||= 'privmsg';
    push @hooks, $args;
}

sub broadcast_message {
    my($class, $receive) = @_;

    for my $hook (@hooks) {
        next unless $hook->{event} eq $receive->event;
        $hook->{cb}->($receive);
    }
}

1;
__END__

=encoding utf8

=head1 NAME

AnySan - ANY mesSaging protocol hANdler

=head1 SYNOPSIS

  # echo bot
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

  AnySan->register_listener(
      echo => {
          cb => sub {
              my $receive = shift;
              return unless $receive->message =~ /^!yappo/;
              $receive->send_replay($receive->message);
          }
      }
  );

  AnySan->run;

=head1 DESCRIPTION

AnySan is L<AnyEvent> based some messaging protocol handling program tool kit.

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo <at> shibuya <döt> plE<gt>

=head1 SEE ALSO

L<AnySan::Receive>,
L<AnyEvent>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
