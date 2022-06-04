gmenu.gui = {}

oldDermaMenu = DermaMenu
function gmenu.gui.DMenu()
    local dmenu = oldDermaMenu()
    dmenu.Options = {}
    dmenu.Paint = nil
    dmenu.OldAddOption = dmenu.AddOption
    dmenu.AddOption = function(self, strText, funcFunction)
        local pnl = self:OldAddOption(strText, funcFunction)
        pnl:SetFont("gmenu.16")
        pnl:SetTextColor(gmenu_text)
        table.insert(self.Options, pnl)

        pnl.Paint = function(self, w, h)
            draw.RoundedBoxEx(8, 0, 0, w, h, self:IsHovered() and gmenu_trit or gmenu_sec, self.lt, self.rt, self.lb, self.rb)
        end

        return pnl
    end

    dmenu.OldOpen = dmenu.Open
    dmenu.Open = function(self, x, y, s, o)
        if not gmenu.Config.HasOffset then
            for k, v in ipairs(self.Options) do
                v.lt, v.rt, v.lb, v.rb = false, false, false, false
            end
        else
            local count = table.Count(self.Options)
            local i = 0
            for k, v in ipairs(self.Options) do
                i = i+1
                if i == 1 then
                    v.lt, v.rt = true, true
                    if count == 1 then
                        v.lb, v.rb = true, true
                    end
                elseif i == count then
                    v.lt, v.rt, v.lb, v.rb = false, false, true, true
                else
                    v.lt, v.rt, v.lb, v.rb = false, false, false, false
                end
            end
        end

        self:OldOpen(x, y, s, o)
    end
    
    return dmenu
end

DermaMenu = gmenu.gui.DMenu

function gmenu.gui:TextEntry(parent, placeholderText, font)
    local panel = vgui.Create("DTextEntry", parent)
    panel:SetPlaceholderColor(gmenu_stext)
    panel:SetPlaceholderText(placeholderText)
    panel:SetFont("gmenu." .. (font or "16"))
    panel:SetTextColor(gmenu_text)
    panel:SetTall(30)
    panel:SetDrawLanguageID(false)
    panel.Paint = function(panel, w, h)
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

    return panel
end

function gmenu.gui:ComboBox(parent, tab, defaultValue, font)
    local panel = vgui.Create("DComboBox", parent)
    panel:SetFont("gmenu." .. (font or "16"))
    panel:SetTextColor(gmenu_text)
    panel:SetTall(30)
    panel:SetSortItems(false)
    
    if istable(tab) then
        for k, v in ipairs(tab) do
            panel:AddChoice(v)
        end
    end

    panel:SetValue(defaultValue)
    panel.Paint = function(panel, w, h)
        return draw.RoundedBox(gmenu.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
    end

    return panel
end