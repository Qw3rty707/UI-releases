local Services = setmetatable({}, {__index = function(Self, Index)
	return game:GetService(Index)
end})

-->Services<--
local Players = Services.Players;
local UserInputService = Services.UserInputService;
local RunService = Services.RunService;
local ts = Services.TweenService;
local HtppService = Services.HttpService;

--> dont need these variables anymore, will fix them one day; i am too lazy to do it right now <-- 
-->Variables<--
local localPlayer = Players.LocalPlayer;
local camera = workspace.CurrentCamera;
local Mouse = localPlayer:GetMouse();
local INew = Instance.new;
local color3RGB =  Color3.fromRGB;
local V2new = Vector2.new;
local UDim2new = UDim2.new;
local UDimnew = UDim.new;

local Library = {
	Connections = {},
	Subtabs = {}, 
	sections = {},
	short_keybind_names = {
		["MouseButton1"] = "MB1",
		["MouseButton2"] = "MB2",
		["MouseButton3"] = "MB3",
		["Insert"] = "INS",
		["LeftAlt"] = "LALT",
		["LeftControl"] = "LC",
		["LeftShift"] = "LS",
		["RightAlt"] = "RALT",
		["RightControl"] = "RC",
		["RightShift"] = "RS",
		["CapsLock"] = "CAPS",
		["Return"] = "RET",
		--	["Backspace"] = "BSP",
		["BackSlash"] = "BS"
	},
	Elementsopened = {},
	InstanceStorage = {},
	WhitelistedMouse = {
		Enum.UserInputType.MouseButton1, Enum.UserInputType.MouseButton2,
		Enum.UserInputType.MouseButton3
	},
	BlacklistedKeys = {
		Enum.KeyCode.Unknown, Enum.KeyCode.W, Enum.KeyCode.A, Enum.KeyCode.S,
		Enum.KeyCode.D, Enum.KeyCode.Up, Enum.KeyCode.Left, Enum.KeyCode.Down,
		Enum.KeyCode.Right, Enum.KeyCode.Slash, Enum.KeyCode.Tab,
		Enum.KeyCode.Backspace, Enum.KeyCode.Escape
	},
	Flags = {}, --> stores the modules table
	Tabs = {}, --> stores tabs
	Elements = {},
	Folder = "Qw hub/", --> folder directory 

	--> text configuration (static) <--
	Text = {
		Font = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
		Size = 12,
		TitleSize = 12,
		TextStrokeTranspareny = 0,
	},
}
local Utility = {
--> Color Configuration for Interface (static) <--	
	Theme = {
		DarkContrastBackground = Color3.fromRGB(10, 10, 10),
		LightContrastBackground = Color3.fromRGB(23, 23, 23),
		Text = Color3.fromRGB(255, 255, 255),
		Muted = Color3.fromRGB(176, 176, 176),
		Accent = Color3.fromRGB(200, 159, 223),
		BorderInner = Color3.fromRGB(71, 71, 71),
		Highlight = color3RGB(99, 99, 99),
		BorderOuter = Color3.fromRGB(0,0,0),

	},
	TweenInfo = TweenInfo.new(0.46, Enum.EasingStyle.Sine,Enum.EasingDirection.Out)
}

Library.Utility = Utility -- for some reason if i return two tables at the end it doesnt work so this will do, i need it so i can use the utility functions 
--> stores Connect RBXSCRIPTSIGNAl to disconnect them once the UI is unloaded<--
function Utility:storeEvent(Event, thread)
	local Connection;
	local Passed, Statement = pcall(function()
		Connection = Event:Connect(thread);
	end)
	if Passed then
		table.insert(Library.Connections, Connection);
		return Connection;
	else
		warn(Event, Statement);
		return nil;
	end
end
function Utility:ToRGB(color)
	return math.floor(color.R*255), math.floor(color.G*255), math.floor(color.B*255)
end
--> changes the object current theme <--
function Utility:UpdateObject(Object, Property, Value)
	if not Library.InstanceStorage[Object] then
		Library.InstanceStorage[Object] = {[Property] = Value}
	else
		Library.InstanceStorage[Object][Property] = Value
	end
end


--> Makes new frames <--
function Utility:Render(ObjectType: string, Properties, Children)
	local Passed, Statement = pcall(function()
		local Object = Instance.new(ObjectType)

		for Property, Value in pairs(Properties) do
			if string.find(Property, "Color") and typeof(Value) == "string" and
				ObjectType ~= "UIGradient" then
				local Theme = self.Theme[Value]
				Utility:UpdateObject(Object, Property, Value)
				Object[Property] = Theme
			else
				Object[Property] = Value

			end
			if string.find(Property,"FontFace")  then 
				Object[Property] = Library.Text.Font
				Utility:UpdateObject(Object, Property, Value)

			end
		end
		if Children then
			for Index, Child in pairs(Children) do
				Child.Parent = Object
			end
		end
		return Object
	end)

	if Passed then
		return Statement
	else
		warn("Failed to render object: " .. tostring(ObjectType),
			tostring(Statement))
		return nil
	end
end
--> converts hext to a color3 value <--
function Utility:hexToColor3(hex: string)
	hex = hex:gsub("#","")
	local r = tonumber("0x" .. hex:sub(1, 2)) / 255
	local g = tonumber("0x" .. hex:sub(3, 4)) / 255
	local b = tonumber("0x" .. hex:sub(5, 6)) / 255
	return Color3.new(r, g, b)
end
--> changes the theme of the menu <--
function Utility:SetTheme(Theme: string, Color: Color3)
	if Utility.Theme[Theme] ~= Color then
		Utility.Theme[Theme] = Color
		--
		for Index, Value in pairs(Library.InstanceStorage) do
			for Index2, Value2 in pairs(Value) do
				if Value2 == Theme then Index[Index2] = Color end
			end
		end
	end
