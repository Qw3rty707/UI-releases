local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/Qw3rty707/UI-releases/refs/heads/main/Pink/Source.lua"))()

local Window = Library:Window({Title = "Qw Hub"})
local RageTab = Window:Page({Title = "Rage",Image = "rbxassetid://136879043989014",SubPages = false,})
local VisualsTab = Window:Page({Title = "Extra Sensory Perception",SubPages = true,})
local SettingsTab = Window:Page({Title = "Settings", Image = "rbxassetid://72732892493295",Filled = true,})

local PlayersPage = VisualsTab:SubPage({Title = "Players"})
local WorldPage = VisualsTab:SubPage({Title = "World"})

local selfSection,HostileSection,FriendlySection = WorldPage:Section({Title = "Self",Side = "Left"}), WorldPage:Section({Title = "Hostile", Side = "Right"}), WorldPage:Section({Title = "Friendly", Side = "Left"})

local InterfaceSettingsSection = SettingsTab:Section({Title = "User Interface"})

selfSection:Switch({Title = "Enabled", callback = function(bool)
	print(bool)
end,})

selfSection:Slider({Title = "Max render distance", Increment = 0.7, Max = 1000,Value = 0, Unit = "km", Min = 10, callback = function(bool)
	print(bool)
end,})

HostileSection:Switch({Title = "Enabled", callback = function(bool)
	print(bool)
end,})
HostileSection:Switch({Title = "Box", callback = function(bool)
	print(bool)
end,})
HostileSection:Switch({Title = "Health Bar", callback = function(bool)
	print(bool)
end,})
HostileSection:Switch({Title = "Health Text", callback = function(bool)
	print(bool)
end,})
HostileSection:Switch({Title = "Username", callback = function(bool)
	print(bool)
end,})
HostileSection:Combo({Title = "Box Style", List = {"Box", "3D","Round corner"}, Value = {"Box","3D"}, callback = function(bool)
	print(bool)
end,})
HostileSection:Slider({Title = "Max render distance", Increment = 0.7, Max = 1000,Value = 0, Unit = "Studs", Min = 10, callback = function(bool)
	print(bool)
end,})
local ThemePresets = {
	Default = {			
		DarkContrastBackground = Library.Utility.Theme.DarkContrastBackground,
		Accent = Library.Utility.Theme.Accent,
		Text = Library.Utility.Theme.Text,
		Muted = Library.Utility.Theme.Muted,
		BorderInner = Library.Utility.Theme.BorderInner,
		BorderOuter = Library.Utility.Theme.BorderOuter,
		LightContrastBackground = Library.Utility.Theme.LightContrastBackground,

	},
	Dracula = {
		Accent = Color3.fromHex("9a81b3"),
		DarkContrastBackground = Color3.fromHex("252730"),
		Text = Color3.fromHex("b4b4b8"),
		Muted = Color3.fromHex("88888b"),
		BorderInner = Color3.fromHex("3c384d"),
		BorderOuter = Color3.fromHex("202126"),
		LightContrastBackground = Color3.fromHex("2a2c38"),
	},
	Interwebz = {		
		Accent = Color3.fromHex("c9654b"),
		DarkContrastBackground = Color3.fromHex("1f162b"),
		Text = Color3.fromHex("fcfcfc"),
		Muted = Color3.fromHex("a8a8a8"),
		BorderInner = Color3.fromHex("40364f"),
		BorderOuter = Color3.fromHex("1a1a1a"),
		LightContrastBackground = Color3.fromHex("291f38"),

	}, 
	Neko  = {		
		Accent = Color3.fromHex("d21f6a"),
		DarkContrastBackground = Color3.fromHex("131313"),
		Text = Color3.fromHex("ffffff"),
		Muted = Color3.fromHex("afafaf"),
		BorderInner = Color3.fromHex("2d2d2d"),
		BorderOuter = Color3.fromHex("000000"),
		LightContrastBackground = Color3.fromHex("171717"),

	}, 
}
local ThemepresetsDropdown = InterfaceSettingsSection:Dropdown({Title = "Theme Preset",  List = {},Callback = function(selectedTheme)
	for preset,ValueTable in pairs(ThemePresets) do 
		if preset == selectedTheme then

			for Theme,v in next, ValueTable do 
			Library.Utility:SetTheme(Theme,v)

			end 
		end
	end
end})
for Themes,_ in pairs(ThemePresets) do 
	ThemepresetsDropdown:AddOption(Themes)
	--ThemepresetsDropdown:SetValue("Default")
end
ThemepresetsDropdown:SetValue("Default")
