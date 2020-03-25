#!/usr/bin/env bash
# Written by visorask and 88lex :-)  Input from randyjc ;-)
# Usage: ./sarotate2 set.remotes  <= set.remotes is a text file with remote names, no ':'

REMOTES=`cat $1`    # REMOTES taken from the set.remotes file.
#REMOTES="$@"       # OR Use "$@" below if you prefer to specify remotes in the command line
MINJS=1             # First json file number in your JSON directory.
MAXJS=12            # Max json file number you wish to use in your JSON directory.
JSONDIR=/opt/sa     # Location of DIR with SA .json files.
SLEEPTIME=5s        # Sleep time before switching SA .json files.
COUNT=$MINJS        # COUNT needs to be initialized.

while :
do
  echo SA Rotate is running.
  for remote in $REMOTES;do
    rclone config update $remote: service_account_file $JSONDIR/$COUNT.json
    #systemctl restart teamdrive@"$remote".service
    COUNT=$(( $COUNT>=$MAXJS?MINJS:$COUNT+1 ))
  done
  echo SA rotate is now going to sleep for $SLEEPTIME
  sleep $SLEEPTIME
done
