### Introducing Monitor Witness

I know, not a very exciting name, I was lazy at the time and it wasn't something I planned on posting anywhere.  I recently threw it up on Github and letting other witnesses benefit from it.

Monitor Witness is build using completely free tools with no ongoing fees.  Unlike typical network monitoring, **Monitor Witness** will warn you *before* a problem happens potentially saving you days of downtime.

### How does it work?

Monitor WItness is a relatively simple bash shell script that monitors your witness log file looking for the last block processed, then compares against full nodes to determine if it is within 10 blocks.  If it is, it sends a heart beat, if it isn't, you get notified it is behind or even failed. 

First you need an account with HealthChecks, Uptime Robot, or your own Uptime Kuma instance.  Any service that provides ping/heatbeat type of monitors via url will work.

Healthchecks is basically a reverse notification.  Typically when you use notification services, you set a destination service for it to ping or monitor and alert you when it can't be reached.  With a healthcheck, you set up a URL that needs to be visited within a set amount of time, if it is not, then it starts to complain.  It's a dead man's switch, something you probably only heard of in movies.  This is an extremely handy tool for monitoring backup jobs, and other jobs that run and you want to make sure it completely properly but has no external IP to ping or monitor.

### Installation

#### Enable Logging

To use this, you need to have logging enabled.  The easiest way to do this is to use screen (i.e. screen -S witness -L -Logfile witness.log) so it can monitor the log file.   You can use tmux as well, but it much more diffcult to log with out of the box.

#### Setup Heartbeat monitors

Setup an account https://healthchecks.io.  Create one Health Check for each of your witness nodes.  I am going to assume through these instructions you are using healthchecks.io. 

![](https://i.imgur.com/qCRPufL.png)

I recommend using the name of the witness as the name and slug.   I recommend setting it to 1 minute checks with a 5 minute grace period.  This means, if you don't visit this url every minute, it will go into a failure state, but there is a grace period of 5 minutes before it starts sending alerts.  Customize this as you wish, but this is what I would recommend.

If you want to see the health check in action, visit the URL of one of your health checks in the browser and you will see it turn green immediately.  By default, your healthchecks will notify you by email, but you can customize it with almost every tool you can think of from discord, ntfy, pushover, slack, and even SMS.

Once you have created these, just leave the tab open, we will come back to this.  

#### Download Monitor Witness

You can download **Monitor Witness* from Github using `git clone  https://github.com/officiallymarky/monitorwitness`.

As always, review the code and make sure it doesn't do anything you don't approve of.  The code is very easy to read and extremely short.  Should only take a minute.

Make sure monitorwitness.sh is executable using `chmod +x monitorwitness.sh`.

Modify *monitorwitness.env* with your preferred settings and healthcheck URL from above.  The defaults are three popular full nodes with allowing a single failure and a 10 block tolerance.  This means if you are outside of 10 blocks on 2 out of 3 nodes, you will send a heatbeat preventing any notifications.  If you are outside of 10 blocks for 2 or more nodes, you will not send a heartbeat causing an alert.  

**The code will not run unless you add a healthcheck URL to the configuration file. **

I recommend installing this on all witness nodes, and setting a unique healthcheck URL for each node, idealy with a matching name on Healthchecks.  UptimeRobot supports this sort of monitoring as well, but you need a paid account.   Healthchecks.io allows you 20 free healthchecks.  You can also use UptimeKuma (my favorite) which is an open source clone of Uptime Robot you can host yourself, but is a lot more involved.  Healthchecks.io works really well, is free, and super fast to set up (under 15 seconds to be up and running!).

#### Schedule monitorwitness.sh

Once you have modified monitorwitness.env with your preferred settings, all that is left is to schedule it.

I recommend using cron, it is as easy as typing `crontab -e` to modify your cron schedule.

Add in the following entry with the correct path to monitorwitness.sh.  Cron requires exact paths and will not use short cuts like $HOME or ~.

`* * * * * /home/marky/monitorwitness.sh`

This entry will call this script every 1 minute.  This is what I recommend, and remember your healthcheck will only fail after 5 minutes of failures.   Google search **crontab examples** or **crontab generator** if you do not understand this.

#### Verify installation

After about 60 seconds, you should be able to see all your healthchecks.io on healthchecks.io are green and everything is running and notifying you.   You can do two things to verify everything is working properly.  You can pause your witness or you can just remove the crontab entry once it turns green and make sure you get notified.
