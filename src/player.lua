--[[
   This program is free Player: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Player Foundation, either version 3 of the License, or
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see http://www.gnu.org/licenses/.
]]--

--- An interface to manage the player.
-- @author Wesley Werner
-- @license GPL v3
local Player = {}

Player.MAXHEALTH = 20

--- A lookup list of all the lifestyles available.
-- @table lifestyles
-- @tfield number cost
-- @tfield string text
Player.lifestyles = {
  {
    ["cost"] = 500,
    ["text"] = "Poverty"
  },
  {
    ["cost"] = 1000,
    ["text"] = "Lower Class"
  },
  {
    ["cost"] = 2000,
    ["text"] = "Middle Class"
  },
  {
    ["cost"] = 4000,
    ["text"] = "Upper Class"
  },
  {
    ["cost"] = 10000,
    ["text"] = "Elite"
  },
}

--- Create a new player instance.
-- @treturn player:instance
function Player:create()

  --- @table instance
  -- @tfield string name The player name.
  -- @tfield number credits Money owned by the player.
  -- @tfield player:lifestyle lifestyle Living data.
  -- @tfield player:health health Health data.
  -- @tfield player:reputation reputation
  -- @tfield player:skills skills
  -- @tfield player:corporations corporations
  -- @tfield player:hardware hardware
  -- @tfield player:software software
  -- @tfield player:chips chips
  -- @tfield player:load load
  -- @tfield player:contract contract
  -- @tfield player:sourcecode sourcecode
  -- @tfield player:order order

  local instance = {}
  instance.name = "Hacker X"
  instance.credits = 0

  --- The player's current lifestyle information.
  -- One of @{player.lifestyles}
  -- @table lifestyle
  -- @tfield number level Current lifestyle level.
  -- @tfield string text Current lifestyle title.
  instance.lifestyle = {
    ["level"] = 1,
    ["text"] = ""
  }

  --- Player mental, physical and deck health information.
  -- Mental and deck health resets to max when entering the matrix.
  -- Physical health only gets restored through rest or hospital visits.
  -- @table health
  -- @tfield number physical Death occurs when this drops to zero.
  -- @tfield number mental Player falls unconscious when this drops
  -- below zero, and negative values carry over to physical health.
  -- Lethal @{ice} does mental damage instead of deck damage.
  -- @tfield number deck Deck health inside the matrix.
  -- This value is reduced when attacked by @{ice}, and restored by
  -- the Medic @{software}.
  instance.health = {
    ["physical"] = self.MAXHEALTH,
    ["mental"] = 0,
    ["deck"] = 0
  }

  --- Player reputation information.
  -- @table reputation
  -- @tfield number level Reputation level.
  -- @tfield number points Accumulated reputation points that
  -- determines the current level of reputation. Adjusted via
  -- @{player:alterReputation}.
  -- @tfield string text Descriptive title.
  instance.reputation = {
    ["level"] = 1,
    ["points"] = 0,
    ["text"] = ""
  }

  --- Table of player skills.
  -- The player earns points completing missions, and spend points
  -- to improve skills.
  -- @table skills
  -- @tfield number points Amount of skill points available to spend.
  -- @tfield number attack Affects attack rating.
  -- @tfield number defense Affects defense rating.
  -- @tfield number stealth Affects stealth rating.
  -- @tfield number analysis Affects analysis rating.
  -- @tfield number chipdesign Affects chip design rating.
  instance.skills = {
    ["points"] = 0,
    ["attack"] = 1,
    ["defense"] = 1,
    ["stealth"] = 1,
    ["analysis"] = 1,
    ["programming"] = 1,
    ["chipdesign"] = 1,
  }

  instance.reputation.text = self:getReputationText(instance)
  instance.lifestyle.text = self:getLifestyleText(instance)

  --- List of corporations visited, stores alert status and backdoors installed.
  -- @table corporations
  instance.corporations = {}

  --- List of hardware owned.
  -- @table hardware
  instance.hardware = {}

  --- List of software owned.
  -- @table software
  instance.software = {}

  --- List of chips installed in the deck.
  -- @table chips
  instance.chips = {}

  --- Deck load information.
  -- @table load
  instance.load = {
    ["current"] = 0,
    ["status"] = ""
  }

  --- current contract information.
  -- @table contract
  instance.contract = {}

  --- Source code information.
  -- Source code owned by the player is stored in their repository.
  -- The project tracks progress of a current development effort on new code.
  -- Cooking tracks progress of a chip being burned.
  -- @table sourcecode
  -- @tfield table repository List of owned source code.
  -- @tfield sourcecode project Tracks current development effort on code.
  -- @tfield sourcecode cooking Tracks the source of the chip being cooked.
  instance.sourcecode = {
    ["repository"] = {},
    ["project"] = nil,
    ["cooking"] = nil
  }

  --- Shop item on special order.
  -- @table order
  instance.order = {}

  --- Game world date as the number of seconds since the epoch.
  -- Get the readable date with os.date("%c", instance.date)
  -- and forward it by a day with +(60*60*24).
  instance.date = os.time({year=2150, month=1, day=1})

  --- We are in the matrix
  instance.onRun = false

  --- A red alert was triggered (gets reset each time entering the matrix)
  -- m_dwRunFlags in original source
  instance.alertTriggered = false

  -- tracks damage done to the player during a turn in the matrix.
  -- I feel these will be better placed in the turn logic, if possible.
  --int m_nDamageMental;
  --int m_nDamageDeck;

  --- Matrix system we are in
  instance.system = nil

  --- Matrix node we are in
  instance.node = nil

  --- targetted ICE
  instance.targetICE = nil

  --- tracks the highest rated ICE that was deceived.
  -- this is reset each time a node is entered, or the last ICE exits your node.
  -- surely there is a better place to store this, with a shorter name.
  instance.highestRatedICEDeceived = nil



  return instance

