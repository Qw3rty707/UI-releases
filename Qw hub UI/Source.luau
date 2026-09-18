--[[
Qw Hub UI by Qw
Contact me by my discord qw211 for inquires or help about the Ui library.

Do not sell this UI or claim it as yours. This UI is free to use for anyone and will be forever.

there is no need to feel ashamed to learn or copy code from here, I tried my best to explain 
some of my code to make it easier to understand. 

* to add: search guide should also scroll to the element. I noticed that i did not add a element guide with scrolling implemented, so like it wont scroll to the element when you use search
*to add: subtabs filled sections
* to add: Colorpicker text boxes and use accent button

*Bug: When the theme is changed, the option text color does not change alongside the change of theme but when clicked again, it finally changes. This is without combo on, have not tested if this occurs for combo but it might
* Bug: tab auto size broke again???? WTF i swear i fixed it last time but something broke it again, i am so frustrated over this . Solution: remove it
* Performance issue oberservation: 500 tabs, hovering the tabs causes FPS reduction from 60ish to 40ish. Thought: it might be from trying to calculate the textbound and Ui scale or too much connections (i doubt this because i know Roblox optimizes rbxscriptsignal)
* Performance issue observation: 500 tabs, scrolling the tab bar causes FPS reduction from 60ish to 40ish. Thought: It could be from the amount of instances and tabs with threads and RBXSCRIPTSignal connections, and i see no one creating more than 10 tabs so i would ignore fixing this unless it gets serious


]]

if not game:IsLoaded() then game.Loaded:Wait() end

-->Services<--
local Players = game:GetService("Players");
local UserInputService = game:GetService("UserInputService");
--local RunService = game:GetService("RunService");
local TweenService = game:GetService("TweenService");
local HttpService = game:GetService("HttpService");
local TextService = game:GetService("TextService")
-->Variables<--
local localPlayer = Players.LocalPlayer;
local camera = workspace.CurrentCamera;
local Mouse = localPlayer:GetMouse();


local Library = {
	Connections = {},
	Subtabs = {}, 
	ModuleDock = {},
	short_keybind_names = {
		["MouseButton1"] = "LMB",
		["MouseButton2"] = "RMB",
		["MouseButton3"] = "MMB",
		["Insert"] = "INS",
		["LeftAlt"] = "LALT",
		["LeftControl"] = "LC",
		["LeftShift"] = "LS",
		["RightAlt"] = "RALT",
		["RightControl"] = "RC",
		["RightShift"] = "RS",
		["CapsLock"] = "CAPS",
		["Return"] = "RET",
		["Backspace"] = "BSP",
		["BackSlash"] = "BS"
	},
	Actives = {},
	InstanceStorage = {},
	WhitelistedMouse = {
		Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,
		Enum.UserInputType.MouseButton3
	},
	BlacklistedKeys = {
		Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S,
		Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down,
		Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab,
		Enum.KeyCode.Backspace, Enum.KeyCode.Escape
	},
	Flags = {}, --> stores the modules 
	Tabs = {}, --> stores tabs
	Elements = {},

	--> text configuration  <--
	Text = {
		Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Size = 12,
		Name = "Inter",
		TextStrokeTransparency = 0,
	},
	Images = {},
	
	Theme = {
		Accent=Color3.fromRGB(121,0,0),
		DarkContrast=Color3.fromRGB(7, 7, 7),
		ModuleBackground = Color3.fromRGB(16,16,16),
		LightContrast=Color3.fromRGB(11, 11, 11),
		LightText= Color3.fromRGB(255,255,255),
		DarkText=Color3.fromRGB(100,100,100),
		InnerStroke = Color3.fromRGB(24,24,24),
		OuterStroke = Color3.fromRGB(0,0,0),
		Inactive = Color3.fromRGB(100,100,100),
		Active = Color3.fromRGB(255,255,255),
		LoadButton = Color3.fromRGB(25, 143, 25),
		SaveButton = Color3.fromRGB(140, 140, 140),
		DeleteButton = Color3.fromRGB(140, 0, 2),

	},

	TweenInfo = TweenInfo.new(0.3, Enum.EasingStyle.Linear,Enum.EasingDirection.In),
	ZIndex = 3,

	Device = "Desktop", --> "Desktop" or "Mobile"
}
if UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
	Library.Device = "Mobile" 
	print("Mobile")
else
	Library.Device = "Desktop"
	print("Desktop")
end



--> stores RBXSCRIPTSIGNAl to disconnect them once the UI is unloaded to prevent memory leaks<--
function Library:storeEvent(Event: RBXScriptSignal, thread: thread)
	local Connection;
	local Passed, Statement = pcall(function()
		Connection = Event:Connect(thread);
	end)
	if Passed then
		table.insert(self.Connections, Connection);
		return Connection;
	else
		warn(Event, Statement);
		return nil;
	end
end


function Library:MakeDraggable(Dragger: Instance , Object:Instance, OnChange:thread, OnEnd:thread)
	local Position, StartPosition = nil, nil

	Library:storeEvent(Dragger.InputBegan,function(Input)
		if Input.UserInputType == Enum.UserInputType.Touch or  Input.UserInputType == Enum.UserInputType.MouseButton1  then
			Position = UserInputService:GetMouseLocation()
			StartPosition = Object.AbsolutePosition
		end
	end)
	Library:storeEvent(UserInputService.InputChanged,function(Input)
		if StartPosition and (Input.UserInputType ==
			Enum.UserInputType.MouseMovement  or Input.UserInputType == Enum.UserInputType.Touch) then
			local Mouse =UserInputService:GetMouseLocation()
			local Delta = Mouse - Position
			Position = Mouse

			Delta = Object.Position + UDim2.fromOffset(Delta.X, Delta.Y)
			if OnChange then OnChange(Delta) end
		end
	end)
	Library:storeEvent(Dragger.InputEnded,function(Input)
		if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
			if OnEnd then
				OnEnd(Object.Position, StartPosition)
			end
			Position, StartPosition = nil, nil
		end
	end)

end

--> converts color3.new values to RGB <--
function Library:ToRGB(color: Color3)
	return math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255) 
end

--> this is to like automatically adapt to a new theme that a object does so whenever like a toggle is toggled and i change it to accent and text to light text than i will update it so when you change theme it wont change the toggle main color 
function Library:UpdateObject(Object:Instance, Property:any, Value:string)
	if not self.InstanceStorage[Object] then
		self.InstanceStorage[Object] = {[Property] = Value}
	else
		self.InstanceStorage[Object][Property] = Value
	end
end

--> Makes new frames <--
function Library:Render(ObjectType: string, Properties) 
	local Passed, Statement = pcall(function()
		local Object = Instance.new(ObjectType)
		for Property, Value in pairs(Properties) do
		--	if string.find(Property,"Transparency") and typeof(Value) == "number" then
			--	Library:UpdateObject(Object,Property,Value)
			--end
			if string.find(Property, "Color") and typeof(Value) == "string" and ObjectType ~= "UIGradient" then

				local Theme = self.Theme[Value]
					Library:UpdateObject(Object, Property, Value)
				 
				Object[Property] = Theme
			else
				Object[Property] = Value
			end
		end

		return Object 
	end)

	if Passed then
		return Statement
	else
		warn("Failed to render object: " .. tostring(ObjectType, Properties.Name),
			tostring(Statement))
		return nil
	end
end
--> converts Hex to a color3 RGB value <--
function Library:hexToColor3(hex: string )
	local hex = hex:gsub("#","")
	local r = tonumber("0x" .. hex:sub(1, 2)) * 255
	local g = tonumber("0x" .. hex:sub(3, 4)) * 255
	local b = tonumber("0x" .. hex:sub(5, 6)) * 255
	return Color3.fromRGB(r, g, b)
end
--> changes the theme of the menu <--
function Library:ChangeTheme(Theme: string, Color: Color3)
	if self.Theme[Theme] ~= Color then
		self.Theme[Theme] = Color
		--
		for Index, Value in pairs(self.InstanceStorage) do
			for Index2, Value2 in pairs(Value) do
				if Value2 == Theme then Index[Index2] = Color end
			end
		end
	end
end

function Library:FindModuleByFlag(Needle)
	-- search through the haystalk and isolate the needle
end
local NewConfig = {}
NewConfig.__index = NewConfig
--> i use this to list the configs for the dropdown and isolate the name so they won't show as the entire directory
function Library:ListConfigFiles()
	-- List the config files, remove the directory string and isolate the file name 
end

function Library:SaveConfigFile(Folder:string,Title:string,Description:string,Author:string) : NewConfig
	if not isfolder(Folder) then makefolder(Folder) end
	local config = setmetatable({},NewConfig)
	for _, Element in pairs(Library.Elements) do 
		if Element.Flag and Element.Flag ~= ""   then 
			config[Element.Flag] = Library.Flags[Element.Flag]
		end
	end
	if Description ~= "" then config.Description = Description end
	config.Author = Author ~= "" and Author or "Unknown"
	writefile(Folder .. "/Configs/" .. Title .. ".Json", HttpService:JSONEncode(config))
	return config :: NewConfig
end
function Library:LoadConfig(Title)
	-- Grab data from config file by decoding it and load the modules settings and when it comes to multi dropdown, keybind, and colorpicker i have to specifically decode them and load them different than usual because the values are different for some reason 
		
end
function Library:CloseAllActives()

	for _,Actives in pairs(Library.Actives) do 
		if Actives.Opened then
			Actives:Open(false)
			table.clear(Library.Actives)
		end
		if Actives.SearchOpened then 
			Actives:OpenSearch(false)
			table.clear(Library.Actives)
		end
		end
		
end
function Library:ImportImage()
	
end
function Library:IsHovered(Object:Instance)
	if Mouse.X >= Object.AbsolutePosition.X and Mouse.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X  and Mouse.Y >= Object.AbsolutePosition.Y and Mouse.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y then 
		return true
	else 
		return false
	end
end
function Library:ChangeFont(Font: Enum.Font| string,useCustomFont:boolean?) --> this part is not done and has not been tested yet <--
	for Index, Value in pairs(self.InstanceStorage) do
		if Value:IsA("FontFace") then
			for Index2, _ in pairs(Value) do
				Index[Index2] = Font

			end
		end
	end

end


