--
-- Auto accept Party Invite Request
-- Auto accept Ressurect Request
-- Texture Square Frame
-- Scan health state
-- Scan mana state 
-- Scan mount state
--


local frame = nil
local health_tsf = nil
local mana_tsf = nil
local time = 0
local is_trade = false
local t_m_c_fp_tsf = nil


-- Trade, Mount, Cast, Follow Paused
local function Check_T_M_C_FP()
    if is_trade then
        t_m_c_fp_tsf:SetVertexColor(0, 0, 1, 1) -- blue
    elseif IsMounted() then
        t_m_c_fp_tsf:SetVertexColor(1, 1, 0, 1) -- yellow
    else
        local spell_name = UnitCastingInfo("player")
        if spell_name or AAAMB.follow_paused then
            t_m_c_fp_tsf:SetVertexColor(1, 0, 0, 1) -- red
        else
            t_m_c_fp_tsf:SetVertexColor(0, 1, 0, 1) -- green
        end
    end
end


local function Mana_State_100_50(texture)
    texture:SetVertexColor(0, 1, 0, 1) -- green
end

local function Mana_State_50_10(texture)
    texture:SetVertexColor(0, 0, 1, 1) -- blue
end

local function Mana_State_10_0(texture)
    texture:SetVertexColor(1, 0, 0, 1) -- red
end

local function Mana_State_0(texture)
    texture:SetVertexColor(0, 1, 1, 1) -- aqua
end


local function Health_State_100_90(texture)
    texture:SetVertexColor(0, 1, 0, 1) -- green
end

local function Health_State_90_75(texture)
    texture:SetVertexColor(0, 0, 1, 1) -- blue
end

local function Health_State_75_50(texture)
    texture:SetVertexColor(1, 1, 0, 1) -- yellow
end

local function Health_State_50_30(texture)
    texture:SetVertexColor(1, 0, 0, 1) -- red
end

local function Health_State_30_0(texture)
    texture:SetVertexColor(1, 0, 1, 1) -- purple
end

local function Health_State_0(texture)
    texture:SetVertexColor(0, 1, 1, 1) -- aqua
end


local function SetCharacterState(percent, texture, is_mana)
    if not is_mana then
        if percent >= 90 then
            Health_State_100_90(texture)
        elseif percent > 75 then
            Health_State_90_75(texture)
        elseif percent > 50 then
            Health_State_75_50(texture)
        elseif percent > 30 then
            Health_State_50_30(texture)
        elseif percent > 0 then
            Health_State_30_0(texture)
        else
            Health_State_0(texture)
        end
    else
        if AAAMB.Methods.ScanMana then
            AAAMB.Methods.ScanMana(percent, texture)
        else
            --if percent >= 50 then
                --Mana_State_100_50(texture)
            --elseif percent > 10 then
                --Mana_State_50_10(texture)
            --elseif percent > 0 then
                --Mana_State_10_0(texture)
            --else
                --Mana_State_0(texture)
            --end
        end
    end
end


local function IsDeadOrGhost(unit)
    local is_death = UnitIsDead(unit)
    local is_ghost = UnitIsGhost(unit)
    if is_death or is_ghost then
        return true
    end
    return false
end


function AAAMB.Methods.ScanHealth(unit, texture)
    if not unit then return end
    local flag = IsDeadOrGhost(unit)
    if flag then
        SetCharacterState(0, texture)
        return
    end

    local is_exists = UnitExists(unit)
    local is_connected = UnitIsConnected(unit)
    local is_enemy = UnitIsEnemy("player", unit)
    local in_range = IsSpellInRange("Holy Light", unit)
    local is_visible = UnitIsVisible(unit)
    if not in_range or not is_visible or not is_exists or not is_connected or is_enemy then
        SetCharacterState(0, texture)
        return
    end

    local health = UnitHealth(unit)
    local max_health = UnitHealthMax(unit)
    local percent = 0
    if max_health > 0 then
        percent = (health / max_health) * 100
    end
    if unit == "player" then
        AAAMB.health_percent = percent
    end
    SetCharacterState(percent, texture)
end


local function ScanMana(unit, texture)
    local flag = IsDeadOrGhost(unit)
    if flag then
        SetCharacterState(0, texture, true)
        return
    end
    local mana = UnitMana(unit)
    local max_mana = UnitManaMax(unit)
    local percent = 0
    if max_mana > 0 then
        percent = (mana / max_mana) * 100
    end
    if unit == "player" then
        AAAMB.mana_percent = percent
    end
    SetCharacterState(percent, mana_tsf, true)
end


local function ScanCharacterState()
    local unit = "player"
    AAAMB.Methods.ScanHealth(unit, health_tsf)
    ScanMana(unit, mana_tsf)
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
    texture:SetVertexColor(0, 1, 0, 1) -- green
    return texture
end


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.1 then -- 100 ms
        time = 0
        ScanCharacterState()
        Check_T_M_C_FP()
    end
end


local function OnEvent(self, event, arg1, arg2, ...)
    if event == "UNIT_AURA" then
        if arg1 == "player" then
            Check_T_M_C_FP()
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
    end
end


local function Init()
    health_tsf = AAAMB.Methods.CreateTSF("Health", 0, 0)
    mana_tsf = AAAMB.Methods.CreateTSF("Mana", 30, 0)
    t_m_c_fp_tsf = AAAMB.Methods.CreateTSF("T_M_C_FP", 60, 0)
    frame:SetScript("OnEvent", OnEvent)
    
    frame:RegisterEvent("PARTY_INVITE_REQUEST")
    frame:RegisterEvent("RESURRECT_REQUEST")
    frame:RegisterEvent("START_LOOT_ROLL")
    frame:RegisterEvent("TRADE_ACCEPT_UPDATE")
    frame:RegisterEvent("TRADE_CLOSED")
    frame:RegisterEvent("UNIT_AURA")

    frame:SetScript("OnUpdate", OnUpdate)
end


-- Initialize helper logic
local function PreInit()
    ConsoleExec("scriptErrors 1") -- Show lua errors for Debug

    frame = CreateFrame("Frame", "AAAMB_Helper_Frame", UIParent)
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(...)
        frame:UnregisterEvent("PLAYER_LOGIN")
        Init()
    end)
end

PreInit()
