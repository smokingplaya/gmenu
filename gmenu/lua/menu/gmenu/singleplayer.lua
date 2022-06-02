function gmenu:GetSingleplayer()
    local panel = self:GetBasePanel()
    local columnsheet = panel:Add("gmenu.ColumnSheetCats")
    columnsheet:Dock(FILL)

    local loadmain = function()
        local maps = GetMapList()
        local hostname, p2pEN, p2pFO, lan, maxplayers, mapname = "Garry's Mod", true, false, false, 0, nil
        for k, v in pairs(maps) do
            local pan = vgui.Create("Panel")
            pan:Dock(FILL)
            pan.Paint = function(panel, w, h)
                draw.RoundedBox(self.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
            end

            -- maps list
            local mapList = pan:Add("DIconLayout") -- TODO: MAKE SCROLL
            mapList:Dock(FILL)
            mapList.Summ = 240+200

            if self.Config.HasOffset then
                mapList:SetSpaceX(10)
                mapList:SetSpaceY(10)
                mapList:DockMargin(5, 5, 5, 5)
            end

            local loadMap = function()
                if mapname == nil then return end

                if maxplayers > 0 then
                    RunConsoleCommand("sv_cheats", "0")
                    RunConsoleCommand("commentary", "0")
                end

                hook.Run("StartGame")

                RunConsoleCommand("progress_enable")
                RunConsoleCommand("disconnect")
                RunConsoleCommand("hostname", hostname)
                RunConsoleCommand("p2p_enabled", p2pEN)
                RunConsoleCommand("p2p_friendsonly", p2pFO)
                RunConsoleCommand("sv_lan", lan)
                RunConsoleCommand("maxplayers", maxplayers)
                RunConsoleCommand("map", mapname)
            end

            for _, map in ipairs(v) do
                local mapPanel = mapList:Add("DButton")
                mapPanel:SetText("")
                mapPanel.Size = 128 --(ScrW()-mapList.Summ)/6 
                mapPanel:SetSize(mapPanel.Size, mapPanel.Size+24)
                local m = Material("maps/thumb/".. map ..".png")
                mapPanel.mat, mapPanel.matgrad = m:IsError() and Material("gmenu/mapnothumb.png") or m, Material("vgui/gradient_up")
                
                mapPanel.DoClick = function()
                    mapname = map    
                end

                mapPanel.DoDoubleClick = function()
                    loadMap()
                end

                mapPanel.Paint = function(panel, w, h)
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(panel.mat)
                    surface.DrawTexturedRect(0, 0, w, h-24)

                    surface.SetDrawColor(color_black)
                    surface.SetMaterial(panel.matgrad)
                    surface.DrawTexturedRect(0, 16, w, h-32)

                    draw.RoundedBoxEx(self.Config.HasOffset and gmenu_round or 0, 0, h-24, w, 24, panel:IsHovered() and gmenu_trit or gmenu_prim, false, false, true, true)
                    draw.SimpleText(map, "gmenu.14", w/2, h-12, gmenu_text, 1, 1)
                end
            end

            -- controls

            local controls = pan:Add("Panel")
            controls:Dock(RIGHT)
            controls:SetWide((ScrW() <= 800 and 200 or 300))

            controls.hostname = controls:Add("DTextEntry")
            controls.hostname:Dock(TOP)
            controls.hostname:SetFont("gmenu.16")
            controls.hostname:SetTextColor(gmenu_text)
            controls.hostname:SetTall(30)
            controls.hostname:SetDrawLanguageID(false)
            controls.hostname:SetText(hostname)
            controls.hostname.Paint = function(panel, w, h)
                if ( panel.m_bBackground ) then
                    draw.RoundedBox(self.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
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

            controls.hostname.OnTextChanged = function(self)
                hostname = self:GetValue()
            end

            controls.maxplayers = controls:Add("DComboBox")
            controls.maxplayers:Dock(TOP)
            controls.maxplayers:SetFont("gmenu.16")
            controls.maxplayers:SetTextColor(gmenu_text)
            controls.maxplayers:SetTall(30)
            controls.maxplayers:SetSortItems(false)
            controls.maxplayers.Paint = function(panel, w, h)
                return draw.RoundedBox(self.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
            end

            for k, v in ipairs({1, 2, 4, 8, 16, 32, 64, 128}) do
                controls.maxplayers:AddChoice(v)
            end

            controls.maxplayers.OnSelect = function(_, _, val)
                maxplayers = tonumber(val)
            end

            controls.play = controls:Add("DButton")
            controls.play:Dock(BOTTOM)
            controls.play:SetText(language.GetPhrase("start_game"))
            controls.play:SetFont("gmenu.18B")
            controls.play:SetTextColor(gmenu_text)
            controls.play:SetTall(40)
            controls.play.Paint = function(panel, w, h)
                draw.RoundedBox(self.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, panel:IsHovered() and gmenu_prim or gmenu_sec)
            end

            controls.play.DoClick = function()
                loadMap()
            end

            if self.Config.HasOffset then
                controls:DockMargin(0, 5, 5, 5)
                controls.hostname:DockMargin(5, 5, 5, 0)
                controls.maxplayers:DockMargin(5, 5, 5, 0)

                controls.play:DockMargin(5, 0, 5, 5)
            end

            controls.Paint = function(panel, w, h)
                draw.RoundedBox(self.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_trit)
            end

            -- end

            columnsheet:AddTab(k, pan)
        end
    end

    timer.Simple(1, loadmain) -- If your maps don't have time to load, set the time on this timer a couple of tenths of a second longer.
    return panel
end

gmenu:AddToMenu("gmenu/singleplayer.png", gmenu:GetSingleplayer())