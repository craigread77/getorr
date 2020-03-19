#!/usr/bin/perl
use v5.18;
use strict;
use warnings;

use lib 'lib';
use Getorr;

my $DEBUG;

# Get name of movie
my $name = $ARGV[0] or die "Usage: get_torrent.pl <Name of Movie>";
my $words_match = join('|', split(' ', $name));
my $magnet;


# Returns list of torrent hashesfrom 1337x.to
# keys are (url, title, size, seeders)
my @torrents = Getorr->fetch_leet_torrent($name);

for my $i (0 .. $#torrents) {
    next if !$torrents[$i]{size}  || $torrents[$i]{size} > 2048; # Don't download files over 2GB
    next if $torrents[$i]{title} !~ /$words_match/i;
    
    say "---------------------------------";
    say "Title: ". $torrents[$i]{title};
    say "Seeders: ". $torrents[$i]{seeds};
    say "Size: ". $torrents[$i]{size} . " MB";
    say '---------------------------------';
    
    
    $magnet = Getorr->get_magnet_link_leet($torrents[$i]{url});
    last if $magnet; # End loop if magnet link was returned
}


# Download using qbittorrent
Getorr->download_torrent_leet($magnet) unless $DEBUG;


