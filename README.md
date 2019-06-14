# **sasync**
**Usage:  `./sasync set.tv`**    
**Note1:** Before running sasync double check that line 2 in the script `JSON_FOLDER=/opt/sa` points to the correct location of your json files.    
**Note2:** To generate logs run `./sasync set.tv | tee -a sasync.log` or for timestamped log run `./sasync set.tv | tee sasync$(date +%y%m%d%h%m).log`

**This script uses rclone with service accounts to sync, copy or move files between rclone remotes.**

**The new version of sasync:**
1. Checks if each SOURCE and DESTINATION in your set.* file are accessible. If not then sasync exits to let you fix it. Typically this is a typo or remote auth issue.
2. Calculates the size of the SOURCE and DESTINATION for each pair in the set.* file, then estimates the number 
of SAs required based on the --max-transfer setting. If you wish to set the number of SAs manually, put a # before sacalc and unhash the `SAs=` line.
3. Allows the user to sync, copy or move for any SOURCE DESTINATION pair (first column of set.* file). 
4. Allows adding multiple rclone flags to each/all pairs in the set.* file. Flags which conflict with default flags in the sasync script will override the defaults.
5. Requires changing your set.* files if you were running a previous version of sasync 
6. Skips a sync pair if source and destination are exactly equal in size, then moves on to the next sync pair.
7. If there are too few items in any set.* line then the script aborts with an error.

**NOTE:** Recent betas of rclone require a new flag `--drive-server-side-across-configs` in order to do server-side sync/copy. This flag has been
added to this version of sasync as a default. If you are running an older version of rclone or wish to not execute server-side copies simply
delete the flag from sasync.

**There are several files in the repo at the moment.**
1. sasync is the main script that pulls sync sets from 'set' files and runs rclone sync/copy/move.
2. json.count is an external counter for the json set. This allows running multiple instances of sasync that pull in sequence from the jsons without wasting or duplicating usage.
3. Two sample set.* files with rclone source, destination and max-transfer size.
4. An exclude.txt file with file patterns to exclude from rclone copy/sync. At the moment these are files that sometimes hang rclone service side copying, so we skip them. Typically it is only a handful of files. Until this gets fixed you will need to do an occasional 'sweep' sync/copy using the --disable move,copy flag which copies without hanging.


The set.* files specify which sync pairs you would like to run along with rclone flags for that sync pair. The format would be as follows:
<pre>
# set.tv
#0synccopymove  1source    2destination  3maxtransfer  4rcloneflags
sync            td_tv:     my_tv:        350G          --dry-run
copy            td_tv_4k:  my_tv_4k:     350G          --dry-run --no-traverse
</pre>

The script will ignore lines that begin with a hash '#'

Script syntax would be `./sasync set.tv` which runs rclone sync for each source-dest pair, in a loop for number of SAs.

Each sync set can have from 1 to an unlimited number of sync pairs. Or if you prefer to create smaller/separate sets like tv, movies, 4k, ebooks/audiobooks, etc. then you can create individual set.* files for each subset.

If you have multiple sets then you can run them in sequence with `./sasync set.tv set.movies set.books`
Or you can run them in parallel with `./sasync set.tv & ./sasync set.movies`

Resource usage for this script is very light as the copy/move actions are all executed server side. That said, the script can be modified to use the --disable move,copy flag if you prefer, in which case I/O and CPU usage would rise.

There is a clean_tds option in the script to dedupe and remove empty directores from source or destination. If you don't need that feature simply insert a hash '#' before the clean_tds command.

This script runs on any system with bash >4.x (before which the readarray command did not exist). The current version of bash is 5.x. On MacOS you will need to install a newer version of bash, which is easy enough.