end

function Utility:SetFont(Font: Enum.Font) --> this part is not done and has not been tested yet <--
	for Index, Value in pairs(Library.InstanceStorage) do
		for Index2, Value2 in pairs(Value) do
			Index[Index2] = Font

		end
	end

end

Library.RenderModules = setmetatable({
	Window = function()
		local Copy = Utility:Render("ScreenGui", {  
			ResetOnSpawn = false,
			Name = "Copy",
			Enabled = true,
		}) 
		local Window = Utility:Render("Frame", {  
			Name = "Window",
			Position = UDim2.new(0.05540476366877556, 168, -0.18541717529296875, 122),
			Size = UDim2.new(0, 629, 0, 461),
			BorderSizePixel = 0,
			BackgroundColor3 = "DarkContrastBackground",
			Parent = Copy 
		}) 
		local SideBar = Utility:Render("Frame", {  
			Name = "SideBar",
			Size = UDim2.new(0, 167, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = "LightContrastBackground",
			Parent = Window 
		}) 
		local SideBarSeparator = Utility:Render("Frame", {  
			AnchorPoint = Vector2.new(1, 0),
			Name = "SideBarSeparator",
			Position = UDim2.new(1, 0, 0, 0),
			Size = UDim2.new(0, 1, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = "BorderInner",
			Parent = SideBar 
		}) 
		local TabContainer = Utility:Render("ScrollingFrame", {  
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 4,
			Name = "TabContainer",
			Size = UDim2.new(1, 0, 0, 382),
			Position = UDim2.new(0, 0, 0, 42),
			BackgroundTransparency = 1,
			ScrollingDirection = Enum.ScrollingDirection.Y,
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = SideBar 
		}) 
		local UIListLayout = Utility:Render("UIListLayout", {  
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = TabContainer 
		}) 
		local UIPadding = Utility:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 4),
			PaddingRight = UDim.new(0, 11),
			PaddingLeft = UDim.new(0, 10),
			Parent = TabContainer 
		}) 
		local InterfaceTitle = Utility:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Bold, Enum.FontStyle.Normal),
			TextColor3 = "Text",
			TextStrokeTransparency = 0,
			Name = "InterfaceTitle",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 164, 0, 30),
			BorderSizePixel = 0,
			TextYAlignment = Enum.TextYAlignment.Bottom,
			TextSize = 18,
			Parent = SideBar 
		}) 
		local PageContentsContainer = Utility:Render("ScrollingFrame", {  
			Active = true,
			AutomaticCanvasSize = Enum.AutomaticSize.Y,
			ScrollBarThickness = 0,
			Name = "PageContentsContainer",
			Size = UDim2.new(0, 461, 1, 0),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.26581498980522156, 0, 0, 0),
			BorderSizePixel = 0,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Parent = Window 
		}) 
		local PageContentLayout = Utility:Render("UIPageLayout", {  
			TouchInputEnabled = false,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			GamepadInputEnabled = false,
			Padding = UDimnew(0,20),
			EasingStyle = Enum.EasingStyle.Linear,
			FillDirection = Enum.FillDirection.Vertical,
			Animated = true,
			TweenTime = 0.6000000238418579,
			ScrollWheelInputEnabled = false,
			Name = "PageContentLayout",
			EasingDirection = Enum.EasingDirection.InOut,
			Parent = PageContentsContainer 
		}) 
		local UIScale = Utility:Render("UIScale", {  
			Parent = Copy 
		}) 

		return Copy


	end,
	TabButton = function()

		local TabFrame = Utility:Render("TextButton", {  
			Name = "TabFrame",
			Text = "",
			AutoButtonColor = false,
			BackgroundTransparency = 1,
			Active = true,
			Selectable = true,
			Size = UDim2.new(1, 0, 0, 24),
			BorderSizePixel = 0,
			BackgroundColor3 = "Accent",
		}) 
		local UIListLayout = Utility:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			FillDirection = Enum.FillDirection.Horizontal,
			Padding = UDim.new(0, 8),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = TabFrame
		}) 
		local TabTitle = Utility:Render("TextLabel", {  
			LayoutOrder = 2,
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = "Muted",
			TextStrokeTransparency = 0,
			Name = "TabTitle",
			Size = UDim2.new(0, 0, 1, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 12,
			Parent = TabFrame
		}) 
		local InnerStroke = Utility:Render("UIStroke", {  
			Transparency = 1,
			Name = "InnerStroke",
			Color = "Accent",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			Parent = TabFrame 
		}) 
		local OuterStroke = Utility:Render("UIStroke", {  
			Transparency = 1,
			Name = "OuterStroke",
			Color = "BorderOuter",
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
			Parent = TabFrame 
		}) 
		local TabIcon = Utility:Render("ImageLabel", {  
			LayoutOrder = 1,
			Name = "TabIcon",
			Image = "rbxassetid://72732892493295",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 12, 0, 12),
			ImageColor3 = "Muted",
			BorderSizePixel = 0,
			Parent = TabFrame
		}) 
		local UIPadding = Utility:Render("UIPadding", {  
			PaddingRight = UDim.new(0, 10),
			PaddingLeft = UDim.new(0, 8),
			Parent = TabFrame 
		}) 
		local UIGradient = Utility:Render("UIGradient", {  
			Rotation = -92,
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.8374999761581421),
				NumberSequenceKeypoint.new(0.014, 0),
				NumberSequenceKeypoint.new(1, 0.006249964237213135)
			},
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, Color3.fromRGB(20,20,20)),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))
			},
			Parent = TabFrame 
		}) 

		return TabFrame
	end,
	PageContainer = function()
		local PageContainer = Utility:Render("Frame", {  
			BackgroundTransparency = 1,
			Name = "PageContainer",
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			ClipsDescendants = true,
		}) 

		local UIListLayout = Utility:Render("UIListLayout", {  
			Padding = UDim.new(0, 26),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = PageContainer 
		}) 
		local UIPadding = Utility:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 12),
			PaddingRight = UDim.new(0, 12),
			PaddingLeft = UDim.new(0, 12),
			Parent = PageContainer 
		}) 
		local TabPage = Utility:Render("Frame", {  
			LayoutOrder = 2,
			BackgroundTransparency = 1,
			Name = "TabPage",
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			Parent = PageContainer,
			ClipsDescendants = true,

		}) 
		local PageContentLayout = Utility:Render("UIPageLayout", {  
			TouchInputEnabled = false,
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			FillDirection = Enum.FillDirection.Horizontal,
			GamepadInputEnabled = false,
			EasingStyle = Enum.EasingStyle.Linear,
			Animated = true,
			TweenTime = 0.6000000238418579,
			ScrollWheelInputEnabled = false,
			Name = "PageContentLayout",
			EasingDirection = Enum.EasingDirection.InOut,
			Parent = TabPage 
		}) 
		return PageContainer
	end,
	PagemoduleContainer = function()



		local PageContainerinside = Utility:Render("Frame", {  
			LayoutOrder = 2,
			BackgroundTransparency = 1,
			Name = "PageContainerinside",
			Size = UDim2.new(1, 0, 1, 0),
			BorderSizePixel = 0,
			ClipsDescendants = true,

		}) 
		local UIListLayout = Utility:Render("UIListLayout", {  
			FillDirection = Enum.FillDirection.Horizontal,
			HorizontalAlignment = Enum.HorizontalAlignment.Center,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent =PageContainerinside
		}) 

		local Left = Utility:Render("Frame", {  
			BackgroundTransparency = 1,
			Name = "Left",
			Size = UDim2.new(0, 100, 1, 0),
			BorderSizePixel = 0,
			Parent = PageContainerinside 
		}) 
		local UIListLayout = Utility:Render("UIListLayout", {  
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Left 
		}) 
		local Right = Utility:Render("Frame", {  
			BackgroundTransparency = 1,
			Name = "Right",
			Size = UDim2.new(0, 100, 1, 0),
			BorderSizePixel = 0,
			Parent = PageContainerinside 
		}) 
		local UIListLayout = Utility:Render("UIListLayout", {  
			Padding = UDim.new(0, 12),
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = Right 
		}) 

		return PageContainerinside

	end,
	SubtabContainer = function()
		local SubtabBar = Utility:Render("Frame", {  
			Name = "SubtabBar",
			Position = UDim2.new(0, 12, 0, 8),
			Size = UDim2.new(1, 0, 0, 26),
			BorderSizePixel = 0,
			Visible = true,
			BackgroundColor3 = "LightContrastBackground",
		}) 
		local UIListLayout = Utility:Render("UIListLayout", {  
			VerticalAlignment = Enum.VerticalAlignment.Center,
			SortOrder = Enum.SortOrder.LayoutOrder,
			HorizontalFlex = Enum.UIFlexAlignment.Fill,
			FillDirection = Enum.FillDirection.Horizontal,
			Parent = SubtabBar 
		}) 

		local OuterStroke = Utility:Render("UIStroke", {  
			Name = "OuterStroke",
			Parent = SubtabBar 
		}) 
		local InnerStroke = Utility:Render("UIStroke", {  
			Color = "BorderInner",
			Name = "InnerStroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SubtabBar 
		}) 
		return SubtabBar

	end,
	SubtabButton = function()
		local SubtabButton = Utility:Render("TextButton", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = "Muted",
			TextStrokeTransparency = 0,
			Name = "SubtabButton",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 0, 1, 0),
			AutoButtonColor = false,
			BackgroundColor3 = "Highlight",
			AutomaticSize = Enum.AutomaticSize.X,
			TextSize = 12,
		}) 
		return SubtabButton

	end,

	SectionFrame = function()

		local SectionFrame = Utility:Render("Frame", {  
			Name = "SectionFrame",
			Size = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = false,
			BackgroundColor3 = "LightContrastBackground",
		}) 



		local UIPadding = Utility:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 18),
			PaddingBottom = UDim.new(0, 16),
			PaddingRight = UDim.new(0, 14),
			PaddingLeft = UDim.new(0, 14),
			Parent = SectionFrame 
		}) 

		local Innerstroke = Utility:Render("UIStroke", {  
			Color = "BorderInner",
			Name = "Innerstroke",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SectionFrame 
		}) 
		local OuterStroke = Utility:Render("UIStroke", {  
			Name = "OuterStroke",
			Color = "BorderOuter",
			Parent = SectionFrame 
		}) 

		local ModuleContainer = Utility:Render("Frame", {  
			LayoutOrder = 2,
			BackgroundTransparency = 1,
			Name = "ModuleContainer",
			Size = UDim2.new(1, 0, 0, 0),
			BorderSizePixel = 0,
			ClipsDescendants = false,
			AutomaticSize = Enum.AutomaticSize.Y,
			Parent = SectionFrame
		}) 
		local SectionTitle = Utility:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = "Text",
			TextStrokeTransparency = 0,
			Name = "SectionTitle",
			Size = UDim2.new(0, -4, 0, 14),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			TextSize = 12,
			Parent = ModuleContainer
		}) 

		local UIListLayout = Utility:Render("UIListLayout", {  
			Padding = UDim.new(0, 14),
			Name = "UiListLayout",
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ModuleContainer 
		}) 
		return SectionFrame
	end,
	
	SwitchContainer = function()
		local SwitchContainer = Utility:Render("TextButton", {  
			BackgroundTransparency = 1,
			Text="",
			Name = "SwitchContainer",
			Size = UDim2.new(1, 0, 0, 16),
			BorderSizePixel = 0,
		}) 
		local switchbackground = Utility:Render("Frame", {  
			AnchorPoint = Vector2.new(0, 0.5),
			Name = "switchbackground",
			Position = UDim2.new(0, 0, 0.5, 0),
			Size = UDim2.new(0, 32, 1, 0),
			BorderSizePixel = 0,
			BackgroundColor3 = "DarkContrastBackground",
			Parent = SwitchContainer 
		}) 
		local UIStroke = Utility:Render("UIStroke", {  
			Color = "BorderInner",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = switchbackground 
		}) 
		local UIStroke = Utility:Render("UIStroke", {  
			Color = "BorderOuter",
			Parent = switchbackground 
		}) 
		local switchslider = Utility:Render("Frame", {  
			AnchorPoint = Vector2.new(0, 0.5),
			Name = "switchslider",
			Position = UDim2.new(1, -12, 0.5, 0),
			Size = UDim2.new(0, 8, 0, 8),
			BorderSizePixel = 0,
			BackgroundColor3 = "Muted",
			Parent = switchbackground 
		}) 
		local SwitchTitle = Utility:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = "Muted",
			TextStrokeTransparency = 0,
			Name = "SwitchTitle",
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 38, 0, 0),
			BorderSizePixel = 0,
			TextSize = 12,
			Parent = SwitchContainer 
		}) 
		return SwitchContainer
	end,
	SliderContainer = function()
		local SliderContainer = Utility:Render("TextButton", {  
			BackgroundTransparency = 1,
			Text = "",
			Name = "SliderContainer",
			Size = UDim2.new(1, 0, 0, 28),
			BorderSizePixel = 0,
		}) 
		local SliderBackground = Utility:Render("Frame", {  
			AnchorPoint = Vector2.new(0, 1),
			Name = "SliderBackground",
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 8),
			Active = true,
			BorderSizePixel = 0,
			BackgroundColor3 = "DarkContrastBackground",
			Parent = SliderContainer 
		}) 
		local UIStroke = Utility:Render("UIStroke", {  
			Color = "BorderInner",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = SliderBackground 
		}) 
		local UIStroke = Utility:Render("UIStroke", {  
			Parent = SliderBackground,
			Color = "BorderOuter"
		}) 
		local SliderScale = Utility:Render("Frame", {  
			Name = "SliderScale",
			Size = UDim2.new(0.5, 0, 1, 0),
			BorderSizePixel = 0,
			Active = true,
			BackgroundColor3 = "Accent",
			Parent = SliderBackground 
		}) 
		local SliderDot = Utility:Render("Frame", {  
			AnchorPoint = Vector2.new(1, 0.5),
			Position = UDim2.new(1, 0, 0.5, 0),
			Size = UDim2.new(0, 8, 1, 0),
			BorderSizePixel = 0,
			Active = true,
			Name = "SliderDot",
			Parent = SliderScale 
		}) 
		SliderDot.BackgroundColor3 = color3RGB(255,255,255)
		local UIGradient = Utility:Render("UIGradient", {  
			Color = ColorSequence.new{
				ColorSequenceKeypoint.new(0, color3RGB(20,20,20)),
				ColorSequenceKeypoint.new(1, color3RGB(255,255,255))
			},
			Transparency = NumberSequence.new{
				NumberSequenceKeypoint.new(0, 0.8374999761581421),
				NumberSequenceKeypoint.new(0.014, 0),
				NumberSequenceKeypoint.new(1, 0.006249964237213135)
			},
			Parent = SliderScale 
		}) 
		local SliderTitle = Utility:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = "Muted",
			Text = "Aim Sensetivity",
			TextStrokeTransparency = 0,
			Name = "SliderTitle",
			Size = UDim2.new(0, 200, 0, 14),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			Parent = SliderContainer 
		}) 
		local SlidervalueText = Utility:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextStrokeTransparency = 0,
			AnchorPoint = Vector2.new(1, 0),
			TextTruncate = Enum.TextTruncate.SplitWord,
			TextSize = 12,
			Size = UDim2.new(0, 55, 0, 14),
			TextColor3 = "Muted",
			Name = "SlidervalueText",
			TextWrapped = true,
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Right,
			Position = UDim2.new(1, 0, 0, 0),
			TextYAlignment = Enum.TextYAlignment.Top,
			BorderSizePixel = 0,
			Parent = SliderContainer 
		}) 


		return SliderContainer
	end,

	DropdownContainer = function()

		local DropdownContainer = Utility:Render("TextButton", {  
			BackgroundTransparency = 1,
			Text = "",
			AutomaticSize = Enum.AutomaticSize.Y,
			Name = "DropdownContainer",
			Size = UDim2.new(1, 0, 0, 40),
			BorderSizePixel = 0,
		}) 
		local DropdownBox = Utility:Render("Frame", {  
			AnchorPoint = Vector2.new(0, 1),
			Name = "DropdownBox",
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 20),
			BorderSizePixel = 0,
			BackgroundColor3 = "DarkContrastBackground",
			Parent = DropdownContainer 
		}) 
		local InnerStroke = Utility:Render("UIStroke", {  
			Color = "BorderInner",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = DropdownBox 
		}) 
		local OuterStroke = Utility:Render("UIStroke", {  
			Parent = DropdownBox,
			Color = "BorderOuter"
		}) 
		local DropdownValueText = Utility:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = "Muted",
			TextStrokeTransparency = 0,
			Name = "DropdownValueText",
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundTransparency = 1,
			TextTruncate = Enum.TextTruncate.AtEnd,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 8, 0, 0),
			BorderSizePixel = 0,
			TextSize = 12,
			Parent = DropdownBox 
		}) 
		local Anticlick = Utility:Render("TextButton", {  
			Visible = false,
			FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal),
			Text = "",
			Name = "Anticlick",
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			BackgroundTransparency = 1,
			Position = UDim2.new(0, 0, 1, 0),
			Size = UDim2.new(1, 0, 0, 0),
			ZIndex = 2,
			TextSize = 14,
			Parent = DropdownBox 
		}) 
		local ListContainer = Utility:Render("Frame", {  
			Name = "ListContainer",
			Active = true,
			AutomaticSize = Enum.AutomaticSize.Y,
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 1, 0),
			ZIndex = 2,
			BackgroundColor3 = "DarkContrastBackground",
			Parent = Anticlick 
		}) 
		local UIStroke = Utility:Render("UIStroke", {  
			Color = "BorderInner",
			BorderStrokePosition = Enum.BorderStrokePosition.Inner,
			Parent = ListContainer 
		}) 
		local UIStroke = Utility:Render("UIStroke", {  
			Color = "BorderOuter",
			BorderStrokePosition = Enum.BorderStrokePosition.Outer,
			Parent = ListContainer 
		}) 
		local UIListLayout = Utility:Render("UIListLayout", {  
			SortOrder = Enum.SortOrder.LayoutOrder,
			Parent = ListContainer 
		}) 
		local UIPadding = Utility:Render("UIPadding", {  
			PaddingTop = UDim.new(0, 6),
			PaddingBottom = UDimnew(0,6),
			Parent = ListContainer 
		}) 
		local DropdownArrow = Utility:Render("ImageLabel", {  
			ImageColor3 = "Muted",
			BorderColor3 = "BorderOuter",
			Name = "DropdownArrow",
			AnchorPoint = Vector2.new(1, 0.5),
			Image = "rbxassetid://113229176886493",
			BackgroundTransparency = 1,
			Position = UDim2.new(1, -8, 0.5, 0),
			Size = UDim2.new(0, 16, 0, 16),
			BorderSizePixel = 0,
			Parent = DropdownBox 
		}) 
		local DropdownTitle = Utility:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = "Muted",
			TextStrokeTransparency = 0,
			Name = "DropdownTitle",
			Size = UDim2.new(0, 200, 0, 14),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			BorderSizePixel = 0,
			TextYAlignment = Enum.TextYAlignment.Top,
			TextSize = 12,
			Parent = DropdownContainer 
		}) 
		return DropdownContainer

	end,
	OptionButton = function()
		local OptionFrame = Utility:Render("TextButton", {  
			Name = "OptionFrame",
			BackgroundTransparency = 1,
			Text = "",
			AutoButtonColor = false,
			BackgroundColor3 = "Accent",
			Size = UDim2.new(1, 0, 0, 16),
			ZIndex = 2,
			BorderSizePixel = 0,
		}) 
		local OptionText = Utility:Render("TextLabel", {  
			FontFace = Font.new("rbxassetid://12187372847", Enum.FontWeight.Medium, Enum.FontStyle.Normal),
			TextColor3 = "Muted",
			Name = "OptionText",
			TextStrokeTransparency = 0,
			BorderSizePixel = 0,
			Size = UDim2.new(0, 200, 1, 0),
			BackgroundTransparency = 1,
			TextXAlignment = Enum.TextXAlignment.Left,
			Position = UDim2.new(0, 10, 0, 0),
			ZIndex = 2,
			TextSize = 12,
			Parent = OptionFrame 
		}) 
		local Indicator = Utility:Render("Frame", {  
			Name = "Indicator",
			BackgroundTransparency = 1,
			Size = UDim2.new(0, 2, 1, 0),
			ZIndex = 2,
			BorderSizePixel = 0,
			BackgroundColor3 = "Accent",
			Parent = OptionFrame 
		}) 
		return OptionFrame


	end,
},Library.RenderModules)
local Tabs = Library.Tabs;
local Sections = Library.sections;
--> this is so when initating and using the library functions, the elements get connected by index
Library.__index = Library
Tabs.__index = Library.Tabs
Sections.__index = Library.sections
function Library:Window(properties)
	properties = properties or {}
	local window = {
		Title = properties.Title or properties.title or "Qw hub",
		Opened = true,
		Library = self,
	}
	local NewWindow = self.RenderModules:Window()
	NewWindow.Parent =  game:GetService("CoreGui") and game.Players.LocalPlayer:WaitForChild("PlayerGui")
	NewWindow["Window"]["SideBar"]["InterfaceTitle"].Text = window.Title

	NewWindow["UIScale"].Scale = camera.ViewportSize.X /  1400	
	Utility:storeEvent(camera:GetPropertyChangedSignal('ViewportSize'),function()
		NewWindow["UIScale"].Scale = camera.ViewportSize.X /  1400
	end)
	function window:Abort()
		for i, v in ipairs(Library.Connections) do
			v:Disconnect()
		end
		NewWindow:Destroy()
		setmetatable(Library,nil)
	end

	window.MainFrame = NewWindow["Window"]
	return setmetatable(window,Library)
