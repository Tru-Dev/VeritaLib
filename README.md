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
Head over to the [releases page](https://github.com/Tru-Dev/VeritaLib/releases/latest) and download
the first zip file in the list. It should include a
[specially-designed copy of LuaSTG Sub](https://github.com/Tru-Dev/LuaSTG-Sub/tree/verita) and a
copy of VeritaLib.

VeritaLib uses a Lua preprocessor (run by LuaSTG itself) to allow easy customization. A
description of the options is available [here](https://github.com/Tru-Dev/VeritaLib/wiki/Configuration-Reference).
They are also defined and described in `vlib_conf.lua`, feel free to edit them as needed.

The project is configured to build and debug automatically under Visual Studio Code.
It should prompt you to install the recommended extensions if you do not already have them.

If you do not use VS Code, then you can run the provided batch files to launch and build VeritaLib.
The batch files do not have any external dependencies aside from LuaSTG itself.

## Usage
When you have built VeritaLib with your preferred settings, add a `main.lua` file to your source tree
(along with VeritaLib's files). A minimal tree should look like this:

- Your project folder
  - `res`: Resource folder
  - `src`: Source code folder
    - `VeritaLib`: Built VeritaLib code folder
    - `loader.lua`: Smart Lua Loader, required by VeritaLib
    - `main.lua`: LuaSTG entrypoint

At the top of your `main.lua`, you should at least add this line:
```lua
lstg.DoFile("src/loader.lua")
```
This will add a custom loader to the modules system to allow relative imports.

If you want to use VeritaLib, you'll probably want to require it:
```lua
local vlib = require("VeritaLib")
```

VeritaLib uses a scenes system to manage global resources and state.  
Here's a basic scene:
```lua
local scene_hello = Scene.New {
    init = function(self)
        lstg.LoadTTF("Arial", "C:/Windows/Fonts/arial.ttf", 64, 64)
    end,
    render = function(self)
        lstg.RenderClear(lstg.Color(0xFF222222))
        lstg.RenderTTF(
            "Arial", "Hello, World!",
            vlib.screen.width / 2, vlib.screen.width / 2,
            vlib.screen.height / 2, vlib.screen.height / 2,
            5, lstg.Color(0xFFFFFFFF), 2
        )
    end
}

Scene.Set(scene_hello)
```

You can read more about using VeritaLib in the documentation.

## Documentation
See [the repo's wiki](https://github.com/Tru-Dev/VeritaLib/wiki).

If you're using VS Code, you should get intellisense if you install the
[sumneko Lua extension](https://marketplace.visualstudio.com/items?itemName=sumneko.lua).

## Features (work in progress)
- [X] Intuitive OOP for game behavior and data classes
- [X] Graphics contexts to facilitate shaders, render targets, and 2D/3D viewports
- [X] Scene/stage system to manage resource scopes
- [X] Input mapping system
- [X] Texture pager/atlas
- [X] Asynchronous resource loading
- [ ] Menu helper

## FAQ
- Is this supposed to replace THlib?  
  - Yes, but it's not meant to be the same thing as THlib.  
    THlib is a rigid framework designed for only one purpose: creating Touhou-style shmups.  
    Because this was very limiting for many use cases, I decided to make my own version.
- Is this finished?
  - Not yet.
- Is there a graphical editor?
  - An editor is planned, but has not been started.

## License
VeritaLib is distributed under the zlib license.  
What this means is that you can use it without crediting me (although that would be appreciated!),
but if you modify it you need to a. state what you changed, and b. not claim that you made
Veritalib yourself.

## Credits
- [TruDev](https://github.com/Tru-Dev): Creator of VeritaLib
- [Zino](https://github.com/zinoLath): Contributor
- [Kuanlan](https://github.com/Demonese): Creator of LuaSTG Sub
