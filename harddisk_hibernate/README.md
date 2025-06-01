# Problem: Harddisk(s) never spin down

While hibernation of harddisks are said to be a bad strategy and cause more wear and tear than leaving them idle, constantly accessing them might also be a bad idea.

Here is a bit about investigating what is using your disks, so you might limit this, whether you want to enable hibernation or not.

If your Synology runs a lot of services, it's probably not gonna be easy to make the disks idle/hibernate. Many servies are constantly doing something or other with the disks.

If you still want to give it a go, read on to find typical culprits that keeps the disks spinning. And find out further down, how you might discover what else keeps your disks spinning.

## Causes that keeps the disks running

* You are browing a SMB share from Windows
  * Close that explorer window or navigate away
* You have a file open on an SMB share
  * Close the file
* Surveillance Station continously updates its database file: @appstore/SurveillanceStation/system.db-shm
  * Uninstall Surveillance Station if you don't use it. I didn't so didn't try other solutions
* Download Station's emule client updates its statistics file: @appconf/DownloadStation/amule/statistics.dat
  * Disable Emule capability, when you don't need it.
* Download Station's torrent client opens some library (`.so`) files at least once every hour.
  * Did not find a remedy to eliminate this. Tried
     * Disable automatic loading of .torrent and .nzb files from a folder
     * Emptying download and share list
* Active Insight keeps other files busy. Learned about it [on reddit](https://www.reddit.com/r/synology/comments/1i89w76/why_is_my_synology_nas_frequently_spinning_up/)
  * Remove Active Insight 
* Some SMBXFERDB file is constantly being modified
  * Disable logging under File Servies -> SMB

## Finding more causes

I was not able to find anything interesting in the original logs. So I installed the `inotify-tools` package and created and ran this script:

`/usr/local/bin/log_disk_activity.sh`
```
#!/bin/sh

LOGDIR="/var/log/hibernation"
DATE=$(date +%Y-%m-%d)
LOGFILE="$LOGDIR/access_$DATE.log"
ERRORLOG="$LOGDIR/error_$DATE.log"

mkdir -p "$LOGDIR"

# Use full path to inotifywait
/usr/local/bin/inotifywait -m -r \
  --timefmt '%F %T' \
  --format '%T %w%f %e' \
  -e open -e attrib -e modify -e create -e delete \
  /volume1 >> "$LOGFILE" 2>> "$ERRORLOG"
```

After appropriately setting it as executable, I ran it 

```
chmod +x /usr/local/bin/log_disk_activity.sh
nohup /usr/local/bin/log_disk_activity.sh &
```

Then discovered an error and increased the `max_user_watches` accordingly, after which the script could be run again.



```
tail /var/log/hibernation/error_2025-05-31.log

Setting up watches.  Beware: since -r was given, this may take a while!
Failed to watch /volume1; upper limit on inotify watches reached!
Please increase the amount of inotify watches allowed per user via /proc/sys/fs/inotify/max_user_watches'.
```
```
sudo echo 524288 > /proc/sys/fs/inotify/max_user_watches
nohup /usr/local/bin/log_disk_activity.sh &
```

You can then monitor the file `/var/log/hibernation/access_$DATE.log`, to see what accesses the disk.

Once you are done, stop the monitoring again with 

```
pkill inotifywait
```