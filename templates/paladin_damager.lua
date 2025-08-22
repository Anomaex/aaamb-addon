
local frame = nil
local rotation_tsf = nil
local judgement_name = "Judgement of Light"
local time = 0
local taow = false -- The Art of War


local function Rotation_Exorcism()
    local cd = GetSpellCooldown("Exorcism")
    if cd == 0 then
        local in_range = IsSpellInRange("Exorcism", "target") == 1
        if in_range then
            -- cast Exorcism
            rotation_tsf:SetVertexColor(1, 0, 0, 1) -- red
            return 0
        end
    end
    return 1
end


local function Rotation_Consecration()
    local cd = GetSpellCooldown("Consecration")
    if cd == 0 then
        local in_range = IsSpellInRange(judgement_name, "target") == 1
        if in_range then
            -- cast Consecration
            rotation_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
            return 0
        end
    end
    return 1
end


local function Rotation_JoL()
    local cd = GetSpellCooldown(judgement_name)
    if cd == 0 then
        local in_range = IsSpellInRange(judgement_name, "target") == 1
        if in_range then
            -- cast Judgement
            rotation_tsf:SetVertexColor(0, 1, 0, 1) -- green
            return 0
        end
    end
    return 1
end


local function GetTargetHealthPercent()
    local unit = "target"
    if not UnitExists(unit) then
        return 0
    end
    local health = UnitHealth(unit)
    local max_health = UnitHealthMax(unit)
    local percent = 0
    if max_health > 0 then
        percent = (health / max_health) * 100
    end
    return percent
end


local function GetManaPercent()
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

    rotation_tsf:SetVertexColor(0, 0, 0, 1) -- black

    if not is_attack then return end

    local cd = -1
    local mana = GetManaPercent()

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

    if taow then
        cd = Rotation_Exorcism()
        if cd == 0 then
            return
        end
    end

    if mana > 50 then
        if GetTargetHealthPercent() > 30 then
            cd = Rotation_Consecration()
            if cd == 0 then
                return
            end
        end
    end

    if not taow then
        cd = Rotation_Exorcism()
        if cd == 0 then
            return
        end
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
    for i = 1, #AAAMB.char_names.damagers do
        local unit_name = UnitName("player")
        if unit_name == AAAMB.char_names.damagers[1] then
            local flag = GetSpellInfo("Judgement of Wisdom")
            if flag then
                judgement_name = "Judgement of Wisdom"
                AAAMB.Methods.KMB.MoveSpellToBar("Judgement of Wisdom", 1) -- key q
            end
            break
        end
    end

    AAAMB.Methods.KMB.MoveSpellToBar("Consecration", 2) -- key e
    AAAMB.Methods.KMB.MoveSpellToBar("Exorcism", 3) -- key r
end


function AAAMB.Methods.Templates.Paladin.Damager.Init()
    frame = CreateFrame("Frame", "AAAMB_Paladin_Damager_Frame", UIParent)
    rotation_tsf = AAAMB.Methods.CreateTSF("Paladin_Damager_Rotation", 240, 0)

    SetKeyMacroBar()

    local _, _, _, rank = GetTalentInfo(3, 17)
    if rank and rank > 1 then
        taow = true
    end

    frame:SetScript("OnUpdate", OnUpdate)
end
