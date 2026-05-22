local VERIFICATION_BUFF_SPELL_ID = 436412

local function getPlayerAura(spellId)
  if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID then
    return C_UnitAuras.GetPlayerAuraBySpellID(spellId)
  end

  local spellName = GetSpellInfo(spellId)
  for i = 1, 40 do
    local name, _, _, _, _, _, _, _, _, id = UnitAura('player', i, 'HELPFUL')
    if id == spellId or (spellName and name == spellName) then
      return { spellId = id or spellId, name = name }
    end
  end
end

local function auraIsAtZeroPercent(aura)
  if not aura or not aura.points then
    return false
  end

  for _, point in ipairs(aura.points) do
    if point == 0 then
      return true
    end
  end

  return false
end

local function descriptionIsExactlyZeroPercent(description)
  if not description then
    return false
  end

  for value in description:gmatch('(%d+)%%') do
    if tonumber(value) == 0 then
      return true
    end
  end

  return false
end

local function getSpellDescription(spellId)
  if GetSpellDescription then
    local description = GetSpellDescription(spellId)
    if description and description ~= '' then
      return description
    end
  end

  if C_Spell and C_Spell.GetSpellDescription then
    local description = C_Spell.GetSpellDescription(spellId)
    if description and description ~= '' then
      return description
    end
  end
end

-- absent: buff not on player (do not count as verified-disabled)
-- disabled: buff present at exactly 0%
-- active: buff present above 0%
function FreshSoD_GetVerificationBuffState()
  local aura = getPlayerAura(VERIFICATION_BUFF_SPELL_ID)
  if not aura then
    return 'absent'
  end

  if aura.points and #aura.points > 0 then
    if auraIsAtZeroPercent(aura) then
      return 'disabled'
    end
    return 'active'
  end

  if descriptionIsExactlyZeroPercent(getSpellDescription(VERIFICATION_BUFF_SPELL_ID)) then
    return 'disabled'
  end

  return 'active'
end

function FreshSoD_IsBuffExplicitlyDisabled()
  return FreshSoD_GetVerificationBuffState() == 'disabled'
end

function FreshSoD_IsBuffVerificationPassed()
  local state = FreshSoD_GetVerificationBuffState()
  return state == 'absent' or state == 'disabled'
end

function FreshSoD_IsBuffActive()
  return FreshSoD_IsBuffVerificationPassed()
end