end

--- Get the player name.
-- @tparam player:instance player
function Player:getName(player)
  return player.name
end

--- Prepare the player to enter the matrix.
-- This resets the player mental and deck health to max.
-- @tparam player:instance player
function Player:prepareForMatrix(player)
  player.health.mental = self.MAXHEALTH
  player.health.deck = self.MAXHEALTH
end

--- Get the player's credit balance.
-- @tparam player:instance player
function Player:getCredits(player)
  return player.credits
end

--- Increase credits.
-- @tparam player:instance player
-- @tparam number amount The amount of credits to add.
function Player:addCredits(player, amount)
  player.credits = player.credits + amount
end

--- Spend credits.
-- @tparam player:instance player
-- @tparam number amount The amount of credits to spend.
-- @treturn bool true if credits are spent, false if not enough credits
-- available for spending the requested amount.
function Player:spendCredits(player, amount)
  if player.credits < amount then
    return false
  else
    player.credits = player.credits - amount
    return true
  end
end

--- Add hardware to the player inventory.
-- If the player already own the hardware at a lower rating, it is
-- sold for a second-hand price.
-- @tparam player:instance player
-- @tparam hardware:instance hardware The hardware to add.
-- @treturn bool true on success,
-- false if the player owns the same or a higher rated version already.
function Player:addHardware(player, hardware)
  local HWModule = require("hardware")

  -- check for existing of the same class
  local existing = self:findHardwareByClass(player, hardware.class)
  if existing then
    local currentRating = HWModule:getRating(existing)
    local proposedRating = HWModule:getRating(hardware)
    -- remove existing if lower rated
    if currentRating < proposedRating then
      self:removeHardware(player, existing)
    else
      -- TODO send message: You already own that hardware at the same or higher rating
      return false
    end
  end

  -- resell old hardware
  if existing then
    local value = HWModule:getResellPrice(existing)
    self:removeHardware(player, existing)
    self:addCredits(player, value)
    -- TODO send message: You sold your old hardware for %dcr
  end

  -- add the new hardware
  table.insert(player.hardware, hardware)
  return true
end

--- Remove hardware from the player inventory.
-- @tparam player:instance player
-- @tparam hardware:instance hardware The hardware to remove.
-- @treturn bool true on successful removal.
function Player:removeHardware(player, hardware)
  for i,v in ipairs(player.hardware) do
    if v == hardware then
      table.remove(player.hardware, i)
      return true
    end
  end
end

--- Find owned hardware by class.
-- @tparam player:instance player
-- @tparam string class The class of hardware to find.
-- @treturn hardware:instance or nil if no match found.
function Player:findHardwareByClass(player, class)
  for i,v in ipairs(player.hardware) do
    if v.class == class then
      return v
    end
  end
end

--- Find rating of owned hardware by class.
-- This is similar to calling @{player:findHardwareByClass} to get the
-- rating with nil checking.
-- @tparam player:instance player
-- @tparam string class The class of hardware to find.
-- @treturn number The rating of the hardware owned, or 0 if no match found.
function Player:findHardwareRatingByClass(player, class)
  local ware = self:findHardwareByClass(player, class)
  return ware and ware.rating or 0
end

--- Add software to the player inventory.
-- @tparam player:instance player
-- @tparam software:instance software The software to add.
-- @treturn bool true on success,
-- false if the player owns the same or a higher rated version already.
function Player:addSoftware(player, software)
  local SWModule = require("software")

  -- check for existing of the same class
  local existing = self:findSoftwareByClass(player, software.class)
  if existing then
    local currentRating = SWModule:getPotentialRating(existing)
    local proposedRating = SWModule:getPotentialRating(software)
    -- remove existing if lower rated
    if currentRating < proposedRating then
      self:removeSoftware(player, existing)
    else
      -- TODO send message: You already own that software at the same or higher rating
      return false
    end
  end

  table.insert(player.software, software)
  return true
