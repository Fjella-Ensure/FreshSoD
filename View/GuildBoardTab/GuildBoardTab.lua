local CONTENT_TOP_OFFSET = -55
local LIST_LEFT_OFFSET = 10
local SEARCH_HEIGHT = 24
local SEARCH_BOTTOM_GAP = 4
local HEADER_BOTTOM_GAP = 4
local ROW_HEIGHT = 13
local ROWS_PER_PAGE = 15
local SEARCH_MIN_CHARS = 3
local STATUS_COLUMN_OFFSET = 180
local ACTION_COLUMN_OFFSET = 238
local REFRESH_BUTTON_SIZE = 16
local PAGINATION_HEIGHT = 24
local PAGINATION_BOTTOM_MARGIN = -2
local PAGINATION_BUTTON_WIDTH = 64
local PAGINATION_BUTTON_GAP = 6

local SEARCH_HELPER_TEXT = 'Search members (3+ characters)'
local REFRESH_ICON = 'Interface\\Buttons\\UI-RefreshButton'
local REFRESH_TOOLTIP_TEXT = 'This will re-validate the player'

local updateGuildBoardTabDisplay

local STATUS_DISPLAY = {
  valid = { text = 'Valid', r = 0.35, g = 0.8, b = 0.35 },
  invalid = { text = 'Invalid', r = 0.82, g = 0.33, b = 0.33 },
  unknown = { text = 'Unknown', r = 0.95, g = 0.82, b = 0.25 },
}

local function getMemberVerificationDisplay(playerName, guildName)
  local playerShortName = Ambiguate(UnitName('player'), 'short')
  if Ambiguate(playerName, 'short') == playerShortName then
    if FreshSoD_UpdateBuffVerification then
      FreshSoD_UpdateBuffVerification()
    end
    return FreshSoD_AmIVerified() and STATUS_DISPLAY.valid or STATUS_DISPLAY.invalid
  end

  local storedStatus = FreshSoD_GetGuildMemberVerificationStatus(guildName, playerName)
  if storedStatus == true then
    return STATUS_DISPLAY.valid
  end
  if storedStatus == false then
    return STATUS_DISPLAY.invalid
  end

  return STATUS_DISPLAY.unknown
end

local function getMemberStoredVerificationStatus(playerName, guildName)
  local playerShortName = Ambiguate(UnitName('player'), 'short')
  if Ambiguate(playerName, 'short') == playerShortName then
    return FreshSoD_AmIVerified()
  end

  return FreshSoD_GetGuildMemberVerificationStatus(guildName, playerName)
end

local function getSearchText(content)
  local searchText = content.searchInput:GetText()
  if searchText then
    searchText = searchText:match('^%s*(.-)%s*$')
  end
  return searchText or ''
end

