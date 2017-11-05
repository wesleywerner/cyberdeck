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

--- Provides methods to control the game.
-- @author Wesley Werner
-- @license GPL v3
local controller = {}

--- The controller instance used to control most of the game actions.
-- @table instance
--
-- @tfield database database
-- All the game data is stored in here.

--- Start a new game.
-- Creates a new database
function controller:newGame()

  self.database = require("model.database"):create()
  self.combat = require("logic.combat")

end

function controller:enterMatrix(seed)

  -- generate the matrix
  -- TODO the system size should match the player level.
  -- TODO the seed could be stored on the corporation giving
  --  a reproducable layout.
  local systemModule = require("model.system")
  self.database.system = systemModule:create(1, seed or os.time())
  systemModule:generate(self.database.system)

  -- set the player entry point
  local playerModule = require("model.player")
  local entryNode = systemModule:getEntryNode(self.database.system)
  playerModule:prepareForMatrix(self.database.player)
  self:enterNode(self.database.player, entryNode)

end

--- Move into the direction of a node exit.
--
-- @tparam string direction
-- One of the cardinal directions, "north", "south", "east" or "west".
function controller:move(direction)

  -- decker source https://keyboardmonkey.co.za/extra/games/decker/class_c_matrix_view.html#abf94da8e3588e8b9066a779dbfa3df85

  local node = self.database.player.node
  local player = self.database.player

  -- sanity test
  if not node then
    error("player is not in a valid node")
  end

  -- test the node direction
  if not node.exits[direction] then
    -- TODO message that there is no exit in that direction
    return false
  end

  local canMove = self.combat:bypassGatewayIce(player, node, direction)

  if canMove then
    -- TODO cancel running file transfers
    -- TODO cancel running scans
    -- TODO cancel client program execution
    -- TODO update state of all ICE in the node
    -- TODO set new player node
    self:enterNode(player, node.exits[direction])
  end

  -- end the turn
  local playerModule = require("model.player")
  local iceModule = require("model.ice")
  playerModule:endTurn(player)
  iceModule:endTurn(player.node)

end

--- Enters the given node.
--  This also resets some variables that track the target ICE.
--
-- @tparam player.instance player
-- @tparam node.instance node
function controller:enterNode(player, node)

  player.node = node
  player.targetICE = nil
  player.highestRatedICEDeceived = nil

  -- TODO mark the node as mapped
  --node.mapped = true

  -- TODO If mapper hardware installed, mark adjacent nodes as mapped

  if player.traced then
    self.combat:markIceHostile(node)
  end

  -- TODO message that you entered %node

end

return controller