end

--- Remove software from the player inventory.
-- @tparam player:instance player
-- @tparam software:instance software The software to add.
-- @treturn bool true on success.
function Player:removeSoftware(player, software)
  for i,v in ipairs(player.software) do
    if v == software then
      table.remove(player.software, i)
      return true
    end
  end
end

--- Find owned software by class.
-- @tparam player:instance player
-- @tparam string class The class of software to find.
-- @treturn software:instance or nil if no match found.
function Player:findSoftwareByClass(player, class)
  for i,v in ipairs(player.software) do
    if v.class == class then
      return v
    end
  end
end

--- Add a chip to the player inventory.
-- Any lower rated version if the same chip class is removed if owned.
-- @tparam player:instance player
-- @tparam chip:instance chip The chip to add.
-- @treturn bool true on success,
-- false if the player owns the same or a higher rated version already.
function Player:addChip(player, chip)
  -- check for existing of the same class
  local CHModule = require("chips")
  local existing = self:findChipByClass(player, chip.class)
  if existing then
    local currentRating = CHModule:getRating(existing)
    local proposedRating = CHModule:getRating(chip)
    -- remove existing if lower rated
    if currentRating < proposedRating then
      self:removeChip(player, existing)
    else
      -- TODO send message: You already own that chip at the same or higher rating
      return false
    end
  end
  table.insert(player.chips, chip)
  return true
end

--- Remove a chip from the player inventory.
-- @tparam player:instance player
-- @tparam chip:instance chip The chip to remove.
-- @treturn bool true on success,
-- false if the chip is not owned by the player.
function Player:removeChip(player, chip)
  for i,v in ipairs(player.chips) do
    if v == chip then
      table.remove(player.chips, i)
      return true
    end
  end
  return false
end

--- Find owned chip by class.
-- @tparam player:instance player
-- @tparam string class The class of chip to find.
-- @treturn chip:instance or nil if no match found.
function Player:findChipByClass(player, class)
  for i,v in ipairs(player.chips) do
    if v.class == class then
      return v
    end
  end
end

--- Get the total skill points available for spending.
-- @tparam player:instance player
-- @treturn number Skill points free for spending.
function Player:getSkillPoints(player)
  return player.skills["points"]
end

--- Add skill points to the player that they can spend.
-- @tparam player:instance player
-- @tparam number amount Skill points to add.
function Player:addSkillPoints(player, amount)
  local skills = player.skills
  skills["points"] = skills["points"] + amount
end

--- Increase one of the player skills.
-- The cost to increase a skill equals the current skill's level.
-- @tparam player:instance player
-- @tparam string class The skill class to increase.
-- One of @{player:skills}.
-- @treturn bool true on success,
-- false if not enough points are available
function Player:spendSkillPoints(player, class)
  local skills = player.skills
  if not skills[class] then
    error(string.format("%q is not a valid skill class", class))
  end
  local points = skills["points"]
  local cost = self:getSkillLevel(player, class)
  if cost > points then
    return false
  else
    skills["points"] = skills["points"] - cost
    skills[class] = skills[class] + 1
    return true
  end
end

--- Get a skill level.
-- @tparam player:instance player
-- @tparam string class The skill class to query.
-- @treturn number The skill level.
function Player:getSkillLevel(player, class)
  local skills = player.skills
  if not skills[class] then
    error(string.format("%q is not a valid skill class", class))
  else
    return skills[class]
  end
end

--- Alter the player's reputation with positive or negative points.
-- This function applies the given points and properly adjusts the
-- player reputation level and descriptive text. Negative points will
-- subtract from reputation.
-- Reputation is limited to 4 * the player's lifestyle level.
-- @tparam player:instance player
-- @tparam number points The amount of points to apply, positive or negative.
function Player:alterReputation(player, points)

  -- alias variable for ease of use
  local rep = player.reputation

  -- apply the points
  rep.points = rep.points + points
  rep.points = math.max(0, rep.points)

  -- calculator for points needed per reputation level
  local calcPointsForLevel = function(level)
    return math.floor((5 * level * (level+1)) / 2)
  end

  -- adding points can upgrade the reputation level
  if points > 0 then

    -- Reputation level is limited by your lifestyle
    local maxLevelPerLifestyle = player.lifestyle.level * 4

    if rep.level >= maxLevelPerLifestyle then
      --print("max points reached for lifestyle")
      -- TODO message that max reputation is reached for this lifestyle
      return false
    end

    -- Check if we have enough points to move to the next level
    local pointsToUpgrade = calcPointsForLevel(rep.level+1)
    --print("need " .. pointsToUpgrade .. " has " .. rep.points)

    if rep.points >= pointsToUpgrade then
      rep.level = rep.level + 1
      --print("leveled up")
      -- TODO message that our reputation has increased
    end

  end

  -- subtracting points can reduce the reputation level
  -- if the player has reputation to lose.
  if points < 0 and rep.level > 1 then

    local pointsToSustainLevel = calcPointsForLevel(rep.level)

    if rep.points < pointsToSustainLevel then
      rep.level = rep.level - 1
      --print("not enough points to sustain level")
      -- TODO message that reputation was reduced
    end

  end

  rep.text = self:getReputationText(player)

