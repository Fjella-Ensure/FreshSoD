local LEVEL_BRACKETS = { 25, 40, 50 }
local LEVEL_BRACKET_SET = {
  [25] = true,
  [40] = true,
  [50] = true,
}

local function getAcknowledgedBrackets()
  return FreshSoD_GetDBValue('levelBracketAcknowledged') or {}
end

local function hasAcknowledgedBracket(level)
  return getAcknowledgedBrackets()[level] == true
end

function FreshSoD_AcknowledgeLevelBracket(level)
  local acknowledged = getAcknowledgedBrackets()
  acknowledged[level] = true
  FreshSoD_SaveDBData('levelBracketAcknowledged', acknowledged)
end

local function getPendingBracketLevel(playerLevel)
  for _, bracketLevel in ipairs(LEVEL_BRACKETS) do
    if playerLevel >= bracketLevel and not hasAcknowledgedBracket(bracketLevel) then
      return bracketLevel
    end
  end
  return nil
end

local function checkPlayerLevel(playerLevel)
  if playerLevel < LEVEL_BRACKETS[1] then
    return
  end

  local pendingBracket = getPendingBracketLevel(playerLevel)
  if pendingBracket then
    FreshSoD_ShowLevelBracketModal(pendingBracket)
  end
end

local function getPreviewBracketLevel(requestedLevel)
  if requestedLevel and LEVEL_BRACKET_SET[requestedLevel] then
    return requestedLevel
  end

  local playerLevel = UnitLevel('player')
  local selectedBracket = LEVEL_BRACKETS[1]

  for _, bracketLevel in ipairs(LEVEL_BRACKETS) do
    if playerLevel >= bracketLevel then
      selectedBracket = bracketLevel
    end
  end

  return selectedBracket
end

local function openLevelBracketModal(requestedLevel)
  if requestedLevel and not LEVEL_BRACKET_SET[requestedLevel] then
    print('|cfff44336[SoD Guild Found]|r Invalid level cap. Use: /levelcap [' .. table.concat(LEVEL_BRACKETS, '|') .. ']')
    return
  end

  FreshSoD_ShowLevelBracketModal(getPreviewBracketLevel(requestedLevel))
end

local frame = CreateFrame('Frame')
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('PLAYER_LEVEL_UP')

frame:SetScript('OnEvent', function(_, event, ...)
  if event == 'PLAYER_LOGIN' then
    checkPlayerLevel(UnitLevel('player'))
  elseif event == 'PLAYER_LEVEL_UP' then
    local newLevel = ...
    if LEVEL_BRACKET_SET[newLevel] then
      checkPlayerLevel(newLevel)
    end
  end
end)

SLASH_LEVELCAP1 = '/levelcap'
SlashCmdList['LEVELCAP'] = function(msg)
  local requestedLevel = tonumber(msg)
  openLevelBracketModal(requestedLevel)
end
