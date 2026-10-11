-- Mapper: draws the map from GMCP Room.Info as the player walks.
--
-- Room.Info carries the room vnum, its name and area in the player's
-- language, the exits as {dir = vnum} and the zone's web map URL, whose file
-- name ("midgaard") is the stable key of the area. The downloadable starter
-- map (Client.Map) is built by tools/build_map.lua with these same functions,
-- so rooms found while walking and rooms from the file line up.
dl.map = dl.map or {}

local DELTA = {
  n = { 0, 1, 0 }, e = { 1, 0, 0 }, s = { 0, -1, 0 }, w = { -1, 0, 0 },
  u = { 0, 0, 1 }, d = { 0, 0, -1 },
}

-- "https://dreamland.rocks/maps/midgaard.html" -> "midgaard"
function dl.map.areaKey(info)
  local key = type(info.map) == "string" and info.map:match("([^/]+)%.html$")
  return key or info.area or "unknown"
end

local function findArea(key)
  for _, id in pairs(getAreaTable()) do
    if getAreaUserData(id, "dl.key") == key then
      return id
    end
  end
end

function dl.map.areaId(key, name)
  local id = findArea(key)
  if not id then
    id = addAreaName(name ~= "" and name or key)
    if not id or id < 0 then
      -- The name is taken by an area from another source: keep it unique.
      id = addAreaName((name ~= "" and name or key) .. " (" .. key .. ")")
    end
    setAreaUserData(id, "dl.key", key)
  elseif name ~= "" and getRoomAreaName(id) ~= name then
    -- The player switched the game language: follow it.
    setAreaName(id, name)
  end
  return id
end

-- Exits are remembered per room so that a room met later can find the
-- neighbour that points at it.
local function savedExits(id)
  local raw = getRoomUserData(id, "dl.exits")
  if raw == nil or raw == "" then
    return {}
  end
  local ok, t = pcall(yajl.to_value, raw)
  return ok and type(t) == "table" and t or {}
end

-- Pick coordinates next to a room of the same area that is already placed,
-- either one this room leads to or one that leads here.
local function place(num, areaId, exits)
  for dir, target in pairs(exits) do
    local dlt = DELTA[dir]
    if dlt and roomExists(target) and getRoomArea(target) == areaId then
      local x, y, z = getRoomCoordinates(target)
      return x - dlt[1], y - dlt[2], z - dlt[3]
    end
  end
  for _, other in pairs(getAreaRooms(areaId) or {}) do
    for dir, target in pairs(savedExits(other)) do
      local dlt = DELTA[dir]
      if dlt and tonumber(target) == num then
        local x, y, z = getRoomCoordinates(other)
        return x + dlt[1], y + dlt[2], z + dlt[3]
      end
    end
  end
  -- Nothing to hang on to: start a fresh patch to the right of the area.
  local maxX
  for _, other in pairs(getAreaRooms(areaId) or {}) do
    local x = getRoomCoordinates(other)
    if not maxX or x > maxX then
      maxX = x
    end
  end
  return maxX and maxX + 5 or 0, 0, 0
end

-- Add or refresh one room. Returns its id.
function dl.map.addRoom(info)
  local num = tonumber(info.num)
  if not num then
    return
  end
  local exits = {}
  for dir, target in pairs(info.exits or {}) do
    exits[dir] = tonumber(target)
  end
  local areaId = dl.map.areaId(dl.map.areaKey(info), info.area or "")

  if not roomExists(num) then
    addRoom(num)
    setRoomArea(num, areaId)
    setRoomCoordinates(num, place(num, areaId, exits))
  end
  if info.name and info.name ~= "" then
    setRoomName(num, info.name)
  end

  -- Exits only ever get added: the server hides the ones the player cannot
  -- see right now (darkness, closed hidden doors), which is not a removal.
  local known = savedExits(num)
  for dir, target in pairs(exits) do
    known[dir] = target
    if roomExists(target) then
      setExitStub(num, dir, false)
      setExit(num, target, dir)
    else
      setExitStub(num, dir, true)
    end
  end
  setRoomUserData(num, "dl.exits", yajl.to_string(known))

  -- Link the rooms that were waiting for this one behind a stub.
  for dir, target in pairs(exits) do
    if roomExists(target) then
      for backDir, backTarget in pairs(savedExits(target)) do
        if tonumber(backTarget) == num then
          setExitStub(target, backDir, false)
          setExit(target, num, backDir)
        end
      end
    end
  end
  return num
end

function dl.map.onRoomInfo()
  local info = gmcp.Room and gmcp.Room.Info
  if type(info) ~= "table" then
    return
  end
  local num = dl.map.addRoom(info)
  if num then
    centerview(num)
  end
end
