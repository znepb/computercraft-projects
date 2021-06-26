local function getPlayers()
  local words = {}
  local success, resp, count = commands.exec("list")

  local players = string.gsub(resp[1], "There are %d- tracked entities: ", "")

  for w in (players .. ", "):gmatch("([^, ]*), ") do
    if w:match("^#") == nil then
      table.insert(words, w)
    end
  end

  return words
end

local function getPlaytimeTicks(player)
  local success, resp, count = commands.scoreboard('players', 'get', player, "playtime")

  return count
end

local function isOnline(player)
  local ticks = getPlaytimeTicks(player)
  sleep(0.1)
  local newticks = getPlaytimeTicks(player)
  return ticks ~= newticks
end

parallel.waitForAny(function()
  while true do
    local now = os.epoch("utc")

    for i, v in pairs(getPlayers()) do
      if isOnline(v) then
        local ok, ret = commands.scoreboard('players', 'set', v, "lastOnline", math.floor(now / 1000))

        for i, v in pairs(ret) do
          print(v)
        end
      end
    end

    sleep(10)
  end
end, function()
  while true do
    redstone.setOutput("top", true)
    sleep(1)
    redstone.setOutput("top", false)
    sleep(1)
  end
end)
