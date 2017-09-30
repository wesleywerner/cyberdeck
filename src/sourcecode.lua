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

-- Source code is what you use to build software, or burn chips.
-- You can obtain it via a file download in the matrix, in this case
-- it is added to the player's source code list.

-- It can also be created by spending days developing your own, in this
-- case it is considered a "project", and only once development is
-- complete will it be added to your source code list.

-- Building source code for software will add it to your software list
-- where it can be loaded and used by your deck in the matrix.

-- Building the code for chips involves burning it to a chip. This can
-- take several days.

--- An interface to manage chip and software sources.
-- Source code is used in-game to create @{chips} or @{software} for your deck.
-- The other way to acquire chips or software is through the @{shop}.
-- @author Wesley Werner
-- @license GPL v3
local Sourcecode = {}

--- Create a new instance of source code.
-- Source code can be based on either @{chips} or @{software},
-- the determining factor is the class name given during creation.
-- @tparam player:instance player Reference to the player instance.
-- @tparam string class The class of the source, one of @{chips.types} or @{software.types}.
-- @tparam number rating The rating of chip or software that is built from this source.
-- @treturn sourcecode:instance
function Sourcecode:create(player, class, rating)

  local Player = require("player")
  local Software = require("software")
  local Chips = require("chips")

  -- source can refer to software or a chip design. find out which one it is.
  local isSoftware = false
  local isChip = false
  local complexity = 0

  local softwareDefinition = Software:getType(class)
  if softwareDefinition then
      isSoftware = true
      complexity = softwareDefinition.complexity
  end

  if not isSoftware then
    local chipDefinition = Chips:getType(class)
    if chipDefinition then
        isChip = true
        complexity = chipDefinition.complexity
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

  --- @table instance
  -- @field class The instance class.
  -- @field rating The instance rating, clamped to the player's relevantSkillLevel.
  -- @field relevantSkillLevel The rating of the player's skill relevant to the class.
  -- For software sources this will be the player "programming" skill,
  -- and for chip sources the "chip design" skill.
  -- @field maxBuildRating NOT CURRENTLY USED, MAY BE REMOVED.
  -- @field complexity The chip or software complexity.
  -- Affects the time required to complete the project,
  -- and the burn time (when cooked in a chip burner).
  -- @field isSoftware = isSoftware
  -- @field isChip = isChip
  -- @field daysToComplete = self:calculateTimeToDevelop(player, instance)
  -- @field isCooking = false

  local instance = {}
  instance.class = class
  instance.rating = math.min(relevantSkillLevel, rating)
  instance.relevantSkillLevel = relevantSkillLevel
  instance.maxBuildRating = relevantSkillLevel
  instance.complexity = complexity
  instance.isSoftware = isSoftware
  instance.isChip = isChip
  instance.daysToComplete = self:calculateTimeToDevelop(player, instance)
  instance.isCooking = false
  return instance

end

--- Gets the time to develop source code.
-- If the source is for software, the player's "programming" skill is used
-- and if it is for a chip, the "chip design" skill is used.
-- This skill is then multiplied by the "design assistant" hardware rating
-- if owned by the player.
--
-- applied skill = skill * design assistant rating
--
-- A base time is calculated as the product of the source complexity
-- and the source rating to the second power.
--
-- base time = complexity * (rating^2)
--
-- Next we look if the player owns sourcecode for the same software/chip
-- and if so, reduce the base time by the existing sourcecode's base time.
-- This gives a time bonus with the reasoning that the player is using
-- the existing sourcecode to speed up development time.
--
-- base time = base time - existing sourcecode base time
--
-- Finally we add and divide the base time by the skill.
-- We subtract 1 so that only skills above 1 have any significant effect.
--
-- ceil((base time + applied skill - 1) / applied skill)
--
-- @tparam player:instance player The player instance.
-- @tparam sourcecode:instance entity The source code instance to query.
-- @treturn number The days to develop the code to completion
function Sourcecode:calculateTimeToDevelop(player, entity)

  local Player = require("player")

  -- Owning design assistant hardware reduces the time
  local designAssistLevel = Player:findHardwareRatingByClass(player, "Design Assistant")
  local appliedSkill = entity.relevantSkillLevel * (1 + designAssistLevel)
  local baseTime = entity.complexity * math.pow(entity.rating, 2)

  -- Receive a time bonus if the player owns source for this class already
  local ownedSource = Player:findSourceByClass(player, entity.class)
  if ownedSource then
    local previousBaseTime = (entity.complexity * math.pow(ownedSource.rating, 2))
    baseTime = baseTime - previousBaseTime
    --print(string.format("owned %d, reduced by %d", ownedSource.rating, previousBaseTime))
  end

  return math.ceil((baseTime + appliedSkill - 1) / appliedSkill)

end

