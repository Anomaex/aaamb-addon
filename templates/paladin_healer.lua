
local frame = nil
local party_health_tsfs = {nil, nil, nil, nil} -- 1 - tank, 2 - damager f, 3 - damager s, 4 - damager t
local party_dispel_tsf = nil
local time = 0
local time_dispel = 0
local jow_df_tsf = nil
local is_jow = false
local is_df = false
local hs_iol_tsf = nil
local bol_tsf = nil
local time_bol = 0
local mana_potion = nil


local function ScanMana(percent, texture)
    if InCombatLockdown() then
        if percent < 50 then
            if percent < 10 and mana_potion then
                local cd = GetItemCooldown(mana_potion)
                if cd == 0 then
                    texture:SetVertexColor(1, 1, 0, 1) -- yellow
                    return
                end
            end
            local di = GetSpellCooldown("Divine Illumination")
            if di == 0 then
                texture:SetVertexColor(0, 0, 1, 1) -- blue
                return
            end
        end
    end
    texture:SetVertexColor(0, 1, 0, 1) -- green
end


local function GetPerfectManaItem(items)
    local mana_item = nil
    local max_item_level = -1
    for i = 1, #items do
        local item = items[i]
        if item[3] > max_item_level then
            mana_item = item
            max_item_level = item[3]
        end
    end
    return mana_item
end


local function IsItemForMana(item_link)
    local tooltip = CreateFrame("GameTooltip", "MyItemTooltip", UIParent, "GameTooltipTemplate")
    tooltip:SetOwner(UIParent, "ANCHOR_NONE")
    tooltip:SetHyperlink(item_link)
    tooltip:Show()
    for i = 2, 6 do
        local line = _G["MyItemTooltipTextLeft" .. i]
        if line then
            local text = line:GetText()
            if text and string.find(string.lower(text), "mana") then
                tooltip:Hide()
                tooltip = nil
                return true
            end
        end
    end
    tooltip:Hide()
    tooltip = nil
end


local function SetDrinkPotionToBar()
    local drinks = {}
    local potions = {}

    for bag = 0, 4 do
        local num_slots = GetContainerNumSlots(bag)
        for slot = 1, num_slots do
            local item_link = GetContainerItemLink(bag, slot)
            if item_link then
                local item_name, _, _, _, req_min_level, item_type, item_sub_type = GetItemInfo(item_link)
                if req_min_level then
                    local self_lvl = UnitLevel("player")
                    if req_min_level <= self_lvl and item_type == "Consumable" then
                        if item_sub_type == "Food & Drink" then
                            if IsItemForMana(item_link) then
                                table.insert(drinks, {bag, slot, req_min_level, item_name})
                            end
                        elseif item_sub_type == "Potion" then
                            if IsItemForMana(item_link) then
                                table.insert(potions, {bag, slot, req_min_level, item_name})
                            end
                        end
                    end
                end
            end
        end
    end

    local item = GetPerfectManaItem(drinks)
    if item then
        AAAMB.Methods.KMB.MoveItemToBar(item[1], item[2], 25)
    end

    item = GetPerfectManaItem(potions)
    if item then
        mana_potion = item[4]
        AAAMB.Methods.KMB.MoveItemToBar(item[1], item[2], 26)
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
    if AAAMB.damagers[3] then
        is_dispel = AAAMB.Methods.Templates.Paladin.CheckDispel(AAAMB.damagers[3], nil, true)
        if is_dispel then
            party_dispel_tsf:SetVertexColor(1, 0, 0, 1) -- red
            return
        end
    end
    if AAAMB.damagers[2] then
        is_dispel = AAAMB.Methods.Templates.Paladin.CheckDispel(AAAMB.damagers[2], nil, true)
        if is_dispel then
            party_dispel_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
            return
        end
    end
    if AAAMB.damagers[1] then
        is_dispel = AAAMB.Methods.Templates.Paladin.CheckDispel(AAAMB.damagers[1], nil, true)
        if is_dispel then
            party_dispel_tsf:SetVertexColor(0, 0, 1, 1) -- blue
            return
        end
    end

    party_dispel_tsf:SetVertexColor(0, 1, 0, 1) -- green
end 


