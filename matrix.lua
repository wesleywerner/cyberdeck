--[[
   This program is free Template: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Template Foundation, either version 3 of the License, or
   any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program. If not, see http://www.gnu.org/licenses/.
]]--

--[[ List of conditions when alerts are triggered:
    
    RED
    state is moving and is hostile
    state is destroying
    state is attacking
    state is guarding and is hostile
    while querying the player and is not bypassed and the player has decoys active
    when confused and decides to attack, but is not an attacking ICE (not attack, not trace, not probe)
    a random chance when switching a IO node that has no sub-type (a useless node)
    when failing to crash the logged-in system
    when failing to create a backdoor
    when failing to kill a yellow alert
    when failing to cancel system shutdown
    when failing to remove a trace
    
    YELLOW
    state is queried 3, is not bypassed and the player is not in the same node anymore
    when failing to deceive ICE that is *not* in any queried state
]]


Template = {}

Template.types = {}

--[[ Constructor
  the __call metamethod allows us to call the table like a function,
  this becomes a constructor for creating new instances.
  ]]
setmetatable( Template, {
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
      error (string.format("%q is not a valid THING type.", typeName))
    end
    
    if not rating or rating < 1 then
      error (string.format("%q is not a valid rating for THING.", rating or "nil" ))
    end
    
    -- assign the given values
    instance.typeName = typeName
    instance.rating = rating
    
    return instance
  
  end
})

function Template:getType()
  local def = self.types[self.typeName]
  if not def then
    error( "No type definition found for %q", self.typeName)
  end
  return def
end

function Template:getName()
  local def = self:getType()
  return def.names[self.rating]
end

function Template:getRating()
  return self.rating
end

function Template:getPrice()
  local def = self:getType()
  return 42;
end

function Template:getText()
  return string.format("%s (%s %d)", self:getName(), self.typeName, self.rating)
end

return Template
