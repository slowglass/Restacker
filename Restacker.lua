local name = "Restacker"
local version = "0.2.0"

Restacker = {}
Restacker.langBundle = {}
local langBundle

local LibLang = LibStub('LibLang-0.1')

local StackIcon = [[/esoui/art/campaign/campaign_tabicon_summary]]
local MoveStacks = [[/esoui/art/inventory/inventory_tabicon_quickslot]]
local MoveAll = [[/esoui/art/campaign/campaign_tabicon_history]]

local BACKPACK = 1
local BANK = 2
local BagWindows = {}
BagWindows[BACKPACK]     = ZO_PlayerInventoryBackpack
BagWindows[BANK]         = ZO_PlayerBankBackpack

local Buttons = {}

local function Move(srcBag, srcSlot, destBag, destSlot, num)
	if (num==0) then return end
	local status = true
    ClearCursor()
    CallSecureProtected("PickupInventoryItem", srcBag, srcSlot, num)
    if (status) then status = CallSecureProtected("PlaceInInventory", destBag, destSlot) end
    ClearCursor()
end

local function RecordItem(bag, recorder, slot, recordAll)
	local id = GetItemInstanceId(bag, slot)
	if (id == nil) then return end
	local num, maxNum = GetSlotStackSize(bag, slot)
	if (maxNum<2 and recordAll==false) then return end
	if (num>=maxNum and recordAll==false) then return end

	if (recorder[id] == nil) then
		recorder[id] = { }
	end
	table.insert(recorder[id], slot)
end

local function PrintStackingInfo(msg, bag, slots)
	stacks = ""
	local i; for i = 1, #slots, 1 do
		local num, maxNum = GetSlotStackSize(bag, slots[i])
		if (i~=1) then stacks = stacks..", " end
		stacks = stacks.."["..num.."/".. maxNum.."]"
	end
	langBundle:print(msg, GetItemName(1, slots[1]), stacks)
end

local function PrintInv()
	d("---------------------------------------------")
	d("BACKPACK:"..BACKPACK)
	d("BANK    :"..BANK)
	d("---------------------------------------------")
	for bag = 1,2 do
	d("---------------------------------------------")
	d("BAG:"..bag)
	d("---------------------------------------------")
	local _, numberOfItems = GetBagInfo(bag)
	for slot = 0, numberOfItems do
		local id = GetItemInstanceId(bag, slot)
		local name = GetItemName(bag, slot)
		local link = GetItemLink(bag, slot)
		local num, maxNum = GetSlotStackSize(bag, slot)
		if (name ~= "") then
			d(id .. " : ".. name..": ["..num.."/"..maxNum.."] - "..link)
		end
	end
	end
end

