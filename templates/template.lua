
function AAAMB.Methods.Templates.Init()
    local _, class = UnitClass("player")
    if class == "PALADIN" then
        AAAMB.Methods.Templates.Paladin.Init()
    end
end
