const Rcon = require("rcon-client").Rcon;
const express = require("express");
const path = require("path");
const fs = require("fs");

const app = express();
let rcon = null;

async function connect() {
  rcon = await Rcon.connect({
    host: "", port: 0, password: "" // Enter rcon host, port, and password here. Should be the only setup required here.
  })
}

connect();

/* Player Stats Rest API */

async function getPlayers() {
  let response = await rcon.send("scoreboard players list");
  response = response.replace(/There are \d+ tracked entities: /g, "").replace("\n", "");
  let items = response.split(/[ ,]+/);
  let out = [];

  for(let i in items) {
    let item = items[i];

    if(!item.startsWith("#")) {
      out.push(item);
    }
  }

  return out;
}

async function getOnlinePlayers() {
  let response = await rcon.send("list");
  response = response.replace(/There are \d+ of a max of \d+ players online: /g, "").replace("\n", "");
  let items = response.split(/[ ,]+/);
  let out = [];

  for(let i in items) {
    let item = items[i];

    if(!item.startsWith("#")) {
      out.push(item);
    }
  }

  return out;
}

app.get("/players", async (req, res) => {
  return res.json({
    ok: true,
    data: await getPlayers()
  });
})

app.get("/players/online", async (req, res) => {
  let onlinePlayers = await getOnlinePlayers();

  return res.json({
    ok: true,
    data: {
      count: onlinePlayers.length,
      list: onlinePlayers
    }
  });
})

app.get("/players/:name", async (req, res) => {
  if((await getPlayers()).some(player => player === req.params.name)) {

    let player = req.params.name;

    let leavesResp = await rcon.send(`/scoreboard players get ${player} leaveGame`);
    let deathsResp = await rcon.send(`/scoreboard players get ${player} deaths`);
    let timePlayed = await rcon.send(`/scoreboard players get ${player} playtime`);
    let lastSeen = await rcon.send(`/scoreboard players get ${player} lastOnline`);

    try {
      return res.json({
        ok: true,
        data: {
          leaves: leavesResp.match(/\d+/)[0] * 1,
          deaths: deathsResp.match(/\d+/)[0] * 1,
          ticksPlayed: timePlayed.match(/\d+/)[0] * 1,
          minutesPlayed: Math.floor(timePlayed.match(/\d+/) / (20 * 60)),
          lastSeen: lastSeen.match(/\d+/)[0] * 1,
          online: (await getOnlinePlayers()).some(player => player === req.params.name)
        }
      });
    } catch(e) {
      console.info(e);
    }
  } else {
    return res.json({
      ok: false,
      error: "Player does not exist."
    });
  }
})

app.listen(4321);