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


local Sourcecode = {}

function Sourcecode:create(player, class, rating)

  local Player = require("player")
  local Software = require("software")
  local Chips = require("chips")

  -- source can refer to software or a chip design. find out which one it is.
  local isSoftware = false
  local isChip = false
  local complexity = 0

  for warekey, ware in pairs(Software.types) do
    if warekey == class then
      isSoftware = true
      complexity = ware.complexity
    end
  end

  if not isSoftware then
    for chipkey, chip in pairs(Chips.types) do
      if chipkey == class then
        isChip = true
        complexity = chip.complexity
      end
    end
  end

  if not isSoftware and not isChip then
    error(string.format("%q is not a valid source class.", class))
  end

  -- Determine the max rating we can build for this source.
  -- It is limited by the player's appropriate skill
  local relevantSkillLevel = 0

  if isSoftware then
    relevantSkillLevel = Player:getSkillLevel(player, "programming")
  elseif isChip then
    relevantSkillLevel = Player:getSkillLevel(player, "chip design")
  end

  -- Owning design assistant hardware reduces the time
  local designAssistant = Player:findHardwareByClass(player, "Design Assistant")
  local designAssistLevel = designAssistant and designAssistant.rating or 0
  local appliedSkill = relevantSkillLevel * (1 + designAssistLevel)
  local baseTime = complexity * math.pow(rating, 2)

  -- Receive a time bonus if the player owns source for this class already
  local ownedSource = Player:findSourceByClass(player, class)
  if ownedSource then
    local previousBaseTime = (complexity * math.pow(ownedSource.rating, 2))
    baseTime = baseTime - previousBaseTime
    --print(string.format("owned %d, reduced by %d", ownedSource.rating, previousBaseTime))
  end

  local daysToComplete = math.ceil((baseTime + appliedSkill - 1) / appliedSkill)


  local instance = {}
  instance.class = class
  instance.rating = math.min(relevantSkillLevel, rating)
  instance.relevantSkillLevel = relevantSkillLevel
  instance.maxBuildRating = relevantSkillLevel
  instance.complexity = complexity
  instance.isSoftware = isSoftware
  instance.isChip = isChip
  instance.daysToComplete = daysToComplete
  return instance

end


-- Gets the list of source code we can work on as a project.
-- This is a join of software classes and chip classes.
function Sourcecode:getSourceList(player)

  local Player = require("player")
  local Software = require("software")
  local Chips = require("chips")
  local sourcelist = {}

  -- build the software list
  for warekey, ware in pairs(Software.types) do
    if ware.clientOnly ~= true then
      table.insert(sourcelist, {
        ["type"] = "software",
        ["class"] = warekey,
        ["complexity"] = ware.complexity,
        ["max build rating"] = Player:getSkillLevel(player, "programming")
      })
    end
  end

  -- sort the list by class name
  table.sort(sourcelist, function(a,b)
    return a.class < b.class
  end)

  -- build the chips list
  for chipkey, chip in pairs(Chips.types) do
    table.insert(sourcelist, {
      ["type"] = "chip",
      ["class"] = chipkey,
      ["complexity"] = chip.complexity,
      ["max build rating"] = Player:getSkillLevel(player, "chip design")
    })
  end

  -- cross reference with owned sources
  for k, source in pairs(sourcelist) do

    -- find this source that is owned by the player
    local ownedSource = Player:findSourceByClass(player, source.class)

    -- The list contains the currently owned source details where available
    source["owned rating"] = ownedSource and ownedSource.rating or 0

  end

  return sourcelist

end

return Sourcecode
