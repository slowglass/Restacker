Slowglass = {}
Slowglass.Restacker = {}

local P;
local Restacker = Slowglass.Restacker
Restacker.name = 'Restacker'
Restacker.author = 'Slowglass'
Restacker.version = '0.8.0'
Restacker.langBundle = {}
Restacker.settings = {}


local StackIcon = [[/esoui/art/campaign/campaign_tabicon_summary]]
local MoveStacks = [[/esoui/art/inventory/inventory_tabicon_quickslot]]
local MoveAll = [[/esoui/art/campaign/campaign_tabicon_history]]

local BACKPACK = 1
local BANK = 2
local Bags = {
	[BACKPACK] = { key="INV", name = "Inventory", window = ZO_PlayerInventoryBackpack },
	[BANK] =     { key="BNK", name = "Bank",      window = ZO_PlayerBankBackpack}
}

local function D(...) if (Restacker.settings["DEBUG"]) then d(...) end end

local Buttons = {}

local function AnnounceTransfer(key,...)
	if (Restacker.settings["ANNOUNCE_TRANSFERS"]) then
		P:print(key,...)
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
	local numberOfItems = GetBagSize(bagId)
	for slot = 0, numberOfItems do
		RecordItem(bagId, records, slot, recordAll)
	end
	return records
end

local function PrintInv(bagId)
	CHAT_SYSTEM:AddMessage("---------------------------------------------")
	P:print("BAG", Bags[bagId].name);
	CHAT_SYSTEM:AddMessage("---------------------------------------------")
	local numberOfItems = GetBagSize(bagId)
	for slot = 0, numberOfItems do
		local itemId = GetItemInstanceId(bagId, slot)
		local name = GetItemName(bagId, slot)
		local link = GetItemLink(bagId, slot)
		local num, maxNum = GetSlotStackSize(bagId, slot)
		if (name ~= "") then
			CHAT_SYSTEM:AddMessage(itemId .. " : ".. link..": ["..num.."/"..maxNum.."]")
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
    local localTooltip = P:translate(tooltip)
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
		z:print("CMD_ERR", text)
		P:print("CMD_DESC")
	end
end

local function Intro()
	EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_PLAYER_ACTIVATED)
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)

	local pos = 244
	local step = 31
	AddButton("Move",  BANK,     pos,        false, MoveStacks, "STACK_BNK_INV", function() StackFromTo(BANK,BACKPACK) end)
	AddButton("Move",  BACKPACK, pos,        false, MoveStacks, "STACK_INV_BNK", function() StackFromTo(BACKPACK,BANK) end)

	D(P:translate("LOADED"))
end

local function TradeSucceded()
	if Restacker.settings["AUTO_STACK_ON_TRADE"] then
		D("Restacking") 
		RestackBag(BACKPACK) 
	else 
		D("Not restacking")
	end
end

local function BankOpened()
	ToggleButtonVisibility("Move", false);
	if Restacker.settings["AUTO_BANK_TRANSFER"] == "ABT_I2B" then
		D("Restacking Inv->Bank") 
		StackFromTo(BACKPACK,BANK)
	elseif Restacker.settings["AUTO_BANK_TRANSFER"] == "ABT_B2I" then
		D("Restacking Bank->Inv")
		StackFromTo(BANK,BACKPACK)
	else
		D("Not restacking")
	end
end

function Restacker:SetDefaults()
	self.defaults = {}
	local d = self.defaults
	d["ANNOUNCE_TRANSFERS"] = true
	d["AUTO_BANK_TRANSFER"] = "ABT_I2B"
	d["AUTO_STACK_ON_TRADE"] = true
	d["DEBUG"] = true
end

function Restacker:CreateOptionsMenu()
	self:SetDefaults()
	local LibSettings = LibStub('LibSettings-0.1')
	local Settings = LibSettings.new("RS_OP", self.langBundle, "Restacker_Settings", self.defaults)
	self.settings = Settings.settings
	Settings:desc(self.name, self.version, self.author, "Desc")
	Settings:header("GENERAL")
	Settings:checkbox("ANNOUNCE_TRANSFERS")
	Settings:checkbox("AUTO_STACK_ON_TRADE")
	Settings:dropdown("AUTO_BANK_TRANSFER", { "ABT_I2B", "ABT_B2I", "ABT_NONE"})
	Settings:header("DEBUG")
	Settings:checkbox("DEBUG")
	Settings:CreateOptionsMenu()
end

local function OnLoad(eventCode, addOnName)
	d("Restacker:C")
	if(addOnName ~= "Restacker") then return end
	local LibLang = LibStub('LibLang-0.2')
	P = LibLang.new(Restacker.langBundle)
	Restacker:CreateOptionsMenu()
    EVENT_MANAGER:UnregisterForEvent("Restacker",EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_PLAYER_ACTIVATED, Intro)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_TRADE_SUCCEEDED, TradeSucceded)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_OPEN_BANK,  BankOpened)
	EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_CLOSE_BANK, function() ToggleButtonVisibility("Move", true);   end)
	SLASH_COMMANDS["/rs"] = Command
end

EVENT_MANAGER:RegisterForEvent("Restacker", EVENT_ADD_ON_LOADED, OnLoad)

