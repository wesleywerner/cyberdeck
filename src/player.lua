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

local Player = {}

Player.MAXHEALTH = 20

-- The list of lifestyle levels
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

function Player:create()

  local instance = {}
  instance.name = "Hacker X"
  instance.credits = 0

  instance.lifestyle = {
    ["level"] = 1,
    ["text"] = ""
  }

  -- Mental and deck health reset when entering the matrix.
  instance.health = {
    ["physical"] = self.MAXHEALTH,
    ["mental"] = 0,
    ["deck"] = 0
  }

  -- Reputation is limited by your lifestyle*4
  instance.reputation = {
    ["level"] = 1,
    ["points"] = 0,
    ["text"] = ""
  }

  instance.skills = {
    ["points"] = 0,
    ["attack"] = 1,
    ["defense"] = 1,
    ["stealth"] = 1,
    ["analysis"] = 1,
    ["programming"] = 1,
    ["chip design"] = 1,
  }

  instance.reputation.text = self:getReputationText(instance)
  instance.lifestyle.text = self:getLifestyleText(instance)

  -- list of corporation names we visited, stores alert status and backdoors installed
  instance.corporations = {}

  -- list of chips installed in the deck
  instance.chips = {}

  -- list of hardware and software we own
  instance.hardware = {}
  instance.software = {}
  instance.chips = {}

  instance.currentLoad = 0
  instance.loadStatus = 0

  -- current contract
  instance.contract = nil

  -- source code owned
  instance.sourcecode = {}

  -- project we are working on
  instance.project = nil
  -- create project module?
  --int m_nProjectType;
  --int m_nProjectClass;
  --int m_nProjectRating;
  --int m_nProjectInitialTime;
  --int m_nProjectTimeLeft;

  -- chip burning
  instance.chipBurner = nil

  -- item on special order
  instance.order = nil

  -- Game world date as the number of seconds since the epoch.
  -- Get the readable date with os.date("%c", instance.date)
  -- and forward it by a day with +(60*60*24).
  instance.date = os.time({year=2150, month=1, day=1})

  -- if we are in the matrix
  instance.onRun = false

  -- a red alert was triggered (gets reset each time entering the matrix)
  -- m_dwRunFlags in original source
  instance.alertTriggered = false

  -- tracks damage done to the player during a turn in the matrix.
  -- I feel these will be better placed in the turn logic, if possible.
  --int m_nDamageMental;
  --int m_nDamageDeck;

  -- system and node we are inside
  instance.system = nil
  instance.node = nil

  -- targetted ICE
  instance.targetICE = nil

  -- tracks the highest rated ICE that was deceived.
  -- this is reset each time a node is entered, or the last ICE exits your node.
  -- surely there is a better place to store this, with a shorter name.
  instance.highestRatedICEDeceived = nil



  return instance

end

function Player:getName(player)
  return player.name
end

-- Reset matrix-specific values.
function Player:prepareForMatrix(player)
  player.health.mental = self.MAXHEALTH
  player.health.deck = self.MAXHEALTH
end

-- Get bank balance
function Player:getCredits(player)
  return player.credits
end

-- Increase credits
function Player:addCredits(player, amount)
  player.credits = player.credits + amount
end

-- If there are not enough credits to spend, return false.
function Player:spendCredits(player, amount)
  if player.credits < amount then
    return false
  else
    player.credits = player.credits - amount
    return true
  end
end

-- Add hardware to the player inventory.
-- If the player already own this hardware at a lower rating, it is
-- sold for a second-hand price. If the player owns a higher rated one
-- this returns false.
function Player:addHardware(player, entity)
  local hardware = require("hardware")

  -- check for existing of the same class
  local existing = self:findHardwareByClass(player, entity.class)
  if existing then
    local currentRating = hardware:getRating(existing)
    local proposedRating = hardware:getRating(entity)
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
    local value = hardware:getResellPrice(existing)
    self:removeHardware(player, existing)
    self:addCredits(player, value)
    -- TODO send message: You sold your old hardware for %dcr
  end

  -- add the new hardware
  table.insert(player.hardware, entity)
  return true
end

-- Remove hardware from the player inventory.
function Player:removeHardware(player, entity)
  for i,v in ipairs(player.hardware) do
    if v == entity then
      table.remove(player.hardware, i)
      return true
    end
  end
