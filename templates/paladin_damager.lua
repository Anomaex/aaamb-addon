
local frame = nil
local party_dispel_tsf = nil
local time = 0
local damage_rotation_tsf = nil


local function Damage_Rotation_GetTargetHealth()
    local health = UnitHealth("target")
    local max_health = UnitHealthMax("target")
    local percent = 0
    if max_health > 0 then
        percent = (health / max_health) * 100
    end
    return percent
end


local function Damage_Rotation_JoL()
    local cd = GetSpellCooldown("Judgement of Light")
    if cd == 0 then
        local in_range = IsSpellInRange("Judgement of Light", "target") == 1
        if in_range then
            -- cast Judgement of Light
            damage_rotation_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
            return 0
        end
    end
    return 1
end


local function Damage_Rotation()
    if AAAMB.health_percent < 50 then
        local aura = UnitAura("player", "The Art of War")
        if aura then
            -- cast Flash of Light
            damage_rotation_tsf:SetVertexColor(0, 1, 1, 1) -- aqua
            return
        end
    end

    local is_combat = InCombatLockdown()
    local is_attack = false
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
        damage_rotation_tsf:SetVertexColor(0, 1, 0, 1) -- green
        return
    end

    local cd = -1
    
    if AAAMB.mana_percent < 50 then
        cd = Damage_Rotation_JoL()
        if cd == 0 then
            return
        end
    end

    local is_usable = IsUsableSpell("Hammer of Wrath")
    if is_usable then
        cd = GetSpellCooldown("Hammer of Wrath")
        if cd == 0 then
            -- cast Hammer of Wrath
            damage_rotation_tsf:SetVertexColor(1, 1, 1, 1) -- white
            return
        end
    end

    cd = GetSpellCooldown("Divine Storm")
    if cd == 0 then
        local in_range = IsSpellInRange("Crusader Strike", "target") == 1
        if in_range then
            -- cast Divine Storm
            damage_rotation_tsf:SetVertexColor(1, 0, 0, 1) -- red
            return
        end
    end

    cd = Damage_Rotation_JoL()
    if cd == 0 then
        return
    end

    cd = GetSpellCooldown("Crusader Strike")
    if cd == 0 then
        local in_range = IsSpellInRange("Crusader Strike", "target") == 1
        if in_range then
            -- cast Crusader Strike
            damage_rotation_tsf:SetVertexColor(0, 0, 1, 1) -- blue
            return
        end
    end

    local aura = UnitAura("player", "The Art of War")
    if aura then
        cd = GetSpellCooldown("Exorcism")
        if cd == 0 then
            -- cast Exorcism
            damage_rotation_tsf:SetVertexColor(1, 0, 1, 1) -- purple
            return
        end
    end

    cd = GetSpellCooldown("Holy Wrath")
    if cd == 0 then
        local creature_type = UnitCreatureType("target")
        if creature_type == "Undead" or creature_type == "Demon" then
            local in_range = IsSpellInRange("Crusader Strike", "target") == 1
            -- cast Holy Wrath
            if in_range then
                damage_rotation_tsf:SetVertexColor(1, 0.75, 0.8, 1) -- розовый (pink)
                return
            end
        end
    end


    if AAAMB.mana_percent > 50 then
        local target_health = Damage_Rotation_GetTargetHealth()
        if target_health > 30 then
            cd = GetSpellCooldown("Consecration")
            if cd == 0 then
                local in_range = IsSpellInRange("Crusader Strike", "target") == 1
                -- cast Consecration
                if in_range then
                    damage_rotation_tsf:SetVertexColor(0, 0, 0, 1) -- black
                    return
                end
            end
        end
    end

    damage_rotation_tsf:SetVertexColor(0, 1, 0, 1) -- green
end


local function GetBuffTargetMacrobody()
    local name = UnitName("player")
    local bless = ""
    if name == "Raifanzen" then
        bless = "Might"
    elseif name == "Bashscript" then
        bless = "Kings"
    end
    if bless == "" then
        return ""
    end

    local target = "target=" .. (AAAMB.tank and AAAMB.tank or "player") .. "target,help,exists,nodead"
    local macro_body = "/cast [nomod," .. target .. "] "
    local great_bless = GetSpellInfo("Greater Blessing of " .. bless)
    if not great_bless then
        macro_body = macro_body .. "Blessing of " .. bless
    else
        local can_use = IsUsableSpell("Greater Blessing of " .. bless)
        if not can_use then
            local link = GetSpellLink("Greater Blessing of " .. bless)
            SendChatMessage("Not have reagents for " .. link, "PARTY")
        end
        macro_body = macro_body .. "Greater Blessing of " .. bless
        macro_body = macro_body .. "\n/cast [mod:ctrl," .. target .. "] Blessing of " .. bless
    end
    return macro_body
end


