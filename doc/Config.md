# VeritaLib Configuration
The [vlib_conf.lua](/src/vlib_conf.lua) file allows you to configure many aspects of VeritaLib.  
They should be documented here.

## Debug
- `debug: table`
  - `enable: boolean` - whether to enable debug mode.
  - `show_ui: boolean` - whether to show the debug ui by default. If debug is enabled, it can
    always be toggled with F12.

## General
- `default_config: table` - the default configuration that your game uses.  
  If `config.json` is missing, it appends this table to the default video configuration.  
  If `config.json` is missing some keys, or some keys are mistyped, then it fills them in from this
  table.

## Screen
- `target_res: { width: integer, height: integer }` - The game's target resolution.  
  It will be scaled up or down to match the window size.
