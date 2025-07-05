--
-- Character mounts
--


local mounts = {
    fly = {
        fast = {},
        slow = {}
    },
    ground = {
        fast = {
            "Charger"
        },
        slow = {
            "Warhorse"
        }
    }
}


local function HasMount(name)
    for i = 1, GetNumCompanions("MOUNT") do
        local _, n = GetCompanionInfo("MOUNT", i)
        if n == name then
            return true
        end
    end
    return false
end


local function GetGroundMount()
    local ground = nil
    for i = 1, #mounts.ground.fast do
        local name = mounts.ground.fast[i]
        if HasMount(name) then
            ground = name
            break
        end
    end

    if not ground then
        for i = 1, #mounts.ground.slow do
            local name = mounts.ground.slow[i]
            if HasMount(name) then
                ground = name
                break
            end
        end
    end

    return ground
end


local function GetFlyMount()
    local fly = nil
    for i = 1, #mounts.fly.fast do
        local name = mounts.fly.fast[i]
        if HasMount(name) then
            fly = name
            break
        end
    end

    if not fly then
        for i = 1, #mounts.fly.slow do
            local name = mounts.fly.fast[i]
            if HasMount(name) then
                fly = name
                break
            end
        end
    end

    return fly
end


function AAAMB.Methods.GetFlyAndGroundMount()
    local fly = GetFlyMount()
    local ground = GetGroundMount()
    return { fly, ground }
end
