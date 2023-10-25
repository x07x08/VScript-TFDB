# VScript-TFDB

This is just the [YADB / TFDB](https://github.com/x07x08/TF2-Dodgeball-Modified) plugin ported to VScript.

# Requirements

1. A `vscript_convar_allowlist.txt` file in `tf/cfg`. The default one is recommended.
2. A compatible map.

   The map must have at least one spawner that is [correctly named](https://github.com/x07x08/VScript-TFDB/blob/main/vscripts/tfdb.nut#L288) for each team. The old `tfdb_` maps should satisfy this requirement.

# How to run

1. Paste the `vscripts` folder in `tf/scripts`.
2. Either execute the script by using `script_execute tfdb` or pack it inside a map and run it in some way.

# Issues

1. Sometimes "fake deflects" can be triggered.
2. Custom models aren't added to the downloads table.

# To-do

1. Make each flamethrower unique in some way.
2. Make this gamemode actually fun and team-based.