end
function Library:Page(properties)
	local properties = properties or {}
	local page = {
		Title = properties.Title or properties.title or "Tab",
		Image = properties.Image or properties.image or false,
		UseSubtabs = properties.SubPages or false,
		SubtabFrame = nil,
		Filled = properties.Filled or properties.filled or false,
		window = self,
		Pagescontainer = nil,
	}
	local NewTab = page.window.Library.RenderModules:TabButton()
	NewTab.Parent = page.window.MainFrame["SideBar"]["TabContainer"]
	NewTab["TabTitle"].Text = page.Title
	NewTab["TabIcon"].Image = typeof(page.Image) == "string" and page.Image or ""
	NewTab["TabIcon"].Visible = true or page.Image == false and false
	NewTab.Name = page.Title

	local PagesContainer = page.window.Library.RenderModules:PageContainer()
	PagesContainer.Parent = page.window.MainFrame["PageContentsContainer"]
	PagesContainer.Name = page.Title

	local NewPage = page.window.Library.RenderModules:PagemoduleContainer()
	NewPage.Parent = PagesContainer


	if page.Filled then 
		NewPage["Right"]:Destroy()
		page.Sides = {Left = NewPage["Left"]}
	end 

	if page.UseSubtabs then
		NewPage:Destroy()
		local SubtabContainer = page.window.RenderModules:SubtabContainer()
		SubtabContainer.Parent = PagesContainer
		page.Pagescontainer = PagesContainer
		page.subtabframe = SubtabContainer
		page.Page = PagesContainer["TabPage"]
	elseif not page.UseSubtabs and not page.Filled then 
		page.Sides = {Left = NewPage["Left"], Right = NewPage["Right"]}
	end

	if not page.UseSubtabs then 
		PagesContainer["TabPage"]:Destroy()

	end


	Utility:storeEvent(page.window.MainFrame["PageContentsContainer"]["PageContentLayout"]:GetPropertyChangedSignal("CurrentPage"),function()
		task.spawn(function()
			if page.window.MainFrame["PageContentsContainer"]["PageContentLayout"].CurrentPage.Name == page.Title then
				ts:Create(NewTab, Utility.TweenInfo, {BackgroundTransparency = 0.65 }):Play()
				ts:Create(NewTab["OuterStroke"],Utility.TweenInfo, {Transparency = 0}):Play()
				ts:Create(NewTab["InnerStroke"],Utility.TweenInfo, {Transparency = 0.55}):Play()
				ts:Create(NewTab["TabIcon"],Utility.TweenInfo, {ImageColor3 = Utility.Theme.Accent}):Play()
				ts:Create(NewTab["TabTitle"],Utility.TweenInfo, {TextColor3 = Utility.Theme.Text}):Play()

				Utility:UpdateObject(NewTab["TabTitle"], "TextColor3","Text")
				Utility:UpdateObject(NewTab["TabIcon"], "ImageColor3","Accent")
			else 
				ts:Create(NewTab,Utility.TweenInfo, {BackgroundTransparency = 1 }):Play()
				ts:Create(NewTab["OuterStroke"],Utility.TweenInfo, {Transparency = 1}):Play()
				ts:Create(NewTab["InnerStroke"],Utility.TweenInfo, {Transparency = 1}):Play()
				ts:Create(NewTab["TabIcon"],Utility.TweenInfo, {ImageColor3 = Utility.Theme.Muted}):Play()
				ts:Create(NewTab["TabTitle"],Utility.TweenInfo, {TextColor3 = Utility.Theme.Muted}):Play()

				Utility:UpdateObject(NewTab["TabTitle"], "TextColor3","Muted")
				Utility:UpdateObject(NewTab["TabIcon"], "ImageColor3","Muted")
			end
		end)
	end)
	Utility:storeEvent(NewTab.MouseButton1Down,function()
		page.window.MainFrame["PageContentsContainer"]["PageContentLayout"]:JumpTo(page.window.MainFrame["PageContentsContainer"][page.Title])
	end)

	return setmetatable(page, Library.Tabs)
