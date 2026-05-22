function FreshSoD_MinimapButton_Initialize()
    local TEXTURE_PATH = 'Interface\\AddOns\\FreshSoD\\Textures'

    local addonLDB = LibStub('LibDataBroker-1.1'):NewDataObject('FreshSoD', {
        type = 'data source',
        text = 'Fresh SoD',
        icon = TEXTURE_PATH .. '\\bonnie-round.png',
        OnClick = function(self, btn)
        if btn == 'LeftButton' then
            FreshSoD_ToggleFreshSoDSettings()
        end
        end,
        OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end
        tooltip:AddLine('|cffffffffFresh SoD|r\n\nLeft-click to open', nil, nil, nil, nil)
        end,
    })

    local addonIcon = LibStub('LibDBIcon-1.0')
    local minimapButtonSettings = FreshSoD_GetDBValue('minimapButton')
    addonIcon:Register('FreshSoD', addonLDB, minimapButtonSettings)
end