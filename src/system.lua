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

local System = {}

function System:create(size)

  local instance = {}
  instance.size = size
  instance.areas = {}
  return instance

end

function System:generate(entity, areafunc, layoutfunc, nodeSpecification)

  layoutfunc = layoutfunc or self.defaultLayoutFunc
  areafunc = areafunc or self.defaultAreasFunc
  nodeSpecification = nodeSpecification or self.defaultNodesSpecificationFunc

  -- The higher the system level the more areas it has.
  -- The first areas are the inner areas, the last area would be
  -- the entry point into the matrix.
  local areas = areafunc(entity)

  for areaNo=1,areas do

    -- get the node spec that defines which nodes should be placed
    local spec = nodeSpecification(entity, areaNo)

    -- get the min and max number of nodes for the specification
    local nmin,nmax = self:calculateMinMaxNodes(spec)
    print(nmin,nmax,nmax-nmin)

    -- add a random variance of max nodes allowed
    local totalNodes = nmin + math.random(nmax-nmin)

    -- generate the area layout, based on the number of nodes to place
    local map = self:newMap()
    local gen = layoutfunc(map, entity, areaNo, totalNodes)
    table.insert(entity.areas, map)
  end

end

function System:newMap()
  local map = {}
  for h=1,10 do
    map[h] = {}
    for w=1,10 do
      map[h][w] = 0
    end
  end
  return map
end

-- Return the number of areas the system will have.
function System.defaultAreasFunc(entity)
  return math.max(1, math.floor(math.log(entity.size) * 1.5))
  -- by default the number of areas is logarithmic to entity size.
  -- level 1 has 1 area
  -- level 4 has 2 areas
  -- level 8 has 3 areas
  -- level 15 has 4 areas
  -- for i=1,20 do
  -- print("level " .. i .. " has " .. math.floor(math.log(i)*1.5) .. " areas")
  -- end
end

function System.defaultLayoutFunc(map, systemEntity, areaNo, nodeCount)
  local UP=1
  local DN=2
  local LT=3
  local RT=4
  local x,y=5,5

  --local nodes=4+math.floor(math.log(systemEntity.size) * 2)

  -- Move in a random direction until an empty map space is encountered.
  -- this always creates the requested number of nodes, by walking over
  -- existing nodes until a free space is encountered. Every node will
  -- always be adjacent to at least one other node.
  for nsteps=1,nodeCount do
    map[x][y] = 1
    while map[x][y] > 0 do
      local dir = math.random(1,4)
      if dir == UP then
        y=math.max(1,y-1)
      elseif dir == DN then
        y=math.min(10,y+1)
      elseif dir == LT then
        x=math.max(1, x-1)
      elseif dir == RT then
        x=math.min(10,x+1)
      end
    end
  end

  --return map

end

-- Return a table defining the nodes that should appear in the system.
-- areaNo 1 is the innermost area.
function System.defaultNodesSpecificationFunc(entity, areaNo)

  local nodes = {}

  -- The maximum nodes is a log function that increases rapidly at
  -- lower system sizes.
  local maxnodes = 1 + math.log(entity.size)

  -- the CPU node is always in the inner-most area, otherwise it gets a SPU.
  if areaNo == 1 then
    table.insert(nodes, {
      ["type"] = "central processing node",
      ["minimum"] = 1,
      ["maximum"] = 1,
    })
  else
    table.insert(nodes, {
      ["type"] = "sub processing node",
      ["minimum"] = 1,
      ["maximum"] = 1,
    })
  end

  -- the external alarm I/O node is always in the innermost area.
  if areaNo == 1 then
    table.insert(nodes, {
      ["type"] = "input output node",
      ["minimum"] = 1,
      ["maximum"] = 1,
      ["controls"] = { "external alarms" }
    })
  end

  -- Always add a security node.
  -- A chance of more ICE appearing in the security node.
  -- A chance of higher rating ICE in this node too.
  table.insert(nodes, {
    ["type"] = "coprocessor node",
    ["minimum"] = 1,
    ["maximum"] = 1,
    ["controls"] = { "security" }
  })

  -- Data stores
  table.insert(nodes, {
    ["type"] = "data store node",
    ["minimum"] = 1,
    ["maximum"] = math.random(maxnodes),
  })

  -- Add the ICE port I/O node
  table.insert(nodes, {
    ["type"] = "input output node",
    ["minimum"] = 1,
    ["maximum"] = 1,
    ["controls"] = { "ICE" }
  })

  -- Optional coprocessors
  table.insert(nodes, {
    ["type"] = "coprocessor node",
    ["minimum"] = 0,
    ["maximum"] = math.random(maxnodes),
  })

  -- Optional IO nodes
  table.insert(nodes, {
    ["type"] = "input output node",
    ["minimum"] = 0,
    ["maximum"] = math.random(maxnodes),
  })

  -- Random high-speed IO node
  if math.random(30) < entity.size then
    table.insert(nodes, {
      ["type"] = "input output node",
      ["minimum"] = 1,
      ["maximum"] = 1,
      ["controls"] = { "high speed" }
    })
  end

  -- Portal IN node
  if areaNo > 1 then
    table.insert(nodes, {
      ["type"] = "portal in node",
      ["minimum"] = 1,
      ["maximum"] = 1,
    })
  end

  -- Portal out
  table.insert(nodes, {
    ["type"] = "portal out node",
    ["minimum"] = 1,
    ["maximum"] = 1,
  })

  return nodes

  -- // Node Types
  -- #define NT_CPU     0 // Central Processing Unit
  -- #define  NT_SPU      1 // Sub Processing Unit
  -- #define NT_COP     2 // Coprocessor
  -- #define  NT_DS     3 // Data store
  -- #define  NT_IO     4 // I/O Controller
  -- #define NT_JUNC      5 // Junction
  -- #define NT_PORTAL_IN 6 // Portal
  -- #define NT_PORTAL_OUT  7 // Portal

  -- // Node subtypes
  -- #define NST_IO_USELESS   0 // Useless IO node
  -- #define NST_IO_QUEST_NODE  1 // This is the quest node
  -- #define NST_IO_ALARM   2 // IO Node - alarm
  -- #define NST_IO_ICE_PORT    3 // IO Node - ICE port - ice respawn here (not impl.)
  -- #define NST_IO_MATRIX    4 // High-speed matrix port
  --
  -- #define NST_DS_NORMAL    0
  -- #define NST_DS_QUEST_NODE  1
  --
  -- #define NST_COP_NORMAL   0
  -- #define NST_COP_SECURITY 1 // FSO 12-17-01

end

-- Take a node specification table and return the min,max number of nodes.
function System:calculateMinMaxNodes(spec)
  local minimum, maximum = 0, 0
  for k,entry in ipairs(spec) do
    minimum = minimum + entry.minimum
    maximum = maximum + entry.maximum
  end
  return minimum, maximum
end

function System:print(entity)
  for i,area in ipairs(entity.areas) do
    for h=1,10 do
      for w=1,10 do
        if area[w][h] == 1 then
          io.write("+")
        else
          io.write(" ")
        end
      end
      io.write("\n")
    end
  end
end

return System
