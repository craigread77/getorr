#!/usr/bin/perl
use v5.18;
use strict;
use warnings;

use lib 'lib';
use Getorr;

# Get name of movie
my $name = $ARGV[0];


# TODO pull html to get magnet link
Getorr->fetch_leet_torrent($name);



# TODO download torrent using qbt
