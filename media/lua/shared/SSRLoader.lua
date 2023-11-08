-- Copyright (c) 2022-2023 Oneline/D.Borovsky
-- All rights reserved
require "SSRCore"
require "SSRTimer"

SSRLoader = {}
SSRLoader.initialized = false;
SSRLoader.timezone = 0;

local font_size, scale = getCore():getOptionFontSize() or 1, { 1, 1.3, 1.65, 1.95, 2.3 };
SSRLoader.scale = scale[font_size];

SSRLoader.NFO = require("NFOCompatibility");
SSRLoader.QSystem = require("QuestsCompatibility");
SSRLoader.Private = require("PrivateCompatibility");
SSRLoader.Expansion = require("ExpansionCompatibility");

SSRLoader.load = function()
	if not SSRLoader.initialized then
		SSRLoader.initialized = true;
		if isServer() then
			if SSRLoader.NFO then
				NFOServer.init();
			end

			if SSRLoader.Private then
				FW.init();
			end
		elseif isClient() then
			if SSRLoader.NFO then
				NFOClient.init();
			end

			if SSRLoader.Private then
				Private.init();
			end
		end

		if SSRLoader.QSystem then
			QSystem.init();
		end
	end
end

SSRLoader.onGameStartZombie = function(zombie)
	Events.OnZombieUpdate.Remove(SSRLoader.onGameStartZombie); -- remove event after zombies appeared on map and got their first update
	SSRLoader.load();
end

local function setTimeZone()
	local sdf = SimpleDateFormat.new("X");
	local timestamp = Calendar.getInstance():getTime();
	SSRLoader.timezone = tonumber(sdf:format(timestamp)) or 0;
end

SSRLoader.init = function ()
	setTimeZone();
	if isServer() then
		SSRLoader.load();
	else
		SSRTimer.add_ms(SSRLoader.onGameStartZombie, SSRLoader.NFO and 3000 or 500, false); -- a) load after 3 seconds or 500 ms
		Events.OnZombieUpdate.Add(SSRLoader.onGameStartZombie); -- b) load after the first zombie update
	end
end

Events.OnGameStart.Add(SSRLoader.init)
Events.OnServerStarted.Add(SSRLoader.init);