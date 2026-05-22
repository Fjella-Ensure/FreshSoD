function FreshSoD_IsPlayerInGuildRoster(playerName)
    return C_GuildInfo.IsGuildMember(playerName) or C_GuildInfo.IsGuildOfficer(playerName)
end