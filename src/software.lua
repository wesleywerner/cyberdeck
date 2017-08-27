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

-- Software is what you load into your deck when you enter the matrix.
-- The most prominent properties are:
-- * a class ("Attack", "Shield", "Slow", ...) that determines behaviour
-- * a rating (1..n) that determines how effective it works,
--   the market price, and memory required to run in your deck.
--   This is known as the Potential Rating. It can fluctuate while in the
--   matrix, and is then known as the Active Rating.
-- * a complexity, a value used internally to calculate those above.
--
-- The types table lists all the classes and predefined
-- names for each class.


local Software = {}

function Software:create(class, rating, name)

  local instance = {}

  -- validate the given values
  if not self.types[class] then
    error (string.format("%q is not a valid software class.", class))
  end

  if not rating or rating < 1 then
    error (string.format("%q is not a valid rating for software.", rating or "nil" ))
  end

  -- assign the given values
  instance.class = class
  instance.potentialRating = math.floor(rating)
  instance.name = name or self:getDefaultName(instance)

  -- The effective rating while in the matrix.
  -- It will equal "rating" when loaded into your deck.
  -- It can also be lowered while in the matrix - medic for example
  -- decreases on each use, until it hits zero and crashes.
  instance.activeRating = 0

  -- Number of turns that remain for the software to be fully loaded.
  -- It won't be usable until this value reaches zero.
  instance.loadTurns = 0

  -- The program is ready for use.
  instance.loaded = false

  -- The program does not require execution by the player, it runs
  -- in the background and is used automatically in certain events.
  -- The shield and hide programs for example.
  instance.background = false

  return instance

end

