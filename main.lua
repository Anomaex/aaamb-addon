--
-- Initialize contol party
-- Initialize KMB (Key Macro Bar)
--


local frame = nil


local function GetDamagersIndeces()
    local count = GetNumPartyMembers()
    local damagers = {}
    for i = 1, count do
        local unit = "party" .. i
        if unit ~= AAAMB.tank and unit ~= AAAMB.healer then
            table.insert(damagers, unit)
        end
    end
    
    return damagers
end


local function GetHealerIndex()
    local count = GetNumPartyMembers()
    local healer = nil
    for i = 1, count do
        local unit = "party" .. i
        local role = UnitGroupRolesAssigned(unit)
        if role == "HEALER" then
            healer = unit
            break
        end
    end

    if not healer then
        for i = 1, count do
            local unit = "party" .. i
            local name = UnitName(unit)
            if name == AAAMB.char_names.healer then
                healer = unit
                break
            end
        end
    end

    if not tank then
        local name = UnitName("player")
        if name == AAAMB.char_names.healer then
            healer = "player"
        end
    end

    return healer
end


local function GetTankIndex()
    local count = GetNumPartyMembers()
    local tank = nil
    for i = 1, count do
        local unit = "party" .. i
        local role = UnitGroupRolesAssigned(unit)
        if role == "TANK" then
            tank = unit
            break
        end
    end

    if not tank then
        for i = 1, count do
            local unit = "party" .. i
            local name = UnitName(unit)
            if name == AAAMB.char_names.tank then
                tank = unit
                break
            end
        end
    end

    if not tank then
        if count > 0 then
            local index = GetPartyLeaderIndex()
            if index ~= 0 and not IsPartyLeader() then
                tank = "party" .. index
            end
        end
    end

    return tank
end


local function PartyChanges()
    AAAMB.tank = GetTankIndex()
    AAAMB.healer = GetHealerIndex()
    AAAMB.damagers = GetDamagersIndeces()
    AAAMB.Methods.KMB.PartyChanges()
end


local function OnEvent(self, event, ...) 
    if event == "PARTY_MEMBERS_CHANGED" then
        PartyChanges()
    end
end


local function PostInit()
    AAAMB.Methods.KMB.PreInit()
    PartyChanges()
    AAAMB.Methods.Templates.Init()
    if GetNumPartyMembers() > 0 then
        SendChatMessage(
            "[T]: " .. (AAAMB.tank and AAAMB.tank or "-") ..
            ", [H]: " .. (AAAMB.healer and AAAMB.healer or "-"),
        "PARTY")
    else
        print("|cff00ff00[AAAMB]:|r You are not in PARTY!")
    end
end


local function Init()
    frame:RegisterEvent("PARTY_MEMBERS_CHANGED")
    frame:SetScript("OnEvent", OnEvent)
    PostInit()
end


-- Initialize addon logic
local function PreInit()
    frame = CreateFrame("Frame", "AAAMB_Frame", UIParent)
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(...)
        frame:UnregisterEvent("PLAYER_LOGIN")
        Init()
    end)
end

PreInit()