end
function Tabs:SubPage(properties)
	local properties = properties or {}
	local subpage = {
		Selected = false,
		Title = properties.Title or properties.title or "SubTab",
		window = self.window,
		Filled = properties.Filled or properties.filled or false,
	}
	local NewSubtabButton = self.window.Library.RenderModules:SubtabButton()
	NewSubtabButton.Parent = self.subtabframe
	NewSubtabButton.Text = subpage.Title
	NewSubtabButton.Name = subpage.Title

	local NewPageModule = self.window.Library.RenderModules:PagemoduleContainer()
	NewPageModule.Parent = self.Page
	NewPageModule.Name = subpage.Title
	if subpage.Filled then 
		subpage.Sides = {Left= NewPageModule["Left"]}
	else 
		subpage.Sides = {Left= NewPageModule["Left"], Right = NewPageModule["Right"]}
	end 
	-- if you're planning to use UIPageLayout for switching pages, make sure to listen on "CurrentPage" instead of "Previous" and "Next" because they do not work for whats intended here
	Utility:storeEvent(self.Page["PageContentLayout"]:GetPropertyChangedSignal("CurrentPage"),function()
		task.spawn(function()
			if self.Page["PageContentLayout"].CurrentPage.Name == subpage.Title then 
				ts:Create(NewSubtabButton,Utility.TweenInfo, {TextColor3 = Utility.Theme.Text,BackgroundTransparency = 0.65}):Play()
				ts:Create(NewSubtabButton,Utility.TweenInfo, {BackgroundTransparency = 0.65}):Play()
				Utility:UpdateObject(NewSubtabButton, "TextColor3","Text")
			else 
				ts:Create(NewSubtabButton,Utility.TweenInfo, {TextColor3 = Utility.Theme.Muted,BackgroundTransparency = 1}):Play()
				Utility:UpdateObject(NewSubtabButton, "TextColor3","Muted")
			end
		end)
	end)

	Utility:storeEvent(NewSubtabButton.MouseButton1Down,function()
		self.Page["PageContentLayout"]:JumpTo(self.Page[subpage.Title])
	end)
	
	return setmetatable(subpage, Library.Tabs) 