--> Object  creation <-- 
Library.UI_Create ={
	NewWindow = function()
		local ScreenGui = Library:Render("ScreenGui", {ZIndexBehavior = Enum.ZIndexBehavior.Global, ResetOnSpawn = false}) 
		local UIScale = Library:Render("UIScale", {Parent = ScreenGui})
		local Blur = Library:Render("BlurEffect", {  
			Size = 56,
			Parent = game.Lighting 
		}) 


		local WindowHeader = Library:Render("Frame", {  
			Size = UDim2.new(0, 356, 0, 80),
			Name = "WindowHeader",

			Position = UDim2.new(0.33260834217071533, 0, 0, 5),
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			BackgroundColor3 = "DarkContrast",
			Parent = ScreenGui 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 7),
			TopRightRadius = UDim.new(0, 7),
			BottomRightRadius = UDim.new(0, 7),
			BottomLeftRadius = UDim.new(0, 7),
			Parent = WindowHeader 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Name = "UiTitle",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			RichText = true,
			Size = UDim2.new(0, 92, 0, 12),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 11, 0, 12),
			TextSize = 12,
			Parent = WindowHeader 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextDirection = Enum.TextDirection.RightToLeft,
			TextColor3 = "DarkText",
			RichText = true,
			Name = "GameTitle",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(0, 70, 0, 12),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, -11, 0, 12),
			TextSize = 12,
			Parent = WindowHeader 
		}) 
		local TabContainer = Library:Render("ScrollingFrame", {  
			AutomaticCanvasSize = Enum.AutomaticSize.X,
			ScrollBarThickness = 0,
			ScrollBarImageTransparency = 1,
			ClipsDescendants = true,
			BackgroundColor3 = "LightContrast",
			ZIndex = Library.ZIndex,
			AnchorPoint = Vector2.new(0, 1),
			Position = UDim2.new(0, 11, 1, -12),
			Name = "TabContainer",
			ScrollingDirection = Enum.ScrollingDirection.X,
			Size = UDim2.new(1, -70, 0, 34),
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = WindowHeader 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 7),
			TopRightRadius = UDim.new(0, 7),
			BottomRightRadius = UDim.new(0, 7),
			BottomLeftRadius = UDim.new(0, 7),
			Parent = TabContainer 
		}) 
		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 2),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = TabContainer 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = TabContainer 
		}) 
		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 6),
			PaddingLeft = UDim.new(0, 6),
			Parent = TabContainer 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = TabContainer 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = WindowHeader 
		}) 
		local SearchToggleButton = Library:Render("TextButton", {  
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = "LightContrast",
			ZIndex = Library.ZIndex,
			AnchorPoint = Vector2.new(1, 1),
			Name = "SearchToggleButton",
			Position = UDim2.new(1, -11, 1, -12),
			BorderSizePixel = 0,
			TextSize = 14,
			Size = UDim2.new(0, 34, 0, 34),
			Parent = WindowHeader 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = SearchToggleButton 
		}) 
		Library:Render("UIStroke", {  
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SearchToggleButton 
		}) 
		Library:Render("UICorner", {  
			Parent = SearchToggleButton 
		}) 
		local SearchFrame = Library:Render("Frame", {  
			Visible = false,
			Name = "SearchFrame",
			BackgroundColor3 = "DarkContrast",
			AnchorPoint = Vector2.new(0.5,0),
			Position = UDim2.new(0.5, 0, 1, 40),
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			Size = UDim2.new(0, 250, 0, 30),
			Parent = WindowHeader 
		}) 
		Library:Render("UIStroke", {  
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SearchFrame 
		}) 
		Library:Render("UICorner", {  
			Parent = SearchFrame 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = SearchFrame 
		}) 
		Library:Render("ImageLabel", {  
			ImageColor3 = "Inactive",
			ZIndex = Library.ZIndex,
			Name = "SearchImage",
			Size = UDim2.new(0, 12, 0, 12),
			AnchorPoint = Vector2.new(0, 0.5),
			Image = "rbxassetid://135906220803984",
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 11, 0.5, 0),
			BorderSizePixel = 0,
			Parent = SearchFrame 
		}) 
		local Inputbox = Library:Render("TextBox", {  
			Name = "Inputbox",
			CursorPosition = -1,
			TextColor3 = "LightText",
			ZIndex = Library.ZIndex + 1,
			Text = "",
			Size = UDim2.new(1, -29, 1, 0),
			Position = UDim2.new(0, 29, 0, 0),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			BackgroundTransparency = 1,
			PlaceholderColor3 = "DarkText",
			TextXAlignment = Enum.TextXAlignment.Left,
			PlaceholderText = "Search ...",
			TextSize = 12,
			Parent = SearchFrame 
		}) 
		Library:Render("TextLabel", {  
			Name = "SuggestionAutoComplete",
			TextColor3 = "DarkText",
			ZIndex = Library.ZIndex,
			Text = "",
			Size = UDim2.new(1, 0, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
			Parent = Inputbox 
		}) 
		Library:Render("TextLabel", {  
			Name = "Hint",
			TextColor3 = "DarkText",
			ZIndex = Library.ZIndex,
			Text = "Press >",
			Size = UDim2.new(1, -6, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			TextSize = 12,
			Parent = Inputbox 
		}) 
		Library:Render("ImageLabel", {  
			ImageColor3 = "Inactive",
			Name = "SearchImage",
			Size = UDim2.new(0, 15, 0, 15),
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = Library.ZIndex,
			Image = "rbxassetid://135906220803984",
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BorderSizePixel = 0,
			Parent = SearchToggleButton 
		}) 
		local HidetabbarButton = Library:Render("TextButton", {  
			TextTransparency = 1,
			Text = "",
			ZIndex = Library.ZIndex,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 1, 10),
			Name = "HidetabbarButton",
			Size = UDim2.new(1, 0, 0, 20),
			BorderSizePixel = 0,
			Parent = WindowHeader 
		}) 
		Library:Render("ImageLabel", {  
			Name = "Arrow",
			Size = UDim2.new(0, 18, 0, 18),
			Rotation = 180,
			ImageColor3 = "Active",
			Image = "rbxassetid://95082215439315",
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			Parent = HidetabbarButton 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = WindowHeader 
		}) 


		return ScreenGui,Blur
	end,
	NewResultContainer = function()
		local ResultContainer =Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 0),
			Name = "ResultContainer",
			Position = UDim2.new(0, 0, 1, 8),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency=1,
		}) 

		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 6),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ResultContainer 
		}) 

		Library:Render("UICorner", {  
			Parent = ResultContainer 
		}) 
	return ResultContainer
	end,
	NewResultFrame = function()
		local ResultFrame = Library:Render("Frame", {  
			Name = "ResultFrame",
			Size = UDim2.new(1, 0, 0, 40),
			BorderSizePixel = 0,
			BackgroundColor3 = "LightContrast",
		}) 
		Library:Render("UIStroke", {  
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = ResultFrame 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = ResultFrame 
		}) 
		Library:Render("UICorner", {  
			Parent = ResultFrame 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Name = "ModuleTitle",
			Size = UDim2.new(1, -40, 0, 12),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 11, 0, 8),
			BorderSizePixel = 0,
			TextSize = 12,
			Parent = ResultFrame 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			Name = "PageInfo",
			Size = UDim2.new(1, -40, 0, 12),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 11, 0, 19),
			BorderSizePixel = 0,
			TextSize = 12,
			Parent = ResultFrame 
		}) 
		Library:Render("ImageButton", {  
			ImageColor3 = "Active",
			Name = "GotoButton",
			AnchorPoint = Vector2.new(1, 0.5),
			Image = "rbxassetid://90385430770591",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -11, 0.5, 0),
			Size = UDim2.new(0, 15, 0, 15),
			BorderSizePixel = 0,
			Parent = ResultFrame 
		}) 
		return ResultFrame
	end,
	NewTabFrame = function()
		local Tabbuton = Library:Render("TextButton", {  
			TextTransparency = 1,
			Text = "",
			BackgroundTransparency = 1,
			ZIndex = Library.ZIndex,
			AutoButtonColor =false,
			AutomaticSize = Enum.AutomaticSize.X,
			Name = "Tabbuton",
			Size = UDim2.new(0, 0, 0, 22),
			BorderSizePixel = 0,
			BackgroundColor3 = "Accent",
		}) 
		 Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent =Tabbuton
		}) 

		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			Parent = Tabbuton 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 4),
			TopRightRadius = UDim.new(0, 4),
			BottomRightRadius = UDim.new(0, 4),
			BottomLeftRadius = UDim.new(0, 4),
			Parent = Tabbuton 
		}) 
		Library:Render("ImageLabel", {  
			ImageColor3 = "Inactive",
			ScaleType = Enum.ScaleType.Fit,
			Name = "TabImage",
			Size = UDim2.new(0, 16, 0, 16),
			AnchorPoint = Vector2.new(0, 0.5),
			ZIndex = Library.ZIndex,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 4, 0.5, 0),
			BorderSizePixel = 0,
			Parent = Tabbuton 
		}) 
		Library:Render("UIGradient", {  
			Rotation = 127,
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,20)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
			},
			Parent = Tabbuton 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			Name = "TabTitle",
			TextColor3 = "DarkText",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			AutomaticSize = Enum.AutomaticSize.X,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClipsDescendants = true,
			TextSize = 12,
			Parent = Tabbuton 
		}) 
		return Tabbuton
	end,
	NewWindowPage = function()
		local NewPageWindow = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(0.5, 0.5),
			Size = UDim2.new(0, 557, 0, 452),
			Name = "NewPageWindow",
			Position = UDim2.new(0.4899267852306366, 0, 0.6116071343421936, 0),
			BorderSizePixel = 0,
			Visible = false,
			ZIndex = Library.ZIndex,
			BackgroundColor3 = "DarkContrast",
		}) 
		Library:Render("UICorner", { 
			TopLeftRadius = UDim.new(0, 8),
			TopRightRadius = UDim.new(0, 8),
			BottomRightRadius = UDim.new(0, 8),
			BottomLeftRadius = UDim.new(0, 8),
			Parent = NewPageWindow 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = NewPageWindow 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = NewPageWindow 
		}) 

		return NewPageWindow
	end,
	NewPage = function()
		local Page = Library:Render("ScrollingFrame", {  
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			ScrollBarImageTransparency = 1,
			Name = "Page",
			Size = UDim2.new(1, 0, 1, -28),
			ZIndex = Library.ZIndex,
			BackgroundTransparency = 1,
			ClipsDescendants = true,

			ScrollingDirection = Enum.ScrollingDirection.Y,
			Position = UDim2.new(0, 0, 0, 28),
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
		}) 
		local Left = Library:Render("Frame", {  
			Size = UDim2.new(0, 100, 1, 0),
			Name = "LEFT",
			BackgroundTransparency = 1,
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = Page 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 19),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Left 
		}) 
		Library:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 1),
			Parent = Left 
		}) 
		local Right = Library:Render("Frame", {  
			Size = UDim2.new(0, 100, 1, 0),
			ZIndex = Library.ZIndex,
			Name = "RIGHT",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = Page 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 19),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Right 
		}) 
		Library:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 1),
			Parent = Right 
		}) 
		Library:Render("UIListLayout", {  
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 14),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Page 
		}) 
		Library:Render("UIPadding", {  
			PaddingBottom = UDim.new(0, 20),
			PaddingLeft = UDim.new(0, 20),
			PaddingRight = UDim.new(0, 20),
			Parent = Page 
		}) 

		return Page



	end,
	NewPageforSubtabsActive = function()
		local Pages = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(0.5, 0),
			Name = "Pages",
			BackgroundTransparency = 1,
			ClipsDescendants  = true,
			Position = UDim2.new(0.5, 0, 0, 28),
			Size = UDim2.new(1, -39, 1, -28),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
		}) 
		Library:Render("UIPageLayout", {  
			Animated = false,
			SortOrder = Enum.SortOrder.LayoutOrder,
			GamepadInputEnabled = false,
			Padding = UDim.new(1, 0),
			ScrollWheelInputEnabled = false,
			TouchInputEnabled = false,
			Parent = Pages 
		}) 
		local SubtabBar = Library:Render("Frame", {  
			Active = true,
			AutomaticSize = Enum.AutomaticSize.X,
			Name = "SubtabBar",
			ZIndex = Library.ZIndex,
			BackgroundColor3 = "DarkContrast",
			Size = UDim2.new(0, 0, 0, 34),
			BorderSizePixel = 0,
			Position = UDim2.new(0, 0, 0, -34 - 5),
		}) 
		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = SubtabBar 
		}) 
		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = SubtabBar 
		}) 
		Library:Render("UICorner", {  
			CornerRadius = UDim.new(0,8),
			Parent = SubtabBar 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SubtabBar 
		}) 


		return Pages, SubtabBar
	end,
	NewSubTab = function()
		local Subtab = Library:Render("TextButton", {  
			ClipsDescendants = false,
			TextTransparency = 1,
			ZIndex = Library.ZIndex,
			Text = "",
			Name = "Subtab",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
		}) 
		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 4),
			PaddingLeft = UDim.new(0, 4),
			Parent = Subtab 
		}) 
		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 3),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent =Subtab
		}) 

		Library:Render("ImageLabel", {  
			ScaleType = Enum.ScaleType.Fit,
			ZIndex = Library.ZIndex,
			Name = "SubtabImage",
			Size = UDim2.new(0, 15, 0, 15),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0.5, 0),
			BorderSizePixel = 0,
			ImageColor3 = "Inactive",
			Parent = Subtab 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			Name = "SubtabTitle",
			TextColor3 = "DarkText",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1,0),
			AnchorPoint = Vector2.new(0, 0.5),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClipsDescendants = false,
			TextSize = 12,
			Parent = Subtab 
		}) 

		return Subtab
	end,
	NewSubTabPage = function()
		local Page = Library:Render("ScrollingFrame", {  
			Active = true,
			ScrollBarImageTransparency = 1,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			ClipsDescendants = true,
			Name = "Page",
			BackgroundTransparency = 1,
			ZIndex = Library.ZIndex,
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
		}) 
		Library:Render("UIListLayout", {  
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 14),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Page 
		}) 
		local Left = Library:Render("Frame", {  
			Size = UDim2.new(0, 100, 1, 0),
			ZIndex = Library.ZIndex,
			Name = "LEFT",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = Page 
		}) 
		Library:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 1),
			Parent = Left 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 19),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Left 
		}) 
		local Right = Library:Render("Frame", {  
			Size = UDim2.new(0, 100, 1, 0),
			BackgroundTransparency = 1,
			ZIndex = Library.ZIndex,
			Name = "RIGHT",
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = Page 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 19),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Right 
		}) 
		Library:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 1),
			Parent = Right 
		}) 
		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 1),
			PaddingLeft = UDim.new(0, 1),
			Parent = Page 
		}) 
		return Page
	end,
	NewSectionFrame = function()
		local SectionFrame = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 0),
			Name = "SectionFrame",
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = "LightContrast",
		}) 
		local SectionHeaderFrame = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			Name = "SectionHeaderFrame",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Parent =SectionFrame
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Name = "Sectiontitle",
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 28),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 0, 0, 0),
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = SectionHeaderFrame 
		}) 
		Library:Render("UICorner", {  
			BottomRightRadius = UDim.new(0, 0),
			BottomLeftRadius = UDim.new(0, 0),
			Parent = SectionHeaderFrame 
		}) 

		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SectionFrame 
		}) 
		Library:Render("UICorner", {  
			Parent = SectionFrame 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = SectionFrame 
		}) 
		Library:Render("UIPadding", {  
			PaddingBottom = UDim.new(0, 11),
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = SectionFrame 
		}) 

		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = SectionFrame 
		}) 
		return SectionFrame
	end,
	NewMultiSectionFrame = function()
		local SectionPagesContainer = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 0),
			Name = "SectionPagesContainer",
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = "LightContrast",
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SectionPagesContainer 
		}) 
		local SectionTabBar = Library:Render("Frame", {  
			BackgroundTransparency = 1,
			Name = "SectionTabBar",
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			Size = UDim2.new(1, 0, 0, 38),
			Parent = SectionPagesContainer 
		}) 
		Library:Render("UICorner", {  
			BottomRightRadius = UDim.new(0, 0),
			BottomLeftRadius = UDim.new(0, 0),
			Parent = SectionTabBar 
		}) 
		Library:Render("UIListLayout", {  
			FillDirection = Enum.FillDirection.Horizontal,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Parent = SectionTabBar 
		}) 
		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = SectionTabBar 
		}) 
		Library:Render("UICorner", {  
			Parent = SectionPagesContainer 
		}) 
		local Pages = Library:Render("Frame", {  
			Name = "Pages",
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			ZIndex = Library.ZIndex,
			Position = UDim2.new(0, 0, 0, 50),
			Size = UDim2.new(1, 0, 0, 0),
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = "LightText",
			Parent = SectionPagesContainer 
		}) 
		Library:Render("UIPadding", {  
			PaddingBottom = UDim.new(0, 11),
			Parent = SectionPagesContainer 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = SectionPagesContainer 
		}) 
		return SectionPagesContainer,Pages
	end,
	NewMultiSectionTab = function()
		local Sectiontab = Library:Render("TextButton", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			ZIndex = Library.ZIndex,
			Name = "Sectiontab",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			BorderSizePixel = 0,
			TextSize = 12,
		}) 
		local Indicator = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(0, 1),
			Name = "Indicator",
			ZIndex = Library.ZIndex,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 4),
			BorderSizePixel = 0,
			BackgroundColor3 = "Accent",
			Parent = Sectiontab 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1, 0),
			TopRightRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(0, 0),
			BottomLeftRadius = UDim.new(0, 0),
			Parent = Indicator 
		}) 
		local page = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 0),
			Name = "page",
			BackgroundTransparency = 1,
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Visible = false,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = "LightText",
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = page 
		}) 
		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = page
		}) 
		return Sectiontab,page
	end,
	NewWidgetContainer = function()
		local ToggleWidgetButton = Library:Render("ImageButton", {  
			Name = "ToggleWidgetButton",
			Size = UDim2.new(0, 12, 0, 12),
			ImageColor3 = "Inactive",
			Image = "rbxassetid://95127553964880",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 0.5, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
		}) 
		local NoclickDetector = Library:Render("TextButton", {  
			Name = "NoclickDetector",
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 10, 0, 0),
			Size = UDim2.new(0, 0, 0, 0),
			ZIndex = Library.ZIndex,
			TextSize = 14,
			Visible = false,
		}) 
		local ModulesContainer = Library:Render("ScrollingFrame", {  
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			ClipsDescendants = true,
			ScrollBarImageTransparency = 1,
			BackgroundColor3 = "LightContrast",
			Name = "ModulesContainer",
			ScrollingDirection = Enum.ScrollingDirection.Y,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = NoclickDetector 
		}) 
		Library:Render("UICorner", {  
			Parent = ModulesContainer 
		}) 
		Library:Render("UIStroke", {  
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = ModulesContainer 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = ModulesContainer 
		}) 
		Library:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = ModulesContainer 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ModulesContainer 
		}) 
		return ToggleWidgetButton,NoclickDetector
	end,
	NewButtonContainer = function()
		local ButtonsContainer = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 22),
			BackgroundTransparency = 1,
			Name = "ButtonsContainer",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
		}) 


		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ButtonsContainer 
		}) 
		return ButtonsContainer
	end,
	NewButton = function()
		local Button = Library:Render("TextButton", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Name = "Button",
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			BackgroundColor3 = "ModuleBackground",
			TextSize = 12,
			Size = UDim2.new(0, 0, 1, 0),
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 6),
			TopRightRadius = UDim.new(0, 6),
			BottomRightRadius = UDim.new(0, 6),
			BottomLeftRadius = UDim.new(0, 6),
			Parent = Button 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = Button 
		}) 
		Library:Render("UIStroke", {  
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = Button 
		}) 
		return Button
	end,
	NewToggle = function()
		local ToggleContainer = Library:Render("TextButton", {  
			Size = UDim2.new(1, 0, 0, 15),
			BackgroundTransparency = 1,
			Text = "",
			Name = "ToggleContainer",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
		}) 
		local Checkbox = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(0, 0.5),
			Name = "Checkbox",
			Position = UDim2.new(0, 0, 0.5, 0),
			ZIndex = Library.ZIndex,
			BackgroundColor3="ModuleBackground",
			BorderSizePixel = 0,
			Size = UDim2.new(0, 15, 0, 15),
			Parent = ToggleContainer 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 4),
			TopRightRadius = UDim.new(0, 4),
			BottomRightRadius = UDim.new(0, 4),
			BottomLeftRadius = UDim.new(0, 4),
			Parent = Checkbox 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = Checkbox 
		}) 
		Library:Render("ImageLabel", {  
			ImageTransparency = 0,
			Name = "Checkmark",
			Image = "rbxassetid://85862941581996",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 0, 0),
			ImageColor3 = "Active",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Parent = Checkbox 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = Checkbox 
		}) 
		Library:Render("UIGradient", {  
			Rotation = -99,
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
			},
			Parent = Checkbox 
		}) 

		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			Name = "ToggleTitle",
			BorderSizePixel = 0,
			Size = UDim2.new(0, 100, 1, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 23, 0, 0),
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = ToggleContainer 
		}) 
		local ToggleExtraModuletContainer = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(1, 0),
			Name = "ToggleExtraModuletContainer",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 100, 1, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Parent = ToggleContainer 
		}) 
		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ToggleExtraModuletContainer 
		}) 
		return ToggleContainer
	end,
	NewDropdown = function()
		local DropdownContainer = Library:Render("TextButton", {  
			TextTransparency = 1,
			Text = "",
			BackgroundTransparency = 1,
			Name = "DropdownContainer",
			Size = UDim2.new(1, 0, 0, 44),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
		}) 
		local DropdownBox = Library:Render("Frame", {  
			Name = "DropdownBox",
			Position = UDim2.new(0, 0, 0, 21),
			ZIndex = Library.ZIndex,
			BackgroundColor3 = "ModuleBackground",
			BorderSizePixel = 0,
			ClipsDescendants = true,
			Size = UDim2.new(1, 0, 0, 23),
			Parent = DropdownContainer 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 6),
			TopRightRadius = UDim.new(0, 6),
			BottomRightRadius = UDim.new(0, 6),
			BottomLeftRadius = UDim.new(0, 6),
			Parent = DropdownBox 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = DropdownBox 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			Name = "DropdownSelected",
			TextTruncate = Enum.TextTruncate.AtEnd,
			Size = UDim2.new(1, -40, 0, 23),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = DropdownBox 
		}) 

		Library:Render("ImageLabel", {  
			ImageColor3 = "Inactive",
			Name = "Dropdownarrow",
			Rotation = 0,
			Size = UDim2.new(0, 18, 0, 18),
			AnchorPoint = Vector2.new(1, 0),
			Image = "rbxassetid://95082215439315",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 0, 2.5),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Parent = DropdownBox 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = DropdownBox 
		}) 
		local NoClickDetector = Library:Render("TextButton", {  
			Visible = false,
			Text = "",
			Name = "NoClickDetector",
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 27),
			Size = UDim2.new(1, 0, 0, 80),
			ZIndex = Library.ZIndex + 3,
			Parent = DropdownBox 
		}) 
		local OptionContainer = Library:Render("ScrollingFrame", {  
			Active = true,
			ScrollBarImageTransparency = 1,
			ScrollBarThickness = 0,
			Name = "OptionContainer",
			ClipsDescendants = true,

			Size = UDim2.new(1, 0, 1, 0),
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			ZIndex = Library.ZIndex + 4,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = NoClickDetector 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = OptionContainer 
		}) 
		Library:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 8),
			PaddingBottom = UDim.new(0, 8),
			Parent = OptionContainer 
		}) 
		Library:Render("Frame", {  
			Name = "SeparatorLine",
			Size = UDim2.new(1, 0, 0, 1),
			ZIndex = Library.ZIndex + 4,
			BorderSizePixel = 0,
			BackgroundColor3 = "InnerStroke",
			Parent = NoClickDetector 
		}) 
		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 8),
			PaddingLeft = UDim.new(0, 8),
			Parent = DropdownBox 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			Name = "DropdownTitle",
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 50, 0, 12),
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = DropdownContainer 
		}) 
		return DropdownContainer
	end,
	NewOption = function()
		local NewOptionContainer = Library:Render("TextButton", {  
			Text = "",
			Name = "NewOptionContainer",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0, 12),
			ZIndex = Library.ZIndex + 3,
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			BorderSizePixel = 0,
			Name = "OptionText",
			AnchorPoint = Vector2.new(1, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(1, 0, 0, 0),
			ZIndex = Library.ZIndex +3,
			TextSize = 12,
			Parent = NewOptionContainer 
		}) 
		local Indicator = Library:Render("Frame", {  
			BackgroundTransparency = 0,
			Size = UDim2.new(0, 0, 1, 0),
			ZIndex = Library.ZIndex + 3,
			Name="Indicator",
			BorderSizePixel = 0,
			BackgroundColor3 = "Accent",
			Parent = NewOptionContainer 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 0),
			TopRightRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(1, 0),
			BottomLeftRadius = UDim.new(0, 0),
			Parent = Indicator 
		}) 
		return NewOptionContainer
	end,
	NewKeybindContainer = function()
		
		local KeybindContainer = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 16),
			BackgroundTransparency = 1,
			Name = "KeybindContainer",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			Name = "KeybindTitle",
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 50, 1, 0),
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = KeybindContainer 
		}) 
		Library:Render("ImageButton", {  
			ImageColor3 = "Inactive",
			Name = "KeybindWidget",
			Size = UDim2.new(0, 16, 0, 16),
			AnchorPoint = Vector2.new(1, 0.5),
			Image = "rbxassetid://72732892493295",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 0.5, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Parent = KeybindContainer 
		}) 
		local KeybindFrame = Library:Render("TextButton", {  
			Text = "",
			AnchorPoint = Vector2.new(1, 0.5),
			BackgroundColor3= "ModuleBackground",
			Name = "KeybindFrame",
			Position = UDim2.new(1, -23, 0.5, 0),
			AutomaticSize = Enum.AutomaticSize.X,
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 0, 16),
			Parent = KeybindContainer 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 4),
			TopRightRadius = UDim.new(0, 4),
			BottomRightRadius = UDim.new(0, 4),
			BottomLeftRadius = UDim.new(0, 4),
			Parent = KeybindFrame 
		}) 
		Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = KeybindFrame 
		}) 
		local Bindingkeytext = Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextDirection = Enum.TextDirection.RightToLeft,
			TextColor3 = "DarkText",
			Name = "Bindingkeytext",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 12),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = KeybindFrame 
		}) 
		Library:Render("UIPadding", {  
			PaddingBottom = UDim.new(0, 2),
			PaddingTop = UDim.new(0, 1),
			Parent = Bindingkeytext 
		}) 
		Library:Render("ImageLabel", {  
			LayoutOrder = 1,
			Name = "KeybindIcon",
			Size = UDim2.new(0, 15, 0, 15),
			Image = "rbxassetid://127234352005171",
			BackgroundTransparency = 1,
			ImageColor3 = "Accent",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Parent = KeybindFrame 
		}) 
		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 7),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = KeybindFrame 
		}) 
		Library:Render("UIStroke", {  
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = KeybindFrame 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = KeybindFrame 
		}) 
	return KeybindContainer
	end,
	NewModeContainer = function()
		local NoclickDetector = Library:Render("TextButton", {  
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			Name = "NoclickDetector",
			AnchorPoint = Vector2.new(1, 0),
			BorderSizePixel = 0,
			Visible = false,
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 1, 10),
			Size = UDim2.new(0, 160, 0, 20),
			ZIndex = Library.ZIndex + 4,
		}) 
		local ModeContainer = Library:Render("Frame", {  
			ClipsDescendants = true,
			Selectable = true,
			Name = "ModeContainer",
			Size = UDim2.new(1, 0, 1, 0),
			SelectionGroup = true,
			ZIndex = Library.ZIndex + 5,
			BorderSizePixel = 0,
			BackgroundColor3 = "DarkContrast",
			Parent = NoclickDetector 
		}) 
		 Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1, 0),
			TopRightRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(1, 0),
			BottomLeftRadius = UDim.new(1, 0),
			Parent = ModeContainer 
		}) 
		Library:Render("UIStroke", {  
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = ModeContainer 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = ModeContainer 
		}) 
		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 1),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ModeContainer 
		}) 
		local ToggleMode = Library:Render("TextButton", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Text = "Toggle",
			AutoButtonColor = false,
			Name = "Toggle",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			ZIndex = Library.ZIndex + 5,
			TextSize = 12,
			BackgroundColor3 = "Accent",
			Parent = ModeContainer 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1, 0),
			TopRightRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(1, 0),
			BottomLeftRadius = UDim.new(1, 0),
			Parent = ToggleMode 
		}) 
		local holdMode = Library:Render("TextButton", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Text = "Hold",
			AutoButtonColor = false,
			Name = "Hold",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			ZIndex = Library.ZIndex + 5,
			TextSize = 12,
			BackgroundColor3 = "Accent",
			Parent = ModeContainer 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1, 0),
			TopRightRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(1, 0),
			BottomLeftRadius = UDim.new(1, 0),
			Parent = holdMode 
		}) 
		local Alwaysmode = Library:Render("TextButton", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Text = "Always",
			Name = "Always",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 0, 1, 0),
			ZIndex = Library.ZIndex + 5,
			TextSize = 12,
			BackgroundColor3 = "Accent",
			Parent = ModeContainer 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1, 0),
			TopRightRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(1, 0),
			BottomLeftRadius = UDim.new(1, 0),
			Parent = Alwaysmode 
		}) 
		return NoclickDetector
	end,
	NewPickerButton = function()
		local PickerButton = Library:Render("TextButton", {  
			ZIndex = Library.ZIndex,
			Name = "PickerButton",
			Size = UDim2.new(0, 18, 1, 0),
			Text = "",
			BorderSizePixel = 0,
			AutoButtonColor = false,
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 4),
			TopRightRadius = UDim.new(0, 4),
			BottomRightRadius = UDim.new(0, 4),
			BottomLeftRadius = UDim.new(0, 4),
			Parent = PickerButton 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = PickerButton 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = PickerButton 
		}) 
		return PickerButton
	end,
	NewColorpickerContainer = function()
		local ColorPickerContainer = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 15),
			BackgroundTransparency = 1,
			Name = "ColorPickerContainer",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
		}) 
		local PalletePickerContainer = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(1, 0),
			Name = "PalletePickerContainer",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 100, 1, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Parent = ColorPickerContainer 
		}) 
		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = PalletePickerContainer 
		}) 



		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			Name = "ColorpickerTitle",
			BorderSizePixel = 0,
			TextColor3 = "DarkText",
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 50, 1, 0),
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = ColorPickerContainer 
		}) 

