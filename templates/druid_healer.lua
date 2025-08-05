
local frame = nil
local mana = nil
local time = 0
local mana_time = 0
local party_health_tsfs = {nil, nil, nil, nil, nil} -- 1 - tank, 2 - healer, 3 - damager f, 4 - damager s, 5 - damager t
local natures_grasp_timer = 0
local natures_grasp_tsf = nil
local mana_potion_id = nil


local function CheckRegrowth(unit, index)
    local name = UnitBuff(unit, "Regrowth")
    if not name then
        party_health_tsfs[index]:SetVertexColor(1, 1, 0, 1) -- yellow
        return false
    end
    return true  
end


local function CheckRejuvenation(unit, index)
    local name = UnitBuff(unit, "Rejuvenation")
    if not name then
        party_health_tsfs[index]:SetVertexColor(0, 1, 0, 1) -- green
        return false
    end
    return true
end


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
    local tank_hp = GetHealth(AAAMB.tank)
    local healer_hp = GetHealth("player")
    local dmg_f_hp = GetHealth(AAAMB.damagers[1])
    local dmg_s_hp = GetHealth(AAAMB.damagers[2])
    local dmg_t_hp = GetHealth(AAAMB.damagers[3])

    party_health_tsfs[1]:SetVertexColor(0, 0, 0, 1) -- black
    party_health_tsfs[2]:SetVertexColor(0, 0, 0, 1) -- black
    party_health_tsfs[3]:SetVertexColor(0, 0, 0, 1) -- black
    party_health_tsfs[4]:SetVertexColor(0, 0, 0, 1) -- black
    party_health_tsfs[5]:SetVertexColor(0, 0, 0, 1) -- black

    -- Global cooldown or silence
    local start, duration = GetSpellCooldown("Healing Touch")
    if start and duration and start > 0 and duration <= 1.5 then
        return
    end


    --
    if tank_hp < 30 then
        if not CheckRegrowth(AAAMB.tank, 1) then return end
        party_health_tsfs[1]:SetVertexColor(1, 1, 1, 1) -- white
        return
    end

    if healer_hp < 30 then
        if not CheckRegrowth("player", 2) then return end
        party_health_tsfs[2]:SetVertexColor(1, 1, 1, 1) -- white
        return
    end


    --
    if tank_hp < 50 then
        if not CheckRegrowth(AAAMB.tank, 1) then return end
        if not CheckRejuvenation("player", 2) then return end
        party_health_tsfs[1]:SetVertexColor(1, 1, 1, 1) -- white
        return
    end

    if healer_hp < 50 then
        if not CheckRegrowth("player", 2) then return end
        if not CheckRejuvenation("player", 2) then return end
        party_health_tsfs[2]:SetVertexColor(1, 1, 1, 1) -- white
        return
    end


    ---
    if dmg_f_hp < 30 then
        if not CheckRegrowth(AAAMB.damagers[1], 3) then return end
        party_health_tsfs[3]:SetVertexColor(1, 1, 1, 1) -- white
        return
    end

    if dmg_s_hp < 30 then
        if not CheckRegrowth(AAAMB.damagers[2], 4) then return end
        party_health_tsfs[4]:SetVertexColor(1, 1, 1, 1) -- white
        return
    end

    if dmg_t_hp < 30 then
        if not CheckRegrowth(AAAMB.damagers[3], 5) then return end
        party_health_tsfs[5]:SetVertexColor(1, 1, 1, 1) -- white
        return
    end


    --
    if tank_hp < 75 then
        if not CheckRegrowth(AAAMB.tank, 1) then return end
        if not CheckRejuvenation(AAAMB.tank, 1) then return end
    end

    if healer_hp < 75 then
        if not CheckRejuvenation("player", 2) then return end
    end

    
    --
    if dmg_f_hp < 50 then
        if not CheckRegrowth(AAAMB.damagers[1], 3) then return end
        if not CheckRejuvenation(AAAMB.damagers[1], 3) then return end
    end

    if dmg_s_hp < 50 then
        if not CheckRegrowth(AAAMB.damagers[2], 4) then return end
        if not CheckRejuvenation(AAAMB.damagers[2], 4) then return end
    end

    if dmg_t_hp < 50 then
        if not CheckRegrowth(AAAMB.damagers[3], 5) then return end
        if not CheckRejuvenation(AAAMB.damagers[3], 5) then return end
    end

    
    --
    if tank_hp < 90 then
        if not CheckRejuvenation(AAAMB.tank, 1) then return end
    end

    if healer_hp < 90 then
        if not CheckRejuvenation("player", 2) then return end
    end


    --
    if dmg_f_hp < 70 then
        if not CheckRejuvenation(AAAMB.damagers[1], 3) then return end
    end

    if dmg_s_hp < 70 then
        if not CheckRejuvenation(AAAMB.damagers[2], 4) then return end
    end

    if dmg_t_hp < 70 then
        if not CheckRejuvenation(AAAMB.damagers[3], 5) then return end
    end
