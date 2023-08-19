#!/usr/bin/perl
use v5.18;
use strict;
use warnings;
use utf8;

use lib 'lib';
use Jackett;
use Data::Dumper;

# Set API_KEY
my %config = (
    'API_KEY'           => 'placeholder',
    'HOSTNAME'          => 'http://127.0.0.1',
    'PORT'              => '9117',
    'MIN_TORRENT_SIZE'  =>  300,  # MB
    'MAX_TORRENT_SIZE'  =>  2500, # MB
    'API_TIMEOUT'       =>  10,   # Seconds (Not yet implemented)
    'MAGNETS_ONLY'      =>  undef,
    'MIN_SEEDS'         =>  3,
    'RESULTS'            =>  10,  # Torrents to pull from each indexer DB
    'CAT'               =>  2000, #Category (Movies = 2000)
);

my ( $search ) = join('+', @ARGV) || die "Usage: get_torrent_api.pl <\"search string\">";

# Name matching for torrent title
my $name = join(' ', @ARGV);
my $name_alt = $name =~ s/\s+/\./r;
my $re = qr/^(?:$name|$name_alt)/i;

my $base_url = join(':', $config{'HOSTNAME'}, $config{'PORT'});

my @indexers = (
    {'url' => "$base_url/api/v2.0/indexers/kickasstorrent/results/torznab/", 'magnet' => 1},
    {'url' => "$base_url/api/v2.0/indexers/rarbg/results/torznab/",          'magnet' => 1},
    {'url' => "$base_url/api/v2.0/indexers/glodls/results/torznab/",         'magnet' => 1},
    {'url' => "$base_url/api/v2.0/indexers/magnetdl/results/torznab/",       'magnet' => 1},
    {'url' => "$base_url/api/v2.0/indexers/torrentz2/results/torznab/",      'magnet' => 1},
    {'url' => "$base_url/api/v2.0/indexers/1337x/results/torznab/",          'magnet' => undef},
    {'url' => "$base_url/api/v2.0/indexers/badasstorrents/results/torznab/", 'magnet' => undef},
    #{'url' => "$base_url/api/v2.0/indexers/bittorrentam/results/torznab/",   'magnet' => undef}, # Lots of connection issues
    {'url' => "$base_url/api/v2.0/indexers/exttorrents/results/torznab/",    'magnet' => undef},
    {'url' => "$base_url/api/v2.0/indexers/limetorrents/results/torznab/",   'magnet' => undef},
);

my @torrents; # Store array of hashes
my @valid_torrents; # Store valid torrents

# Loop through indexers and pull torents via api calls
for my $i (0 .. $#indexers) {
    if ($config{'MAGNETS_ONLY'}) {
       next unless $indexers[$i]{'magnet'}; 
    }
    
    # Example:
    # http://127.0.0.1:9117/api/v2.0/indexers/1337x/results/torznab/api?apikey={REMOVED}&t=search&cat=2000&q=ubuntu+server&limit=10
    my $api_call = $indexers[$i]{'url'}.'api?apikey='.$config{'API_KEY'}.'&t=search&cat='.$config{'CAT'}.'&q='.$search.'&limit='.$config{'RESULTS'};  
    say $api_call;
    my $magnet = $indexers[$i]{'magnet'} // undef;
    push @torrents, Jackett->get_torrents($api_call, $magnet);
}

# Filter invalid torrents
for my $i (0 .. $#torrents) {
    next if $torrents[$i]{'size'} > $config{'MAX_TORRENT_SIZE'};
    next if $torrents[$i]{'size'} < $config{'MIN_TORRENT_SIZE'};
    next if $torrents[$i]{'seeds'} < $config{'MIN_SEEDS'};
    next if $torrents[$i]{'title'} !~ /$re/;
    next if $torrents[$i]{'title'} =~ /FRENCH|GERMAN|SPANISH|GER|FR/;
    next unless $torrents[$i]{'magnet'};
    
    push @valid_torrents, $torrents[$i];
}

if (!@valid_torrents) {
    die "No valid torrents found for '$name'";
}


# Sort list by number of seeders
# Download the first torrent in the list

my @sorted = sort { $b->{seeds} <=> $a->{seeds} } @valid_torrents;
Jackett->download_torrent($sorted[0]{magnet});


say "---------------------------------";
say "Title  : ",$sorted[0]{title};
say "Seeders: ",$sorted[0]{seeds};
say "Size   : ",$sorted[0]{size};
say "---------------------------------";