local function CheckJoWDF()
    local jow_cd = 1
    if is_jow then
        local is_exists = UnitExists("target")
        if is_exists then
            local is_death = UnitIsDead("target")
            if not is_death then
                local is_friend = UnitIsFriend("player", "target")
                if not is_friend and InCombatLockdown() then
                    jow_cd = GetSpellCooldown("Judgement of Wisdom")
                end
            end
        end
    end

    if is_df then
        local df_cd = GetSpellCooldown("Divine Favor")
        if df_cd == 0 then
            if jow_cd == 0 then
                jow_df_tsf:SetVertexColor(0, 0, 1, 1) -- blue
            else
                jow_df_tsf:SetVertexColor(0, 1, 0, 1) -- green
            end
        else
            if jow_cd == 0 then
                jow_df_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
            else
                jow_df_tsf:SetVertexColor(1, 0, 0, 1) -- red
            end
        end
    end
end


local function CheckPartyHealth()
    AAAMB.Methods.ScanHealth(AAAMB.tank, party_health_tsfs[1])
    for i = 1, 3 do
        AAAMB.Methods.ScanHealth(AAAMB.damagers[i], party_health_tsfs[i + 1])
    end
end


local function CheckBoL()
    if AAAMB.tank then
        if InCombatLockdown() then
            local is_death = UnitIsDead(AAAMB.tank)
            local is_ghost = UnitIsGhost(AAAMB.tank)
            local is_exists = UnitExists(AAAMB.tank)
            local is_enemy = UnitIsEnemy("player", AAAMB.tank)
            local in_range = IsSpellInRange("Holy Light", AAAMB.tank)
            local is_visible = UnitIsVisible(AAAMB.tank)
            if not is_visible or not in_range or is_death or is_ghost or not is_exists or is_enemy then
                bol_tsf:SetVertexColor(0, 1, 0, 1) -- green
                return
            end

            local name, _, _, _, _, _, exp_time = UnitAura(AAAMB.tank, "Beacon of Light")
            if name then
                local time_left = exp_time - GetTime()
                if time_left > 4 then
                    bol_tsf:SetVertexColor(1, 0, 0, 1) -- red
                else
                    bol_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
                end
            else
                bol_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
            end
            return
        end
    end
    bol_tsf:SetVertexColor(0, 1, 0, 1) -- green
end


local function CheckHSIoL()
    local hs = GetSpellCooldown("Holy Shock")
    local iol = UnitAura("player", "Infusion of Light")
    if hs == 0 and iol then
        hs_iol_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
    elseif hs == 0 then
        hs_iol_tsf:SetVertexColor(0, 1, 0, 1) -- green
    elseif iol then
        hs_iol_tsf:SetVertexColor(1, 0, 0, 1) -- red
    else
        hs_iol_tsf:SetVertexColor(0, 1, 1, 1) -- aqua
    end
end


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.1 then -- 100 ms
        time = 0
        CheckHSIoL()
        CheckPartyHealth()
    end

    time_dispel = time_dispel + delta
    if time_dispel >= 0.2 then -- 200 ms
        time_dispel = 0
        CheckPartyDispel()
    end

    time_bol = time_bol + delta
    if time_bol >= 0.3 then -- 300 ms
        time_bol = 0
        CheckJoWDF()
        CheckBoL()
    end
end


local function OnEvent(self, event, arg1, ...)
    if event == "UNIT_AURA" then
        if arg1 == AAAMB.tank then
            CheckBoL()
        end
    end
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
        if AAAMB.damagers[1] then
            macro_body = macro_body .. "\n/cast [mod:shift,target=" .. AAAMB.damagers[1] .. "] " .. spell
        end
        if AAAMB.damagers[2] then
            macro_body = macro_body .. "\n/cast [mod:ctrl,target=" .. AAAMB.damagers[2] .. "] " .. spell
        end
        if AAAMB.damagers[3] then
            macro_body = macro_body .. "\n/cast [mod:alt,target=" .. AAAMB.damagers[3] .. "] " .. spell
        end
    end
    if macro_body == "" then return false end
    return macro_body
end


local function GetBuffTargetMacrobody()
    local bless = GetSpellInfo("Blessing of Wisdom")
    if not bless then return false end
    local target = "target=" .. (AAAMB.tank and AAAMB.tank or "player") .. "target,help,exists,nodead"
    local macro_body = "/cast [nomod," .. target .. "] "
    local great_bless = GetSpellInfo("Greater Blessing of Wisdom")
    if not great_bless then
        macro_body = macro_body .. "Blessing of Wisdom"
    else
        local can_use = IsUsableSpell("Greater Blessing of Wisdom")
        if not can_use then
            local link = GetSpellLink("Greater Blessing of Wisdom")
            SendChatMessage("Not have reagents for " .. link, "PARTY")
        end
        macro_body = macro_body .. "Greater Blessing of Wisdom"
        macro_body = macro_body .. "\n/cast [mod:ctrl," .. target .. "] Blessing of Wisdom"
    end
    return macro_body
