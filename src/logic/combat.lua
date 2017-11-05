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

--- Provides logic for combat actions against enemy ICE.
local combat = {}

--- Test if a gateway ICE is blocking the exit in a given direction
-- and attempt to bypass it so we can move past.
--
-- @treturn bool
-- Success indicating we may pass through the exit
function combat:bypassGatewayIce(player, node, direction)

  -- see if there is ICE blocking this direction
  local gateIce = self:findGatewayIce(node, direction)

  -- no ICE to stop us
  if not gateIce then
    return true
  end

  -- bypassed ice pose a challenge
  if not gateIce.bypassed then

    -- find the hide program
    local hideProgram = player:findSoftwareByClass(player, "hide")

    -- without a hide program, we fail to move past the ice.
    -- in these cases, an offensive approach is needed.
    if not hideProgram then
      -- TODO message that the ice blocks your way
      return false
    end

    -- run the hide program against the ice
    local success = self:runProgramVsIce(player, gateIce, hideProgram)

    if success then
      -- TODO message that the %ice was successfully bypassed by the %program.
      return true
    else
      -- TODO message that the %ice was not fooled by %program
      -- TODO The only place accessed is used, is when ice perform
      --  their turns, and if it was accessed, it will query the player.
      --  consider renaming "accessed" to a name like "failedHideAttempt".
      gateIce.accessed = true
      return false
    end

  end

end

--- Get the gateway ICE in the current node in the given direction.
function combat:findGatewayIce(node, direction)

  for _, ice in pairs(node.ice) do

    if ice.class == "Gateway" and ice.direction == direction then
      return ice
    end

  end

end

function combat:runProgramVsIce(player, gateIce, hideProgram)

end

--- Mark the ICE in the given node as hostile
function combat:markIceHostile(node)

  local icemodule = require("model.ice")

  -- TODO pseudo code
  for _, ice in pairs(node.ice) do

    -- clear bypassed state
    ice.bypassed = false

    if ice.state == "destroying" then
      -- ICE busy destroying data files are not updated, let them
      -- continue their work.
    elseif ice.isCombat then
      -- black ice become offensive
      icemodule:setState(ice, "attacking")
    else
      -- move non-combat (guardian) ICE back to their home nodes
      icemodule:setState(ice, "homeward")
    end

  end

end



return combat
