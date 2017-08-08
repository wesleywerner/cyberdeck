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

Hardware = {}

--[[ Constructor
  the __call metamethod allows us to call the table like a function,
  this becomes a constructor for creating new instances.
  ]]
setmetatable( Hardware, {
  __call = function( cls, typeName, rating)

    -- new instance
    local instance = {}
    
    --[[
      the __index metatable redirects function-calls on any instances to
      this base table (ie inheritance), and
      "cls" refers to the current table
      ]]
    setmetatable( instance, { __index=cls } )
    
    -- validate the given values
    if not cls.types[typeName] then
      error (string.format("%q is not a valid hardware type.", typeName))
    end
    
    if not rating or rating < 1 then
      error (string.format("%q is not a valid rating for hardware.", rating or "nil" ))
    end
    
    -- assign the given values
    instance.typeName = typeName
    instance.rating = rating
    
    return instance
  
  end
})

-- TODO possibly move to global.lua
Hardware.categories = {
  "software",
  "chip",
  "hardware"
}

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

function Hardware:getType()
  local def = self.types[self.typeName]
  if not def then
    error( "No type definition found for %q", self.typeName)
  end
  return def
end

function Hardware:getName()
  return self.typeName
end

function Hardware:getRating()
  return self.rating
end

function Hardware:getMaxRating()
  local def = self:getType()
  return def.maxRating
end

function Hardware:getPrice()
  -- the original calculation uses bitwise left shift on the rating.
  -- since only lua 5.3+ has native bitwise operator support we use a
  -- lookup here to keep compatiblity with older luas.
  local lookup = {1,2,4,8,16}
  local def = self:getType()
  return def.baseCost * lookup[self.rating]
end

function Hardware:getText()
  local def = self:getType()
  if def.maxRating == 1 then
    -- only one level presents a simplified text
    return self:getName()
  else
    -- append a suffix instead of the current rating (if available)
    local suffix = def.levelSuffixes and def.levelSuffixes[self.rating]
    if suffix then
      return string.format("%s %s", self:getName(), suffix )
    else
      return string.format("%s L%d", self:getName(), self.rating )
    end
  end
end

return Hardware
