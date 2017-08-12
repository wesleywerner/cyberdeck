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

  TODO 
  ICE STATES - implemented from Ice.h
  
  inactive (STATE_INACTIVE)
    Black ice which is not active
  
  guarding (STATE_GUARDING)
    Attack and trace ICE that are *not* bypassed will query the player autonomously.
    Other ICE only query if they are accessed.
  
  following (STATE_FOLLOWING)
    Follows the player to adjacent nodes, unless the current node is smoked.
    If in the same node as the player, it will query the player.
    If the query was bypassed, it goes into a searching state and wanders.
  
  moving (STATE_MOVING)
    Going to a target node. (Black only)
  
  searching (STATE_SEARCHING)
    Searching for intruders (Black/Probe)
  
  destroying* (STATE_DESTROYING)
    Destroying a datafile - tapeworm only
  
  queried 1, queried 2, queried 3 (STATE_QUERIED1/2/3)
    Queried player, waiting for response
  
  attacking (STATE_ATTACKING)
    Black ice attacking/chasing the player
  
  return home (STATE_MOVING_H)
    White ice returning to home node
       
 * possibly no need for this as a state?  
]]

--[[ List of conditions when the player can be queried:
     always assume the ICE and the player are in the same node
     & indicates only if the ICE is not bypassed
     ^ indicates only if the ICE noticed the player - tests the player hide program vs the ICE
  
    state is following
    state is moving and ICE is attack, probe or trace &^
    state is searching with notice &^
    state is queried1/2/3 &
    state is guarding and (ICE is attack or trace &^) or (ICE was accessed)
]]


Ice = {}
Ice.MAX_HEALTH = 20

-- Constructor
-- the __call metamethod allows us to call the table like a function,
-- this becomes a constructor for creating new instances.
setmetatable( Ice, {
  __call = function( cls, typeName, rating, flags)

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
    instance.name = nil
    instance.typeName = typeName
    instance.rating = rating
    instance.health = Ice.MAX_HEALTH
    -- number of turns to slow the ICE - skips every other turn - Affected by slow program
    instance.slowLevel = nil
    -- is confused for this many turns - Affected by confusion program
    instance.confusionLevel = nil
    -- weakened for this many turns - Affected by weaken program
    instance.weakenLevel = nil
    -- take damage this many turns - Affected by virus program
    instance.virusLevel = nil
    -- the analyzed level this ICE was subjected against
    instance.analyzedLevel = 0
    -- was this ICE bypassed by the player
    instance.bypassed = nil
    -- was this ICE accessed by the player
    instance.accessed = nil
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
    -- see the list of ICE state at the top of this file
    instance.state = nil
    --  try signal a red alert
    instance.hostile = nil
    -- actively wanders about searching for the player. also navigates to the player on alerts.
    instance.response = nil

    -- BEHAVIOUR FLAGS
    -- Resistant to non-piercing attacks
    instance.hardened = false
    -- Resistant to non-area attacks
    instance.phasing = false
    -- Can crash your programs on succesful hits
    instance.crasher = false
    -- sends power surges through your cyberdeck directly into your brain to cause mental damage
    instance.lethal = false
    -- destroys a file when it dies
    instance.databomb = false
    -- dump the decker out of the matrix
    instance.dumper = false
    -- attempt to fry a random one of the player's chips on successful dump
    instance.fryer = false
    -- apply any given flags
    instance:applyFlags(flags)
    
    instance.name = instance:getDefaultName()
    return instance
  
  end
})

-- There are a couple types of ICE, some of them have optional flags
-- to change their behaviour. Some of these flags changes the ICE's name.
Ice.types = {
  ["Gateway"] = {
    note = "Bars passageway to another node.",
    isCombat = false,
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
    isCombat = false,
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
    isCombat = false,
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
    isCombat = false,
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
  },
  ["Attack"] = {
    note = "Attacks intruders.",
    isCombat = true,
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
  },
  ["Trace"] = {
    note = "Attempts to trace an intruder's signal in the system.",
    isCombat = true,
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
  },
}

