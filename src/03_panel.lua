-- The info panel: the same blocks the web client shows, in the same order,
-- redrawn from dl.prompt after every prompt.

local C = dl.colors
local has = dl.has

-- Who panel race and clan names, keyed by the short codes the server sends.
-- Same table as mudjs windowletsConstants.js.
local RACE_NAMES = {
  ar = { en = "Arial", ru = "Ариал", ua = "Аріал" },
  ce = { en = "Centa", ru = "Кентавр", ua = "Кентавр" },
  cl = { en = "ClGia", ru = "ОбВелик", ua = "ХмВелет" },
  da = { en = "D-Elf", ru = "ТемЭльф", ua = "ТемЕльф" },
  dr = { en = "Drow", ru = "Дроу", ua = "Дроу" },
  du = { en = "Duerg", ru = "Дуэргар", ua = "Дуергар" },
  dw = { en = "Dwarf", ru = "Дварф", ua = "Дварф" },
  el = { en = "Elf", ru = "Эльф", ua = "Ельф" },
  fa = { en = "Faery", ru = "Фея", ua = "Фея" },
  fe = { en = "Felar", ru = "Фелар", ua = "Фелар" },
  fi = { en = "FiGia", ru = "ОгВелик", ua = "ВгВелет" },
  fr = { en = "FrGia", ru = "ИнВелик", ua = "КрВелет" },
  gi = { en = "Githy", ru = "Гитианк", ua = "Гітіанки" },
  gn = { en = "Gnome", ru = "Гном", ua = "Гном" },
  ha = { en = "H-Elf", ru = "ПолЭльф", ua = "НапЕльф" },
  ho = { en = "Hobbi", ru = "Хоббит", ua = "Гобіт" },
  hu = { en = "Human", ru = "Человек", ua = "Людина" },
  ke = { en = "Kendr", ru = "Кендер", ua = "Кендер" },
  ma = { en = "Mawg", ru = "Чес", ua = "Псюрень" },
  ro = { en = "Rocks", ru = "Роксир", ua = "Роксір" },
  sa = { en = "Satyr", ru = "Сатир", ua = "Сатир" },
  st = { en = "StGia", ru = "ШтВелик", ua = "ШтВелет" },
  sv = { en = "Svirf", ru = "Свирф", ua = "Свірф" },
  tr = { en = "Troll", ru = "Тролль", ua = "Троль" },
  ur = { en = "Urkhi", ru = "Урукха", ua = "Урукхай" },
}

local CLAN_NAMES = {
  a = { en = "Artificers", ru = "Артель", ua = "Артіль" },
  b = { en = "Fury", ru = "Ярости", ua = "Ярості" },
  c = { en = "Chaos", ru = "Хаос", ua = "Хаос" },
  e = { en = "Exiles", ru = "Изгои", ua = "Ізгої" },
  f = { en = "Flowers", ru = "Цветы", ua = "Квіти" },
  g = { en = "Ghosts", ru = "Призраки", ua = "Привиди" },
  i = { en = "Invaders", ru = "Захватчики", ua = "Загарбники" },
  k = { en = "Knights", ru = "Рыцари", ua = "Лицарі" },
  l = { en = "Lions", ru = "Львы", ua = "Леви" },
  o = { en = "Loners", ru = "Одиночки", ua = "Одинаки" },
  r = { en = "Rulers", ru = "Правители", ua = "Правителі" },
  s = { en = "Shalafi", ru = "Шалафи", ua = "Шалафі" },
}

local function localName(tbl, code)
  local e = tbl[code]
  if not e then
    return code or ""
  end
  return e[dl.lang()] or e.en
end

-- Affect families in the web order: curses first, bad news leads.
local AFFECT_FAMILIES = { "mal", "pro", "det", "trv", "enh", "cln" }

local function out(text, color)
  dl.ui.info:hecho((color or C.text) .. text)
end

local function title(text)
  out("\n" .. text .. "\n", C.title)
end

local function pad(s, n)
  s = tostring(s or "")
  local len = utf8.len(s) or #s
  if len >= n then
    return s
  end
  return s .. string.rep(" ", n - len)
end

local function location(p)
  if not (has(p.zone) or has(p.room)) then
    return
  end
  title(dl.t("loc.title"))
  if has(p.zone) then
    out(p.zone .. "\n", C.zone)
  end
  if has(p.room) then
    out(p.room .. "\n", C.room)
  end
  local ex = p.exits
  if type(ex) == "table" then
    -- e: open exits, h: closed ones, as lowercase English letters.
    -- l: which letters to draw, "r" for Russian ones.
    local dirs = { { "n", "N", "С" }, { "e", "E", "В" }, { "s", "S", "Ю" },
                   { "w", "W", "З" }, { "d", "D", "О" }, { "u", "U", "П" } }
    out(dl.t("loc.exits") .. " ")
    for _, d in ipairs(dirs) do
      local letter = ex.l == "r" and d[3] or d[2]
      if string.find(ex.h or "", d[1], 1, true) then
        out(letter .. " ", C.dim)
      elseif string.find(ex.e or "", d[1], 1, true) then
        out(letter .. " ", C.room)
      else
        out("· ", C.dim)
      end
    end
    out("\n")
  end
  if type(p.sect) == "table" and has(p.sect.n) then
    out(p.sect.n .. "\n", C.dim)
  end
