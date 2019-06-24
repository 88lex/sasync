**sasync** -- This script uses rclone with service accounts to sync, copy or move files between rclone remotes. 
Further information and tools can be found  at https://github.com/88lex/sa-guide

**Usage**:  `./sasync set.tv` Enable execution of sasync with `chmod +x sasync` each time you update. The default location for set files is a subfolder called `sasets`    

**IMPORTANT**:   
==>  If this is your first time running sasync then rename `sasync.conf.default` to `sasync.conf`. If you are updating sasync then check for new 
flags and add/edit as needed into your existing `sasync.conf`.   
==>  sasync will NOT create base folders. e.g. If you specify remote:movies in a set, sasync will not create the movies folder, but will create movies/myhomevideo.
==>  Check in the sasync.conf file to point sasync to where your sasync script, set files and SA jsons are located.    
==>  Versions of rclone from 1.48 require a new flag `--drive-server-side-across-configs` in order to do server-side sync/copy. This flag has been
added to sasync as a default. If you are running an older version of rclone or wish to not execute server-side copies simply delete the flag from sasync.  

**This version of sasync includes the following features:**


*  **sasync.conf file**:  Set global variables within the sasync.conf file including as many global rclone flags as you like.    
**NOTE** The config file in the repo is called **`sasync.conf.default`** in order to not overwrite your existing `sasync.config`.
Check `sasync.conf.default` for new flags that you may need rename to `sasync.conf` if you want to keep the defaults. `sasync.conf` files are backed up
daily and kept for 14 days (default, adjustable) in a config_backup folder.

*  **Auto calc the number of SAs required**:  Calculates the size of the SOURCE and DESTINATION for each pair in the set.* file, then estimates the number 
of SAs required based on the --max-transfer setting. If you wish to set the number of SAs manually, put a # before sacalc and unhash the `SAs=` line. 
Moved the sacalc function to an external file.

*  **Flexible unlimited rclone flags in the set files**:  Allows adding multiple rclone flags to each/all pairs in the set.* file. Flags which conflict with 
default flags in the sasync script will override the defaults. Note that you can still add/change flags in the script if you want them to apply to all set.

*  **rClone config check**:  Checks if each SOURCE and DESTINATION in your set.* file are accessible. If not then sasync exits to let you fix it.
Typically this is a typo or remote auth issue. 
**NOTE: sasync does not create missing folders, as rclone could accidentally create and copy to a local folder = DANGEROUS.**

*  **Log files**:  sasync creates two log files with each run. `stderr_set.name.log` and `stdout_set.name.log` and puts them in `logs` folder

*  **Set files are in a sub folder called `sasets`**:  The new format requires changing your set.* files if you were running an older version of sasync 

*  **Skips identical source-dest pairs**:  Skips a sync pair if source and destination are exactly equal in size, then moves on to the next sync pair.

**There are several files in the repo at the moment.**
1. **`sasync`** is the main script that pulls sync sets from 'set' files and runs rclone sync/copy/move.
2. **`sasync.conf`** contains major variables and rclone global flags.
3. **`sacalc`** estimates the number of service accounts required to sync/copy the gap between source and destination.
4. **`clean_tds`** deletes exact dupes, removes empty directories and permanently deletes trash. By default for DESTINATION only, 
but can be set to clean SOURCE as well.
5. **`json.count`** is an external counter for the json set. This allows running multiple instances of sasync that pull in 
sequence from the jsons without wasting or duplicating usage.
6. Two sample set files with rclone source, destination and max-transfer size. **`set.tv.sample`** and **`set.movies.sample`**
7. **`exclude.txt`** contains file patterns to exclude from sasync. At the moment these are files that sometimes hang rclone 
service side copying, so we skip them. Typically it is only a handful of files. Until this gets fixed you will need to do an 
occasional 'sweep' sync/copy using the --disable move,copy flag which copies without hanging.


The set.* files specify which sync pairs you would like to run along with rclone flags for that sync pair. The format would be as follows:
<pre>
# set.tv
#0synccopymove  1source         2destination     3maxtransfer  4rcloneflags
sync            td_video:       my_video:        350G          --dry-run
copy            td_video_4k:    my_video_4k:     350G          --dry-run --no-traverse
</pre>

Script syntax would be `./sasync set.tv` which runs rclone sync for each source-dest pair, in a loop for number of SAs.

Each sync set can have an unlimited number of sync pairs. If you prefer to create smaller/separate sets then you can create set.* files
for each subset. e.g. set.tv, set.movies, set.books etc.

If you have multiple sets then you can run them in sequence with "./sasync set.tv set.movies set.books" or in parallel with
"./sasync set.tv & ./sasync set.movies &" .


Resource usage for this script is very light as the copy/move actions are all executed server side. That said, the script can be modified to use the
--disable move,copy flag if you prefer, in which case I/O and CPU usage would rise.

This script runs on any system with bash >4.x (before which the readarray command did not exist). The current version of bash is 5.x. On MacOS you
will need to install a newer version of bash, which is easy enough.
