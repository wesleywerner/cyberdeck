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

describe("game controller", function()

  local controller = require("controller")
  controller:newGame()

  it("contains a player object", function()

    assert.is_not.is_nil(controller.database.player)
    assert.is_false(controller.database.player.onRun)

  end)

  it("generates a system with nodes", function()

    -- map with seed 1 (position 8 is the entry point)
    --    2
    --   415
    --    28
    --   13

    controller:enterMatrix(1)
    assert.is_not.is_nil(controller.database.system)
    assert.is_true(controller.database.player.onRun)

    local node = controller.database.player.node
    assert.is_not.is_nil(node)
    assert.are.equals(8, node.id)

    local northNode = node.exits["north"]
    assert.are.equals(5, northNode.id)

    local southNode = node.exits["south"]
    assert.is_nil(southNode)

    local westNode = node.exits["west"]
    assert.are.equals(2, westNode.id)

    -- test the node north of the west node
    assert.are.equals(1, westNode.exits["north"].id)

  end)

  it("move between nodes", function()

    controller:enterMatrix(1)
    controller:move("north")
    assert.are.equals(5, controller.database.player.node.id)

  end)

  pending("blocked by gateway on move", function()

  end)

end)
