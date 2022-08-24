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

Head over to the releases page and download the zip file. It should include a copy of LuaSTG Sub
specifically designed for VeritaLib and a copy of VeritaLib.

## Usage
> TODO: Make it usable

## Documentation
See [the doc folder](./doc/).

If you're using VS Code, you should get intellisense if you install the
[Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua).

## Features (work in progress)
- [X] [Intuitive OOP for game behavior and data classes](doc/Core/Classes.md)
- [ ] Scene/stage system to manage resource scopes

## FAQ
- Is this supposed to replace THlib?  
  - Yes, but it's not meant to be the same thing as THlib.  
    THlib is a rigid framework designed for only one purpose: creating Touhou-style shmups.  
    Because this was very limiting for many use cases, I decided to make my own version.
- Where's the launch file?
  - LuaSTG Sub automatically loads video settings from `config.json`, rendering the launch file
    effectively obsolete.  
    You can still have one, though.
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
