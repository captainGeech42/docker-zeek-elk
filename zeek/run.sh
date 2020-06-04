#!/bin/bash

# https://www.howtogeek.com/405468/how-to-perform-a-task-when-a-new-file-is-added-to-a-directory-in-linux/

function log() {
    echo "$(date -Iseconds) $1"
}

INDIR=$HOME/pcaps_to_process
OUTDIR=$HOME/finished_pcaps
LOGDIR=/zeek_logs

inotify -m -e create -e moved_to --format "%f" $INDIR/ | while read FILENAME; do
    log "Got a new PCAP: $FILENAME"

    # make sure PCAP doesn't get double processed
    mv "$INDIR/$FILENAME" "$OUTDIR/$FILENAME"
    
    # run Zeek
    # unfortunately Zeek will overwrite log files instead of appending, so
    # we need to do this in a temp dir and then copy it into the filebeat
    # watch directory
    tmpdir=$(mktemp -d)
    cd $tmpdir
    zeek -C -r "$OUTDIR/$FILENAME" /usr/local/zeek/share/zeek/site/local.zeek
    log "Zeek finished processing PCAP"

    # copy logs
    mkdir "$LOGDIR/$FILENAME"
    for log in $(ls); do
        cat $log >> "$LOGDIR/$FILENAME/$log"
    done

    log "Logs transferred to $LOGDIR/$FILENAME/$log"

    # clean up
    cd
    rm -rf $tmpdir
done