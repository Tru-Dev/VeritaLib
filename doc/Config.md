# VeritaLib Preprocessor Configuration
The [vlib_conf.lua](/src/vlib_conf.lua) file allows you to configure many aspects of VeritaLib.  
They should be documented here.

## Debug
- `debug: table`
  - `enable: boolean` - whether to enable debug mode.

## Source Result
- `no_comments: boolean` - whether to remove comments from the resulting source. Implied by `minify`.
- `minify: boolean` - whether to minify the Lua files (removes comments + insignificant whitespace)

## General
- `default_config: table` - the default configuration that your game uses.  
  If `config.json` is missing, it appends this table to the default video configuration.  
  If `config.json` is missing some keys, or some keys are the wrong type, then it fills them in
  from this table.

## Screen
- `target_res: { width: integer, height: integer }` - The game's target resolution.  
  It will be scaled up or down to match the window size.
