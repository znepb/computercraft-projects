--[[
  Elevator runner for Create, Advanced Peripherals and, of course, CC.
  Demo video: https://youtu.be/Wwx5LPin9-g
--]]

-- Config

local down = 6 -- Integrator ID for the down button
local up = 7 -- Integrator ID for the up button
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
  set(floors[floor].outerDoor, redstone)
  set(floors[floor].innerDoors[1], redstone)
  set(floors[floor].innerDoors[2], redstone)
end

local level = 0

local function setTargetFloor(n)
  print("moving to floor", n)
  if n == 0 or n == #floors + 1 then return end
  if n == level then return end
  setDoors(level, false)
  print("doors closed", n)

  redstone.setOutput(shiftSide, n > level)
  redstone.setOutput(clutchSide, false)
  print("moving")
  level = n

  repeat sleep() until get(floors[n].level) == true
  redstone.setOutput(clutchSide, true)
  setDoors(level, true)
  print("at floor, doors opened")
end

for i, v in pairs(floors) do
  if get(v.level) == true then
    level = i
  end
end

if level == 0 then error("Elevator is stuck. Please manually move it down.") end
print("Registered current floor as", level)

local ok, err = pcall(function()
  while true do
    for i, v in pairs(floors) do
      if get(v.call, "front") == true then
        print("elevator called to", i)
        setTargetFloor(i)
      end
    end

    if get(down) == true then
      print("going down")
      setTargetFloor(level - 1)
    elseif get(up) == true then
      print("going up")
      setTargetFloor(level + 1)
    end

    sleep()
  end
end)

if not ok then
  print(ok, err)
  redstone.setOutput(clutchSide, true)
  redstone.setOutput(shiftSide, false)

  for i, v in pairs(floors) do
    set(v.level, false)
    set(v.innerDoors[1], false)
    set(v.innerDoors[2], false)
    set(v.outerDoor, false)
  end
end