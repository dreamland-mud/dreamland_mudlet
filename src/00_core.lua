-- DreamLand interface for Mudlet.
--
-- Everything on screen comes from GMCP (Char.Vitals, Dreamland.Prompt,
-- Comm.Channel.Text), never from matching game text, so it works in every game
-- language and with any custom prompt. The game text itself is never gagged or
-- moved: the panels only repeat it, so screen reader players lose nothing.
dl = dl or {}
dl.version = "2.3"
dl.prompt = dl.prompt or {}
dl.ui = dl.ui or {}

local SETTINGS_FILE = getMudletHomeDir() .. "/dreamland_ui.lua"

dl.settings = dl.settings or { hidden = false, width = 30 }

function dl.loadSettings()
  if io.exists(SETTINGS_FILE) then
    local saved = {}
    table.load(SETTINGS_FILE, saved)
    for k, v in pairs(saved) do
      dl.settings[k] = v
    end
  end
end

function dl.saveSettings()
  table.save(SETTINGS_FILE, dl.settings)
end

-- The panel speaks the language the player picked in the game, which arrives
-- with every prompt.
function dl.lang()
  local l = dl.prompt.lang
  if dl.strings[l] then
    return l
  end
  return "en"
end

function dl.t(key)
  return dl.strings[dl.lang()][key] or dl.strings.en[key] or key
end

-- "none" is how the server says a prompt block is empty.
function dl.has(v)
  return v ~= nil and v ~= "none" and v ~= ""
end

-- ANSI colour digits the server uses in the prompt (hit_clr and the like),
-- as the bright variants the web client draws.
dl.ansi = {
  ["0"] = "#808080", ["1"] = "#ff5555", ["2"] = "#55ff55", ["3"] = "#ffff55",
  ["4"] = "#5555ff", ["5"] = "#ff55ff", ["6"] = "#55ffff", ["7"] = "#ffffff",
}

dl.colors = {
  title = "#b48cff",
  text = "#c0c0c0",
  dim = "#707070",
  zone = "#00aaaa",
  room = "#55ffff",
  bg = "#14111c",
  button = "#2a2238",
  buttonFight = "#5a1e28",
}
