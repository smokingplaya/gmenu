include( "background.lua" )
include( "cef_credits.lua" )
include( "openurl.lua" )
include( "ugcpublish.lua" )

pnlMainMenu = nil

local PANEL = {}

function PANEL:Init()
	self:Dock( FILL )
	self:SetKeyboardInputEnabled( true )
	self:SetMouseInputEnabled( true )

	self.Menu = self:Add("gmenu.ColumnSheet")
	self.Menu:Dock(FILL)

	for k, v in ipairs(gmenu.MenuTabs) do
		self.Menu:AddTab(v.icon, v.panel)
	end

	self.Menu:AddTab(Material("gmenu/terminal.png"), function()
		gui.ShowConsole()
	end)

	self.Menu:AddTab(Material("gmenu/settings.png"), function()
		RunGameUICommand("OpenOptionsDialog")
	end)

	self.Menu:AddTab(Material("gmenu/quit.png"), function()
		RunGameUICommand("Quit")
	end)

	self:MakePopup()
	self:SetPopupStayAtBack( true )

	if ( gui.IsConsoleVisible() ) then
		gui.ShowConsole()
	end
end

function PANEL:Call()
end

function PANEL:Notification(text, time)
	if self.NotifyPan then
		self.NotifyPan:Remove()
	end

	surface.SetFont("gmenu.18")
	local w = surface.GetTextSize(text)
	local width = w+20

	local panel = self:Add("DPanel")
	self.NotifyPan = panel
	panel:SetSize(width, 28)
	panel:SetPos(-width-10, 10)
	panel:MoveTo(10, 10, 0.3, 0, -1)
	panel.Paint = function(self, w, h)
		draw.RoundedBox(gmenu_round, 0, 0, w, h, gmenu_prim)
		draw.SimpleText(text, "gmenu.18", w/2, h/2, gmenu_text, 1, 1)
	end
	
	timer.Simple(time or 2, function()
		if IsValid(panel) then
			panel:AlphaTo(0, 0.3, 0, function()
				panel:Remove()
				self.NotifyPan = nil
			end)
		end
	end)
end

function PANEL:ScreenshotScan( folder )
	local bReturn = false

	local Screenshots = file.Find( folder .. "*.*", "GAME" )
	for k, v in RandomPairs( Screenshots ) do

		AddBackgroundImage( folder .. v )
		bReturn = true

	end

	return bReturn
end

function PANEL:Paint()
	DrawBackground()

	if ( !self.IsInGame ) then return end

	local canAdd = CanAddServerToFavorites()
	local isFav = serverlist.IsCurrentServerFavorite()
	if ( self.CanAddServerToFavorites != canAdd || self.IsCurrentServerFavorite != isFav ) then
		self.CanAddServerToFavorites = canAdd
		self.IsCurrentServerFavorite = isFav
	end
end

function PANEL:RefreshContent()
	self:RefreshGamemodes()
end

function PANEL:RefreshGamemodes()
	local json = util.TableToJSON( engine.GetGamemodes() )

	self:UpdateBackgroundImages()
end

function PANEL:UpdateBackgroundImages()

	ClearBackgroundImages()

	if ( !self:ScreenshotScan( "gamemodes/" .. engine.ActiveGamemode() .. "/backgrounds/" ) ) then
		self:ScreenshotScan( "backgrounds/" )
	end

	ChangeBackground( engine.ActiveGamemode() )

end

vgui.Register( "MainMenuPanel", PANEL, "EditablePanel" )

--[[ gMenu: Other ]]--

local iconLanguageTable = {}

local function fixLangTable(tab)
	for k, v in ipairs(tab) do
		iconLanguageTable[string.Left(v, 2)] = v
	end

	return iconLanguageTable
end

function UpdateLanguages()
	local f = file.Find( "resource/localization/*.png", "MOD" )
	local json = util.TableToJSON( f )
	
	return fixLangTable(f)
end

function GetLanguageIcon(str, material)
	local str = "resource/localization/" .. str
	return material and Material(str) or str
end

function engine.GetLanguages()
	return iconLanguageTable
end

