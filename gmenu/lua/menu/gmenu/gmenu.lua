--[[
    gMenu - is simple Lua menu for Garry's Mod
    coded by johngetman
]]--

gmenu = {}
gmenu.Config = {}
gmenu.MenuTabs = {}

--[[ Config ]]--

gmenu.Config.Font = "Montserrat Regular"
gmenu.Config.FontBold = "Montserrat SemiBold"
gmenu.Config.Rounding = 4 -- Rounding of all blocks (number)
gmenu.Config.HasOffset = true -- Is Offsets enabled? (true/false)
gmenu.Config.ClockEnabled = true -- Is clock enabled? (true/false)

gmenu.Colors = { -- You can customize colors of gMenu
    ["Primary"] = Color(40, 40, 40),
    ["Secondary"] = Color(50, 50, 50),
    ["Tritary"] = Color(60, 60, 60),
    ["Text"] = Color(255, 255, 255),
    ["SecondaryText"] = Color(220, 220, 220)
}

--[[ Color global variables ]]--

gmenu_round, gmenu_prim, gmenu_sec, gmenu_trit, gmenu_text, gmenu_stext = gmenu.Config.Rounding, gmenu.Colors["Primary"], gmenu.Colors["Secondary"], gmenu.Colors["Tritary"], gmenu.Colors["Text"], gmenu.Colors["SecondaryText"] -- Global variables

--[[ Functions ]]--

function gmenu:AddToMenu(icon, panel)
    table.insert(self.MenuTabs, {icon = Material(icon), panel = panel})
end

function gmenu:GetBasePanel()
    local panel = vgui.Create("Panel")
    panel:SetAlpha(0)
    panel:Dock(FILL)
    panel:AlphaTo(255, 0.3, 0)
    panel.Paint = function(_, w, h)
        draw.RoundedBox(self.Config.HasOffset and gmenu_round or 0, 0, 0, w, h, gmenu_prim)
    end

    return panel
end

for k, v in ipairs({14, 16, 18, 24}) do
    surface.CreateFont("gmenu." .. v, {
        font = gmenu.Config.Font,
        size = v,
        extended = true
    })

    surface.CreateFont("gmenu." .. v .. "B", {
        font = gmenu.Config.FontBold,
        size = v,
        extended = true
    })
end

--[[ Including other files ]]--

include "gui.lua"
include "columnsheets.lua"
include "singleplayer.lua"
include "multiplayer.lua"
include "addons.lua"