-- Definitions for the different software types.
-- complexity: affects the software price and memory usage (among other things).
-- names: list of predefined software names, indexed to correlate to the software rating.
-- includeOnNewGame: the player starts with this software.
Software.types = {
  ["Attack"] = {
    includeOnNewGame = true,
    complexity = 2,
    names = {
      "Zap 1.0",
      "Zap 2.1",
      "IceBreaker Mk1",
      "Magnum",
      "AK 4.7",
      "Blaster",
      "IceBreaker Mk2",
      "Bazooka",
      "Magnum II",
      "Zap 4.2",
      "Bazooka",
      "CyberDagger",
      "SuperBlaster",
      "Zap 5.0",
      "CyberSword",
      "MegaBlaster",
      "DigiUzi",
      "CyberKatana",
      "IceBreaker Mk3",
      "GigaBlaster",
    }
  },
  ["Area Attack"] = {
    complexity = 3,
    names = {
      "Grenade 1.0",
      "Logic Bomb I",
      "Grenade 1.5",
      "BugSwarm",
      "Shrapnel 1.0",
      "Fireball 1.2",
      "Scattergun",
      "Grenade 2.0",
      "BugSwarm II",
      "Logic Bomb II",
      "Shrapnel 3.0",
      "Grenade 3.0",
      "Fireball 3.1",
      "Logic Bomb III",
      "BugSwarm III",
      "Grenade 4.0",
      "Logic Bomb IV",
      "EMP",
      "Logic Bomb V",
      "Nuke",
    }
  },
  ["Piercing Attack"] = {
    complexity = 3,
    names = {
      "Spear 1.0a",
      "Crossbow",
      "Laser 1.1",
      "Javelin 1.0",
      "Scalpel",
      "Drill 2.2",
      "IcePick 1.3",
      "FMJ",
      "Teflon",
      "Stiletto 1.1.0",
      "Awl 1.0",
      "Drill 3.1",
      "Scalpel II",
      "IcePick 2.0",
      "Laser 4.0",
      "IcePick 2.3",
      "Drill 4.0",
      "Laser 5.1",
      "IcePick 3.0",
      "Shredder",
    }
  },
  ["Slow"] = {
    complexity = 2,
    names = {
      "Slow",
      "Bind 1.0",
      "Goo 1.2",
      "Limpets 1.0",
      "Quicksand 2.3",
      "Glue",
      "Flypaper 1.7a",
      "Goo 2.2",
      "Limpets 2.0",
      "Goo 3.0",
      "Quicksand 3.0",
      "Flypaper 2.2b",
      "SuperGlue",
      "Freeze 1.0",
      "Quicksand",
      "Bind 3.1",
      "Limpets 3.0",
      "KrazyGlue",
      "Bind 4.1",
      "TimeStop",
    }
  },
  ["Virus"] = {
    complexity = 3,
    names = {
      "Flu 1.0",
      "Flu 2.0",
      "Pneumonia 1.2",
      "Arsenic",
      "Strep 1.0",
      "BrainBugs 1.2",
      "RotWorms Mk1",
      "Cancer 2.3",
      "BedBugs",
      "Flu 10.0",
      "Pneumonia 3.1",
      "RotWorms Mk2",
      "Cancer 3.0",
      "More Bedbugs",
      "Cyanide",
      "Pneumonia 4.0",
      "RotWorms Mk2",
      "Cancer 4.0",
      "BrainBugs 3.1",
      "Ebola",
    }
  },
  ["Silence"] = {
    includeOnNewGame = true,
    complexity = 3,
    names = {
      "Silence",
      "QuietYou",
      "Gag 3.3",
      "ZipIt 1.0",
      "Muffler 2.1",
      "Shhhh!",
      "Laryngitis 2.3",
      "MouthClamp 2.1",
      "Hush 1.0",
      "QuietYou 2.0",
      "Muffler 3.0",
      "Laryngitis 3.3a",
      "QuietYou 3.0",
      "Hush 2.0",
      "Shhhh! II",
      "Muffler 4.0",
      "QuietYou 4.1",
      "Laryngitis 4.02",
      "ZipIt 2.1",
      "MegaMute",
    }
  },
  ["Confuse"] = {
    complexity = 4,
    names = {
      "Confusion",
      "Duh? 12.3",
      "Gremlins",
      "Gremlins II",
      "LSD 4.1",
      "Duh? 192.334",
      "Lobotomy 1.0",
      "Duh? 3.14159",
      "LSD 5.0",
      "Fermat's Theorem",
      "Lobotomy 2.0",
      "Gump 2.3",
      "BrainFry 1.0",
      "Gremlins III",
      "Lobotomy 3.0",
      "Gump 3.1",
      "BrainFry 2.1",
      "Psychadelicious",
      "Lobotomy 4.0",
      "DanQuayle",
    }
  },
  ["Weaken"] = {
    complexity = 2,
    names = {
      "Weaken",
      "WussyBoy 2.0",
      "Shrink 1.0",
      "Hamstring 1.2",
      "WussyBoy 2.3a",
      "Decrepify Mk1",
      "Soften",
      "Shrink 2.0",
      "Weinee 1.0",
      "GirlyMan 1.0",
      "YouPansy 1.0",
      "Nausea 3.2",
      "Decrepify Mk2",
      "Tenderize",
      "Hamstring 2.2",
      "Decrepify Mk3",
      "GirlyMan 3.2",
      "Weinee 2.0",
      "Sap",
      "Impotence",
    }
  },
  ["Shield"] = {
    complexity = 3,
    names = {
      "Shield",
      "Buckler 1.1a",
      "Umbrella 1.0",
      "Shield Mk2",
      "Blocker 1.0",
      "Bumper",
      "Airbag 1.0",
      "Blocker 2.0",
      "Shield Mk3",
      "Buckler 2.3",
      "Airbag 2.0",
      "Umbrella 3.0",
      "ForceField 1.0",
      "Buckler 3.0",
      "Shield Mk4",
      "Airbag 3.0",
      "Buckler 3.2c",
      "ForceField 2.0",
      "Blocker 7.0",
      "Aegis",
    }
  },
  ["Smoke"] = {
    includeOnNewGame = true,
    complexity = 1,
    names = {
      "Smoke",
      "Blind 1.0",
      "Darkness 1.1",
      "Distraction 1.1",
      "Escape! 1.2",
      "Fog",
      "Smog",
      "Blind 2.1",
      "Sandstorm",
      "Distraction 2.0",
      "ECM 1.0",
      "Flashbang 1.0",
      "Blind 3.2",
      "Distraction 3.0",
      "WhereDidHeGo?",
      "Blind 3.7",
      "Flashbang 2.0",
      "Distraction 4.1",
      "Blind 4.0a",
      "Houdini",
    }
  },
  ["Decoy"] = {
    complexity = 4,
    names = {
      "Decoy",
      "MirrorImage 1.0",
      "MyBuddy 1.0",
      "StandIn 1.0",
      "Twins 2.0",
      "BodyDouble 1.3",
      "MirrorImage 2.0",
      "Mitosis 1.02",
      "StandIn 2.0",
      "Clone 1.2",
      "MyBuddy 2.0",
      "BodyDouble 2.1",
      "MirrorImage 3.0",
      "Clone 2.0",
      "Mitosis 1.3",
      "Clone 2.21",
      "MirrorImage 4.0",
      "BodyDouble 3.2",
      "StandIn 4.1",
      "Simulacrum",
    }
  },
  ["Medic"] = {
    includeOnNewGame = true,
    complexity = 4,
    names = {
      "Medic",
      "FirstAid 1.0",
      "VirtualEMT",
      "Bandage 1.0",
      "Tourniquet 2.2",
      "VirtualNurse",
      "FirstAid 2.4d",
      "MedKit 1.0",
      "Restoration",
      "Succor 1.0",
      "Bandage 2.30",
      "VirtualDoctor",
      "Restoration II",
      "Succor 2.01",
      "Bandage 4.1",
      "Restoration III",
      "Succor 3.2",
      "Restoration IV",
      "VirtualSurgeon",
      "M.A.S.H",
    }
  },
  ["Armor"] = {
    includeOnNewGame = true,
    complexity = 3,
    names = {
      "Armor",
      "StoneSkin 1.0",
      "ChainMail",
      "SteelPlate 1.2",
      "Protector 1.2",
      "Kevlar 2.0",
      "Protector 2.3a",
      "SteelPlate 2.1",
      "Kevlar 3.0",
      "StoneSkin 2.0",
      "PlateMail",
      "Kevlar 4.1",
      "Mithril",
      "SteelPlate 3.1",
      "StoneSkin 3.0",
      "Titanium",
      "Mithril II",
      "Titanium Mk2",
      "StoneSkin 4.0",
      "Adamantium",
    }
  },
  ["Hide"] = {
    includeOnNewGame = true,
    complexity = 3,
    names = {
      "Hide",
      "IgnoreMe 1.0",
      "Cloak",
      "Chameleon 1.0",
      "Hide Mk2",
      "Camoflauge 2.1",
      "IgnoreMe 2.0",
      "Inviso",
      "IgnoreMe 2.2a",
      "Camoflauge 3.0",
      "Inviso II",
      "Chameleon 2.1",
      "IgnoreMe 3.02",
      "Camoflauge 4.1",
      "Inviso III",
      "Enhanced Cloak",
      "IgnoreMe 4.1",
      "Hide Mk5",
      "SuperCloak",
      "HollowMan",
    }
  },
  ["Deceive"] = {
    includeOnNewGame = true,
    complexity = 2,
    names = {
      "Deceive",
      "PassGen 2.0",
      "LiarLiar 1.02",
      "FakeOut 3.1",
      "MistakenID 1.2",
      "Masquerade",
      "Costume 2.1",
      "Passport 3.1",
      "Masquerade III",
      "PassGen 3.0",
      "FakeOut 3.2",
      "Masquerade IV",
      "LiarLiar 2.11",
      "Forge 1.0",
      "Costume 3.2",
      "PassGen 4.0",
      "Masquerade VI",
      "Forge 2.0",
      "Forge 2.3a",
      "Politician",
    }
  },
  ["Relocate"] = {
    complexity = 2,
    names = {
      "Relocate",
      "ImGone 1.1",
      "Misdirect 1.0a",
      "WildGooseChase 1.31",
      "TraceBuster 1.0",
      "WrongNumber 1.3",
      "Mislead 1.0",
      "ImGone 2.0",
      "LineSwitch 9.0",
      "Loopback 10.0",
      "WildGooseChase 2.03",
      "Misdirect 2.3b",
      "Mislead 2.0",
      "TraceBuster 2.0",
      "WrongNumber 2.1",
      "RedHerring",
      "Misdirect 3.1a",
      "RedHerring II",
      "TraceBuster 3.0",
      "Trail-B-Gone",
    }
  },
  ["Analyze"] = {
    includeOnNewGame = true,
    complexity = 1,
    names = {
      "Analyze",
      "WhatzIt 1.0",
      "Encyclopedia",
      "Identify 1.0.1",
      "Classify 1.0",
      "Taxonomy 3.0",
      "Autopsy",
      "Classify 2.0",
      "WhatzIt 2.0",
      "Identify 2.1.1",
      "Microscope 1.0",
      "Enhanced Analyze",
      "Taxonomy 5.0",
      "Identify 2.2.0",
      "WhatzIt 3.0",
      "Microscope 3.0",
      "Taxonomy 7.0",
      "WhatzIt 3.2",
      "Identify 3.0.3",
      "Forensics",
    }
  },
  ["Scan"] = {
    includeOnNewGame = true,
    complexity = 1,
    names = {
      "Scan",
      "FindIt 1.0",
      "NodeSearch 1.2",
      "FindIt 2.0",
      "Detective 1.3",
      "Sherlock 1.1",
      "Flashlight Mk1",
      "FindIt 3.0",
      "NodeSearch 2.0",
      "FindIt 4.0",
      "Snoopy 1.0",
      "Detective 3.1",
      "Flashlight Mk2",
      "NodeSearch 3.1",
      "Snoopy 2.0",
      "Detective 3.5",
      "Sherlock 3.1",
      "Flashlight Mk3",
      "Snoopy 3.0",
      "SuperScan",
    }
  },
  ["Evaluate"] = {
    includeOnNewGame = true,
    complexity = 1,
    names = {
      "Evaluate",
      "Priceless 1.0",
      "Divine",
      "BlueBook 1.0",
      "ValueSoft 1.0",
      "Evaluate Mk2",
      "GoldDigger",
      "Priceless 2.0",
      "BlueBook 2.1",
      "Priceless 2.1",
      "Peruse 1.0",
      "Appraise 1.0",
      "Evaluate Mk3",
      "BlueBook 3.0",
      "Priceless 3.0",
      "ValueSoft 7.0",
      "GoldDigger II",
      "Evaluate Mk4",
      "BlueBook 4.0a",
      "ShowMeTheMoney",
    }
  },
  ["Decrypt"] = {
    includeOnNewGame = true,
    complexity = 2,
    names = {
      "Decrypt",
      "SolveIt 2.0",
      "CodeBreaker 1.1",
      "Descramble",
      "WormKiller 1.2",
      "Untangle",
      "SolveIt 3.0",
      "Decrypt II",
      "CodeBreaker 2.2",
      "WormKiller 1.7",
      "Descramble 95",
      "SolveIt 4.0",
      "Untangle Mk2",
      "WormKiller 2.1",
      "Decrypt III",
      "Descramble 98",
      "CodeBreaker 3.4",
      "SolveIt 6.0",
      "Decrypt IV",
      "SuperCracker",
    }
  },
  ["Reflect"] = {
    complexity = 4,
    names = {
      "Reflect",
      "ImRubber 1.1",
      "Reflect Mk2",
      "BounceBack",
      "Reflect Mk3",
      "ImRubber 2.1",
      "Reflect Mk4",
      "ImRubber 3.0",
      "BounceBackEx",
      "Deflector I",
      "Reflect Mk5",
      "BounceBackDeluxe",
      "ImRubber 3.4",
      "Deflector II",
      "ImRubber 4.2",
      "Deflector III",
      "BounceBackPremium",
      "Deflector IV",
      "BounceBackSupreme",
      "Trampoline",
    }
  },
  ["Attack Boost"] = {
    complexity = 3,
    names = {
      "Attack Boost 1.0",
      "Attack Boost 1.1",
      "Attack Boost 1.2",
      "Attack Boost 1.3",
      "Attack Boost 1.4",
      "Attack Boost 1.5",
      "Attack Boost 2.0",
      "Attack Boost 2.1",
      "Attack Boost 2.2",
      "Attack Boost 2.3",
      "Attack Boost 3.1",
      "Attack Boost 3.2",
      "Attack Boost 3.3",
      "Attack Boost 3.4",
      "Attack Boost 4.1",
      "Attack Boost 4.2",
      "Attack Boost 4.3",
      "Attack Boost 5.0",
      "Attack Boost 5.1",
      "Attack Boost 6.0",
    }
  },
  ["Defense Boost"] = {
    complexity = 3,
    names = {
      "Defense Boost 1.0",
      "Defense Boost 1.1",
      "Defense Boost 1.2",
      "Defense Boost 1.3",
      "Defense Boost 1.4",
      "Defense Boost 1.5",
      "Defense Boost 2.0",
      "Defense Boost 2.1",
      "Defense Boost 2.2",
      "Defense Boost 2.3",
      "Defense Boost 3.1",
      "Defense Boost 3.2",
      "Defense Boost 3.3",
      "Defense Boost 3.4",
      "Defense Boost 4.1",
      "Defense Boost 4.2",
      "Defense Boost 4.3",
      "Defense Boost 5.0",
      "Defense Boost 5.1",
      "Defense Boost 6.0",
    }
  },
  ["Stealth Boost"] = {
    complexity = 3,
    names = {
      "Stealth Boost 1.0",
      "Stealth Boost 1.1",
      "Stealth Boost 1.2",
      "Stealth Boost 1.3",
      "Stealth Boost 1.4",
      "Stealth Boost 1.5",
      "Stealth Boost 2.0",
      "Stealth Boost 2.1",
      "Stealth Boost 2.2",
      "Stealth Boost 2.3",
      "Stealth Boost 3.1",
      "Stealth Boost 3.2",
      "Stealth Boost 3.3",
      "Stealth Boost 3.4",
      "Stealth Boost 4.1",
      "Stealth Boost 4.2",
      "Stealth Boost 4.3",
      "Stealth Boost 5.0",
      "Stealth Boost 5.1",
      "Stealth Boost 6.0",
    }
  },
  ["Analysis Boost"] = {
    complexity = 3,
    names = {
      "Analysis Boost 1.0",
      "Analysis Boost 1.1",
      "Analysis Boost 1.2",
      "Analysis Boost 1.3",
      "Analysis Boost 1.4",
      "Analysis Boost 1.5",
      "Analysis Boost 2.0",
      "Analysis Boost 2.1",
      "Analysis Boost 2.2",
      "Analysis Boost 2.3",
      "Analysis Boost 3.1",
      "Analysis Boost 3.2",
      "Analysis Boost 3.3",
      "Analysis Boost 3.4",
      "Analysis Boost 4.1",
      "Analysis Boost 4.2",
      "Analysis Boost 4.3",
      "Analysis Boost 5.0",
      "Analysis Boost 5.1",
      "Analysis Boost 6.0",
    }
  },
  ["Client Software"] = {
    clientOnly = true,
    complexity = 4,
    names = {
      "Client Supplied Software"
    }
  },

}

