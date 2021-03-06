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

--- An interface to manage software for your deck.
-- Software is loaded into your deck when you enter the matrix.
-- It provides much needed features to complete missions.
-- @author Wesley Werner
-- @license GPL v3
local Software = {}

--- Create a new software instance.
--
-- @tparam string class
--   The class determines the behaviour and function.
--   One of @{software.types}.
--
-- @tparam number rating
--   Effectiveness of the software, also determines
--   the market price, and memory usage when running in the deck.
--   The value given here is saved as the potentialRating
--   and is used to restore the software rating to full when it is
--   loaded into the deck.
--   In contrast the activeRating is the value to watch,
--   it reflects the current rating which can fluctuate during play,
--   notably from being used.
--
-- @tparam[opt] string name
--   A descriptive title for the software. A default name is selected
--   if not given, or given as nil.
--
-- @treturn software.instance
function Software:create(class, rating, name)

  -- validate the given values
  local typeDefinition = self:getType(class)
  if not typeDefinition then
    error(string.format("No software class definition found for %q", class))
  end

  if not rating or rating < 1 then
    error (string.format("%q is not a valid rating for software.", rating or "nil" ))
  end

  --- The instance definition received from calling @{create}.
  -- @table instance
  --
  -- @tfield string class
  --   The software class name.
  --
  -- @tfield number rating
  --   The software rating.
  --
  -- @tfield number potentialRating
  --   The maximum allowed potential rating possible.
  --   This value is set from the rating given to @{software:create}.
  --
  -- @tfield number activeRating
  --   The effective rating while in the matrix.
  --   It will equal potential rating when (re)loaded into the deck.
  --   It can fluctuate while in the matrix.
  --   The "Medic" software for example
  --   decreases rating on each use, until it hits zero and crashes.
  --
  -- @tfield number loadTurns
  --   Turns remaining until the software is loaded in the deck.
  --
  -- @tfield bool loaded
  --   The application is loaded in the deck and ready to use.
  --   Used internally by @{software:isLoading} and @{software:isLoaded}.
  --
  -- @tfield bool background
  --   The program does not require execution by the player, it runs
  --   in the background and is used automatically in certain events.
  --   The shield and hide programs for example.
  --
  -- @see software:update

  local instance = {}
  instance.class = class
  instance.potentialRating = math.floor(rating)
  instance.name = name or self:getDefaultName(instance)
  instance.activeRating = 0
  instance.loadTurns = 0
  instance.loaded = false
  instance.background = false
  return instance

end

