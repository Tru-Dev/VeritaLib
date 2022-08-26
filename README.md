# VeritaLib for LuaSTG Sub
*Unlocking the power of LuaSTG.*

VeritaLib is a framework meant for use in LuaSTG Sub.

- [Download/Setup](#downloadsetup)
  - [Customization](#customization)
- [Usage](#usage)
- [Documentation](#documentation)
- [Features (work in progress)](#features-work-in-progress)
- [FAQ](#faq)
- [License](#license)
- [Credits](#credits)

## Download/Setup
> TODO: Make releases page

Head over to the releases page and download a zip file. The chosen zip file should include a
[specially-designed copy of LuaSTG Sub](https://github.com/Tru-Dev/LuaSTG-Sub/tree/verita) and a
copy of VeritaLib.

There should be multiple zip files. Each one will have a different configuration:
- Release builds: Built with debug disabled.
- Minified builds: Same as release but with comments and (most) whitespace removed.  
  Useful for a release version of a game.
- Debug builds: Built with debug enabled.
- Custom: Customize your build to your needs. Described in the section below.

### Customization
If you are to grab the custom build (or download the source directly and bring in a
VeritaLib-compatible LuaSTG Sub build), you can open the folder in Visual Studio Code, and
provided you have the [sumneko Lua](https://marketplace.visualstudio.com/items?itemName=sumneko.lua) and
[Local Lua Debugger](https://marketplace.visualstudio.com/items?itemName=tomblind.local-lua-debugger-vscode)
extensions, it should be able to build, launch, and debug through VS Code in its current state.

The preprocessor options are defined and described in `vlib_conf.lua`. Feel free to edit them as needed.

## Usage
> TODO: Make it usable

## Documentation
See [the doc folder](./doc/).

If you're using VS Code, you should get intellisense if you install the
[sumneko Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua).

## Features (work in progress)
- [X] [Intuitive OOP for game behavior and data classes](doc/Core/Classes.md)
- [ ] Scene/stage system to manage resource scopes

## FAQ
- Is this supposed to replace THlib?  
  - Yes, but it's not meant to be the same thing as THlib.  
    THlib is a rigid framework designed for only one purpose: creating Touhou-style shmups.  
    Because this was very limiting for many use cases, I decided to make my own version.
- Is this finished?
  - Not yet.

## License
VeritaLib is distributed under the zlib license.  
What this means is that you can use it without crediting me (although that would be appreciated!),
but if you modify it you need to a. state what you changed, and b. not claim that you made
Veritalib yourself.

## Credits
- [TruDev](https://github.com/Tru-Dev): Creator of VeritaLib
- [Zino](https://github.com/zinoLath): Contributor
- [Kuanlan](https://github.com/Demonese): Creator of LuaSTG Sub
