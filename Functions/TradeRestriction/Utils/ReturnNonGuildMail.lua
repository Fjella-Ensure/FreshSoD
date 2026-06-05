function FreshSoD_ReturnNonGuildMail()
  local indices = FreshSoD_GetNonGuildMailIndices()

  for _, inboxIndex in ipairs(indices) do
    ReturnInboxItem(inboxIndex)
  end

  if #indices > 0 then
    FreshSoD_PrintRestrictionMessage('Returned mail from non-guild senders.')
  end
end