hook.Add( "GameContentChanged", "RefreshMainMenu", function()
	if not IsValid(pnlMainMenu) then return end

	pnlMainMenu:RefreshContent()
end)

hook.Add( "LoadGModSaveFailed", "LoadGModSaveFailed", function( str, wsid )
	local button2 = nil
	if ( wsid && wsid:len() > 0 ) then button2 = "Open map on Steam Workshop" end

	Derma_Query( str, "Failed to load save!", "OK", nil, button2, function() steamworks.ViewFile( wsid ) end )
end )

--
-- Initialize
--
timer.Simple(0, function()
	UpdateLanguages()
	pnlMainMenu = vgui.Create( "MainMenuPanel" )

	local language = GetConVarString( "gmod_language" )

	hook.Run( "GameContentChanged" )

	timer.Simple(0, function()
		if file.Exists("gmenu/gmenu.txt", "DATA") then return end
		
		local welcomeFrame = vgui.Create("DFrame")
		welcomeFrame.SysTime = SysTime()
		welcomeFrame:SetAlpha(0)
		welcomeFrame:AlphaTo(255, 0.3, 0)
		welcomeFrame:SetSize(ScrW()*0.6, ScrH()*0.6)
		welcomeFrame:Center()
		welcomeFrame:SetTitle("")
		welcomeFrame:ShowCloseButton(false)
		welcomeFrame:MakePopup()
		welcomeFrame.Paint = function(self, w, h)
			Derma_DrawBackgroundBlur(self, self.SysTime)
			draw.RoundedBox(gmenu.Config.HasOffset and gmenu.Config.Rounding or 0, 0, 0, w, h, gmenu_prim)
		end

		local ho = gmenu.Config.HasOffset

		welcomeFrame.closeBtn = gmenu.gui:Button(welcomeFrame)
		welcomeFrame.closeBtn:SetSize(32, 32)
		local x, y = ho and welcomeFrame:GetWide()-32-12 or welcomeFrame:GetWide()-32, ho and 12 or 0
		welcomeFrame.closeBtn:SetPos(x, y)
		welcomeFrame.closeBtn:SetIcon(Material("gmenu/close.png"), 16, 16)
		welcomeFrame.closeBtn:SetColorStyle(gmenu_sec, gmenu_trit)

		welcomeFrame.closeBtn.DoClick = function()
			welcomeFrame:AlphaTo(0, 0.3, 0, function()
				welcomeFrame:Remove()
			end)

			file.CreateDir("gmenu")
			file.Append("gmenu/gmenu.txt", "by johngetman<3")

			pnlMainMenu:Notification("Thanks for installing gMenu, enjoy your use!", 3)
		end

		welcomeFrame.Content = welcomeFrame:Add("Panel")
		welcomeFrame.Content:Dock(FILL)
		welcomeFrame.Content.Paint = function(self, w, h)
			draw.SimpleText("gMenu", "gmenu.24B", w/2, h/2-35, gmenu_text, 1)
			draw.SimpleText("A powerful solution for comfortable gaming.", "gmenu.18", w/2, h/2-10, gmenu_text, 1)
		end

		welcomeFrame.Content.Bottom = welcomeFrame.Content:Add("Panel")
		welcomeFrame.Content.Bottom:Dock(BOTTOM)
		welcomeFrame.Content.Bottom:SetTall(35)

		local buttons = {
			["gMenu Github Repo"] = "https://github.com/johngetman/gmenu"
		}

		local createdButtons = {}
		for k, v in pairs(buttons) do
			local button = gmenu.gui:Button(welcomeFrame.Content.Bottom, k, "18B")
			button:Dock(LEFT)
			button:SetColorStyle(gmenu_sec, gmenu_trit)

			button.DoClick = function()
				gui.OpenURL(v)	
			end

			table.insert(createdButtons, button)
		end

		welcomeFrame.Content.Bottom.PerformLayout = function(self, w)
			for k, v in ipairs(createdButtons) do
				local wide = math.Round(w/table.Count(createdButtons))
	
				v:SetWide(wide)
			end
		end

		if ho then
			welcomeFrame.Content:DockMargin(0, 20, 0, 0)
		end
	end)
end)
