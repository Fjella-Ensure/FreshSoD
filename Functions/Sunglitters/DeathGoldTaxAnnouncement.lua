local announcementFrame

local DISPLAY_DURATION = 5
local FADE_DURATION = 1
local FRAME_WIDTH = 520
local TOP_OFFSET = -50
local HEADER_HEIGHT = 34
local CONTENT_HORIZONTAL_INSET = 16
local CONTENT_TOP_GAP = 8
local CONTENT_BOTTOM_PADDING = 10
local BORDER_TEXTURE = 'Interface\\DialogFrame\\UI-DialogBox-Border'
local BORDER_EDGE_SIZE = 32
local BORDER_OUTSET = 10
local PANEL_BACKGROUND_ALPHA = 0.5
local HEADER_BACKGROUND_ALPHA = 0.55
local BORDER_ALPHA = 0.7
local DIVIDER_ALPHA = 0.55

local TITLE_COLOR = { 0.92, 0.22, 0.18 }
local BORDER_COLOR = { 0.78, 0.48, 0.12 }
local BODY_COLOR = { 0.9, 0.88, 0.84 }
local TAX_COLOR = { 1, 0.82, 0 }

local function colorCode(color)
  return string.format('|cff%02x%02x%02x', color[1] * 255, color[2] * 255, color[3] * 255)
end

local function formatTaxAmount(taxCopper)
  local gold = math.floor(taxCopper / 10000)
  local silver = math.floor((taxCopper % 10000) / 100)
  local copper = taxCopper % 100
  local parts = {}

  if gold > 0 then
    table.insert(parts, string.format('%02dg', gold))
  end
  if silver > 0 then
    table.insert(parts, string.format('%02ds', silver))
  end
  if copper > 0 then
    table.insert(parts, string.format('%02dc', copper))
  end

  if #parts == 0 then
    return '0c'
  end

  return table.concat(parts, ' ')
end

local function buildAnnouncementMessage(playerName, taxCopper)
  return string.format(
    '%s%s|r%s has died, they owe %s%s|r%s in death tax.|r',
    colorCode(BODY_COLOR),
    playerName,
    colorCode(BODY_COLOR),
    colorCode(TAX_COLOR),
    formatTaxAmount(taxCopper),
    colorCode(BODY_COLOR)
  )
end

