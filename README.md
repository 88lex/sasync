NEW VERSION OF SASYNC, 2.0
I have not edited the README below to reflect the changes. Will do shortly    

You must use the new config file for the new script to work.    

Main changes are:    
SACALC is no longer used. rclone is run on a loop for each pair in a set file until finished (using exit codes).    
SWEEPER is gone.    
SASYNC-DEST is gone.    
I'm using a script to check if source and destination are TDs, MDs, shared folders or local. This then determines if SAs are used
for the source and adjusts flags accordingly.    
If `--disable move,copy` is used then `--max-transfer` is set to 1TB , which allows a graceful exit of rclone and also uses the full quota
for an SA (750GB).    

There are a few other changes but these are the big ones.    

This is a develop version. Needs to be stress tested. Comments/input welcome. Readme will be updated ... soon.

*******************************************
*******************************************
OLD README BELOW
*******************************************
*******************************************

WHEN YOU UPGRADE TO THIS VERSION YOU SHOULD DO A CLEAN INSTALL AND CAREFULLY CHECK YOUR CONFIG FILE.    
EXCLUDE files have been replace by FILTER files. Be sure to transfer your `exclude` list to your new `filter` file.


**sasync** -- This script uses rclone with service accounts to sync, copy or move files between rclone remotes. 
Further information and tools can be found  at https://github.com/88lex/sa-guide

**Usage**:  `./sasync set.video` Enable execution of sasync with `chmod +x sasync` each time you update. The default location for set files is a subfolder called `sasets`    

**NEW**: Changed `--exclude-from` to `--filter-from` in sasync.conf. Allows more flexibility in excluding/including file and folder types to match your use-case. 
There is a very good description with examples in the rclone wiki https://rclone.org/filtering/#filter-from-read-filtering-patterns-from-a-file    
**NEW**: (May not be needed w just released rclone versions!) Added `sweeper` which will pick up files that cannot copy server-side. Turn on (TRUE) or off (FALSE) in sasync.conf    
**NEW**: Added a filter.sweep file with fewer exclusions for the sweeper run. You can change this to `+ *.filetype` if you want only certain files in sweeper.    

**IMPORTANT**:   
==>  If this is your first time running sasync then copy `sasync.conf.default` to `sasync.conf`. If you are updating sasync then double check
`sasync.conf.default` to see if there are any new settings.   
==>  Check each line in the sasync.conf file, especially the directory (`DIR`) locations. sasync will not run correctly if it cannot find sets, jsons or filters .    
==>  The default set file folder is `/opt/sasync/sasets`. If you want to put set files in another folder be sure to change sasync.conf SET_DIR    
==>  sasync will NOT create base folders. e.g. If you specify `remote:movies` in a set file, you must create the `movies` folder in `remote:` before syncing.    
==>  Versions of rclone from 1.48 require a new flag `--drive-server-side-across-configs` in order to do server-side sync/copy. This flag has been
added to sasync as a default. If you are running an older version of rclone or wish to not execute server-side copies simply delete the flag from sasync.conf.  

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
1. **`sasync`** is the main script that pulls sync sets from 'set' files and runs rclone sync/copy/move.
2. **`sasync.conf.default`** contains major variables and rclone global flags.
3. **`sacalc`** estimates the number of service accounts required to sync/copy the gap between source and destination.
4. **`clean_tds`** deletes exact dupes, removes empty directories and permanently deletes trash. By default for DESTINATION only, 
but can be set to clean SOURCE as well.
5. **`json.count`** is an external counter for the json set. This allows running multiple instances of sasync that pull in 
sequence from the jsons without wasting or duplicating usage.
6. Two sample set files with rclone source, destination and max-transfer size. **`set.tv.sample`** and **`set.movies.sample`**
7. **`filter and filter.sweep`** contain file patterns to include or exclude from sasync. You may customize the filters in many ways to suit your
own needs / use case.
8. **`utils` folder** contains a few misc scripts. `readsets` will check if your set.* files are readable by sasync. `cleansets` will 
replace tabs and unreadable characters in your set.* files. Syntax is `./cleansets set.video`.
9. **`install_sasync`** will automate some installation tasks for you. It is intended for use during initial install, but can be used with subsequent installs.
10. Put your actual set files in the `sasets` folder. If you put them in a different folder be sure to change the SET_DIR in sasync.conf

The set.* files specify which sync pairs you would like to run along with rclone flags for that sync pair. The format would be as follows:
<pre>
# set.video
#0synccopymove  1source         2destination     3maxtransfer  4rcloneflags
sync            td_video:       my_video:        350G          --dry-run
copy            td_video_4k:    my_video_4k:     350G          --dry-run --no-traverse
#end-of-file
</pre>

Script syntax would be `./sasync set.video` which runs rclone sync for each source-dest pair, in a loop for number of SAs.

Each sync set can have an unlimited number of sync pairs. If you prefer to create smaller/separate sets then you can create set.* files
for each subset. e.g. set.tv, set.movies, set.books etc.

If you have multiple sets then you can run them in sequence with "./sasync set.tv set.movies set.books" or in parallel with
"./sasync set.tv & ./sasync set.movies &" .


Resource usage for this script is very light as the copy/move actions are all executed server side. That said, the script can be modified to use the
--disable move,copy flag if you prefer, in which case I/O and CPU usage would rise.

