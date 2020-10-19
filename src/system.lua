--[[ SYSTEM.LUA
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

--- An interface to manage systems in the matrix.
-- A system is made from one or more areas, each one contains multiple
-- nodes.
--
-- A system is analogous to a dungeon, areas the levels, nodes the rooms.
--
-- @author Wesley Werner
-- @license GPL v3

-- TODO: move to constants.lua
-- Node type constants
NT_CPU = 0  -- Central Processing Unit
NT_SPU = 1  -- Sub Processing Unit
NT_COP = 2 -- Coprocessor
NT_DS = 3 -- Data store
NT_IO = 4 -- I/O Controller
NT_JUNC = 5 -- Junction
NT_PORTAL_IN = 6 -- Portal to next area
NT_PORTAL_OUT = 7 -- Portal to previous area

--  Node subtype constants
NST_IO_USELESS = 0 -- Useless IO node
NST_IO_QUEST_NODE = 1 -- This is the quest node
NST_IO_ALARM = 2 -- Controls the system alarm
NST_IO_ICE_PORT = 3 -- IO Node - ICE port - ice respawn here (not impl.)
NST_IO_MATRIX = 4 -- High-speed matrix port
NST_DS_NORMAL = 0
NST_DS_QUEST_NODE = 1
NST_COP_NORMAL = 0
NST_COP_SECURITY = 1

system = {}

--- Generate a system in the matrix.
-- A system is composed of areas and nodes.
-- An area is analogous to a dungeon level, a node is a room.
--
-- @tfield number seed
-- The system seed ensures regeneration of the same layout.
--
-- @tfield number size
-- The size of the system determines the number of areas and nodes.
function generate_system(seed, size)

  -- Reset and seed the system
  system.size = size
  system.areas = {}
  srand(seed)

  -- Calc the number of areas in the system.
  -- Larger sizes have more areas.
  -- The first 20 sizes yield: 1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5
  area_count = ceil(size/4)

  -- Calc the smallest area size.
  -- Each area added will increase in size.
  -- The first 20 sizes yield: 1 2 3 4 2 3 4 5 3 4 5 6 4 5 6 7 5 6 7 8
  area_size = (size-1)%4+area_count

  for area_no=1, area_count do
    local area = generate_system_area(area_no, area_size)
    -- The last area's out portal is the system entry point.
    system.entry_node = area.out_portal_node
  end

end

--- Generate an area within the current system.
function generate_system_area(area_no, size)

  local _nodes = {}

  -- First area has a CPU and external alarms IO
  if area_no == 1 then
    add(_nodes, {NT = NT_CPU})
    add(_nodes, {NT = NT_IO, SUB = NST_IO_ALARM})
  else
    -- Other areas have a SPU
    add(_nodes, {NT = NT_SPU})
  end

  -- Add security coprocessor
  add(_nodes, {NT = NT_COP, SUB = NST_COP_SECURITY})

  -- Add data stores
  for n = 1, 1 + flr(rnd(size + 1)) do
    add(_nodes, {NT = NT_DS})
  end

  -- Add IO nodes
  for n = 1, 1 + flr(size + 1) do
    add(_nodes, {NT = NT_IO})
  end

  -- Add ICE IO node
  add(_nodes, {NT = NT_IO, SUB = NST_IO_ICE_PORT})

  -- Add high speed matrix node
  if rnd(30) < system.size then
    add(_nodes, {NT = NT_IO, SUB = NST_IO_MATRIX})
  end

  -- Add a coprocessor for every n nodes
  for n = 1, flr(#_nodes / 4) do
    add(_nodes, {NT = NT_COP})
  end

  local area = {nodes = _nodes, no = area_no, size = size}

  -- Add portal in node (leads to the next area)
  if area_no > 1 then
    area.in_portal_node = add(_nodes, {NT = NT_PORTAL_IN})
  end

  -- Add portal out node (where the player emerges when entering the area)
  area.out_portal_node = add(_nodes, {NT = NT_PORTAL_OUT})

  -- Create and assign a layout to the nodes
  generate_area_layout(area)

  -- Add this area to the system
  add(system.areas, area)

  return area

end

--- Walk in random directions to build an area layout.
function generate_area_layout(area)

  -- List of keys of map points assigned
  local _points = {}
  local _nodes = area.nodes
  local _points_added = 1

  -- start at the origin, which is always the CPU or SPU.
  local _x, _y = 0, 0
  _points["00"] = 1 --_nodes[1]
  _nodes[1].x = 0
  _nodes[1].y = 0

  -- Until there are as many map points as nodes
  while (_points_added < #_nodes) do

    -- Move in a random direction
    local _dir = rnd({DIR_UP, DIR_DN, DIR_LT, DIR_RT})
    if _dir == DIR_UP then
      _y = _y - 1
    elseif _dir == DIR_DN then
      _y = _y + 1
    elseif _dir == DIR_LT then
      _x = _x - 1
    elseif _dir == DIR_RT then
      _x = _x + 1
    end

    local _key = tostr(_x)..tostr(_y)

    -- This place is free
    if _points[_key] == nil then
      _points_added = _points_added + 1
      local _node = _nodes[_points_added]
      _points[_key] = _points_added --_node
      _node.x = _x
      _node.y = _y
    else
      -- reposition at a random known point
      local _any_node = _nodes[1 + flr(rnd(_points_added))]
      _x = _any_node.x
      _y = _any_node.y
    end
  end

  -- Table of map positions. The key is x..y
  area.map = _points

end

--- Get a list of nodes adjacent to the current.
function get_adj_nodes()
  -- this_node is the current node which the player is in.
end