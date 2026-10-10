-- Chat tabs fed by Comm.Channel.Text. Every line also stays in the main
-- window as the game printed it; the tabs are a copy you can scroll back in.

dl.chat = dl.chat or {}

local TABS = { "all", "room", "personal", "group", "world" }

-- The server's coarse channel buckets (chatframe.h), folded into five tabs.
local KIND_TO_TAB = {
  room = "room", mob = "room", quest = "room",
  personal = "personal",
  group = "group",
  world = "world", area = "world", race = "world",
}

local function tabStyle(label, active, unread)
  local bg = active and "#3a2f52" or "#1c1726"
  local fg = unread and "#ffff55" or (active and "white" or "#a090c0")
  label:setStyleSheet(string.format(
    "background-color: %s; color: %s; border: 1px solid #3a2f52; border-radius: 3px;", bg, fg))
end

local function tabCaption(tab)
  local caption = dl.t("tab." .. tab)
  if dl.chat.unread[tab] then
    caption = caption .. " *"
  end
  return "<center>" .. caption .. "</center>"
end

function dl.chat.refreshTabs()
  for _, tab in ipairs(TABS) do
    local label = dl.chat.labels[tab]
    if label then
      label:echo(tabCaption(tab))
      tabStyle(label, tab == dl.chat.active, dl.chat.unread[tab])
    end
  end
end

function dl.chat.switch(tab)
  dl.chat.active = tab
  dl.chat.unread[tab] = nil
  for _, t in ipairs(TABS) do
    if t == tab then
      dl.chat.consoles[t]:show()
    else
      dl.chat.consoles[t]:hide()
    end
  end
  dl.chat.refreshTabs()
end

function dl.chat.build()
  dl.chat.labels = {}
  dl.chat.consoles = {}
  dl.chat.unread = {}
  for _, tab in ipairs(TABS) do
    local label = Geyser.Label:new({ name = "dl.tab." .. tab }, dl.ui.tabBar)
    label:setClickCallback(function() dl.chat.switch(tab) end)
    dl.chat.labels[tab] = label

    local console = Geyser.MiniConsole:new({
      name = "dl.chat." .. tab, x = 0, y = 0, width = "100%", height = "100%",
    }, dl.ui.chatBox)
    dl.ui.consoleStyle(console)
    dl.chat.consoles[tab] = console
  end
  dl.chat.switch("all")
end

local function put(tab, line)
  local console = dl.chat.consoles[tab]
  if not console then
    return
  end
  console:decho(line)
  if tab ~= dl.chat.active then
    dl.chat.unread[tab] = true
  end
end

function dl.chat.onText()
  local msg = gmcp.Comm and gmcp.Comm.Channel and gmcp.Comm.Channel.Text
  if type(msg) ~= "table" or not dl.chat.consoles then
    return
  end
  local text = msg.text or ""
  if text == "" then
    return
  end
  if not text:ends("\n") then
    text = text .. "\n"
  end
  local stamp = ""
  if tonumber(msg.at) then
    stamp = "<112,112,112>" .. os.date("%H:%M ", tonumber(msg.at))
  end
  local line = stamp .. ansi2decho(text)

  put("all", line)
  local tab = KIND_TO_TAB[msg.kind or ""]
  if tab then
    put(tab, line)
  end
  dl.chat.refreshTabs()
end
