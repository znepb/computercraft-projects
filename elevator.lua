--[[
  ~~~ The elevator program has been updated, check out elevator-v2.lua! ~~~
  Elevator runner for Create, Advanced Peripherals and, of course, CC.
  Demo video: https://youtu.be/Wwx5LPin9-g
--]]

-- Config

local down = 24 -- Integrator ID for the down button
local up = 23 -- Integrator ID for the up button
local shiftSide = "left" -- Side of computer with gearshift redstone
local clutchSide = "back" -- Side of computer with clutch redstone

local floors = {
  {
    level = 1, -- Level detector integrator
    innerDoors = {2, 3}, -- The two redstone integraters that control the inside doors of the elevator
    outerDoor = 4, -- The integrator that controls the outside doors
    call = 5 -- The integrator that detects when a floor button is pressed
  }
}

-- Program

local function get(id, side)
  if not side then side = "top" end

  return peripheral.call("redstoneIntegrator_" .. tostring(id), "getInput", side)
end

local function set(id, value, side)
  if not side then side = "top" end

  return peripheral.call("redstoneIntegrator_" .. tostring(id), "setOutput", side, value)
end

local function setDoors(floor, redstone)
  set(floor.outerDoor, redstone)
  set(floor.innerDoors[1], redstone)
  set(floor.innerDoors[2], redstone)
end

local moving = false
local level = 1

local calling

local ok, err = pcall(function()
  while true do
    local found = false
    for i, v in pairs(floors) do
      if get(v.level) == true then
        level = i
        found = true

        if calling == nil then
          redstone.setOutput(clutchSide, true)
        end

        break
      end
    end

    moving = not found
    if calling == nil then setDoors(floors[level], not moving) end

    if calling then
      print(level, calling)
      if level == calling then

        redstone.setOutput(clutchSide, true)
        calling = nil
      end
    else
      if get(up) and level ~= #floors then
        setDoors(floors[level], false)
        redstone.setOutput(clutchSide, false)
        redstone.setOutput(shiftSide, true)
        sleep(1)
      end

      if get(down) and level ~= 1 then
        setDoors(floors[level], false)
        redstone.setOutput(clutchSide, false)
        redstone.setOutput(shiftSide, false)
        sleep(1)
      end
    end

    if not moving and calling == nil then
      for i, v in pairs(floors) do
        if get(v.call, "front") == true and i ~= level then
          if level > i then
            calling = i
            setDoors(floors[level], false)
            redstone.setOutput(clutchSide, false)
            redstone.setOutput(shiftSide, false)
            sleep(1)
          else
            calling = i
            setDoors(floors[level], false)
            redstone.setOutput(clutchSide, false)
            redstone.setOutput(shiftSide, true)
            sleep(1)
          end
        end
      end
    end
  end
end)

if not ok then
  redstone.setOutput(clutchSide, true)
  redstone.setOutput(shiftSide, false)

  for i, v in pairs(floors) do
    set(v.level, false)
    set(v.innerDoors[1], false)
    set(v.innerDoors[2], false)
    set(v.outerDoor, false)
  end
end
