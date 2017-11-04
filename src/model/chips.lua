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
-- @author Wesley Werner
-- @license GPL v3
local Chips = {}

--- Create a new instance of a chip.
--
-- @tparam string class
-- The class of the chip, one of @{chips.types}.
--
-- @tparam number rating
-- The rating of the chip affects the price and affectiveness.
--
-- @treturn chips:instance
function Chips:create(class, rating)

  -- validate the given values
  local typeDefinition = self:getType(class)
  if not typeDefinition then
    error(string.format("No type definition found for %q", class))
  end

  if not rating or rating < 1 then
    error (string.format("%q is not a valid rating for chips.", rating or "nil" ))
  end

  --- The instance definition received from calling @{create}.
  --- @table instance
  --
  -- @tfield string class
  -- The chip's class name.
  --
  -- @tfield number rating
  -- The chip's rating.
  local instance = {}
  instance.class = class
  instance.rating = rating
  return instance

end

--- A table of available chip types.
-- Each type is identified by a class name.
-- The list of chip classes are:
-- CPU, Attack Firmware, Defense Firmware,
-- Stealth Firmware, Analysis Firmware, Coprocessor.
--
-- @table types
--
-- @tfield string class
-- The class of the chip.
--
-- @tfield number baseCost
-- A base cost used to derive market price.
--
-- @tfield number complexity
-- Affects price, memory usage and development time as a @{sourcecode} item.
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

--- Get the type definition.
--
-- @tparam string class
--   The class name to look up.
--
-- @treturn chips.types or nil if no match is found.
function Chips:getType(class)
  local def = nil
  for i,v in ipairs(self.types) do
    if v.class == class then
      def = v
    end
  end
  return def
end

--- Get the name.
--  Currently it returns the class name.
--
-- @tparam chips.instance chip
-- The chip instance to query.
--
-- @treturn string
-- The name of the chip.
function Chips:getName(chip)
  return chip.class
end

--- Get the rating.
--
-- @tparam chips.instance chip
-- The chip instance to query.
--
-- @treturn number
-- The rating of the chip.
function Chips:getRating(chip)
  return chip.rating
end

--- Get the market price.
-- The chip rating affects the price.
--
-- @tparam chips.instance chip
-- The chip instance to query.
--
-- @treturn number
function Chips:getPrice(chip)
  local def = self:getType(chip.class)
  return math.pow(chip.rating, 2) * def.baseCost
end

--- Get the display text.
-- Formatted as the chip name and rating.
--
-- @tparam chips.instance chip
-- The chip instance to query.
--
-- @treturn string
function Chips:getText(chip)
  return string.format("%s L%d", self:getName(chip), chip.rating)
end

--- Ges the complexity.
-- For more on how this is used, see @{sourcecode:instance}
--
-- @tparam chips.instance chip
-- The chip instance to query.
--
-- @treturn number
-- The complexity of the chip.
function Chips:getComplexity(chip)
  local definition = self:getType(chip.class)
  return definition.complexity
end

return Chips
