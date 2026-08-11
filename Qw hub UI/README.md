# Qw Hub UI Library

## Documentation 

### Making a New Window

```lua
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Qw3rty707/UI-releases/refs/heads/main/Pink/Source.lua](https://raw.githubusercontent.com/Qw3rty707/UI-releases/refs/heads/main/Qw%20hub%20UI/Source.lua)"))()
--[[
i would reccomend you use the Library:storeEvent(type: RbxScriptSignal,type: Thread) when using RbxscriptSignal like renderstepped or Inputbegan to prevent memory leaks when unloading the UI on your end  
]]
local NewWindow = Library:Window({Title = "Qw hub", Game = "Universal"})

```

