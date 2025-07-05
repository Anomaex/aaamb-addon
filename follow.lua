--
-- Follow logic
--


local frame = nil
local time = 0
local time_follow_paused = 0


local function Follow()
    SetCVar("AutoInteract", 0)

    if AAAMB.stay_at_place then return end
    if AAAMB.follow_paused then return end

    if AAAMB.click_to_move then
        if CheckInteractDistance(AAAMB.tank, 3) then
            if UnitExists("target") then
                SetCVar("AutoInteract", 1)
                return
            end
        end
    end

    if not AAAMB.follow then return end
    if not AAAMB.tank then return end

    local count = GetNumPartyMembers()
    if count < 1 then return end

    local is_exists = UnitExists(AAAMB.tank)
    if not is_exists then return end

    local is_connected = UnitIsConnected(AAAMB.tank)
    if not is_connected then return end

    local is_death = UnitIsDead(AAAMB.tank)
    if is_death then return end

    is_death = UnitIsDead("player")
    if is_death then return end

    local is_enemy = UnitIsEnemy("player", AAAMB.tank)
    if is_enemy then return end

    FollowUnit(AAAMB.tank)
end


local function CheckFollowPaused()
    local spell_name = UnitCastingInfo("player")
    if spell_name then return end

    local aura = UnitAura("player", "Drink")
    if aura then
        AAAMB.follow_paused = true
    else
        AAAMB.follow_paused = false
    end
end


local function OnUpdate(self, delta)
    time = time + delta
    if time >= 0.2 then -- 200 ms
        time = 0
        Follow()
    end

    time_follow_paused = time_follow_paused + delta
    if time_follow_paused >= 0.6 then -- 600 ms
        time_follow_paused = 0
        CheckFollowPaused()
    end
end


local function OnEvent(self, event, arg1, ...)
    if event == "UNIT_SPELLCAST_START" then
        if arg1 == "player" then
            AAAMB.follow_paused = true
        end
    elseif event == "UNIT_AURA" then
        if arg1 == "player" then
            CheckFollowPaused()
        end
    end
end


local function Init()
    frame:RegisterEvent("UNIT_SPELLCAST_START")
    frame:RegisterEvent("UNIT_AURA")
    frame:SetScript("OnEvent", OnEvent)
    frame:SetScript("OnUpdate", OnUpdate)
end


-- Initialize follow logic
local function PreInit()
    frame = CreateFrame("Frame", "AAAMB_Follow_Frame", UIParent)
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(...)
        frame:UnregisterEvent("PLAYER_LOGIN")
        Init()
    end)
end

PreInit()
