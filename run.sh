#!/bin/bash
if ps -C qbittorrent; then
    echo 'Running!';
else
    qbittorrent & disown;
fi;

cd ~/getorr;
perl get_torrent.pl $@;
