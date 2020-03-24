#!/usr/bin/perl
use v5.18;
use strict;
use warnings;
use utf8;

use lib 'lib';
use Jackett;

# Set API_KEY
# Update Hostname/Port if applicable
my %connect = (
    'API_KEY'       => '***REMOVED***',
    'HOSTNAME'      => 'http://127.0.0.1',
    'PORT'          => '9117',
);

my ( $search ) = join('+', @ARGV) || die "Usage: get_torrent_api.pl <\"search string\">";

my $base_url = join(':', $connect{HOSTNAME}, $connect{PORT});

my @indexers = (
    {url => "$base_url/api/v2.0/indexers/kickasstorrent/results/torznab/", magnet => 1},
    (url => "$base_url/api/v2.0/indexers/rarbg/results/torznab/",          magnet => 1),
    (url => "$base_url/api/v2.0/indexers/glodls/results/torznab/",         magnet => 1),
    (url => "$base_url/api/v2.0/indexers/magnetdl/results/torznab/",       magnet => 1),
    (url => "$base_url/api/v2.0/indexers/torrentz2/results/torznab/",      magnet => 1),
    (url => "$base_url/api/v2.0/indexers/1337x/results/torznab/",          magnet => undef),
    (url => "$base_url/api/v2.0/indexers/badasstorrents/results/torznab/", magnet => undef),
    (url => "$base_url/api/v2.0/indexers/bittorrentam/results/torznab/",   magnet => undef),
    (url => "$base_url/api/v2.0/indexers/exttorrents/results/torznab/",    magnet => undef),
    (url => "$base_url/api/v2.0/indexers/limetorrents/results/torznab/",   magnet => undef),
);

for my $i (0 .. $#indexers) {
    next unless $indexers[$i]{magnet};
    my $api_call = $indexers[$i]{url} . 'api?apikey=' . $connect{API_KEY} . '&t=search&q=' . $search;
    
    say $api_call;
    Jackett->get_torrents($api_call);

}




