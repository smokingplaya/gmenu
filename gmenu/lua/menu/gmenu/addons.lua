
function gmenu:GetAddons()
    local panel = self:GetBasePanel()
    local columnsheet = panel:Add("gmenu.ColumnSheetCats")
    columnsheet:Dock(FILL)

    local loadmain = function()
        local panelws = vgui.Create("Panel")
        panelws:Dock(FILL)
        panelws.Paint = function(panel, w, h)
            draw.RoundedBox(self.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
        end

        local addonsList = panelws:Add("DIconLayout") -- TODO: MAKE SCROLL
        addonsList:Dock(FILL)

        if self.Config.HasOffset then
            addonsList:SetSpaceX(10)
            addonsList:SetSpaceY(10)
            addonsList:DockMargin(5, 5, 5, 5)
        end

        for k, v in ipairs(engine.GetAddons()) do
            v.id = 0
            steamworks.FileInfo(v.wsid, function(result)
                local addon = addonsList:Add("DButton")
                addon:SetText("")
                addon.Size = 128
                addon:SetSize(addon.Size, addon.Size+24)
                addon.mat, addon.matgrad = AddonMaterial("cache/workshop/" .. result.previewid .. ".cache") or Material("gmenu/mapnothumb.png"), Material("vgui/gradient_up")

                addon.DoClick = function()
                    gui.OpenURL("https://steamcommunity.com/sharedfiles/filedetails/?id=" .. v.wsid)
                end

                addon.Paint = function(panel, w, h)
                    surface.SetDrawColor(color_white)
                    surface.SetMaterial(panel.mat)
                    surface.DrawTexturedRect(0, 0, w, h-24)

                    surface.SetDrawColor(color_black)
                    surface.SetMaterial(panel.matgrad)
                    surface.DrawTexturedRect(0, 16, w, h-32)

                    draw.RoundedBoxEx(self.Config.HasOffset and gmenu_round or 0, 0, h-24, w, 24, panel:IsHovered() and gmenu_trit or gmenu_prim, false, false, true, true)
                    draw.SimpleText(v.title, "gmenu.14", w/2, h-12, gmenu_text, 1, 1)
                end
            end)
        end

        columnsheet:AddTab("Установленные", panelws)
    end

    columnsheet:AddTab(language.GetPhrase("addons.openworkshop"), function()
        gui.OpenURL("https://steamcommunity.com/app/4000/workshop/")
    end)

    timer.Simple(1, loadmain)
    return panel
end

gmenu:AddToMenu("gmenu/addons.png", gmenu:GetAddons())