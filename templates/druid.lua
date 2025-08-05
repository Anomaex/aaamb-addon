
local frame = nil
local is_healer = false

local buffs_time = 0
local buffs = false
local thorns = false
local buff_spell_name = ""
local buffs_tsf = nil

local dispel_time = 0
local curse_dispel = false
local CURSE_DISPEL_SPELL_NAME = "Remove Curse"
local curse_dispel_tsf = nil
local poison_dispel = false
local POISON_DISPEL_SPELL_NAME = "Abolish Poison"
local poison_dispel_tsf = nil


function AAAMB.Methods.Templates.Druid.Reset()
    buffs_tsf:SetVertexColor(0, 0, 0, 1) -- black
end


local function CheckCurseDispel(unit, color)
    for i = 1, 40 do
        local name, _, _, _, debuff_type, _, exp_time, _, _, _, spell_id = UnitDebuff(unit, i, 1)
        if not name then break end
        if debuff_type == "Curse" then
            local time_left = exp_time - GetTime()
            if time_left > 1 then
                curse_dispel_tsf:SetVertexColor(color[1], color[2], color[3], 1)
                return true
            end
        --SendChatMessage("Debuff: " .. name .. ", id: " .. spell_id, "PARTY")
        end
    end
    return false
end


local function CheckPoisonDispel(unit, color)
    for i = 1, 40 do
        local name, _, _, _, debuff_type, _, exp_time, _, _, _, spell_id = UnitDebuff(unit, i, 1)
        if not name then break end
        if debuff_type == "Poison" then
            local time_left = exp_time - GetTime()
            if time_left > 1 then
                poison_dispel_tsf:SetVertexColor(color[1], color[2], color[3], 1)
                return true
            end
        end
    end
    return false
end


local function CheckDispels()
    curse_dispel_tsf:SetVertexColor(0, 0, 0, 1) -- black
    poison_dispel_tsf:SetVertexColor(0, 0, 0, 1) -- black

    local is_ok = false

    if curse_dispel then
        local tank = AAAMB.Methods.Helper.GetUnitState(AAAMB.tank, CURSE_DISPEL_SPELL_NAME)
        if tank then
            is_ok = CheckCurseDispel(AAAMB.tank, {0, 1, 0}) -- green
            if is_ok then return end
        end

        local healer = AAAMB.Methods.Helper.GetUnitState(AAAMB.healer, CURSE_DISPEL_SPELL_NAME)
        if healer then
            is_ok = CheckCurseDispel(AAAMB.healer, {0, 0, 1}) -- blue
            if is_ok then return end
        end

        if not is_healer then
            local player = AAAMB.Methods.Helper.GetUnitState("player", CURSE_DISPEL_SPELL_NAME)
            if player then
                is_ok = CheckCurseDispel("player", {1, 1, 1}) -- white
                if is_ok then return end
            end
        end

        local damager_f = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[1], CURSE_DISPEL_SPELL_NAME)
        if damager_f then
            is_ok = CheckCurseDispel(AAAMB.damagers[1], {1, 1, 0}) -- yellow
            if is_ok then return end
        end
    
        local damager_s = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[2], CURSE_DISPEL_SPELL_NAME)
        if damager_s then
            is_ok = CheckCurseDispel(AAAMB.damagers[2], {1, 0, 0}) -- red
            if is_ok then return end
        end
    
        if is_healer then
            local damager_t = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[3], CURSE_DISPEL_SPELL_NAME)
            if damager_t then
                is_ok = CheckCurseDispel(AAAMB.damagers[3], {1, 0, 1}) -- purple
                if is_ok then return end
            end
        end
    end

    if poison_dispel then
        local tank = AAAMB.Methods.Helper.GetUnitState(AAAMB.tank, POISON_DISPEL_SPELL_NAME)
        if tank then
            is_ok = CheckPoisonDispel(AAAMB.tank, {0, 1, 0}) -- green
            if is_ok then return end
        end

        local healer = AAAMB.Methods.Helper.GetUnitState(AAAMB.healer, POISON_DISPEL_SPELL_NAME)
        if healer then
            is_ok = CheckPoisonDispel(AAAMB.healer, {0, 0, 1}) -- blue
            if is_ok then return end
        end

        if not is_healer then
            local player = AAAMB.Methods.Helper.GetUnitState("player", POISON_DISPEL_SPELL_NAME)
            if player then
                is_ok = CheckPoisonDispel("player", {1, 1, 1}) -- white
                if is_ok then return end
            end
        end

        local damager_f = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[1], POISON_DISPEL_SPELL_NAME)
        if damager_f then
            is_ok = CheckPoisonDispel(AAAMB.damagers[1], {1, 1, 0}) -- yellow
            if is_ok then return end
        end
    
        local damager_s = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[2], POISON_DISPEL_SPELL_NAME)
        if damager_s then
            is_ok = CheckPoisonDispel(AAAMB.damagers[2], {1, 0, 0}) -- red
            if is_ok then return end
        end
    
        if is_healer then
            local damager_t = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[3], POISON_DISPEL_SPELL_NAME)
            if damager_t then
                is_ok = CheckPoisonDispel(AAAMB.damagers[3], {1, 0, 1}) -- purple
                if is_ok then return end
            end
        end
    end
