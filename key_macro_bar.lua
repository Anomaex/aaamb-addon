--
-- KMB - Key Macro Bar, control methods
--


local function MoveMacroToBar(name, slot)
    PickupMacro(name)
    PlaceAction(slot)
    ClearCursor()
end

function AAAMB.Methods.KMB.MoveMacroToBar(name, slot)
    MoveMacroToBar(name, slot)
end


local function CreateCharMacro(name, body)
    CreateMacro(name, 1, body, 1) -- 1 - save macro per character only, nil - save macro to account/general 
end

function AAAMB.Methods.KMB.CreateCharMacro(name, body)
    CreateCharMacro(name, body)
end


local function SetDefaultMacros()
    CreateCharMacro("Exit_A", "/quit")
    MoveMacroToBar("Exit_A", 71) -- key -

    CreateCharMacro("Heartstone_A", "/use Hearthstone")
    MoveMacroToBar("Heartstone_A", 70) -- key 0

    local mount = AAAMB.Methods.GetFlyAndGroundMount()
    local mount_macrobody = "/stopcasting" .. (mount[2] and "\n/cast !" .. mount[2] or "") .. (mount[1] and "\n/cast !" .. mount[1] or "")
    CreateCharMacro("Mount_A", mount_macrobody)
    MoveMacroToBar("Mount_A", 69) -- key 9

    CreateCharMacro("Trade_A", "/run AcceptTrade()")
    MoveMacroToBar("Trade_A", 67) -- key 7

    CreateCharMacro("Follow_A", "/aaamb follow")
    MoveMacroToBar("Follow_A", 61) -- key 1

    CreateCharMacro("Follow_Stopped_A", "/aaamb follow_stopped")
    MoveMacroToBar("Follow_Stopped_A", 62) -- key 2

    CreateCharMacro("Follow_Paused_A", "/aaamb follow_paused")
    MoveMacroToBar("Follow_Paused_A", 63) -- key 3

    CreateCharMacro("Stay_at_Place_A", "/aaamb stay_at_place")
    MoveMacroToBar("Stay_at_Place_A", 64) -- key 4

    CreateCharMacro("Click_to_Move_A", "/aaamb click_to_move")
    MoveMacroToBar("Click_to_Move_A", 65) -- key 5
end


local function BindKey(key, cmd)
    SetBinding(key) -- remove key from other bindings
    SetBinding(key, cmd, 0) -- 0 - for account, 1 - per character, 
end


