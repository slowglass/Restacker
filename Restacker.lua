﻿local name = "Restacker"
local version = "0.3.2"

Restacker = {}
Restacker.langBundle = {}
local langBundle

local LibLang = LibStub('LibLang-0.1')

local StackIcon = [[/esoui/art/campaign/campaign_tabicon_summary]]
local MoveStacks = [[/esoui/art/inventory/inventory_tabicon_quickslot]]
local MoveAll = [[/esoui/art/campaign/campaign_tabicon_history]]

local BACKPACK = 1
local BANK = 2
local Bags = {
	[BACKPACK] = { name = "Inventory", window = ZO_PlayerInventoryBackpack },
	[BANK] =     { name = "Bank",      window = ZO_PlayerBankBackpack}
}

local Buttons = {}

local function MoveStack(srcBagId, srcSlot, destBagId, destSlot, num)
	if (num==0) then return end
	local status = true
    ClearCursor()
    CallSecureProtected("PickupInventoryItem", srcBagId, srcSlot, num)
    if (status) then status = CallSecureProtected("PlaceInInventory", destBagId, destSlot) end
    ClearCursor()
end

local function RecordItem(bagId, records, slot, recordAll)
	local itemId = GetItemInstanceId(bagId, slot)
	if (itemId == nil) then return end
	local num, maxNum = GetSlotStackSize(bagId, slot)
	if (maxNum<2 and recordAll==false) then return end
	if (num>=maxNum and recordAll==false) then return end

	if (records[itemId] == nil) then
		records[itemId] = { }
	end
	table.insert(records[itemId], slot)
end

local function RecordBag(bagId, recordAll)
	local records = {}
	local _, numberOfItems = GetBagInfo(bagId)
	for slot = 0, numberOfItems do
		RecordItem(bagId, records, slot, recordAll)
	end
	return records
end

local function PrintInv(bagId)
	d("---------------------------------------------")
	langBundle:print("BAG", Bags[bagId].name);
	d("---------------------------------------------")
	local _, numberOfItems = GetBagInfo(bagId)
	for slot = 0, numberOfItems do
		local itemId = GetItemInstanceId(bagId, slot)
		local name = GetItemName(bagId, slot)
		local link = GetItemLink(bagId, slot)
		local num, maxNum = GetSlotStackSize(bagId, slot)
		if (name ~= "") then
			d(itemId .. " : ".. name..": ["..num.."/"..maxNum.."] - "..link)
		end
	end
end