--[[ Gets the definition for the class underlying this software ]]
function Software:getType(sw)
  local def = self.types[sw.class]
  if not def then
    error( "No software class definition found for %q", sw.class)
  end
  return def
end

-- Get the potential rating.
function Software:getPotentialRating(entity)
  return entity.potentialRating
end

-- Get the active (current) rating.
function Software:getActiveRating(entity)
  return entity.activeRating
end

-- load time is dependent on your hardware bus and node speed.
function Software:getLoadTime(entity, inActivatedHighSpeedNode, playerBandwidthRate)

  -- If have a high-speed connection, time is 1 turn.
  if inActivatedHighSpeedNode == true then
    return 1
  end

  -- Time is size / (2^(bus size))
  local mp = self:getMemoryUsage(entity)
  local speed = 2^playerBandwidthRate
  local loadtime = math.floor((mp + speed - 1) / speed)

  -- clamp to 1 for lowest value
  return math.max(1, loadtime)

end

function Software:getMemoryUsage(sw)
  local def = self:getType(sw)
  return def.complexity * sw.potentialRating
end

function Software:getDefaultName(sw)
  local def = self:getType(sw)
  return def.names[sw.potentialRating]
end

function Software:getPrice(sw)
  local def = self:getType(sw)
  return def.complexity * sw.potentialRating^2 * 25;
