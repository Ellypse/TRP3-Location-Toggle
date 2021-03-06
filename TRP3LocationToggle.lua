------------------------------------------------------
-- TRP3 Location Toggle by iMintty_ (Curse)
------------------------------------------------------

------------------------------------------------------
-- Updates 'Enable character location' checkbox in settings
local function updateSettingsCheckbox(bool)
    for i, v in ipairs(TRP3_API.register.CONFIG_STRUCTURE.elements) do
        if v.configKey == "register_map_location" then
            v.controller:SetChecked(bool)
            break
        end
    end
end

local function onStart()
    local color = TRP3_API.utils.str.color

    if not TRP3_API.toolbar then
        TRP3_API.utils.message.displayMessage(color("r").."The 'Toolbar' module must be enabled for Location Toggle to work!")
        return
    end

    -- imports
    local getConfigValue, registerConfigHandler, setConfigValue = TRP3_API.configuration.getValue, TRP3_API.configuration.registerHandler, TRP3_API.configuration.setValue

    local location_setting_updated = true
    local tooltip_loc_shown = "Location: "..color("g").."Visible"
    local tooltip_loc_hidden = "Location: "..color("r").."Hidden"

    
    TRP3_API.Events.registerCallback(TRP3_API.Events.WORKFLOW_ON_FINISH, function()
        -- As of TRP 1.5.0 'register_map_location' isn't always loaded until after we're initialized
        registerConfigHandler({'register_map_location'}, function()
            location_setting_updated = true
        end)
        location_setting_updated = true
    end)

    TRP3_API.toolbar.toolbarAddButton{
        id = "trp3_location_toggle",
        icon = "INV_DARKMOON_EYE",
        configText = "Location Toggle",
        tooltip = "Location Toggle",
        tooltipSub = "Click to toggle location on/off",
        onUpdate = function(Uibutton, buttonStructure)
            TRP3_API.toolbar.updateToolbarButton(Uibutton, buttonStructure)
            if GetMouseFocus() == Uibutton then
                TRP3_API.ui.tooltip.refresh(Uibutton)
            end
        end,
        onModelUpdate = function(buttonStructure)
            -- Instead of checking getConfigValue() and setting each buttonStructure element every 0.5
            -- seconds we for config handler event to throw then check/set new values appropriately.
            if location_setting_updated then
                if getConfigValue('register_map_location') then
                    buttonStructure.tooltip = tooltip_loc_shown
                    buttonStructure.icon = "INV_DARKMOON_EYE"
                else
                    buttonStructure.tooltip = tooltip_loc_hidden
                    buttonStructure.icon = "Spell_Shadow_AuraOfDarkness"
                end
                location_setting_updated = false
            end
        end,
        onClick = function(Uibutton, buttonStructure, button)
            if getConfigValue('register_map_location') then
                setConfigValue('register_map_location', false)
                buttonStructure.toolbar = tooltip_loc_hidden
                buttonStructure.icon = "Spell_Shadow_AuraOfDarkness"
                updateSettingsCheckbox(false)
            else
                setConfigValue('register_map_location', true)
                buttonStructure.toolbar = tooltip_loc_shown
                buttonStructure.icon = "INV_DARKMOON_EYE"
                updateSettingsCheckbox(true)
            end
        end,
    }
end

-- Module Registration
TRP3_API.module.registerModule({
    ["name"] = "Location Toggle",
    ["description"] = "Adds a toolbar button to quickly enable/disable map location.",
    ["version"] = 1.4,
    ["id"] = "trp_location_toggle",
    ["onStart"] = onStart,
    ["minVersion"] = 3,    
})