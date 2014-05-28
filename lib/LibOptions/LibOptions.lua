
-- Good example to use a real class
-- Instance variables -
--   lastWidgetAdded
--   langBundle
--   settings
-- Methods
--    create
--    addTitle
--    addHeading
--    addBool
--    addChoice




lam.lastAddedControl = {}
local lastAddedControl = lam.lastAddedControl
local wm = GetWindowManager()
local optionsWindow = ZO_OptionsWindowSettingsScrollChild

function lam:CreateControlPanel(controlPanelID, controlPanelName)
	local panelID
	
	if _G[controlPanelID] then
		panelID = _G[controlPanelID]
		return panelID
	end
	
	ZO_OptionsWindow_AddUserPanel(controlPanelID, controlPanelName)

	return panelID
end

function lam:AddFirstHeader(panelID, controlName, text)
	local header = wm:CreateControlFromVirtual(controlName, optionsWindow, "ZO_Options_SectionTitle")
	header:SetAnchor(TOPLEFT)
	header.controlType = OPTIONS_SECTION_TITLE
	header.panel = panelID
	header.text = text
	
	ZO_OptionsWindow_InitializeControl(header)
	
	lastAddedControl[panelID] = header
	
	return header
end

function lam:AddHeader(panelID, controlName, text)
	local header = wm:CreateControlFromVirtual(controlName, optionsWindow, "ZO_Options_SectionTitle_WithDivider")
	header:SetAnchor(TOPLEFT, lastAddedControl[panelID], BOTTOMLEFT, 0, 15)
	header.controlType = OPTIONS_SECTION_TITLE
	header.panel = panelID
	header.text = text
	
	ZO_OptionsWindow_InitializeControl(header)
	
	lastAddedControl[panelID] = header
	
	return header
end


function lam:AddDropdown(panelID, controlName, text, tooltip, validChoices, getFunc, setFunc, warning, warningText)
	local dropdown = wm:CreateControlFromVirtual(controlName, optionsWindow, "ZO_Options_Dropdown")
	dropdown:SetAnchor(TOPLEFT, lastAddedControl[panelID], BOTTOMLEFT, 0, 6)
	dropdown.controlType = OPTIONS_DROPDOWN
	dropdown.system = SETTING_TYPE_UI
	dropdown.panel = panelID
	dropdown.text = text
	dropdown.tooltipText = tooltip
	dropdown.valid = validChoices
	local dropmenu = ZO_ComboBox_ObjectFromContainer(GetControl(dropdown, "Dropdown"))
	local setText = dropmenu.m_selectedItemText.SetText
	local selectedName
	ZO_PreHookHandler(dropmenu.m_selectedItemText, "OnTextChanged", function(self)
			if dropmenu.m_selectedItemData then
				selectedName = dropmenu.m_selectedItemData.name
				setText(self, selectedName)
				setFunc(selectedName)
			end
		end)
	dropdown:SetHandler("OnShow", function()
			dropmenu:SetSelectedItem(getFunc())
		end)
	
	if warning then
		dropdown.warning = wm:CreateControlFromVirtual(controlName.."WarningIcon", dropdown, "ZO_Options_WarningIcon")
		dropdown.warning:SetAnchor(RIGHT, dropdown:GetNamedChild("Dropdown"), LEFT, -5, 0)
		dropdown.warning.tooltipText = warningText
	end
	
	ZO_OptionsWindow_InitializeControl(dropdown)
	
	lastAddedControl[panelID] = dropdown

	return dropdown
end


