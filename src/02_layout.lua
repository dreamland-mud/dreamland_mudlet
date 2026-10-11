-- The right-hand column: chat tabs on top, then the gauges, the map, the info
-- panel and the command buttons. Built once; dl.ui.render() refills it.

local GAUGE_H = 20
local GAUGES_H = 4 * (GAUGE_H + 2)
local TABS_H = 24
local CHAT_PCT = 28
local MAP_PCT = 30
local BUTTONS_H = 6 * 26

local function consoleStyle(console)
  console:setColor(dl.colors.bg)
  console:setFontSize(math.max(getFontSize() - 1, 8))
  console:enableAutoWrap()
end

local function gauge(name, y, r, g, b)
  local gg = Geyser.Gauge:new({
    name = "dl." .. name,
    x = 4, y = y, width = "100%-8", height = GAUGE_H,
  }, dl.ui.root)
  gg:setColor(r, g, b)
  gg.back:setStyleSheet("background-color: #201a2c; border-radius: 3px;")
  gg.text:setStyleSheet("color: white; qproperty-alignment: 'AlignCenter';")
  return gg
end

function dl.ui.applyBorder()
  if dl.settings.hidden or not dl.ui.root then
    setBorderRight(0)
    return
  end
  local w = getMainWindowSize()
  setBorderRight(math.floor(w * dl.settings.width / 100))
end

function dl.ui.build()
  if dl.ui.root then
    return
  end
  local w = dl.settings.width

  dl.ui.root = Geyser.Container:new({
    name = "dl.root", x = -w .. "%", y = 0, width = w .. "%", height = "100%",
  })

  dl.ui.tabBar = Geyser.HBox:new({
    name = "dl.tabBar", x = 0, y = 0, width = "100%", height = TABS_H,
  }, dl.ui.root)

  dl.ui.chatBox = Geyser.Container:new({
    name = "dl.chatBox", x = 0, y = TABS_H, width = "100%", height = CHAT_PCT .. "%-" .. TABS_H,
  }, dl.ui.root)

  local gy = CHAT_PCT .. "%+"
  dl.ui.hp = gauge("hp", gy .. 2, 170, 30, 30)
  dl.ui.mana = gauge("mana", gy .. (2 + GAUGE_H + 2), 40, 70, 190)
  dl.ui.move = gauge("move", gy .. (2 + 2 * (GAUGE_H + 2)), 40, 150, 60)
  dl.ui.enemy = gauge("enemy", gy .. (2 + 3 * (GAUGE_H + 2)), 200, 120, 30)

  dl.ui.map = Geyser.Mapper:new({
    name = "dl.map",
    x = 0, y = gy .. (GAUGES_H + 4),
    width = "100%", height = MAP_PCT .. "%",
  }, dl.ui.root)

  dl.ui.info = Geyser.MiniConsole:new({
    name = "dl.info",
    x = 0, y = (CHAT_PCT + MAP_PCT) .. "%+" .. (GAUGES_H + 6),
    width = "100%", height = (100 - CHAT_PCT - MAP_PCT) .. "%-" .. (GAUGES_H + 6 + BUTTONS_H),
  }, dl.ui.root)
  consoleStyle(dl.ui.info)

  dl.ui.buttonBox = Geyser.Container:new({
    name = "dl.buttons", x = 0, y = -BUTTONS_H, width = "100%", height = BUTTONS_H,
  }, dl.ui.root)

  dl.chat.build()

  if dl.settings.hidden then
    dl.ui.root:hide()
  end
  dl.ui.applyBorder()
end

function dl.ui.consoleStyle(console)
  consoleStyle(console)
end

function dl.ui.setHidden(hidden)
  dl.settings.hidden = hidden
  dl.saveSettings()
  if not dl.ui.root then
    return
  end
  if hidden then
    dl.ui.root:hide()
  else
    dl.ui.root:show()
    dl.ui.render()
  end
  dl.ui.applyBorder()
end

function dl.ui.setWidth(pct)
  dl.settings.width = pct
  dl.saveSettings()
  if not dl.ui.root then
    return
  end
  dl.ui.root:move(-pct .. "%", 0)
  dl.ui.root:resize(pct .. "%", "100%")
  dl.ui.applyBorder()
end

function dl.ui.destroy()
  if dl.ui.root then
    dl.ui.root:hide()
  end
  setBorderRight(0)
  -- A reinstall (every package update) runs the scripts again and must build
  -- a fresh panel instead of finding this hidden one.
  dl.ui.root = nil
  dl.ui.buttons = {}
  dl.ui.buttonSig = nil
end

function dl.ui.updateVitals()
  if not dl.ui.root then
    return
  end
  local p = dl.prompt
  local function set(g, cur, max, key)
    cur = tonumber(cur) or 0
    max = tonumber(max) or 0
    if max <= 0 then
      max = 1
    end
    g:setValue(math.max(cur, 0), max, string.format("%s %d/%d", dl.t(key), cur, max))
  end
  set(dl.ui.hp, p.hit, p.max_hit, "st.health")
  set(dl.ui.mana, p.mana, p.max_mana, "st.mana")
  set(dl.ui.move, p.move, p.max_move, "st.moves")

  -- prompt.fight is the enemy's health in percent, 0 when not fighting.
  local fight = tonumber(p.fight) or 0
  if fight > 0 then
    dl.ui.enemy:show()
    dl.ui.enemy:setValue(fight, 100, string.format("%s %d%%", dl.t("st.enemy"), fight))
  else
    dl.ui.enemy:hide()
  end
end
