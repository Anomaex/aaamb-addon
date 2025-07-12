--
-- All things for Quests logic
--


local getted_quests = {}
local completed_quests = {}


local function GetQuestTitle()
    local quest_title = GetTitleText and GetTitleText() or (QuestInfoTitleHeader and QuestInfoTitleHeader:GetText())
    quest_title = quest_title or "Unknown"
    return quest_title
end


local function OnEvent(self, event, arg1, ...)
    print(event)

    if event == "QUEST_GREETING" then
        local numAvailableQuests = GetNumAvailableQuests()
        for i = 1, numAvailableQuests do
            SelectAvailableQuest(i)
        end
        local numActiveQuests = GetNumActiveQuests()
        for i = 1, numActiveQuests do
            SelectActiveQuest(i)
        end
        
    elseif event == "GOSSIP_SHOW" then
        local numAvailableQuests = GetNumGossipAvailableQuests()
        for i = 1, numAvailableQuests do
            SelectGossipAvailableQuest(i)
        end
        local numActiveQuests = GetNumGossipActiveQuests()
        for i = 1, numActiveQuests do
            SelectGossipActiveQuest(i)
        end

    elseif event == "QUEST_DETAIL" then
        local quest_title = GetQuestTitle()
        if not getted_quests[quest_title] then
            if GetNumPartyMembers() > 0 then
                SendChatMessage("[Q Accept]: " .. quest_title, "PARTY")
            end
        end
        AcceptQuest()
        getted_quests[quest_title] = true

    elseif event == "QUEST_PROGRESS" then
        if IsQuestCompletable() then
            CompleteQuest()
        end

    elseif event == "QUEST_COMPLETE" then
        local quest_title = GetQuestTitle()
        if GetNumQuestChoices() > 0 then
            if GetNumPartyMembers() > 0 then
                SendChatMessage("[Q Reward]: Choose the reward ...", "PARTY")
            end
            --GetQuestReward(1)
        else
            if completed_quests[quest_title] then
                if GetNumPartyMembers() > 0 then
                    SendChatMessage("[Q Completed]: " .. quest_title, "PARTY")
                end
            end
            GetQuestReward(0)
            completed_quests[quest_title] = true
        end
    end
end


local function Init()
    frame:SetScript("OnEvent", OnEvent)

    frame:RegisterEvent("GOSSIP_SHOW")
    frame:RegisterEvent("QUEST_GREETING")
    frame:RegisterEvent("QUEST_DETAIL")
    frame:RegisterEvent("QUEST_PROGRESS")
    frame:RegisterEvent("QUEST_COMPLETE")

    frame:SetScript("OnEvent", OnEvent)
end


-- Initialize quests logic
local function PreInit()
    frame = CreateFrame("Frame", "AAAMB_Quests_Frame", UIParent)
    frame:RegisterEvent("PLAYER_LOGIN")
    frame:SetScript("OnEvent", function(...)
        frame:UnregisterEvent("PLAYER_LOGIN")
        Init()
    end)
end

PreInit()