local function RestackItem(bagId, slots)
	local stacks = {}
	local name = GetItemName(bagId, slots[1])
	local i; for i = 1, #slots, 1 do
		local num, maxNum = GetSlotStackSize(bagId, slots[i])
		table.insert(stacks, "["..num.."/".. maxNum.."]")
	end

	while #slots>1 do
		local srcSlot = slots[#slots]
		local destSlot = slots[1]
		local numInSrc = GetSlotStackSize(bagId, srcSlot)
		local numInDest, maxNumInDest = GetSlotStackSize(bagId, destSlot)
		local numToMove = math.min(numInSrc, maxNumInDest-numInDest)
		MoveStack(bagId, srcSlot, bagId, destSlot, numToMove)
		if numToMove == numInSrc then 
			table.remove(slots, #slots) 
		else
			table.remove(slots, 1)
		end
	end

	langBundle:print("RESTACKING", name, table.concat(stacks, ', '))
end

local function RestackBag(bagId)
	local recorder = RecordBag(bagId, false)
	for id, slots in pairs(recorder) do 
		if (#slots >1 ) then RestackItem(bagId,slots) end
	end 
end

local function StackItemFromTo(srcBagId, srcSlots, destBagId, destSlots)
	local totalMoved=0
	if (destSlots == nil) then return 0 end
	if (#srcSlots == 0) then return 0 end
	
	for s = 1, #srcSlots do
		for d = 1, #destSlots do
			local numInSrc = GetSlotStackSize(srcBagId, srcSlots[s])
			local numInDest, maxNumInDest = GetSlotStackSize(destBagId, destSlots[d])
			local numToMove = math.min(numInSrc, maxNumInDest-numInDest)
			totalMoved = totalMoved + numToMove
			MoveStack(srcBagId, srcSlots[s], destBagId, destSlots[d], numToMove)
		end
	end
	if (totalMoved>0) then
		local name = GetItemName(srcBagId, srcSlots[1])
		langBundle:print("MOVED_FROM_"..srcBagId.."_TO_"..destBagId, name, totalMoved)
	end
	return totalMoved
end

local function StackFromTo(srcBagId, destBagId)
	local srcRecorder = RecordBag(srcBagId, false)
	local destRecorder = RecordBag(destBagId, false)
	for id, srcSlots in pairs(srcRecorder) do 
		local destSlots = destRecorder[id]
		local totalMoved=StackItemFromTo(srcBagId, srcSlots, destBagId, destSlots)
	end
end

local function ToggleButtonVisibility(buttonSet, flag)
	local _, button
	for _,button in pairs(Buttons[buttonSet]) do
    	button:SetHidden(flag)
    end
end

local function AddButton(buttonSet, bagId, position, visible, icon, tooltip, callback)
    local parentWindow = Bags[bagId].window
	local buttonName = parentWindow:GetName() .. "_"..buttonSet.."_Bt"
	local bgName = parentWindow:GetName() .. "_"..buttonSet.."_Bg"

    local button = WINDOW_MANAGER:CreateControl( buttonName, parentWindow, CT_BUTTON)
 	if (Buttons[buttonSet] == nil) then Buttons[buttonSet]={} end
    table.insert(Buttons[buttonSet], button)

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

    -- Setup Tooltip
    local localTooltip = langBundle:translate(tooltip)
	button:SetHandler("OnMouseEnter", function(self) ZO_Tooltips_ShowTextTooltip(self, TOP, localTooltip) end)
	button:SetHandler("OnMouseExit",  function(self) ZO_Tooltips_HideTextTooltip() end)
end


local function Command(text)
	if text == nil then text="" end;
	local com = {}
	for word in string.gmatch(text,"%w+") do  
  		table.insert(com, word)
	end

	if (com[1] == "restack") then RestackBag(BACKPACK); 
	elseif (com[1] == "show" and com[2]=="inv") then PrintInv(BACKPACK);
	elseif (com[1] == "show" and com[2]=="bank") then PrintInv(BANK);
	elseif (com[1] == "help") then PrintInv();
	else
		langBundle:print("CMD_ERR", text)
		langBundle:print("CMD_DESC")
	end
end

local function Intro()
	local pos = 244
	local step = 31
	EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
	
	langBundle = LibLang:getBundleHandler()
	langBundle:setLang(GetCVar("language.2") or "en")
	langBundle:addBundle("en", Restacker.langBundle["en"])

	AddButton("Stack", BACKPACK, pos+step*2, true,  StackIcon,  "RESTACK_INV",   function() RestackBag(BACKPACK) end)
	AddButton("Stack", BANK,     pos+step*2, true,  StackIcon,  "RESTACK_BNK",   function() RestackBag(BANK) end)
	AddButton("Move",  BANK,     pos,        false, MoveStacks, "STACK_INV_BNK", function() StackFromTo(BANK,BACKPACK) end)
	AddButton("Move",  BACKPACK, pos,        false, MoveStacks, "STACK_BNK_INV", function() StackFromTo(BACKPACK,BANK) end)

	langBundle:print("LOADED")
end

local function Loaded(eventCode, addOnName)
	if(addOnName ~= "Restacker") then return end
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_PLAYER_ACTIVATED, Intro)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_TRADE_SUCCEEDED, function() RestackBank(BACKPACK) end)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_OPEN_BANK,  function() ToggleButtonVisibility("Move", false);  end)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_CLOSE_BANK, function() ToggleButtonVisibility("Move", true);   end)
	SLASH_COMMANDS["/rs"] = Command

end

EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_ADD_ON_LOADED, Loaded)

