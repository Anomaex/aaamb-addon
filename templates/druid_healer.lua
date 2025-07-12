
local frame = nil
local party_health_tsfs = {nil, nil, nil, nil, nil} -- 1 - tank, 2 - healer, 3 - damager f, 4 - damager s, 5 - damager t
local time = 0


local function GetHealth(unit)
    if not unit then return 100 end

    local flag = UnitIsDead(unit)
    flag = UnitIsGhost(unit)
    if flag then return 100 end

    local is_exists = UnitExists(unit)
    local is_connected = UnitIsConnected(unit)
    local is_enemy = UnitIsEnemy("player", unit)
    local in_range = IsSpellInRange("Healing Touch", unit)
    local is_visible = UnitIsVisible(unit)
    if not in_range or not is_visible or not is_exists or not is_connected or is_enemy then
        return 100
    end

    local health = UnitHealth(unit)
    local max_health = UnitHealthMax(unit)
    local percent = 0
    if max_health > 0 then
        percent = (health / max_health) * 100
    end
    return percent
end


local function ScanPartyHealth()
    local tank_health = GetHealth(AAAMB.tank)
    local healer_health = GetHealth("player")
    local damager_f_health = GetHealth(AAAMB.damagers[1])
    local damager_s_health = GetHealth(AAAMB.damagers[2])
    local damager_t_health = GetHealth(AAAMB.damagers[3])

    party_health_tsfs[1]:SetVertexColor(0, 1, 0, 1) -- green
    party_health_tsfs[2]:SetVertexColor(0, 1, 0, 1) -- green
    party_health_tsfs[3]:SetVertexColor(0, 1, 0, 1) -- green
    party_health_tsfs[4]:SetVertexColor(0, 1, 0, 1) -- green
    party_health_tsfs[5]:SetVertexColor(0, 1, 0, 1) -- green

    if tank_health < 50 then
        local rejuvenation = UnitBuff(AAAMB.tank, "Rejuvenation")
        if not rejuvenation then
            party_health_tsfs[1]:SetVertexColor(0, 0, 1, 1) -- blue
            return
        else
            -- cast Healing Touch
            party_health_tsfs[1]:SetVertexColor(1, 0, 1, 1) -- purple
            return
        end
    end

    if healer_health < 50 then
        local rejuvenation = UnitBuff("player", "Rejuvenation")
        if not rejuvenation then
            party_health_tsfs[2]:SetVertexColor(0, 0, 1, 1) -- blue
            return
        else
            -- cast Healing Touch
            party_health_tsfs[2]:SetVertexColor(1, 0, 1, 1) -- purple
            return
        end
    end
end


local function SetKeyMacroBar()
    local rejuvenation = GetSpellInfo("Rejuvenation")
    if rejuvenation then
        if AAAMB.tank then
            local tank_heal = "/cast [nomod,target=" .. AAAMB.tank .. "] Rejuvenation"
            tank_heal = tank_heal .. "\n/cast [mod:alt,target=" .. AAAMB.tank .. "] Healing Touch"
            AAAMB.Methods.KMB.CreateAccountMacro("Tank_Heal_A", tank_heal)
            AAAMB.Methods.KMB.MoveMacroToBar("Tank_Heal_A", 49) -- key y
        end
    end
end


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.1 then -- 100 ms
        time = 0
        ScanPartyHealth()
    end
end


function AAAMB.Methods.Templates.Druid.Healer.Init()
    frame = CreateFrame("Frame", "AAAMB_Druid_Healer_Frame", UIParent)

    party_health_tsfs[1] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Tank_Health", 0, -120)
    party_health_tsfs[2] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Healer_Health", 30, -120)
    party_health_tsfs[3] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Damager_F_Health", 60, -120)
    party_health_tsfs[4] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Damager_S_Health", 90, -120)
    party_health_tsfs[5] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Damager_T_Health", 120, -120)

    SetKeyMacroBar()

    frame:SetScript("OnUpdate", OnUpdate)
end
