#!/usr/bin/env bash

case ${1,,} in
  start)
    echo -e "\nSTARTING SASYNC v2.2 with $set_file\n" ;;

  conf_ok)
    echo -e "\nSASYNC CONFIG AND INIT COMPLETED" ;;

  ck_rem)
    echo -e "\nBEGIN CHECK OF RCLONE REMOTES FOR $src and $dest\n" ;;

  ck_fin)
    echo -e "\nRCLONE REMOTE CHECK COMPLETED FOR $src and $dest" ;;

  rc_bad)
    echo -e "***\nFAILURE: CHECK the rclone config for remote = $2\n***"|tee -a $FAIL_LOG ;;

  ok_td)
    echo -e "SUCCESS-TD: REMOTE $2 is a TEAM DRIVE" ;;

  not_td)
    echo -e "FAILURE-TD: REMOTE $2 is NOT a TEAM DRIVE" ;;

  ok_sa)
    echo -e "SUCCESS-SA: REMOTE $2 works correctly with SAs." ;;

  no_sa)
    echo -e "FAILURE-SA: CHECK $2 config and SA permissions in $set_file" ;;

  fail_rem)
    echo -e "***\nFAILURE-REMOTE: CHECK PERMISSIONS and rclone config for $2 in $set_file"|tee -a $FAIL_LOG ;;

  skip2next)
    echo -e "SKIPPING TO NEXT SRC-DEST PAIR. SOURCE $src = DEST $dest." ;;

  ck_size)
    echo -e "\nCHECKING SIZE of $src and $dest BE PATIENT" ;;

  diff_size)
    echo -e "$srcsizeGB GB = $srcsize bytes = SIZE of SOURCE $src"
    echo -e "$destsizeGB GB = $destsize bytes = SIZE of DEST $dest"
    echo -e "DIFF is $srcdestdiffGB GB = $srcdestdiff bytes"
    echo -e "EST NUM OF SAs is $SAs with Max Transfer = $maxt\n" ;;

  dedupe)
    echo -e "STARTING DEDUPE of identical files from $2\n" ;;

  perm_del)
      echo -e "PERMANENTLY DELETING TRASH and EMPTY DIRECTORIES from $2\n" ;;

  run_rc)
    echo -e "\nBEGIN $sync of $src to $dest w $COUNT/$MAXJS.json from $set_file\n"
    echo -e "FLAGS=$FLAGS\nset_flags=$set_flags\nTIMEOUT=$TMOUT\n";sleep 0.3s ;;

  fin_sync)
    echo -e "\nFINISHED $sync FROM $src TO $dest" ;;

  complete)
    echo -e "\nSASYNC COMPLETED FOR SET FILE $set_file. NOW EXITING\n"
    cat $FAIL_LOG ;;

  *)
    echo !! MISSING MESSAGE Yo! You forgot to add a message for this command $0 $1 $2!! ;;

esac
