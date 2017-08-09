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
    instance.health = nil
    -- number of turns to slow the ICE - skips every other turn - Affected by slow program
    instance.slowLevel = nil
    -- is confused for this many turns - Affected by confusion program
    instance.confusionLevel = nil
    -- weakened for this many turns - Affected by weaken program
    instance.weakenLevel = nil
    -- take damage this many turns - Affected by virus program
    instance.virusLevel = nil
    -- if this ICE has been analyzed
    instance.analyzed = nil
    -- was this ICE bypassed by the player
    instance.bypassed = nil
    -- was this ICE accessed by the player
    instance.acccessed = nil
    -- home node of this ICE
    instance.homeNode = nil
    -- current location
    instance.node = nil
    -- position within the node
    instance.nodeDrawPosition = nil
    -- the node this ICE is moving towards
    instance.targetNode = nil
    -- last direction moved
    instance.lastMoveDirection = nil
    -- track list of flags
    instance.flags = {}
    
    
    return instance
  
  end
})

--[[ There are a couple types of ICE, some of them have optional flags
    to change their behaviour. Some of these flags changes the ICE's name. ]]  
Ice.types = {
  ["Gateway"] = {
    note = "Bars passageway to another node.",
    names = {
      "Gateway",
      "Fence",
      "Barrier",
      "Doorway",
      "Blockade",
      "Checkpoint",
      "Bouncer",
      "Doorman",
      "Gateway Mk2",
      "Reinforced Fence",
      "Roadblock",
      "Gate",
      "Barrier II",
      "Checkpoint",
      "BouncerEx",
      "Doorman 2.0",
      "Gateway Mk 3",
      "Reinforced Door",
      "Electric Fence",
      "Big Bouncer",
    },
  },
  ["Probe"] = {
    note = "Searches for intruders in the system.",
    names = {
      "Probe",
      "Gazer",
      "Bobby",
      "Snooper",
      "Inquisitor",
      "Gazer II",
      "Cop",
      "Probe Mk2",
      "Mystic Eye",
      "Scout",
      "Bobby 2.0",
      "Scout II",
      "Police",
      "Magic Eye",
      "Gazer III",
      "Probe Mk3",
      "Scout III",
      "SuperFuzz",
      "Wizard Eye",
      "Beholder",
    },
  },
  ["Guardian"] = {
    note = "Guards access to the node.",
    names = {
      "Guardian",
      "Protector",
      "Sentry",
      "Gargoyle",
      "Guardian Mk2",
      "Sphinx",
      "Golem",
      "Eunoch",
      "Protector 2",
      "Guardian Mk3",
      "GynoSphinx",
      "Gargoyle 2.0",
      "Golem II",
      "Protector 3",
      "Guardian Mk4",
      "Protector 3",
      "EunochEx",
      "Guardian Mk5",
      "Golem III",
      "AndroSphinx",
    },
  },
  ["Tapeworm"] = {
    note = "Guards a file. Will self-destruct on illegal access, taking the file with it.",
    names = {
      "Tapeworm",
      "Boa",
      "Kudzu",
      "Anaconda",
      "Boa 2.0",
      "Tapeworm Mk2",
      "Kudzu II",
      "Anaconda 2.1",
      "Boa 3.0",
      "Tapeworm Mk3",
      "Boa 3.1a",
      "Kudzu III",
      "Anaconda 3.0",
      "Boa 3.1",
      "Tapeworm Mk4",
      "StrangleVine",
      "Anaconda 4.2",
      "Boa 4.0",
      "Tapeworm Mk5",
      "StrangleVine II",
    },
    allowedFlags = {
      "data bomb",  -- Will attack on self destruct
    },
    flagNamesOverride = {
      ["data bomb"] = {
        "Data Bomb",
        "Dynamyte 1.0",
        "Trap",
        "Data Bomb Mk2",
        "Dynamyte 2.0",
        "Trap II",
        "Dynamyte 2.1",
        "Data Bomb Mk3",
        "Trap III",
        "Da Bomb",
      },
    }
  },
  ["Attack"] = {
    note = "Attacks intruders.",
    names = {
      "Attack",
      "Brute",
      "Grunt",
      "Centurion",
      "Attack Mk2",
      "Enforcer",
      "Wolf",
      "Soldier",
      "Attack Mk3",
      "Centurion II",
      "Dire Wolf",
      "Attack Mk4",
      "Marine",
      "Worg",
      "Centurion III",
      "Barbarian",
      "Werewolf",
      "Attack Mk5",
      "Centurion IV",
      "Green Beret",
    },
    allowedFlags = {
      "hardened",   -- Resistant to non-piercing attacks
      "phasing",    -- Resistant to non-area attacks
      "crash",      -- Can crash your programs on succesful hits
      "lethal",     -- sends power surges through your cyberdeck directly into your brain to cause mental damage
    },
    flagNamesOverride = {
      ["hardened"] = {
        "Attack-H",
        "Knight",
        "Tank",
        "Turtle",
        "Attack-H Mk2",
        "Knight II",
        "Terrapin",
        "Sherman",
        "Attack-H Mk3",
        "Knight III",
        "Tortoise",
        "Attack-H Mk4",
        "Dragon Turtle",
        "Knight IV",
        "Bradley",
      },
      ["phasing"] = {
        "Attack-P",
        "Bugs",
        "Spook",
        "Neophyte",
        "Attack-P Mk2",
        "Bees",
        "Ghost",
        "Disciple",
        "Shade",
        "Wasps",
        "Attack-P Mk3",
        "Monk",
        "Phantom",
        "Hornets",
        "Quai Chang Kain",
      },
      ["crash"] = {
        "Attack-C",
        "Spider",
        "Scorpion",
        "Rattler",
        "Attack-C Mk2",
        "Copperhead",
        "Scorpion 2.0",
        "Attack-C Mk3",
        "Spider II",
        "Scorpion 2.3",
        "Cottonmouth",
        "Spider III",
        "Attack-C Mk4",
        "Scorpion 3.0",
        "Black Widow",
      },
      ["lethal"] = {
        "Attack-L",
        "Cowboy",
        "Attack-L Mk2",
        "Wrangler",
        "Executioner",
        "Sheriff",
        "Attack-L Mk3",
        "Executioner II",
        "Marshal",
        "Highlander",
      },
    }
  },
  ["Trace"] = {
    note = "Attempts to trace an intruder's signal in the system.",
    names = {
      "Trace",
      "Hound",
      "Tracker",
      "Private Eye",
      "Trace Mk2",
      "Tracker II",
      "Blue Tick Hound",
      "Private Eye 2.0",
      "Sherlock",
      "Trace Mk3",
      "Tracker III",
      "Bloodhound",
      "Sherlock II",
      "Private Eye 3.0",
      "Trace Mk4",
      "Mastiff",
      "Tracker IV",
      "Sherlock III",
      "Trace Mk5",
      "Hound of the Baskervilles",
    },
    allowedFlags = {
      "dump",       -- dump the decker
      "fry",        -- attempt to fry a chip
    },
    flagNamesOverride = {
      ["dump"] = {
        "Trace & Dump",
        "Detective",
        "Ranger",
        "Investigator",
        "Trace & Dump Mk2",
        "Detective 2.2",
        "Ranger II",
        "Investigator",
        "Trace & Dump Mk3",
        "Detective 3.1",
        "Ranger III",
        "Investigator",
        "Trace & Dump Mk4",
        "Detective 4.0",
        "Ranger IV",
      },
      ["fry"] = {
        "Trace & Fry",
        "Mindworm",
        "Zapp",
        "Trace & Fry Mk2",
        "Mindworm 2.0",
        "SuperZapp",
        "Mindworm 3.1",
        "Trace & Fry Mk3",
        "Mindworm 4.0",
        "MegaZapp",
      },
    },
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
  
  -- if the ICE flags have name overrides
  if def.allowedFlags then
    for flagIdx,flagKey in ipairs(self.flags) do
      local flagNameList = def.flagNamesOverride[flagKey]
      if flagNameList then
        if self.rating < #flagNameList then
          return flagNameList[self.rating]
        else
          return flagNameList[#flagNameList]
        end
      end
    end
  end
  
  -- get the name related to rating, limited to names list size
  if self.rating < #def.names then
    return def.names[self.rating]
  else
    return def.names[#def.names]
  end
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

function Ice:hasFlag(flagName)
  local def = self:getType()
  for k,v in pairs(def.allowedFlags) do
    if v==flagName then return true end
  end
  return false
end

function Ice:setFlag(flagName)
  if not self:hasFlag(flagName) then
    error(string.format("%q is not a valid flag for %q", flagName, self.typeName))
  end
  if not self.flags[flagName] then
    table.insert(self.flags, flagName)
  end
end

return Ice
