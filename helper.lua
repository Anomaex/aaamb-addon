--
-- Auto accept Party Invite Request
-- Auto accept Ressurect Request
-- Texture Square Frame
-- Scan mount state
-- Colors:
--  SetVertexColor(0, 0, 0, 1) -- black
--  SetVertexColor(0, 1, 0, 1) -- green
--  SetVertexColor(0, 0, 1, 1) -- blue
--  SetVertexColor(1, 1, 0, 1) -- yellow
--  SetVertexColor(1, 0, 0, 1) -- red
--  SetVertexColor(1, 0, 1, 1) -- purple
--  SetVertexColor(0, 1, 1, 1) -- aqua
--  SetVertexColor(1, 1, 1, 1) -- white
--


local frame = nil
local time = 0
local is_trade = false
local t_m_c_fp_lfgin_tsf = nil
local is_lfg_in = false


function AAAMB.Methods.Helper.GetUnitState(unit, range_spell)
    if unit then
        if UnitIsConnected(unit) then
            if UnitExists(unit) then
                if not UnitIsDead(unit) then
                    if not UnitIsGhost(unit) then
                        if range_spell then 
                            if IsSpellInRange(range_spell, unit) then
                                return true
                            end
                        end
                    end
                end
            end
        end
    end
    return false
end


function AAAMB.Methods.Helper.FindItemInBag(category)
    local items = {}
    local best_item = nil

    for bag = 0, 4 do
        if GetBagName(bag) then
            local numSlots = GetContainerNumSlots(bag)
            for slot = 1, numSlots do
                local id = GetContainerItemID(bag, slot)
                if id then
                    local name, _, _, _, item_min_lvl, item_type, item_sub_type = GetItemInfo(id)
                    if item_type == "Consumable" then
                        if item_sub_type == category then
                            local item = {bag, slot, id, item_min_lvl}
                            table.insert(items, item)
                        end
                    end
                end
            end
        end
    end

    for i, v in ipairs(items) do
        if not best_item or v[4] > best_item[4] then
            if v[4] <= UnitLevel("player") then
                best_item = v
            end
        end
    end

    if best_item then
        return best_item
    end

    return nil
end


-- Trade, Mount, Cast, Follow Paused, LFG tp In
local function Check_T_M_C_FP_LFGIn()
    if is_lfg_in then
        t_m_c_fp_lfgin_tsf:SetVertexColor(1, 1, 1, 1) -- white
    elseif is_trade then
        t_m_c_fp_lfgin_tsf:SetVertexColor(0, 1, 0, 1) -- green
    elseif IsMounted() then
        t_m_c_fp_lfgin_tsf:SetVertexColor(0, 0, 1, 1) -- blue
    else
        local spell_name = UnitCastingInfo("player")
        if spell_name or AAAMB.follow_paused then
            t_m_c_fp_lfgin_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
        else
            t_m_c_fp_lfgin_tsf:SetVertexColor(0, 0, 0, 1) -- black
        end
    end
end


-- Create Texture Square Frame for AHK2 scanning
function AAAMB.Methods.CreateTSF(name, x, y)
    local square = CreateFrame("Frame", "AAAMB_TS_" .. name .. "_Frame", UIParent)
    square:SetSize(25, 25)
    square:SetPoint("TOPLEFT", UIParent, "TOPLEFT", x, y)
    square:SetFrameStrata("HIGH")
    square:Show()
    local texture = square:CreateTexture(nil, "BACKGROUND")
    texture:SetAllPoints()
    texture:SetTexture("Interface\\Buttons\\WHITE8x8")  -- white texture square
    texture:SetVertexColor(0, 0, 0, 1) -- black
    return texture
end


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.1 then -- 100 ms
        time = 0
        Check_T_M_C_FP_LFGIn()
    end
end


local function OnEvent(self, event, arg1, arg2, ...)
    if event == "UNIT_AURA" then
        if arg1 == "player" then
            Check_T_M_C_FP_LFGIn()
        end
    elseif event == "PARTY_INVITE_REQUEST" then
        AcceptGroup()
        StaticPopup_Hide("PARTY_INVITE")
    elseif event == "RESURRECT_REQUEST" then
        AcceptResurrect()
        StaticPopup_Hide("RESURRECT")
    elseif event == "START_LOOT_ROLL" then
        RollOnLoot(arg1, 0)  -- arg1 it's roll_id, 0 = PASS, 1 - Need, 2 - Greed, 3 - Disenchant
    elseif event == "TRADE_ACCEPT_UPDATE" then
        if arg2 == 1 then
            is_trade = true
        end
    elseif event == "TRADE_CLOSED" then
        is_trade = false
    elseif event == "LFG_ROLE_CHECK_SHOW" then
        CompleteLFGRoleCheck(true)
        StaticPopup_Hide("LFG_ROLE_CHECK")
    elseif event == "LFG_PROPOSAL_SHOW" then
        is_lfg_in = true
    elseif event == "LFG_PROPOSAL_SUCCEEDED" or event == "LFG_PROPOSAL_FAILED" then
        is_lfg_in = false
    end
end


local function Init()
    t_m_c_fp_lfgin_tsf = AAAMB.Methods.CreateTSF("T_M_C_FP_LFGIn", 0, 0)
    frame:SetScript("OnEvent", OnEvent)
    
    frame:RegisterEvent("PARTY_INVITE_REQUEST")
    frame:RegisterEvent("RESURRECT_REQUEST")
    frame:RegisterEvent("START_LOOT_ROLL")
    frame:RegisterEvent("TRADE_ACCEPT_UPDATE")
    frame:RegisterEvent("TRADE_CLOSED")
    frame:RegisterEvent("UNIT_AURA")
    frame:RegisterEvent("LFG_ROLE_CHECK_SHOW")
    frame:RegisterEvent("LFG_PROPOSAL_SHOW")
    frame:RegisterEvent("LFG_PROPOSAL_SUCCEEDED")
    frame:RegisterEvent("LFG_PROPOSAL_FAILED")

    frame:SetScript("OnUpdate", OnUpdate)
end


-- Initialize helper logic
local function PreInit()
    ConsoleExec("scriptErrors 1") -- Show lua errors for Debug

    frame = CreateFrame("Frame", "AAAMB_Helper_Frame", UIParent)
    frame:SetScript("OnEvent", function(...)
        frame:UnregisterEvent("PLAYER_LOGIN")
        Init()
    end)
    frame:RegisterEvent("PLAYER_LOGIN")
end

PreInit()
