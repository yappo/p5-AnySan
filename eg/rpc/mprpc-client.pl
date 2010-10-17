use common::sense;
use AnyEvent::MPRPC;

my $channel = shift;
my $message = shift;

my $client = mprpc_client '127.0.0.1', '4423';
my $d = $client->call(
    send => {
        channel => $channel,
        message => $message,
    }
);

say $d->recv;