end
function Tabs:Section(properties)
	local properties = properties or {}
	local Section = {
		Side = self.Filled and "Left" or properties.Side or properties.side or "Left",
		window = self.window,
		Title = properties.Title or properties.title or "Section",
		Container = nil,
	}
	local sectionFrame = Library.RenderModules:SectionFrame()
	sectionFrame.Parent = self.Sides[Section.Side]
	sectionFrame["ModuleContainer"]["SectionTitle"].Text = Section.Title

	Section.Container = sectionFrame["ModuleContainer"]
	return setmetatable(Section,Library.sections)
end

function Sections:Switch(properties)
	properties = properties or {}
	local Switch = {
		Title = properties.title or properties.Title or "Toggle",
		Value = properties.Value or properties.value or false,
		Flag = properties.Flag or properties.flag or nil,
		Callback = properties.Callback or properties.callback or function() end
	}
	local switchcontainer = Library.RenderModules:SwitchContainer()
	switchcontainer.Parent = self.Container
	switchcontainer["SwitchTitle"].Text = Switch.Title

	function Switch:Set(value: boolean)

		task.spawn(function()
			ts:Create(switchcontainer["SwitchTitle"],Utility.TweenInfo, {TextColor3 = value and Utility.Theme.Text or Utility.Theme.Muted}):Play()
			ts:Create(switchcontainer["switchbackground"]["switchslider"],Utility.TweenInfo, {Position = value and   UDim2new(0, 4,0.5,0) or UDim2new(1, -12,0.5,0), BackgroundColor3 = value and Utility.Theme.Accent or Utility.Theme.Muted}):Play()
			self.Value = value
			self.Callback(value)

		end)
	end
	Utility:storeEvent(switchcontainer.MouseButton1Down,function()

		Switch:Set(not Switch.Value)
	end)

	Switch:Set(Switch.Value)
