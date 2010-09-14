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

AnySan -

=head1 SYNOPSIS

  use AnySan;

=head1 DESCRIPTION

AnySan is

=head1 AUTHOR

Kazuhiro Osawa E<lt>yappo <at> shibuya <döt> plE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
