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

local Area = {}

function Area:create(number, definition)

  local instance = {}
  instance.number = number
  instance.definition = definition
  instance.nodeCount = self:calculateAreaNodeCount(definition)
  -- map size is padded for extra room.
  instance.mapsize = instance.nodeCount*2
  instance.map = {}

  -- Fill the map with blank values
  for h=1, instance.mapsize do
    instance.map[h] = {}
    for w=1, instance.mapsize do
      instance.map[h][w] = 0
    end
  end

  self:generateLayout(instance)
  self:assignNodesToMap(instance)
  self:convertMapPointsToNodes(instance)
  self:linkNodeExits(instance)

  return instance

end

-- Get the number of nodes for an area
function Area:calculateAreaNodeCount(definition)

  -- sum the minimum and spare values for all definition entries
  local minimum, spare = 0, 0

  for k,entry in ipairs(definition) do
    minimum = minimum + entry.minimum
    spare = spare + entry.spare
  end

  local total = minimum + spare

  return total

end

-- Fill node positions on the map with a placeholder value.
function Area:generateLayout(area)

  local UP=1
  local DN=2
  local LT=3
  local RT=4

  -- start in the center of the map
  local x,y=math.floor(area.mapsize/2),math.floor(area.mapsize/2)

  -- Move in a random direction until an empty map space is encountered.
  -- this always creates the requested number of nodes, by walking over
  -- existing nodes until a free space is encountered. Every node will
  -- always be adjacent to at least one other node.
  for nsteps=1, area.nodeCount do

    -- revserve this space for a node
    area.map[x][y] = -1

    -- move alont the map until a blank space is found
    while area.map[x][y] == -1 do
      local dir = math.random(1,4)
      if dir == UP then
        y=math.max(1,y-1)
      elseif dir == DN then
        y=math.min(area.mapsize,y+1)
      elseif dir == LT then
        x=math.max(1, x-1)
      elseif dir == RT then
        x=math.min(area.mapsize,x+1)
      end
    end
  end

end

-- Replace placeholders on the map with items from the node definition.
-- The minimum required nodes are placed first, and the spare nodes
-- fill in the remaining placeholders.
function Area:assignNodesToMap(area)

  -- Puts a value in a random placeholder
  local setMapValue = function(value)
    local x,y=1,1
    -- scan for placeholders only (-1)
    while area.map[x][y] >= 0 do
      x = math.random(area.mapsize)
      y = math.random(area.mapsize)
    end
    area.map[x][y] = value
  end

  local nodeCount = area.nodeCount

  -- there are nodes left to assign
  while nodeCount > 0 do

    -- track whether minimum required nodes are left to place
    local hasMinimumLeft = false

    -- TODO copy the definition to preserve original from modification.
    -- THIS IS A DEMO COPY THAT HANDLES 2 LEVELS ONLY.
    -- FIND A BEST DEEP COPY SOLUTION.
    local defcopy = {}
    for k,v in pairs(area.definition) do
      if type(v) == "table" then
        defcopy[k] = {}
        for m,n in pairs(v) do
          defcopy[k][m] = n
        end
      else
        defcopy[k] = v
      end
    end

    -- look at the node specification for guidance
    for entryIndex, entry in ipairs(defcopy) do

      -- we must test this inside the loop to avoid an infinite loop
      if nodeCount > 0 then

        -- assign the minimum number of nodes required
        if entry.minimum > 0 then
          entry.minimum = entry.minimum - 1
          nodeCount = nodeCount - 1
          hasMinimumLeft = true
          setMapValue(entryIndex)
        end

        -- place optional maximum nodes if all minimum has been placed
        if not hasMinimumLeft and entry.spare > 0 then
          entry.spare = entry.spare - 1
          nodeCount = nodeCount - 1
          setMapValue(entryIndex)
        end

      end
    end
  end
end

--- Convert the map points into node objects.
-- Initially an area map is generated as numbers that correlate
-- to the node definition entries. This method converts each map point
-- to a bonafide node object.
function Area:convertMapPointsToNodes(area)

  for h=1, area.mapsize do
    for w=1, area.mapsize do

      -- get node definition id for this map position
      local nodeDefinitionId = area.map[w][h]

      -- get the node definition
      local definition = area.definition[nodeDefinitionId]

      if definition then

        local node = {}
        node.id = nodeDefinitionId
        node.type = definition.type

        -- convert the control flags into an easy lookup
        node.controls = {}
        if definition.controls then
          for _, control in pairs (definition.controls) do
            node.controls[control] = true
          end
        end

        -- generate ICE in this node
        node.ice = {}

        area.map[w][h] = node

      else
        area.map[w][h] = nil
      end
    end
  end

end

--- Generate exit links between nodes in this area.
function Area:linkNodeExits(area)

  for h=1, area.mapsize do
    for w=1, area.mapsize do

      local node = area.map[w][h]

      if node then
        node.exits = {}
        node.exits["north"] = self:getNodeFromMap(area, w, h-1)
        node.exits["south"] = self:getNodeFromMap(area, w, h+1)
        node.exits["east"] = self:getNodeFromMap(area, w+1, h)
        node.exits["west"] = self:getNodeFromMap(area, w-1, h)
      end

    end
  end

end

--- Get the node at a given map position
function Area:getNodeFromMap(area, x, y)

  -- clamp values
  x = math.max(1, x)
  y = math.max(1, y)
  x = math.min(area.mapsize, x)
  y = math.min(area.mapsize, y)

  return area.map[x][y]

end

return Area
