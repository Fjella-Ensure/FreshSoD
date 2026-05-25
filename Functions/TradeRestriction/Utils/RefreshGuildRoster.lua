function FreshSoD_RefreshGuildRoster()
    local inGuild = IsInGuild and IsInGuild()
    if inGuild and GuildRoster then
      SetGuildRosterShowOffline(true)
      GuildRoster()
    end
  end