--[[
  A simple soda dispenser program using Pam's Harvestcraft and CC.
--]]

local dropper = "minecraft:dropper_5" -- Side of the dropper

local sodas = {
  {
    name = "Cherry",
    slot = 1,
    color = "red",
    text = "white"
  },
  {
    name = "Cola",
    slot = 2,
    color = "brown",
    text = "white"
  },
  {
    name = "Ginger",
    slot = 3,
    color = "brown",
    text = "white"
  },
  {
    name = "Grapefruit",
    slot = 4,
    color = "orange",
    text = "white"
  },
  {
    name = "Grape",
    slot = 5,
    color = "purple",
    text = "white"
  },
  {
    name = "Lemon-Lime",
    slot = 6,
    color = "lime",
    text = "white"
  },
  {
    name = "Orange",
    slot = 7,
    color = "orange",
    text = "white"
  },
  {
    name = "Rootbeer",
    slot = 8,
    color = "brown",
    text = "white"
  },
  {
    name = "Strawberry",
    slot = 9,
    color = "pink",
    text = "white"
  }
}

local m = peripheral.find("monitor")
local chest = peripheral.find("minecraft:chest")

local w, h = m.getSize()

local function centerWrite(text)
  local width, height = m.getSize() -- Get terminal size
  local x, y = m.getCursorPos() -- Get current cursor position
  m.setCursorPos(math.ceil((width / 2) - (text:len() / 2)), y)
  m.write(text)
end

local function drawScreen(n)
  local s = sodas[n]
  m.setTextScale(0.5)
  m.setBackgroundColor(colors[s.color])
  m.setTextColor(colors[s.text])
  m.clear()

  m.setCursorPos(1, h / 2)
  centerWrite(s.name)

  m.setCursorPos(1, h / 2)
  m.write("\17")
  m.setCursorPos(w, h / 2)
  m.write("\16")

  m.setBackgroundColor(colors.white)

  m.setCursorPos(1, h)
  m.clearLine()

  if chest.getItemDetail(s.slot) == nil then
    m.setTextColor(colors.lightGray)
    centerWrite("Out of Stock")
  else
    m.setTextColor(colors.black)
    centerWrite("Dispense")
  end
end

local screen = 1
drawScreen(screen)

while true do
  local e, s, x, y = os.pullEvent("monitor_touch")

  local width, height = m.getSize()
  print(y, height)
  if y == height then
    print(chest.getItemDetail(sodas[screen].slot))
    if chest.getItemDetail(sodas[screen].slot) ~= nil then
      print("ok")
      m.setCursorPos(2, h)
      m.setBackgroundColor(colors.white)
      m.clearLine()
      m.setTextColor(colors.gray)
      m.write("Dispensing...")

      chest.pushItems(dropper, sodas[screen].slot, 1)
      redstone.setOutput("bottom", true)
      sleep(0.5)
      redstone.setOutput("bottom", false)
    end
  elseif x == 1 then
    if screen == 1 then
      screen = #sodas
    else
      screen = screen - 1
    end
  elseif x == width then
    if screen == #sodas then
      screen = 1
    else
      screen = screen + 1
    end
  end

  drawScreen(screen)
end
