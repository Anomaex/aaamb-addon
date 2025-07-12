--
-- Auto accept Party Invite Request
-- Auto accept Ressurect Request
-- Texture Square Frame
-- Scan mount state
-- Colors:
--  SetVertexColor(0, 1, 0, 1) -- green
--  SetVertexColor(0, 0, 1, 1) -- blue
--  SetVertexColor(1, 1, 0, 1) -- yellow
--  SetVertexColor(1, 0, 0, 1) -- red
--  SetVertexColor(1, 0, 1, 1) -- purple
--  SetVertexColor(0, 1, 1, 1) -- aqua
--


local frame = nil
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
    t_m_c_fp_tsf = AAAMB.Methods.CreateTSF("T_M_C_FP", 0, 0)
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
    frame:SetScript("OnEvent", function(...)
        frame:UnregisterEvent("PLAYER_LOGIN")
        Init()
    end)
    frame:RegisterEvent("PLAYER_LOGIN")
end

PreInit()
