local token = "Place Discord Bot Token Here"
local channel = "Place Discord Channel ID Here"

local base = "https://discord.com/api/"

print("Connecting...")
local resp, err = http.get(base .. "gateway/bot", {
  ["Authorization"] = "Bot " .. token
})

local heartbeatInterval
local sequence

if resp then
  local data = textutils.unserialiseJSON(resp.readAll())
  local url = data.url

  local ws, err = http.websocket(url)
  if ws then
    print("Connected to " .. url)
    parallel.waitForAll(function()
      while true do
        local event, wsUrl, rawContents = os.pullEvent()
        if url == wsUrl and event == "websocket_message" and rawContents then
          if contents.s then
            sequence = contents.s
          end

          if contents.op == 10 then
            heartbeatInterval = contents.d["heartbeat_interval"]
            print("Got heartbeat interval: " .. heartbeatInterval)

            ws.send(textutils.serialiseJSON({
              ["op"] = 2,
              ["d"] = {
                ["token"] = token,
                ["intents"] = 512,
                ["properties"] = {
                  ["$os"] = "linux",
                  ["$browser"] = "Minecraft Server Bridge",
                  ["$device"] = "Minecraft Server Bridge"
                }
              }
            }))
          elseif contents.op == 0 then
            if contents.t == "MESSAGE_CREATE" or contents.t == "MESSAGE_UPDATE" then
              local d = contents.d
              print(d.author.bot)
              if d.channel_id == channel and d.author.bot == nil then
                commands.tellraw("@a", {
                  {
                    text = "[",
                    color = "dark_gray"
                  },
                  {
                    text = "D",
                    color = "blue"
                  },
                  {
                    text = "]",
                    color = "dark_gray"
                  },
                  {
                    text = " <",
                    color = "white"
                  },
                  {
                    text = contents.d.author.username,
                    color = "white",
                    hoverEvent = {
                      action = "show_text",
                      contents = {contents.d.author.username .. "#" .. contents.d.author.discriminator}
                    }
                  },
                  {
                    text = "> " .. contents.d.content,
                    color = "white"
                  }
                })
                end
              end
            end
          end
        elseif event == "websocket_closed" then
          error("Websocket closed: " .. rawContents)
        end
      end
    end, function()
      while true do
        print("Beat")
        if heartbeatInterval then
          print(heartbeatInterval / 1000)
          if heartbeatInterval then
            ws.send(textutils.serialiseJSON(
              {op = 1, d = sequence}
            ))
          end
          sleep(heartbeatInterval / 1000)
        else
          sleep(1)
        end
      end
    end)

  else
    error("No websocket gotten: " .. err)
  end

  resp.close()
else
  resp.close()
  error("Could not connect: " .. err)
end