return ColorPickerContainer
	end,
	ColorPaletteContainer = function()
		local PaletteContainer = Library:Render("Frame", {  
			Name = "PaletteContainer",
			ZIndex = Library.ZIndex,
			Position = UDim2.new(1, 20, 0, 0),
			BackgroundColor3 = "DarkContrast",
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 200, 0, 0),
		}) 
		Library:Render("UICorner", {  
			Parent = PaletteContainer 
		}) 
		 Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = PaletteContainer 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = PaletteContainer 
		}) 
		Library:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 7),
			PaddingBottom = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 10),
			Parent = PaletteContainer 
		}) 
		local Palette = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 0),
			Name = "Palette",
			ZIndex = Library.ZIndex,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 0, 22),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = PaletteContainer 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 9),
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Palette 
		}) 
		local ACtualSVCOlor = Library:Render("Frame", {  
			--LayoutOrder = 1,
			Name = "ACtualSVCOlor",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Size = UDim2.new(1, -4, 0, 100),
			Parent = Palette 
		}) 
		local SVcolorWhitetexture = Library:Render("Frame", {  
			Name = "SVcolorWhitetexture",
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			Parent = ACtualSVCOlor 
		}) 
		Library:Render("UIGradient", {  
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			},
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
			},
			Parent = SVcolorWhitetexture 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 4),
			TopRightRadius = UDim.new(0, 4),
			BottomRightRadius = UDim.new(0, 4),
			BottomLeftRadius = UDim.new(0, 4),
			Parent = SVcolorWhitetexture 
		}) 
		Library:Render("UICorner", {  
			Parent = ACtualSVCOlor 
		}) 
		local SVIndicator = Library:Render("Frame", {  
			Name = "SVIndicator",
			ZIndex = Library.ZIndex + 1,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 8, 0, 8),
			Parent = ACtualSVCOlor 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1,0),
			TopRightRadius = UDim.new(1,0),
			BottomRightRadius = UDim.new(1,0),
			BottomLeftRadius = UDim.new(1,0),
			Parent = SVIndicator 
		}) 
		Library:Render("UIStroke", {  
			Color = Color3.fromRGB(255,255,255),
			Thickness = 2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = SVIndicator 
		}) 
		local SVTextureBackground = Library:Render("TextButton", {  
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			ZIndex = Library.ZIndex,
			Name = "SVTextureBackground",
			Size = UDim2.new(1, 0, 1, 0),
			Text = "",
			BorderSizePixel = 0,
			AutoButtonColor = false,
			Parent = ACtualSVCOlor 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 4),
			TopRightRadius = UDim.new(0, 4),
			BottomRightRadius = UDim.new(0, 4),
			BottomLeftRadius = UDim.new(0, 4),
			Parent = SVTextureBackground 
		}) 
		Library:Render("UIGradient", {  
			Rotation = 270,
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0),
				NumberSequenceKeypoint.new(1, 1)
			},
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB()),
				ColorSequenceKeypoint.new(1, Color3.fromRGB())
			},
			Parent = SVTextureBackground 
		}) 
		local HueButton = Library:Render("TextButton", {  
			--LayoutOrder = 2,
			Text = "",
			AutoButtonColor = false,
			Name = "HueButton",
			ZIndex = Library.ZIndex,
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			Position = UDim2.new(0, 10, 1, -40),
			Size = UDim2.new(1, -4, 0, 8),
			BorderSizePixel = 0,
			Parent = Palette 
		}) 
		Library:Render("UIGradient", {  
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(255,0,0)),
				ColorSequenceKeypoint.new(0.17,  Color3.fromRGB(255,255,0)),
				ColorSequenceKeypoint.new(0.33,  Color3.fromRGB(0,255,0)),
				ColorSequenceKeypoint.new(0.5,  Color3.fromRGB(0,255,255)),
				ColorSequenceKeypoint.new(0.67,  Color3.fromRGB(0,0,255)),
				ColorSequenceKeypoint.new(0.83,  Color3.fromRGB(255,0,255)),
				ColorSequenceKeypoint.new(1,  Color3.fromRGB(255,0,0))
			},
			Parent = HueButton 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 6),
			TopRightRadius = UDim.new(0, 6),
			BottomRightRadius = UDim.new(0, 6),
			BottomLeftRadius = UDim.new(0, 6),
			Parent = HueButton 
		}) 
		local HIndicator = Library:Render("TextButton", {  
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0, 0.5),
			Name = "HIndicator",
			Position = UDim2.new(0, 0, 0.5, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 8, 0, 8),
			Parent = HueButton 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1,0),
			TopRightRadius = UDim.new(1,0),
			BottomRightRadius = UDim.new(1, 0),
			BottomLeftRadius = UDim.new(1,0),
			Parent = HIndicator 
		}) 
		Library:Render("UIStroke", {  
			Color = Color3.fromRGB(255,255,255),
			Thickness = 2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = HIndicator 
		}) 

		local TransparencyButton = Library:Render("TextButton", {  
		--	LayoutOrder = 3,
			Size = UDim2.new(1, -4, 0, 8),
			Name = "TransparencyButton",
			Position = UDim2.new(0, 10, 1, -20),
			Text = "",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			AutoButtonColor = false,
			Parent = Palette 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 6),
			TopRightRadius = UDim.new(0, 6),
			BottomRightRadius = UDim.new(0, 6),
			BottomLeftRadius = UDim.new(0, 6),
			Parent = TransparencyButton 
		}) 
		Library:Render("UIGradient", {  
			Name = "ActualTColor", 
		Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
			},
			Parent = TransparencyButton 
		}) 
		local TransparencyImage = Library:Render("ImageLabel", {  
			ScaleType = Enum.ScaleType.Tile,
			Image = "rbxassetid://18274452449",
			TileSize = UDim2.new(0, 6, 0, 6),
			Name = "TransparencyImage",
			ZIndex = Library.ZIndex + 1,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			Parent = TransparencyButton 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 6),
			TopRightRadius = UDim.new(0, 6),
			BottomRightRadius = UDim.new(0, 6),
			BottomLeftRadius = UDim.new(0, 6),
			Parent = TransparencyImage 
		}) 
		Library:Render("UIGradient", {  
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB()),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
			},
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.8062499761581421),
				NumberSequenceKeypoint.new(1, 0)
			},
			Parent = TransparencyImage 
		}) 
		local TIndicator = Library:Render("TextButton", {  
			Text = "",
			AutoButtonColor = false,
			AnchorPoint = Vector2.new(0, 0.5),
			Name = "TIndicator",
			Position = UDim2.new(0, 0, 0.5, 0),
			ZIndex = Library.ZIndex + 2,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 8, 0, 8),
			Parent = TransparencyButton 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1,0),
			TopRightRadius = UDim.new(1,0),
			BottomRightRadius = UDim.new(1, 0),
			BottomLeftRadius = UDim.new(1,0),
			Parent = TIndicator 
		}) 
		Library:Render("UIStroke", {  
			Color = Color3.fromRGB(255,255,255),
			Thickness = 2,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = TIndicator 
		}) 

		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Name = "PaletteTitle",
			ZIndex = Library.ZIndex,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(1, 0, 0, 12),
			BorderSizePixel = 0,
			TextSize = 12,
			Parent = PaletteContainer 
		}) 
		return PaletteContainer
	end,
	NewconfigcontrollerFrame = function()
		local ConfigControllerFrame = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			Name = "ConfigControllerFrame",
			ZIndex = Library.ZIndex,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundColor3 = "LightContrast",
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 7),
			TopRightRadius = UDim.new(0, 7),
			BottomRightRadius = UDim.new(0, 7),
			BottomLeftRadius = UDim.new(0, 7),
			Parent = ConfigControllerFrame 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = ConfigControllerFrame 
		}) 
		Library:Render("TextLabel", {  
			LayoutOrder = 2,
			TextWrapped = true,
			Name = "ConfigDescription",
			AutomaticSize = Enum.AutomaticSize.Y,
			Text = "",
			TextColor3 = "DarkText",
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(0, 11, 0, 34),
			BorderSizePixel = 0,
			RichText = true,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			ZIndex = Library.ZIndex,
			TextSize = 12,
			BackgroundColor3 = "LightText",
			Parent = ConfigControllerFrame 
		}) 
		Library:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 12),
			PaddingBottom = UDim.new(0, 14),
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = ConfigControllerFrame 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ConfigControllerFrame 
		}) 
		local ConfigcommandButtonsContainer = Library:Render("Frame", {  
			LayoutOrder = 3,
			Size = UDim2.new(1, 0, 0, 20),
			BackgroundTransparency = 1,
			Name = "ConfigcommandButtonsContainer",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			BackgroundColor3 = "LightText",
			Parent = ConfigControllerFrame 
		}) 
		Library:Render("UIListLayout", {  
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			Parent = ConfigcommandButtonsContainer 
		}) 
		Library:Render("ImageButton", {  
			Image = "rbxassetid://83581130141351",
			BackgroundTransparency = 1,
			Name = "LoadButton",
			ImageColor3 = "LoadButton",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 20, 0, 20),
			Parent = ConfigcommandButtonsContainer 
		}) 

		Library:Render("ImageButton", {  
			Image = "rbxassetid://98785971093258",
			BackgroundTransparency = 1,
			Name = "SaveButton",
			ImageColor3 = "SaveButton",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 20, 0, 20),
			Parent = ConfigcommandButtonsContainer 
		}) 
		Library:Render("ImageButton", {  
			Image = "rbxassetid://84632957702765",
			BackgroundTransparency = 1,
			Name = "DeleteButton",
			ImageColor3 = "DeleteButton",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 20, 0, 20),
			Parent = ConfigcommandButtonsContainer 
		}) 
		local ConfigTitle = Library:Render("TextLabel", {  
			LayoutOrder = 1,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "LightText",
			Text = "",
			Name = "ConfigTitle",
			Size = UDim2.new(1, 0, 0, 12),
			Position = UDim2.new(0, 11, 0, 14),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = ConfigControllerFrame 
		}) 
		local ConfigAuthor = Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			Name = "ConfigAuthor",
			Text = "",
			TextColor3 = "LightText",
			Size = UDim2.new(0, 200, 0, 12),
			AnchorPoint = Vector2.new(1, -0),
			Position = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = ConfigTitle 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = ConfigControllerFrame 
		}) 
	return ConfigControllerFrame
	end,
	NewTextContainer = function()
		local TextContainer = Library:Render("Frame", {  
			Size = UDim2.new(1, 0, 0, 12),
			Name = "TextContainer",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			AutomaticSize = Enum.AutomaticSize.Y,
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			Name = "Paragraph",
			AutomaticSize = Enum.AutomaticSize.Y,
			Size = UDim2.new(1, -18, 1, 0),
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextWrapped = true,
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = TextContainer 
		}) 
		local ExtraModuleContainer = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(1, 0),
			Name = "ExtraModuleContainer",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 12, 1, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			Parent = TextContainer 
		}) 
		Library:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Right,
			Padding = UDim.new(0, 4),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ExtraModuleContainer 
		}) 
		return TextContainer
	end,
	NewSliderContainer = function()
		local SliderContainer = Library:Render("TextButton", {  
			Size = UDim2.new(1, 0, 0, 29),
			Text = "",
			BackgroundTransparency = 1,
			Name = "SliderContainer",
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
		}) 
		local SliderBG = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(0, 1),
			Name = "SliderBG",
			Position = UDim2.new(0, 0, 1, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			BackgroundColor3 = "ModuleBackground",
			Size = UDim2.new(1, 0, 0, 8),
			Parent = SliderContainer 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 6),
			TopRightRadius = UDim.new(0, 6),
			BottomRightRadius = UDim.new(0, 6),
			BottomLeftRadius = UDim.new(0, 6),
			Parent = SliderBG 
		}) 
		Library:Render("UIStroke", {  
			Color = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SliderBG 
		}) 
		local SliderIndicator = Library:Render("Frame", {  
			Name = "SliderIndicator",
			Size = UDim2.new(0, 100, 1, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			BackgroundColor3 = "Accent",
			Parent = SliderBG 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(0, 6),
			TopRightRadius = UDim.new(0, 6),
			BottomRightRadius = UDim.new(0, 3),
			BottomLeftRadius = UDim.new(0, 3),
			Parent = SliderIndicator 
		}) 
		local Dot = Library:Render("Frame", {  
			AnchorPoint = Vector2.new(1, 0.5),
			Size = UDim2.new(0, 15, 0, 15),
			Name = "Dot",
			Position = UDim2.new(1, 0, 0.5, 0),
			ZIndex = Library.ZIndex,
			BorderSizePixel = 0,
			BackgroundColor3 = Color3.fromRGB(140,140,140),
			Parent = SliderIndicator 
		}) 
		Library:Render("UICorner", {  
			TopLeftRadius = UDim.new(1, 0),
			TopRightRadius = UDim.new(1, 0),
			BottomRightRadius = UDim.new(1, 0),
			BottomLeftRadius = UDim.new(1, 0),
			Parent = Dot 
		}) 
		Library:Render("UIGradient", {  
			Rotation = -180,
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB()),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
			},
			Parent = SliderIndicator 
		}) 
		Library:Render("UIStroke", {  
			Color = "OuterStroke",
			Parent = SliderBG 
		}) 
		Library:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			TextColor3 = "DarkText",
			Text = "SliderTitle",
			Name = "SliderTitle",
			BorderSizePixel = 0,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Size = UDim2.new(0, 100, 0, 12),
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = SliderContainer 
		}) 
		Library:Render("TextBox", {  
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			Name = "SliderValueText",
			TextColor3 = "DarkText",
			Text = "",
			AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 0, 12),
			AnchorPoint = Vector2.new(1, 0),
			Position = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			TextSize = 12,
			Parent = SliderContainer 
		}) 
