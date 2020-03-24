#!/usr/bin/perl
use v5.18;
use strict;
use warnings;
use utf8;

use lib 'lib';
use Getorr;

my $DEBUG; # Set to 1 to disable downloads
# TODO - Add option to show top 10 results and allow the user to choose (good for stuff like sequels)

# Arguments
my $name = join(' ', @ARGV) or die "Usage: get_torrent.pl <Name of Movie>";
#my $torrsite = $ARGV[1] // 'tpb';
my $torrsite = 'tpb';


# $torrsite =~ /(?:tpb|leet|rarbg)/i or die "Invalid torrent provider: ". $ARGV[1]. "\nUsage: get_torrent.pl <\"Name of Movie\"> <tpb | leet | rarbg> (default is tpb)";
my $name_alt = $name =~ s/\s/\./r;
my $re = qr/$name|$name_alt/i;
my $magnet;

sub fetch_tpb {
    my @torrents = Getorr->get_tpb_torrent($name);
    
    for my $i (0 .. $#torrents) {
        next if !$torrents[$i]{size}  || $torrents[$i]{size} > 2048 || $torrents[$i]{size} < 300; # Don't download files over 2GB or under 300MB
        next if $torrents[$i]{title} !~ $re; # Match all parts of title in order!
        next if $torrents[$i]{seeds} < 2;
        
        say "------------TPB------------------";
        say "---------------------------------";
        say "Title  : ". $torrents[$i]{title};
        say "Seeders: ". $torrents[$i]{seeds};
        say "Size   : ". $torrents[$i]{size} . " MB";
        say "---------------------------------\n";
        
        return $torrents[$i]{magnet};
    }
    
    die "No matches found for '$name' on '$torrsite'";
}

sub fetch_leet {
    # Returns list of torrent hashesfrom 1337x.to
    # keys are (url, title, size, seeders)
    #my @torrents = Getorr->get_leet_torrent($name);
    #
    #for my $i (0 .. $#torrents) {
    #    next if !$torrents[$i]{size}  || $torrents[$i]{size} > 2048; # Don't download files over 2GB
    #    next if $torrents[$i]{title} !~ $re;
    #    
    #    say "---------------------------------";
    #    say "Title: ". $torrents[$i]{title};
    #    say "Seeders: ". $torrents[$i]{seeds};
    #    say "Size: ". $torrents[$i]{size} . " MB";
    #    say '---------------------------------';
    #
    #
    #    $magnet = Getorr->get_magnet_link_leet($torrents[$i]{url});
    #    last if $magnet; # End loop if magnet link was returned
    #}
    die "1337x Disabled. Use TPB";
}

sub fetch_rarbg {
    die "RARBG not yet implemented. Use TPB";
}


# Download using qbittorrent

if ($torrsite eq 'rarbg') {
    Getorr->download_torrent(fetch_rarbg()) unless $DEBUG;
}
elsif ($torrsite eq 'leet') {
    Getorr->download_torrent(fetch_leet()) unless $DEBUG;
}
else {
    Getorr->download_torrent(fetch_tpb()) unless $DEBUG;
}
    




