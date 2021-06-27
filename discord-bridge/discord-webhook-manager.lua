local wsURL = "Place Webhook Here"

local last = {}
local lastCount = 0

local function exec(content, username)
  http.post({ url = wsURL, headers = { ["Content-Type"] = "application/json" }, body = textutils.serialiseJSON({
    content = content,
    username = username or "Server",
    ["avatar_url"] = "https://www.mc-heads.net/head/" .. (username or "MHF_Exclamation")
  })})
end

exec(":white_check_mark: Server online!")

parallel.waitForAll(function()
  while true do
    local ok, out, count = commands.exec("list")
    out = out[1]:gsub("There are %d- of a max of %d- players online: ", "")

    local found = {}

    for w in out:gmatch('([^, ]+)') do
      found[w] = true
    end

    local left, joined

    if count ~= lastCount then
      for i, v in pairs(found) do
        if not last[i] then
          joined = i
          break
        end
      end

      for i, v in pairs(last) do
        if not found[i] then
          left = i
          break
        end
      end
    end

    print("joined", joined, "left", left)

    lastCount = count
    last = found
    sleep(1)

    if joined then
      exec(":inbox_tray: " .. joined .. " joined the game.")
    end

    if left then
      exec(":outbox_tray: " .. left .. " left the game.")
    end
  end
end, function()
  while true do
    local _, username, message = os.pullEvent("chat")
    exec(message, username)
  end
end)