local function filterMembers(members, searchText)
  if #searchText < SEARCH_MIN_CHARS then
    return members
  end

  local query = string.lower(searchText)
  local filtered = {}

  for _, memberName in ipairs(members) do
    if string.find(string.lower(memberName), query, 1, true) then
      filtered[#filtered + 1] = memberName
    end
  end

  return filtered
end

local function createRefreshButton(parent)
  local button = CreateFrame('Button', nil, parent)
  button:SetSize(REFRESH_BUTTON_SIZE, REFRESH_BUTTON_SIZE)

  local normal = button:CreateTexture(nil, 'ARTWORK')
  normal:SetAllPoints()
  normal:SetTexture(REFRESH_ICON)

  local highlight = button:CreateTexture(nil, 'HIGHLIGHT')
  highlight:SetAllPoints()
  highlight:SetTexture(REFRESH_ICON)
  highlight:SetBlendMode('ADD')
  highlight:SetAlpha(0.4)

  button:SetScript('OnEnter', function(self)
    GameTooltip:SetOwner(self, 'ANCHOR_RIGHT')
    GameTooltip:SetText(REFRESH_TOOLTIP_TEXT)
    GameTooltip:Show()
  end)
  button:SetScript('OnLeave', function()
    GameTooltip:Hide()
  end)

  return button
end

local function getPageMembers(filteredMembers, page)
  local totalPages = math.max(1, math.ceil(#filteredMembers / ROWS_PER_PAGE))
  page = math.max(1, math.min(page, totalPages))

  local startIndex = (page - 1) * ROWS_PER_PAGE + 1
  local pageMembers = {}

  for index = startIndex, math.min(startIndex + ROWS_PER_PAGE - 1, #filteredMembers) do
    pageMembers[#pageMembers + 1] = filteredMembers[index]
  end

  return pageMembers, totalPages, page
end

local function updateGuildBoardLayout(content)
  local contentWidth = content:GetWidth()
  local searchWidth = contentWidth - (LIST_LEFT_OFFSET * 2)
  if searchWidth < 1 then
    searchWidth = 1
  end

  content.searchHelperLabel:ClearAllPoints()
  content.searchHelperLabel:SetPoint('TOPLEFT', content, 'TOPLEFT', LIST_LEFT_OFFSET, CONTENT_TOP_OFFSET)
  content.searchHelperLabel:SetWidth(searchWidth)
  content.searchHelperLabel:SetWordWrap(true)
  content.searchHelperLabel:SetJustifyH('LEFT')
  content.searchHelperLabel:SetJustifyV('TOP')

  content.searchInput:SetSize(searchWidth, SEARCH_HEIGHT)
  content.searchInput:ClearAllPoints()
  content.searchInput:SetPoint('TOPLEFT', content.searchHelperLabel, 'BOTTOMLEFT', 0, -SEARCH_BOTTOM_GAP)

  content.headerName:ClearAllPoints()
  content.headerName:SetPoint('TOPLEFT', content.searchInput, 'BOTTOMLEFT', 0, -SEARCH_BOTTOM_GAP)

  content.headerStatus:ClearAllPoints()
  content.headerStatus:SetPoint('LEFT', content.headerName, 'LEFT', STATUS_COLUMN_OFFSET, 0)

  content.prevButton:SetSize(PAGINATION_BUTTON_WIDTH, PAGINATION_HEIGHT)
  content.nextButton:SetSize(PAGINATION_BUTTON_WIDTH, PAGINATION_HEIGHT)
  content.prevButton:ClearAllPoints()
  content.nextButton:ClearAllPoints()
  content.prevButton:SetPoint('BOTTOMLEFT', content, 'BOTTOMLEFT', LIST_LEFT_OFFSET, PAGINATION_BOTTOM_MARGIN)
  content.nextButton:SetPoint('BOTTOMRIGHT', content, 'BOTTOMRIGHT', -LIST_LEFT_OFFSET, PAGINATION_BOTTOM_MARGIN)

  content.pageLabel:ClearAllPoints()
  content.pageLabel:SetPoint('CENTER', content, 'BOTTOM', 0, PAGINATION_BOTTOM_MARGIN + (PAGINATION_HEIGHT / 2))

  content.tableContainer:ClearAllPoints()
  content.tableContainer:SetPoint('TOPLEFT', content.headerName, 'BOTTOMLEFT', 0, -HEADER_BOTTOM_GAP)
  content.tableContainer:SetPoint('BOTTOMLEFT', content.prevButton, 'TOPLEFT', 0, 6)
  content.tableContainer:SetPoint('BOTTOMRIGHT', content, 'BOTTOMRIGHT', -LIST_LEFT_OFFSET, PAGINATION_HEIGHT + PAGINATION_BOTTOM_MARGIN + 6)
  content.tableContainer:SetClipsChildren(true)

  for index = 1, ROWS_PER_PAGE do
    local nameRow = content.memberNameRows[index]
    local statusRow = content.memberStatusRows[index]
    local resetButton = content.memberResetButtons and content.memberResetButtons[index]

    nameRow:ClearAllPoints()
    nameRow:SetPoint('TOPLEFT', content.tableContainer, 'TOPLEFT', 0, -((index - 1) * ROW_HEIGHT))
    nameRow:SetHeight(ROW_HEIGHT)

    statusRow:ClearAllPoints()
    statusRow:SetPoint('LEFT', nameRow, 'LEFT', STATUS_COLUMN_OFFSET, 0)

    if resetButton then
      resetButton:ClearAllPoints()
      resetButton:SetPoint('LEFT', nameRow, 'LEFT', ACTION_COLUMN_OFFSET, 0)
      resetButton:SetSize(REFRESH_BUTTON_SIZE, REFRESH_BUTTON_SIZE)
    end
  end
end

local function ensureGuildBoardTabLayout(content)
  if content.guildBoardInitialized then
    return
  end

  content.guildBoardCurrentPage = 1

  content.searchHelperLabel = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
  content.searchHelperLabel:SetText(SEARCH_HELPER_TEXT)
  content.searchHelperLabel:SetTextColor(0.85, 0.85, 0.85)

  content.searchInput = CreateFrame('EditBox', nil, content, 'InputBoxTemplate')
  content.searchInput:SetAutoFocus(false)
  content.searchInput:SetMaxLetters(50)
  content.searchInput:SetScript('OnTextChanged', function()
    content.guildBoardCurrentPage = 1
    updateGuildBoardTabDisplay(content)
  end)

  content.headerName = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')
  content.headerStatus = content:CreateFontString(nil, 'OVERLAY', 'GameFontNormal')

  content.tableContainer = CreateFrame('Frame', nil, content)
  content.tableContainer:SetClipsChildren(true)

  content.memberNameRows = {}
  content.memberStatusRows = {}
  content.memberResetButtons = {}
  for index = 1, ROWS_PER_PAGE do
    content.memberNameRows[index] = content.tableContainer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')
    content.memberStatusRows[index] = content.tableContainer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')

    local resetButton = createRefreshButton(content.tableContainer)
    resetButton:Hide()
    resetButton:SetScript('OnClick', function(self)
      local targetName = self.memberName
      if targetName and FreshSoD_SendGuildResetRequest(targetName) then
        FreshSoD_PrintRestrictionMessage('Reset validation request sent to ' .. Ambiguate(targetName, 'short') .. '. They must be online to receive the request.')
      end
    end)
    content.memberResetButtons[index] = resetButton
  end

  content.emptyLabel = content.tableContainer:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')

  content.prevButton = CreateFrame('Button', nil, content, 'UIPanelButtonTemplate')
  content.prevButton:SetText('Prev')
  content.prevButton:SetScript('OnClick', function()
    content.guildBoardCurrentPage = math.max(1, (content.guildBoardCurrentPage or 1) - 1)
    updateGuildBoardTabDisplay(content)
  end)

  content.nextButton = CreateFrame('Button', nil, content, 'UIPanelButtonTemplate')
  content.nextButton:SetText('Next')
  content.nextButton:SetScript('OnClick', function()
    content.guildBoardCurrentPage = (content.guildBoardCurrentPage or 1) + 1
    updateGuildBoardTabDisplay(content)
  end)

  content.pageLabel = content:CreateFontString(nil, 'OVERLAY', 'GameFontHighlight')

  content.guildBoardInitialized = true
end

local function hideTableRows(content)
  for index = 1, ROWS_PER_PAGE do
    content.memberNameRows[index]:Hide()
    content.memberStatusRows[index]:Hide()
    if content.memberResetButtons then
      content.memberResetButtons[index]:Hide()
    end
  end
end

updateGuildBoardTabDisplay = function(content)
  ensureGuildBoardTabLayout(content)
  updateGuildBoardLayout(content)

  local guildName = FreshSoD_GetPlayerGuildName()
  local members = guildName and FreshSoD_GetGuildMemberNames() or {}
  local searchText = getSearchText(content)
  local filteredMembers = filterMembers(members, searchText)
  local pageMembers, totalPages, currentPage = getPageMembers(filteredMembers, content.guildBoardCurrentPage or 1)

  content.guildBoardCurrentPage = currentPage
  local showOfficerActions = FreshSoD_AmITopGuildRank()

  content.headerName:SetText('Member')
  content.headerName:SetTextColor(0.75, 0.75, 0.75)

  content.headerStatus:SetText('Status')
  content.headerStatus:SetTextColor(0.75, 0.75, 0.75)

  if #members == 0 then
    content.searchHelperLabel:Hide()
    content.searchInput:Hide()
    content.headerName:Hide()
    content.headerStatus:Hide()
    content.tableContainer:Hide()
    content.prevButton:Hide()
    content.nextButton:Hide()
    content.pageLabel:Hide()
    hideTableRows(content)

    content.emptyLabel:ClearAllPoints()
    content.emptyLabel:SetPoint('TOPLEFT', content, 'TOPLEFT', LIST_LEFT_OFFSET, CONTENT_TOP_OFFSET)
    content.emptyLabel:SetText(guildName and 'No guild members found.' or 'Join a guild to see member verification status.')
    content.emptyLabel:SetTextColor(0.85, 0.85, 0.85)
    content.emptyLabel:Show()
    return
  end

  content.searchHelperLabel:Show()
  content.searchInput:Show()
  content.tableContainer:Show()
  content.prevButton:Show()
  content.nextButton:Show()
  content.pageLabel:Show()

  if #filteredMembers == 0 then
    content.headerName:Show()
    content.headerStatus:Show()
    hideTableRows(content)

    content.emptyLabel:ClearAllPoints()
    content.emptyLabel:SetPoint('TOPLEFT', content.tableContainer, 'TOPLEFT', 0, 0)
    content.emptyLabel:SetText('No members match your search.')
    content.emptyLabel:SetTextColor(0.85, 0.85, 0.85)
    content.emptyLabel:Show()
  else
    content.headerName:Show()
    content.headerStatus:Show()
    content.emptyLabel:Hide()

    for index = 1, ROWS_PER_PAGE do
      local memberName = pageMembers[index]
      local nameRow = content.memberNameRows[index]
      local statusRow = content.memberStatusRows[index]
      local resetButton = content.memberResetButtons[index]

      if memberName then
        local status = getMemberVerificationDisplay(memberName, guildName)
        local storedStatus = getMemberStoredVerificationStatus(memberName, guildName)

        nameRow:SetText(memberName)
        nameRow:SetTextColor(0.922, 0.871, 0.761)
        nameRow:Show()

        statusRow:SetText(status.text)
        statusRow:SetTextColor(status.r, status.g, status.b)
        statusRow:Show()

        if showOfficerActions and storedStatus == false then
          resetButton.memberName = memberName
          resetButton:Show()
        else
          resetButton.memberName = nil
          resetButton:Hide()
        end
      else
        nameRow:Hide()
        statusRow:Hide()
        resetButton.memberName = nil
        resetButton:Hide()
      end
    end
  end

  content.pageLabel:SetText(string.format('Page %d of %d', currentPage, totalPages))
  content.prevButton:SetEnabled(currentPage > 1)
  content.nextButton:SetEnabled(currentPage < totalPages)
end

function FreshSoD_InitializeGuildBoardTab(tabContents)
  local content = tabContents[2]
  if not content then
    return
  end

  ensureGuildBoardTabLayout(content)
  updateGuildBoardTabDisplay(content)
end

function FreshSoD_RefreshGuildBoardTabIfVisible()
  local content = FreshSoD_GetTabContent and FreshSoD_GetTabContent(2)
  if not content or not content:IsShown() or not content.guildBoardInitialized then
    return
  end

  updateGuildBoardTabDisplay(content)
end

local guildBoardRefreshFrame = CreateFrame('Frame')
guildBoardRefreshFrame:RegisterEvent('GUILD_ROSTER_UPDATE')

guildBoardRefreshFrame:SetScript('OnEvent', function()
  FreshSoD_RefreshGuildBoardTabIfVisible()
end)
