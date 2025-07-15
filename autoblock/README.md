# Problem: Your IP gets auto blocked

Apparently there is a glitch that may cause you to be blocked, even if you type in the correct password.

If you have SSH access, you can reset the blocklist like this:

```
sudo sqlite3 /etc/synoautoblock.db
```

and inside the SQL prompt:

```
select * from AutoBlockIP;
delete from AutoBlockIP where IP = 'blocked ip'
```

After this you can login again and fix the settings under 

Control Panel -> Security -> Protection