local function GetConsecrationHW_Macrobody()
    if not AAAMB.tank then return false end
    local macro_body = "/cast [nomod,target=player] Consecration"
    macro_body = macro_body .. "\n/cast [mod:shift,target=" .. AAAMB.tank .. "target] Holy Wrath"
    return macro_body
end


local function GetExorcismFoL_Macrobody()
    if not AAAMB.tank then return false end
    local macro_body = "/cast [nomod,target=player] Flash of Light"
    macro_body = macro_body .. "\n/cast [mod:shift,target=" .. AAAMB.tank .. "target] Exorcism"
    return macro_body
end


local function GetDispelPartyMacrobody()
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
    local macro_body = ""
    if spell ~= "" then
        if AAAMB.tank then
            macro_body = "/cast [nomod,target=" .. AAAMB.tank .. "] " .. spell
        end
        if AAAMB.healer then
            macro_body = macro_body .. "\n/cast [mod:shift,target=" .. AAAMB.healer .. "] " .. spell
        end
        if AAAMB.damagers[1] then
            macro_body = macro_body .. "\n/cast [mod:ctrl,target=" .. AAAMB.damagers[1] .. "] " .. spell
        end
        if AAAMB.damagers[2] then
            macro_body = macro_body .. "\n/cast [mod:alt,target=" .. AAAMB.damagers[2] .. "] " .. spell
        end
    end
    if macro_body == "" then return false end
    return macro_body
end


local function SetKeyMacroBar()
    local dispelparty_macrobody = GetDispelPartyMacrobody()
    if dispelparty_macrobody then
        AAAMB.Methods.KMB.CreateAccountMacro("DispelParty_A", dispelparty_macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("DispelParty_A", 54) -- key h
    end
    
    local bufftarget_macrobody = GetBuffTargetMacrobody()
    if bufftarget_macrobody then
        AAAMB.Methods.KMB.EditMacro("BuffTarget_A", bufftarget_macrobody)
    end

    AAAMB.Methods.KMB.MoveSpellToBar("Judgement of Light", 3) -- key r
    AAAMB.Methods.KMB.MoveSpellToBar("Hammer of Wrath", 4) -- key t
    AAAMB.Methods.KMB.MoveSpellToBar("Crusader Strike", 5) -- key f
    AAAMB.Methods.KMB.MoveSpellToBar("Divine Storm", 6) -- key g

    local exorcism_fol = GetExorcismFoL_Macrobody()
    if exorcism_fol then
        AAAMB.Methods.KMB.CreateAccountMacro("ExorcismFoL_A", GetExorcismFoL_Macrobody())
        AAAMB.Methods.KMB.MoveMacroToBar("ExorcismFoL_A", 7) -- key z
    end

    local consecration_hw = GetConsecrationHW_Macrobody()
    if consecration_hw then
        AAAMB.Methods.KMB.CreateAccountMacro("ConsecrationHW_A", GetConsecrationHW_Macrobody())
        AAAMB.Methods.KMB.MoveMacroToBar("ConsecrationHW_A", 8) -- key x
    end
end


local function CheckPartyDispel()
    local is_dispel = false
    if AAAMB.tank then
        is_dispel = AAAMB.Methods.Templates.Paladin.CheckDispel(AAAMB.tank, nil, true)
        if is_dispel then
            party_dispel_tsf:SetVertexColor(1, 0, 1, 1) -- purple
            return
        end
    end
    if AAAMB.healer then
        is_dispel = AAAMB.Methods.Templates.Paladin.CheckDispel(AAAMB.healer, nil, true)
        if is_dispel then
            party_dispel_tsf:SetVertexColor(0, 0, 1, 1) -- blue
            return
        end
    end
    if AAAMB.damagers[1] then
        is_dispel = AAAMB.Methods.Templates.Paladin.CheckDispel(AAAMB.damagers[1], nil, true)
        if is_dispel then
            party_dispel_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
            return
        end
    end
    if AAAMB.damagers[2] then
        is_dispel = AAAMB.Methods.Templates.Paladin.CheckDispel(AAAMB.damagers[2], nil, true)
        if is_dispel then
            party_dispel_tsf:SetVertexColor(1, 0, 0, 1) -- red
            return
        end
    end

    party_dispel_tsf:SetVertexColor(0, 1, 0, 1) -- green
end 


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.2 then -- 200 ms
        time = 0
        CheckPartyDispel()
        Damage_Rotation()
    end
end


function AAAMB.Methods.Templates.Paladin.Damager.Init()
    frame = CreateFrame("Frame", "AAAMB_Paladin_Damager_Frame", UIParent)

    party_dispel_tsf = AAAMB.Methods.CreateTSF("AAAMB_Paladin_Damager_Party_Dispel", 90, -75)
    damage_rotation_tsf = AAAMB.Methods.CreateTSF("AAAMB_Paladin_Damager_Damage_Rotation", 240, 0)

    frame:SetScript("OnUpdate", OnUpdate)

    SetKeyMacroBar()
end
