local playerMoneyFrame = CreateFrame('Frame')

local function OnMoneyChanged()
  local current = GetMoney() or 0
  FreshSoD_SaveDBData('playerMoney', current)
end

local function ValidatePlayerMoneyOnLogin()
  local playerMoney = FreshSoD_GetDBValue('playerMoney')
  local current = GetMoney()
  if playerMoney ~= current and not FreshSoD_GetDBValue('playerMoneyValidationFailed') then
    FreshSoD_SaveDBData('playerMoneyValidationFailed', true)
    FreshSoD_SaveDBData('playerMoneyValidationFailedAt', time())
  end
end

playerMoneyFrame:RegisterEvent('PLAYER_MONEY')
playerMoneyFrame:RegisterEvent('PLAYER_LOGIN')

playerMoneyFrame:SetScript('OnEvent', function(_, event, arg1)
  if event == 'PLAYER_MONEY' then
    OnMoneyChanged()
  elseif event == 'PLAYER_LOGIN' then
    ValidatePlayerMoneyOnLogin()
  end
end)