end


local function SetHealMacroBar()
    local hs = GetSpellInfo("Holy Shock")

    local self_heal = "/cast [nomod,target=player] Holy Light"
    if hs then
        self_heal = self_heal .. "\n/cast [mod:shift,target=player] Holy Shock"
    end
    self_heal = self_heal .. "\n/cast [mod:ctrl,target=player] Flash of Light"
    AAAMB.Methods.KMB.CreateAccountMacro("Self_Heal_A", self_heal)
    AAAMB.Methods.KMB.MoveMacroToBar("Self_Heal_A", 50) -- key u

    if AAAMB.tank then
        local tank_heal = "/cast [nomod,target=" .. AAAMB.tank .. "] Holy Light"
        if hs then
            tank_heal = tank_heal .. "\n/cast [mod:shift,target=" .. AAAMB.tank .. ",help] Holy Shock"
        end
        tank_heal = tank_heal .. "\n/cast [mod:ctrl,target=" .. AAAMB.tank .. "] Flash of Light"
        AAAMB.Methods.KMB.CreateAccountMacro("Tank_Heal_A", tank_heal)
        AAAMB.Methods.KMB.MoveMacroToBar("Tank_Heal_A", 49) -- key y
    end

    for i = 1, 3 do
        local unit = AAAMB.damagers[i]
        if unit then
            local damager_heal = "/cast [nomod,target=" .. unit .. "] Holy Light"
            if hs then
                damager_heal = damager_heal .. "\n/cast [mod:shift,target=" .. unit .. ",help] Holy Shock"
            end
            damager_heal = damager_heal .. "\n/cast [mod:ctrl,target=" .. unit .. "] Flash of Light"
            AAAMB.Methods.KMB.CreateAccountMacro("Dmg_" .. i .. "_Heal_A", damager_heal)
            AAAMB.Methods.KMB.MoveMacroToBar("Dmg_" .. i .. "_Heal_A", 50 + i) -- key i, o, p
        end
    end
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

    local jow = GetSpellInfo("Judgement of Wisdom")
    if jow then
        is_jow = true
        AAAMB.Methods.KMB.MoveSpellToBar("Judgement of Wisdom", 3) -- key r
    end

    local df = GetSpellInfo("Divine Favor")
    if df then
        is_df = true
        AAAMB.Methods.KMB.MoveSpellToBar("Divine Favor", 4) -- key t
    end

    AAAMB.Methods.KMB.MoveSpellToBar("Divine Illumination", 5) -- key f

    if AAAMB.tank then
        local bol = GetSpellInfo("Beacon of Light")
        if bol then
            local bol_macrobody = "/cast [target=" .. AAAMB.tank .. "] Beacon of Light"
            AAAMB.Methods.KMB.CreateCharMacro("BoL_A", bol_macrobody)
            AAAMB.Methods.KMB.MoveMacroToBar("BoL_A", 6) -- key g
        end
    end

    SetHealMacroBar()
    SetDrinkPotionToBar()
end


function AAAMB.Methods.Templates.Paladin.Healer.Init()
    frame = CreateFrame("Frame", "AAAMB_Paladin_Healer_Frame", UIParent)

    party_health_tsfs[1] = AAAMB.Methods.CreateTSF("AAAMB_Paladin_Healer_Tank_Health", 0, -120)
    party_health_tsfs[2] = AAAMB.Methods.CreateTSF("AAAMB_Paladin_Healer_Damager_F_Health", 30, -120)
    party_health_tsfs[3] = AAAMB.Methods.CreateTSF("AAAMB_Paladin_Healer_Damager_S_Health", 60, -120)
    party_health_tsfs[4] = AAAMB.Methods.CreateTSF("AAAMB_Paladin_Healer_Damager_T_Health", 90, -120)

    party_dispel_tsf = AAAMB.Methods.CreateTSF("AAAMB_Paladin_Healer_Party_Dispel", 90, -75)
    
    jow_df_tsf = AAAMB.Methods.CreateTSF("JoW_DF", 240, 0) -- Judgement of Wisdom , Divine Favor
    hs_iol_tsf = AAAMB.Methods.CreateTSF("HS_IoL", 270, 0) -- Holy Shock, Infusion of Light
    bol_tsf = AAAMB.Methods.CreateTSF("BoL", 300, 0) -- Beacon of Light

    frame:SetScript("OnEvent", OnEvent)

    frame:RegisterEvent("UNIT_AURA")

    frame:SetScript("OnUpdate", OnUpdate)

    SetKeyMacroBar()

    AAAMB.Methods.ScanMana = ScanMana
end
