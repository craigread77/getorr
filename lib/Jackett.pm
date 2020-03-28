package Jackett;
use v5.18;
use strict;
use warnings;
use utf8;
use Data::Dumper;

use XML::LibXML;
use WWW::Mechanize;

sub get_torrents {
    my ( $self, $url, $magnet ) = @_;
    my @torrents;
    
    # Indexer has direct magnet links in XML
    if ($magnet) { 
        my $dom = XML::LibXML->load_xml(location => $url);
        
        for my $item ($dom->findnodes('//item')) {
            my $title = $item->findvalue('./title');
            my $size = int($item->findvalue('./size')) / 1000000;
            my $seeds;
            my $magnet;
            
            for ($item->findnodes('./torznab:attr')) {
                $seeds  = $_->{value} if $_->{name} eq "seeders";
                $magnet = $_->{value} if $_->{name} eq "magneturl";
            }
            
            push @torrents, {
                'title'  => $title,
                'size'   => $size,
                'seeds'  => $seeds,
                'magnet' => $magnet
                };
        }
        
        return @torrents;
    }
    
    # Get magnet from Jackett api link
    else {
        my $dom = XML::LibXML->load_xml(location => $url) or say "skipped $url" && return undef;
        
        for my $item ($dom->findnodes('//item')) {
            my $title = $item->findvalue('./title');
            my $size = int($item->findvalue('./size')) / 1000000;
            my $torrent_url = $item->findvalue('./link');
            my $seeds;
            my $magnet;
            
            
            for ($item->findnodes('./torznab:attr')) {
                $seeds  = $_->{value} if $_->{name} eq "seeders";
            }
            
            # Pull headers from link and grep magnet URL
            $magnet = `curl -si '$torrent_url' | grep -oP 'Location: \\K.*'`;
            
            push @torrents, {
                'title'  => $title,
                'size'   => $size,
                'seeds'  => $seeds,
                'magnet' => $magnet
                };
        }
        
        return @torrents;
    }
    
    
}

sub download_torrent {
    my ($self, $magnet) = @_;

    my $script = 'qbt torrent add url "' . $magnet . '"';
    `$script` // say "FAILED!";
    
}





1;