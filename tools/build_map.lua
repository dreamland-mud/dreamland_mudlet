-- Build Dreamland-mapping.dat inside Mudlet, with the package's own mapper.
--
--   lua dlMapDir = "/path/to/dreamland_mudlet"; dofile(dlMapDir .. "/tools/build_map.lua")
--
-- Run it in an empty profile: it wipes the map first.
dl = dl or {}
dofile(dlMapDir .. "/src/07_mapper.lua")

local f = assert(io.open(dlMapDir .. "/tools/rooms.json"))
local rooms = yajl.to_value(f:read("*a"))
f:close()

for _, id in pairs(getRooms() and table.keys(getRooms()) or {}) do
  deleteRoom(id)
end

local byNum = {}
for _, r in ipairs(rooms) do
  byNum[r.num] = r
end

-- Breadth first inside each area, so every room after the first is placed
-- next to a neighbour that is already on the map.
local added = {}
for _, seed in ipairs(rooms) do
  if not added[seed.num] then
    local queue = { seed }
    added[seed.num] = true
    local head = 1
    while queue[head] do
      local r = queue[head]
      head = head + 1
      dl.map.addRoom(r)
      for _, target in pairs(r.exits) do
        local next = byNum[target]
        if next and not added[target] and next.map == r.map then
          added[target] = true
          queue[#queue + 1] = next
        end
      end
    end
  end
end

local out = dlMapDir .. "/Dreamland-mapping.dat"
saveMap(out)
echo(string.format("\nbuild_map: %d rooms -> %s\n", #rooms, out))
