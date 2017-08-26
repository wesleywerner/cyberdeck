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

local Hardware = {}

function Hardware:create(class, rating)

  -- new instance
  local instance = {}

  -- validate the given values
  if not self.types[class] then
    error (string.format("%q is not a valid hardware class.", class))
  end

  if not rating or rating < 1 then
    error (string.format("%q is not a valid rating for hardware.", rating or "nil" ))
  end

  -- assign the given values
  instance.class = class
  instance.rating = rating

  return instance

end

Hardware.types = {
  ["Chip Burner"] = {
    maxRating = 4,
    baseCost = 1000,
    levelSuffixes = {
      [1] = nil,
      [2] = "(Double Speed)",
      [3] = "(Triple Speed)",
      [4] = "(Quad Speed)"

    }
  },
  ["Surge Suppressor"] = {
    maxRating = 5,
    baseCost = 500,
  },
  ["Neural Damper"] = {
    maxRating = 5,
    baseCost = 1000,
  },
  ["Trace Monitor"] = {
    maxRating = 3,
    baseCost = 250,
  },
  ["Bio Monitor"] = {
    maxRating = 2,
    baseCost = 500,
    levelSuffixes = {
      [1] = nil,
      [2] = "(Auto Dump)"
    }
  },
  ["High Bandwidth Bus"] = {
    maxRating = 5,
    baseCost = 500,
  },
  ["Proximity Mapper"] = {
    maxRating = 1,
    baseCost = 2000,
  },
  ["Design Assistant"] = {
    maxRating = 3,
    baseCost = 2000,
  },
  ["AntiTrace Proxy"] = {
    maxRating = 1,
    baseCost = 1500,
  },
}

function Hardware:getType(hw)
  local def = self.types[hw.class]
  if not def then
    error( "No type definition found for %q", self.class)
  end
  return def
end

function Hardware:getRating(hw)
  return hw.rating
end

function Hardware:getMaxRating(hw)
  local def = self:getType(hw)
  return def.maxRating
end

function Hardware:getPrice(hw)
  -- the original calculation uses bitwise left shift on the rating.
  -- since only lua 5.3+ has native bitwise operator support we use a
  -- lookup here to keep compatiblity with older luas.
  local lookup = {1,2,4,8,16}
  local def = self:getType(hw)
  return def.baseCost * lookup[hw.rating]
end

function Hardware:getResellPrice(entity)
  return self:getPrice(entity) / 2
end

function Hardware:getText(entity)
  local def = self:getType(entity)
  if def.maxRating == 1 then
    -- only one level presents a simplified text
    return entity.class
  else
    -- append a suffix instead of the current rating (if available)
    local suffix = def.levelSuffixes and def.levelSuffixes[entity.rating]
    if suffix then
      return string.format("%s %s", entity.class, suffix )
    else
      return string.format("%s L%d", entity.class, entity.rating )
    end
  end
end

return Hardware
