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

	self.Menu.Gamemode = self.Menu:Add("DButton")
	self.Menu.Gamemode:Dock(RIGHT)
	self.Menu.Gamemode:SetWide(40)
	self.Menu.Gamemode:SetText("")
	--self.Menu.Gamemode:SetTooltip(engine.GetNiceGamemode(engine.ActiveGamemode())) -- TODO: Fix it
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
	
	local mat = Material("gmenu/gamemodes.png")
	
	self.Menu.Gamemode.Paint = function(panel, w, h)
		draw.RoundedBox(self.HasOffset and gmenu_round or 0, 0, 0, w, h, panel:IsHovered() and gmenu_trit or gmenu_sec)

		surface.SetDrawColor(gmenu_text)
		surface.SetMaterial(mat)
		surface.DrawTexturedRect(w/2-8, h/2-8, 16, 16)
	end

	--
	
	self.Menu.Language = self.Menu:Add("DButton")
	self.Menu.Language:Dock(RIGHT)
	self.Menu.Language:SetWide(40)
	self.Menu.Language:SetText("")
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
	
	self.Menu.Language.Icon = Material(GetLanguageIcon(engine.GetLanguages()[GetConVarString( "gmod_language" )])) or Material("gmenu/language.png")
	
	self.Menu.Language.Paint = function(panel, w, h)
		draw.RoundedBox(self.HasOffset and gmenu_round or 0, 0, 0, w, h, panel:IsHovered() and gmenu_trit or gmenu_sec)

		surface.SetDrawColor(gmenu_text)
		surface.SetMaterial(panel.Icon)
		surface.DrawTexturedRect(w/2-8, h/2-8, 16, 16)
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

	Sheet.Button = self.Menu:Add("DButton")
	Sheet.Button:SetText("")
	Sheet.Button:Dock(LEFT)
	Sheet.Button:SetWide(40)

	if self.HasOffset then
		Sheet.Button:SetWide(30)
		Sheet.Button:DockMargin(5, 5, 0, 5)
	end

	Sheet.Button.Paint = function(panel, w, h)
		draw.RoundedBox(self.HasOffset and gmenu_round or 0, 0, 0, w, h, panel:IsHovered() and gmenu_trit or gmenu_sec)

		surface.SetDrawColor(gmenu_text)
		surface.SetMaterial(icon)
		surface.DrawTexturedRect(w/2-8, h/2-8, 16, 16)
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

	if ( self.ActiveButton == active ) then
		self.ActiveButton.Target:SetVisible(not self.ActiveButton.Target:IsVisible())

		return
	end

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

derma.DefineControl("gmenu.ColumnSheet", "", panel, "Panel")

-- Categories

local panel = {}

AccessorFunc( panel, "ActiveButton", "ActiveButton" )

function panel:Init()
	self.HasOffset = gmenu.Config.HasOffset

	self.Menu = self:Add("Panel")
	self.Menu:Dock(LEFT)
	self.Menu:SetWide(200)

	self.Menu.Search = gmenu.gui:TextEntry(self.Menu, language.GetPhrase("searchbar_placeholer"))
    self.Menu.Search:Dock(TOP)
	self.Menu.Search:DockMargin(0, 0, 0, 10)

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

	self.Menu.Buttons = self.Menu:Add("DScrollPanel")
	self.Menu.Buttons:Dock(FILL)
	self.Menu.Buttons:GetVBar():SetWide(0)

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

	Sheet.Button = self.Menu.Buttons:Add("DButton")
	Sheet.Button:SetText(label)
	Sheet.Button:SetFont("gmenu.16")
	Sheet.Button:SetTextColor(gmenu_text)
	Sheet.Button:Dock(TOP)
	Sheet.Button:SetTall(30)
	Sheet.Button:DockMargin(0, 0, 0, 5)

	Sheet.Button.Paint = function(panel, w, h)
		draw.RoundedBox(self.HasOffset and gmenu_round or 0, 0, 0, w, h, panel:IsHovered() and gmenu_trit or gmenu_sec)
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
