--[[
Qw Hub UI by Qw
Contact me by my discord qw211 for inquires or help about the Ui library.

Do not sell this UI or claim it as yours. This UI is free to use for anyone and will be forever.

there is no need to feel ashamed to learn or copy code from here, I tried my best to explain 
some of my code to make it easier to understand. 


]]
-- Use string.sub(string,#searchtext) to make sure the it filter through start to finish so the search wont just search whatever has the letter, autocomplete will just find first result and when tab is pressed it will direct to the module

if not game:IsLoaded() then game.Loaded:Wait() end

-->Services<--f
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
	Folder = "Qw Hub/ Universal", --> folder directory 

	--> text configuration  <--
	Text = {
		Font = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
		Size = 12,
		Name = "Inter",
		TextStrokeTranspareny = 0,
	},

	Theme = {
		Accent=Color3.fromRGB(121,0,0),
		DarkContrast=Color3.fromRGB(7, 7, 7),
		LightContrast=Color3.fromRGB(11, 11, 11),
		LightText= Color3.fromRGB(255,255,255),
		DarkText=Color3.fromRGB(100,100,100),
		InnerStroke = Color3.fromRGB(24,24,24),
		OuterStroke = Color3.fromRGB(0,0,0),
		Inactive = Color3.fromRGB(100,100,100),
		Active = Color3.fromRGB(255,255,255),

	},

	TweenInfo = TweenInfo.new(0.46, Enum.EasingStyle.Sine,Enum.EasingDirection.Out),
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
function Library:UpdateObject(Object:Instance, Property:any, Value:any)
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
			if string.find(Property,"Transparency") and typeof(Value) == "number" then
				Library:UpdateObject(Object,Property,Value)
			end
			if string.find(Property, "Color") and typeof(Value) == "string" and ObjectType ~= "UIGradient" then

				local Theme = self.Theme[Value]
				if Property ~= "IgnoreTheme" then 
					Library:UpdateObject(Object, Property, Value)
				end 
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
		warn("Failed to render object: " .. tostring(ObjectType .. table.unpack(Properties)),
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
--> this is so like 
function Library:FindModuleByFlag(Needle)
	-- search through the haystalk and isolate the needle
end
--> i use this to list the configs for the dropdown and isolate the name so they won't show as the entire directory
function Library:ListConfigFiles()
	-- List the config files, remove the directory string and isolate the file name 
end

function Library:NewConfig(Title:string,Description:string,Author:string)
	if isfolder(self.Folder) then makefolder(self.Folder) end
	for _, Element in pairs(Library.Elements) do 
		if Element.Flag and Element.Flag ~= ""   then 

		end
	end
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
	end
end

function Library:IsHovered(Object:Instance)
	if Mouse.X >= Object.AbsolutePosition.X and Mouse.X <= Object.AbsolutePosition.X + Object.AbsoluteSize.X  and Mouse.Y >= Object.AbsolutePosition.Y and Mouse.Y <= Object.AbsolutePosition.Y + Object.AbsoluteSize.Y then 
		return true
	else 
		return false
	end
end
function Library:ChangeFont(Font: Enum.Font| string) --> this part is not done and has not been tested yet <--
	for Index, Value in pairs(self.InstanceStorage) do
		if Value:IsA("FontFace") then
			for Index2, _ in pairs(Value) do
				Index[Index2] = Font

			end
		end
	end

end
--> Object Backend creation <-- 
Library.UI_Create ={
	NewWindow = function()
		local ScreenGui = Library:Render("ScreenGui", {ZIndexBehavior = Enum.ZIndexBehavior.Global, ResetOnSpawn = false}) 
		local UIScale = Library:Render("UIScale", {Parent = ScreenGui})


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
			Padding = UDim.new(0, 4),
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
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
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
			Position = UDim2.new(0, 0, 1, 20),
			BorderSizePixel = 0,
			ZIndex = Library.ZIndex,
			Size = UDim2.new(0, 140, 0, 30),
			Parent = SearchToggleButton 
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
			ImageColor3 = "DarkText",
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
			Name = "Input",
			CursorPosition = -1,
			TextColor3 = "LightText",
			ZIndex = Library.ZIndex + 1,
			Text = "",
			Size = UDim2.new(1, -34, 1, 0),
			Position = UDim2.new(0, 34, 0, 0),
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
			Name = "AutoComplete",
			TextColor3 = "DarkText",
			ZIndex = Library.ZIndex,
			Text = "",
			Size = UDim2.new(1, -34, 1, 0),
			Position = UDim2.new(0, 34, 0, 0),
			BorderSizePixel = 0,
			FontFace = Font.new("rbxassetid://12187365364", Enum.FontWeight.SemiBold, Enum.FontStyle.Normal),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
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


		return ScreenGui
	end,
	NewTabFrame = function()
		local Tabbuton = Library:Render("TextButton", {  
			TextTransparency = 1,
			Text = "",
			BackgroundTransparency = 1,
			ZIndex = Library.ZIndex,
			AutoButtonColor =false,
			Name = "Tabbuton",
			Size = UDim2.new(0, 26, 0, 26),
			BorderSizePixel = 0,
			BackgroundColor3 = "Accent",
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
			AnchorPoint = Vector2.new(0.5, 0.5),
			ZIndex = Library.ZIndex,
			Image = "rbxassetid://72732892493295",
			BackgroundTransparency = 1,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			BorderSizePixel = 0,
			Parent = Tabbuton 
		}) 
		Library:Render("UIGradient", {  
			Rotation = 127,
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(0,0,0)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
			},
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
			Name = "Page",
			Size = UDim2.new(1, 0, 1, -28),
			ZIndex = Library.ZIndex,
			BackgroundTransparency = 1,
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
			ClipsDescendants = true,
			TextTransparency = 1,
			ZIndex = Library.ZIndex,
			Text = "",
			Name = "Subtab",
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			--AutomaticSize = Enum.AutomaticSize.X,
			Size = UDim2.new(0, 0, 1, 0),
		}) 

		local UISizeConstraint = Library:Render("UISizeConstraint", {  
			MinSize = Vector2.new(18, 0),
			MaxSize = Vector2.new(10, 10),
			Parent = Subtab
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
			Size = UDim2.new(0, 0, 0, 12),
			AnchorPoint = Vector2.new(0, 0.5),
			Position = UDim2.new(0, 20, 0.5, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			ClipsDescendants = true,
			TextSize = 12,
			Parent = Subtab 
		}) 

		return Subtab
	end,
	NewSubTabPage = function()
		local Page = Library:Render("ScrollingFrame", {  
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
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
		local UIPadding = Library:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = page
		}) 
		return Sectiontab,page
	end,
	NewWidgetContainer = function()
		local ToggleWidgetButton = Library:Render("ImageButton", {  
			Name = "ToggleWidgetButton",
			Size = UDim2.new(0, 15, 0, 15),
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
			BackgroundColor3 = "LightContrast",
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
			BackgroundColor3="DarkContrast",
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
			BackgroundColor3 = "LightContrast",
			BorderSizePixel = 0,
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
			Position = UDim2.new(1, 0, 0, 4),
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
			TextSize = 14,
			Parent = DropdownBox 
		}) 
		local OptionContainer = Library:Render("ScrollingFrame", {  
			Active = true,
			ScrollBarImageTransparency = 1,
			ScrollBarThickness = 0,
			Name = "OptionContainer",
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
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 11),
			Parent = DropdownContainer 
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

}

local Tab = Library.Tabs;
local ModuleDock = Library.ModuleDock;
--> using Metatables aka Object Oriented Programming as constructors are so overpowered, if i call a function with a table index, i can Index it whatever as long as i index it with a metatable like this for example Index:Toggle <-- As long as the index is a metatables of Sections then it will work. Genius right? take notes beginners! <--
Library.__index = Library
Tab.__index = Library.Tabs
ModuleDock.__index = Library.ModuleDock

function Library:Window(Data) 
	local Data = Data or {} 
	local Window = {Title = Data.Title or Data.title,Game=Data.Game or Data.game,firsttab=true,tabs={}}


	local NewWindow = Library.UI_Create:NewWindow()

	NewWindow.Parent =  localPlayer:WaitForChild("PlayerGui")-- game:GetService("CoreGui")
	NewWindow["WindowHeader"]["UiTitle"].Text = Window.Title
	NewWindow["WindowHeader"]["GameTitle"].Text = Window.Game

	task.spawn(function() 
		-- this was the fucking solution all along, i was trying to find a way to run this code before subtab animation during runtime because this piece of shit code would be delaying during runtime and fuck up subtab size until you click, thank god i was looking at task library and found this miracle
		task.wait(0.2)
		NewWindow["UIScale"].Scale = camera.ViewportSize.X /  1440	

		Library:storeEvent(camera:GetPropertyChangedSignal('ViewportSize'),function()
			NewWindow["UIScale"].Scale = camera.ViewportSize.X /  1440
		end)
	end)

	function Window:HideHeader(bool: boolean)
		TweenService:Create(NewWindow["WindowHeader"]["HidetabbarButton"]["Arrow"], Library.TweenInfo, {Rotation =  bool and 0 or 180}):Play()
		TweenService:Create(NewWindow["WindowHeader"], Library.TweenInfo, {Size =  bool and UDim2.new(0,356,0,36) or UDim2.new(0,356,0,80)}):Play()
		TweenService:Create(NewWindow["WindowHeader"]["TabContainer"], Library.TweenInfo, {Size =  bool and UDim2.new(1,-70,0,0) or UDim2.new(1,-70,0,34)}):Play()
		NewWindow["WindowHeader"]["TabContainer"].Visible = not bool
		TweenService:Create(NewWindow["WindowHeader"]["SearchToggleButton"], Library.TweenInfo, {Size =  bool and UDim2.new(0,34,0,0) or UDim2.new(0,34,0,34)}):Play()
		TweenService:Create(NewWindow["WindowHeader"]["SearchToggleButton"]["SearchImage"], Library.TweenInfo, {Size =  bool and UDim2.new(1,12,0,0) or UDim2.new(0,12,0,12)}):Play()
	end



	Library:storeEvent(NewWindow["WindowHeader"]["HidetabbarButton"].MouseButton1Down,function()
		Window.WindowHeaderVis = not Window.WindowHeaderVis
		Window:HideHeader(Window.WindowHeaderVis)
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
	local Tab = {window = self, firstsubtab = true, Opened = false, Image = Data.Image or Data.image or nil, subtabs = Data.Subtabs or Data.subtabs or false,}

	local NewTabFrame = Library.UI_Create:NewTabFrame()
	NewTabFrame.Parent = self.Container["WindowHeader"]["TabContainer"]
	NewTabFrame["TabImage"].Image = Tab.Image

	local newWindowPage = Library.UI_Create:NewWindowPage()
	newWindowPage.Parent = self.Container
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
		local NewpagecontainerinsideWindow = Library.UI_Create:NewPage() 
		NewpagecontainerinsideWindow.Parent = newWindowPage
		Tab.Container = {LEFT = NewpagecontainerinsideWindow["LEFT"], RIGHT = NewpagecontainerinsideWindow["RIGHT"]}

		NewpagecontainerinsideWindow = nil -- garbage collection

	end
	Library:storeEvent(NewTabFrame.MouseEnter,function()
		if not Tab.Opened then 
			TweenService:Create(NewTabFrame["TabImage"], Library.TweenInfo, {ImageColor3 =  Library.Theme.Active}):Play()
			Library:UpdateObject(NewTabFrame["TabImage"], "ImageColor3",  Library.Theme.Active )
		end
	end)
	Library:storeEvent(NewTabFrame.MouseLeave,function()
		if not Tab.Opened then 
			TweenService:Create(NewTabFrame["TabImage"], Library.TweenInfo, {ImageColor3 =  Library.Theme.Inactive}):Play()
			Library:UpdateObject(NewTabFrame["TabImage"], "ImageColor3",  Library.Theme.Inactive )
		end
	end)

	function Tab:Open(bool: boolean)
		newWindowPage.Visible = bool
		self.Opened = bool

		TweenService:Create(NewTabFrame, Library.TweenInfo, {BackgroundTransparency = bool and 0 or 1}):Play()
		TweenService:Create(NewTabFrame["TabImage"], Library.TweenInfo, {ImageColor3 = bool and Library.Theme.Active or Library.Theme.Inactive}):Play()
		Library:UpdateObject(NewTabFrame["TabImage"], "ImageColor3", bool and Library.Theme.Active or Library.Theme.Inactive)
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

	if self.firsttab then 
		Tab:Goto()
		self.firsttab = nil 
	end 

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
		local Subtab = {tab = self,window=self.window,issubtab = true,Title = Data.Title or Data.title or "Tab", Image = Data.Image or Data.image or nil, }

		local NewSubTab = Library.UI_Create:NewSubTab()
		NewSubTab.Parent = self.Container[2]
		NewSubTab["SubtabTitle"].Text = Subtab.Title 
		NewSubTab["SubtabImage"].Image = Subtab.Image 
		NewSubTab["UISizeConstraint"].MaxSize = Vector2.new((NewSubTab["SubtabTitle"].TextBounds.X + 4) / math.clamp(self.window.Container["UIScale"].Scale,0,0.99)  + 18 + 4,40 )
		local NewSubTabPage = Library.UI_Create:NewSubTabPage()
		NewSubTabPage.Parent = self.Container[1]
		NewSubTabPage.Name = Subtab.Title

		Subtab.Container = {LEFT = NewSubTabPage["LEFT"], RIGHT = NewSubTabPage["RIGHT"]}

		function Subtab:Openanimation(bool:boolean)
--[[ 
Boy oh boy, this ahs got the most stressful part of making this ui, as i was making it, i realized that words would get cut off after i added
auto scaling to my UI, than it took me 2 hours to research, experiment, and come with the final calculation. I HOPE I DONT FIND ANOTHER BUG AGAIN FROM THIS PART AND IF I DO I AM GOING TO CHANGE THE DESIGN
]]
			TweenService:Create(NewSubTab, Library.TweenInfo, {Size = bool and UDim2.new(0,(NewSubTab["SubtabTitle"].TextBounds.X + 4) / math.clamp(self.tab.window.Container["UIScale"].Scale,0,0.99)  + 18 + 4, 1,0) or UDim2.new(0,18,1,0) }):Play() -- 18 = Icon size, 9 = spacing between icon 
			TweenService:Create(NewSubTab["SubtabImage"], Library.TweenInfo, {ImageColor3 = bool and Library.Theme.Accent or Library.Theme.Inactive}):Play()
			Library:UpdateObject(NewSubTab["SubtabImage"], "ImageColor3", bool and Library.Theme.Accent or Library.Theme.Inactive)
			TweenService:Create(NewSubTab["SubtabTitle"], Library.TweenInfo, {TextColor3 = bool and Library.Theme.Accent or Library.Theme.DarkText,Size = bool and UDim2.new(0,(NewSubTab["SubtabTitle"].TextBounds.X + 4) / math.clamp(self.tab.window.Container["UIScale"].Scale,0,0.99) ,1,0) or UDim2.new(0,0,0) }):Play()
			Library:UpdateObject(NewSubTab["SubtabTitle"], "TextColor3", bool and Library.Theme.Accent or Library.Theme.DarkText)
			--	NewSubTab["UISizeConstraint"].MaxSize = Vector2.new((NewSubTab["SubtabTitle"].TextBounds.X + 4) / math.clamp(self.tab.window.Container["UIScale"].Scale,0,0.99)  + 18 + 4,40 )

		end

		function Subtab:Goto() -- gonna need this for search function
			self.tab:Goto()
			self.tab.Container[1]["UIPageLayout"]:JumpTo(self.tab.Container[1][self.Title])

		end

		Library:storeEvent(NewSubTab.MouseEnter,function()

			if  self.Container[1]["UIPageLayout"].CurrentPage.Name ~= Subtab.Title then 
				TweenService:Create(NewSubTab, Library.TweenInfo, {Size = UDim2.new(0,(NewSubTab["SubtabTitle"].TextBounds.X + 4) / math.clamp(self.window.Container["UIScale"].Scale,0,0.99)  + 18 + 4 , 1,0)}):Play()
				TweenService:Create(NewSubTab["SubtabImage"], Library.TweenInfo, {ImageColor3 = Library.Theme.Active}):Play()
				Library:UpdateObject(NewSubTab["SubtabImage"], "ImageColor3",  Library.Theme.Active )
				TweenService:Create(NewSubTab["SubtabTitle"], Library.TweenInfo, {TextColor3 = Library.Theme.LightText,Size =  UDim2.new(0,(NewSubTab["SubtabTitle"].TextBounds.X + 4) /math.clamp(self.window.Container["UIScale"].Scale,0,0.99), 1,0,1,0) }):Play()
				Library:UpdateObject(NewSubTab["SubtabTitle"], "TextColor3",  Library.Theme.Active)

			end
		end)
		Library:storeEvent(NewSubTab.MouseLeave,function()
			if  self.Container[1]["UIPageLayout"].CurrentPage.Name ~= Subtab.Title then 

				TweenService:Create(NewSubTab, Library.TweenInfo, {Size = UDim2.new(0,18,1,0) }):Play()
				TweenService:Create(NewSubTab["SubtabImage"], Library.TweenInfo, {ImageColor3 = Library.Theme.Inactive}):Play()
				Library:UpdateObject(NewSubTab["SubtabImage"], "ImageColor3",  Library.Theme.Inactive )
				TweenService:Create(NewSubTab["SubtabTitle"], Library.TweenInfo, {TextColor3 = Library.Theme.DarkText,Size =  UDim2.new(0,0,1,0) }):Play()
				Library:UpdateObject(NewSubTab["SubtabTitle"], "TextColor3",  Library.Theme.Inactive)

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
	local Section = {Page = self,WindowPage=self.Windowpage,Side = Data.Side or Data.side or "Left",Pages={}, Title = Data.Title or Data.title or "", SubSections = Data.group or Data.Group or false,Firstsectiontab = true,}

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
			Section.Page:Goto()
		end
	end
	Section.Windowpage = self.Windowpage
	return setmetatable(Section,Library.ModuleDock)	
end
function ModuleDock:Section_Page(Data) 
	if self.SubSections then   
		local Data = Data or {}
		local SectionTab = {Section=self,page=self.Page,Tab=self.tab,Title = Data.Title or Data.title or "",Opened = false,}
		SectionTab.Windowpage = self.Windowpage

		local NewMultiSectionTab,Page = Library.UI_Create:NewMultiSectionTab()
		NewMultiSectionTab.Parent = self.Container[1]["SectionTabBar"]
		NewMultiSectionTab.Text = SectionTab.Title
		Page.Parent = self.Container[2]

		function SectionTab:Open(bool)
			self.Opened = bool
			TweenService:Create(NewMultiSectionTab, Library.TweenInfo, {TextColor3 = bool and Library.Theme.Accent or Library.Theme.DarkText}):Play()
			Library:UpdateObject(NewMultiSectionTab,"TextColor3", bool and Library.Theme.Accent or Library.Theme.DarkText)
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
		if self.Firstsectiontab then 
			SectionTab:Goto()
			self.Firstsectiontab = nil 
		end
		Library:storeEvent(NewMultiSectionTab.MouseButton1Down,function()
			if not SectionTab.Opened then 
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
function ModuleDock:Dropdown(Data)
	local Data = Data or {}
	local Dropdown = {Opened = false,Combo = Data.Combo or Data.combo or false, Title = Data.Title or Data.title or "Dropdown", Value = Data.Value or Data.value or "" ,Options = Data.Options or Data.options or {"1","2"},Callback=Data.Callback or Data.callback }

	local NewDropdown = Library.UI_Create:NewDropdown()
	NewDropdown.Parent = self.Container
	NewDropdown["DropdownTitle"].Text = Dropdown.Title

	function Dropdown:SetValue(Value: string)
		if self.Combo then 
			if table.find(self.Value,Value) then 
				table.remove(self.Value,table.find(self.Value, Value))
			elseif not table.find(self.Value,Value) then
				self.Value[#self.Value + 1] = Value
			end
			NewDropdown["DropdownBox"]["DropdownSelected"].Text =  table.concat(self.Value, ", ")
		elseif not Dropdown.Combo then
			self.Value = Value
			NewDropdown["DropdownBox"]["DropdownSelected"].Text =  tostring(self.Value)
		end 
		for _,Option in pairs(NewDropdown["DropdownBox"]["NoClickDetector"]["OptionContainer"]:GetChildren()) do 
			if Dropdown.Combo then 
			if  Option.Name == Value and  table.find(self.Value,Option.Name)and Option:IsA("TextButton") then 
				TweenService:Create(Option["OptionText"], Library.TweenInfo, {TextColor3 = Library.Theme.Accent, Size = UDim2.new(1,-8,1,0)}):Play()
				TweenService:Create(Option["Indicator"], Library.TweenInfo, {Size = UDim2.new(0,3,1,0)}):Play()
				Library:UpdateObject(Option["OptionText"],"TextColor3",Library.Theme.LightText)
				elseif  Option.Name == Value and not table.find(self.Value,Option.Name) and Option:IsA("TextButton") then
				TweenService:Create(Option["OptionText"], Library.TweenInfo, {TextColor3 = Library.Theme.DarkText, Size = UDim2.new(1,0,1,0)}):Play()
				TweenService:Create(Option["Indicator"], Library.TweenInfo, {Size = UDim2.new(0,0,1,0)}):Play()
				Library:UpdateObject(Option["OptionText"],"TextColor3",Library.Theme.DarkText)
				end
				else
			if  Option.Name == Value  and Option:IsA("TextButton") then 
					TweenService:Create(Option["OptionText"], Library.TweenInfo, {TextColor3 = Library.Theme.Accent, Size = UDim2.new(1,-8,1,0)}):Play()
				TweenService:Create(Option["Indicator"], Library.TweenInfo, {Size = UDim2.new(0,3,1,0)}):Play()
				Library:UpdateObject(Option["OptionText"],"TextColor3",Library.Theme.LightText)
					
			elseif  Option.Name ~= Value  and Option:IsA("TextButton") then
					TweenService:Create(Option["OptionText"], Library.TweenInfo, {TextColor3 = Library.Theme.DarkText, Size = UDim2.new(1,0,1,0)}):Play()
					TweenService:Create(Option["Indicator"], Library.TweenInfo, {Size = UDim2.new(0,0,1,0)}):Play()
					Library:UpdateObject(Option["OptionText"],"TextColor3",Library.Theme.DarkText)
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
					Dropdown:SetValue(NewOption.Name)
				end)
			end
		end
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
			TweenService:Create(NewDropdown["DropdownBox"]["Dropdownarrow"], Library.TweenInfo, {Rotation = bool and 180 or 0,ImageColor3 = bool and Library.Theme.Active or Library.Theme.Inactive}):Play()
			Library:UpdateObject(NewDropdown["DropdownTitle"],"ImageColor3",  bool and Library.Theme.Active or Library.Theme.Inactive)
			TweenService:Create(NewDropdown["DropdownBox"]["DropdownSelected"], Library.TweenInfo, {TextColor3 = bool and Library.Theme.LightText or Library.Theme.DarkText}):Play()
			Library:UpdateObject(NewDropdown["DropdownBox"]["DropdownSelected"],"TextColor3", bool and Library.Theme.LightText or Library.Theme.DarkText)
			TweenService:Create(NewDropdown["DropdownTitle"], Library.TweenInfo, {TextColor3 = bool and Library.Theme.LightText or Library.Theme.DarkText}):Play()
			Library:UpdateObject(NewDropdown["DropdownTitle"],"TextColor3", bool and Library.Theme.LightText or Library.Theme.DarkText)
			NewDropdown["DropdownBox"]["NoClickDetector"].Visible = bool
			

			task.wait(0.4)
			debounce= false
		end
	end
	Library:storeEvent(NewDropdown.MouseButton1Down,function()
		Dropdown:Open(not Dropdown.Opened)
	end)
			
	Dropdown:NewOptions(Dropdown.Options)
	
	if Dropdown.Combo and Dropdown.Value == "" then 
		Dropdown.Value = {}
		Dropdown:SetValue(Dropdown.Options[1])
	elseif Dropdown.Combo and Dropdown.Value ~= "" then  
		Dropdown:SetValue(Dropdown.Value)
	end
	if  not Dropdown.Combo and Dropdown.Value == "" then
		Dropdown:SetValue(Dropdown.Options[1])
	elseif not Dropdown.Combo and Dropdown.Value ~= "" then
		Dropdown:SetValue(Dropdown.Value)
		end
	return setmetatable(Dropdown,Library.ModuleDock)
end
function ModuleDock:Toggle(Data)
	local Data = Data or {}
	local Toggle = {Identification = "Toggle",Dock = self,Title = Data.Title or Data.title or "", Value = Data.Value or Data.value or false, Callback = Data.Callback or Data.callback}

	local NewToggle = Library.UI_Create:NewToggle()
	NewToggle.Parent = self.Container
	NewToggle["ToggleTitle"].Text = Toggle.Title

	function Toggle:DirectTo() --> For search
		--
		if self.Dock.Identification == "Settings" then return end
		self.Dock.Goto()
		--> to catch the user attention <--
		TweenService:Create(NewToggle["ToggleTitle"], Library.TweenInfo, {TextColor3 =Library.Theme.Accent }):Play()
		Library:UpdateObject(NewToggle["ToggleTitle"],"TextColor3", Library.Theme.Accent )
		task.wait(2)
		TweenService:Create(NewToggle["ToggleTitle"], Library.TweenInfo, {TextColor3 = Toggle.Value and Library.Theme.LightText or Library.Theme.DarkText }):Play()
		Library:UpdateObject(NewToggle["ToggleTitle"],"TextColor3",Toggle.Value and Library.Theme.LightText or Library.Theme.DarkText )
	end

	function Toggle:Set(NewValue:boolean)
		self.Value = NewValue 
		TweenService:Create(NewToggle["ToggleTitle"], Library.TweenInfo, {TextColor3 = NewValue and Library.Theme.LightText or Library.Theme.DarkText}):Play()
		Library:UpdateObject(NewToggle["ToggleTitle"],"TextColor3", NewValue and Library.Theme.LightText or Library.Theme.DarkText)
		TweenService:Create(NewToggle["Checkbox"], Library.TweenInfo, {BackgroundColor3 = NewValue and Library.Theme.Accent or Library.Theme.DarkContrast}):Play()
		Library:UpdateObject(NewToggle["ToggleTitle"],"BackgroundColor3", NewValue and Library.Theme.Accent or Library.Theme.DarkContrast)
		TweenService:Create(NewToggle["Checkbox"]["Checkmark"], Library.TweenInfo, {Size = NewValue and UDim2.new(0,15,0,15) or UDim2.new(0,0,0,0)}):Play()
		
	end

	Library:storeEvent(NewToggle.MouseButton1Down,function()
		Toggle:Set(not Toggle.Value)
	end)
	Toggle:Set(Toggle.Value)

	Toggle.Container = {NewToggle["ToggleExtraModuletContainer"],Toggle.Dock.Windowpage}
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
			Library:UpdateObject(ToggleButton,"ImageColor3", bool and Library.Theme.Active or Library.Theme.Inactive)
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
function ModuleDock:Colorpicker(Data)
	local Data = Data or {}
	local Colorpicker = {Identification = "Colorpicker",Flag = Data.Flag or Data.flag or "", Title = Data.Title or Data.title or "", Value = Data.Value or Data.value or Color3.fromHSV(0,0,0), transparency = Data.Transparency or Data.transparency or 0, Container = nil, Callback = Data.Callback or Data.callback }

	return setmetatable(Library.ModuleDock,Colorpicker)
end
function ModuleDock:Button(Data)
	local Data = Data or {}
	local Button = {Identification="Button",Title = Data.Title or Data.title or "Button", Callback = Data.Callback or Data.callback }

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
		Library:UpdateObject(NewButton,"TextColor3", Library.Theme.Accent )
		task.wait(2)
		TweenService:Create(NewButton, Library.TweenInfo, {TextColor3 = Library.Theme.LightText}):Play()
		Library:UpdateObject(NewButton,"TextColor3",Library.Theme.LightText )
	end
	function Button:Button(Data)
		local Data = Data or {}
		local Button = {Title = Data.Title or Data.title or "Button", Callback = Data.Callback or Data.callback}

		local NewButton =Library.UI_Create:NewButton()
		NewButton.Parent = NewButtonContainer
		NewButton.Text = Button.Title

		Library:storeEvent(NewButton.MouseButton1Down,function()
			Button.Callback()
		end)
	end
	return setmetatable(Button,Library.ModuleDock)
end 
return Library
