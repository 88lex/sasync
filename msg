#!/usr/bin/env bash

VER=3.3
case ${1,,} in
  start)
    printf '%.0s*' {1..80};echo
    echo -e "STARTING SASYNC $VER"
    printf '%.0s*' {1..80};echo ;;

  init_complete)
    echo -e "\nSASYNC STARTUP CONFIG COMPLETED" ;;

  no_files)
    echo -e "\nThere are no files found in your command line. CHECK YOUR COMMAND SYNTAX" ;;

  no_file)
    echo -e "\nThe file [ $file ] DOES NOT EXIST. CHECK YOUR FILES AND SASYNC COMMAND" ;;

  ck_rem)
    echo -e "\nBEGIN CHECK OF RCLONE REMOTES";printf '%.0s*' {1..60};echo
    echo -e "ACTION = $sync\nSOURCE = $src\nDEST   = $dest";printf '%.0s*' {1..60};echo ;;

  ck_fin)
    echo -e "\nCHECK OF RCLONE REMOTES COMPLETED FOR $src and $dest" ;;

  ok_cfg)
    echo -e "\nCHECKING         $2"
    echo -e "SUCCESS CONFIG   $2 EXISTS in rclone.conf file" ;;

  rc_bad)
    echo -e "\nCHECKING         $2"
    echo -e "FAILURE          $2 DOES NOT EXIST IN YOUR RCLONE CONFIG"|tee -a "$FAIL_LOG" ;;

  ok_td)
    echo -e "SUCCESS TD       $2 is a TEAM DRIVE" ;;

  not_td)
    echo -e "NOT A TD         $2 is NOT a TEAM DRIVE"
    echo -e "                 NOT FATAL BUT QUOTA FOR $2 MAY BE LIMITED" ;;

  ok_sa)
    echo -e "SUCCESS SA       $2 works correctly with SAs." ;;

  no_sa)
    echo -e "FAILURE SA       $2 config and SA permissions in $files"
    echo -e "                 NON-FATAL BUT QUOTA FOR $2 MAY BE LIMITED" ;;

  ok_read)
    echo -e "SUCCESS READ     $2" ;;

  ok_crypt)
    echo -e "REMOTE ENCRYPTED $2" ;;

  fail_read)
    echo -e "***\nFAILURE READ     $2 : CHECK PERMISSIONS and rclone config\n"|tee -a "$FAIL_LOG" ;;

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

  src_zero)
    (printf '%.0s*' {1..80};echo;printf '%.0s*' {1..80};echo ) | tee -a "$FAIL_LOG"
    echo -e "\nSOURCE $src is EMPTY, SIZE=0. CHECK REMOTE!\n" | tee -a "$FAIL_LOG"
    (printf '%.0s*' {1..80};echo;printf '%.0s*' {1..80};echo) | tee -a "$FAIL_LOG" ;;

  srcdest_ratio_bad)
    (printf '%.0s*' {1..80};echo;printf '%.0s*' {1..80};echo) | tee -a "$FAIL_LOG"
    echo -e "\nSOURCE $src is below $DIFF_LIMIT % src/dest ratio. CHECK REMOTE!\n" | tee -a "$FAIL_LOG"
    echo -e "\nDIFF_LIMIT = $DIFF_LIMIT %\nSRC/DEST ratio = $sd_ratio %\nsrcsize = $srcsize \ndestsize = $destsize"
    (printf '%.0s*' {1..80};echo;printf '%.0s*' {1..80};echo) | tee -a "$FAIL_LOG" ;;

  srcdest_ratio_ok)
    echo -e "\nDIFF_LIMIT = $DIFF_LIMIT %\nSRC/DEST ratio $sd_ratio % is OKAY\n" ;;

  diff_size)
    echo "SIZE is $srcsizeGB GB in SOURCE $src  ( $srcsize bytes )"
    echo "SIZE is $destsizeGB GB in DEST $dest  ( $destsize bytes )"
    echo "DIFF is $diffGB GB  ( $diff bytes )"
    [[ $SRC_LIMIT ]] && echo -e "DAILY SRC transfer limit is $SRC_LIMIT GB"
    [[ $diff != 0 ]] && echo -e "EST NUM OF SAs is $SAs \n" #Max Transfer per SA is $maxt"
    : ;;

  dedupe)
    echo -e "STARTING DEDUPE of identical files from $2\n" ;;

  perm_del)
      echo -e "PERMANENTLY DELETING TRASH and EMPTY DIRECTORIES from $2\n" ;;

  start_par)
      echo -e "Starting max $n parallel instances of tmux" ;;

  fin_par)
      echo -e "Finished parallel instances of tmux" ;;

  run_rc)
    eval echo -e "BEGIN $sync of $src to $dest from $files. SA= $COUNT/$MAXJS.json"$notif_key
    echo -e "FLAGS= $FLAGS\nset_flags= $set_flags\ncmd_flags= $cmd_flags\n"
    echo -e "Max SAs for this set = $SAs ( = MAXJS if no size calculated )\n" ;;

  sa_js)
    echo -e "$COUNT.json added to config for $2" ;;

  fin_rc)
    echo
    eval echo -e "FINISHED $sync of $src TO $dest from $files. Last SA = $COUNT.json"$notif_key ;;

  complete)
    echo -e "\nSASYNC COMPLETED FOR SET FILE $files. NOW EXITING\n"
    if [[ -s "$FAIL_LOG" ]];then
      echo -e "CRITICAL ERRORS LISTED BELOW\nFile = "$FAIL_LOG"\n"
      cat "$FAIL_LOG";echo;echo
    fi ;;

  *)
    echo !! MISSING MESSAGE!! You forgot to add a message for this command $0 $1 $2!! ;;

esac | eval tee "$notif_all"