end

-- Find player owned hardware by class name.
function Player:findHardwareByClass(player, class)
  for i,v in ipairs(player.hardware) do
    if v.class == class then
      return v
    end
  end
end

-- Find the rating of hardware owned by the player.
-- Returns 0 if no hardware was found.
function Player:findHardwareRatingByClass(player, class)
  local ware = self:findHardwareByClass(player, class)
  return ware and ware.rating or 0
end

-- Add software to the player inventory.
-- Returns true on success.
-- Returns false if the player owns the same or higher rated version.
function Player:addSoftware(player, entity)
  local software = require("software")

  -- check for existing of the same class
  local existing = self:findSoftwareByClass(player, entity.class)
  if existing then
    local currentRating = software:getPotentialRating(existing)
    local proposedRating = software:getPotentialRating(entity)
    -- remove existing if lower rated
    if currentRating < proposedRating then
      self:removeSoftware(player, existing)
    else
      -- TODO send message: You already own that software at the same or higher rating
      return false
    end
  end

  table.insert(player.software, entity)
  return true
end

-- Remove software from the player inventory.
function Player:removeSoftware(player, entity)
  for i,v in ipairs(player.software) do
    if v == entity then
      table.remove(player.software, i)
      return true
    end
  end
end

-- Find player owned software by class name.
function Player:findSoftwareByClass(player, class)
  for i,v in ipairs(player.software) do
    if v.class == class then
      return v
    end
  end
end

-- Add a chip to the player inventory.
function Player:addChip(player, entity)
  -- check for existing of the same class
  local chips = require("chips")
  local existing = self:findChipByClass(player, entity.class)
  if existing then
    local currentRating = chips:getRating(existing)
    local proposedRating = chips:getRating(entity)
    -- remove existing if lower rated
    if currentRating < proposedRating then
      self:removeChip(player, existing)
    else
      -- TODO send message: You already own that software at the same or higher rating
      return false
    end
  end
  table.insert(player.chips, entity)
  return true
end

-- Remove a chip from the player inventory.
function Player:removeChip(player, entity)
  for i,v in ipairs(player.chips) do
    if v == entity then
      table.remove(player.chips, i)
      return true
    end
  end
end

-- Find player owned chip by class name.
function Player:findChipByClass(player, class)
  for i,v in ipairs(player.chips) do
    if v.class == class then
      return v
    end
  end
end

-- Get the total skill points available for spending.
function Player:getSkillPoints(player)
  return player.skills["points"]
end

-- Add skill points to the player that they can spend.
function Player:addSkillPoints(player, amount)
  local skills = player.skills
  skills["points"] = skills["points"] + amount
end

-- Increase one of the player skills.
-- If not enough points are available, return false.
-- The cost equals the current skill level.
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

-- Get the skill level of the requested skill class.
function Player:getSkillLevel(player, class)
  local skills = player.skills
  if not skills[class] then
    error(string.format("%q is not a valid skill class", class))
  else
    return skills[class]
  end
end

-- Change the player's reputation with positive or negative points
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

function Player:getLifestyleUpgradeCost(player)
  return self:getLifestyleCost(player, true) * 3
end

function Player:upgradeLifestyle(player)
  local cost = self:getLifestyleUpgradeCost(player)
  if player.credits >= cost then
    player.credits = player.credits - cost
    player.lifestyle.level = player.lifestyle.level + 1
    player.lifestyle.text = self:getLifestyleText(player)
    -- TODO message that lifestyle has been upgraded
    return true
  end
end

function Player:downgradeLifestyle(player)
  if player.lifestyle.level > 1 then
    player.lifestyle.level = player.lifestyle.level - 1
    player.lifestyle.text = self:getLifestyleText(player)
    -- TODO message that lifestyle has been downupgraded
    return true
  else
    -- downgrade is not possible
    return false
  end
end

function Player:getLifestyleText(player)
  if player.lifestyle.level > #self.lifestyles then
    return self.lifestyles[#self.lifestyles].text
  else
    return self.lifestyles[player.lifestyle.level].text
  end
end

function Player:findSourceByClass(player, class)
  for k, source in pairs(player.sourcecode) do
    if source.class == class then
      return source
    end
  end
end

return Player
