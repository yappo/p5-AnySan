package AnySan::Receive;
use strict;
use warnings;

sub new {
    my($class, %args) = @_;
    bless { %args }, $class;
}

sub provider      { $_[0]->{provider} }
sub event         { $_[0]->{event} }
sub nickname      { $_[0]->{nickname} }
sub from_nickname { $_[0]->{from_nickname} }
sub message       { $_[0]->{message} }

sub attribute {
    my($self, $name, $value) = @_;
    return $self->{attribute}->{$name} = $value if defined $name && defined $value;
    return $self->{attribute}->{$name} if defined $name;
    return $self->{attribute};
}

sub send_reply {
    my($self, $message) = @_;
    $self->{cb}->(
        reply => $message
    );
}

# for backward compatible
*send_replay = \&send_reply;

1;
__END__

=head1 NAME

AnySan::Receive - recive messages manipulate object

=head1 SYNOPSIS

  AnySan->register_listener(
      synopsis => {
          cb => sub {
              my $receive = shift; # get AnySan::Receive object
              $receive->event; # irc's NOTICE or PRIVMSG
              $receive->nickname; # your nickname
              $receive->from_nickname; # nickname of message writer
              $receive->message; # recive message
              my $geo = $receive->attribute('geo'); # twitter's geo object
              $receive->send_replay('message'); # sending message
          }
      }
  );

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo <at> shibuya <döt> plE<gt>

=head1 SEE ALSO

L<AnySan>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