end


local function SetDispelKeyMacroBar()
    local dispel_spell = GetSpellInfo(CURSE_DISPEL_SPELL_NAME)
    if dispel_spell then
        -- Tank, Healer and Self
        local macrobody = "/cast [nomod,target=" .. (AAAMB.tank or "") .. "] " .. CURSE_DISPEL_SPELL_NAME
        macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.healer or "") .. "] " .. CURSE_DISPEL_SPELL_NAME
        macrobody = macrobody .. "\n/cast [mod:ctrl,target=player] " .. CURSE_DISPEL_SPELL_NAME
        AAAMB.Methods.KMB.CreateAccountMacro("CurseDispel_0_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("CurseDispel_0_A", 58) -- key b

        -- Damagers
        local macrobody = "/cast [nomod,target=" .. (AAAMB.damagers[1] or "") .. "] " .. CURSE_DISPEL_SPELL_NAME
        macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.damagers[2] or "") .. "] " .. CURSE_DISPEL_SPELL_NAME
        macrobody = macrobody .. "\n/cast [mod:ctrl,target=" .. (AAAMB.damagers[3] or "") .. "] " .. CURSE_DISPEL_SPELL_NAME
        AAAMB.Methods.KMB.CreateAccountMacro("CurseDispel_1_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("CurseDispel_1_A", 59) -- key n
    end

    dispel_spell = GetSpellInfo(POISON_DISPEL_SPELL_NAME)
    if dispel_spell then
        -- Tank, Healer and Self
        local macrobody = "/cast [nomod,target=" .. (AAAMB.tank or "") .. "] " .. POISON_DISPEL_SPELL_NAME
        macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.healer or "") .. "] " .. POISON_DISPEL_SPELL_NAME
        macrobody = macrobody .. "\n/cast [mod:ctrl,target=player] " .. POISON_DISPEL_SPELL_NAME
        AAAMB.Methods.KMB.CreateAccountMacro("PoisonDispel_0_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("PoisonDispel_0_A", 56) -- key k

        -- Damagers
        local macrobody = "/cast [nomod,target=" .. (AAAMB.damagers[1] or "") .. "] " .. POISON_DISPEL_SPELL_NAME
        macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.damagers[2] or "") .. "] " .. POISON_DISPEL_SPELL_NAME
        macrobody = macrobody .. "\n/cast [mod:ctrl,target=" .. (AAAMB.damagers[3] or "") .. "] " .. POISON_DISPEL_SPELL_NAME
        AAAMB.Methods.KMB.CreateAccountMacro("PoisonDispel_1_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("PoisonDispel_1_A", 57) -- key l
    end
end


local function CheckBuff(unit, color, buff)
    if not buff or buff == "" then return end
    local name, _, _, _, _, _, exp_time = UnitBuff(unit, buff)
    if name then
        local time_left = exp_time - GetTime()
        if time_left < 150 then -- 1.30 min
            buffs_tsf:SetVertexColor(color[1], color[2], color[3], 1)
            return true
        end
    else
        buffs_tsf:SetVertexColor(color[1], color[2], color[3], 1)
        return true
    end
    return false
end


local function CheckBuffs()
    buffs_tsf:SetVertexColor(0, 0, 0, 1) -- black

    if not buffs then return end

    if InCombatLockdown() then return end

    local is_ok = false

    local tank = AAAMB.Methods.Helper.GetUnitState(AAAMB.tank, buff_spell_name)
    if tank then
        if thorns then
            is_ok = CheckBuff(AAAMB.tank, {0, 1, 1}, "Thorns") -- aqua
            if is_ok then return end
        end
        is_ok = CheckBuff(AAAMB.tank, {0, 1, 0}, buff_spell_name) -- green
        if is_ok then return end
    end

    local healer = AAAMB.Methods.Helper.GetUnitState(AAAMB.healer, buff_spell_name)
    if healer then
        is_ok = CheckBuff(AAAMB.healer, {0, 0, 1}, buff_spell_name) -- blue
        if is_ok then return end
    end

    local damager_f = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[1], buff_spell_name)
    if damager_f then
        is_ok = CheckBuff(AAAMB.damagers[1], {1, 1, 0}, buff_spell_name) -- yellow
        if is_ok then return end
    end

    local damager_s = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[2], buff_spell_name)
    if damager_s then
        is_ok = CheckBuff(AAAMB.damagers[2], {1, 0, 0}, buff_spell_name) -- red
        if is_ok then return end
    end

    if AAAMB.healer == "player" then
        local damager_t = AAAMB.Methods.Helper.GetUnitState(AAAMB.damagers[3], buff_spell_name)
        if damager_s then
            is_ok = CheckBuff(AAAMB.damagers[3], {1, 0, 1}, buff_spell_name) -- purple
            if is_ok then return end
        end
    else
        is_ok = CheckBuff("player", {1, 1, 1}, buff_spell_name) -- white
        if is_ok then return end
    end
