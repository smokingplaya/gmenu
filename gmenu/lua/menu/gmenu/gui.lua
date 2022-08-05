gmenu.gui = {}

local ho = gmenu.Config.HasOffset

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
        if not ho then
            for k, v in ipairs(self.Options) do
                v.lt, v.rt, v.lb, v.rb = false, false, false, false
            end
        else -- передаю челендж по фиксу этого Jaff'у
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

function gmenu.gui:Button(parent, text, font)
    local button = vgui.Create("DButton", parent)
    button:SetText(text or "gMenu")
    button:SetTextColor(gmenu_text)
    button:SetFont("gmenu." .. (font or "16"))
    
    button.Col1 = gmenu_prim
    button.Col2 = gmenu_sec
    button.ColDraw = button.Col1

    button.SetColor = function(self, col)
        self.ColDraw = col
    end

    button.SetColorStyle = function(self, col1, col2)
        self:SetColor(col2)
        self.Col1 = col1
        self.Col1 = col2
    end

    button.GetColor = function(self)
        return self.ColDraw
    end

    button.OnCursorEntered = function(self)
        self:ColorTo(self.Col2, 0.1, 0)
    end

    button.OnCursorExited = function(self)
        self:ColorTo(self.Col1, 0.1, 0)
    end

    button.SetIcon = function(self, icon, w, h)
        self.Icon = icon or Material(icon)
        self.IconW = w
        self.IconH = h
        
        self:SetText("")
    end

    button.Paint = function(self, w, h)
        draw.RoundedBox(ho and gmenu_round or 0, 0, 0, w, h, self.ColDraw)

        if self.Icon then
            surface.SetDrawColor(gmenu_text)
            surface.SetMaterial(self.Icon)
            surface.DrawTexturedRect((w/2-self.IconW/2), (h/2-self.IconH/2), self.IconW, self.IconH)
        end
    end

    return button
end

function gmenu.gui:SetVBar(vbar)
    if not ispanel(vbar) then return end

    vbar:SetWide(ho and (gmenu_round*2)+2 or 4+2)
    vbar:SetHideButtons(true)
    vbar.Paint = nil
    
    vbar.btnGrip.SetColor = function(self, col)
        self.ColDraw = col
    end

    vbar.btnGrip:SetColor(gmenu_sec)

    vbar.btnGrip.Paint = function(self, w, h)
        draw.RoundedBox(ho and gmenu_round or 0, 2, 0, w-2, h, self.ColDraw)
    end

    return vbar
end

function gmenu.gui:ScrollPanel(parent)
    local panel = vgui.Create("DScrollPanel", parent)
    self:SetVBar(panel:GetVBar())

    return panel
end

function gmenu.gui:DListView(parent)
    local panel = vgui.Create("DListView", parent)
    self:SetVBar(panel.VBar)

    return panel
end

function gmenu.gui:TextEntry(parent, placeholderText, font)
    local panel = vgui.Create("Panel", parent)
    
    panel.SetColor = function(self, col)
        self.ColDraw = col
    end

    panel:SetColor(gmenu_prim)

    panel.Paint = function(panel, w, h)
        draw.RoundedBox(ho and gmenu_round or 0, 0, 0, w, h, panel.ColDraw)
    end

    local entry = vgui.Create("DTextEntry", panel)
    entry:SetPlaceholderColor(gmenu_stext)
    entry:SetPlaceholderText(placeholderText)
    entry:SetFont("gmenu." .. (font or "16"))
    entry:SetTextColor(gmenu_text)
    entry:Dock(FILL)
    entry:DockMargin(4, 0, 0, 0)
    entry:SetDrawLanguageID(false)
    entry.Paint = function(panel, w, h)
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

    return panel, entry
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
        return draw.RoundedBox(ho and gmenu_round or 0, 0, 0, w, h, gmenu_sec)
    end

    return panel
end