-- names applied for specific ICE flags
Ice.alternateNames = {
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
  ["crasher"] = {
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
  ["dumper"] = {
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
  ["fryer"] = {
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
}

-- apply the given flags, a table of string values, to the ICE
function Ice:applyFlags(flags)
  local allowedFlags = {
    ["hardened"] = true,
    ["phasing"] = true,
    ["crasher"] = true, 
    ["lethal"] = true,
    ["databomb"] = true,
    ["dumper"] = true,
    ["fryer"] = true,
  }
  if flags then
    for k,v in pairs(flags) do
      if not allowedFlags[v] then
        error(string.format("%q is not a valid ICE flag", v))
      else
        self[v] = true
      end
    end
  end
end

function Ice:getType()
  local def = self.types[self.typeName]
  if not def then
    error("No type definition found for %q", self.typeName)
  end
  return def
end

function Ice:getName()
  return self.name
end

function Ice:getDefaultName()
  local nameList = nil
  if self.hardened then
    nameList = self.alternateNames["hardened"]
  elseif self.phasing then
    nameList = self.alternateNames["phasing"]
  elseif self.crasher then
    nameList = self.alternateNames["crasher"]
  elseif self.lethal then
    nameList = self.alternateNames["lethal"]
  elseif self.databomb then
    nameList = self.alternateNames["data bomb"]
  elseif self.fryer then
    nameList = self.alternateNames["fryer"]
  elseif self.dumper then
    nameList = self.alternateNames["dumper"]
  else
    local def = self:getType()
    nameList = def.names
  end
  
  if not nameList then
    error(string.format("%q has no namelist", self.typeName))
  end
  
  -- get the name related to rating, clamped to list size
  if self.rating < #nameList then
    return nameList[self.rating]
  else
    return nameList[#nameList]
  end
end

function Ice:getPrice()
  local def = self:getType()
  return 42;
end

function Ice:getNotes()
  local def = self:getType()
  if self.analyzedLevel == 0 then
    -- give the ICE type note
    return def.note
  else
    -- add extra notes for the behaviour flags
    local extraNotes = {}
    if self.hardened then
      table.insert(extraNotes, "Resistant to non-piercing attacks.")
    end
    if self.phasing then
      table.insert(extraNotes, "Resistant to non-area attacks.")
    end
    if self.crasher then
      table.insert(extraNotes, "Attacks can crash your programs.")
    end
    if self.lethal then
      table.insert(extraNotes, "Attacks can cause you mental damage.")
    end
    if self.dumper then
      table.insert(extraNotes, "Can dump your deck from the matrix.")
    end
    if self.fryer then
      table.insert(extraNotes, "Can fry one of your hardware chips.")
    end
    return def.note .. " " .. table.concat(extraNotes, " ")
  end
end

function Ice:getText()
  return string.format("%s (%s %d)", self:getName(), self.typeName, self.rating)
end

-- get the ICE rating, adjusted by factors like health, 
-- if the ICE was analyzed and any weakened effects.
-- larger results indicate a favorable outcome for the ICE.
-- give optional parameter "versusHardwareOrOtherICE" as true to ignore player analysis effects.
function Ice:getRating(versusHardwareOrOtherICE)

  -- use the base rating
	local nRating = self.rating

	-- adjust according to ICE health. The curve of this can be seen with
  -- this code:
  --  for n=20,1,-1 do
  --    print(string.format("%d%% ICE health reduces rating by -%.2f",n/20*100,(20-n)/4))
  --  end
  -- this was called GetConditionModifier() in the original source.
	nRating = nRating - ((Ice.MAX_HEALTH - self.health)/4)

	-- reduce if the ICE is weakened
	if self.weakened then
    nRating = nRating - 4
  end

	-- reduce if the ICE was analyzed
	if not versusHardwareOrOtherICE then
    nRating = nRating - self.analyzedLevel
  end

	return nRating
end

-- get the ICE rating adjusted for combat.
-- non-combat ICE take a penalty.
function Ice:getAttackRating(versusHardwareOrOtherICE)
  local nRating = self:getRating(versusHardwareOrOtherICE)
  local def = self:getType()
  if not def.isCombat then
    return nRating - 2
  else
    return nRating
  end
end

-- get the ICE rating adjusted for sensors.
-- used when calculating odds of hide and deceive programs against ICE.
-- non-combat ICE get a bonus.
function Ice:getSensorRating(versusHardwareOrOtherICE)
  local nRating = self:getRating(versusHardwareOrOtherICE)
  local def = self:getType()
  if not def.isCombat then
    return nRating + 2
  else
    return nRating
  end
end

return Ice
