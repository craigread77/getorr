package Jackett;
use v5.18;
use strict;
use warnings;
use utf8;

use XML::LibXML;

sub get_torrents {
    my ( $self, $url ) = @_;
    my %torrenthash;
    my $dom = XML::LibXML->load_xml(
        location => $url,
    );
    
    my @items = $dom->getElementsByTagName('item');
    
    for (@items) {
        my $title = $_->getElementsByTagName('title');
        my $size = $_->getElementsByTagName('size');
        my $magnet = $_->getElementsByTagName('link') if qr(magnet);
        say "---------------------------------------";
        say "Size: " . int($size) / 1000000 . " MB";
        say "Title: " . $title;
        say "Magnet: " . $magnet;
        
        my @attribs = $_->getElementsByTagName('torznab:attr');
        
        
    }
    
}




1;