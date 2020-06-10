#!/bin/bash

# https://www.howtogeek.com/405468/how-to-perform-a-task-when-a-new-file-is-added-to-a-directory-in-linux/

function log() {
    echo "$(date -Iseconds) $1"
}

inotifywait -m -e create -e moved_to --format "%f" $ZEEK_INDIR/ | while read FILENAME; do
    log "Got a new PCAP: $FILENAME"

    # make sure PCAP doesn't get double processed
    mv "$ZEEK_INDIR/$FILENAME" "$ZEEK_OUTDIR/$FILENAME"
    
    # run Zeek
    # unfortunately Zeek will overwrite log files instead of appending, so
    # we need to do this in a temp dir and then copy it into the filebeat
    # watch directory
    tmpdir=$(mktemp -d)
    cd $tmpdir
    zeek -C -r "$ZEEK_OUTDIR/$FILENAME" /usr/local/zeek/share/zeek/site/local.zeek
    log "Zeek finished processing PCAP"

    # copy logs
    pcaplogdir="$ZEEK_LOGDIR/${FILENAME}_$(date +'%Y%m%d_%H%M%S')"
    mkdir "$pcaplogdir"
    for log in $(ls); do
        cat $log >> "$pcaplogdir/$log"
    done

    log "Logs transferred to $pcaplogdir"

    # clean up
    cd
    rm -rf $tmpdir
done