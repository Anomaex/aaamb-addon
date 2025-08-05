
local frame = nil
local buffs_time = 0
local seal_name = nil
local bless_name = ""
local small_bless_name = ""
local check_buffs = nil
local buffs_tsf = nil
local dispel_name = ""
local dispel_tsf = nil
local dispel_magic = false
local time = 0
local is_healer = false


function AAAMB.Methods.Templates.Paladin.Reset()
    buffs_tsf:SetVertexColor(0, 0, 0, 1) -- black
end


local function CheckDispel(unit, color)
    for i = 1, 40 do
        local name, _, _, _, debuff_type, _, exp_time, _, _, _, spell_id = UnitDebuff(unit, i, 1)
        if not name then break end
        local magic = false
        if debuff_type == "Magic" and dispel_magic then
            magic = true
        end
        if magic or debuff_type == "Disease" or debuff_type == "Poison" then
            local time_left = exp_time - GetTime()
            if time_left > 1 then
                dispel_tsf:SetVertexColor(color[1], color[2], color[3], 1)
                return true
            end
        --SendChatMessage("Debuff: " .. name .. ", id: " .. spell_id, "PARTY")
        end
    end
    return false
end


local function GetUnitState(unit, range_spell)
    if unit and range_spell ~= "" then 
        local is_connected = UnitIsConnected(unit)
        if is_connected then
            local is_dead = UnitIsDead(unit)
            if not is_dead then
                local is_ghost = UnitIsGhost(unit)
                if not is_ghost then
                    local in_range = IsSpellInRange(range_spell, unit)
                    if in_range then
                        return true
                    end
                end
            end
        end
    end
    return false
end


local function CheckDispels()
    local is_ok = false

    local tank = GetUnitState(AAAMB.tank, dispel_name)
    if tank then
        is_ok = CheckDispel(AAAMB.tank, {0, 1, 0}) -- green
        if is_ok then return end
    end

    local healer = GetUnitState(AAAMB.healer, dispel_name)
    if healer then
        is_ok = CheckDispel(AAAMB.healer, {0, 0, 1}) -- blue
        if is_ok then return end
    end

    if not is_healer then
        local player = GetUnitState("player", dispel_name)
        if player then
            is_ok = CheckDispel("player", {1, 1, 1}) -- white
            if is_ok then return end
        end
    end

    local damager_f = GetUnitState(AAAMB.damagers[1], dispel_name)
    if damager_f then
        is_ok = CheckDispel(AAAMB.damagers[1], {1, 1, 0}) -- yellow
        if is_ok then return end
    end

    local damager_s = GetUnitState(AAAMB.damagers[2], dispel_name)
    if damager_s then
        is_ok = CheckDispel(AAAMB.damagers[2], {1, 0, 0}) -- red
        if is_ok then return end
    end

    if is_healer then
        local damager_t = GetUnitState(AAAMB.damagers[3], dispel_name)
        if damager_t then
            is_ok = CheckDispel(AAAMB.damagers[3], {1, 0, 1}) -- purple
            if is_ok then return end
        end
    end

    dispel_tsf:SetVertexColor(0, 0, 0, 1) -- black
end


