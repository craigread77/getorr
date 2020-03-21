package Getorr;
use v5.18;
use strict;
use warnings;
use utf8;
use WWW::Mechanize;
use WWW::Mechanize::TreeBuilder;

sub convert_mb {
    my $size = $_[0];
    $size // return undef;
    
    if ($size =~ /MB/n) {
        $size =~ s/ MB//;
        return $size;
    }
    elsif ($size =~ / GB/n) {
        $size =~ s/ GB//;
        return int($size * 1024);
    }
    
    elsif ($size =~ /GiB/n) {
        $size =~ s/GiB//;
        return int($size * 1024);
    }
    
    else {
        $size =~ s/MiB//;
        return $size;
    }
    
    
    
    
}

sub get_tpb_torrent {
    my $self = shift;
    my $name = shift;  
    my $url_name = $name =~ s/\s+/\%20/gr; # Replace spaces with '+'
    my $url = "https://thepiratebay.zone/search/$url_name/1/99/0";
    say "Executing get_tpb_torrent...";
    say "Search URL: $url\n\n";

    # Array of hashes (keys are title, size, seeds, magnet)
    my @torrents;

    my $mech = WWW::Mechanize->new();
    WWW::Mechanize::TreeBuilder->meta->apply($mech);
    
    $mech->get( $url );
    
    # Get all magnet links
    my $count = 0;
    for (@{ $mech->extract_links('a') }) {
        my ($link) = @$_;
        if ( $link =~ /^(?:magnet)/ ) {
            $torrents[$count]{magnet} = $link;
            $count++;
        }
    }
    
    $count = 0;
    for my $title ( $mech->look_down( class => 'detLink' ) ) {
        $torrents[$count]{title} = $title->as_text();
        $count++;
    }
    
    $count = 0;
    for my $size ( $mech->look_down( class => 'detDesc' ) ) {
        $size = $size->as_text() =~ s/[^a-zA-Z0-9 .]//gr;
        if ($size =~ /Size (\d+\.\d+)(GiB|MiB)/) {
            $size = convert_mb($1 . $2);
            $torrents[$count]{size} = $size;
            $count++;
        }   
    }
    
    # Seeds and leechers come through together, so we alternate through the array.
    # Even indexes are Seed values
    $count = 0;
    my $subcount = 0;
    for my $seed ( $mech->look_down("align", "right") ) {
        $seed = $seed->as_text();
        if ($subcount % 2 == 0) {
            $torrents[$count]{seeds} = $seed;
            $count++;
        }    
        
        $subcount++;     
    }
    
    return @torrents;
 
}

sub get_leet_torrent {
    my $self = shift;
    my $name = shift;
    my $url_name = $name =~ s/\s+/%20/gr; # Replace spaces with '%20'
    my $url = "https://www.1377x.to/search/$url_name/1/";
    my $mech = WWW::Mechanize->new();
    my @torrents;
    my $torrent_url;
    my $title;
    my $count = 0;
    
    
    WWW::Mechanize::TreeBuilder->meta->apply($mech);
    
    $mech->get( $url );
    
    # Get info from torrent table
    my @rows      =  $mech->look_down( class   => 'coll-1 name' );
    my @seeders   =  $mech->look_down( class   => 'coll-2 seeds' );
    my @sizes_alt =  $mech->look_down( class   => 'coll-4 size mob-uploader'); # Some titles use a different class for file size
    my @sizes     =  $mech->look_down( class   => 'coll-4 size mob-vip' );
    
    # Skip first line (headers)
    for (splice(@rows, 1)) {
        my $data = $_->as_XML();
        if ($data =~ m{(/torrent/\d+/.+/)">(.+)</a>}s) {
            $torrent_url = $1;
            $title = $2;
        } else {
            warn "No match!: $!";
        }
        
        $torrents[$count]{url} = 'https://1337x.to' . $torrent_url;
        $torrents[$count]{title} = $title;
        
        $count++
    }
    
    $count = 0;
    
    for (@seeders) {
        my $seeds = $_->as_text();
        $torrents[$count]{seeds} = $seeds;
        $count++;
    }
    
    $count = 0;
    
    push(@sizes, @sizes_alt); 
    for (@sizes) {
        my $size = $_->as_XML();
        if ($size =~ m{(\d+\.\d+ GB)|(\d+\.\d+ MB)|(\d,\d+\.\d+ MB)}s) {
            $size = convert_mb($1);
            $size =~ s/"//g if $size;
        }
        
        $torrents[$count]{size} = $size;
        $count++;
      
    }
    
    return @torrents;
    
}

sub get_rarbg_torrent {
    my $self = shift;
    my $name = shift;
    my $url_name = $name =~ s/\s+/\+/gr; # Replace spaces with '+'
    my $url = "http://rarbg.to/torrents.php?search=$name";
}

sub get_magnet_link_leet {
    my $self = shift;
    my $url = shift;
    my $mech = WWW::Mechanize->new();
    WWW::Mechanize::TreeBuilder->meta->apply($mech);
    my $magnet;
    my @links;
    
    $mech->get( $url );
    
    @links = $mech->look_down(
        class => 'l8e38fe43402620d7ba3be520d79ebba7c45382ce l7cd3af1a2fc1ad3785dcbd482bc889ca0e47f69d l3e5e5898ac3e4f296d17506223739c9666af7cb1');
    
    # Try alternative magnet class
    if (! $links[0]) {
        @links = $mech->look_down(
            class => 'lf5cab25abeea2db047987e779843b6bb1c0aa307 l642d2dc206fb87702b09284b24d4f5a1919a84d3 lf134dbe95e3f85ce836b190e341297de8a86d431');
    }
    
    if ($links[0]->as_XML() =~ m{href="(.+)" onclick}s) {
        $magnet = $1;
    } else { return undef };
    
    return $magnet;
}

sub download_torrent {
    my $self = shift;
    my $magnet = shift;
    
    my $script = 'qbt torrent add url "' . $magnet . '"';
    `$script` // say "FAILED!";
}
    


1;