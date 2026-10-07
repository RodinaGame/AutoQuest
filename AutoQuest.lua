local ADDON_VERSION = "1.1.1"

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("QUEST_GREETING")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")

-- Проверяет, есть ли квест с данным названием в логе и он завершён (для сдачи)
local function IsQuestCompleteInLog(questTitle)
    if not questTitle or questTitle == "" then return false end
    for i = 1, GetNumQuestLogEntries() do
        local title, _, _, isHeader, _, isComplete = GetQuestLogTitle(i)
        if not isHeader and title == questTitle and isComplete then
            return true
        end
    end
    return false
end

-- Закрывает все окна квестов/gossip, чтобы они не зависали после сдачи
local function CloseAllQuestFrames()
    if GossipFrame and GossipFrame:IsVisible() then
        CloseGossip()
    end
    if QuestFrame and QuestFrame:IsVisible() then
        CloseQuest()
    end
    -- На всякий случай прячем фреймы (некоторые клиенты/аддоны оставляют их видимыми)
    if GossipFrame then GossipFrame:Hide() end
    if QuestFrame then QuestFrame:Hide() end
    if QuestFrameDetailPanel then QuestFrameDetailPanel:Hide() end
    if QuestFrameProgressPanel then QuestFrameProgressPanel:Hide() end
    if QuestFrameRewardPanel then QuestFrameRewardPanel:Hide() end
    if QuestFrameGreetingPanel then QuestFrameGreetingPanel:Hide() end
end

frame:SetScript("OnEvent", function()
    if event == "ADDON_LOADED" and arg1 == "AutoQuest" then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AutoQuest|r v" .. ADDON_VERSION .. " loaded. Hold Shift to disable auto.")
        return
    end

    -- Если зажат Shift, пропускаем автоматизацию
    if IsShiftKeyDown() then
        return
    end

    -- 1. Окно сплетен (Gossip Frame)
    if event == "GOSSIP_SHOW" then
        -- Сначала ищем готовые к сдаче активные квесты (приоритет сдачи)
        for i = 1, 32 do
            local button = getglobal("GossipTitleButton" .. i)
            if button and button:IsVisible() and button.type == "Active" then
                local title = button:GetText()
                -- Убираем возможные цветовые коды из текста кнопки
                title = string.gsub(title or "", "|c%x%x%x%x%x%x%x%x", "")
                title = string.gsub(title, "|r", "")
                title = string.gsub(title, "^%s*(.-)%s*$", "%1")

                if IsQuestCompleteInLog(title) then
                    SelectGossipActiveQuest(button:GetID())
                    return
                end
            end
        end

        -- Если готовых к сдаче нет — берём первый доступный квест
        for i = 1, 32 do
            local button = getglobal("GossipTitleButton" .. i)
            if button and button:IsVisible() and button.type == "Available" then
                SelectGossipAvailableQuest(button:GetID())
                return
            end
        end

        -- Fallback
        if GossipTitleButton1 and GossipTitleButton1:IsVisible() then
            GossipTitleButton1:Click()
            return
        end

    -- 2. Окно приветствия (QuestGreeting Frame)
    elseif event == "QUEST_GREETING" then
        -- Сначала сдаём готовые
        local numActive = GetNumActiveQuests()
        for i = 1, numActive do
            local title = GetActiveTitle(i)
            if IsQuestCompleteInLog(title) then
                SelectActiveQuest(i)
                return
            end
        end

        -- Затем берём доступные
        local numAvailable = GetNumAvailableQuests()
        if numAvailable > 0 then
            SelectAvailableQuest(1)
            return
        end

        if QuestTitleButton1 and QuestTitleButton1:IsVisible() then
            QuestTitleButton1:Click()
            return
        end

    -- 3. Окно описания квеста — принимаем
    elseif event == "QUEST_DETAIL" then
        AcceptQuest()

    -- 4. Окно сдачи квеста (прогресс)
    elseif event == "QUEST_PROGRESS" then
        if IsQuestCompletable() then
            CompleteQuest()
        end

    -- 5. Завершение и получение награды
    elseif event == "QUEST_COMPLETE" then
        -- Если выбор награды только один (или нет) — берём автоматически
        if GetNumQuestChoices() <= 1 then
            GetQuestReward(1)
            -- После получения награды принудительно закрываем окна,
            -- иначе на некоторых персонажах/клиентах окно остаётся висеть
            CloseAllQuestFrames()
        end
        -- Если несколько наград — оставляем окно открытым, чтобы игрок выбрал
    end
end)