end
function Sections:Slider(properties)
	properties = properties or {}
	local slider = {
		Title = properties.Title or properties.title or "Slider",
		Value = properties.Value or properties.value or 0,
		Maximum = properties.Max or properties.max or properties.Maximum or properties.maximum or 100,
		Minimum = properties.Min or properties.min or properties.Minimum or properties.minimum or 0,
		Increment = properties.Increment or properties.increment or 0.5,
		Callback = properties.Callback or properties.callback or function() end,
		Unit = properties.Unit or properties.unit or properties.Suffix or properties.suffix or "",
	}
	slider.Increment = 1 / slider.Increment
	local Slidercontainer = Library.RenderModules:SliderContainer()
	Slidercontainer.Parent = self.Container
	Slidercontainer["SliderTitle"].Text = slider.Title

	function slider:Set(val: number)

		Slidercontainer["SlidervalueText"].Text = tostring(val) .. self.Unit

		local Value = (((val - self.Minimum) * (self.Maximum - self.Minimum)) / (self.Maximum - self.Minimum)) + self.Minimum 
		local percent = 1 - (self.Maximum - val) / (self.Maximum- self.Minimum)
		ts:Create(Slidercontainer["SliderBackground"]["SliderScale"], Utility.TweenInfo, {Size = UDim2new(percent, 0, 1, 0)}):Play()
		self.Callback(Value)
	end

	function slider:Move()
		local BoundingFrame = math.clamp(Mouse.X - Slidercontainer["SliderBackground"]["SliderScale"].AbsolutePosition.X, 0, Slidercontainer["SliderBackground"].AbsoluteSize.X) / Slidercontainer["SliderBackground"].AbsoluteSize.X
		local Svalue = math.floor((self.Minimum + (self.Maximum - self.Minimum) * BoundingFrame) * self.Increment) / self.Increment
		Svalue = math.clamp(Svalue, self.Minimum, self.Maximum)
		self:Set(Svalue)

	end
	Utility:storeEvent(Slidercontainer.MouseButton1Down,function()

		while UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) do
			task.wait()
			slider:Move()
		end
	end)
	if slider.Value >= slider.Minimum and  slider.Value <= slider.Maximum then 

		slider:Set(slider.Value)
	else 
		slider:Set(slider.Minimum)
	end 
	return slider
