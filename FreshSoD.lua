addonName = ...
FreshSoD = CreateFrame('Frame')

FreshSoD:RegisterEvent('PLAYER_LOGIN')

FreshSoD:SetScript('OnEvent', function(self, event, ...)
  if event == 'PLAYER_LOGIN' then
    print('FreshSoD: Player logged in')
  end
end)
