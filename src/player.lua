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
    ["attack"] = 0,
    ["defense"] = 0,
    ["stealth"] = 0,
    ["analysis"] = 0,
    ["programming"] = 0,
    ["chip design"] = 0,
  }

  -- list of corporation names we visited, stores alert status and backdoors installed
  instance.corporations = {}

  -- list of chips installed in the deck
  instance.chips = {}

  -- list of hardware and software we own
  instance.hardware = {}
  instance.software = {}

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

return Player
