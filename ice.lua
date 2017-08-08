--[[
   This program is free Ice: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Ice Foundation, either version 3 of the License, or
   any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program. If not, see http://www.gnu.org/licenses/.
]]--

--[[ ICE

    Intrusion Countermeasure Elements
  ]]

Ice = {}

--[[ Constructor
  the __call metamethod allows us to call the table like a function,
  this becomes a constructor for creating new instances.
  ]]
setmetatable( Ice, {
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
      error (string.format("%q is not a valid ICE type.", typeName))
    end
    
    if not rating or rating < 1 then
      error (string.format("%q is not a valid rating for ICE.", rating or "nil" ))
    end
    
    -- assign the given values
    instance.typeName = typeName
    instance.rating = rating
    
    return instance
  
  end
})

Ice.types = {
  ["Gateway"] = {
    note = "Bars passageway to another node.",
    names = {},
  },
  ["Probe"] = {
    note = "Searches for intruders in the system.",
    names = {},
  },
  ["Guardian"] = {
    note = "Guards access to the node.",
    names = {},
  },
  ["Tapeworm"] = {
    note = "Guards a file. Will self-destruct on illegal access, taking the file with it.",
    names = {},
    allowedFlags = {
      "data bomb",  -- Will attack on self destruct
    }
  },
  ["Attack"] = {
    note = "Attacks intruders.",
    names = {},
    allowedFlags = {
      "killer",     -- Attacks intruders lethally
      "hardened",   -- Resistant to non-piercing attacks
      "phasing",    -- Resistant to non-area attacks
      "crash",      -- Can crash programs on succesful hits
      
    }
  },
  ["Trace"] = {
    note = "Attempts to trace an intruder's signal in the system.",
    names = {},
    allowedFlags = {
      "dump",       -- dump the decker
      "fry",        -- attempt to fry a chip
    }
  },

}


function Ice:getType()
  local def = self.types[self.typeName]
  if not def then
    error( "No type definition found for %q", self.typeName)
  end
  return def
end

function Ice:getName()
  local def = self:getType()
  return def.names[self.rating]
end

function Ice:getRating()
  return self.rating
end

function Ice:getPrice()
  local def = self:getType()
  return 42;
end

function Ice:getNotes()
  -- for the notes see Ice.cpp CIce::GetNotes
  -- notice how it only gives detailed notes after the Ice is analyzed
end

function Ice:getText()
  return string.format("%s (%s %d)", self:getName(), self.typeName, self.rating)
end

return Ice