local function Restack(bag, slots)
	local stacks = {}
	local name = GetItemName(bag, slots[1])
	local i; for i = 1, #slots, 1 do
		local num, maxNum = GetSlotStackSize(bag, slots[i])
		table.insert(stacks, "["..num.."/".. maxNum.."]")
	end

	while #slots>1 do
		local fromSlot = slots[#slots]
		local toSlot = slots[1]
		local fromNum = GetSlotStackSize(bag, fromSlot)
		local toNum, toMaxNum = GetSlotStackSize(bag, toSlot)
		local available = math.min(fromNum, toMaxNum-toNum)
		local moveNum = math.min(fromNum, available)
		Move(bag, fromSlot, bag, toSlot, moveNum)
		if moveNum == fromNum then 
			table.remove(slots, #slots) 
		else
			table.remove(slots, 1)
		end
	end

	langBundle:print("RESTACKING", name, table.concat(stacks, ', '))
end

local function RestackTo(srcBag, srcSlots, destBag, destSlots)
	local totalMoved=0
	if (destSlots == nil) then return 0 end
	if (#srcSlots == 0) then return 0 end
	
	for s = 1, #srcSlots do
		for d = 1, #destSlots do
			local fromNum = GetSlotStackSize(srcBag, srcSlots[s])
			local toNum, toMaxNum = GetSlotStackSize(destBag, destSlots[d])
			local available = math.min(fromNum, toMaxNum-toNum)
			local moveNum = math.min(fromNum, available)
			totalMoved = totalMoved + moveNum
			Move(srcBag, srcSlots[s], destBag, destSlots[d], moveNum)
		end
	end
	if (totalMoved>0) then
		local name = GetItemName(srcBag, srcSlots[1])
		langBundle:print("MOVED_FROM_"..srcBag.."_TO_"..destBag, name, totalMoved)
	end
	return totalMoved
end

local function RecordBag(bag, recordAll)
	local recorder = {}
	local _, numberOfItems = GetBagInfo(bag)
	for slot = 0, numberOfItems do
		RecordItem(bag, recorder, slot, recordAll)
	end
	return recorder
end

local function RestackBag(bag)
	local recorder = RecordBag(bag, false)
	for id, slots in pairs(recorder) do 
		if (#slots >1 ) then Restack(bag,slots) end
	end 
end

local function RestackBank(srcBag, destBag)
	local srcBag, destBag = srcBag, destBag
	local srcRecorder = RecordBag(srcBag, false)
	local destRecorder = RecordBag(destBag, false)
	for id, srcSlots in pairs(srcRecorder) do 
		local destSlots = destRecorder[id]
		local totalMoved=RestackTo(srcBag, srcSlots, destBag, destSlots)
	end
end

local function SetMoveButtonsHidden(flag)
	Buttons["Move_"..BACKPACK]:SetHidden(flag)
	Buttons["Move_"..BANK]:SetHidden(flag)
end

local function AddButton(id, bagId, position, visible, icon, callback)
    local parentWindow = BagWindows[bagId]
	local buttonName = parentWindow:GetName() .. "_"..id.."_Bt"
	local bgName = parentWindow:GetName() .. "_"..id.."_Bg"

    local button = WINDOW_MANAGER:CreateControl( buttonName, parentWindow, CT_BUTTON)

    button:SetAnchor(BOTTOMLEFT, parentWindow, BOTTOMLEFT, position, 39)
    button:SetDimensions(42,42)
    button:SetMouseEnabled(true)
    button:SetHidden(visible == false)

    local texture = WINDOW_MANAGER:CreateControl(bgName, button, CT_TEXTURE)
    texture:SetAnchorFill()

    -- Hover Animation
    button:SetHandler("OnMouseEnter", function() texture:SetTexture(icon.."_over.dds") end)
    button:SetHandler("OnMouseExit",  function() texture:SetTexture(icon.."_up.dds") end)
    button:GetHandler("OnMouseExit")()

    -- Attach Callback
    button:SetHandler("OnClicked", callback, "OnClicked")
    Buttons[id.."_"..bagId]=button
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

	if (com[1] == "restack") then RestackBag(BACKPACK); 
	elseif (com[1] == "inv") then PrintInv();
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
	
	AddButton("Stack", BACKPACK, pos+step*2, true, StackIcon, function() RestackBag(BACKPACK) end)
	AddButton("Stack", BANK,     pos+step*2, true, StackIcon, function() RestackBag(BANK) end)
	AddButton("Move", BANK,     pos, false, MoveStacks, function() RestackBank(BANK,BACKPACK) end)
	AddButton("Move", BACKPACK, pos, false, MoveStacks, function() RestackBank(BACKPACK,BANK) end)

	langBundle = LibLang:getBundleHandler()
	langBundle:setLang(GetCVar("language.2") or "en")
	langBundle:addBundle("en", Restacker.langBundle["en"])
	langBundle:print("LOADED")
end

local function Loaded(eventCode, addOnName)
	if(addOnName ~= "Restacker") then return end
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_PLAYER_ACTIVATED, Intro)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_TRADE_SUCCEEDED, function() RestackBank(BACKPACK) end)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_OPEN_BANK, function() SetMoveButtonsHidden(false);  end)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_CLOSE_BANK, function() SetMoveButtonsHidden(true);  end)
	SLASH_COMMANDS["/rs"] = Command

end

EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_ADD_ON_LOADED, Loaded)

