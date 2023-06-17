-- Grab the ID for the last desktop, which is assumed to be the most recently create one
function getLargestDesktopKey()
	rawSpaceNames = hs.spaces.missionControlSpaceNames()
	for key, value in pairs(rawSpaceNames) do
		uuid = key
	end
	spaceNames = rawSpaceNames[uuid]
	for _, nested_table in pairs(rawSpaceNames) do
		for __, value in pairs(nested_table) do
			desktopNum = string.match(value, "Desktop (%d+)")
			if desktopNum ~= nil then
				desktopNum = tonumber(desktopNum)
				if largestDesktop == nil or desktopNum > largestDesktop then
					largestDesktop = desktopNum
				end
			end
		end
	end
	desktop = string.format("select Desktop %d", largestDesktop)
	desktopKey = nil
	for key, value in pairs(spaceNames) do
		if value == desktop then
			return key
		end
	end
	return nil
end

-- Create a new space and stick a fresh Chrome window in it
-- Define a hotkey to trigger the script
hs.hotkey.bind({ "cmd", "ctrl", "alt" }, "N", function()
	-- Add new space, find its key
	hs.spaces.addSpaceToScreen(true)
	largestDesktopKey = getLargestDesktopKey()
	if largestDesktopKey ~= nil then
		-- Finally, focus that desktop
		hs.spaces.gotoSpace(largestDesktopKey)
	end
end, 0.2)
