--[[
  Simple world scanner. Deposits to a map.nft file.
  Must be run on a command PC!
--]]

local blockColors = {
  ["minecraft:stone"] = "lightGray",
  ["minecraft:stone_bricks"] = "gray",
  ["minecraft:water"] = "blue",
  ["computercraft:computer_command"] = "orange",
  ["minecraft:grass_block"] = "green",
  ["minecraft:dirt"] = "brown",
  ["quark:orange_blossom_leaves"] = "orange",
  ["minecraft:spruce_log"] = "brown",
  ["quark:lit_lamp"] = "yellow",
  ["minecraft:gray_concrete"] = "gray",
  ["minecraft:bricks"] = "red",
  ["minecraft:grass"] = "lime",
  ["minecraft:dandelion"] = "yellow",
  ["minecraft:poppy"] = "red",
  ["minecraft:oxeye_daisy"] = "lightGray",
  ["minecraft:azure_bluet"] = "lightGray",
  ["minecraft:cornflower"] = "blue",
  ["minecraft:crimson_trapdoor"] = "purple",
  ["minecraft:sandstone"] = "yellow",
  ["minecraft:lantern"] = "orange",
  ["minecraft:mangenta_carpet"] = "magenta",
  ["minecraft:blue_carpet"] = "blue",
  ["minecraft:orange_carpet"] = "orange",
  ["minecraft:light_blue_carpet"] = "lightBlue",
  ["minecraft:pink_carpet"] = "pink",
  ["minecraft:lime_carpet"] = "lime",
  ["minecraft:cobblestone_slab"] = "lightGray",
  ["quark:red_shingles_slab"] = "red",
  ["cfm:light_gray_picket_fence"] = "lightGray",
  ["cfm:oak_upgraded_fence"] = "brown",
  ["computercraft:cable"] = "lightGray",
  ["computercraft:monitor_advanced"] = "yellow",
  ["minecraft:chain"] = "lightGray",
  ["create:shaft"] = "gray",
  ["create:vertical_gearbox"] = "brown",
  ["create:gearbox"] = "brown",
  ["minecraft:iron_bars"] = "lightGray",
  ["create:encased_chain_drive"] = "brown",
  ["create:belt"] = "black",
  ["create:cogwheel"] = "brown",
  ["create:large_cogwheel"] = "brown",
  ["create:creative_motor"] = "magenta",
  ["minecraft:lever"] = "lightGray",
  ["quark:permafrost_bricks_wall"] = "lightBlue",
  ["minecraft:yellow_concrete"] = "yellow",
  ["minecraft:red_concrete"] = "red",
  ["minecraft:blue_concrete"] = "blue",
  ["minecraft:sea_lantern"] = "lightBlue",
  ["minecraft:spruce_planks"] = "brown",
  ["create:encased_fan"] = "lightGray",
  ["cfm:trampoline"] = "gray",
  ["cfm:oak_table"] = "brown",
  ["cfm:oak_chair"] = "brown",
  ["minecraft:dark_oak_fence"] = "brown",
  ["cfm:oak_mail_box"] = "brown",
  ["minecraft:red_wool"] = "red",
  ["minecraft:black_concrete"] = "black",
  ["create:sticky_mechanical_piston"] = "lightGray",
  ["create:piston_extension_pole"] = "lightGray",
  ["minecraft:redstone_lamp"] = "brown",
  ["create:redstone_link"] = "brown",
  ["minecraft:warped_planks"] = "cyan",
  ["computercraft:computer_advanced"] = "yellow",
  ["minecraft:glowstone"] = "orange",
  ["minecraft:chest"] = "brown",
  ["create:fancy_andesite_bricks_wall"] = "lightGray",
  ["minecraft:oak_fence_gate"] = "brown",
  ["cfm:spruce_upgraded_fence"] = "brown",
  ["cfm:spruce_upgraded_gate"] = "brown",
  ["create:scoria_pillar"] = "black",
  ["minecraft:jungle_planks"] = "orange",
  ["create:gabbro_bricks"] = "lightGray",
  ["minecraft:jungle_stairs"] = "orange",
  ["computercraft:disk_drive"] = "lightGray",
  ["minecraft:furnace"] = "lightGray",
  ["create:clutch"] = "brown",
  ["minecraft:slime_block"] = "lime"
}

local colorIndex = {
  white = "0", orange = "1", magenta = "2", lightBlue = "3", yellow = "4", lime = "5",
  pink = "6", gray = "7", lightGray = "8", cyan = "9", purple = "a", blue = "b",
  brown = "c", green = "d", red = "e", black = "f"
}

for i, v in pairs(blockColors) do
  write(i)
  if colorIndex[v] then
    print("OK")
  else
    error("Invalid color, got " .. v)
  end
end

if peripheral.find("monitor") then peripheral.find("monitor").setTextScale(0.5) end

term.setBackgroundColor(colors.black)
term.setTextColor(colors.white)
term.clear()

local function scanCol(x, z)
  local blocks = commands.getBlockInfos(x, 0, z, x, 255, z)
  for i = #blocks, 1, -1 do
    if blocks[i].name ~= "minecraft:air" and blocks[i].name ~= "minecraft:glass" then
      return blocks[i].name
    end
  end
end

local image = ""

local size = 300

local currentBlock = 0
local area = size * size + (size * 2) - 1
local totalScanTime = 0

print("Ready to render", area, "blocks. This will take a bit!")

for r = -(size / 2), size / 2 do
  for c = -(size / 2), size / 2 do
    local block = scanCol(r, c)
    local color

    if blockColors[block] then
      color = colorIndex[blockColors[block]]
    else
      color = "0"
    end

    image = image .. color

    currentBlock = currentBlock + 1

    if c % 50 == 0 then
      print(c, r, currentBlock, currentBlock / area * 100)
    end
  end
  image = image .. "\n"

  local f = fs.open("map.nft", "w")
  f.write(image)
  f.close()

end

local f = fs.open("map.nft", "w")
f.write(image)
f.close()
