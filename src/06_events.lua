-- Wiring: GMCP events, install/uninstall, and the `dl` command.

local OWNER = "dreamland"

function dl.ui.render()
  dl.ui.updateVitals()
  dl.ui.renderInfo()
  dl.ui.renderButtons()
end

-- The server sends only the prompt fields that changed, like it does for the
-- web client, so merge them into what we already have.
function dl.onPrompt()
  local p = gmcp.Dreamland and gmcp.Dreamland.Prompt
  if type(p) ~= "table" then
    return
  end
  local oldLang = dl.prompt.lang
  for k, v in pairs(p) do
    dl.prompt[k] = v
  end
  if not dl.ui.root then
    dl.ui.build()
  end
  if dl.prompt.lang ~= oldLang and dl.chat.refreshTabs then
    dl.chat.refreshTabs()
    dl.ui.buttonSig = nil
  end
  dl.ui.render()
end

-- Mudlet installs its generic mapper on every new profile. DreamLand has no
-- mapper of its own, and an idle generic mapper keeps asking for a prompt
-- pattern, so remove it -- unless the player already drew a map with it.
function dl.quietGenericMapper()
  if not table.contains(getPackages(), "generic_mapper") then
    return
  end
  local rooms = getRooms() or {}
  if next(rooms) ~= nil then
    return
  end
  uninstallPackage("generic_mapper")
end

-- The 2019 package drew a bottom bar, a mapper and a chat window. When it is
-- upgraded in a running session its windows outlive its scripts, so hide them.
local OLD_WINDOWS = { "bottompanel", "dhb.healthbox", "dhb.ui.mapchat", "dhb.ui.chat",
                      "dhb.ui.mapper", "DemonChatTabs" }

function dl.hideOldPackage()
  local hidden = false
  for _, name in ipairs(OLD_WINDOWS) do
    local w = Geyser.windowList[name]
    if w then
      w:hide()
      hidden = true
    end
  end
  if hidden then
    setBorderBottom(0)
  end
end

function dl.start()
  dl.loadSettings()
  dl.hideOldPackage()
  deleteAllNamedEventHandlers(OWNER)
  registerNamedEventHandler(OWNER, "prompt", "gmcp.Dreamland.Prompt", dl.onPrompt)
  registerNamedEventHandler(OWNER, "chat", "gmcp.Comm.Channel.Text", dl.chat.onText)
  registerNamedEventHandler(OWNER, "resize", "sysWindowResizeEvent", function()
    dl.ui.applyBorder()
  end)
  registerNamedEventHandler(OWNER, "uninstall", "sysUninstallPackage", function(_, name)
    if name == "Dreamland" then
      dl.ui.destroy()
      deleteAllNamedEventHandlers(OWNER)
    end
  end)
  tempTimer(1, dl.quietGenericMapper)
end

function dl.help()
  cecho("\n<orchid>DreamLand UI " .. dl.version .. "<reset>\n"
    .. "  dl hide        -- hide the side panel (the game text stays as it is)\n"
    .. "  dl show        -- show it again\n"
    .. "  dl width <N>   -- panel width, 15 to 60 percent of the window\n")
end

function dl.command(args)
  args = (args or ""):trim()
  local width = args:match("^width%s+(%d+)$")
  if args == "hide" then
    dl.ui.setHidden(true)
  elseif args == "show" then
    dl.ui.setHidden(false)
  elseif width then
    dl.ui.setWidth(math.max(15, math.min(60, tonumber(width))))
  else
    dl.help()
  end
end

dl.start()
