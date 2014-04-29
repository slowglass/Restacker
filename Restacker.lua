﻿local name = "Restacker"
local version = "0.1.1"

local function Intro()
	EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
	d(LibLang:print("RESTACK_AVAILABLE"))
end

local function RecordItem(recorder, slot)
	local id = GetItemInstanceId(1, slot)
	if (id == nil) then return end
	local num, maxNum = GetSlotStackSize(1, slot)
	if (maxNum<2) then return end
	if (num>=maxNum) then return end

	if (recorder[id] == nil) then
		recorder[id] = { }
	end
	table.insert(recorder[id], slot)
end

local function MoveError(msg, from, to)
	d("|cFF0000Restacker Error: ".. msg)
	if (from ~= nil) then d("|cFF0000   ".. LibLang:print("SRC_ITEM", from)) end
	if (to ~= nil) then   d("|cFF0000   ".. LibLang:print("DST_ITEM", to)) end
end

local function Move(from, to, num)
	local status = true
    ClearCursor()
    CallSecureProtected("PickupInventoryItem", 1, from, num)
    if (status) then status = CallSecureProtected("PlaceInInventory", 1, to) end
    ClearCursor()
end

local function PrintDetails(msg, slots)
	msg = LibLang:print(msg, GetItemName(1, slots[1]))
	msg = msg....": "
	local i; for i = 1, #slots, 1 do
		local slot = slots[i]
		local name = GetItemName(1, slot)
		local link = GetItemLink(1, slot)
		local num, maxNum = GetSlotStackSize(1, slot)

		if (i~=1) then msg = msg..", " end
		msg = msg.."["..num.."/".. maxNum.."]"
	end
	return msg
end

local function Restack(slots)
	d("   |c00FF00"..PrintDetails("RESTACKING", slots))
	
	while #slots>1 do
		local fromSlot = slots[#slots]
		local toSlot = slots[1]
		local fromNum = GetSlotStackSize(1, fromSlot)
		local toNum, toMaxNum = GetSlotStackSize(1, slot)
		local available = math.min(fromNum, toMaxNum-toNum)
		local moveNum = math.min(fromNum, available)
		Move(fromSlot, toSlot, moveNum)
		if moveNum == fromNum then table.remove(slots, #slots) end
		if moveNum == available then table.remove(slots, 1) end
	end
end

local function TradeSucceded()
	local recorder = {}
	local _, numberOfItems = GetBagInfo(1)
	for slot = 0, numberOfItems do
		RecordItem(recorder, slot)
	end
	for id, slots in pairs(recorder) do 
		if (#slots >1 ) then Restack(slots) end
	end 
end

local function PrintInv()
	local _, numberOfItems = GetBagInfo(1)
	for slot = 0, numberOfItems do
		local id = GetItemInstanceId(1, slot)
		local name = GetItemName(1, slot)
		local link = GetItemLink(1, slot)
		local num, maxNum = GetSlotStackSize(1, slot)
		if (name ~= "") then
			d(id .. " : ".. name..": ["..num.."/"..maxNum.."] - "..link)
		end
	end
end


local function PrintMovable()
	local recorder = {}
	local _, numberOfItems = GetBagInfo(1)
	for slot = 0, numberOfItems do
		RecordItem(recorder, slot)
	end
	LibLang:print("RESTACK_EVAL")
	for key, slots in pairs(recorder) do 
		if (#slots >1 ) then 
			d("   |c00FF00"..PrintDetails("RESTACK_AVAILABLE", slots))
		end
	end
end

local function CommandError()
	d(LibLang:print("CMD_DESC"))
end

local function Command(text)
	if text == nil then text="" end;
	local com = {}
	for word in string.gmatch(text,"%w+") do  
  		table.insert(com, word)
	end

	if (com[1] == "restack") then TradeSucceded(); 
	elseif (com[1] == "inv") then PrintInv();
	elseif (com[1] == "evaluate") then PrintMovable();
	else
		d(LibLang:print("CMD_ERR", text))
		CommandError()
	end
end

local function Loaded(eventCode, addOnName)
	if(addOnName ~= "Restacker") then return end

	LibLang:setLang("en")
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_PLAYER_ACTIVATED, Intro)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_TRADE_SUCCEEDED, TradeSucceded)
	SLASH_COMMANDS["/rs"] = Command
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
end

function Restacker:addLangBundle(lang,bundle)
	LibLang.addBundle(lang,bundle)
end

EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_ADD_ON_LOADED, Loaded)

