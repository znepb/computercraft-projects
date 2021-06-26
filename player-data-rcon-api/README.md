# Player Data RCON Api

Some cool REST api that sucks. It crashes sometimes, lol.

## Setup

Create three scoreboards:

```
/scoreboard objectives add leaveGame minecraft.custom:minecraft.leave_game
/scoreboard objectives add leaveGame minecraft.custom:minecraft.play_one_minute
/scoreboard objectives add leaveGame deathCount
```

If people have already joined your server, you'll need to sync your scoreboards with your stat files.  
Now everything will work except last seen. You'll need to set that up with a command computer

## Last Seen

Just wget the `lastSeenServer.lua` into a command computer, and name is startup.lua. That's pretty much it.

## Problems?

If you have problems, please make an issue. I might fix it.