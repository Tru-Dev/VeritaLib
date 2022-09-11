# VeritaLib for LuaSTG Sub
*Unlocking the power of LuaSTG.*

VeritaLib is a framework meant for use in LuaSTG Sub.

- [Download/Setup](#downloadsetup)
- [Usage](#usage)
- [Documentation](#documentation)
- [Features (work in progress)](#features-work-in-progress)
- [FAQ](#faq)
- [License](#license)
- [Credits](#credits)

## Download/Setup
> TODO: Make releases page

Head over to the releases page and download the first zip file in the list. It should include a
[specially-designed copy of LuaSTG Sub](https://github.com/Tru-Dev/LuaSTG-Sub/tree/verita) and a
copy of VeritaLib.

The project is configured to build and debug automatically under Visual Studio Code.
It should prompt you to install the recommended extensions if you do not already have them.

VeritaLib uses a Lua preprocessor to allow easy customization. A description of the options is
available [here](doc/Config.md). They are also defined and described in `vlib_conf.lua`,
feel free to edit them as needed.

## Usage
> TODO: Make it usable

## Documentation
See [the doc folder](./doc/).

If you're using VS Code, you should get intellisense if you install the
[sumneko Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua).

## Features (work in progress)
- [X] [Intuitive OOP for game behavior and data classes](doc/Core/Classes.md)
- [X] Graphics contexts to facilitate shaders, render targets, and 2D/3D viewports
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
