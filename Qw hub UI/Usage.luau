--> Once i finish writing the docs which will happen after i finish the whole UI, i will delete this
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Qw3rty707/UI-releases/refs/heads/main/Qw%20hub%20UI/Source.luau"))()

do 
	local NewWindow = Library:Window({Title = "Qw hub", Game = "Universal"})
	local CombatTab = NewWindow:Tab({Title = "Combat", Image = "rbxassetid://136879043989014"})
	local VisualsTab = NewWindow:Tab({Title = "Visuals",Image = "rbxassetid://109514269737059",Subtabs=true})
	VisualsTab:Subtab({Title = "Players",Image="rbxassetid://15150178302"})
	VisualsTab:Subtab({Title = "World",Image="rbxassetid://15964021599"})

	local SettingsTab = NewWindow:Tab({Title = "Settings",Size = UDim2.new(0,300,0,300),Filled=true,Image = "rbxassetid://72732892493295"})
	local UISettings = SettingsTab:Section({Title = "UI"})
	UISettings:Keybind({Title = "open/close menu", Bind = "RightControl"})
	local Configslisttext = UISettings:Text({Text = "Config list", AddModules = true})
	local ConfigslistContainer = Configslisttext:Settings()
	ConfigslistContainer:NewConfig("Rage","This configuration provides all the needs to start dominating matches!","Qw")
	ConfigslistContainer:NewConfig("Rage","This configuration provides all the needs to start dominating matches!","Qw")
	ConfigslistContainer:NewConfig("Rage","This configuration provides all the needs to start dominating matches!","Qw")
	ConfigslistContainer:NewConfig("Rage","This configuration provides all the needs to start dominating matches!","Qw")

	UISettings:Toggle({Title = "Blur", Value = true, Callback = function(bool)
		NewWindow:BlurEnabled(bool)
	end,})
	UISettings:Slider({Title = "Blur radius", Value = 0, Increment = 0.1, Minimum = 0, Maximum = 1,Callback = function(number)
		
	end,})
	UISettings:Button({Title ="Self Destruct",Callback = function()
		NewWindow:SelfDestruct()
	end,})
	
	local themeSection = SettingsTab:Section({Title = "Theme"})
	local ThemePresets = {
		Default = {			
			DarkContrast = Library.Theme.DarkContrast,
			Accent = Library.Theme.Accent,
			LightText = Library.Theme.Text,
			DarkText = Library.Theme.DarkText,
			InnerStroke = Library.Theme.InnerStroke,
			OuterStroke = Library.Theme.OuterStroke,
			LightContrast = Library.Theme.LightContrast,
			ModuleBackground = Library.Theme.ModuleBackground
		},
	}
	themeSection:Dropdown({Title="Preset Theme",Options={},combo=false,Value="Default",Callback=function(option)

	end,})
	themeSection:Colorpicker({Title = "Accent", Color = Library.Theme.Accent, Callback = function(Color)
		NewWindow:ChangeTheme("Accent",Color)
	end,})
	
	local Textcolorpicker = themeSection:Colorpicker({Title = "Text Color", PaletteTitle = "Light Text",Color = Library.Theme.LightText, Callback = function(Color)
		NewWindow:ChangeTheme("LightText",Color)
	end,})
	Textcolorpicker:Colorpicker({Title = "Dark Text", Color = Library.Theme.DarkText,Callback = function(Color)
		NewWindow:ChangeTheme("DarkText",Color)
	end})
	local contrastbackgrounds = themeSection:Colorpicker({Title = "Background", PaletteTitle = "Dark Contrast",Color = Library.Theme.DarkContrast, Callback = function(Color)
		NewWindow:ChangeTheme("DarkContrast",Color)
	end,})
	contrastbackgrounds:Colorpicker({Title = "Light Contrast", Color = Library.Theme.LightContrast,Callback = function(Color)
		NewWindow:ChangeTheme("LightContrast",Color)
	end})
	themeSection:Colorpicker({Title = "Module Background", Color = Library.Theme.ModuleBackground, Callback = function(Color)
		NewWindow:ChangeTheme("ModuleBackground",Color)
	end,})
	local BorderColors = themeSection:Colorpicker({Title = "Border", PaletteTitle = "Inner Border",Color = Library.Theme.InnerStroke, Callback = function(Color)
		NewWindow:ChangeTheme("InnerStroke",Color)
	end,})
	BorderColors:Colorpicker({Title = "Outer border", Color = Library.Theme.OuterStroke,Callback = function(Color)
		NewWindow:ChangeTheme("OuterStroke",Color)
	end})
	end
	
	
