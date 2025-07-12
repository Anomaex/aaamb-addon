
local function GetBuffTargetMacrobody()
    local mark = GetSpellInfo("Mark of the Wild")
    if not mark then return false end
    local target = "target=" .. (AAAMB.tank and AAAMB.tank or "player") .. "target,help,exists,nodead"
    local macro_body = "/cast [nomod," .. target .. "] "

    local gift = GetSpellInfo("Gift of the Wild")
    if not gift then
        macro_body = macro_body .. "Mark of the Wild"
    else
        local can_use = IsUsableSpell("Gift of the Wild")
        if not can_use then
            local link = GetSpellLink("Gift of the Wild")
            SendChatMessage("Not have reagents for " .. link, "PARTY")
        end
        macro_body = macro_body .. "Gift of the Wild"
        macro_body = macro_body .. "\n/cast [mod:ctrl," .. target .. "] Mark of the Wild"
    end
    return macro_body
end


local function SetKeyMacroBar()
    local bufftarget_macrobody = GetBuffTargetMacrobody()
    if bufftarget_macrobody then
        AAAMB.Methods.KMB.CreateCharMacro("BuffTarget_A", bufftarget_macrobody)
        AAAMB.Methods.KMB.MoveMacroToBar("BuffTarget_A", 2) -- key e
    end
end


local function PostInit()
    if AAAMB.healer == "player" then
        AAAMB.Methods.Templates.Druid.Healer.Init()
    end
end


function AAAMB.Methods.Templates.Druid.Init()
    SetKeyMacroBar()
    PostInit()
end
