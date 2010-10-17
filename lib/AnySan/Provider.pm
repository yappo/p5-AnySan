package AnySan::Provider;
use strict;
use warnings;
use base 'Exporter';
our @EXPORT = qw();

sub new {
    my($class, %args) = @_;
    bless { %args }, $class;
}

sub event_callback { die 'event_callback is not implemented ' . ref(shift) }
sub send_message   { die 'event_callback is not implemented ' . ref(shift) }

1;
