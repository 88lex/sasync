# sasync

This script uses rclone with service accounts to copy large volumes of files between two rclone remotes.

There are 5 files in the repo at the moment.
1. sasync is the main script
2. json.count is an external counter for the json set. This allows running multiple instances of sasync that pull in sequence from the jsons without wasting or duplicating usage.
3. Two sample files with rclone source, destination, transfers, checkers, chunks, number of service accounts and max-transfer size.
4. An exclude.txt file with file patterns to exclude from rclone copy/sync. At the moment these are files that sometimes hang rclone service side copying, so we skip them. Typically it is only a handful of files. Until this gets fixed you will need to do an occasional 'sweep' sync/copy using the --disable move,copy flag which copies without hanging.

The set.* files specify which sync pairs you would like to run along with rclone flags for that sync pair. The format would be as follows:

```filename: set.tv
1source    2destination   3transfers 4checkers 5chunks     6SAs     7maxtransfer
td_tv:       my_tv:         20         20        16M         5        700G
td_tv_4k:    my_tv_4k:      4          20        16M         2        600G```

The script will ignore lines that begin with a hash '#'

An example script syntax would be "./sasync set.tv" which would run iterative rclone commands for each source-dest pair and each block of SAs.
Each sync set can have from 1 to unlimited number of sync pairs. One sync set could handle all sync pairs.
Or if you prefer to create smaller/separate sets like tv, movies, 4k, ebooks/audiobooks, whatever then you can create individual set.* files for each subset

If you have multiple sets then you can run them in sequence with "./sasync set.tv set.movies set.books"
Or you can run them in parallel with "./sasync set.tv & ./sasync set.movies"


Resource usage for this script is very light as the copy/move actions are all executed server side. That said, the script can be modified to use the --disable move,copy flag if you prefer, in which case I/O and CPU usage would rise.

RAM usage is typically light. The only flag that appears to increase RAM usage is --fast-list. You can delete the fast list flag and the script will run fine, but scans will take a bit longer.

There is a clean_tds option in the script to dedupe and remove empty directores from source or destination. If you don't need that feature simply insert a hash '#' before the clean_tds command.

This script runs on any system with bash >4.x (before which the readarray command did not exist). The current version of bash is 5.x. On MacOS you will need to install a newer version of bash, which is easy enough.
