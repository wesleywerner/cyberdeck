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

--- Provides dice roll functions.
local Die = {}

--- Roll a 20-sided die against a target value.
-- A roll equal to the target value is a success, thus smaller targets favor the player.
-- A successful roll also returns the degree of success, a value between 1 and 5.
-- A larger target yields a smaller degree of success.
-- There is always a 1 in 20 chance of critical failure.
-- @param target A value between 1 and 20 to roll against, favoring lower values.
-- @return A table of the roll result { degree=[1..5], success=[true/false], critical=[true/false] }.
function Die:roll(target)

  target = math.min(20, target)
  local roll = math.random(20)

  if roll == 1 then
    return {
      ["degree"] = 0,
      ["success"] = false,
      ["critical"] = true
    }
  end

  local diff = roll - target

  -- failure
  if diff < 0 then
    return {
      ["degree"] = 0,
      ["success"] = false,
      ["critical"] = false
    }
  end

  -- limit value to at most a 5
  local value = math.floor( math.min(5, (diff+4)/4) )
  return {
    ["degree"] = value,
    ["success"] = true,
    ["critical"] = false
  }

end

return Die
