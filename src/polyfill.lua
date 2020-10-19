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
--]]

--- Provides pico-8 filler functions for Lua 5 compatibility.
-- @author Wesley Werner
-- @license GPL v3

--- Sets the random number seed.
--
-- @tfield number x
function srand(x)
 math.randomseed(x)
end

--- Get a random number or element from a table.
--
-- @tfield number n
-- Returns a random float x, where 0 <= x < n.
--
-- @tfield table n
-- Returns a random element from the table.
function rnd(n)
 if type(n) == "table" then
  return n[1 + math.floor(rnd() * #n)]
 else
  return math.random() * (n or 1)
 end
end

--- Get the maximum of two values.
--
-- @tfield number a
-- @tfield number b
--
-- @treturn number
-- The larger of a or b.
function max(a, b)
 return math.max(a, b)
end

--- Get the minimum of two values.
--
-- @tfield number a
-- @tfield number b
--
-- @treturn number
-- The smaller of a or b.
function min(a, b)
 return math.min(a, b)
end

--- Get the floor value of a float.
--
-- @tfield number n
-- @treturn number
function flr(n)
 return math.floor(n)
end

--- Get the ceiling value of a float.
--
-- @tfield number n
-- @treturn number
function ceil(n)
 return math.ceil(n)
end

--- Append value t to a table
function add(t, v)
  table.insert(t, v)
  return v
end

--- Remove item at index i from table.
function deli(t, i)
  i = i or #t
  table.remove(t, i)
end

--- Cast to string
function tostr(v)
  return tostring(v)
end

-- round function (unused)
-- function round(num, numDecimalPlaces)
--   local mult = 10^(numDecimalPlaces or 0)
--   return math.floor(num * mult + 0.5) / mult
-- end
