
local frame = nil
local seal_tsf = nil
local seal_time = 0
local seal_name = nil


local function CheckSeal()
    local name, _, _, _, _, _, exp_time = UnitBuff("player", seal_name)
    if name then
        local time_left = exp_time - GetTime()
        if time_left > 300 then -- 3 min
            seal_tsf:SetVertexColor(0, 1, 0, 1) -- green
            return
        end
    end
    seal_tsf:SetVertexColor(0, 0, 1, 1) -- blue
end


local function OnUpdate(self, delta)
    seal_time = seal_time + delta
    if seal_time >= 5 then -- 5000 ms / 5 sec
        seal_time = 0
        CheckSeal()
    end
end


local function OnEvent(self, event, arg1, ...)
    if event == "UNIT_AURA" then
        if arg1 == "player" then
            CheckSeal()
        end
    end
end


local function GetBuffTargetMacrobody()
    local bless = GetSpellInfo("Blessing of Might")
    if not bless then return false end
    local target = "target=" .. (AAAMB.tank and AAAMB.tank or "player") .. "target,help,exists,nodead"
    local macro_body = "/cast [nomod," .. target .. "] "
    macro_body = macro_body .. "Blessing of Might"
    return macro_body
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


local function SetKeyMacroBar()
    seal_name = GetSealNameSpell()
    AAAMB.Methods.KMB.MoveSpellToBar(seal_name, 1) -- key q

    local bufftarget_macrobody = GetBuffTargetMacrobody()
    if bufftarget_macrobody then
        AAAMB.Methods.KMB.CreateCharMacro("BuffTarget_A", bufftarget_macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("BuffTarget_A", 2) -- key e
    end
end


local function PostInit()
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


function AAAMB.Methods.Templates.Paladin.Init()
    frame = CreateFrame("Frame", "AAAMB_Paladin_Frame", UIParent)
    seal_tsf = AAAMB.Methods.CreateTSF("Paladin_Seal", 210, 0)
    
    SetKeyMacroBar()
    PostInit()

    frame:SetScript("OnEvent", OnEvent)
    frame:RegisterEvent("UNIT_AURA")

    frame:SetScript("OnUpdate", OnUpdate)
end
