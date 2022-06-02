function gmenu:GetMultiplayer()
    local gamemodes = {}
    local panel = self:GetBasePanel()
    local columnsheet = panel:Add("gmenu.ColumnSheetCats")
    columnsheet:Dock(FILL)

    local registerGamemode = function(gm)
        local panel = vgui.Create("DListView")
        --panel.VBar:SetWide(0)
        panel.DoDoubleClick = function(self, _, panel)
            JoinServer(panel.ip) -- Connect to the server
        end
        panel:Dock(FILL)
        panel:SetMultiSelect(false)
        panel.Paint = function(panel, w, h)
            draw.RoundedBox(self.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
        end
        
        gamemodes[gm] = panel

        columnsheet:AddTab(gm, panel)

        local c_head = panel:AddColumn(language.GetPhrase("server_name_header"))
        c_head:SetWide(panel:GetParent():GetWide()*0.60)
        c_head:SetTall(30)
        c_head.Header:SetFont("gmenu.14")
        c_head.Header:SetTextColor(gmenu_text)
        c_head.Header.Paint = function(panel, w, h)
            draw.RoundedBox(0, 0, h-24, w, 24, panel:IsHovered() and gmenu_trit or gmenu_prim)
        end

        local c_mapname = panel:AddColumn(language.GetPhrase("server_mapname"))
        c_mapname:SetWide(panel:GetParent():GetWide()*0.20)
        c_mapname:SetTall(30)
        c_mapname.Header:SetFont("gmenu.14")
        c_mapname.Header:SetTextColor(gmenu_text)
        c_mapname.Header.Paint = function(panel, w, h)
            draw.RoundedBox(0, 0, h-24, w, 24, panel:IsHovered() and gmenu_trit or gmenu_prim)
        end

        local c_plys = panel:AddColumn(language.GetPhrase("server_players"))
        c_plys:SetWide(panel:GetParent():GetWide()*0.20)
        c_plys:SetTall(30)
        c_plys.Header:SetFont("gmenu.14")
        c_plys.Header:SetTextColor(gmenu_text)
        c_plys.Header.Paint = function(panel, w, h)
            draw.RoundedBox(0, 0, h-24, w, 24, panel:IsHovered() and gmenu_trit or gmenu_prim)
        end

        local c_ping = panel:AddColumn(language.GetPhrase("server_ping"))
        c_ping:SetWide(panel:GetParent():GetWide()*0.20)
        c_ping:SetTall(30)
        c_ping.Header:SetFont("gmenu.14")
        c_ping.Header:SetTextColor(gmenu_text)
        c_ping.Header.Paint = function(panel, w, h)
            draw.RoundedBox(0, 0, h-24, w, 24, panel:IsHovered() and gmenu_trit or gmenu_prim)
        end
    end

    local dat = {
        Callback = function(ping, name, desc, map, plys, mplys, _, _, _, ip, _, _, _, _, localize)
            if not gamemodes[desc] then
                registerGamemode(desc)
            end

            --local server = gamemodes[desc].Panel:AddLine(name, map, plys .. "/" .. mplys, ping)
            local server = gamemodes[desc].Panel:AddLine(name, map, plys, ping)
            server.ip = ip
            server:SetTooltip(localize ~= "" and localize or "N/A")

            for k, v in ipairs(server:GetChildren()) do
                if v:GetName() == "DListViewLabel" then
                    v:SetFont("gmenu.18")
                    v:SetTextColor(gmenu_text)
                end
            end
        end
    }

    serverlist.Query(dat)
    
    return panel
end

gmenu:AddToMenu("gmenu/multiplayer.png", gmenu:GetMultiplayer())