local function CheckBuff(unit, color, buff)
    if not buff or buff == "" then return end
    local name, _, _, _, _, _, exp_time = UnitBuff(unit, buff)
    if name then
        local time_left = exp_time - GetTime()
        if time_left < 200 then -- 2 min
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
    
    local is_ok = CheckBuff("player", {0, 1, 1}, seal_name) -- aqua
    if is_ok then return end

    if InCombatLockdown() then return end

    local tank = GetUnitState(AAAMB.tank, bless_name)
    if tank then
        is_ok = CheckBuff(AAAMB.tank, {0, 1, 0}, bless_name) -- green
        if is_ok then return end
    end

    local healer = GetUnitState(AAAMB.healer, bless_name)
    if healer then
        is_ok = CheckBuff(AAAMB.healer, {0, 0, 1}, bless_name) -- blue
        if is_ok then return end
    end

    local damager_f = GetUnitState(AAAMB.damagers[1], bless_name)
    if damager_f then
        is_ok = CheckBuff(AAAMB.damagers[1], {1, 1, 0}, bless_name) -- yellow
        if is_ok then return end
    end

    local damager_s = GetUnitState(AAAMB.damagers[2], bless_name)
    if damager_s then
        is_ok = CheckBuff(AAAMB.damagers[2], {1, 0, 0}, bless_name) -- red
        if is_ok then return end
    end

    if is_healer then
        local damager_t = GetUnitState(AAAMB.damagers[3], bless_name)
        if damager_s then
            is_ok = CheckBuff(AAAMB.damagers[3], {1, 0, 1}, bless_name) -- purple
            if is_ok then return end
        end
    else
        is_ok = CheckBuff("player", {1, 1, 1}, bless_name) -- white
        if is_ok then return end
    end
end


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.2 then
        time = 0
        if dispel_name ~= "" then
            CheckDispels()
        end
    end

    buffs_time = buffs_time + delta
    if buffs_time >= 5 then -- 5000 ms / 5 sec
        buffs_time = 0
        if check_buffs then
            check_buffs()
        end
    end
end


local function GetSealNameSpell()
    local header = "Seal of "
    local s = "Righteousness"
    local s_command = GetSpellInfo("Seal of Command")
    if s_command then
        s = "Command"
    else
        local s_wisdom = GetSpellInfo("Seal of Wisdom")
        if s_wisdom then
            s = "Wisdom"
        else
            local s_justice = GetSpellInfo("Seal of Justice")
            if s_justice then
                s = "Justice"
            end
        end
    end
    s = header .. s
    return s
end


local function SetDispelKeyMacroBar()
    local dispel_spell = GetSpellInfo("Purify")
    if not dispel_spell then return end
    dispel_name = "Purify"
    dispel_spell = GetSpellInfo("Cleanse")
    if dispel_spell then
        dispel_name = "Cleanse"
        dispel_magic = true
    end

    -- Tank, Healer and Self
    local macrobody = "/cast [nomod,target=" .. (AAAMB.tank or "") .. "] " .. dispel_name
    macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.healer or "") .. "] " .. dispel_name
    macrobody = macrobody .. "\n/cast [mod:ctrl,target=player] " .. dispel_name
    AAAMB.Methods.KMB.CreateAccountMacro("Dispel_0_A", macrobody)
    AAAMB.Methods.KMB.MoveMacroToBar("Dispel_0_A", 49) -- key y

    -- Damagers
    local macrobody = "/cast [nomod,target=" .. (AAAMB.damagers[1] or "") .. "] " .. dispel_name
    macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.damagers[2] or "") .. "] " .. dispel_name
    macrobody = macrobody .. "\n/cast [mod:ctrl,target=" .. (AAAMB.damagers[3] or "") .. "] " .. dispel_name
    AAAMB.Methods.KMB.CreateAccountMacro("Dispel_1_A", macrobody)
    AAAMB.Methods.KMB.MoveMacroToBar("Dispel_1_A", 50) -- key u
end


