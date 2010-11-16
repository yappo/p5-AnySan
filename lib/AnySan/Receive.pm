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