end


local function CheckNaturesGrasp()
    natures_grasp_tsf:SetVertexColor(0, 0, 0) -- black
    if not InCombatLockdown() then return end
    local cd = GetSpellCooldown("Nature's Grasp")
    if cd == 0 then
        natures_grasp_tsf:SetVertexColor(0, 1, 0) -- green
    end
end


local function CheckMana()
    mana_tsf:SetVertexColor(0, 0, 0) -- black

    if not mana_potion_id then return end

    local unit = "player"
    local flag = UnitIsDead(unit)
    flag = UnitIsGhost(unit)
    if flag then return end

    local mana = UnitPower(unit)
    local max_mana = UnitPowerMax(unit)
    local percent = 0
    if max_mana > 0 then
        percent = (mana / max_mana) * 100
    end

    if percent < 15 then
        local cd = GetItemCooldown(mana_potion_id)
        if cd == 0 then
            mana_tsf:SetVertexColor(1, 1, 0) -- yellow
        end
    end
end


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.1 then -- 100 ms
        time = 0
        ScanPartyHealth()
    end

    mana_time = mana_time + delta
    if mana_time >= 0.3 then -- 300 ms
        mana_time = 0
        CheckMana()
    end

    natures_grasp_timer = natures_grasp_timer + delta
    if natures_grasp_timer >= 1 then -- 1000 ms / 1s
        natures_grasp_timer = 0
        CheckNaturesGrasp()
    end
end


local function GetHealingMacrobody(spell_name)
    local spell = GetSpellInfo(spell_name)
    if spell then
        local macrobody = "/cast [mod:alt,mod:shift,target=" .. (AAAMB.damagers[3] or "") .. "] " .. spell_name
        macrobody = macrobody .. "\n/cast [mod:alt,target=" .. (AAAMB.damagers[2] or "") .. "] " .. spell_name
        macrobody = macrobody .. "\n/cast [mod:ctrl,target=" .. (AAAMB.damagers[1] or "") .. "] " .. spell_name
        macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.healer or "") .. "] " .. spell_name
        macrobody = macrobody .. "\n/cast [nomod,target=" .. (AAAMB.tank or "") .. "] " .. spell_name
        return macrobody
    end
    return false
end


local function SetKeyMacroBar()
    local macrobody = GetHealingMacrobody("Rejuvenation")
    if macrobody then
        AAAMB.Methods.KMB.CreateAccountMacro("Rej_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("Rej_A", 49) -- key y
    end

    local macrobody = GetHealingMacrobody("Healing touch")
    if macrobody then
        AAAMB.Methods.KMB.CreateAccountMacro("HT_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("HT_A", 50) -- key u
    end

    local macrobody = GetHealingMacrobody("Regrowth")
    if macrobody then
        AAAMB.Methods.KMB.CreateAccountMacro("Reg_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("Reg_A", 51) -- key i
    end

    AAAMB.Methods.KMB.MoveSpellToBar("Nature's Grasp", 1) -- key q

    local drink_item = AAAMB.Methods.Helper.FindItemInBag("Food & Drink")
    if drink_item then
        AAAMB.Methods.KMB.MoveItemToBar(drink_item[1], drink_item[2], 25)
    end

    local mana_potion_item = AAAMB.Methods.Helper.FindItemInBag("Potion")
    if mana_potion_item then
        AAAMB.Methods.KMB.MoveItemToBar(mana_potion_item[1], mana_potion_item[2], 26)
        mana_potion_id = mana_potion_item[3]
    end
end


function AAAMB.Methods.Templates.Druid.Healer.Init()
    frame = CreateFrame("Frame", "AAAMB_Druid_Healer_Frame", UIParent)

    party_health_tsfs[1] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Tank_Health", 0, -120)
    party_health_tsfs[2] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Healer_Health", 30, -120)
    party_health_tsfs[3] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Dmg_F_Health", 60, -120)
    party_health_tsfs[4] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Dmg_S_Health", 90, -120)
    party_health_tsfs[5] = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Dmg_T_Health", 120, -120)

    mana_tsf = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Mana", 210, -30)
    natures_grasp_tsf = AAAMB.Methods.CreateTSF("AAAMB_Druid_Healer_Natures_Grasp", 240, 0)

    SetKeyMacroBar()

    frame:SetScript("OnUpdate", OnUpdate)
end
