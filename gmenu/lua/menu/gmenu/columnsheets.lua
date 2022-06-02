--[[
    Original: DColumnSheet
    https://github.com/Facepunch/garrysmod/blob/master/garrysmod/lua/vgui/dcolumnsheet.lua
]]--

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
			self.Menu.Clock:DockMargin(5, 5, 5, 5)
		end

		self.Menu.Clock.Paint = function(panel, w, h)
			draw.RoundedBox(self.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
			
			draw.SimpleText(panel.Time, "gmenu.16B", w/2, h/2, gmenu_text, 1, 1)
		end

		self.Menu.Clock.Think = function(self)
			self.Time = os.date("%H:%M:%S", os.time())
		end
	end

	self.Content = self:Add("Panel")
	self.Content:Dock( FILL )

	if self.HasOffset then
		self.Content:DockMargin(10, 10, 10, 0)
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

	self.Menu.Search = self.Menu:Add("DTextEntry")
    self.Menu.Search:Dock(TOP)
	self.Menu.Search:DockMargin(0, 0, 0, 10)
    self.Menu.Search:SetFont("gmenu.16")
    self.Menu.Search:SetTextColor(gmenu_text)
    self.Menu.Search:SetTall(30)
    self.Menu.Search:SetDrawLanguageID(false)
    self.Menu.Search:SetPlaceholderText(language.GetPhrase("searchbar_placeholer"))
    self.Menu.Search.Paint = function(panel, w, h)
        if ( panel.m_bBackground ) then
            draw.RoundedBox(gmenu.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
        end

        if ( panel.GetPlaceholderText && panel.GetPlaceholderColor && panel:GetPlaceholderText() && panel:GetPlaceholderText():Trim() != "" && panel:GetPlaceholderColor() && ( !panel:GetText() || panel:GetText() == "" ) ) then
            local oldText = panel:GetText()

            local str = panel:GetPlaceholderText()
            if ( str:StartWith( "#" ) ) then str = str:sub( 2 ) end
            str = language.GetPhrase( str )

            panel:SetText( str )
            panel:DrawTextEntryText( panel:GetPlaceholderColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
            panel:SetText( oldText )
            return
        end
        panel:DrawTextEntryText( panel:GetTextColor(), panel:GetHighlightColor(), panel:GetCursorColor() )
    end

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