function lam:AddCheckbox(panelID, controlName, text, tooltip, getFunc, setFunc, warning, warningText)
	local checkbox = wm:CreateControlFromVirtual(controlName, optionsWindow, "ZO_Options_Checkbox")
	checkbox:SetAnchor(TOPLEFT, lastAddedControl[panelID], BOTTOMLEFT, 0, 6)
	checkbox.controlType = OPTIONS_CHECKBOX
	checkbox.system = SETTING_TYPE_UI
	checkbox.settingId = _G[string.format("SETTING_%s", controlName)]
	checkbox.panel = panelID
	checkbox.text = text
	checkbox.tooltipText = tooltip
	
	local checkboxButton = checkbox:GetNamedChild("Checkbox")
	
	ZO_PreHookHandler(checkbox, "OnShow", function()
			checkboxButton:SetState(getFunc() and 1 or 0)
			checkboxButton:toggleFunction(getFunc())
		end)
	ZO_PreHookHandler(checkboxButton, "OnClicked", function() setFunc(not getFunc()) end)
	
	if warning then
		checkbox.warning = wm:CreateControlFromVirtual(controlName.."WarningIcon", checkbox, "ZO_Options_WarningIcon")
		checkbox.warning:SetAnchor(RIGHT, checkboxButton, LEFT, -5, 0)
		checkbox.warning.tooltipText = warningText
	end
	
	ZO_OptionsWindow_InitializeControl(checkbox)
	
	lastAddedControl[panelID] = checkbox
	
	return checkbox
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

local function QB_SettingsMenu() 
--this is my function that sets up the settings menu
    local LAM = LibStub:GetLibrary( "LibAddonMenu-1.0" )
    
    local QB_SettingsPanelID = LAM:CreateControlPanel( "QB_Config", "|cFFD700Quest Buddy|r" )
    --here I define the panel ID
    
    local defaultText = ZO_OptionsWindowResetToDefaultButtonNameLabel:GetText()
    local applyText = ZO_OptionsWindowApplyButtonNameLabel:GetText()
    --these two locals are necessary if you are going to change the default texts
 
    ZO_PreHook("ZO_OptionsWindow_ChangePanels", function(panel)     
        if (panel == QB_SettingsPanelID) then
            ZO_OptionsWindowResetToDefaultButton:SetHidden(false) 
            --I'd like to use this apply button as well
            ZO_OptionsWindowResetToDefaultButton:SetKeybindEnabled(false) 
            --this has no effect for some reason, need to look a bit more for this
            ZO_OptionsWindowResetToDefaultButtonKeyLabel:SetHidden(true) 
            --since above has no effect, we hide the button here
            ZO_OptionsWindowResetToDefaultButtonNameLabel:SetText("Reset to Defaults") 
            --we change text with this if we so desire
            
            --same stuff goes for the apply button as well which you can see below
            ZO_OptionsWindowApplyButton:SetHidden(false) 
            ZO_OptionsWindowApplyButton:SetKeybindEnabled(false)
            ZO_OptionsWindowApplyButtonKeyLabel:SetHidden(true)
            ZO_OptionsWindowApplyButtonNameLabel:SetText("Apply Changes")
        
            --below is the callback function for apply button
            --which is merely a ReloadUI for my add-on
            ZO_OptionsWindowApplyButton:SetCallback(function() 
                ReloadUI() 
            end)
            
            --below is the function for the defaults button
            --which resets everything to the default values
            ZO_OptionsWindowResetToDefaultButton:SetCallback(function() 
                for variable, value in next, QB_defaults do
                    QB_vars[variable] = value
                end
                ReloadUI()
            end)
        
        --the ELSE below is IMPORTANT if you are changing the texts and/or hiding the keybind icons
        --what this part does is just reverting everything back to "vanilla"
        else
            ZO_OptionsWindowResetToDefaultButton:SetKeybindEnabled(true)
            ZO_OptionsWindowResetToDefaultButtonKeyLabel:SetHidden(false)
            ZO_OptionsWindowResetToDefaultButtonNameLabel:SetText(defaultText) 
            --defaultText is used here, which was stored prior to the change
            
            ZO_OptionsWindowApplyButton:SetKeybindEnabled(true)
            ZO_OptionsWindowApplyButtonKeyLabel:SetHidden(false)
            ZO_OptionsWindowApplyButtonNameLabel:SetText(applyText)
        end
    end)
    
        local QB_Main = LAM:AddHeader(QB_SettingsPanelID, "QB_Description", "")
        --we need to define a variable name for a header, preferably for the first one
        --because LAM hides these reset buttons while setting up headers, for some reason
        --and then sets handlers, which hides the buttons
        
        QB_Main:SetHandler("OnShow", function() return end)
        QB_Main:SetHandler("OnHide", function() return end)
        --these two above are necessary, we are basically overriding what LAM is doing here
        --if you don't do this, the reset button will stay hidden
 
... --rest of the menu stuff goes here