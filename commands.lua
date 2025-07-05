--
-- Chat slash commands /aaamb ...
--


SLASH_AAAMB1 = "/aaamb"

SlashCmdList["AAAMB"] = function(msg)
    msg = msg:lower():gsub("^%s+", ""):gsub("%s+$", "")
    if msg == "follow" then
        if AAAMB.follow then
            AAAMB.follow = false
        else
            AAAMB.follow = true
        end
    elseif msg == "follow_stopped" then
        AAAMB.follow = false
    elseif msg == "follow_paused" then
        AAAMB.follow_paused = true
    elseif msg == "stay_at_place" then
        if AAAMB.stay_at_place then
            AAAMB.stay_at_place = false
        else
            AAAMB.stay_at_place = true
        end
    elseif msg == "click_to_move" then
        if AAAMB.click_to_move then
            AAAMB.click_to_move = false
        else
            AAAMB.click_to_move = true
        end
    end
end
