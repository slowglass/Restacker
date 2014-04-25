local name = "Restacker"
local version = "0.0.1"

local function Intro()
	EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_PLAYER_ACTIVATED)
	d("Restacker Loaded")
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
end

local function RecordItem(recorder, id, slot)
{
	local id = GetItemInstanceId(1, slot)
	if (id == nil) then return end
	local num, maxNum = GetSlotStackSize(1. slot)
	if (maxNum<2) then return end
	if (num>=maxNum) then return end

	if (recorder[id] == nil) then
		recorder[id] = { }
	end
	table.insert(recorder[id], slot)
}

local function Restack(slots)
{
	d("Duplicate items")
	for slot in pairs(slots) do
		local name = GetItemName(1, slot)
		local link = GetItemLink(1, slot)
		local num, maxNum = GetSlotStackSize(1. slot)
		d(name..": ["..num.."/".."] - "..link)
	end
}

local function TradeSucceded()
	local recorder = {}
	local _, numberOfItems = GetBagInfo(1)
	for slot = 0, numberOfItems do
		RecordItem(recorder, slot)
	end
	for slots in pairs(recorder) do 
		if (#slots >1 ) then Restack(slots) end
	end 
end

function Loaded(eventCode, addOnName)
	if(addOnName ~= "Restacker") then return end

	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_PLAYER_ACTIVATED, Intro)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_TRADE_SUCCEEDED, TradeSucceded)
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_ADD_ON_LOADED, Loaded)

