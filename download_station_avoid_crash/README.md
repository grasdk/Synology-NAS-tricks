# Problem: Download station crashes the whole NAS

Not entirely sure what the cause it, but the problem is reported various places.

Solution that has worked for me:

Increase the number of kilobytes that the kernel tries to keep free to avoid out-of-memory (OOM) conditions. In practice you do this:

Login via SSH or simlar and run the command 
```
sudo /sbin/sysctl -w vm.min_free_kbytes=131072
```

_(source of command: Synology Community Forums reply to [post 122508](https://community.synology.com/enu/forum/1/post/122508) by [SparkMaster](https://community.synology.com/enu/user/sparkmaster/profile) on 17th of May 2019)._

This command increases to a total of 128MB. When run as above the setting applies until next reboot.

## Current setting

To check the amount set BEFORE you change it (this is always good if you need to fall back to the original setting):

```
cat /proc/sys/vm/min_free_kbytes
```

## Persisting the change

If you find that this solution works for you, you can make it persist between reboots but adding a task to the task planner.

Create triggered task, user defined script:
- User: `root`
- Trigger/Event: `Start` or `Boot` (using local language settings, so unsure about the exact phrase used)
- Task settings -> User defined script: `/sbin/sysctl -w vm.min_free_kbytes=131072` (without sudo, it's already root that is running it).