end

local function timeWeather(p)
  local t, d, w = p.time, p.date, p.w
  if type(t) ~= "table" and type(d) ~= "table" and type(w) ~= "table" then
    return
  end
  title(dl.t("tw.title"))
  if type(t) == "table" then
    out(string.format("%s %s", t.h or "", t.tod or ""))
    if has(t.l) then
      out(", " .. t.l)
    end
    out("\n")
  end
  if type(d) == "table" then
    out(string.format("%s / %s", d.d or "", d.m or ""))
    if has(d.s) then
      out(" / " .. d.s)
    end
    out("\n")
  end
  if type(w) == "table" and has(w.m) then
    out(w.m .. "\n")
  end
end

local function quests(p)
  -- aq: area quest, t = title, i = current step.
  if type(p.aq) == "table" then
    title(p.aq.t or "")
    out((p.aq.i or "") .. "\n", "#d0b040")
  end
  -- q: questor task, t = minutes left, i = what to do.
  if type(p.q) == "table" then
    title(string.format("%s %s %s", dl.t("qst.title"), p.q.t or "", dl.t("qst.min")))
    out((p.q.i or "") .. "\n")
  end
end

local function group(p)
  local g = p.group
  -- Solo players get only the leader line; the web hides the block then too.
  if type(g) ~= "table" or (g.pc == nil and g.npc == nil) then
    return
  end
  title(dl.t("grp.title") .. " " .. (g.ln or ""))
  local function row(m)
    out(pad(m.sees, 12) .. pad(m.level, 4))
    out(pad((m.health or "?") .. "%", 6), dl.ansi[tostring(m.hit_clr)] or C.text)
    out(tostring(m.tnl or "") .. "\n", C.dim)
  end
  if type(g.leader) == "table" then
    row(g.leader)
  end
  for _, list in ipairs({ g.pc, g.npc }) do
    if type(list) == "table" then
      for _, m in ipairs(list) do
        row(m)
      end
    end
  end
end

local function affects(p)
  local items = {}
  for _, fam in ipairs(AFFECT_FAMILIES) do
    if type(p[fam]) == "table" then
      for _, a in ipairs(p[fam]) do
        items[#items + 1] = { n = a.n, d = tonumber(a.d), curse = fam == "mal" }
      end
    end
  end
  if #items == 0 then
    return
  end
  -- Curses first, then soonest to expire; permanent ones (d < 0) last.
  local function rank(a)
    if a.d == nil or a.d < 0 then
      return math.huge
    end
    return a.d
  end
  table.sort(items, function(a, b)
    if a.curse ~= b.curse then
      return a.curse
    end
    return rank(a) < rank(b)
  end)
  title(dl.t("aff.title"))
  for i, a in ipairs(items) do
    local color = dl.ansi["2"]
    if a.curse then
      color = dl.ansi["1"]
    elseif a.d ~= nil and a.d < 0 then
      color = dl.ansi["6"]
    elseif a.d ~= nil and a.d <= 1 then
      color = dl.ansi["3"]
    end
    out(a.n or "?", color)
    out(i < #items and "  " or "\n")
  end
end

local function stats(p)
  local p1, p2 = p.p1, p.p2
  if type(p1) ~= "table" and type(p2) ~= "table" then
    return
  end
  title(dl.t("par.title"))
  if type(p1) == "table" and type(p1.ps) == "table" then
    local keys = { "str", "int", "wis", "dex", "con", "cha" }
    for i, k in ipairs(keys) do
      out(dl.t("par." .. k) .. " ", C.dim)
      out(tostring(p1.ps[i] or "?"))
      out("(" .. tostring((p1.cs or {})[i] or "?") .. ")", C.dim)
      out(i % 3 == 0 and "\n" or "  ")
    end
  end
  if type(p2) == "table" then
    for _, k in ipairs({ { "hit", "h" }, { "dam", "d" }, { "ac", "a" }, { "save", "s" } }) do
      out(dl.t("par." .. k[1]) .. " ", C.dim)
      out(tostring(p2[k[2]] or "?") .. "  ")
    end
    out("\n")
  end
end

local function who(p)
  local w = p.who
  if type(w) ~= "table" or type(w.p) ~= "table" then
    return
  end
  title(string.format("%s (%s)", dl.t("who.title"), w.t or #w.p))
  for _, pl in ipairs(w.p) do
    local name = pl.n or "?"
    dl.ui.info:hechoLink(C.room .. pad(name, 13), function()
      send("whois " .. name, true)
    end, "whois " .. name, true)
    out(pad(localName(RACE_NAMES, pl.r), 9), C.dim)
    if pl.cn and pl.cn ~= "n" then
      out(localName(CLAN_NAMES, pl.cn))
    end
    out("\n")
  end
end

function dl.ui.renderInfo()
  if not dl.ui.info or dl.settings.hidden then
    return
  end
  local p = dl.prompt
  dl.ui.info:clear()
  location(p)
  timeWeather(p)
  quests(p)
  group(p)
  affects(p)
  stats(p)
  who(p)
end
