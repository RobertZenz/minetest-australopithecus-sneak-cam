--[[
Copyright (c) 2015, Robert 'Bobby' Zenz
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]


--- The main object for the sneak cam mod.
sneakcam = {
	--- If the system should activated automatically.
	activate_automatically = settings.get_bool("sneakcam_activate", true),
	
	--- If the system is active/has been activated.
	active = false,
	
	--- The interval in which the system updates, defaults to 0.066.
	interval = settings.get_number("sneakcam_interval", 0.066),
	
	--- The offset by which the camera is lowered if the player is sneaking.
	-- The value is read from the configuration file, the name of the value
	-- is sneakcam_offset, defaults to 1.65.
	offset = settings.get_number("sneakcam_offset", 1.65),
	
	--- The state of all players the last time the system has seen them.
	sneak_state = {}
}


--- Activates the sneakcam system. But checks if it is has been disabled via
-- the configuration, the name of the value is sneakcam_activate.
function sneakcam.activate()
	if sneakcam.activate_automatically then
		sneakcam.activate_internal()
	end
end

--- Activates the system, without checking the configuration. Multiple
-- invocations have no effect.
function sneakcam.activate_internal()
	if not sneakcam.active then
		scheduler.schedule(
			"sneakcam",
			sneakcam.interval,
			sneakcam.update_player_cams,
			scheduler.OVERSHOOT_POLICY_RUN_ONCE)
		
		sneakcam.active = true
	end
end

--- Updates the camera of the given player.
--
-- @param player The Player object.
function sneakcam.update_player_cam(player)
	local controls = player:get_player_control()
	local player_name = player:get_player_name()
	
	if sneakcam.sneak_state[player_name] == nil then
		sneakcam.sneak_state[player_name] = controls.sneak
	elseif controls.sneak ~= sneakcam.sneak_state[player_name] then
		local eye_offset_first, eye_offset_third = player:get_eye_offset()
		
		if controls.sneak then
			eye_offset_first.y = eye_offset_first.y - sneakcam.offset
		else
			eye_offset_first.y = eye_offset_first.y + sneakcam.offset
		end
		
		player:set_eye_offset(eye_offset_first, eye_offset_third)
		sneakcam.sneak_state[player_name] = controls.sneak
	end
end

--- Updates the cameras of players.
function sneakcam.update_player_cams()
	for index, player in ipairs(minetest.get_connected_players()) do
		sneakcam.update_player_cam(player)
	end
end

