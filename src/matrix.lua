--[[
   This program is free Template: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Template Foundation, either version 3 of the License, or
   any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program. If not, see http://www.gnu.org/licenses/.
]]--

--[[ List of conditions when alerts are triggered:

    RED
    state is moving and is hostile
    state is destroying
    state is attacking
    state is guarding and is hostile
    while querying the player and is not bypassed and the player has decoys active
    when confused and decides to attack, but is not an attacking ICE (not attack, not trace, not probe)
    a random chance when switching a IO node that has no sub-type (a useless node)
    when failing to crash the logged-in system
    when failing to create a backdoor
    when failing to kill a yellow alert
    when failing to cancel system shutdown
    when failing to remove a trace

    YELLOW
    state is queried 3, is not bypassed and the player is not in the same node anymore
    when failing to deceive ICE that is *not* in any queried state
]]
