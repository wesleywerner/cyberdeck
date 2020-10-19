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

--- Provides helper functions to ease unit testing.

--- Filters items from table.
-- @tfield table t
-- @tfield function callback
-- A function that accepts one item, a table element.
-- It should return true if the item is included in the results.
-- @treturn table
-- Matched items
local function filter(t, callback)
  local result = {}
  for k,v in pairs(t) do
    if callback(v) then
      table.insert(result, v)
    end
  end
  return result
end

--- Pick the first item from a table matching a filter.
-- @tfield table t
-- @tfield function callback
-- @return object
-- First matched result or nil on no match.
-- @see filter
local function first(t, callback)
  local result = filter(t, callback)
  return result[1]
end

return {
  filter=filter,
  first=first
}