#!/usr/bin/perl

use warnings;
use strict;
use Carp;

use AnyEvent::Handle;
use AnyEvent::Socket;
use JSON qw(from_json to_json);
use File::Slurp;
use Getopt::Long;

my $config_file = '/etc/http-tcp-bus.json';

GetOptions( 'config=s', \$config_file );

my $config = from_json( read_file $config_file);
my $secret = $config->{secret} // croak "Secret not defined in config file";

my $w;

sub on_connect {
    my ($fh) = @_;

    if ( ! defined $fh ) {
        AE::log error => "Connect failed: $!";
        $w = AnyEvent->timer( after => 5, cb => \&reconnect );
        return;
    }

    my ( $hdl, $ping_guard );

    my $forget_cb = sub {
        AE::log error => "Connection dead";
        $ping_guard = undef;
        $hdl->push_shutdown;
        $hdl->destroy;
        $w = AnyEvent->timer( after => 5, cb => \&reconnect );
    };

    $hdl = new AnyEvent::Handle(
        fh       => $fh,
        timeout  => 60,
        on_error => sub {
            my ( $hdl, $fatal, $msg ) = @_;
            $forget_cb->();
        },
        on_eof => sub {
            $forget_cb->();
        },
        on_timeout => sub {
            $forget_cb->();
        } );

    $ping_guard = AnyEvent->timer(
        after    => 5,
        interval => 5,
        cb       => sub {
            $hdl->push_write( json => { secret => $secret, command => 'ping' } );
        } );

    foreach my $repo ( keys %{ $config->{repos} } ) {
        $hdl->push_write( json => { secret => $secret, command => 'subscribe', queue => "git-push-org-personal" } );
    }

    my $process_input;
    $process_input = sub {
        my $json = $_[1];

        if ( defined $json->{type} && $json->{type} eq 'message' ) {
            if ( defined $json->{queue} && $json->{queue} =~ m{^git-push-(.*)} && exists $config->{repos}{$1} ) {
                my $repo = $1;

                if ( exists $config->{repos}{$repo}{path} ) {
                    my $path = $config->{repos}{$repo}{path};
                    system "cd $path && git-sync";
                }
            }
        }

        $hdl->push_read( json => $process_input );
    };

    $hdl->push_read( json => $process_input );

}

sub reconnect {
    tcp_connect $config->{server} // 'lepikhin.site', $config->{port} // 9099, \&on_connect;
}

reconnect();

my $cv = AE::cv;
$cv->recv;
