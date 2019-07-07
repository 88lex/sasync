FOR THIS VERSION YOU MAY WANT TO DO A CLEAN INSTALL. THE 4-COLUMN SET FILES WILL STILL WORK, BUT IT IS WORTHWHILE TO COPY THE NEW SASYNC.CONF
FILE AND EDIT THE SETTINGS TO YOUR PREFERENCE.

**sasync** -- This script uses rclone with service accounts to sync, copy or move files between rclone remotes. 
Further information and tools can be found  at https://github.com/88lex/sa-guide

**Usage**:  `./sasync set.video` Enable execution of sasync with `chmod +x sasync` each time you update. The default location for set files is a subfolder called `sasets`    

**NEW**: Changed `--exclude-from` flag and file to `--filter-from` in sasync.conf. Allows more flexibility in excluding/including file and folder types.    
**NEW**: Added a filter.sweep file with fewer exclusions for the sweeper run. You can change this to `+ *.filetype` if you want only certain files in sweeper.
**NEW**: (May not be needed w just released rclone versions!) Added `sweeper` which will pick up files that cannot copy server-side. Turn on (TRUE) or off (FALSE) in sasync.conf

**IMPORTANT**:   
==>  If this is your first time running sasync then rename `sasync.conf.default` to `sasync.conf`. If you are updating sasync then check for new 
flags and add/edit as needed into your existing `sasync.conf`.   
==>  You need to create your own `sasets` folder and point sasync.conf to that folder. The default is `/opt/sasync/sasets`    
==>  sasync will NOT create base folders. e.g. If you specify remote:movies in a set, sasync will not create the `movies` folder in `remote:`.    
==>  Check in the sasync.conf file to point sasync to where your sasync script, set files and SA jsons are located.    
==>  Versions of rclone from 1.48 require a new flag `--drive-server-side-across-configs` in order to do server-side sync/copy. This flag has been
added to sasync as a default. If you are running an older version of rclone or wish to not execute server-side copies simply delete the flag from sasync.conf.  

**This version of sasync includes the following features:**

*  **sasync.conf file**:  Set global variables within the sasync.conf file including as many global rclone flags as you like.   
The `sasync.conf` file is backed up daily to a `./config_backup` folder and kept for 14 days (default, adjustable).    
**NOTE** The config file in the repo is called **`sasync.conf.default`** so you do not not overwrite an existing `sasync.config`.
You can copy via `cp sasync.conf.default sasync.conf` or edit your `sasync.conf` to add any new flags in the default file.     

*  **Auto calc the number of SAs required**:  Calculates the size of the SOURCE and DESTINATION for each pair in the set.* file, then estimates the number 
of SAs required based on the --max-transfer setting. 

*  **Flexible unlimited rclone flags in the set files**:  Add multiple rclone flags to each/all pairs in the set.* file. Flags in the set file will override
flags in the config file.

*  **rClone config check**:  Checks if each SOURCE and DESTINATION in your set.* file is accessible. If not then sasync exits to let you fix it.
Typically this is a typo or remote auth issue. 
**NOTE: sasync intentionally does not create missing folders, as rclone could accidentally create and copy to a local folder = DANGEROUS.**

*  **Log files**:  sasync creates two log files with each run. `stderr_set.name.log` and `stdout_set.name.log` and puts them in the `logs` folder

*  **Set files are in a sub folder called `sasets`**:  The new format requires changing your set.* files if you were running an older version of sasync 

*  **Skips same-size source-dest pairs**:  Skips a sync pair if source and destination are exactly equal in size, then moves on to the next sync pair.

**There are several files in the repo at the moment.**
1. **`sasync`** is the main script that pulls sync sets from 'set' files and runs rclone sync/copy/move.
2. **`sasync.conf.default`** contains major variables and rclone global flags.
3. **`sacalc`** estimates the number of service accounts required to sync/copy the gap between source and destination.
4. **`clean_tds`** deletes exact dupes, removes empty directories and permanently deletes trash. By default for DESTINATION only, 
but can be set to clean SOURCE as well.
5. **`json.count`** is an external counter for the json set. This allows running multiple instances of sasync that pull in 
sequence from the jsons without wasting or duplicating usage.
6. Two sample set files with rclone source, destination and max-transfer size. **`set.tv.sample`** and **`set.movies.sample`**
7. **`filter and filter.sweep`** contain file patterns to include or exclude from sasync. At the moment these are files that sometimes hang rclone 
service side copying, so we skip them. Typically it is only a handful of files.    
8. **`utils` folder** contains a few misc scripts. `readsets` will check if your set.* files are readable by sasync. `cleansets` will 
replace tabs and unreadable characters in your set.* files. Syntax is `./cleansets set.video`.
9. **`install_sasync`** will automate some installation tasks for you. It is intended for use during initial install, but can be used with subsequent installs.
10. The **`sasets`** folder has one sample set in it. This is the location that sasync looks in by default, so a good idea to put your custom sets here.
You may consider creating your own private repo called `sasets` in github/lab/bucket that contains your personal set files. 
Then it is quite easy to add your set files to a new machine while installing sasync.


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

