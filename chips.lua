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


Chips = {}

function Chips:create(class, rating)

  -- new instance
  local instance = {}
  
  -- validate the given values
  if not self.types[class] then
    error (string.format("%q is not a valid chip class.", class))
  end
  
  if not rating or rating < 1 then
    error (string.format("%q is not a valid rating for chips.", rating or "nil" ))
  end
  
  -- assign the given values
  instance.class = class
  instance.rating = rating
  
  return instance

end

Chips.types = {
  ["CPU"] = {
    baseCost = 150,
  },
  ["Attack Firmware"] = {
    baseCost = 100,
  },
  ["Defense Firmware"] = {
    baseCost = 100,
  },
  ["Stealth Firmware"] = {
    baseCost = 100,
  },
  ["Analysis Firmware"] = {
    baseCost = 100,
  },
  ["Coprocessor"] = {
    baseCost = 125,
  },
}

function Chips:getType(ch)
  local def = self.types[ch.class]
  if not def then
    error( "No type definition found for %q", ch.class)
  end
  return def
end

function Chips:getName(ch)
  return ch.class
end

function Chips:getRating(ch)
  return ch.rating
end

function Chips:getPrice(ch)
  local def = self:getType(ch)
  return math.pow(ch.rating, 2) * def.baseCost
end

function Chips:getText(ch)
  return string.format("%s L%d", self:getName(ch), ch.rating)
end

return Chips