end

--- Get the reputation title of the player.
-- This function used internally by the player module when
-- @{Player:alterReputation} is called. The reputation title can
-- be read from the @{player.reputation} table instead.
-- @tparam player:instance player
-- @treturn string The reputation title text.
function Player:getReputationText(player)
  local reputations = {
    "Nobody",
    "Wannabe",
    "Cyber Surfer",
    "Matrix Runner",
    "Newbie Hacker",
    "Journeyman Hacker",
    "Competent Hacker",
    "Experienced Hacker",
    "Hacker Extraordinaire",
    "Cyber Thief",
    "Cyber Sleuth",
    "Cyber Warrior",
    "Cyber Wizard",
    "Ice Crusher",
    "Node Master",
    "System Master",
    "Ghost in the Machine",
    "Digital Dream",
    "Digital Nightmare",
    "Master of the Matrix",
    "Matrix God",
  }
  if player.reputation.level > #reputations then
    return reputations[#reputations]
  else
    return reputations[player.reputation.level]
  end
end

--- Get the cost for the player's current lifestyle, aka the monthly rent.
-- @tparam player:instance player
-- @tparam[opt] bool nextlevel Pass true to calculate the cost for the
-- next lifestyle up from the player's current.
-- @treturn number The cost of monthly rent.
function Player:getLifestyleCost(player, nextlevel)

  local level = player.lifestyle.level

  if nextlevel == true then
    level = level + 1
  end

  if level > #self.lifestyles then
    return self.lifestyles[#self.lifestyles].cost
  else
    return self.lifestyles[level].cost
  end

end

--- Get the cost to upgrade to the next lifestyle level.
-- @tparam player:instance player
-- @treturn number The upgrade cost.
function Player:getLifestyleUpgradeCost(player)
  return self:getLifestyleCost(player, true) * 3
end

--- Upgrade to the next lifestyle level.
-- @see getLifestyleUpgradeCost
-- @see getCredits
-- @tparam player:instance player
-- @treturn bool true on success,
-- false if the player does not have enough credits to upgrade.
function Player:upgradeLifestyle(player)
  local cost = self:getLifestyleUpgradeCost(player)
  if player.credits >= cost then
    player.credits = player.credits - cost
    player.lifestyle.level = player.lifestyle.level + 1
    player.lifestyle.text = self:getLifestyleText(player)
    -- TODO message that lifestyle has been upgraded
    return true
  end
  return false
end

--- Downgrade to a lower lifestyle level.
-- @tparam player:instance player
-- @treturn bool true on success,
-- false if the player's lifestyle is already at the lowest level.
function Player:downgradeLifestyle(player)
  if player.lifestyle.level > 1 then
    player.lifestyle.level = player.lifestyle.level - 1
    player.lifestyle.text = self:getLifestyleText(player)
    -- TODO message that lifestyle has been downgraded
    return true
  else
    -- downgrade is not possible
    return false
  end
end

--- Get the current lifestyle title.
-- This function is used internally in this module
-- by the @{upgradeLifestyle} and @{downgradeLifestyle} functions.
-- The lifestyle title can be read via the @{player:lifestyle} table.
-- @tparam player:instance player
-- @treturn string The descriptive lifestyle title.
function Player:getLifestyleText(player)
  if player.lifestyle.level > #self.lifestyles then
    return self.lifestyles[#self.lifestyles].text
  else
    return self.lifestyles[player.lifestyle.level].text
  end
end

--- Add source code to the player inventory.
-- @tparam player:instance player
-- @tparam sourcecode sourcecode The source code to add.
function Player:addSourcecode(player, sourcecode)
  table.insert(player.sourcecode.repository, sourcecode)
end

--- Find owned source code by class.
-- @tparam player:instance player
-- @tparam string class The class of the source code to find.
-- @treturn sourcecode or nil if no match is found.
function Player:findSourceByClass(player, class)
  for k, source in pairs(player.sourcecode.repository) do
    if source.class == class then
      return source
    end
  end
end

--- Get the chip currently cooking.
-- A chip is cooked from source code with a chip burner @{hardware}.
-- @see sourcecode:build
-- @tparam player:instance player
-- @treturn sourcecode
function Player:getCookingChip(player)
  return player.sourcecode.cooking
end

return Player
