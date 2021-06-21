#! /bin/bash

PREFIX=`date +%Y/%m/%d/`
skip=0
while true; do
    if [ -d $PREFIX$skip ]; then
        skip=$((skip+1));
    else
        break;
    fi
done

echo $PREFIX$skip
mkdir -p $PREFIX$skip

# Need to do a mathematically linked hash sequence. We'll need a seed.
head -n1 /dev/random | sha256sum > $PREFIX$skip/token_initiator.txt

# Now that we have the seed, let's take a first image
ffmpeg -f video4linux2 -s 1920x1080 -i /dev/video0 -frames 1 $PREFIX$skip/0.jpeg || touch $PREFIX$skip/0.jpeg
# and hash it
sha256sum $PREFIX$skip/0.jpeg > 0-hash.md
ps ax > $PREFIX$skip/0-psax.md
date | sha256sum > $PREFIX$skip/0-TS.md
sha256sum $PREFIX$skip/0.jpeg > $PREFIX$skip/0-hash-pic.md
# Let's take a screenshot too.
gnome-screenshot --file $PREFIX$skip/0-screen.jpeg
# and hashit
sha256sum $PREFIX$skip/0-screen.jpeg > $PREFIX$skip/0-hash-screen.md
# finally let's cat everything and hash it for the sequence-start.
cat $PREFIX$skip/token_initiator.txt $PREFIX$skip/0-hash-screen.md $PREFIX$skip/0-hash-pic.md | sha256sum > $PREFIX$skip/token_0.txt 


i=1
while true; do
    mkdir -p `date +%Y/%m/%d/`    
    
    # Now that we have the seed, let's take a first image
    ffmpeg -f video4linux2 -s 1920x1080 -i /dev/video0 -frames 1 $PREFIX$skip/$i.jpeg || touch $PREFIX$skip/0.jpeg
    # and hash it
    sha256sum $PREFIX$skip/$i.jpeg > $PREFIX$skip/$i-hash.md
    ps ax > $PREFIX$skip/$i-psax.md
    date | sha256sum > $PREFIX$skip/$i-TS.md
    sha256sum $PREFIX$skip/$i.jpeg > $PREFIX$skip/$i-hash-pic.md
    # Let's take a screenshot too.
    gnome-screenshot --file $PREFIX$skip/$i-screen.jpeg
    # and hashit
    sha256sum $PREFIX$skip/$i-screen.jpeg > $PREFIX$skip/$i-hash-screen.md
    # finally let's cat everything w/ prev token and hash it for the sequence.
    cat $PREFIX$skip/token_$((i-1)).txt $PREFIX$skip/$i-hash-screen.md $PREFIX$skip/$i-hash-pic.md | sha256sum > $PREFIX$skip/token_$i.txt 


    i=$((i+1));
    if [ $i%10 == 0 ]; then
        sync;
    fi
    sleep 240
done;
