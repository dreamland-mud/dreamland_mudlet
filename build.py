#!/usr/bin/env python3
"""Assemble Dreamland.xml (the Mudlet package) from src/*.lua.

Edit the Lua files, run `python3 build.py`, commit both. The deploy workflow
fails if Dreamland.xml is out of date with src/.
"""
import glob
import os
import sys
from xml.sax.saxutils import escape

ROOT = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(ROOT, "Dreamland.xml")


def script(name, body):
    return (
        '\t\t\t<Script isActive="yes" isFolder="no">\n'
        f"\t\t\t\t<name>{escape(name)}</name>\n"
        "\t\t\t\t<packageName></packageName>\n"
        f"\t\t\t\t<script>{escape(body)}</script>\n"
        "\t\t\t\t<eventHandlerList />\n"
        "\t\t\t</Script>\n"
    )


def build():
    scripts = []
    for path in sorted(glob.glob(os.path.join(ROOT, "src", "*.lua"))):
        name = os.path.splitext(os.path.basename(path))[0].split("_", 1)[-1]
        with open(path, encoding="utf-8") as f:
            scripts.append(script(name, f.read()))

    return (
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        "<!DOCTYPE MudletPackage>\n"
        '<MudletPackage version="1.001">\n'
        "\t<AliasPackage>\n"
        '\t\t<AliasGroup isActive="yes" isFolder="yes">\n'
        "\t\t\t<name>Dreamland</name>\n"
        "\t\t\t<script></script>\n"
        "\t\t\t<command></command>\n"
        "\t\t\t<packageName></packageName>\n"
        "\t\t\t<regex></regex>\n"
        '\t\t\t<Alias isActive="yes" isFolder="no">\n'
        "\t\t\t\t<name>dl</name>\n"
        "\t\t\t\t<script>dl.command(matches[2])</script>\n"
        "\t\t\t\t<command></command>\n"
        "\t\t\t\t<packageName></packageName>\n"
        "\t\t\t\t<regex>^dl(?:\\s+(.*))?$</regex>\n"
        "\t\t\t</Alias>\n"
        "\t\t</AliasGroup>\n"
        "\t</AliasPackage>\n"
        "\t<ScriptPackage>\n"
        '\t\t<ScriptGroup isActive="yes" isFolder="yes">\n'
        "\t\t\t<name>Dreamland</name>\n"
        "\t\t\t<packageName></packageName>\n"
        "\t\t\t<script></script>\n"
        "\t\t\t<eventHandlerList />\n"
        + "".join(scripts)
        + "\t\t</ScriptGroup>\n"
        "\t</ScriptPackage>\n"
        "</MudletPackage>\n"
    )


if __name__ == "__main__":
    xml = build()
    if "--check" in sys.argv:
        with open(OUT, encoding="utf-8") as f:
            if f.read() != xml:
                sys.exit("Dreamland.xml is out of date: run python3 build.py")
        sys.exit(0)
    with open(OUT, "w", encoding="utf-8") as f:
        f.write(xml)