--- Gets the list of source code available.
-- This is a join of software classes and chip classes.
-- @tparam player:instance player The player instance.
-- @treturn sourcecode:sourcelist
function Sourcecode:getSourceList(player)

  local Player = require("player")
  local Software = require("software")
  local Chips = require("chips")
  local sourcelist = {}

  -- build the software list
  for _, ware in ipairs(Software.types) do
    if ware.clientOnly ~= true then
      table.insert(sourcelist, {
        ["type"] = "software",
        ["class"] = ware.class,
        ["complexity"] = ware.complexity,
        ["maxrating"] = Player:getSkillLevel(player, "programming")
      })
    end
  end

  -- sort the list by class name
  table.sort(sourcelist, function(a,b)
    return a.class < b.class
  end)

  -- build the chips list
  for _, chip in ipairs(Chips.types) do
    table.insert(sourcelist, {
      ["type"] = "chip",
      ["class"] = chip.class,
      ["complexity"] = chip.complexity,
      ["maxrating"] = Player:getSkillLevel(player, "chip design")
    })
  end

  -- cross reference with owned sources
  for k, source in pairs(sourcelist) do

    -- find this source that is owned by the player
    local ownedSource = Player:findSourceByClass(player, source.class)

    -- The list contains the currently owned source details where available
    source["ownedrating"] = ownedSource and ownedSource.rating or 0

  end

  --- @table sourcelist
  -- @field type The type of the source as "software" or "chip".
  -- @field class The class name of the source item,
  -- one of @{software.types} or @{chips.types}
  -- @field complexity The complexity of the chip or software.
  -- @field maxrating The rating limit for newly created instances.
  -- Equates to the player's programming/chip design skills.
  -- @field ownedrating The rating of any owned sources of the same class.
  return sourcelist

end

--- Spend time to complete a source code project.
-- On successful work, the instance's daysToComplete value is decreased by one day.
-- When the project completes it is added to the player's sourcecode list.
-- @tparam player:instance player The player instance.
-- @tparam sourcecode:instance entity The source code instance to work on.
function Sourcecode:workOnCode(player, entity)

  local Die = require("die")
  local Player = require("player")
  entity.daysToComplete = entity.daysToComplete - 1

  -- project complete, now we roll to see if we found any bugs
  -- in our sourcecode, which can delay the completion.
  if entity.daysToComplete <= 0 then

    -- owning design assistant hardware improves our success rate
    local designAssistLevel = Player:findHardwareRatingByClass(player, "Design Assistant")

    -- roll for success against:
    -- (10 + source rating) - (relevant skill * design assist rating).
    -- 10 gives about 50% chance of success.
    -- Increase the target by the source rating (reduces success).
    -- Subtract the programming/chip design skill and assistant (increases success).
    local rolltarget = (10 + entity.rating) - (entity.relevantSkillLevel + designAssistLevel)
    local roll = Die:roll(rolltarget)

    if roll.success then
      Player:addSourcecode(player, entity)
      -- TODO message that the project is complete and now in your sources list
    else
      entity.daysToComplete = (self:calculateTimeToDevelop(player, entity) + 3) / 4
      --TODO message that "You have discovered a flaw in your code. Additional time will be required."
    end

  end

end

--- Build developed source code.
-- If the source is of the @{software} type, it will be built into
-- the player's software list. If it is of the @{chips} type it is added
-- to the @{player.sourcecode} cooking property.
-- @tparam player:instance player The player instance.
-- @tparam sourcecode:instance sourcecode The source to build.
-- @treturn bool Build success.
function Sourcecode:build(player, sourcecode)

  local Player = require("player")
  local Software = require("software")

  if sourcecode.daysToComplete > 0 then
    -- TODO message that the source is undeveloped
    return false
  end

  if sourcecode.isSoftware then
    local program = Software:create(sourcecode.class, sourcecode.rating)
    Player:addSoftware(player, program)
    return true
  end

  if sourcecode.isChip then

    -- player must own a chip burner
    local burner = Player:findHardwareRatingByClass(player, "Chip Burner")

    if burner == 0 then
      -- TODO message that a chip burner is required
      --print("you need a burner")
      return false
    end

    local currentproject = Player:getCookingChip(player)
    if currentproject then
      -- TODO message that a chip is already cooking
      --print("chip already cooking")
      return false
    end

    -- cook it
    sourcecode.cooktime = sourcecode.complexity * sourcecode.rating
    player.sourcecode.cooking = sourcecode
    return true

  end

end

--- Reduce the cook time of the burning chip by one day.
-- On completion the chip is installed in the deck.
-- @tparam player:instance player The player instance where the cooking chip
-- information is located.
function Sourcecode:cookChip(player)

    local Player = require("player")
    local Chips = require("chips")
    local burner = Player:getCookingChip(player)

    if burner then

      -- reduce cooking time
      burner.cooktime = burner.cooktime - 1

      -- it is done
      if burner.cooktime < 1 then

        -- install the new chip
        local chip = Chips:create(burner.class, burner.rating)
        Player:addChip(player, chip)

        -- remove the project
        player.sourcecode.cooking = nil

      end

    end

end

return Sourcecode
