local name = "Restacker"
local version = "0.2.0"

Restacker = {}
Restacker.langBundle = {}
local langBundle

local LibLang = LibStub('LibLang-0.1')

local StackIcon = [[/esoui/art/campaign/campaign_tabicon_summary]]
local MoveStacks = [[/esoui/art/inventory/inventory_tabicon_quickslot]]
local MoveAll = [[/esoui/art/campaign/campaign_tabicon_history]]

local BagWindows = {}
BagWindows[INVENTORY_BANK]     = ZO_PlayerBank
BagWindows[INVENTORY_BACKPACK] = ZO_PlayerInventory


local function Move(from, to, num)
	local status = true
    ClearCursor()
    CallSecureProtected("PickupInventoryItem", 1, from, num)
    if (status) then status = CallSecureProtected("PlaceInInventory", 1, to) end
    ClearCursor()
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

local function PrintDetails(msg, slots)
	stacks = ""
	local i; for i = 1, #slots, 1 do
		local slot = slots[i]
		local name = GetItemName(1, slot)
		local link = GetItemLink(1, slot)
		local num, maxNum = GetSlotStackSize(1, slot)

		if (i~=1) then stacks = stacks..", " end
		stacks = stacks.."["..num.."/".. maxNum.."]"
	end
	langBundle:print(msg, GetItemName(1, slots[1]), stacks)
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
	langBundle:print("EVALUATION")
	for key, slots in pairs(recorder) do 
		if (#slots >1 ) then 
			PrintDetails("RESTACK_AVAILABLE", slots)
		end
	end
end

local function Restack(slots)
	PrintDetails("RESTACKING", slots)
	
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

local function RestackBag()
	local recorder = {}
	local _, numberOfItems = GetBagInfo(1)
	for slot = 0, numberOfItems do
		RecordItem(recorder, slot)
	end
	for id, slots in pairs(recorder) do 
		if (#slots >1 ) then Restack(slots) end
	end 
end

local function AddButton(id, bagId, position, icon, callback)
    local parentWindow = BagWindows[bagId]
	local buttonName = parentWindow:GetName() .. "_"..id.."_Bt"
	local bgName = parentWindow:GetName() .. "_"..id.."_Bg"

    local button = WINDOW_MANAGER:CreateControl( buttonName, parentWindow, CT_BUTTON)

    button:SetAnchor(BOTTOMLEFT, parentWindow, BOTTOMLEFT, position, 39)
    button:SetDimensions(42,42)
    button:SetMouseEnabled(true)
    --button:SetFont("ZoFontGameSmall")

    local texture = WINDOW_MANAGER:CreateControl(bgName, button, CT_TEXTURE)
    texture:SetAnchorFill()
    --texture:SetTexture(icon.."_up.dds")

    button:SetHandler("OnClicked", callback, "OnClicked")

    -- Hover Animation
    button:SetHandler("OnMouseEnter", function() texture:SetTexture(icon.."_over.dds") end)
    button:SetHandler("OnMouseExit",  function() texture:SetTexture(icon.."_up.dds") end)
    button:GetHandler("OnMouseExit")()
end

local function CommandError()
	langBundle:print("CMD_DESC")
end

local function Command(text)
	if text == nil then text="" end;
	local com = {}
	for word in string.gmatch(text,"%w+") do  
  		table.insert(com, word)
	end

	if (com[1] == "restack") then RestackBag(); 
	elseif (com[1] == "inv") then PrintInv();
	elseif (com[1] == "evaluate") then PrintMovable();
	else
		langBundle:print("CMD_ERR", text)
		CommandError()
	end
end

local function Intro()
	local pos = 244
	local step = 31
	EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
	
	AddButton("Stack", INVENTORY_BACKPACK, pos+step*2, StackIcon, RestackBag)

	-- AddButton("Move", ZO_PlayerBank, INVENTORY_BANK,  pos,        MoveStacks)
	-- AddButton("MoveAll", ZO_PlayerBank, INVENTORY_BANK,  pos-step,   MoveAll)
	-- AddButton("Stack", ZO_PlayerBank, INVENTORY_BANK,  pos+step*2, StackIcon)

	langBundle = LibLang:getBundleHandler()
	langBundle:setLang(GetCVar("language.2") or "en")
	langBundle:addBundle("en", Restacker.langBundle["en"])
	langBundle:print("LOADED")
end

local function Loaded(eventCode, addOnName)
	if(addOnName ~= "Restacker") then return end

	-- 
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_PLAYER_ACTIVATED, Intro)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_TRADE_SUCCEEDED, RestackBag)
	SLASH_COMMANDS["/rs"] = Command

end

EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_ADD_ON_LOADED, Loaded)