--- A table of available software types.
-- Each type is identified by a class name.
-- The list of software classes are: Attack, Area Attack, Piercing Attack, Slow,
-- Virus, Silence, Confuse, Weaken, Shield, Smoke, Decoy, Medic, Armor, Hide,
-- Deceive, Relocate, Analyze, Scan, Evaluate, Decrypt, Reflect, Attack Boost,
-- Defense Boost, Stealth Boost, Analysis Boost, Client Software.
--
-- @table types
--
-- @tfield string class
--   Software class name.
--
-- @tfield number complexity
--   Affects the software price and memory usage.
--
-- @tfield table names
--   List of predefined software titles, indexed to correlate
--   to the software rating.
--
-- @tfield bool includeOnNewGame
--   The player starts with this software.
--
-- @tfield bool clientOnly
--   Only available as a client supplied program
--   i,e. not for sale in the @{shop}.
Software.types = {
  {
    class = "Attack",
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
  {
    class = "Area Attack",
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
  {
    class = "Piercing Attack",
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
  {
    class = "Slow",
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
  {
    class = "Virus",
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
  {
    class = "Silence",
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
  {
    class = "Confuse",
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
  {
    class = "Weaken",
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
  {
    class = "Shield",
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
  {
    class = "Smoke",
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
  {
    class = "Decoy",
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
  {
    class = "Medic",
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
  {
    class = "Armor",
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
  {
    class = "Hide",
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
  {
    class = "Deceive",
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
  {
    class = "Relocate",
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
  {
    class = "Analyze",
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
  {
    class = "Scan",
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
  {
    class = "Evaluate",
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
  {
    class = "Decrypt",
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
  {
    class = "Reflect",
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
  {
    class = "Attack Boost",
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
  {
    class = "Defense Boost",
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
  {
    class = "Stealth Boost",
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
  {
    class = "Analysis Boost",
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
  {
    class = "Client Software",
    clientOnly = true,
    complexity = 4,
    names = {
      "Client Supplied Software"
    }
  },

}

--- Get the type definition.
--
-- @tparam string class
--   The class name to look up.
--
-- @treturn software.types or nil if no match is found.
function Software:getType(class)
  local def = nil
  for i,v in ipairs(self.types) do
    if v.class == class then
      def = v
    end
  end
  return def
end

--- Get the potential rating.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn number The potential rating.
function Software:getPotentialRating(software)
  return software.potentialRating
end

--- Get the active rating.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn number The active rating.
function Software:getActiveRating(software)
  return software.activeRating
end

--- Get the time required for software to load into the deck.
--  This is dependent on the owned hardware bus rating (if any)
--  and whether the player is inside a high-speed node in the matrix.
--
-- @tparam software.instance software
--   The software instance to query. The memory points of the software
--   is a factor in load time.
--
--@tparam bool inActivatedHighSpeedNode
--   Flag indicating the player is inside a high-speed node inside
--   the matrix. If true the load time is reduced to 1 turn.
--
-- @tparam bool playerBandwidthRate
--   The rating of the "High Bandwidth Bus" hardware owned by the player.
--   Speed is calculated as 2 to the power of the bus rating, it indicates
--   the factor at which software can load. No bus hardware (0 rating)
--   thus yields a speed of 1, not a very expedient rating.
--   Ideally this is found via a call to @{player:findHardwareRatingByClass}.
--
-- @treturn number The load time as the number of turns.
function Software:getLoadTime(software, inActivatedHighSpeedNode, playerBandwidthRate)

  -- If have a high-speed connection, time is 1 turn.
  if inActivatedHighSpeedNode == true then
    return 1
  end

  -- Time is size / (2^(bus size))
  local mp = self:getMemoryUsage(software)
  local speed = 2^playerBandwidthRate
  local loadtime = math.floor((mp + speed - 1) / speed)

  -- clamp to 1 for lowest value
  return math.max(1, loadtime)

end

--- Get the memory points required to load software into the deck.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn number
--
-- @see software:beginLoad
function Software:getMemoryUsage(software)
  local def = self:getType(software.class)
  return def.complexity * software.potentialRating
end

--- Get the default name for software class and rating.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn string
function Software:getDefaultName(software)
  local def = self:getType(software.class)
  return def.names[software.potentialRating]
end

--- Get the recommended market price for software by class and rating.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn number
function Software:getPrice(software)
  local def = self:getType(software.class)
  return def.complexity * software.potentialRating^2 * 25;
end

--- Get a formatted title for software.
--  Contains the name, class and potential rating.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn string
function Software:getText(software)
  return string.format("%s (%s %d)", software.name, software.class, software.potentialRating)
end

--- Get if can be loaded into the deck.
--  That is: if not already loading or loaded.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn bool
function Software:canLoad(software)
  return not self:isLoaded(software) and not self:isLoading(software)
end

--- Get if software is loaded into the deck.
--  This means it is ready for use in the matrix.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn bool
function Software:isLoaded(software)
  return software.loaded
end

--- Get if software is busy loading into the deck.
--  True while there are load turns left.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn bool
function Software:isLoading(software)
  return software.loadTurns > 0
end

--- The software has crashed.
--  A crash occurs when the active rating drops to zero or below.
--  Used internally by @{software:update} to unload crashed software.
--
-- @tparam software.instance software
--   The software instance to query.
--
-- @treturn bool
function Software:hasCrashed(software)
  return software.loaded and software.activeRating < 1
end

--- Load software into the deck.
--  This is not instant. It begins the load process, which is advanced
--  with each call to @{software:update}.
--
-- @tparam software.instance software
--   The software instance to query.
--
--@tparam bool inActivatedHighSpeedNode
--   Flag indicating the player is inside a high-speed node inside
--   the matrix. If true the load time is reduced to 1 turn.
--
-- @tparam bool playerBandwidthRate
--   The rating of the "High Bandwidth Bus" hardware owned by the player.
--
-- @treturn bool
--   true on success
--
-- @see software:getLoadTime
function Software:beginLoad(software, inActivatedHighSpeedNode, playerBandwidthRate)
  -- TODO check if the deck won't overload
  -- TODO check how many other programs are loading, and if we have
  --      the memory to load this one asynchronously
  -- TODO return values
  -- TODO send messages when load fails
  if self:canLoad(software) then
    software.loadTurns = self:getLoadTime(software, inActivatedHighSpeedNode, playerBandwidthRate)
  end
end

--- Update the software state.
--  Advance the loading of software, and unload crashed software.
--  Ideally called at the end of the player's turn.
--
-- @tparam software.instance software
--   The software instance to query.
--
function Software:update(software)
  if self:isLoading(software) then
    software.loadTurns = software.loadTurns - 1
    if software.loadTurns == 0 then
      software.loaded = true
      software.activeRating = software.potentialRating
      -- TODO send message for program loaded
    end
  else
    -- test if the program has crashed
    if self:hasCrashed(software) then
      software.loaded = false
      software.activeRating = 0
      -- TODO send message for program crashed
    end
  end
end

return Software
