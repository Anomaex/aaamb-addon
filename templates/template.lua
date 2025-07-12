
function AAAMB.Methods.Templates.Init()
    local class = UnitClass("player")
    if class == "Druid" then
        AAAMB.Methods.Templates.Druid.Init()
    elseif class == "Paladin" then
        AAAMB.Methods.Templates.Paladin.Init()
    end
end