end
function Sections:Combo(properties)
	properties = properties or {}
	local combo = {
		Title = properties.Title or properties.title or "Dropdown",
		List = properties.List or properties.list or {"Option 1", "Option 2"},
		Value = properties.Value or properties.value or self.List[1],
		Callback = properties.Callback or properties.callback or function() end,
		Opened = false,
	}
	local DropdownContainer = Library.RenderModules:DropdownContainer()
	DropdownContainer.Parent = self.Container
	DropdownContainer["DropdownTitle"].Text = combo.Title


	function combo:SetValue(value)
		if typeof(value) == "table" then 
			value = table.unpack(value) 
		end 
		
		if table.find(self.Value,value) then 
			table.remove(self.Value,table.find(self.Value, value))
		elseif not table.find(self.Value,value) then
			self.Value[#self.Value + 1] = value

		end
			DropdownContainer["DropdownBox"]["DropdownValueText"].Text =  table.concat(combo.Value, ", ")
			for _,Option in pairs(DropdownContainer["DropdownBox"]["Anticlick"]["ListContainer"]:GetChildren()) do 
			if  Option.Name == value and  table.find(self.Value,Option.Name)and Option:IsA("TextButton") then 
					task.spawn(function()
						ts:Create(Option, Utility.TweenInfo, {BackgroundTransparency = 0.6}):Play()
						ts:Create(Option["OptionText"], Utility.TweenInfo, {TextColor3 = Utility.Theme.Text, Position = UDim2new(0,13,0,0)}):Play()
						ts:Create(Option["Indicator"], Utility.TweenInfo, {BackgroundTransparency = 0}):Play()
						Utility:UpdateObject(Option["OptionText"],"TextColor3",Utility.Theme.Text)
					end)
			elseif  Option.Name == value and not table.find(self.Value,Option.Name) and Option:IsA("TextButton") then
					task.spawn(function()
						ts:Create(Option, Utility.TweenInfo, {BackgroundTransparency = 1}):Play()
						ts:Create(Option["OptionText"], Utility.TweenInfo, {TextColor3 = Utility.Theme.Muted, Position = UDim2new(0,10,0,0)}):Play()
						ts:Create(Option["Indicator"], Utility.TweenInfo, {BackgroundTransparency = 1}):Play()
						Utility:UpdateObject(Option["OptionText"],"TextColor3",Utility.Theme.Muted)
					end)

				
			end
		end
		combo.Callback(combo.Value)

	end
	function combo:AddOption(NewOption)
		if typeof(NewOption) == "table" then 
			NewOption = table.unpack(NewOption) 
		end 
		if not table.find(self.List,NewOption) then 
			table.insert(self.List, NewOption)
		end
		local NewOptionButton = Library.RenderModules:OptionButton()
		NewOptionButton.Parent = DropdownContainer["DropdownBox"]["Anticlick"]["ListContainer"]
		NewOptionButton["OptionText"].Text = tostring(NewOption)
		NewOptionButton.Name = tostring(NewOption)
		Utility:storeEvent(NewOptionButton.MouseButton1Click,function()
			combo:SetValue(NewOptionButton.Name)

		end)
	end

	function combo:ToggleListContainer(bool: boolean)
		task.spawn(function()
			ts:Create(DropdownContainer["DropdownTitle"], Utility.TweenInfo, {TextColor3 = bool and Utility.Theme.Text or Utility.Theme.Muted }):Play()
			Utility:UpdateObject(DropdownContainer["DropdownTitle"],"TextColor3",bool and Utility.Theme.Text or Utility.Theme.Muted)
			DropdownContainer["DropdownBox"]["Anticlick"].Visible = bool
			self.Opened = bool

		end)
	end
	Utility:storeEvent(DropdownContainer.MouseButton1Down,function()
		combo:ToggleListContainer(not combo.Opened)
	end)
	for _,option in pairs(combo.List) do
		combo:AddOption(option)
	end
		combo:SetValue(combo.Value)
	
	return combo
end

function Sections:Dropdown(properties)
	properties = properties or {}
	local dropdown = {
		Title = properties.Title or properties.title or "Dropdown",
		List = properties.List or properties.list or {"Option 1", "Option 2"},
		Value = properties.Value or properties.value or "",
		Callback = properties.Callback or properties.callback or function() end,
		Opened = false,
	}
	local DropdownContainer = Library.RenderModules:DropdownContainer()
	DropdownContainer.Parent = self.Container
	DropdownContainer["DropdownTitle"].Text = dropdown.Title


	function dropdown:SetValue(value: string)
		DropdownContainer["DropdownBox"]["DropdownValueText"].Text = value
		dropdown.Callback(value)

		for _,Option in pairs(DropdownContainer["DropdownBox"]["Anticlick"]["ListContainer"]:GetChildren()) do 
			if Option.Name == tostring(value) and Option:IsA("TextButton") then 
				task.spawn(function()
					dropdown.Value = value
					ts:Create(Option, Utility.TweenInfo, {BackgroundTransparency = 0.6}):Play()
					ts:Create(Option["OptionText"], Utility.TweenInfo, {TextColor3 = Utility.Theme.Text, Position = UDim2new(0,13,0,0)}):Play()
					ts:Create(Option["Indicator"], Utility.TweenInfo, {BackgroundTransparency = 0}):Play()
					Utility:UpdateObject(Option["OptionText"],"TextColor3",Utility.Theme.Text)
				end)
			elseif Option.Name ~= tostring(value) and Option:IsA("TextButton") then
				task.spawn(function()
					ts:Create(Option, Utility.TweenInfo, {BackgroundTransparency = 1}):Play()
					ts:Create(Option["OptionText"], Utility.TweenInfo, {TextColor3 = Utility.Theme.Muted, Position = UDim2new(0,10,0,0)}):Play()
					ts:Create(Option["Indicator"], Utility.TweenInfo, {BackgroundTransparency = 1}):Play()
					Utility:UpdateObject(Option["OptionText"],"TextColor3",Utility.Theme.Muted)
				end)

			end
		end


	end
	function dropdown:AddOption(NewOption: string)
		if typeof(NewOption) == "table" then 
			NewOption = table.unpack(NewOption) 
		end 
		if not table.find(self.List,NewOption) then 
			table.insert(self.List, NewOption)
		end
		local NewOptionButton = Library.RenderModules:OptionButton()
		NewOptionButton.Parent = DropdownContainer["DropdownBox"]["Anticlick"]["ListContainer"]
		NewOptionButton["OptionText"].Text = tostring(NewOption)
		NewOptionButton.Name = tostring(NewOption)
		Utility:storeEvent(NewOptionButton.MouseButton1Click,function()
			dropdown:SetValue(NewOptionButton.Name)

		end)
	end

	function dropdown:ToggleListContainer(bool: boolean)
		task.spawn(function()
			ts:Create(DropdownContainer["DropdownTitle"], Utility.TweenInfo, {TextColor3 = bool and Utility.Theme.Text or Utility.Theme.Muted }):Play()
			Utility:UpdateObject(DropdownContainer["DropdownTitle"],"TextColor3",bool and Utility.Theme.Text or Utility.Theme.Muted)
			DropdownContainer["DropdownBox"]["Anticlick"].Visible = bool
			dropdown.Opened = bool

		end)
	end
	Utility:storeEvent(DropdownContainer.MouseButton1Down,function()
		dropdown:ToggleListContainer(not dropdown.Opened)
	end)
	for i,option in pairs(dropdown.List) do
		dropdown:AddOption(option)
	end
	dropdown:SetValue(dropdown.Value)
	return dropdown
end

return Library
