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

--- An interface to manage chips for your deck.
-- Chips are items that enhance player skills or provide new features.
-- They can be purchased from the @{shop} or by building @{sourcecode}.
local Chips = {}

function Chips:create(class, rating)

  -- new instance
  local instance = {}

  -- validate the given values
  local typeDefinition = self:getType(class)
  if not typeDefinition then
    error(string.format("No type definition found for %q", class))
  end

  if not rating or rating < 1 then
    error (string.format("%q is not a valid rating for chips.", rating or "nil" ))
  end

  -- assign the given values
  instance.class = class
  instance.rating = rating

  return instance

end

--- A table of all chip types.
-- The list of chip types are: CPU, Attack Firmware, Defense Firmware, Stealth Firmware, Analysis Firmware, Coprocessor.
-- @table Chips.types
-- @field class Chip class name.
-- @field baseCost Cost used to derive market price.
-- @field complexity Affects price, memory usage and development time as a @{sourcecode} item.
Chips.types = {
  {
    class = "CPU",
    baseCost = 150,
    complexity = 5
  },
  {
    class = "Attack Firmware",
    baseCost = 100,
    complexity = 4
  },
  {
    class = "Defense Firmware",
    baseCost = 100,
    complexity = 4
  },
  {
    class = "Stealth Firmware",
    baseCost = 100,
    complexity = 4
  },
  {
    class = "Analysis Firmware",
    baseCost = 100,
    complexity = 4
  },
  {
    class = "Coprocessor",
    baseCost = 125,
    complexity = 5
  },
}

function Chips:getType(class)
  local def = nil
  for i,v in ipairs(self.types) do
    if v.class == class then
      def = v
    end
  end
  return def
end

function Chips:getName(chip)
  return chip.class
end

function Chips:getRating(chip)
  return chip.rating
end

function Chips:getPrice(chip)
  local def = self:getType(chip.class)
  return math.pow(chip.rating, 2) * def.baseCost
end

function Chips:getText(chip)
  return string.format("%s L%d", self:getName(chip), chip.rating)
end

function Chips:getComplexity(chip)
  local definition = self:getType(chip.class)
  return definition.complexity
end

return Chips
