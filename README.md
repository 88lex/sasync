# **sasync**

**IMPORTANT**: If this is your first time running sasync then rename `sasync.conf.default` to `sasync.conf`. If you are updating sasync then check for new 
flags and add/edit as needed into your existing `sasync.conf`.   

**Usage**:  `./sasync set.tv`  The default location for set files is a subfolder called `sa-sets`    

**Note1:** Check the sasync.conf file to ensure default file/folder locations are correct.
**Note2:** Recent betas of rclone require a new flag `--drive-server-side-across-configs` in order to do server-side sync/copy. This flag has been
added to sasync as a default. If you are running an older version of rclone or wish to not execute server-side copies simply
delete the flag from sasync.  
**Note3:** To generate logs run `./sasync set.tv | tee -a sasync.log` or for timestamped log run `./sasync set.tv | tee sasync$(date +%Y%m%d-%H%M).log`

**This script uses rclone with service accounts to sync, copy or move files between rclone remotes.**  
**Further information and tools can be found  at https://github.com/88lex/sa-guide**

**The new version of sasync:**

1. The config file is now **`sasync.conf.default`** in order to not overwrite your existing `sasync.config`. Check `sasync.conf.default` for new flags that you may need.
2. **Auto calc how many SAs required**: Calculates the size of the SOURCE and DESTINATION for each pair in the set.* file, then estimates the number 
of SAs required based on the --max-transfer setting. If you wish to set the number of SAs manually, put a # before sacalc and unhash the `SAs=` line. 
Moved the sacalc function to an external file.
3. **Flexible unlimited rclone flags in the set files**: Allows adding multiple rclone flags to each/all pairs in the set.* file. Flags which conflict with 
default flags in the sasync script will override the defaults. Note that you can still add/change flags in the script if you want them to apply to all set.
4. **MOVED ALL VARIABLES AND FLAGS TO A NEW CONFIG FILE - `sasync.conf`**:   Set global variables within the sasync.conf file including addding/changing
as many global rclone flags as you like.
5. **rClone config check**: Checks if each SOURCE and DESTINATION in your set.* file are accessible. If not then sasync exits to let you fix it.
Typically this is a typo or remote auth issue.
6. **NEW FORMAT AND LOCATION (`sa-sets`) FOR SET FILES**: Allows the user to sync, copy or move for any SOURCE DESTINATION pair (first column of set.* file). 
Requires changing your set.* files if you were running a previous version of sasync 
7. **Skips identical source-dest pairs**: Skips a sync pair if source and destination are exactly equal in size, then moves on to the next sync pair.
8. **Very basic set file format check**: If there are too few items in any set.* line then the script aborts with an error.

**There are several files in the repo at the moment.**
1. **`sasync`** is the main script that pulls sync sets from 'set' files and runs rclone sync/copy/move.
2. **`sasync.conf`** contains major variables and rclone global flags.
3. **`sacalc`** estimates the number of service accounts required to sync/copy the gap between source and destination.
4. **`clean_tds`** deletes exact dupes, removes empty directories and permanently deletes trash. By default for DESTINATION only, but can be set to clean SOURCE as well.
5. **`json.count`** is an external counter for the json set. This allows running multiple instances of sasync that pull in sequence from the jsons without wasting or duplicating usage.
6. Two sample set files with rclone source, destination and max-transfer size. **`set.tv.sample`** and **`set.movies.sample`**
7. **`exclude.txt`** contains file patterns to exclude from sasync. At the moment these are files that sometimes hang rclone service side copying, so we skip them. 
Typically it is only a handful of files. Until this gets fixed you will need to do an occasional 'sweep' sync/copy using the --disable move,copy flag which copies without hanging.


The set.* files specify which sync pairs you would like to run along with rclone flags for that sync pair. The format would be as follows:
<pre>
# set.tv
#0synccopymove  1source    2destination  3maxtransfer  4rcloneflags
sync            td_tv:     my_tv:        350G          --dry-run
copy            td_tv_4k:  my_tv_4k:     350G          --dry-run --no-traverse
</pre>

Run the script with this syntax "./sasync set.tv" to cycle rclone sync for each source-destination pair and each block of SAs in your set.* file.

Each sync set can have an unlimited number of sync pairs.

If you prefer to create smaller/separate sets then you can create set.* files for each subset. e.g. set.tv, set.movies, set.books etc.

If you have multiple sets then you can run them in sequence with "./sasync set.tv set.movies set.books" or in parallel with "./sasync set.tv & ./sasync set.movies &" .

Script syntax would be `./sasync set.tv` which runs rclone sync for each source-dest pair, in a loop for number of SAs.

Each sync set can have from 1 to an unlimited number of sync pairs. Or if you prefer to create smaller/separate sets like tv, movies, 4k, 
ebooks/audiobooks, etc. then you can create individual set.* files for each subset.

If you have multiple sets then you can run them in sequence with `./sasync set.tv set.movies set.books`
Or you can run them in parallel with `./sasync set.tv & ./sasync set.movies`

Resource usage for this script is very light as the copy/move actions are all executed server side. That said, the script can be modified to use the --disable move,copy flag if you prefer, in which case I/O and CPU usage would rise.

This script runs on any system with bash >4.x (before which the readarray command did not exist). The current version of bash is 5.x. On MacOS you will need to install a newer version of bash, which is easy enough.
