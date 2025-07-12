
local frame = nil
local rotation_tsf = nil
local time = 0


local function Rotation_JoL()
    local cd = GetSpellCooldown("Judgement of Light")
    if cd == 0 then
        local in_range = IsSpellInRange("Judgement of Light", "target") == 1
        if in_range then
            -- cast Judgement of Light
            rotation_tsf:SetVertexColor(0, 0, 1, 1) -- blue
            return 0
        end
    end
    return 1
end


local function GetMana()
    local unit = "player"
    local flag = UnitIsDead(unit)
    flag = UnitIsGhost(unit)
    if flag then return 100 end

    local power = UnitPower(unit)
    local max_power = UnitPowerMax(unit)
    local percent = 0
    if max_power > 0 then
        percent = (power / max_power) * 100
    end
    return percent
end


local function Rotation()
    local is_attack = false
    local is_combat = InCombatLockdown()
    if is_combat then
        local is_exists = UnitExists("target")
        if is_exists then
            local is_friend = UnitIsFriend("player", "target")
            if not is_friend then
                is_attack = true
            end
        end
    end

    if not is_attack then
        rotation_tsf:SetVertexColor(0, 1, 0, 1) -- green
        return
    end

    local cd = -1
    local mana = GetMana()

    if mana < 50 then
        cd = Rotation_JoL()
        if cd == 0 then
            return
        end
    end

    -- other prior attack logic 

    cd = Rotation_JoL()
    if cd == 0 then
        return
    end
end


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.2 then -- 200 ms
        time = 0
        Rotation()
    end
end


local function SetKeyMacroBar()
    AAAMB.Methods.KMB.MoveSpellToBar("Judgement of Light", 3) -- key r
end


function AAAMB.Methods.Templates.Paladin.Damager.Init()
    frame = CreateFrame("Frame", "AAAMB_Paladin_Damager_Frame", UIParent)
    rotation_tsf = AAAMB.Methods.CreateTSF("Paladin_Damager_Rotation", 240, 0)

    SetKeyMacroBar()

    frame:SetScript("OnUpdate", OnUpdate)
end
