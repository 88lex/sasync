
### SASYNC 2.1
SASYNC uses rclone and Google Service Accounts (SAs) to sync, copy or move files between rclone remotes.

**Usage**:  `./sasync set.file [OPTION: --rclone-flags]`  

After downloading enable execution with `chmod +x sasync` each time you update.  

The default location for set files is a subfolder called `sasets`.

SASYNC reads from a set file. Each line in the set file describes 
- An action that rclone will execute (sync, copy or move)
- A source and destination remote folder
- A breakpoint (--max-transfer) which tells sasync to move to the next SA
- Any additional rclone flags which you would like to apply to individual source/destination pairs

<pre>
# set.test
#0action  1source            2destination    3maxtransfer   4rcloneflags
sync      teamdrive:docs     backup:docs     350G
copy      teamdrive:photos   backup:photos   350G           --transfers=8
#end-of-file
</pre>

[[ NOTE: sasync is designed to work with Google Drive as well as local drives as the source. It may work with other rclone remote types but has been tested mostly with gdrive. ]]

**Destination** 
- Must be a Team Drive (TD) or local drive
- Must work with Service Accounts (SA) 
- Must have read/write (RW) permission
- If any of the above not true then you are better off using rclone sync/copy directly.

**Source** 
- Must have read permission 
- Best case if the source is a TD
- Must have at least read permissions to SAs
- If all of the above are true then SAs will rotate with both source and destination, and sync/copy limits can be higher. Each SA has a 750GB upload/inbound quota and a 10TB download/outbound quota.
- If Source does not have SA read access then you need to consider your outbound quotas (e.g. 10 TB for GDrive, ? for others).

**Process:**  SASYNC goes through the following steps:
- The main function of sasync will run `rclone copy/sync/move` for each source-destination pair in your set file using a service account (SA) then move to the next SA until done.

  There are a number of optional features:

-  Check if each source and destination remote exists in the rclone.conf file and if they are Team Drives (now called Shared Drives)
- Check if each remote has read and service account permissions
- Clean Source and Destination remotes of duplicates and trash. Can be done before and/or after the sync
- Check if file count in Source and Destination are equal
  - If equal then skip to the next source-destination pair in the set file

- Check if total file size in Source and Destination are equal
  - If equal then skip to the next source-destination pair in the set file
  - If not equal then estimate number of SA's required
- Choose whether to EXIT or CONTINUE when there is a problem with any source-destination pair in a set file


---
**CHANGELOG**
You must use the new config file for the new script to work. Run `cp sasync.conf.default sasync.conf` and edit new config as needed    

THE MAIN CHANGES ARE:    
- sasync now allows rclone flag pass through. `sasync set1 --flag1 --flag2 --etc`  
   [[ To enable flag pass through multi-sets in the command line were removed (`sasync set1 set2` no longer works). ]]    
    
- SWEEPER is removed. No longer needed   

- SASYNC-DEST is gone as `sasync` should now handle destination-only SA copies correctly.     

- `rc_check` checks if the source and destination are TDs, MDs, shared folders or local. This then determines if SAs are used for the source and adjusts flags accordingly    

- You can now choose to exit or continue when source-destination remotes are bad

There are a few other changes but these are the big ones.    


**IMPORTANT**:   

- When upgrading you can overwrite local files/changes by running 

  `git fetch`  
  `git reset --hard origin/develop`  
  `cp sasync.conf.default sasync.conf`  
  `chmod +x sasync`  
  `./sasync set.p8`  
  Then edit sasync.conf 

- ==>  If this is your first time running sasync then copy `sasync.conf.default` to `sasync.conf`. If you are updating sasync then double check `sasync.conf.default` to see if there are any new settings.   

- Check each line in the sasync.conf file, especially the directory (`DIR`) locations. sasync will not run correctly if it cannot find sets, jsons or filters .    

- The default set file folder is `/opt/sasync/sasets`. If you want to put set files in another folder be sure to change sasync.conf SET_DIR    

- sasync will NOT create base folders. e.g. If you specify `remote:movies` in a set file, you must create the `movies` folder in `remote:` before syncing.    

