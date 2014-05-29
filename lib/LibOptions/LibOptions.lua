local Options, VERSION = LibStub:NewLibrary("LibOptions-0.1", 1)

-- Early exit if this is same or older version of existing library
if not Options then return end	 
Options.__index = Options

function Options.new(id, name, settings, langBundle, prefix)
	if _G[controlPanelID] then
		-- Error Options id has already been registered
		return nil
	end
	local obj = {}
	obj.wm = GetWindowManager()
	obj.window = ZO_OptionsWindowSettingsScrollChild
	obj.settings = settings
	obj.langBundle = langBundle
	obj.prefix = prefix
	obj.id = id
	obj.widgetCount = 1
	ZO_OptionsWindow_AddUserPanel(id, langBundle:translate(prefix.."_"..name))
	obj.id = _G[id]
	return setmetatable(obj, Options)
end

function Options:getNextWidgetName()
	self.widgetCount = self.widgetCount + 1;
	return self.id.."_"..self.widgetCount
end

function Options:PopulateUIWidget(widget, controlType, key)
	widget.controlType = controlType
	widget.system = SETTING_TYPE_UI
	widget.panel = self.id
	widget.text = self.langBundle:translate(self.prefix..key.."_LABEL")
	widget.tooltipText = self.langBundle:translate(self.prefix..key.."_TOOLTIP")
end

function Options:AddHeader(text)
	local name = self:getNextWidgetName()
	local controlType = self.lastAddedControl and "ZO_Options_SectionTitle_WithDivider" or "ZO_Options_SectionTitle"
	local header = self.wm:CreateControlFromVirtual(name, self.window, controlType)
	header.controlType = OPTIONS_SECTION_TITLE
	header.panel = self.id
	header.text = self.langBundle:translate(self.prefix..text)
	if self.lastAddedControl then
		header:SetAnchor(TOPLEFT, self.lastAddedControl, BOTTOMLEFT, 0, 15)
	else
		header:SetAnchor(TOPLEFT)
	end
	
	ZO_OptionsWindow_InitializeControl(header)
	self.lastAddedControl = header
end

function Options:AddCheckbox(key)
	local name = self:getNextWidgetName()
	local controlType = "ZO_Options_Checkbox"
	local checkbox = self.wm:CreateControlFromVirtual(name, self.window, controlType)
	self:PopulateUIWidget(checkbox, OPTIONS_CHECKBOX, key)
	checkbox:SetAnchor(TOPLEFT, self.lastAddedControl, BOTTOMLEFT, 0, 6)
	
	local checkboxButton = checkbox:GetNamedChild("Checkbox")
	local settings = self.settings
	local function OnShow() 
		checkboxButton:SetState(settings[key] and 1 or 0); 
		checkboxButton:toggleFunction(settings[key]) 
	end 
	local function onClick() settings[key] = not settings[key] end 
	ZO_PreHookHandler(checkbox, "OnShow", OnShow)
	ZO_PreHookHandler(checkboxButton, "OnClicked", onClick)
	ZO_OptionsWindow_InitializeControl(checkbox)
	self.lastAddedControl = checkbox
end


function Options:AddChoice(key, options)
	local name = self:getNextWidgetName()
	local controlType = "ZO_Options_Dropdown"
	local dropdown = self.wm:CreateControlFromVirtual(name, self.window, controlType)
	self:PopulateUIWidget(dropdown, OPTIONS_DROPDOWN, key)
	dropdown:SetAnchor(TOPLEFT, self.lastAddedControl, BOTTOMLEFT, 0, 6)

	local forwardMap, reverseMap, mappedOptions = {}, {}, {}
	for _, option in pairs(options) do 
		local trans = self.langBundle:translate(self.prefix..option)
		mappedOptions[#mappedOptions+1] = trans
		forwardMap[option] = trans
		reverseMap[trans] = option
	end
	dropdown.valid = mappedOptions

	local dropmenu = ZO_ComboBox_ObjectFromContainer(GetControl(dropdown, "Dropdown"))
	local settings = self.settings
	local selectedName
	local function OnTextChanged(self) 
		if dropmenu.m_selectedItemData then
				selectedName = dropmenu.m_selectedItemData.name
				dropmenu.m_selectedItemText.SetText(self, selectedName)
				settings[key] = reverseMap[selectedName]
		end
	end
	local function OnShow() dropmenu:SetSelectedItem(forwardMap[settings[key]]) end
	ZO_PreHookHandler(dropmenu.m_selectedItemText, "OnTextChanged", OnTextChanged)
	dropdown:SetHandler("OnShow", OnShow)
	
	ZO_OptionsWindow_InitializeControl(dropdown)
	
	self.lastAddedControl = dropdown
end

