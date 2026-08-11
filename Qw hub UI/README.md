# Qw Hub UI Library

## Documentation 

### Creating a New Window 

```lua
local Library = loadstring(game:HttpGet("[https://raw.githubusercontent.com/Qw3rty707/UI-releases/refs/heads/main/Pink/Source.lua](https://raw.githubusercontent.com/Qw3rty707/UI-releases/refs/heads/main/Qw%20hub%20UI/Source.lua)"))()
--[[
i highly recommend you use the Library:storeEvent(type: RbxScriptSignal,type: Thread) function on your end when using RbxscriptSignal like renderstepped or Inputbegan to prevent memory leaks when unloading the UI 
]]


local NewWindow = Library:Window({Title = "Qw hub", Game = "Universal"})

--[[
self:Window(
{
type Title(title): string
type Game(game): string

}
)
]]
```
### Creating a new Tab
```lua
    
	local NewCombatTab = NewWindow:Tab({Image = "rbxassetid://136879043989014"})
  --[[
  Window:Tab({
  type Image(image): string (images only you could use getcustomasset too)
  type Subtabs: boolean
  })
```

