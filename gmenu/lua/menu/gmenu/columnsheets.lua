--[[
    Original: DColumnSheet
    https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/dcolumnsheet.lua
]]--

-- Да, я знаю что это очень странный метод для создания такой менюшки...

local panel = {}

AccessorFunc( panel, "ActiveButton", "ActiveButton" )

function panel:Init()
	self.HasOffset = gmenu.Config.HasOffset

	self.Menu = self:Add("Panel")
	self.Menu:Dock(BOTTOM)
	self.Menu:SetTall(40)
	self.Menu.ClockEnabled = gmenu.Config.ClockEnabled
	
	if self.HasOffset then
		self.Menu:DockMargin(10, 10, 10, 10)
	end

	self.Menu.Paint = function(_, w, h)
		draw.RoundedBox(self.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_prim)
	end

	if self.Menu.ClockEnabled then
		self.Menu.Clock = self.Menu:Add("Panel")
		self.Menu.Clock:Dock(RIGHT)
		self.Menu.Clock:SetWide(100)
		
		if self.HasOffset then
			self.Menu.Clock:DockMargin(0, 5, 5, 5)
		end

		self.Menu.Clock.Paint = function(panel, w, h)
			draw.RoundedBox(self.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
			
			draw.SimpleText(panel.Time, "gmenu.16B", w/2, h/2, gmenu_text, 1, 1)
		end

		self.Menu.Clock.Think = function(self)
			self.Time = os.date("%H:%M:%S", os.time())
		end
	end

	self.Menu.Gamemode = gmenu.gui:Button(self.Menu)
	self.Menu.Gamemode:Dock(RIGHT)
	self.Menu.Gamemode:SetWide(40)
	self.Menu.Gamemode:SetColorStyle(gmenu_sec, gmenu_trit)
	self.Menu.Gamemode:SetIcon(Material("gmenu/gamemodes.png"), 16, 16)
	self.Menu.Gamemode.DoClick = function(self)
		local dmenu = gmenu.gui:DMenu()
		dmenu:SetMaxHeight(ScrW()*0.8)
		
		for k, v in ipairs(engine.GetGamemodes()) do
			if v.name == "base" then continue end

			dmenu:AddOption(v.title, function()
				self:SetTooltip(v.title)
				RunConsoleCommand("gamemode", v.name)
			end)
		end

		dmenu:Open()
	end

	--

	self.Menu.Language = gmenu.gui:Button(self.Menu)
	self.Menu.Language:Dock(RIGHT)
	self.Menu.Language:SetWide(40)
	self.Menu.Language:SetColorStyle(gmenu_sec, gmenu_trit)
	self.Menu.Language:SetIcon(Material(GetLanguageIcon(engine.GetLanguages()[GetConVarString( "gmod_language" )])) or Material("gmenu/language.png"), 16, 11)
	self.Menu.Language.DoClick = function(self)
		local dmenu = gmenu.gui:DMenu() --DermaMenu()
		dmenu:SetMaxHeight(ScrW()*0.8)
		
		for k, v in pairs(engine.GetLanguages()) do
			dmenu:AddOption(k, function()
				RunConsoleCommand("gmod_language", k)
				self.Icon = Material(GetLanguageIcon(v))
			end):SetIcon(GetLanguageIcon(v))
		end

		dmenu:Open()
	end

	--

	self.Content = self:Add("Panel")
	self.Content:Dock( FILL )

	if self.HasOffset then
		self.Content:DockMargin(10, 10, 10, 0)

		self.Menu.Gamemode:SetWide(30)
		self.Menu.Gamemode:DockMargin(0, 5, 5, 5)

		self.Menu.Language:SetWide(30)
		self.Menu.Language:DockMargin(0, 5, 5, 5)
	end

	self.Items = {}
end

function panel:AddTab(icon, panel)
	local Sheet = {}

	Sheet.Button = gmenu.gui:Button(self.Menu)
	Sheet.Button:SetColorStyle(gmenu_sec, gmenu_trit)
	Sheet.Button:SetIcon(icon, 16, 16)
	Sheet.Button:Dock(LEFT)
	Sheet.Button:SetWide(40)

	if self.HasOffset then
		Sheet.Button:SetWide(30)
		Sheet.Button:DockMargin(5, 5, 0, 5)
	end

	Sheet.Button.DoClick = function()
		if ispanel(panel) then
			self:SetActiveButton( Sheet.Button )
		else
			panel()
		end
	end

	if ispanel(panel) then
		Sheet.Button.Target = panel
		Sheet.Panel = panel
		Sheet.Panel:SetParent( self.Content )
		Sheet.Panel:SetVisible( false )
	end

	table.insert( self.Items, Sheet )
	
	return Sheet
end

function panel:SetActiveButton( active )
	if self.ActiveButton == active then
		self.ActiveButton.Target:SetVisible(not self.ActiveButton.Target:IsVisible())
		return
	end

	if self.ActiveButton && self.ActiveButton.Target then
		self.ActiveButton.Target:SetVisible( false )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active:SetSelected( true )
	active:SetToggle( true )

	self.Content:InvalidateLayout()
end

derma.DefineControl("gmenu.ColumnSheet", "", panel, "Panel")

-- Categories

local panel = {}

AccessorFunc( panel, "ActiveButton", "ActiveButton" )

function panel:Init()
	self.HasOffset = gmenu.Config.HasOffset

	self.Menu = self:Add("Panel")
	self.Menu:Dock(LEFT)
	self.Menu:SetWide(200)

	self.Menu.SearchPan, self.Menu.Search = gmenu.gui:TextEntry(self.Menu, language.GetPhrase("searchbar_placeholer"))
    self.Menu.SearchPan:SetColor(gmenu_trit)
	self.Menu.SearchPan:Dock(TOP)
	self.Menu.SearchPan:DockMargin(0, 0, 0, 10)
	self.Menu.SearchPan:SetTall(30)

	self.Menu.Search.OnEnter = function(panel, value)
		for k, v in ipairs(self.Items) do
			v.Button:Remove()
		end

		for k, v in ipairs(self.NotSearchItems) do
			if string.find(v.l, value) then
				self:AddTab(v.l, v.p, false)
			end
		end
	end

	self.Menu.Buttons = gmenu.gui:ScrollPanel(self.Menu)
	self.Menu.Buttons:Dock(FILL)

	self.Content = self:Add("Panel")
	self.Content:Dock( FILL )

	if self.HasOffset then
		self.Menu:DockMargin(10, 10, 0, 10)
		self.Content:DockMargin(10, 10, 10, 10)
	end

	self.Items = {}
	self.NotSearchItems = {}
end

function panel:AddTab(label, panel, insert)
	local insert = insert == nil and true or insert
	local Sheet = {}

	Sheet.Button = gmenu.gui:Button(self.Menu.Buttons, label)
	Sheet.Button:Dock(TOP)
	Sheet.Button:SetTall(30)
	Sheet.Button:DockMargin(0, 0, 0, 5)
	Sheet.Button:SetColorStyle(gmenu_sec, gmenu_trit)

	Sheet.Button.DoClick = function()
		if ispanel(panel) then
			self:SetActiveButton( Sheet.Button )
		else
			panel()
		end
	end

	if ispanel(panel) then
		Sheet.Button.Target = panel
		Sheet.Panel = panel
		Sheet.Panel:SetParent( self.Content )
		Sheet.Panel:SetVisible( false )
		
		if !IsValid( self.ActiveButton ) then
			self:SetActiveButton( Sheet.Button )
		end
	end

	table.insert( self.Items, Sheet )

	if insert then
		table.insert( self.NotSearchItems, {l = label, p = panel})
	end

	return Sheet
end

function panel:SetActiveButton( active )

	if ( self.ActiveButton == active ) then return end

	if ( self.ActiveButton && self.ActiveButton.Target ) then
		self.ActiveButton.Target:SetVisible( false )
		self.ActiveButton:SetSelected( false )
		self.ActiveButton:SetToggle( false )
	end

	self.ActiveButton = active
	active.Target:SetVisible( true )
	active:SetSelected( true )
	active:SetToggle( true )

	self.Content:InvalidateLayout()

end

derma.DefineControl("gmenu.ColumnSheetCats", "", panel, "Panel")
