Restacker = {}
function Restacker.Intro()
	EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_PLAYER_ACTIVATED)
	d("Restacker Loaded")
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
end

function Restacker.Loaded(eventCode, addOnName)
	if(addOnName ~= "Restacker") then return end

	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_PLAYER_ACTIVATED,Restacker.Intro)
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_ADD_ON_LOADED, Restacker.Loaded)
