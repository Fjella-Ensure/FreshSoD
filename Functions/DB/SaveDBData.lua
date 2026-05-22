function FreshSoD_SaveDBData(key, value)
  local characterGUID = UnitGUID('player')

  if not FRESH_SOD_DB then
    FRESH_SOD_DB = {}
  end

  if not FRESH_SOD_DB[characterGUID] then
    FRESH_SOD_DB[characterGUID] = {}
  end

  FRESH_SOD_DB[characterGUID][key] = value

  if FRESH_SOD_GLOBAL_SETTINGS then
    FRESH_SOD_GLOBAL_SETTINGS[key] = value
  end
end
