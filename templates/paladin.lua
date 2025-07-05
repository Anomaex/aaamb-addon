
local frame = nil
local seal_dispel_tsf = nil
local seal_time = 0
local seal = nil


local function GetHoFMacrobody()
    local hof = GetSpellInfo("Hand of Freedom")
    if hof then
        local macro_body = "/cast [target=player] Hand of Freedom"
        return macro_body
    end
    return false
end


local function GetDispelMacrobody()
    local spell = ""
    local cleanse = GetSpellInfo("Cleanse")
    if cleanse then
        spell = "Cleanse"
    else
        local purify = GetSpellInfo("Purify")
        if purify then
            spell = "Purify"
        end
    end
    if spell ~= "" then
        local macro_body = "/cast [target=player] "
        macro_body = macro_body .. spell
        return macro_body
    end
    return false
end


local function GetBuffTargetMacrobody()
    local bless = GetSpellInfo("Blessing of Might")
    if bless then
        local macro_body = "/cast [target=player] Blessing of Might"
        return macro_body
    end
    return false
end


local function GetSealSpell()
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


local function SetKeyMacroBar()
    seal = GetSealSpell()
    AAAMB.Methods.KMB.MoveSpellToBar(seal, 1) -- key q

    local bufftarget_macrobody = GetBuffTargetMacrobody()
    if bufftarget_macrobody then
        AAAMB.Methods.KMB.CreateCharMacro("BuffTarget_A", bufftarget_macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("BuffTarget_A", 2) -- key e
    end

    local dispel_macrobody = GetDispelMacrobody()
    if dispel_macrobody then
        AAAMB.Methods.KMB.CreateCharMacro("Dispel_A", dispel_macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("Dispel_A", 10) -- key v
    end

    local hof_macrobody = GetHoFMacrobody()
    if hof_macrobody then
        AAAMB.Methods.KMB.CreateCharMacro("HoF_A", hof_macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("HoF_A", 9) -- key c
    end

    AAAMB.Methods.KMB.MoveSpellToBar("Redemption", 28)
    AAAMB.Methods.KMB.MoveSpellToBar("Divine Shield", 11)
    AAAMB.Methods.KMB.MoveSpellToBar("Every Man for Himself", 12)
end


function AAAMB.Methods.Templates.Paladin.CheckDispel(unit, texture, check_only)
    local is_exists = UnitExists(unit)
    local is_connected = UnitIsConnected(unit)
    local is_enemy = UnitIsEnemy("player", unit)
    local in_range = IsSpellInRange("Holy Light", AAAMB.tank)
    local is_visible = UnitIsVisible(AAAMB.tank)
    if not in_range or not is_visible or not is_exists or not is_connected or is_enemy then
        if check_only then return false end
        texture:SetVertexColor(0, 1, 0, 1) -- green
        return false
    end

    local debuff = false
    for i = 1, 40 do
        local name, _, _, _, debuff_type, _, exp_time, _, _, _, spell_id = UnitDebuff(unit, i, 1)
        if not name then break end
        
        if debuff_type == "Magic" or debuff_type == "Disease" or debuff_type == "Poison" then
            local time_left = exp_time - GetTime()
            if time_left > 1 then
                if check_only then return true end
                texture:SetVertexColor(1, 0, 0, 1) -- red
                debuff = true
            end
        --SendChatMessage("Debuff: " .. name .. ", id: " .. spell_id, "PARTY")
        end
    end
    
    if not debuff then
        if not check_only then
            texture:SetVertexColor(0, 1, 0, 1) -- green
        end
        return false
    end
    return true
end


local function CheckSealDispel()
    local is_dispel = AAAMB.Methods.Templates.Paladin.CheckDispel("player", seal_dispel_tsf)
    if not is_dispel then
        local name, _, _, _, _, _, exp_time = UnitAura("player", seal)
        if name then
            local time_left = exp_time - GetTime()
            if time_left > 300 then
                seal_dispel_tsf:SetVertexColor(0, 1, 0, 1) -- green
                return
            end
        end
        seal_dispel_tsf:SetVertexColor(0, 0, 1, 1) -- blue
    end
end


local function OnUpdate(self, delta)
    seal_time = seal_time + delta
    if seal_time >= 5 then -- 5000 ms
        seal_time = 0
        CheckSealDispel()
    end
end


local function OnEvent(self, event, arg1, ...)
    if event == "UNIT_AURA" then
        if arg1 == "player" then
            CheckSealDispel()
        end
    end
end


local function Postinit()
    if AAAMB.healer == "player" then
        AAAMB.Methods.Templates.Paladin.Healer.Init()
    else
        local found = false
        local name = UnitName("player")
        for i = 1, 3 do
            if AAAMB.char_names.damagers[i] == name then
                found = true
                break
            end
        end
        if found then
            AAAMB.Methods.Templates.Paladin.Damager.Init()
        end
    end
end


function AAAMB.Methods.Templates.Paladin.Init()
    frame = CreateFrame("Frame", "AAAMB_Paladin_Frame", UIParent)
    seal_dispel_tsf = AAAMB.Methods.CreateTSF("Paladin_Seal_Dispel", 210, 0)

    frame:RegisterEvent("UNIT_AURA")
    frame:SetScript("OnEvent", OnEvent)
    frame:SetScript("OnUpdate", OnUpdate)
    
    SetKeyMacroBar()
    Postinit()
end
