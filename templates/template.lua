
function AAAMB.Methods.Templates.Init()
    local class = UnitClass("player")
    if class == "Paladin" then
        AAAMB.Methods.Templates.Paladin.Init()
    elseif class == "Druid" then
        AAAMB.Methods.Templates.Druid.Init()
    end
end
