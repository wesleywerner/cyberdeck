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

  local typeDefinition = self:getType(class)
  if not typeDefinition then
    error(string.format("No type definition found for %q", class))
  end

  -- new instance
  local instance = {}

  if not rating or rating < 1 then
    error (string.format("%q is not a valid rating for hardware.", rating or "nil" ))
  end

  -- assign the given values
  instance.class = class
  instance.rating = rating

  return instance

end

Hardware.types = {
  {
    class = "Chip Burner",
    maxRating = 4,
    baseCost = 1000,
    levelSuffixes = {
      [1] = nil,
      [2] = "(Double Speed)",
      [3] = "(Triple Speed)",
      [4] = "(Quad Speed)"

    }
  },
  {
    class = "Surge Suppressor",
    maxRating = 5,
    baseCost = 500,
  },
  {
    class = "Neural Damper",
    maxRating = 5,
    baseCost = 1000,
  },
  {
    class = "Trace Monitor",
    maxRating = 3,
    baseCost = 250,
  },
  {
    class = "Bio Monitor",
    maxRating = 2,
    baseCost = 500,
    levelSuffixes = {
      [1] = nil,
      [2] = "(Auto Dump)"
    }
  },
  {
    class = "High Bandwidth Bus",
    maxRating = 5,
    baseCost = 500,
  },
  {
    class = "Proximity Mapper",
    maxRating = 1,
    baseCost = 2000,
  },
  {
    class = "Design Assistant",
    maxRating = 3,
    baseCost = 2000,
  },
  {
    class = "AntiTrace Proxy",
    maxRating = 1,
    baseCost = 1500,
  },
}

function Hardware:getType(class)
  local def = nil
  for i,v in ipairs(self.types) do
    if v.class == class then
      def = v
    end
  end
  return def
end

function Hardware:getRating(hardware)
  return hardware.rating
end

function Hardware:getMaxRating(hardware)
  local def = self:getType(hardware.class)
  return def.maxRating
end

function Hardware:getPrice(hardware)
  -- the original calculation uses bitwise left shift on the rating.
  -- since only lua 5.3+ has native bitwise operator support we use a
  -- lookup here to keep compatiblity with older luas.
  local lookup = {1,2,4,8,16}
  local def = self:getType(hardware.class)
  return def.baseCost * lookup[hardware.rating]
end

function Hardware:getResellPrice(hardware)
  return self:getPrice(hardware) / 2
end

function Hardware:getText(hardware)
  local def = self:getType(hardware.class)
  if def.maxRating == 1 then
    -- only one level presents a simplified text
    return hardware.class
  else
    -- append a suffix instead of the current rating (if available)
    local suffix = def.levelSuffixes and def.levelSuffixes[hardware.rating]
    if suffix then
      return string.format("%s %s", hardware.class, suffix )
    else
      return string.format("%s L%d", hardware.class, hardware.rating )
    end
  end
end

return Hardware
