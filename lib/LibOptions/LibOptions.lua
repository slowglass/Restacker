local Options, VERSION = LibStub:NewLibrary("LibOptions-0.1", 1)

-- Early exit if this is same or older version of existing library
if not Options then return end	 
Options.__index = Options

function Options.new(id,name,settings, langBundle)
	if _G[controlPanelID] then
		-- Error Options id has already been registered
		return nil
	end
	local obj = {}
	obj.wm = GetWindowManager()
	obj.window = ZO_OptionsWindowSettingsScrollChild
	obj.settings = settings
	obj.langBundle = langBundle
	ZO_OptionsWindow_AddUserPanel(id, name)
	obj.id = _G[id]
	return setmetatable(obj, Options)
end

function Options:PopulateUIWidget(widget, controlType, name, text, tooltip)
	window.controlType = controlType
	checkbox.system = SETTING_TYPE_UI
	checkbox.panel = self.id
	checkbox.text = langBundle:translate(text)
	if tooltip then checkbox.tooltipText = langBundle:translate(tooltip) end
end

function Options:AddHeader(name, text)
	local controlType = self.lastAddedControl and "ZO_Options_SectionTitle_WithDivider" or "ZO_Options_SectionTitle"
	local header = self.wm:CreateControlFromVirtual(name, self.window, titleType)
	header.controlType = OPTIONS_SECTION_TITLE
	header.panel = self.id
	header.text = langBundle:translate(text)
	if self.lastAddedControl then
		header:SetAnchor(TOPLEFT, self.lastAddedControl, BOTTOMLEFT, 0, 15)
	else
		header:SetAnchor(TOPLEFT)
	end
	
	ZO_OptionsWindow_InitializeControl(header)
	self.lastAddedControl = header
end

function Options:AddCheckbox(name, text, tooltip, key)
	local controlType = "ZO_Options_Checkbox"
	local checkbox = self.wm:CreateControlFromVirtual(name, self.window, controlType)
	self.PopulateUIWidget(checkbox, OPTIONS_CHECKBOX, text, tooltip)
	checkbox:SetAnchor(TOPLEFT, self.lastAddedControl, BOTTOMLEFT, 0, 6)
	
	local checkboxButton = checkbox:GetNamedChild("Checkbox")
	local function OnShow() 
		checkboxButton:SetState(self.settings[key] and 1 or 0); 
		checkboxButton:toggleFunction(self.settings[key]) 
	end 
	local function onClick() self.settings[key] = not self.settings[key] end 
	ZO_PreHookHandler(checkbox, "OnShow", OnShow)
	ZO_PreHookHandler(checkboxButton, "OnClicked", onClick)
	ZO_OptionsWindow_InitializeControl(checkbox)
	self.lastAddedControl = checkbox
end


function Options:AddChoice(name, text, tooltip, prefix, options, key)
	local controlType = "ZO_Options_Dropdown"
	local dropdown = self.wm:CreateControlFromVirtual(name, optionsWindow, controlType)
	self.PopulateUIWidget(checkbox, OPTIONS_DROPDOWN, text, tooltip)
	dropdown:SetAnchor(TOPLEFT, self.lastAddedControl, BOTTOMLEFT, 0, 6)
	

	local forwardMap, reverseMap, mappedOptions
	for _, option in pairs(options) do 
		local trans = langBundle:translate(prefix..option)
		mappedOptions[#mappedOptions+1] = trans
		forwardMap[option] = trans
		reverseMap[trans] = option
	end
	dropdown.valid = mappedOptions

	local dropmenu = ZO_ComboBox_ObjectFromContainer(GetControl(dropdown, "Dropdown"))
	local selectedName
	local function OnTextChanged() 
		if dropmenu.m_selectedItemData then
				selectedName = dropmenu.m_selectedItemData.name
				dropmenu.m_selectedItemText.SetText(self, selectedName)
				self.settings[key] = reverseMap[selectedName]
		end
	end
	local function OnShow() ZO_ComboBox_ObjectFromContainer.SetSelectedItem(forwardMap[self.settings[key]]) end
	ZO_PreHookHandler(dropmenu.m_selectedItemText, "OnTextChanged", OnTextChanged)
	dropdown:SetHandler("OnShow", OnShow)
	
	ZO_OptionsWindow_InitializeControl(dropdown)
	
	self.lastAddedControl = dropdown
end