- Versions of rclone from 1.48 require a new flag `--drive-server-side-across-configs` in order to do server-side sync/copy. This flag has been added to sasync as a default. If you are running an older version of rclone or wish to not execute server-side copies simply delete the flag from sasync.conf.  

**This version of sasync includes the following features:**

*  **sasync.conf file**:  Set global variables within the sasync.conf file including as many global rclone flags as you like.   
The `sasync.conf` file is backed up daily to a `./config_backup` folder and kept for 14 days (default, adjustable).    
**NOTE** The config file in the repo is called **`sasync.conf.default`** so you do not not overwrite an existing `sasync.config`.
You can copy via `cp sasync.conf.default sasync.conf`. If you keep your existing `sasync.conf` check carefully not to omit new flags.     

*  **Auto calc the number of SAs required**:  Calculates the size of the SOURCE and DESTINATION for each pair in the set.* file, then estimates the number 
of SAs required based on the --max-transfer setting. 

*  The default **filter** file excludes some system files. Open and customize it to suit your own needs.

*  **Flexible unlimited rclone flags in the set files**:  Add multiple rclone flags to each/all pairs in the set.* file. Flags in the set file will override
flags in the config file.

*  **rClone config check**:  Checks if each SOURCE and DESTINATION in your set.* file is accessible. If not then sasync exits to let you fix it.
Typically this is a typo or remote auth issue. 
**NOTE: sasync intentionally does not create missing folders, as rclone could accidentally create and copy to a local folder = DANGEROUS.**

*  **Log files**:  sasync creates two log files with each run. `stderr_set.name.log` and `stdout_set.name.log` and puts them in the `logs` folder

*  **Set files go by default in a sub folder called `sasets`**:  The new format requires changing the content of your set.* files if you were
running an older version of sasync.  The new set file has 5 columns vs 7 in older versions.

*  **Skips same-size source-dest pairs**:  Skips a sync pair if source and destination are exactly equal in size, then moves on to the next sync pair.

*  You may consider creating your own private repo called `sasets` in github/lab/bucket that contains your personal set files. 
Set files are easy to edit in github/gitlab and can be easily added to / updated to any machines running sasync.

**There are several files in the repo at the moment.**
- **`sasync`** is the main script that pulls sync sets from 'set' files and runs rclone sync/copy/move.
- **`sasync.conf.default`** contains major variables and rclone global flags.
- **`rc_check`** checks rclone remote status
- **`sacalc`** estimates the number of service accounts required to sync/copy the gap between source and destination.
- **`clean_tds`** deletes exact dupes, removes empty directories and permanently deletes trash. By default for DESTINATION only, 
but can be set to clean SOURCE as well.
- **`json.count`** is an external counter for the json set. This allows running multiple instances of sasync that pull in 
sequence from the jsons without wasting or duplicating usage.
- Two sample set files with rclone source, destination and max-transfer size. **`set.tv.sample`** and **`set.movies.sample`**
- **`filter`** contain file patterns to include or exclude from sasync. You may customize the filters in many ways to suit your own needs.
- `msg` contains messages called by the script
- **`utils` folder** contains a few misc scripts. `readsets` will check if your set.* files are readable by sasync. `cleansets` will 
replace tabs and unreadable characters in your set.* files. Syntax is `./cleansets set.video`.
- **`install_sasync`** will automate some installation tasks for you. It is intended for use during initial install, but can be used with subsequent installs.
- Put your actual set files in the `sasets` folder. If you put them in a different folder be sure to change the SET_DIR in sasync.conf

The set.* files specify which sync pairs you would like to run along with rclone flags for that sync pair. The format would be as follows (The # comment lines are entirely optional/unnecessary):
<pre>
# set.video
#0synccopymove  1source         2destination     3maxtransfer  4rcloneflags
sync            td_video:       my_video:        350G          --dry-run
copy            td_video_4k:    my_video_4k:     350G          --dry-run --no-traverse
#end-of-file
</pre>

Resource usage for this script is very light as the copy/move actions are all executed server side. That said, the script can be modified to use the
--disable move,copy flag if you prefer, in which case I/O and CPU usage would rise.

