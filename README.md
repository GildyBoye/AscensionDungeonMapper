# Ascension Dungeon Mapper

A World of Warcraft addon (3.3.5a client, built for the [Ascension](https://ascension.gg) server) for drawing and sharing dungeon and raid routes on the real in-game map art.

## What it does

- **Pick an era and instance** — Classic, TBC, or WotLK, then any dungeon or raid from a collapsible list (click "Dungeons" / "Raids" to expand or collapse each section). Each entry shows its typical leveling range.
- **Real map art as the canvas** — the addon shows the actual in-game map for whichever instance you pick, learned automatically the first time you walk into it (and pre-seeded for most instances so it usually works with zero visits). A green/gray dot next to each dungeon in the list shows whether its map is already known.
- **Multi-wing dungeons get their own entries** — dungeons with genuinely distinct wings (Scarlet Monastery's Graveyard/Library/Armory/Cathedral, Dire Maul's North/West/East) show up as separate list entries, each with its own saved routes, instead of being lumped together under one map.
- **Freehand drawing** — click and hold to paint a route directly onto the map; pick from 7 colors in the palette that appears at the bottom of the map while the Draw tool is active.
- **Markers** — drop a marker anywhere on the map and give it a title/description note (shown on hover). Pick from the 8 classic raid-target icons (skull, cross, moon, etc.) or leave it as a plain marker.
- **Erase** — click any stroke or marker to remove just that one.
- **Undo** and **Clear** (Clear asks for confirmation first — it wipes the whole map).
- **Save up to 5 routes per dungeon/wing** — saved routes show in a small list; click one to load it. Switching between routes (or dungeons) doesn't lose your work as long as you save first.
- **Export / Import** — turn a route into a compressed, paste-able text string to share with other players, or paste one someone shared with you. Works across dungeons/eras — importing loads the right instance automatically.
- **Minimap icon** — click to open/close the window; drag to reposition it.

## Usage

1. Click the minimap icon, or run `/adm`, `/dungeonmapper`, or `/dr`.
2. Pick an era, then a dungeon or raid from the list on the left.
3. Use Draw / Marker / Erase from the toolbar to build a route. Undo/Clear are there if you need them.
4. Hit **Save** — if the current route doesn't have a name yet, you'll be asked for one.
5. **Export** to get a share string, or **Import** to load one someone sent you.

## Slash commands

| Command | Effect |
|---|---|
| `/adm`, `/dungeonmapper`, `/dr` | Open/close the main window |
| `/dr debug` | While standing in an instance: prints the live map ID, what's cached, and what's in the default table — useful for reporting a dungeon whose map isn't loading right |
| `/dr resetmaps` | Clears all cached map IDs so they get re-learned from scratch (defaults + walking in again) |

## Links

- GitHub: https://github.com/GildyBoye/AscensionDungeonMapper
- Discord: https://discord.com/invite/mQjgHCW

Made by Gild.
