-- Command buttons, as in the web client. A button sends the command in the
-- player's own language, so the echo in the main window reads naturally.
-- Source of truth for every word: <name>/<aliases> in dreamland_world/commands.

local WORDS = {
  look = { en = "look", ru = "смотреть", ua = "дивитися" },
  inv = { en = "inventory", ru = "инвентарь", ua = "інвентар" },
  equip = { en = "equipment", ru = "снаряжение", ua = "спорядження" },
  score = { en = "score", ru = "счет", ua = "рахунок" },
  recall = { en = "recall", ru = "возврат", ua = "повернення" },
  flee = { en = "flee", ru = "сбежать", ua = "втекти" },
  practice = { en = "practice", ru = "практиковать", ua = "практикувати" },
  magic = { en = "skills spells", ru = "умения заклинания", ua = "вміння заклинання" },
  skills = { en = "skills skills", ru = "умения навыки", ua = "вміння навички" },
  quests = { en = "quest", ru = "задания", ua = "завдання" },
  commands = { en = "commands", ru = "команды", ua = "команди" },
}

local INFO = { "look", "inv", "equip", "score" }

local function word(key)
  local w = WORDS[key]
  return w[dl.lang()] or w.en
end

-- Returns the list of {label, command, fight} buttons for the current state.
local function buttonList(p)
  local list = {}
  local fighting = (tonumber(p.fight) or 0) > 0
  if fighting then
    -- fcmd: the combat actions this character can use right now, from the server.
    local actions = type(p.fcmd) == "table" and p.fcmd or {}
    if #actions == 0 then
      actions = { word("flee"), word("recall") }
    end
    for _, cmd in ipairs(actions) do
      list[#list + 1] = { cmd:sub(1, 1):upper() .. cmd:sub(2), cmd, true }
    end
    for _, key in ipairs(INFO) do
      list[#list + 1] = { dl.t("cmd." .. key), word(key) }
    end
  else
    local keys = { "look", "inv", "equip", "score", "recall", "practice" }
    -- sp: number of spells; no spell list button for those who have none.
    if p.sp ~= 0 then
      keys[#keys + 1] = "magic"
    end
    for _, k in ipairs({ "skills", "quests", "commands" }) do
      keys[#keys + 1] = k
    end
    for _, key in ipairs(keys) do
      list[#list + 1] = { dl.t("cmd." .. key), word(key) }
    end
  end
  return list
end

dl.ui.buttons = dl.ui.buttons or {}

function dl.ui.renderButtons()
  if not dl.ui.buttonBox or dl.settings.hidden then
    return
  end
  local list = buttonList(dl.prompt)

  -- Rebuild only when the set changes: a prompt arrives after every command.
  local sig = {}
  for _, b in ipairs(list) do
    sig[#sig + 1] = b[1] .. "=" .. b[2]
  end
  sig = table.concat(sig, "|")
  if sig == dl.ui.buttonSig then
    return
  end
  dl.ui.buttonSig = sig

  for _, label in ipairs(dl.ui.buttons) do
    label:hide()
  end

  -- Two columns, filled top-down, the taller one first.
  local half = math.ceil(#list / 2)
  for i, b in ipairs(list) do
    local label = dl.ui.buttons[i]
    if not label then
      label = Geyser.Label:new({ name = "dl.button." .. i }, dl.ui.buttonBox)
      dl.ui.buttons[i] = label
    end
    local col = i <= half and 0 or 1
    local row = i <= half and (i - 1) or (i - half - 1)
    label:move(col == 0 and 4 or "50%+2", row * 26 + 2)
    label:resize("50%-6", 23)
    label:echo("<center>" .. b[1] .. "</center>")
    label:setStyleSheet(string.format(
      "background-color: %s; color: white; border: 1px solid #4a3d66; border-radius: 4px;",
      b[3] and dl.colors.buttonFight or dl.colors.button))
    local cmd = b[2]
    label:setClickCallback(function() send(cmd) end)
    label:show()
  end
end
