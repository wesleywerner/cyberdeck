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

--- @table instance
-- @tfield

--- Start a new game.
-- Creates a new database
function controller:newGame()

  self.database = require("model.database"):create()

end

function controller:enterMatrix()

  local system = require("model.system")
  self.system = system:create(1, os.time())
  system:generate(self.system)

end

return controller