function FreshSoD_ShowDeathTaxAnnouncement(playerName, taxCopper)
  if not announcementFrame then
    announcementFrame = CreateFrame('Frame', 'FreshSoDDeathTaxAnnouncement', UIParent, 'BackdropTemplate')
    announcementFrame:SetSize(FRAME_WIDTH, 1)
    announcementFrame:SetPoint('TOP', UIParent, 'TOP', 0, TOP_OFFSET)
    announcementFrame:SetFrameStrata('HIGH')
    announcementFrame:SetFrameLevel(100)
    announcementFrame:SetClipsChildren(false)
    announcementFrame:SetBackdrop({
      bgFile = 'Interface\\DialogFrame\\UI-DialogBox-Background-Dark',
      tile = true,
      tileSize = 32,
    })
    announcementFrame:SetBackdropColor(0.08, 0.03, 0.03, PANEL_BACKGROUND_ALPHA)

    announcementFrame.border = CreateFrame('Frame', nil, announcementFrame, 'BackdropTemplate')
    announcementFrame.border:SetFrameLevel(announcementFrame:GetFrameLevel() + 10)
    announcementFrame.border:EnableMouse(false)
    announcementFrame.border:SetPoint('TOPLEFT', announcementFrame, 'TOPLEFT', -BORDER_OUTSET, BORDER_OUTSET)
    announcementFrame.border:SetPoint('BOTTOMRIGHT', announcementFrame, 'BOTTOMRIGHT', BORDER_OUTSET, -BORDER_OUTSET)
    announcementFrame.border:SetBackdrop({
      edgeFile = BORDER_TEXTURE,
      tile = true,
      tileSize = BORDER_EDGE_SIZE,
      edgeSize = BORDER_EDGE_SIZE,
      insets = { left = 0, right = 0, top = 0, bottom = 0 },
    })
    announcementFrame.border:SetBackdropBorderColor(BORDER_COLOR[1], BORDER_COLOR[2], BORDER_COLOR[3], BORDER_ALPHA)

    announcementFrame.headerBar = CreateFrame('Frame', nil, announcementFrame, 'BackdropTemplate')
    announcementFrame.headerBar:SetPoint('TOPLEFT', announcementFrame, 'TOPLEFT', 0, 0)
    announcementFrame.headerBar:SetPoint('TOPRIGHT', announcementFrame, 'TOPRIGHT', 0, 0)
    announcementFrame.headerBar:SetHeight(HEADER_HEIGHT)
    announcementFrame.headerBar:SetBackdrop({
      bgFile = 'Interface\\Buttons\\WHITE8x8',
      tile = true,
      tileSize = 8,
    })
    announcementFrame.headerBar:SetBackdropColor(0.18, 0.05, 0.05, HEADER_BACKGROUND_ALPHA)

    announcementFrame.headerTitle = announcementFrame.headerBar:CreateFontString(nil, 'OVERLAY', 'GameFontNormalLarge')
    announcementFrame.headerTitle:SetPoint('CENTER', announcementFrame.headerBar, 'CENTER', 0, 1)
    announcementFrame.headerTitle:SetText('DEATH TAX')
    announcementFrame.headerTitle:SetTextColor(TITLE_COLOR[1], TITLE_COLOR[2], TITLE_COLOR[3])

    announcementFrame.divider = announcementFrame:CreateTexture(nil, 'ARTWORK')
    announcementFrame.divider:SetPoint('TOPLEFT', announcementFrame.headerBar, 'BOTTOMLEFT', 0, 0)
    announcementFrame.divider:SetPoint('TOPRIGHT', announcementFrame.headerBar, 'BOTTOMRIGHT', 0, 0)
    announcementFrame.divider:SetHeight(1)
    announcementFrame.divider:SetColorTexture(0.45, 0.18, 0.12, DIVIDER_ALPHA)

    announcementFrame.text = announcementFrame:CreateFontString(nil, 'OVERLAY', 'GameFontHighlightLarge')
    announcementFrame.text:SetPoint('TOPLEFT', announcementFrame.divider, 'BOTTOMLEFT', CONTENT_HORIZONTAL_INSET, -CONTENT_TOP_GAP)
    announcementFrame.text:SetPoint('TOPRIGHT', announcementFrame.divider, 'BOTTOMRIGHT', -CONTENT_HORIZONTAL_INSET, -CONTENT_TOP_GAP)
    announcementFrame.text:SetWidth(FRAME_WIDTH - (CONTENT_HORIZONTAL_INSET * 2))
    announcementFrame.text:SetWordWrap(true)
    announcementFrame.text:SetJustifyH('CENTER')
    announcementFrame.text:SetSpacing(2)
  end

  announcementFrame.text:SetText(buildAnnouncementMessage(playerName, taxCopper))
  local textHeight = announcementFrame.text:GetStringHeight()
  announcementFrame:SetHeight(
    HEADER_HEIGHT + 1 + CONTENT_TOP_GAP + textHeight + CONTENT_BOTTOM_PADDING
  )
  announcementFrame:SetAlpha(1)
  announcementFrame:Show()
  announcementFrame.fadeTimer = DISPLAY_DURATION

  announcementFrame:SetScript('OnUpdate', function(self, elapsed)
    self.fadeTimer = self.fadeTimer - elapsed
    if self.fadeTimer <= FADE_DURATION then
      self:SetAlpha(math.max(self.fadeTimer / FADE_DURATION, 0))
    end
    if self.fadeTimer <= 0 then
      self:SetScript('OnUpdate', nil)
      self:Hide()
    end
  end)
end

local sunglittersFrame = CreateFrame('Frame')

sunglittersFrame:RegisterEvent('PLAYER_DEAD')

sunglittersFrame:SetScript('OnEvent', function(self, event, ...)
  if event == 'PLAYER_DEAD' then
    if not FreshSoD_IsDeathTaxGuild() then
      return
    end

    local copperCoins = GetMoney()
    local tax = math.floor(copperCoins * 0.10)
    local playerName = UnitName('player') or 'You'

    FreshSoD_AddDeathTaxOwedCopper(tax)
    FreshSoD_SendDeathTaxAddonMessage(playerName, tax)
    FreshSoD_ShowDeathTaxAnnouncement(playerName, tax)
  end
end)
