local name = "Restacker"
local version = "0.6.0"

Restacker = {}
Restacker.langBundle = {}
local langBundle

local LibLang = LibStub('LibLang-0.1')
local LAM = LibStub('LibAddonMenu-1.0')

local StackIcon = [[/esoui/art/campaign/campaign_tabicon_summary]]
local MoveStacks = [[/esoui/art/inventory/inventory_tabicon_quickslot]]
local MoveAll = [[/esoui/art/campaign/campaign_tabicon_history]]

local BACKPACK = 1
local BANK = 2
local Bags = {
	[BACKPACK] = { key="INV", name = "Inventory", window = ZO_PlayerInventoryBackpack },
	[BANK] =     { key="BNK", name = "Bank",      window = ZO_PlayerBankBackpack}
}

local Buttons = {}
local settings = {}
local defaultsSettings = {
		["DEBUG"] = true,
		["ANNOUNCE_TRANSFERS"] = true,
		["AUTO_TRADE_TRANSFER"] = true,
		["AUTO_BANK_TRANSFER"] = "ABT_NONE"
}

local function D(...)
	if (settings["DEBUG"]) then
		d(...)
	end
end

local function TidyupSavedVars(settings, defaultSettings)
	for key in pairs(settings) do
		if (defaultSettings[key] == nil) then
			settings[key] = nil
    	end
    end
end

local function AnnounceTransfer(key,...)
	if (settings["ANNOUNCE_TRANSFERS"]) then
		langBundle:print(key,...)
	end
end

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
	local totalMoved=0
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
		totalMoved = totalMoved + numToMove
		if numToMove == numInSrc then 
			table.remove(slots, #slots) 
		else
			table.remove(slots, 1)
		end
	end
	if (totalMoved >0) then AnnounceTransfer("RESTACKING", name, table.concat(stacks, ', ')) end
	return totalMoved
end

local function RestackBag(bagId)
	AnnounceTransfer("RESTACK_"..Bags[bagId].key) 
	local totalMoved=0
	local recorder = RecordBag(bagId, false)
	for id, slots in pairs(recorder) do 
		if (#slots >1 ) then 
			totalMoved = totalMoved+RestackItem(bagId,slots) 
		end
	end
	if (totalMoved==0) then AnnounceTransfer("NOTHING_MOVED") end
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
		AnnounceTransfer("MOVED_FROM_"..srcBagId.."_TO_"..destBagId, name, totalMoved)
	end
	return totalMoved
end

local function StackFromTo(srcBagId, destBagId)
	AnnounceTransfer("STACK_"..Bags[srcBagId].key.."_"..Bags[destBagId].key)
	local totalMoved = 0
	local srcRecorder = RecordBag(srcBagId, false)
	local destRecorder = RecordBag(destBagId, false)
	for id, srcSlots in pairs(srcRecorder) do 
		local destSlots = destRecorder[id]
		totalMoved = totalMoved+StackItemFromTo(srcBagId, srcSlots, destBagId, destSlots)
	end
	if (totalMoved==0) then AnnounceTransfer("NOTHING_MOVED") end
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

local function LoadLangBundle()
	langBundle = LibLang:getBundleHandler()
	langBundle:setLang(GetCVar("language.2") or "en")
	langBundle:addBundle("en", Restacker.langBundle["en"])
	langBundle:addBundle("de", Restacker.langBundle["de"])
	langBundle:addBundle("fr", Restacker.langBundle["fr"])
end

local function AddOptionsCheckbox(panel, key)
	local pn = "RESTACKER_ADDON_OPTIONS_"

	LAM:AddCheckbox(panel, pn..key, 
		langBundle:translate("OP:"..key.."_LB"), langBundle:translate("OP:"..key.."_TT"),
		function() return settings[key] end,
		function(value) settings[key]=value end)
end

local function AddOptionsDropdown(panel, key, options)
	local _
	local optionsArr = {}
	local optionsForwardMap = {}
	local optionsReverseMap = {}

	for _, option in pairs(options) do 
		local trans = langBundle:translate("OP:"..option)
		optionsArr[#optionsArr+1] = trans
		optionsForwardMap[option] = trans
		optionsReverseMap[trans] = option
	end
	local pn = "RESTACKER_ADDON_OPTIONS_"

	LAM:AddDropdown(panel, pn..key, 
		langBundle:translate("OP:"..key.."_LB"), langBundle:translate("OP:"..key.."_TT"),
		optionsArr, 
		function() return optionsForwardMap[settings[key]] end,
		function(value) settings[key]=optionsReverseMap[value] end)
end

local function CreateOptionsMenu()
	local panel = LAM:CreateControlPanel("RESTACKER_ADDON_OPTIONS", langBundle:translate("OP:TITLE"))
	LAM:AddHeader(panel, "RESTACKER_ADDON_OPTIONS_GENERAL_HDR", langBundle:translate("OP:GENERAL"))
	AddOptionsCheckbox(panel, "ANNOUNCE_TRANSFERS")
	AddOptionsCheckbox(panel, "AUTO_TRADE_TRANSFER")
	AddOptionsDropdown(panel, "AUTO_BANK_TRANSFER", 
		{"ABT_NONE", "ABT_I2B",  "ABT_B2I"})

	LAM:AddHeader(panel, "RESTACKER_ADDON_OPTIONS_DEBUG_HDR", langBundle:translate("OP:DEBUG"))
	AddOptionsCheckbox(panel, "DEBUG")
end

local function Intro()
	LoadLangBundle()

	settings = ZO_SavedVars:New("Restacker_Settings", 1, nil, defaultsSettings)
	TidyupSavedVars(settings, defaultsSettings)
    CreateOptionsMenu()

	EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)

	local pos = 244
	local step = 31
	AddButton("Stack", BACKPACK, pos+step*2, true,  StackIcon,  "RESTACK_INV",   function() RestackBag(BACKPACK) end)
	AddButton("Stack", BANK,     pos+step*2, true,  StackIcon,  "RESTACK_BNK",   function() RestackBag(BANK) end)
	AddButton("Move",  BANK,     pos,        false, MoveStacks, "STACK_BNK_INV", function() StackFromTo(BANK,BACKPACK) end)
	AddButton("Move",  BACKPACK, pos,        false, MoveStacks, "STACK_INV_BNK", function() StackFromTo(BACKPACK,BANK) end)

	D(langBundle:translate("LOADED"))
end

local function TradeSucceded()
	if settings["AUTO_TRADE_TRANSFER"] then
		D("Restacking") 
		RestackBag(BACKPACK) 
	else 
		D("Not restacking")
	end
end

local function BankOpened()
	ToggleButtonVisibility("Move", false);
	if settings["AUTO_BANK_TRANSFER"] == "ABT_I2B" then
		D("Restacking Inv->Bank") 
		StackFromTo(BACKPACK,BANK)
	elseif settings["AUTO_BANK_TRANSFER"] == "ABT_B2I" then
		D("Restacking Bank->Inv")
		StackFromTo(BANK,BACKPACK)
	else
		D("Not restacking")
	end
end

local function Loaded(eventCode, addOnName)
	if(addOnName ~= "Restacker") then return end
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_PLAYER_ACTIVATED, Intro)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_TRADE_SUCCEEDED, TradeSucceded)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_OPEN_BANK,  BankOpened)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_CLOSE_BANK, function() ToggleButtonVisibility("Move", true);   end)
	SLASH_COMMANDS["/rs"] = Command

end

EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_ADD_ON_LOADED, Loaded)

