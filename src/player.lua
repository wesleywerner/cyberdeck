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

function Player:create(db)

  local instance = {}
  instance.name = "Hacker X"
  instance.credits = 0
  instance.lifestyle = nil

  -- Mental and deck health reset when entering the matrix.
  instance.health = {
    ["physical"] = self.MAXHEALTH,
    ["mental"] = 0,
    ["deck"] = 0
  }

  instance.reputation = {
    ["level"] = "Poverty",
    ["points"] = 0
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

function Player:getName(db)
  return db.player.name
end

-- Reset matrix-specific values.
function Player:prepareForMatrix(db)
  db.player.health.mental = self.MAXHEALTH
  db.player.health.deck = self.MAXHEALTH
end

-- Get bank balance
function Player:getCredits(db)
  return db.player.credits
end

-- Increase credits
function Player:addCredits(db, amount)
  db.player.credits = db.player.credits + amount
end

-- If there are not enough credits to spend, return false.
function Player:spendCredits(db, amount)
  if db.player.credits < amount then
    return false
  else
    db.player.credits = db.player.credits - amount
    return true
  end
end

-- Add hardware to the player inventory.
-- If the player already own this hardware at a lower rating, it is
-- sold for a second-hand price. If the player owns a higher rated one
-- this returns false.
function Player:addHardware(db, entity)
  local hardware = require("hardware")

  -- check for existing of the same class
  local existing = self:findHardwareByClass(db, entity.class)
  if existing then
    local currentRating = hardware:getRating(db, existing)
    local proposedRating = hardware:getRating(db, entity)
    -- remove existing if lower rated
    if currentRating < proposedRating then
      self:removeHardware(db, existing)
    else
      -- TODO send message: You already own that hardware at the same or higher rating
      return false
    end
  end

  -- resell old hardware
  if existing then
    local value = hardware:getResellPrice(db, existing)
    self:removeHardware(db, existing)
    self:addCredits(db, value)
    -- TODO send message: You sold your old hardware for %dcr
  end

  -- add the new hardware
  table.insert(db.player.hardware, entity)
  return true
end

-- Remove hardware from the player inventory.
function Player:removeHardware(db, entity)
  local hardware = require("hardware")
  for i,v in ipairs(db.player.hardware) do
    if v == entity then
      table.remove(db.player.hardware, i)
      return true
    end
  end
end

-- Find player owned hardware by class name.
function Player:findHardwareByClass(db, class)
  for i,v in ipairs(db.player.hardware) do
    if v.class == class then
      return v
    end
  end
end

-- Add software to the player inventory.
-- Returns true on success.
-- Returns false if the player owns the same or higher rated version.
function Player:addSoftware(db, entity)
  local software = require("software")

  -- check for existing of the same class
  local existing = self:findSoftwareByClass(db, entity.class)
  if existing then
    local currentRating = software:getPotentialRating(db, existing)
    local proposedRating = software:getPotentialRating(db, entity)
    -- remove existing if lower rated
    if currentRating < proposedRating then
      self:removeSoftware(db, existing)
    else
      -- TODO send message: You already own that software at the same or higher rating
      return false
    end
  end

  table.insert(db.player.software, entity)
  return true
end

-- Remove software from the player inventory.
function Player:removeSoftware(db, entity)
  for i,v in ipairs(db.player.software) do
    if v == entity then
      table.remove(db.player.software, i)
      return true
    end
  end
end

-- Find player owned software by class name.
function Player:findSoftwareByClass(db, class)
  for i,v in ipairs(db.player.software) do
    if v.class == class then
      return v
    end
  end
end

-- Add a chip to the player inventory.
function Player:addChip(db, entity)
  -- check for existing of the same class
  local chips = require("chips")
  local existing = self:findChipByClass(db, entity.class)
  if existing then
    local currentRating = chips:getRating(db, existing)
    local proposedRating = chips:getRating(db, entity)
    -- remove existing if lower rated
    if currentRating < proposedRating then
      self:removeChip(db, existing)
    else
      -- TODO send message: You already own that software at the same or higher rating
      return false
    end
  end
  table.insert(db.player.chips, entity)
  return true
end

-- Remove a chip from the player inventory.
function Player:removeChip(db, entity)
  for i,v in ipairs(db.player.chips) do
    if v == entity then
      table.remove(db.player.chips, i)
      return true
    end
  end
end

-- Find player owned chip by class name.
function Player:findChipByClass(db, class)
  for i,v in ipairs(db.player.chips) do
    if v.class == class then
      return v
    end
  end
end

-- Get the total skill points available for spending.
function Player:getSkillPoints(db)
  return db.player.skills["points"]
end

-- Add skill points to the player that they can spend.
function Player:addSkillPoints(db, amount)
  local skills = db.player.skills
  skills["points"] = skills["points"] + amount
end

-- Increase one of the player skills.
-- If not enough points are available, return false.
-- The cost equals the current skill level.
function Player:spendSkillPoints(db, class)
  local skills = db.player.skills
  if not skills[class] then
    error(string.format("%q is not a valid skill class", class))
  end
  local points = skills["points"]
  local cost = self:getSkillLevel(db, class)
  if cost > points then
    return false
  else
    skills["points"] = skills["points"] - cost
    skills[class] = skills[class] + 1
    return true
  end
end

-- Get the skill level of the requested skill class.
function Player:getSkillLevel(db, class)
  local skills = db.player.skills
  if not skills[class] then
    error(string.format("%q is not a valid skill class", class))
  else
    return skills[class]
  end
end

return Player
