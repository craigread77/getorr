package Getorr;
use v5.18;
use strict;
use warnings;
use WWW::Mechanize;
use WWW::Mechanize::TreeBuilder;

sub fetch_tpb_torrent {
    my $self = shift;
    my $name = shift;  
    my $url_name = $name =~ s/\s+/\+/gr; # Replace spaces with '+'
    my $url = "https://www.pirate-bay.net/search?q=$url_name?q=$url_name";
    my $mech = WWW::Mechanize->new();
    WWW::Mechanize::TreeBuilder->meta->apply($mech);
    
    $mech->get( $url );
    return $mech->text();
}

sub fetch_leet_torrent {
    my $self = shift;
    my $name = shift;
    my $url_name = $name =~ s/\s+/%20/gr; # Replace spaces with '%20'
    my $url = "https://www.1377x.to/search/$url_name/1/";
    my $mech = WWW::Mechanize->new();
    my %torrents;
    
    WWW::Mechanize::TreeBuilder->meta->apply($mech);
    
    $mech->get( $url );
    # Get info from torrent table
    
    my @rows = $mech->look_down(
        #class => 'coll-1 name'
        _tag => 'tr'
    );
    
    for (@rows) {
        my $data = $_->as_XML();
        $data =~ /(\/torrent\/\d+\/\S+\/)"/;
        my $url = 'https://www.1377x.to' . $1;
        
        # Need to update this to go based on individual tags
        $data =~ /\/torrent\/\d+\/(\S+)\/".+<td class="coll-2 seeds">(\d+)<\/td><td class="coll-3 leeches">(\d+)<\/td>.+<td class="coll-4 size mob-uploader">(.+)<span/;
        my ($title, $seeders, $leechers, $size) = ($1, $2, $3, $4);
        
        say "URL: " . $url;
        say "Title: " . $title;
        say "Seeders: " . $seeders;
        say "Leechers: " . $leechers;
        say "Size: " . $size;
    
    }
    
    
    
    
}

sub fetch_rarbg_torrent {
    my $self = shift;
    my $name = shift;
    my $url_name = $name =~ s/\s+/\+/gr; # Replace spaces with '+'
    my $url = "http://rarbg.to/torrents.php?search=$name";
}
    


1;