local function SetAutoBuffsKeyMacroBar()
    local name = UnitName("player")
    for i = 1, 3 do
        if AAAMB.char_names.damagers[i] == name then
            if i == 1 then
                local flag = GetSpellInfo("Blessing of Might")
                bless_name = flag and "Blessing of Might" or ""
                small_bless_name = flag and "Blessing of Might" or ""
                break
            elseif i == 2 then
                local flag = GetSpellInfo("Blessing of Kings")
                bless_name = flag and "Blessing of Kings" or ""
                small_bless_name = flag and "Blessing of Kings" or ""
            elseif i == 3 then
                local flag = GetSpellInfo("Blessing of Wisdom")
                bless_name = flag and "Blessing of Wisdom" or ""
                small_bless_name = flag and "Blessing of Wisdom" or ""
            end
        end
    end

    local bless = GetSpellInfo("Greater " .. bless_name)
    if bless then
        local can_use = IsUsableSpell("Greater " .. bless_name)
        if can_use then
            bless_name = "Greater " .. bless_name
        else
            local link = GetSpellLink("Greater " .. bless_name)
            SendChatMessage("Not have reagents for " .. link, "PARTY")
        end
    end

    -- Tank and Healer
    local macrobody = "/cast [nomod,target=" .. (AAAMB.tank or "") .. "] " .. bless_name
    macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.healer or "") .. "] " .. bless_name
    macrobody = macrobody .. "\n/script AAAMB.Methods.Templates.Paladin.Reset()"
    AAAMB.Methods.KMB.CreateAccountMacro("Buffs_0_A", macrobody)
    AAAMB.Methods.KMB.MoveMacroToBar("Buffs_0_A", 33) -- key F5

    -- Damagers
    local macrobody = "/cast [nomod,target=" .. (AAAMB.damagers[1] or "") .. "] " .. bless_name
    macrobody = macrobody .. "\n/cast [mod:shift,target=" .. (AAAMB.damagers[2] or "") .. "] " .. bless_name
    macrobody = macrobody .. "\n/cast [mod:ctrl,target=" .. (AAAMB.damagers[3] or "") .. "] " .. bless_name
    macrobody = macrobody .. "\n/script AAAMB.Methods.Templates.Paladin.Reset()"
    AAAMB.Methods.KMB.CreateAccountMacro("Buffs_1_A", macrobody)
    AAAMB.Methods.KMB.MoveMacroToBar("Buffs_1_A", 34) -- key F6

    -- Self buff and seal
    seal_name = GetSealNameSpell()
    local macrobody = "/cast [nomod,target=player] " .. bless_name
    macrobody = macrobody .. "\n/cast [mod:shift] " .. seal_name
    macrobody = macrobody .. "\n/script AAAMB.Methods.Templates.Paladin.Reset()"
    AAAMB.Methods.KMB.CreateAccountMacro("Buffs_2_A", macrobody)
    AAAMB.Methods.KMB.MoveMacroToBar("Buffs_2_A", 35) -- key F7
end


local function SetKeyMacroBar()
    SetAutoBuffsKeyMacroBar()

    if AAAMB.tank then
        local macrobody = "/target ".. AAAMB.tank
        macrobody = macrobody .. "\n/castsequence [@targettarget] reset=2 " .. small_bless_name .. ",,,"
        AAAMB.Methods.KMB.CreateAccountMacro("BuffTarget_A", macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("BuffTarget_A", 36) -- key F8
    end

    SetDispelKeyMacroBar()

    AAAMB.Methods.KMB.MoveSpellToBar("Judgement of Light", 1) -- key q
    AAAMB.Methods.KMB.MoveSpellToBar("Redemption", 37)
    AAAMB.Methods.KMB.MoveSpellToBar("Divine Shield", 11)
    AAAMB.Methods.KMB.MoveSpellToBar("Every Man for Himself", 12)
end


local function PostInit()
    local bless = GetSpellInfo(bless_name)
    if bless or seal_name then
        check_buffs = CheckBuffs
    end

    local name = UnitName("player")
    if AAAMB.healer == name then
        is_healer = true
        -- healer init
    else
        for i = 1, 3 do
            if AAAMB.char_names.damagers[i] == name then
                AAAMB.Methods.Templates.Paladin.Damager.Init()
                break
            end
        end
    end
end


function AAAMB.Methods.Templates.Paladin.Init()
    frame = CreateFrame("Frame", "AAAMB_Paladin_Frame", UIParent)
    buffs_tsf = AAAMB.Methods.CreateTSF("Paladin_Buffs", 210, 0)
    dispel_tsf = AAAMB.Methods.CreateTSF("Paladin_Dispels", 90, -75)

    SetKeyMacroBar()
    PostInit()

    frame:SetScript("OnUpdate", OnUpdate)
end
