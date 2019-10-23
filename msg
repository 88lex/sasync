#!/usr/bin/env bash

case ${1,,} in
  start)
    echo -e "\nSTARTING SASYNC v2.3 \nSET FILE= $set_file\n" ;;

  conf_ok)
    echo -e "\nSASYNC CONFIG AND INIT COMPLETED" ;;

  ck_rem)
    echo -e "\nBEGIN CHECK OF RCLONE REMOTES \nSOURCE = $src\nDEST =   $dest\n" ;;

  ck_fin)
    echo -e "\nRCLONE REMOTE CHECK COMPLETED FOR $src and $dest" ;;

  ok_cfg)
    echo -e "SUCCESS CONFIG   $2 EXISTS in rclone.conf file" ;;

  rc_bad)
    echo -e "***\nFAILURE     $2 DOES NOT EXIST IN YOUR RCLONE CONFIG\n***"|tee -a $FAIL_LOG ;;

  ok_td)
    echo -e "SUCCESS TD       $2 is a TEAM DRIVE" ;;

  not_td_src)
    echo -e "SRC NOT TD       $2 is NOT a TEAM DRIVE\n***NON-FATAL BUT QUOTA FOR SOURCE $2 MAY BE LIMITED" ;;

  not_td_dest)
    echo -e "DEST NOT TD      $2 is NOT a TEAM DRIVE"
    echo -e "***\nFATAL ERROR. CANNOT USE SAs/SASYNC IF DESTINATION IS NOT A TD\n***" ;;

  ok_sa)
    echo -e "SUCCESS SA       $2 works correctly with SAs." ;;

  no_sa_src)
    echo -e "FAILURE SA       $2 config and SA permissions in $set_file"
    echo -e "***NON-FATAL BUT QUOTA FOR SOURCE $2 MAY BE LIMITED"  ;;

  no_sa_dest)
    echo -e "FAILURE SA       $2 config and SA permissions in $set_file"
    echo -e "***\nFATAL ERROR. CANNOT USE SAs/SASYNC IF DEST $2 DOES NOT HAVE SA PERMISSIONS\n***" ;;

  ok_read)
    echo -e "SUCCESS READ     $2" ;;

  fail_read)
    echo -e "***\nFAILURE READ     $2 : CHECK PERMISSIONS and rclone config"|tee -a $FAIL_LOG ;;

  ok_write)
    echo -e "SUCCESS WRITE    $2" ;;

  fail_write)
    echo -e "FAILURE WRITE    $2" ;;

  ok_del)
    echo -e "SUCCESS DELETE   $2" ;;

  fail_del)
    echo -e "FAILURE DELETE   $2" ;;

  skip2next)
    echo -e "SKIPPING TO NEXT SRC-DEST PAIR. SOURCE $src = DEST $dest." ;;

  file_cmp)
    echo -e "\nComparing files in $src and $dest\n" ;;

  ck_size)
    echo -e "\nCHECKING SIZE of $src and $dest BE PATIENT" ;;

  diff_size)
    echo "SIZE is $srcsizeGB GB in SOURCE $src  ( $srcsize bytes )"
    echo "SIZE is $destsizeGB GB in DEST $dest  ( $destsize bytes )"
    echo "DIFF is $diffGB GB  ( $diff bytes )"
    [[ $SRC_LIMIT ]] && echo -e "DAILY SRC transfer limit is $SRC_LIMIT GB"
    [[ $diff != 0 ]] && echo -e "EST NUM OF SAs is $SAs \nMax Transfer per SA is $maxt"
    : ;;

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
