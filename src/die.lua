--[[
   This program is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see http://www.gnu.org/licenses/.
]]--

local Die = {}

-- Roll a 20-sided die against a target value.
-- The roll has to be at least the target value for success.
-- A larger target is harder to beat, smaller targets favor the player.
-- A larger target also yields smaller roll values on success.
-- There is always a 1 in 20 chance of critical failure.
-- Returns a table { value=[1..5], success=[true/false], critical=[true/false] }.
function Die:roll(target)

  target = math.min(20, target)
  local roll = math.random(20)

  if roll == 1 then
    return {
      ["value"] = -1,
      ["success"] = false,
      ["critical"] = true
    }
  end

  local diff = roll - target

  -- failure
  if diff < 0 then
    return {
      ["value"] = 0,
      ["success"] = false,
      ["critical"] = false
    }
  end

  -- limit value to at most a 5
  local value = math.floor( math.min(5, (diff+4)/4) )
  return {
    ["value"] = value,
    ["success"] = true,
    ["critical"] = false
  }

end

return Die
