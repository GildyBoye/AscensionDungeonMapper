# Ascension Dungeon Mapper

WoW 3.3.5a addon for the [Ascension](https://ascension.gg) server. Draw and share dungeon/raid routes on the real in-game map.

## Features

- Pick an era (Classic/TBC/WotLK) and a dungeon or raid from the list
- Real map art, learned automatically or pre-seeded for most instances
- Multi-wing dungeons (Scarlet Monastery, Dire Maul) get separate entries and routes per wing
- Freehand draw tool, a click-to-click line tool, and 7 line colors
- Markers with titles, descriptions, raid-target/role/color icons, and numbered (1-9) markers
- Erase, Undo, Clear
- Up to 5 saved routes per dungeon, plus a built-in "Default" route per dungeon where one's been provided
- Export/Import as a paste-able text string
- Share to party/raid/guild, other addon users get a Get/Ignore prompt, then a preview before importing
- Resizable, movable, minimizable route HUD that auto-pops when you zone into a recognized instance
- Route HUD can overlay the current route onto the minimap (buggy/approximate — no real distance data for custom dungeons)
- Minimap icon to open/close

## Usage

1. Open with the minimap icon or `/adm`, `/dungeonmapper`, `/dr`
2. Pick an era, then a dungeon or raid
3. Draw / Line / Marker / Erase to build a route
4. Save it (you'll be asked for a name if it's new)
5. Export to share, or Import to load someone else's

A gold "Default" slot may show up in the route list — that's a built-in route bundled with the addon. It can be loaded but not deleted or renamed; editing it and hitting Save creates your own separate copy under the same name.

## Route HUD

- Pops up automatically when you enter a dungeon/raid it recognizes, or open it manually with `/dr hud`
- Drag to move, drag the top-left grip to resize (aspect ratio is locked)
- "_" minimizes it, "M" toggles the minimap route overlay, the X closes it
- Edits made in the main window sync to an open HUD live, no reload needed

## Slash commands

- `/adm`, `/dungeonmapper`, `/dr` — open/close the window
- `/dr hud` — open/refresh the route HUD for your current dungeon
- `/dr debug` — while inside an instance, prints map ID info (for reporting a broken map)
- `/dr resetmaps` — clears cached map IDs

## Links

- GitHub: https://github.com/GildyBoye/AscensionDungeonMapper
- Discord: https://discord.com/invite/mQjgHCW

Made by Gild.
