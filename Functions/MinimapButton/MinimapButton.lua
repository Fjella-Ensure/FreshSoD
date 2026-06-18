function FreshSoD_MinimapButton_Initialize()
    if not LibStub then
        return
    end

    local ldb = LibStub('LibDataBroker-1.1', true)
    local addonIcon = LibStub('LibDBIcon-1.0', true)
    if not ldb or not addonIcon then
        return
    end

    local TEXTURE_PATH = 'Interface\\AddOns\\FreshSoD\\Textures'

    local addonLDB = ldb:NewDataObject('FreshSoD', {
        type = 'data source',
        text = 'SoD Guild Found',
        icon = TEXTURE_PATH .. '\\sod-guild-found-icon.png',
        OnClick = function(self, btn)
        if btn == 'LeftButton' then
            FreshSoD_ToggleFreshSoDSettings()
        end
        end,
        OnTooltipShow = function(tooltip)
        if not tooltip or not tooltip.AddLine then return end
        tooltip:AddLine('|cffffffffSoD Guild Found|r\n\nLeft-click to open', nil, nil, nil, nil)
        end,
    })

    local minimapButtonSettings = FreshSoD_GetDBValue('minimapButton')
    addonIcon:Register('FreshSoD', addonLDB, minimapButtonSettings)
end