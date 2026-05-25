local CACHE_TTL_SECONDS = 5

FreshSoD_partnerVerificationCache = FreshSoD_partnerVerificationCache or {}

function FreshSoD_PlayerNamesMatch(nameA, nameB)
  if not nameA or not nameB then
    return false
  end

  return Ambiguate(nameA, 'short') == Ambiguate(nameB, 'short')
end

function FreshSoD_CachePartnerVerification(playerName, isVerified)
  if not playerName then
    return
  end

  FreshSoD_partnerVerificationCache[playerName] = {
    verified = isVerified,
    at = time(),
  }
end

function FreshSoD_GetCachedPartnerVerification(playerName)
  for cachedName, entry in pairs(FreshSoD_partnerVerificationCache) do
    if FreshSoD_PlayerNamesMatch(cachedName, playerName) then
      if (time() - entry.at) > CACHE_TTL_SECONDS then
        FreshSoD_partnerVerificationCache[cachedName] = nil
        return nil
      end

      return entry.verified
    end
  end

  return nil
end