end

function Software:getText(sw)
  return string.format("%s (%s %d)", sw.name, sw.class, sw.potentialRating)
end

-- Can load if not loaded already and no load turns are set.
function Software:canLoad(entity)
  return not entity.loaded and entity.loadTurns == 0
end

-- Is loaded and ready for use
function Software:isLoaded(entity)
  return entity.loaded
end

-- Is loading when there are load turns left
function Software:isLoading(entity)
  return entity.loadTurns > 0
end

-- Crashes when loaded and the active rating drops to zero or below
function Software:hasCrashed(entity)
  return entity.loaded and entity.activeRating < 1
end

function Software:beginLoad(entity, inActivatedHighSpeedNode, playerBandwidthRate)
  -- TODO check if the deck won't overload
  -- TODO check how many other programs are loading, and if we have
  --      the memory to load this one asynchronously
  if self:canLoad(entity) then
    entity.loadTurns = self:getLoadTime(entity, inActivatedHighSpeedNode, playerBandwidthRate)
  end
end

-- Update the entity state at the end of the player's turn.
function Software:update(entity)
  if self:isLoading(entity) then
    entity.loadTurns = entity.loadTurns - 1
    if entity.loadTurns == 0 then
      entity.loaded = true
      entity.activeRating = entity.potentialRating
      -- TODO send message for program loaded
    end
  else
    -- test if the program has crashed
    if self:hasCrashed(entity) then
      entity.loaded = false
      entity.activeRating = 0
      -- TODO send message for program crashed
    end
  end
end

function Software:updateAll(softwarelist)
  -- TODO loop through all software and update
  --- pseudocode:
  for k,v in softwarelist do
    self:update(v)
  end
end

return Software
