# checkforsystemidle
Simple script, intended as cron script on linux, to check conditions indicating that the system is idle (and e.g. powerdown)

If you have a linux machine that is sometimes on to perform backups, but you want it to shut down automatically if it's not in use anymore, this might be useful for you.
There are a few tools with similar goals, see for example this article:

> https://www.ostechnix.com/auto-shutdown-reboot-suspend-hibernate-linux-system-specific-time/

However, none of these were directly usable for my requirements on what "system idle" exactly means and most of them are written as daemons/long-running processes for a task that shouldn't really require that.

So here are my requirements so you can decide if it matches yours. Also see the code as it is really very simple.
System is idle if:

* There has been no activity for some time, according to the X Window system.
* There are no locks on file accessed via Samba/CIFS.
* There are no more than the default number of user sessions still logged in, according to `last`.
* The users logged in according to `w` have been idle for some time.

See the variables in the script to adapt it to your situation.

If you are using a cron daemon, e.g. systemd-cron, you can have it run every two minutes by adding the following to your root's crontab (edit the crontab by running `crontab -e` / `crontab-systemd -e`, adapt the path as needed):

  ```
  */2 * * * * /root/bin/checkforsystemidle.sh
  ```

Also note that this generates output on every run, so you would have to pipe that to null if you want to avoid log entries for successful runs.

--strank

<eot>