local function BindDefaultKeys()
    BindKey("w", "MOVEFORWARD")
    BindKey("s", "MOVEBACKWARD")
    BindKey("a", "STRAFELEFT")
    BindKey("d", "STRAFERIGHT")
    BindKey("LEFT", "TURNLEFT")
    BindKey("RIGHT", "TURNRIGHT")
    BindKey("SPACE", "JUMP")
    BindKey("NUMLOCK", "TOGGLEAUTORUN")
    BindKey("HOME", "INTERACTTARGET")
    BindKey("UP", "CAMERAZOOMIN")
    BindKey("DOWN", "CAMERAZOOMOUT")
    BindKey("ESCAPE", "TOGGLEGAMEMENU")
    BindKey("ENTER", "OPENCHAT")
    BindKey("m", "TOGGLEWORLDMAP")
        
    BindKey("q", "ACTIONBUTTON1")
    BindKey("e", "ACTIONBUTTON2")
    BindKey("r", "ACTIONBUTTON3")
    BindKey("t", "ACTIONBUTTON4")
    BindKey("f", "ACTIONBUTTON5")
    BindKey("g", "ACTIONBUTTON6")
    BindKey("z", "ACTIONBUTTON7")
    BindKey("x", "ACTIONBUTTON8")
    BindKey("c", "ACTIONBUTTON9")
    BindKey("v", "ACTIONBUTTON10")
    BindKey("CAPSLOCK", "ACTIONBUTTON11")
    BindKey("`", "ACTIONBUTTON12")
    BindKey("?", "ACTIONBUTTON12")

    BindKey("1", "MULTIACTIONBAR1BUTTON1")
    BindKey("2", "MULTIACTIONBAR1BUTTON2")
    BindKey("3", "MULTIACTIONBAR1BUTTON3")
    BindKey("4", "MULTIACTIONBAR1BUTTON4")
    BindKey("5", "MULTIACTIONBAR1BUTTON5")
    BindKey("6", "MULTIACTIONBAR1BUTTON6")
    BindKey("7", "MULTIACTIONBAR1BUTTON7")
    BindKey("8", "MULTIACTIONBAR1BUTTON8")
    BindKey("9", "MULTIACTIONBAR1BUTTON9")
    BindKey("0", "MULTIACTIONBAR1BUTTON10")
    BindKey("-", "MULTIACTIONBAR1BUTTON11")
    --BindKey("=", "MULTIACTIONBAR1BUTTON12") -- Have in PreInit()

    BindKey("END", "MULTIACTIONBAR3BUTTON1")
    BindKey("PAGEUP", "MULTIACTIONBAR3BUTTON2")

    BindKey("y", "MULTIACTIONBAR2BUTTON1")
    BindKey("u", "MULTIACTIONBAR2BUTTON2")
    BindKey("i", "MULTIACTIONBAR2BUTTON3")
    BindKey("o", "MULTIACTIONBAR2BUTTON4")
    BindKey("p", "MULTIACTIONBAR2BUTTON5")
    BindKey("h", "MULTIACTIONBAR2BUTTON6")
    BindKey("j", "MULTIACTIONBAR2BUTTON7")
    BindKey("k", "MULTIACTIONBAR2BUTTON8")
    BindKey("l", "MULTIACTIONBAR2BUTTON9")
    BindKey("b", "MULTIACTIONBAR2BUTTON10")
    BindKey("n", "MULTIACTIONBAR2BUTTON11")

    SaveBindings(1) -- 1 - for account, 2 - per character, 
end


local function ClearCmd(cmd)
    for i = 1, 5 do
        local key1, key2 = GetBindingKey(cmd, i)
        if key1 then
            SetBinding(key1)
        end
        if key2 then
            SetBinding(key2)
        end
    end
    SaveBindings(1)
end


local function ClearRequiredCmds()
    ClearCmd("MOVEFORWARD")
    ClearCmd("MOVEBACKWARD")
    ClearCmd("STRAFELEFT")
    ClearCmd("STRAFERIGHT")
    ClearCmd("TURNLEFT")
    ClearCmd("TURNRIGHT")
    ClearCmd("JUMP")
    ClearCmd("TOGGLEAUTORUN")
    ClearCmd("INTERACTTARGET")
    ClearCmd("CAMERAZOOMIN")
    ClearCmd("CAMERAZOOMOUT")
    ClearCmd("TOGGLEUI")

    ClearCmd("TOGGLESOUND")
    ClearCmd("TOGGLEMUSIC")

    ClearCmd("PREVIOUSACTIONPAGE")
    ClearCmd("NEXTACTIONPAGE")
    ClearCmd("PREVVIEW")
    ClearCmd("NEXTVIEW")
    
    ClearCmd("ACTIONBUTTON1")
    ClearCmd("ACTIONBUTTON2")
    ClearCmd("ACTIONBUTTON3")
    ClearCmd("ACTIONBUTTON4")
    ClearCmd("ACTIONBUTTON5")
    ClearCmd("ACTIONBUTTON6")
    ClearCmd("ACTIONBUTTON7")
    ClearCmd("ACTIONBUTTON8")
    ClearCmd("ACTIONBUTTON9")
    ClearCmd("ACTIONBUTTON10")
    ClearCmd("ACTIONBUTTON11")
    ClearCmd("ACTIONBUTTON12")
end


local function UnbindKey(key)
    SetBinding(key)
    SaveBindings(1) -- 1 - for account, 2 - per character, 
end