end


local function SetAutoBuffsKeyMacroBar()
    buff_spell_name = "Mark of The Wild"

    local gift = "Gift of The Wild"
    local spell = GetSpellInfo(gift)
    if spell then
        local can_use = IsUsableSpell(gift)
        if can_use then
            buff_spell_name = gift
        else
            local link = GetSpellLink(gift)
            SendChatMessage("Not have reagents for " .. link, "PARTY")
        end
    end

    -- Tank and Healer
    local macrobody = "/cast [nomod,target=" .. (AAAMB.tank or "") .. "] " .. buff_spell_name
    macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.healer or "") .. "] " .. buff_spell_name
    macrobody = macrobody .. "\n/script AAAMB.Methods.Templates.Druid.Reset()"
    AAAMB.Methods.KMB.CreateAccountMacro("Buffs_0_A", macrobody)
    AAAMB.Methods.KMB.MoveMacroToBar("Buffs_0_A", 33) -- key F5

    -- Damagers
    local macrobody = "/cast [nomod,target=" .. (AAAMB.damagers[1] or "") .. "] " .. buff_spell_name
    macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.damagers[2] or "") .. "] " .. buff_spell_name
    macrobody = macrobody .. "\n/cast [mod:ctrl,target=" .. (AAAMB.damagers[3] or "") .. "] " .. buff_spell_name
    macrobody = macrobody .. "\n/script AAAMB.Methods.Templates.Druid.Reset()"
    AAAMB.Methods.KMB.CreateAccountMacro("Buffs_1_A", macrobody)
    AAAMB.Methods.KMB.MoveMacroToBar("Buffs_1_A", 34) -- key F6

    -- Self buff and tank Thorns
    local macrobody = "/cast [nomod,target=player] " .. buff_spell_name
    macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.tank or "") .. "] Thorns"
    macrobody = macrobody .. "\n/script AAAMB.Methods.Templates.Druid.Reset()"
    AAAMB.Methods.KMB.CreateAccountMacro("Buffs_2_A", macrobody)
    AAAMB.Methods.KMB.MoveMacroToBar("Buffs_2_A", 35) -- key F7
end


local function SetKeyMacroBar()
    SetAutoBuffsKeyMacroBar()

    if AAAMB.tank then
        local macrobody = "/target ".. AAAMB.tank
        macrobody = macrobody .. "\n/castsequence [@targettarget] reset=2 Mark of The Wild, Thorns,,"
        AAAMB.Methods.KMB.CreateAccountMacro("BuffTarget_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("BuffTarget_A", 36) -- key F8
    end

    SetDispelKeyMacroBar()

    AAAMB.Methods.KMB.MoveSpellToBar("Revive", 37)
    AAAMB.Methods.KMB.MoveSpellToBar("Rebirth", 38)
end


local function PostInit()
    local buff_spell = GetSpellInfo("Mark of The Wild")
    if buff_spell then
        buffs = true
    end

    buff_spell = GetSpellInfo("Thorns")
    if buff_spell then
        thorns = true
    end

    local name = UnitName("player")
    if AAAMB.healer == name then
        is_healer = true
        AAAMB.Methods.Templates.Druid.Healer.Init()
    end

    local curse_spell = GetSpellInfo(CURSE_DISPEL_SPELL_NAME)
    if curse_spell then
        curse_dispel = true
    end

    local poison_spell = GetSpellInfo(POISON_DISPEL_SPELL_NAME)
    if poison_spell then
        poison_dispel = true
    end
end


local function OnUpdate(self, delta)
    dispel_time = dispel_time + delta
    if dispel_time >= 0.2 then -- 200 ms
        dispel_time = 0
        CheckDispels()
    end

    buffs_time = buffs_time + delta
    if buffs_time >= 5 then -- 5000 ms / 5 sec
        buffs_time = 0
        CheckBuffs()
    end
end


function AAAMB.Methods.Templates.Druid.Init()
    frame = CreateFrame("Frame", "AAAMB_Druid_Frame", UIParent)
    buffs_tsf = AAAMB.Methods.CreateTSF("Druid_Buffs", 210, 0)
    curse_dispel_tsf = AAAMB.Methods.CreateTSF("Druid_Curse_Dispel", 90, -75)
    poison_dispel_tsf = AAAMB.Methods.CreateTSF("Druid_Poison_Dispel", 120, -75)
    
    SetKeyMacroBar()
    PostInit()

    frame:SetScript("OnUpdate", OnUpdate)
end
