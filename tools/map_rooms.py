#!/usr/bin/env python3
"""Dump the starter-map zones from dreamland_areas as Room.Info-shaped JSON.

    python3 tools/map_rooms.py ../dreamland_areas > tools/rooms.json

tools/build_map.lua feeds the result to the package's own mapper inside
Mudlet and saves Dreamland-mapping.dat, the map Client.Map points at.
"""
import json
import os
import re
import sys
import xml.etree.ElementTree as ET

# Where a new character spends the first hours: the Moehewa onboarding, then
# Midgaard with its two newbie zones.
AREAS = ["intro", "midgaard", "newbie2", "school"]
DIRS = {"north": "n", "east": "e", "south": "s", "west": "w", "up": "u", "down": "d"}
MAP_URL = "https://dreamland.rocks/maps/%s.html"


def strip(text):
    return re.sub(r"\{.", "", text or "").strip()


def text(node, tag, lang="en"):
    for n in node.findall(tag):
        if n.get("l") == lang and n.text:
            return strip(n.text)
    return ""


def main(areas_dir):
    rooms = []
    for area in AREAS:
        root = ET.parse(os.path.join(areas_dir, area + ".are.xml")).getroot()
        area_name = text(root.find("areadata"), "name")
        for node in root.find("rooms"):
            exits = {}
            for ex in node.find("exits") if node.find("exits") is not None else []:
                target = ex.find("target")
                if ex.get("name") in DIRS and target is not None and target.text:
                    exits[DIRS[ex.get("name")]] = int(target.text)
            rooms.append({
                "num": int(node.get("name")),
                "name": text(node, "name"),
                "area": area_name,
                "map": MAP_URL % area,
                "exits": exits,
            })
    json.dump(rooms, sys.stdout, ensure_ascii=False, indent=0)


if __name__ == "__main__":
    main(sys.argv[1])