local function UnbindRequiredKeys()
    UnbindKey("F1")
    UnbindKey("F2")
    UnbindKey("F3")
    UnbindKey("F4")
    UnbindKey("F5")
    UnbindKey("F6")
    UnbindKey("F7")
    UnbindKey("F8")
    UnbindKey("F9")
    UnbindKey("F10")
    UnbindKey("F11")
    UnbindKey("F12")
    
    UnbindKey("SHIFT-1")
    UnbindKey("SHIFT-2")
    UnbindKey("SHIFT-3")
    UnbindKey("SHIFT-4")
    UnbindKey("SHIFT-5")
    UnbindKey("SHIFT-6")
    UnbindKey("SHIFT-7")
    UnbindKey("SHIFT-8")
    UnbindKey("SHIFT-8")
    UnbindKey("SHIFT-9")
    UnbindKey("SHIFT-0")
    UnbindKey("SHIFT--")
    UnbindKey("SHIFT-=")
    
    UnbindKey("SHIFT-q")
    UnbindKey("SHIFT-e")
    UnbindKey("SHIFT-r")
    UnbindKey("SHIFT-t")
    UnbindKey("SHIFT-f")
    UnbindKey("SHIFT-g")
    UnbindKey("SHIFT-h")
    UnbindKey("SHIFT-z")
    UnbindKey("SHIFT-x")
    UnbindKey("SHIFT-c")
    UnbindKey("SHIFT-v")
    UnbindKey("SHIFT-b")

    UnbindKey("SHIFT-y")
    UnbindKey("SHIFT-u")
    UnbindKey("SHIFT-i")
    UnbindKey("SHIFT-o")
    UnbindKey("SHIFT-p")
    UnbindKey("SHIFT-h")
    UnbindKey("SHIFT-j")
    UnbindKey("SHIFT-k")
    UnbindKey("SHIFT-l")
    UnbindKey("SHIFT-b")
    UnbindKey("SHIFT-n")

    UnbindKey("ALT-y")
    UnbindKey("ALT-u")
    UnbindKey("ALT-i")
    UnbindKey("ALT-o")
    UnbindKey("ALT-p")
    UnbindKey("ALT-h")
    UnbindKey("ALT-j")
    UnbindKey("ALT-k")
    UnbindKey("ALT-l")
    UnbindKey("ALT-b")
    UnbindKey("ALT-n")


    SaveBindings(1)
end


function AAAMB.Methods.KMB.EditMacro(name, body)
    EditMacro(name, name, 1, body, 1, 1)
end


function AAAMB.Methods.KMB.MoveSpellToBar(name, slot)
    PickupSpell(name)
    PlaceAction(slot)
    ClearCursor()
end


function AAAMB.Methods.KMB.MoveItemToBar(bag, bag_slot, slot)
    PickupContainerItem(bag, bag_slot)
    PlaceAction(slot)
    ClearCursor()
end


function AAAMB.Methods.KMB.CreateAccountMacro(name, body)
    CreateMacro(name, 1, body) -- 1 - save macro per character only, nil - save macro to account/general 
end


local function RemoveAllMacros()
    local a_macros, c_macros = GetNumMacros() -- account macros, character macros
    for i = 1, a_macros do
        DeleteMacro(1)
    end
    for i = 1, c_macros do
        DeleteMacro(1 + 36)
    end
end


local function ClearAllActionBars()
    for i = 1, 120 do
        PickupAction(i)
        ClearCursor()
    end
end


function AAAMB.Methods.KMB.PreInit()
    ClearAllActionBars()
    RemoveAllMacros()
    BindKey("=", "MULTIACTIONBAR1BUTTON12")
    CreateCharMacro("Reload_A", "/reload")
    MoveMacroToBar("Reload_A", 72) -- key =
    UnbindRequiredKeys()
    ClearRequiredCmds()
    BindDefaultKeys()
    SetDefaultMacros()
end


function AAAMB.Methods.KMB.PartyChanges()
    DeleteMacro("Target_A")
    if AAAMB.tank then
        CreateCharMacro("Target_A", "/cleartarget\n/target [target=" .. AAAMB.tank .. "target]")
        MoveMacroToBar("Target_A", 68) -- key 8
    end
end
