function FreshSoD_GetDBValue(key)
  local characterGUID = UnitGUID('player')

  if FRESH_SOD_GLOBAL_SETTINGS and FRESH_SOD_GLOBAL_SETTINGS[key] ~= nil then
    return FRESH_SOD_GLOBAL_SETTINGS[key]
  end

  if FRESH_SOD_DB and FRESH_SOD_DB[characterGUID] and FRESH_SOD_DB[characterGUID][key] ~= nil then
    return FRESH_SOD_DB[characterGUID][key]
  end

  return nil
end