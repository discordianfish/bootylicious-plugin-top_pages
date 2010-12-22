package Bootylicious::Plugin::TopPages;

use strict;
use warnings;

use base 'Mojo::Base';

use Mojo::ByteStream 'b';
use Data::Dumper;

sub register {
    my ($self, $app, $conf) = @_;

    $conf ||= {};

    return unless $conf->{pages};

    $app->plugins->add_hook(
        after_dispatch => sub {
            my ($self, $c) = @_;

            return unless $c->res->code && $c->res->code == 200;

            my $body = $c->res->body;
            return unless $body;

            $c->stash(pages => $conf);

            my $string;

            $string .= b($app->booty->get_page($_)->content)->encode('UTF-8')
                for (@{ $conf->{pages} });

            $body =~ s{<body>}{<body><div id="toppages">$string</div>};
            $c->res->body($body);
        }
    );
}

1;