return SliderContainer
	end,
}

local Tab = Library.Tabs;
local ModuleDock = Library.ModuleDock;
--> using Metatables aka Object Oriented Programming as constructors are so overpowered, if i call a function with a table index, i can Index it whatever as long as i index it with a metatable like this for example Index:Toggle <-- As long as the index is a metatables of Sections then it will work. Genius right? take notes beginners! <--
Library.__index = Library
Tab.__index = Library.Tabs
ModuleDock.__index = Library.ModuleDock

function Library:Window(Data: {any}) 
	local Data = Data or {} 
	local Window = {Title = Data.Title or Data.title,Game=Data.Game or Data.game,tabs={},SearchOpened=false}

	local NewWindow,Blur = Library.UI_Create:NewWindow()
	NewWindow.Parent =  gethui() --localPlayer:WaitForChild("PlayerGui")-- game:GetService("CoreGui")
	NewWindow["WindowHeader"]["UiTitle"].Text = Window.Title
	NewWindow["WindowHeader"]["GameTitle"].Text = Window.Game
	
	task.spawn(function() 
		NewWindow["UIScale"].Scale = camera.ViewportSize.X /  1440	

		Library:storeEvent(camera:GetPropertyChangedSignal('ViewportSize'),function()
			NewWindow["UIScale"].Scale = camera.ViewportSize.X /  1440
		end)
		
	end)

	
	local NewResultContainer = Library.UI_Create:NewResultContainer()
	NewResultContainer.Parent = NewWindow["WindowHeader"]["SearchFrame"]

	Window.Results = {}
	function Window:AddResult(Self: {string | thread}) 
		if table.find(Window.Results,Self) then 	return end --table.remove(self.Results,table.find(self.Results, Self)) end
		Window.Results[#Window.Results + 1] = Self
		local NewResultFrame = Library.UI_Create:NewResultFrame()
		NewResultFrame.Parent = NewResultContainer
		NewResultFrame.Name = Self.Title
		NewResultFrame["ModuleTitle"].Text = Self.Title
		NewResultFrame["PageInfo"].Text = Self.PageInfo or ""
		NewResultFrame["GotoButton"].MouseButton1Down:Once(function()
			NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"].Text = ""
			Library:CloseAllActives()
			self:OpenSearch(false)
			Self:DirectTo()
			NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"]["SuggestionAutoComplete"].Text = ""
			--self:ClearResults()
		end)
	end
	function Window:RemoveResult(Self: {any})
		--> YESSSSS FINALLY I FUCKING FIXED IT, I just copied and pasted the line from my combo value change
		if table.find(self.Results,Self) then table.remove(self.Results,table.find(self.Results, Self)) end
		for _, Resultframe in pairs(NewResultContainer:GetChildren()) do 
			if Resultframe.Name == Self.Title and Resultframe:IsA("Frame") then 
				Resultframe:Destroy()
			end
		end

		
	end
	function Window:ClearResults()
		table.clear(self.Results)
		for _, Resultframe in pairs(NewResultContainer:GetChildren()) do 
			if Resultframe:IsA("Frame") then 
				Resultframe:Destroy()
			end
		end
	end
	function Window:BlurEnabled(bool:boolean)
		Blur.Enabled = bool
	end

	function Window:HideHeader(bool: boolean)
		self.WindowHeaderVis = bool
		TweenService:Create(NewWindow["WindowHeader"]["HidetabbarButton"]["Arrow"], Library.TweenInfo, {Rotation =  bool and 0 or 180}):Play()
		TweenService:Create(NewWindow["WindowHeader"], Library.TweenInfo, {Size =  bool and UDim2.new(0,356,0,36) or UDim2.new(0,356,0,80)}):Play()
		TweenService:Create(NewWindow["WindowHeader"]["TabContainer"], Library.TweenInfo, {Size =  bool and UDim2.new(1,-70,0,0) or UDim2.new(1,-70,0,34)}):Play()
		NewWindow["WindowHeader"]["TabContainer"].Visible = not bool
		TweenService:Create(NewWindow["WindowHeader"]["SearchToggleButton"], Library.TweenInfo, {Size =  bool and UDim2.new(0,34,0,0) or UDim2.new(0,34,0,34)}):Play()
		TweenService:Create(NewWindow["WindowHeader"]["SearchToggleButton"]["SearchImage"], Library.TweenInfo, {Size =  bool and UDim2.new(1,12,0,0) or UDim2.new(0,12,0,12)}):Play()
	end
	
	local debounce = false
	function Window:OpenSearch(bool:boolean)
		if not debounce then 
			debounce = true

			if bool then 
				Library:CloseAllActives()
				Library.Actives[#Library.Actives + 1] = self
			end
			
			self.SearchOpened = bool
			for _,tabs in pairs(self.tabs) do 
				if tabs.Opened then 
					tabs:Open(false)
				end
			end
			NewWindow["WindowHeader"]["SearchFrame"].Visible = bool 
			TweenService:Create(NewWindow["WindowHeader"]["SearchToggleButton"]["SearchImage"], Library.TweenInfo, {ImageColor3 =  bool and Library.Theme.Active or Library.Theme.Inactive}):Play()

			task.wait(0.3)
			debounce = false
		end
	end

	--> This part down here was harder than i expected but i somehow got lucky when i used string.len lol. Update: so many bugs and i am here stuck
	Library:storeEvent(NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"]:GetPropertyChangedSignal("Text"), function(TextIndex)
		if Window.SearchOpened then 
			local TextLowered = string.lower(NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"].Text)
			
			for _,Module in ipairs(Library.Elements) do
				local start_index, end_index = string.find(string.lower(Module.Title),TextLowered)
				
				if TextLowered == "" then
					Window:ClearResults()
					NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"]["SuggestionAutoComplete"].Text = ""
				end
				
				if  Module.Dock.Identification ~= "Settings" and Module.Identification ~= "ColorpickerinsideColorpicker" and TextLowered ~= ""  then 
					if string.find(string.lower(Module.Title),string.lower(Module.Title):sub(string.len(TextLowered))) and not TextLowered:match("[^%w%s]")  and end_index == string.len(TextLowered) then
						Window:AddResult(Module)
						print(Module.Title:gsub(string.lower(Module.Title):sub(string.len(TextLowered))," "))
					if NewResultContainer:FindFirstChildWhichIsA("Frame")  then
							NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"]["SuggestionAutoComplete"].Text = Module.Title:gsub(string.sub(string.lower(Module.Title),string.len(TextLowered)  ), "") --! reminder: use string.format and remove the index letters by the search input
					end
					else 

					Window:RemoveResult(Module)


							end
						end
				end
			end
	end)
	
	Library:storeEvent(NewWindow["WindowHeader"]["SearchToggleButton"].MouseButton1Down,function()
		Window:OpenSearch(not Window.SearchOpened)

	end)
	
	Library:storeEvent(UserInputService.InputBegan,function(Input,GPE)
		if  GPE and Window.SearchOpened and  Input.KeyCode == Enum.KeyCode.Right then 
			
			NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"].Text = NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"].Text .. NewWindow["WindowHeader"]["SearchFrame"]["Inputbox"]["SuggestionAutoComplete"].Text
		end
	end)

	Library:storeEvent(NewWindow["WindowHeader"]["HidetabbarButton"].MouseButton1Down,function()
		Window:HideHeader(not Window.WindowHeaderVis)
	end)
	
	Library:MakeDraggable(NewWindow["WindowHeader"],NewWindow["WindowHeader"],function(newPos)
		NewWindow["WindowHeader"].Position = newPos
	end)
	--> Cleaning up to prevent memory leaks <--
	function Window:SelfDestruct()
		for _,connections in ipairs(Library.Connections) do 
			connections:Disconnect()
		end
		NewWindow:Destroy()
		Library = nil

	end

	Window.Container = NewWindow

	return setmetatable(Window,Library)
end

function Library:Tab(Data) 
	local Data = Data or {} 
	local Tab = {window = self,Filled=Data.Filled or Data.filled or false, Size = Data.Size or Data.size or  UDim2.new(0, 557, 0, 452), firstsubtab = true, Title = Data.Title or Data.title or "Tab", Opened = false, Image = Data.Image or Data.image or nil, subtabs = Data.Subtabs or Data.subtabs or false,}

	local NewTabFrame = Library.UI_Create:NewTabFrame()
	NewTabFrame.Parent = self.Container["WindowHeader"]["TabContainer"]
	NewTabFrame["TabImage"].Image = Tab.Image
	NewTabFrame["TabTitle"].Text = Tab.Title
	
	local newWindowPage = Library.UI_Create:NewWindowPage()
	newWindowPage.Parent = self.Container
	newWindowPage.Size = Tab.Size
	Tab.Windowpage = newWindowPage

	Library:MakeDraggable(newWindowPage,newWindowPage,function(newPos)
		newWindowPage.Position = newPos
	end)

	if Tab.subtabs then
		local NewSubPagesContainerInWindow,Subtabbar = Library.UI_Create:NewPageforSubtabsActive()
		NewSubPagesContainerInWindow.Parent = newWindowPage
		Subtabbar.Parent = newWindowPage
		Tab.Container = {NewSubPagesContainerInWindow,Subtabbar}
		NewSubPagesContainerInWindow = nil -- garbage collection 
	else
		if Tab.Filled then 
			local NewpagecontainerinsideWindow = Library.UI_Create:NewPage() 
			NewpagecontainerinsideWindow.Parent = newWindowPage
			NewpagecontainerinsideWindow["RIGHT"]:Destroy()
			Tab.Container = {LEFT = NewpagecontainerinsideWindow["LEFT"]}

			NewpagecontainerinsideWindow = nil -- garbage collection
			else
		local NewpagecontainerinsideWindow = Library.UI_Create:NewPage() 
		NewpagecontainerinsideWindow.Parent = newWindowPage
		Tab.Container = {LEFT = NewpagecontainerinsideWindow["LEFT"], RIGHT = NewpagecontainerinsideWindow["RIGHT"]}

		NewpagecontainerinsideWindow = nil -- garbage collection
		end
	end

	function Tab:Open(bool: boolean)
		if self.window.SearchOpened then self.window:OpenSearch(false) end
		newWindowPage.Visible = bool
		self.Opened = bool
		TweenService:Create(NewTabFrame, Library.TweenInfo, { BackgroundTransparency = bool and 0 or 1 }):Play() 

		TweenService:Create(NewTabFrame["TabImage"], Library.TweenInfo, {ImageColor3 = bool and Library.Theme.Active or Library.Theme.Inactive}):Play()
		Library:UpdateObject(NewTabFrame["TabImage"], "ImageColor3", bool and "Active" or "Inactive")
		TweenService:Create(NewTabFrame["TabTitle"], Library.TweenInfo, {TextColor3 = bool and Library.Theme.LightText or Library.Theme.DarkText}):Play() -- 18 = Icon size, 9 = spacing between icon 
		Library:UpdateObject(NewTabFrame["TabTitle"], "TextColor3",   bool and "LightText" or "DarkText")

	end
	function Tab:Goto()
		if not self.Opened then
			self:Open(true)
			for _,Tabs in pairs(self.window.tabs) do 
				if Tabs ~= self and Tabs.Opened then
					Tabs:Open(false)

				end
			end
		end
	end


	Library:storeEvent(NewTabFrame.MouseEnter,function()
		if not Tab.Opened then 

			TweenService:Create(NewTabFrame["TabImage"], Library.TweenInfo, {ImageColor3 =  Library.Theme.Active}):Play()
			Library:UpdateObject(NewTabFrame["TabImage"], "ImageColor3",  "Active" )
		end
	end)
	Library:storeEvent(NewTabFrame.MouseLeave,function()
		if not Tab.Opened then 

			TweenService:Create(NewTabFrame["TabImage"], Library.TweenInfo, {ImageColor3 =  Library.Theme.Inactive}):Play()
			Library:UpdateObject(NewTabFrame["TabImage"], "ImageColor3",  "Inactive" )
		end
	end)

	Library:storeEvent(NewTabFrame.MouseButton1Down,function()
		if  Tab.Opened then 
			Tab:Open(false)
		else 
			Tab:Open(true)
			for _,Tabs in pairs(self.tabs) do 
				if Tabs ~= Tab and Tabs.Opened then
					Tabs:Open(false)
				end
			end
		end
	end)

	self.tabs[#self.tabs+1] = Tab
	return setmetatable(Tab,Library.Tabs)
end

function Tab:Subtab(Data)

	if self.subtabs then   
		local Data = Data or {}
		local Subtab = {tab = self,Identification = "SubPage", window=self.window,issubtab = true,Title = Data.Title or Data.title or "Tab", Image = Data.Image or Data.image or "", }
			
		local NewSubTab = Library.UI_Create:NewSubTab()
		NewSubTab.Parent = self.Container[2]
		NewSubTab["SubtabTitle"].Text = Subtab.Title 
		NewSubTab["SubtabImage"].Image = Subtab.Image 
		local NewSubTabPage = Library.UI_Create:NewSubTabPage()
		NewSubTabPage.Parent = self.Container[1]
		NewSubTabPage.Name = Subtab.Title

		Subtab.Container = {LEFT = NewSubTabPage["LEFT"], RIGHT = NewSubTabPage["RIGHT"]}

		function Subtab:Openanimation(bool:boolean)
--[[ 
Boy oh boy, this ahs got the most stressful part of making this ui, as i was making it, i realized that words would get cut off after i added
auto scaling to my UI, than it took me 2 hours to research, experiment, and come with the final calculation. I HOPE I DONT FIND ANOTHER BUG AGAIN FROM THIS PART AND IF I DO I AM GOING TO CHANGE THE DESIGN
]]
			TweenService:Create(NewSubTab["SubtabImage"], Library.TweenInfo, {ImageColor3 = bool and Library.Theme.Accent or Library.Theme.Inactive}):Play()
			Library:UpdateObject(NewSubTab["SubtabImage"], "ImageColor3", bool and "Accent" or "Inactive")
			TweenService:Create(NewSubTab["SubtabTitle"], Library.TweenInfo, {TextColor3 = bool and Library.Theme.Accent or Library.Theme.DarkText}):Play()
			Library:UpdateObject(NewSubTab["SubtabTitle"], "TextColor3", bool and "Accent" or "DarkText")

		end

		function Subtab:Goto() -- gonna need this for search function
			
			self.tab:Goto()
			
			self.tab.Container[1]["UIPageLayout"]:JumpTo(self.tab.Container[1][self.Title])

		end

		Library:storeEvent(NewSubTab.MouseEnter,function()

			if  self.Container[1]["UIPageLayout"].CurrentPage.Name ~= Subtab.Title then 
				TweenService:Create(NewSubTab["SubtabImage"], Library.TweenInfo, {ImageColor3 = Library.Theme.Active}):Play()
				Library:UpdateObject(NewSubTab["SubtabImage"], "ImageColor3",  "Active" )
				TweenService:Create(NewSubTab["SubtabTitle"], Library.TweenInfo, {TextColor3 = Library.Theme.LightText}):Play()
				Library:UpdateObject(NewSubTab["SubtabTitle"], "TextColor3",  "LightText")

			end
		end)
		Library:storeEvent(NewSubTab.MouseLeave,function()
			if  self.Container[1]["UIPageLayout"].CurrentPage.Name ~= Subtab.Title then 

				TweenService:Create(NewSubTab["SubtabImage"], Library.TweenInfo, {ImageColor3 = Library.Theme.Inactive}):Play()
				Library:UpdateObject(NewSubTab["SubtabImage"], "ImageColor3",  "Inactive" )
				TweenService:Create(NewSubTab["SubtabTitle"], Library.TweenInfo, {TextColor3 = Library.Theme.DarkText}):Play()
				Library:UpdateObject(NewSubTab["SubtabTitle"], "TextColor3",  "Inactive")

			end
		end)

		Library:storeEvent(self.Container[1]["UIPageLayout"]:GetPropertyChangedSignal("CurrentPage"),function()
			if self.Container[1]["UIPageLayout"].CurrentPage.Name == Subtab.Title then 
				Subtab:Openanimation(true)
			else 
				Subtab:Openanimation(false)
			end
		end)


		Library:storeEvent(NewSubTab.MouseButton1Down,function()
			Subtab:Goto()
			
		end)

		Subtab.Windowpage = self.Windowpage
		return setmetatable(Subtab,Library.Tabs)
	end
end

function Tab:Section(Data) 
	local Data = Data or {}
	local Section = {page = self,WindowPage=self.Windowpage,Side = Data.Side or Data.side or "Left",Pages={}, Title = Data.Title or Data.title or "", SubSections = Data.group or Data.Group or false,Firstsectiontab = true,}
	Section.PageInfo = self.Identification == "SubPage" and string.format("%s/%s/%s",self.Title,self.page.Title,Section.Title) or string.format("%s/%s",self.Title,Section.Title)

	if Section.SubSections then
		local NewMultiSectionFrame,Pages = Library.UI_Create:NewMultiSectionFrame()
		NewMultiSectionFrame.Parent = self.Container[Section.Side:upper()]

		Section.Container = {NewMultiSectionFrame,Pages}

	else
		local NewSectionFrame = Library.UI_Create:NewSectionFrame()
		NewSectionFrame.Parent = self.Container[Section.Side:upper()]
		NewSectionFrame["SectionHeaderFrame"]["Sectiontitle"].Text = Section.Title

		Section.Container = NewSectionFrame
		
		function Section:Goto()
			Section.page:Goto()
		end
	end
	Section.Windowpage = self.Windowpage
	return setmetatable(Section,Library.ModuleDock)	
end
function ModuleDock:Section_Page(Data) 
	if self.SubSections then   
		local Data = Data or {}
		local SectionTab = {Section=self,page=self.page,Tab=self.tab,Windowpage=self.Windowpage,Title = Data.Title or Data.title or "",Opened = false,}
		SectionTab.PageInfo = `{self.PageInfo} / { SectionTab.Title}`
		
		local NewMultiSectionTab,Page = Library.UI_Create:NewMultiSectionTab()
		NewMultiSectionTab.Parent = self.Container[1]["SectionTabBar"]
		NewMultiSectionTab.Text = SectionTab.Title
		Page.Parent = self.Container[2]

		function SectionTab:Open(bool)
			self.Opened = bool
			TweenService:Create(NewMultiSectionTab, Library.TweenInfo, {TextColor3 = bool and Library.Theme.Accent or Library.Theme.DarkText}):Play()
			Library:UpdateObject(NewMultiSectionTab,"TextColor3", bool and "Accent" or "DarkText")
			TweenService:Create(NewMultiSectionTab["Indicator"], Library.TweenInfo, {BackgroundTransparency = bool and 0 or 1}):Play()
			Page.Visible = bool
		end
		function SectionTab:Goto()
			-- why can i not use self for this function?? whenver i use DirectTo function  from toggle it errors but before i changed it,  first section tab init is just fine when i used self, this is so weird if anyone is reading this and understands let me know
			if not SectionTab.page.Opened then SectionTab.page:Goto() end

			if not SectionTab.Opened then
				SectionTab:Open(true)
				for _,Tabs in pairs(SectionTab.Section.Pages) do 
					if Tabs ~= SectionTab and Tabs.Opened then
						Tabs:Open(false)

					end
				end
			end
		end
	--	if self.Firstsectiontab then 
	--		SectionTab:Goto()
		--	self.Firstsectiontab = nil 
		--end
		Library:storeEvent(NewMultiSectionTab.MouseButton1Down,function()
			if  SectionTab.Opened then 
				SectionTab:Open(false)
			else 
				SectionTab:Open(true)
				for _,Tabs in pairs(self.Pages) do 
					if Tabs ~= SectionTab and Tabs.Opened then 
						Tabs:Open(false)
					end
				end
			end
	
		end)
		self.Pages[#self.Pages + 1] = SectionTab
		SectionTab.Container = Page
		return setmetatable(SectionTab,Library.ModuleDock)	

	end
end
function ModuleDock:NewConfig(Title: string, Description:string?, Author:string?) 
	local Config = {}
	local Newconfigcontrollerframe = Library.UI_Create:NewconfigcontrollerFrame()
	Newconfigcontrollerframe.Parent = self.Container
	Newconfigcontrollerframe["ConfigTitle"].Text = Title
	Newconfigcontrollerframe["ConfigTitle"]["ConfigAuthor"].Text = Author ~= "" and Author or "Unknown"
	if Description == "" then
		Newconfigcontrollerframe["ConfigDescription"]:Destroy()
	else 
		Newconfigcontrollerframe["ConfigDescription"].Text = Description
	end
	Library:storeEvent(Newconfigcontrollerframe["ConfigcommandButtonsContainer"]["LoadButton"].MouseButton1Down,function()
		
	end)
	Library:storeEvent(Newconfigcontrollerframe["ConfigcommandButtonsContainer"]["SaveButton"].MouseButton1Down,function()

	end)
	Library:storeEvent(Newconfigcontrollerframe["ConfigcommandButtonsContainer"]["DeleteButton"].MouseButton1Down,function()

	end)
	return setmetatable(Config,Library.ModuleDock)
end
function ModuleDock:Keybind(Data)
	local Data = Data or {}
	local Keybind = {Identification = "Keybind",Opened = false,Dock=self,Title = Data.Title or Data.title or "Keybind",Mode = Data.Mode or Data.mode or "Toggle", Bind = Data.Bind or Data.bind or "Q", Value = Data.Value or Data.value or false, Callback = Data.Callback or Data.callback or function() end}
	if self.Identification ~= "Settings" then Keybind.PageInfo = self.PageInfo end
	Keybind.Flag = Data.flag or Data.Flag or Keybind.Title
	local Focused, Holding = false, false

	
	if Keybind.Mode == "Always" then 
		Keybind.Value = true 
		Keybind.Callback(true)
	end
	local modes = {"Toggle", "Hold","Always"}
	
	local NewKeybindContainer = Library.UI_Create:NewKeybindContainer()
	NewKeybindContainer["KeybindTitle"].Text = Keybind.Title
	NewKeybindContainer.Parent = self.Container
	
	local NewModeContainer = Library.UI_Create:NewModeContainer()
	NewModeContainer.Parent = NewKeybindContainer["KeybindWidget"]
		
	function Keybind:DirectTo() --> For search
		--
		if self.Dock.Identification == "Settings" then return end
		self.Dock.Goto()
		--> to catch the user attention <--
		TweenService:Create(NewKeybindContainer["KeybindTitle"], Library.TweenInfo, {TextColor3 =Library.Theme.Accent }):Play()
		Library:UpdateObject(NewKeybindContainer["KeybindTitle"],"TextColor3", "Accent" )
		task.wait(2)
		TweenService:Create(NewKeybindContainer["KeybindTitle"], Library.TweenInfo,{ TextColor3= Library.Theme.DarkText }):Play()
		Library:UpdateObject(NewKeybindContainer["KeybindTitle"],"TextColor3","DarkText" )
	end
	
	function Keybind:CheckKey(tab, key)
		for _, v in next, tab do 
			if v == key then 
				return true 
			end 
		end
	end

	function Keybind:Set(NewKey)
		Focused = false
		Keybind.Bind = NewKey
		Library.Flags[Keybind.Flag] = {["Bind"] = tostring(Keybind.Bind),["Mode"] = tostring(Keybind.Mode)}

		if not Focused then
			NewKeybindContainer["KeybindFrame"]["Bindingkeytext"].Text = Library.short_keybind_names[tostring(Keybind.Bind)]  or tostring(Keybind.Bind):upper()
		end
	end
	local debounce = false
	function Keybind:Open(bool:boolean)
		if not debounce then 
			if bool then 
				Library:CloseAllActives()
				Library.Actives[#Library.Actives] = Keybind
			end
			self.Opened = bool
			TweenService:Create(NewKeybindContainer["KeybindWidget"],Library.TweenInfo,{ImageColor3 =self.Opened and Library.Theme.Active or Library.Theme.Inactive}):Play()
			Library:UpdateObject(NewKeybindContainer["KeybindWidget"],"ImageColor3",self.Opened and "Active" or "Inactive")
			NewModeContainer.Visible = self.Opened
		end
	end

	function Keybind:SetMode(NewMode:string)
		self.Mode = NewMode
		Library.Flags[Keybind.Flag] = {["Bind"] = tostring(Keybind.Bind),["Mode"] = tostring(Keybind.Mode)}

		for _,Mode in pairs(NewModeContainer["ModeContainer"]:GetChildren()) do
			if Mode.Name == NewMode and Mode:IsA("TextButton") then 
				TweenService:Create(Mode,Library.TweenInfo,{BackgroundTransparency = 0}):Play()
			elseif Mode.Name ~= NewMode and Mode:IsA("TextButton") then
				TweenService:Create(Mode,Library.TweenInfo,{BackgroundTransparency = 1}):Play()

			end
		end
	end
	Keybind:Set(Keybind.Bind)
	Keybind:SetMode(Keybind.Mode)

	Library:storeEvent(UserInputService.InputBegan, function(Input) 
		if (Input.KeyCode.Name == Keybind.Bind or Input.UserInputType.Name == Keybind.Bind) and not Focused then
			if Keybind.Mode == "Always" then
				Keybind.Value = true
				Keybind.Callback(Keybind.Value)
			end
			if  Keybind.Mode == "Hold" then
				Holding = true
				Keybind.Value = Holding
				Keybind.Callback(Keybind.Value)
			elseif not Focused and Keybind.Mode == "Toggle" then
				Keybind.Value = not Keybind.Value
				Keybind.Callback(Keybind.Value)
			end
		elseif Focused then
			local key
			pcall(function()
				if not Keybind:CheckKey(Library.BlacklistedKeys, Input.KeyCode) then
					key = Input.KeyCode
					NewKeybindContainer["KeybindFrame"]["KeybindIcon"].Image = "rbxassetid://127234352005171"

				end
				if Keybind:CheckKey(Library.WhitelistedMouse, Input.UserInputType)  then
					key = Input.UserInputType
					NewKeybindContainer["KeybindFrame"]["KeybindIcon"].Image = "rbxassetid://138543267637348"
				end
			end)

			Keybind:Set(key.Name or Keybind.Bind)
		end
	end)
	Library:storeEvent(UserInputService.InputEnded, function(Input)
		if Input.KeyCode.Name == Keybind.Bind or Input.UserInputType.Name ==Keybind.Bind then
			if Keybind.Mode == "Hold" and Holding then
				Holding = false
				Keybind.Value = Holding
				Keybind.Callback(Holding)
			end
		end
	end)
	
	Library:storeEvent(NewKeybindContainer["KeybindFrame"].MouseButton1Click, function()
		if Focused ~= true then
			Focused = true
			NewKeybindContainer["KeybindFrame"]["Bindingkeytext"].Text = "..."

		end
	end)
	Library:storeEvent(NewKeybindContainer["KeybindWidget"].MouseButton1Click, function()
		Keybind:Open(not Keybind.Opened)
	end)
	Library:storeEvent(	NewModeContainer["ModeContainer"]["Toggle"].MouseButton1Click, function()
		Keybind:SetMode("Toggle")
	end)
	Library:storeEvent(	NewModeContainer["ModeContainer"]["Hold"].MouseButton1Click, function()
		Keybind:SetMode("Hold")
	end)
	Library:storeEvent(	NewModeContainer["ModeContainer"]["Always"].MouseButton1Click, function()
		Keybind:SetMode("Always")
	end)
	
	Library.Elements[#Library.Elements + 1] = Keybind

	return setmetatable(Keybind,Library.ModuleDock)
end
function ModuleDock:Dropdown(Data)
	local Data = Data or {}
	local Dropdown = {Dock = self,Opened = false,Combo = Data.Combo or Data.combo or false, Title = Data.Title or Data.title or "Dropdown", Value = Data.Value or Data.value or "" ,Options = Data.Options or Data.options or {"1","2"},Callback=Data.Callback or Data.callback or function() end }
	Dropdown.Flag = Data.flag or Data.Flag or Dropdown.Title
	if self.Identification ~= "Settings" then Dropdown.PageInfo = self.PageInfo end
	local NewDropdown = Library.UI_Create:NewDropdown()
	NewDropdown.Parent = self.Container
	NewDropdown["DropdownTitle"].Text = Dropdown.Title

	function Dropdown:Set(Value: string)
		
		if self.Combo then 
			if table.find(self.Value,Value) then 
				table.remove(self.Value,table.find(self.Value, Value))
			elseif not table.find(self.Value,Value) then
				self.Value[#self.Value + 1] = Value
			end
			NewDropdown["DropdownBox"]["DropdownSelected"].Text =  table.concat(self.Value, ", ")
			Library.Flags[self.Flag] = self.Value

		elseif not self.Combo then
			Library.Flags[self.Flag] = self.Value

			self.Value = Value
			NewDropdown["DropdownBox"]["DropdownSelected"].Text =  tostring(self.Value)
		end 
		
		for _,Option in pairs(NewDropdown["DropdownBox"]["NoClickDetector"]["OptionContainer"]:GetChildren()) do 
			if self.Combo then 
				if  Option.Name == Value and  table.find(self.Value,Option.Name) and Option:IsA("TextButton") then 
					TweenService:Create(Option["OptionText"], Library.TweenInfo, {TextColor3 = Library.Theme.Accent, Size = UDim2.new(1,-8,1,0)}):Play()
					TweenService:Create(Option["Indicator"], Library.TweenInfo, {Size = UDim2.new(0,3,1,0)}):Play()
					Library:UpdateObject(Option["OptionText"],"TextColor3","Accent")
				elseif  Option.Name == Value and not table.find(self.Value,Option.Name) and Option:IsA("TextButton") then
					TweenService:Create(Option["OptionText"], Library.TweenInfo, {TextColor3 = Library.Theme.DarkText, Size = UDim2.new(1,0,1,0)}):Play()
					TweenService:Create(Option["Indicator"], Library.TweenInfo, {Size = UDim2.new(0,0,1,0)}):Play()
					Library:UpdateObject(Option["OptionText"],"TextColor3","DarkText")
				end
			else
				if  Option.Name == Value  and Option:IsA("TextButton") then 
					TweenService:Create(Option["OptionText"], Library.TweenInfo, {TextColor3 = Library.Theme.Accent, Size = UDim2.new(1,-8,1,0)}):Play()
					TweenService:Create(Option["Indicator"], Library.TweenInfo, {Size = UDim2.new(0,3,1,0)}):Play()
					Library:UpdateObject(Option["OptionText"],"TextColor3","Accent")
					print(`{Option.name} " "  {Library.InstanceStorage[Option["OptionText"]]["TextColor3"]}`)
				elseif  Option.Name ~= Value  and Option:IsA("TextButton") then
					
					TweenService:Create(Option["OptionText"], Library.TweenInfo, {TextColor3 = Library.Theme.DarkText, Size = UDim2.new(1,0,1,0)}):Play()
					TweenService:Create(Option["Indicator"], Library.TweenInfo, {Size = UDim2.new(0,0,1,0)}):Play()
					Library:UpdateObject(Option["OptionText"],"TextColor3","DarkText")
					print(`{Option.Name} " "  {Library.InstanceStorage[Option["OptionText"]]["TextColor3"]}`)

				end			
			end
		end
		self.Callback(self.Value)
		
	end

	function Dropdown:NewOptions(Options: {string})
		for _,NewOptions in pairs(Options) do 
			if typeof(NewOptions) == "string" then 

				local NewOption = Library.UI_Create:NewOption()
				NewOption.Name = NewOptions
				NewOption.Parent = NewDropdown["DropdownBox"]["NoClickDetector"]["OptionContainer"]
				NewOption["OptionText"].Text = NewOptions

				Library:storeEvent(NewOption.MouseButton1Down,function()
					Dropdown:Set(NewOption.Name)
				end)
			end
		end
	end

	function Dropdown:DirectTo() --> For search
		--
		if self.Dock.Identification == "Settings" then return end
		self.Dock.Goto()
		--> to catch the user attention <--
		TweenService:Create(NewDropdown["DropdownTitle"], Library.TweenInfo, {TextColor3 =Library.Theme.Accent }):Play()
		Library:UpdateObject(NewDropdown["DropdownTitle"],"TextColor3", "Accent" )
		task.wait(2)
		TweenService:Create(NewDropdown["DropdownTitle"], Library.TweenInfo, {TextColor3 = Dropdown.Opened and Library.Theme.LightText or Library.Theme.DarkText }):Play()
		Library:UpdateObject(NewDropdown["DropdownTitle"],"TextColor3",Dropdown.Opened and "LightText" or "DarkText" )
	end

	local debounce = false
	function Dropdown:Open(bool:boolean)
		if not debounce then 
			debounce = true 
			if bool then 
				Library:CloseAllActives()
				Library.Actives[#Library.Actives +1] = self
			end
			self.Opened = bool
			NewDropdown["DropdownBox"].ZIndex = bool and Library.ZIndex + 3 or Library.ZIndex
			NewDropdown["DropdownBox"]["DropdownSelected"].ZIndex = bool and Library.ZIndex + 3 or Library.ZIndex
			NewDropdown["DropdownBox"]["Dropdownarrow"].ZIndex = bool and Library.ZIndex + 3 or Library.ZIndex

			TweenService:Create(NewDropdown["DropdownBox"], Library.TweenInfo, {Size = bool and UDim2.new(1,0,0,23+80) or UDim2.new(1,0,0,23)}):Play()
			
			TweenService:Create(NewDropdown["DropdownBox"]["NoClickDetector"]["OptionContainer"], Library.TweenInfo, {Size = bool and UDim2.new(1,0,1,0) or UDim2.new(1,0,0,0)}):Play()

			TweenService:Create(NewDropdown["DropdownBox"]["Dropdownarrow"], Library.TweenInfo, {Rotation = bool and 180 or 0,ImageColor3 = bool and Library.Theme.Active or Library.Theme.Inactive}):Play()
			Library:UpdateObject(NewDropdown["DropdownBox"]["Dropdownarrow"],"ImageColor3",  bool and "Active" or "Inactive")
			TweenService:Create(NewDropdown["DropdownBox"]["DropdownSelected"], Library.TweenInfo, {TextColor3 = bool and Library.Theme.LightText or Library.Theme.DarkText}):Play()
			Library:UpdateObject(NewDropdown["DropdownBox"]["DropdownSelected"],"TextColor3", bool and"LightText" or "DarkText")
			TweenService:Create(NewDropdown["DropdownTitle"], Library.TweenInfo, {TextColor3 = bool and Library.Theme.LightText or Library.Theme.DarkText}):Play()
			Library:UpdateObject(NewDropdown["DropdownTitle"],"TextColor3", bool and "LightText" or "DarkText")
			NewDropdown["DropdownBox"]["NoClickDetector"].Visible = bool


			task.wait(0.4)
			debounce= false
		end
	end
	Library:storeEvent(NewDropdown.MouseButton1Down,function()
		Dropdown:Open(not Dropdown.Opened)
	end)
	Library:storeEvent(UserInputService.InputBegan,function(Input)
		if Dropdown.Opened and (Input.UserInputType == Enum.UserInputType.Touch or  Input.UserInputType == Enum.UserInputType.MouseButton1) then
			if not Library:IsHovered(NewDropdown["DropdownBox"]) then 
				Dropdown:Open(false)
			end
		end
	end)
	Dropdown:NewOptions(Dropdown.Options)

	if Dropdown.Combo and Dropdown.Value == "" then 
		Dropdown.Value = {}
		Dropdown:Set(Dropdown.Options[1])
	elseif Dropdown.Combo and Dropdown.Value ~= "" then  
		Dropdown:Set(Dropdown.Value)
	end
	if  not Dropdown.Combo and Dropdown.Value == "" then
		Dropdown:Set(Dropdown.Options[1])
	elseif not Dropdown.Combo and Dropdown.Value ~= "" then
		Dropdown:Set(Dropdown.Value)
	end
	Library.Elements[#Library.Elements + 1] = Dropdown
	return setmetatable(Dropdown,Library.ModuleDock)
end
function ModuleDock:Toggle(Data) 
	local Data = Data or {}
	local Toggle = {Identification = "Toggle",Dock = self,Title = Data.Title or Data.title or "", Value = Data.Value or Data.value or false, Callback = Data.Callback or Data.callback or function()end}
	Toggle.Flag = Data.Flag or Data.flag or Toggle.Title
	
	if self.Identification ~= "Settings" then Toggle.PageInfo = self.PageInfo end

	local NewToggle = Library.UI_Create:NewToggle()
	NewToggle.Parent = self.Container
	NewToggle["ToggleTitle"].Text = Toggle.Title

	function Toggle:DirectTo() --> For search
		
		if self.Dock.Identification == "Settings" then return end
		self.Dock.Goto()
		--> to catch the user attention <--
		TweenService:Create(NewToggle["ToggleTitle"], Library.TweenInfo, {TextColor3 =Library.Theme.Accent }):Play()
		Library:UpdateObject(NewToggle["ToggleTitle"],"TextColor3", "Accent" )
		task.wait(2)
		TweenService:Create(NewToggle["ToggleTitle"], Library.TweenInfo, {TextColor3 = Toggle.Value and Library.Theme.LightText or Library.Theme.DarkText }):Play()
		Library:UpdateObject(NewToggle["ToggleTitle"],"TextColor3",Toggle.Value and "LightText" or "DarkText" )
	end

	function Toggle:Set(NewValue:boolean)
		self.Value = NewValue 
		self.Callback(NewValue) 
		TweenService:Create(NewToggle["ToggleTitle"], Library.TweenInfo, {TextColor3 = NewValue and Library.Theme.LightText or Library.Theme.DarkText}):Play()
		Library:UpdateObject(NewToggle["ToggleTitle"],"TextColor3", NewValue and "LightText" or "DarkText")
		TweenService:Create(NewToggle["Checkbox"], Library.TweenInfo, {BackgroundColor3 = NewValue and Library.Theme.Accent or Library.Theme.DarkContrast}):Play()
		Library:UpdateObject(NewToggle["Checkbox"],"BackgroundColor3", NewValue and "Accent" or "DarkContrast")
		TweenService:Create(NewToggle["Checkbox"]["Checkmark"], Library.TweenInfo, {Size = NewValue and UDim2.new(0,15,0,15) or UDim2.new(0,0,0,0)}):Play()
		Library.Flags[Toggle.Flag] = self.Value
	end

	Library:storeEvent(NewToggle.MouseButton1Down,function()
		Toggle:Set(not Toggle.Value)
	end)
	Toggle:Set(Toggle.Value)

	Toggle.Container = {NewToggle["ToggleExtraModuletContainer"],Toggle.Dock.Windowpage}
	Library.Elements[#Library.Elements + 1] = Toggle
	return setmetatable(Toggle,Library.ModuleDock)
end

function ModuleDock:Settings()
	local Settings = {Opened = false,Identification="Settings"}
	local ToggleButton,AntiClick = Library.UI_Create:NewWidgetContainer()

	ToggleButton.Parent = self.Container[1]
	AntiClick.Parent = self.Container[2]

	local debounce = false --> to prevent settings closing when you click on it because the Auto close when not hover will just auto close when settings is clicked, it so i put a cooldown
	function Settings:Open(bool:boolean)
		if not  debounce then   
			debounce = true 

			if bool then 
				Library:CloseAllActives()
				Library.Actives[#Library.Actives +1] = self
			end
			AntiClick.Visible = bool
			Settings.Opened = bool 

			TweenService:Create(AntiClick, Library.TweenInfo, {Size = bool and UDim2.new(0,200,0,200) or UDim2.new(0,0,0,0)}):Play()
			TweenService:Create(ToggleButton, Library.TweenInfo, {ImageColor3 = bool and Library.Theme.Active or Library.Theme.Inactive}):Play()
			Library:UpdateObject(ToggleButton,"ImageColor3", bool and "Active" or "Inactive")
			task.wait(0.4)
			debounce = false 
		end
	end

	Library:storeEvent(UserInputService.InputBegan,function(Input)
		if Settings.Opened and (Input.UserInputType == Enum.UserInputType.Touch or  Input.UserInputType == Enum.UserInputType.MouseButton1) then
			if not Library:IsHovered(AntiClick["ModulesContainer"]) then 
				Settings:Open(false)
			end
		end
	end)

	Library:storeEvent(ToggleButton.MouseButton1Down,function()
		Settings:Open(not Settings.Opened)
	end)

	Settings.Container = AntiClick["ModulesContainer"]
	return setmetatable(Settings,Library.ModuleDock)
end
function ModuleDock:Slider(Data)
	local Data = Data or {}
	local Slider = {Title = Data.Title or Data.title or "",Flag = Data.Flag or Data.flag or false, Unit = Data.Unit or Data.unit or "", Increment = Data.Increment or Data.increment or 1, Value = Data.value or Data.Value or 0, Min = Data.Minimum or Data.minimum or 0, Max = Data.Maximum or Data.maximum or 10,Callback = Data.callback or Data.Callback or function() end}
	Slider.Increment = 1 / Slider.Increment
	local NewSliderContainer = Library.UI_Create:NewSliderContainer()
	NewSliderContainer["SliderTitle"].Text = Slider.Title
	NewSliderContainer.Parent = self.Container
	
	function Slider:Set(Value: number)
		self.value = Value
		NewSliderContainer["SliderValueText"].Text = tostring(Value) .. self.Unit
		local Value = (((Value - self.Min) * (self.Max - self.Min)) / (self.Max - self.Min)) + self.Min 
		local percent = 1 - (self.Max - Value) / (self.Max- self.Min)
		TweenService:Create(NewSliderContainer["SliderBG"]["SliderIndicator"], Library.TweenInfo, {Size = UDim2.new(percent, 0, 1, 0)}):Play()
		self.Callback(Value)
	end
	
	local function Update()
		local MouseBound = math.clamp(Mouse.X - NewSliderContainer["SliderBG"]["SliderIndicator"].AbsolutePosition.X, 0, NewSliderContainer["SliderBG"].AbsoluteSize.X) / NewSliderContainer["SliderBG"].AbsoluteSize.X
		local Svalue = math.floor((Slider.Min + (Slider.Max - Slider.Min) * MouseBound) * Slider.Increment) / Slider.Increment
		Svalue = math.clamp(Svalue, Slider.Min, Slider.Max)
		Slider:Set(Svalue)
	end
	local Pressing
	Library:storeEvent(NewSliderContainer.MouseButton1Down,function()
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
			Update()			
		end
	end)
	Library:storeEvent(NewSliderContainer["SliderValueText"].FocusLost,function()
		if type(tonumber(NewSliderContainer["SliderValueText"].Text)) == "number" and tonumber(NewSliderContainer["SliderValueText"].Text) <= Slider.Max and tonumber(NewSliderContainer["SliderValueText"].Text) >= Slider.Min then 
			Slider:Set(math.clamp(tonumber(NewSliderContainer["SliderValueText"].Text),Slider.Min,Slider.Max)) 
		else 
			Slider:Set(Slider.Value)
		end
	end)
	
	if Slider.Value >= Slider.Min and  Slider.Value <= Slider.Max then 

		Slider:Set(Slider.Value)
	else 
		Slider:Set(Slider.Min)
	end 
	
	return setmetatable(Slider,Library.ModuleDock)
end
function ModuleDock:Text(Data)
	local Data = Data or {}
	local Text = {Text = Data.Text or Data.text or "", ExtraModuleContainer = Data.AddModules or false}
	
	local NewTextcontainer = Library.UI_Create:NewTextContainer()
	NewTextcontainer.Parent = self.Container
	
	if not Text.ExtraModuleContainer then 
		NewTextcontainer["ExtraModuleContainer"]:Destroy()
		NewTextcontainer["Paragraph"].Size = UDim2.new(1,0,1,0)
	end
	
	function Text:UpdateText(newText:string) 
		self.Text = newText
		NewTextcontainer["Paragraph"].Text = self.Text
	end
	Text.Container =  {NewTextcontainer["ExtraModuleContainer"],self.Windowpage}

	Text:UpdateText(Text.Text)
	return setmetatable(Text,Library.ModuleDock)
end
function ModuleDock:Colorpicker(Data)
	local Data = Data or {}
	local Colorpicker = {Identification = "Colorpicker",PaletteTitle = Data.PaletteTitle or Data.palettetitle or "",Dock = self,Opened = false, Title = Data.Title or Data.title or "", Color = Data.Color or Data.color or Color3.fromHSV(0,0,0), transparency = Data.Transparency or Data.transparency or 0, Container = nil,Colors = {Hue = 0, Saturation = 0, Brightness = 0,Transparency = 0}, Callback = Data.Callback or Data.callback or function() end }
	if self.Identification ~= "Settings" then Colorpicker.PageInfo = self.PageInfo end
	
	Colorpicker.Flag = Data.flag or Data.Flag  or Colorpicker.Title
	
	local NewColorpickerContainer = Library.UI_Create:NewColorpickerContainer()
	NewColorpickerContainer.Parent = self.Container
	NewColorpickerContainer["ColorpickerTitle"].Text = Colorpicker.Title
	
	local NewPickerButton = Library.UI_Create:NewPickerButton()
	NewPickerButton.Parent = NewColorpickerContainer["PalletePickerContainer"]
	Colorpicker.Container =  {NewColorpickerContainer["PalletePickerContainer"],self.Windowpage}
	local ColorPaletteContainer = Library.UI_Create:ColorPaletteContainer()
	ColorPaletteContainer.Visible = false
	ColorPaletteContainer.Parent = self.Windowpage
	ColorPaletteContainer["PaletteTitle"].Text = Colorpicker.PaletteTitle == "" and Colorpicker.Title or Colorpicker.PaletteTitle
	

	local debounce = false
	function Colorpicker:DirectTo()
			if self.Dock.Identification == "Settings" then return end
			self.Dock.Goto()
			--> to catch the user attention <--
		TweenService:Create(NewColorpickerContainer["ColorpickerTitle"], Library.TweenInfo, {TextColor3 =Library.Theme.Accent }):Play()
		Library:UpdateObject(NewColorpickerContainer["ColorpickerTitle"],"TextColor3", "Accent" )
			task.wait(2)
		TweenService:Create(NewColorpickerContainer["ColorpickerTitle"], Library.TweenInfo, {TextColor3 = Colorpicker.Opened and Library.Theme.LightText or Library.Theme.DarkText }):Play()
		Library:UpdateObject(NewColorpickerContainer["ColorpickerTitle"],"TextColor3",Colorpicker.Opened and w"LightText" or "DarkText" )
	end
	function Colorpicker:Open(bool:boolean)
		if not debounce then 
			debounce = true
			if bool then 
				Library:CloseAllActives()
				Library.Actives[#Library.Actives + 1] = self
			end
			self.Opened = bool
			TweenService:Create(NewColorpickerContainer["ColorpickerTitle"], Library.TweenInfo, {TextColor3 = self.Opened and Library.Theme.LightText or Library.Theme.DarkText }):Play()
			Library:UpdateObject(NewColorpickerContainer["ColorpickerTitle"],"TextColor3",self.Opened and "LightText" or "DarkText" )
			
			ColorPaletteContainer.Visible = bool

			task.wait(0.2)
			debounce = false
		end
	end
	function Colorpicker:Set(color: Color3, Transparency: number?)
		local H,S,V = color:ToHSV()
		self.Colors.Hue,self.Colors.Saturation,self.Colors.Brightness,self.Colors.Transparency = H,S,V,Transparency ~= nil  and Transparency or  self.Colors.Transparency 

		self.Color = Color3.fromHSV(H,S,V)
		self.transparency = self.Colors.Transparency 
		
		ColorPaletteContainer["Palette"]["TransparencyButton"]["ActualTColor"].Color =ColorSequence.new{ColorSequenceKeypoint.new(0,  Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)),ColorSequenceKeypoint.new(1,Color3.fromRGB(122,122,122))}
		ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].Position =UDim2.new(Colorpicker.Colors.Transparency,0,0.5,0)
		ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundColor3 =Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
		ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundTransparency = self.transparency 
		ColorPaletteContainer["Palette"]["HueButton"]["HIndicator"].Position =UDim2.new(Colorpicker.Colors.Hue,0,0.5,0)
		ColorPaletteContainer["Palette"]["HueButton"]["HIndicator"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,1,1)

		ColorPaletteContainer["Palette"]["ACtualSVCOlor"]["SVIndicator"].Position =UDim2.new(Colorpicker.Colors.Saturation,0,1 -Colorpicker.Colors.Brightness,0)
		ColorPaletteContainer["Palette"]["ACtualSVCOlor"]["SVIndicator"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
		ColorPaletteContainer["Palette"]["ACtualSVCOlor"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,1,1)

		NewPickerButton.BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
		
		Library.Flags[self.Flag] = self.Colors

		Colorpicker.Callback(NewPickerButton.BackgroundColor3,ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundTransparency)		
	end
	local function UpdateColorpicker()
		Colorpicker.Color = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].Transparency)
		Colorpicker.transparency = Colorpicker.Colors.Transparency
			
		ColorPaletteContainer["Palette"]["TransparencyButton"]["ActualTColor"].Color =ColorSequence.new{ColorSequenceKeypoint.new(0,  Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)),ColorSequenceKeypoint.new(1,Color3.fromRGB(122,122,122))}
		ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].Position =UDim2.new(Colorpicker.Colors.Transparency,0,0.5,0)
		ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundColor3 =Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
		ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundTransparency =Colorpicker.Colors.Transparency
		
		ColorPaletteContainer["Palette"]["HueButton"]["HIndicator"].Position =UDim2.new(Colorpicker.Colors.Hue,0,0.5,0)
		ColorPaletteContainer["Palette"]["HueButton"]["HIndicator"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,1,1)
		
		ColorPaletteContainer["Palette"]["ACtualSVCOlor"]["SVIndicator"].Position =UDim2.new(Colorpicker.Colors.Saturation,0,1 -Colorpicker.Colors.Brightness,0)
		ColorPaletteContainer["Palette"]["ACtualSVCOlor"]["SVIndicator"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
		ColorPaletteContainer["Palette"]["ACtualSVCOlor"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,1,1)
		
		NewPickerButton.BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
		Library.Flags[Colorpicker.Flag] = Colorpicker.Colors

		Colorpicker.Callback(NewPickerButton.BackgroundColor3,ColorPaletteContainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundTransparency)
	end
	local function UpdateHue()
		local MouseOnHuePallete = math.clamp(Mouse.X - ColorPaletteContainer["Palette"]["HueButton"].AbsolutePosition.X,0,ColorPaletteContainer["Palette"]["HueButton"].AbsoluteSize.X) / ColorPaletteContainer["Palette"]["HueButton"].AbsoluteSize.X

		Colorpicker.Colors.Hue = MouseOnHuePallete
		UpdateColorpicker()
	end
	local function UpdateSV()
		local MouseOnSaturationPallete = math.clamp(Mouse.X - ColorPaletteContainer["Palette"]["ACtualSVCOlor"].AbsolutePosition.X,0,ColorPaletteContainer["Palette"]["ACtualSVCOlor"].AbsoluteSize.X) / ColorPaletteContainer["Palette"]["ACtualSVCOlor"].AbsoluteSize.X
		local MouseOnBrightnessPallete =  math.clamp(Mouse.Y - ColorPaletteContainer["Palette"]["ACtualSVCOlor"].AbsolutePosition.Y,0,ColorPaletteContainer["Palette"]["ACtualSVCOlor"].AbsoluteSize.Y) / ColorPaletteContainer["Palette"]["ACtualSVCOlor"].AbsoluteSize.Y

		Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness = MouseOnSaturationPallete, 1 - MouseOnBrightnessPallete
		UpdateColorpicker()
	end

	local function UpdateTransparency()
		local MouseOntransparencyBar = math.clamp(Mouse.X - ColorPaletteContainer["Palette"]["TransparencyButton"].AbsolutePosition.X,0,ColorPaletteContainer["Palette"]["TransparencyButton"].AbsoluteSize.X) / ColorPaletteContainer["Palette"]["TransparencyButton"].AbsoluteSize.X

		Colorpicker.Colors.Transparency = MouseOntransparencyBar
		UpdateColorpicker()
	end
	Library:storeEvent(UserInputService.InputBegan,function(Input)
		if Colorpicker.Opened and (Input.UserInputType == Enum.UserInputType.Touch or  Input.UserInputType == Enum.UserInputType.MouseButton1) then
			if not Library:IsHovered(ColorPaletteContainer) then 
				Colorpicker:Open(false)
			end
		end
	end)
	Library:storeEvent(NewPickerButton.MouseButton1Down,function()
			Colorpicker:Open(not Colorpicker.Opened)
			
	end)
	Library:storeEvent(ColorPaletteContainer["Palette"]["HueButton"].MouseButton1Down,function()
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
			UpdateHue()
		end
	end)
	Library:storeEvent(ColorPaletteContainer["Palette"]["ACtualSVCOlor"]["SVTextureBackground"].MouseButton1Down,function()
		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
			UpdateSV()
		end
		end)
		Library:storeEvent(ColorPaletteContainer["Palette"]["TransparencyButton"].MouseButton1Down,function()
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
				UpdateTransparency()
			end
	end)
	local ColorPalette = {Container = ColorPaletteContainer["Palette"],Identification = "Palette"}
	ColorPalette = setmetatable(ColorPalette,Library.ModuleDock)
	ColorPalette:Button({Title = "Use Accent",Callback = function()
	Colorpicker:Set(Library.Theme.Accent)
	end,})
	Colorpicker:Set(Colorpicker.Color,Colorpicker.transparency)
	Library.Elements[#Library.Elements + 1] = Colorpicker
	function Colorpicker:Colorpicker(Data)
		local Data = Data or {}
		local Colorpicker = {Identification = "ColorpickerinsideColorpicker",Dock=self,Opened = false,Title = Data.Title or Data.title or "", Color = Data.Color or Data.color or Color3.fromHSV(0,0,0), transparency = Data.Transparency or Data.transparency or 0, Colors = {Hue = 0, Saturation = 0, Brightness = 0,Transparency = 0}, Callback = Data.Callback or Data.callback or function() end }
		
		Colorpicker.Flag = Data.flag or Data.Flag  or Colorpicker.Title

		local NewPickerButtonInsideColorpicker = Library.UI_Create:NewPickerButton()
		NewPickerButtonInsideColorpicker.Parent = NewColorpickerContainer["PalletePickerContainer"]

		local NewColorpaletteinsidecolorcontainer = Library.UI_Create:ColorPaletteContainer()
		NewColorpaletteinsidecolorcontainer.Visible = false
		NewColorpaletteinsidecolorcontainer.Parent = self.Dock.Windowpage
		NewColorpaletteinsidecolorcontainer["PaletteTitle"].Text = Colorpicker.Title

		local debounce = false
		function Colorpicker:Open(bool:boolean)
			if not debounce then 
				debounce = true
				if bool then 
					Library:CloseAllActives()
					Library.Actives[#Library.Actives + 1] = self
				end
				self.Opened = bool
				NewColorpaletteinsidecolorcontainer.Visible = bool
				TweenService:Create(NewColorpickerContainer["ColorpickerTitle"], Library.TweenInfo, {TextColor3 = self.Opened and Library.Theme.LightText or Library.Theme.DarkText }):Play()
				Library:UpdateObject(NewColorpickerContainer["ColorpickerTitle"],"TextColor3",self.Opened and "LightText" or "DarkText" )

				task.wait(0.2)
				debounce = false
			end
		end
		function Colorpicker:Set(color: Color3, Transparency: number?)
			local H,S,V = color:ToHSV()
			self.Colors.Hue,self.Colors.Saturation,self.Colors.Brightness,self.Colors.Transparency = H,S,V,Transparency == nil  and self.Colors.Transparency or Transparency

			self.Color = Color3.fromHSV(H,S,V)
			self.transparency = self.Colors.Transparency 

			NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["ActualTColor"].Color =ColorSequence.new{ColorSequenceKeypoint.new(0,  Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)),ColorSequenceKeypoint.new(1,Color3.fromRGB(122,122,122))}
			NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].Position =UDim2.new(Colorpicker.Colors.Transparency,0,0.5,0)
			NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundColor3 =Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
			if Transparency ~= nil then 
			NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundTransparency =Colorpicker.Colors.Transparency
end
			NewColorpaletteinsidecolorcontainer["Palette"]["HueButton"]["HIndicator"].Position =UDim2.new(Colorpicker.Colors.Hue,0,0.5,0)
			NewColorpaletteinsidecolorcontainer["Palette"]["HueButton"]["HIndicator"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,1,1)

			NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"]["SVIndicator"].Position =UDim2.new(Colorpicker.Colors.Saturation,0,1 -Colorpicker.Colors.Brightness,0)
			NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"]["SVIndicator"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
			NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,1,1)

			NewPickerButtonInsideColorpicker.BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
			Library.Flags[Colorpicker.Flag] = self.Colors

			Colorpicker.Callback(NewPickerButtonInsideColorpicker.BackgroundColor3,NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundTransparency)		
		end
		local function UpdateColorpicker()
			Colorpicker.Color = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].Transparency)
			Colorpicker.transparency = Colorpicker.Colors.Transparency

			NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["ActualTColor"].Color =ColorSequence.new{ColorSequenceKeypoint.new(0,  Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)),ColorSequenceKeypoint.new(1,Color3.fromRGB(122,122,122))}
			NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].Position =UDim2.new(Colorpicker.Colors.Transparency,0,0.5,0)
			NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundColor3 =Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
			NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundTransparency =Colorpicker.Colors.Transparency

			NewColorpaletteinsidecolorcontainer["Palette"]["HueButton"]["HIndicator"].Position =UDim2.new(Colorpicker.Colors.Hue,0,0.5,0)
			NewColorpaletteinsidecolorcontainer["Palette"]["HueButton"]["HIndicator"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,1,1)

			NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"]["SVIndicator"].Position =UDim2.new(Colorpicker.Colors.Saturation,0,1 -Colorpicker.Colors.Brightness,0)
			NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"]["SVIndicator"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
			NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"].BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,1,1)

			NewPickerButtonInsideColorpicker.BackgroundColor3 = Color3.fromHSV(Colorpicker.Colors.Hue,Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness)
			Library.Flags[Colorpicker.Flag] = Colorpicker.Colors

			Colorpicker.Callback(NewPickerButtonInsideColorpicker.BackgroundColor3,NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"]["TIndicator"].BackgroundTransparency)
		end
		local function UpdateHue()
			local MouseOnHuePallete = math.clamp(Mouse.X - NewColorpaletteinsidecolorcontainer["Palette"]["HueButton"].AbsolutePosition.X,0,NewColorpaletteinsidecolorcontainer["Palette"]["HueButton"].AbsoluteSize.X) / NewColorpaletteinsidecolorcontainer["Palette"]["HueButton"].AbsoluteSize.X

			Colorpicker.Colors.Hue = MouseOnHuePallete
			UpdateColorpicker()
		end
		local function UpdateSV()
			local MouseOnSaturationPallete = math.clamp(Mouse.X - NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"].AbsolutePosition.X,0,NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"].AbsoluteSize.X) / NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"].AbsoluteSize.X
			local MouseOnBrightnessPallete =  math.clamp(Mouse.Y - NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"].AbsolutePosition.Y,0,NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"].AbsoluteSize.Y) / NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"].AbsoluteSize.Y

			Colorpicker.Colors.Saturation,Colorpicker.Colors.Brightness = MouseOnSaturationPallete, 1 - MouseOnBrightnessPallete
			UpdateColorpicker()
		end

		local function UpdateTransparency()
			local MouseOntransparencyBar = math.clamp(Mouse.X - NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"].AbsolutePosition.X,0,NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"].AbsoluteSize.X) / NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"].AbsoluteSize.X

			Colorpicker.Colors.Transparency = MouseOntransparencyBar
			UpdateColorpicker()
		end
		Library:storeEvent(UserInputService.InputBegan,function(Input)
			if Colorpicker.Opened and (Input.UserInputType == Enum.UserInputType.Touch or  Input.UserInputType == Enum.UserInputType.MouseButton1) then
				if not Library:IsHovered(ColorPaletteContainer) then 
					Colorpicker:Open(false)
				end
			end
		end)
		
		Library:storeEvent(NewPickerButtonInsideColorpicker.MouseButton1Down,function()
			Colorpicker:Open(not Colorpicker.Opened)

		end)
		Library:storeEvent(NewColorpaletteinsidecolorcontainer["Palette"]["HueButton"].MouseButton1Down,function()
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
				UpdateHue()
			end
		end)
		Library:storeEvent(NewColorpaletteinsidecolorcontainer["Palette"]["ACtualSVCOlor"]["SVTextureBackground"].MouseButton1Down,function()
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
				UpdateSV()
			end
		end)
		Library:storeEvent(NewColorpaletteinsidecolorcontainer["Palette"]["TransparencyButton"].MouseButton1Down,function()
			while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do task.wait()
				UpdateTransparency()
			end
		end)
		local ColorPalette = {Container = NewColorpaletteinsidecolorcontainer["Palette"],Identification = "Palette"}
		ColorPalette = setmetatable(ColorPalette,Library.ModuleDock)
		ColorPalette:Button({Title = "Use Accent",Callback = function()
			Colorpicker:Set(Library.Theme.Accent)
		end,})
		Colorpicker:Set(Colorpicker.Color,Colorpicker.transparency)
		Library.Elements[#Library.Elements + 1] = Colorpicker
		return setmetatable(Colorpicker,Library.ModuleDock)
	end
	return setmetatable(Colorpicker,Library.ModuleDock)
end
function ModuleDock:Button(Data)
	local Data = Data or {}
	local Button = {Identification="Button",Dock = self,Title = Data.Title or Data.title or "Button", Callback = Data.Callback or Data.callback }
	if self.Identification ~= "Settings" and self.Identification ~= "Palette" then Button.PageInfo = string.format("Page: %s",self.page.Title or "") end

	local NewButtonContainer = Library.UI_Create:NewButtonContainer()
	NewButtonContainer.Parent = self.Container

	local NewButton =Library.UI_Create:NewButton()
	NewButton.Parent = NewButtonContainer
	NewButton.Text = Button.Title
	Library:storeEvent(NewButton.MouseButton1Down,function()
		Button.Callback()
	end)
	function Button:DirectTo() --> For search
		--
		if self.Dock.Identification == "Settings" then return end
		self.Dock.Goto()
		--> to catch the user attention <--
		TweenService:Create(NewButton, Library.TweenInfo, {TextColor3 =Library.Theme.Accent }):Play()
		Library:UpdateObject(NewButton,"TextColor3", "Accent" )
		task.wait(2)
		TweenService:Create(NewButton, Library.TweenInfo, {TextColor3 = Library.Theme.LightText}):Play()
		Library:UpdateObject(NewButton,"TextColor3","LightText" )
	end
	function Button:Button(Data)
		local Data = Data or {}
		local Button = {Dock = self.Dock,Title = Data.Title or Data.title or "Button", Callback = Data.Callback or Data.callback}
		if self.Identification ~= "Settings" or self.Identification ~= "Palette" then Button.PageInfo = string.format("Page: %s",self.Dock.page.Title or "") end

		local NewButton =Library.UI_Create:NewButton()
		NewButton.Parent = NewButtonContainer
		NewButton.Text = Button.Title
		function Button:DirectTo() --> For search
			--
			self.Dock.Goto()
			--> to catch the user attention <--
			TweenService:Create(NewButton, Library.TweenInfo, {TextColor3 =Library.Theme.Accent }):Play()
			Library:UpdateObject(NewButton,"TextColor3", "Accent" )
			task.wait(2)
			TweenService:Create(NewButton, Library.TweenInfo, {TextColor3 = Library.Theme.LightText}):Play()
			Library:UpdateObject(NewButton,"TextColor3","LightText" )
		end
		Library:storeEvent(NewButton.MouseButton1Down,function()
			Button.Callback()
		end)
		Library.Elements[#Library.Elements + 1] = Button

	end
	Library.Elements[#Library.Elements + 1] = Button

	return setmetatable(Button,Library.ModuleDock)
end
return Library
