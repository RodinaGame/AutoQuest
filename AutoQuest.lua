local frame = CreateFrame("Frame")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("QUEST_GREETING")
frame:RegisterEvent("QUEST_DETAIL")
frame:RegisterEvent("QUEST_PROGRESS")
frame:RegisterEvent("QUEST_COMPLETE")

frame:SetScript("OnEvent", function()
    -- Если зажат Shift, пропускаем автоматизацию и открываем стандартное окно
    if IsShiftKeyDown() then
        return
    end

    -- 1. Окно сплетен (Gossip Frame)
    if event == "GOSSIP_SHOW" then
        -- Сначала выбираем выполненный квест на сдачу
        local active = { GetGossipActiveQuests() }
        if table.getn(active) > 0 then
            SelectGossipActiveQuest(1)
            return
        end

        -- Затем выбираем доступный квест на взятие
        local available = { GetGossipAvailableQuests() }
        if table.getn(available) > 0 then
            SelectGossipAvailableQuest(1)
            return
        end

        -- Страховочный клик по первой кнопке списка, если Blizzard API вернул пустую таблицу
        if GossipTitleButton1 and GossipTitleButton1:IsVisible() then
            GossipTitleButton1:Click()
            return
        end

    -- 2. Окно приветствия (QuestGreeting Frame)
    elseif event == "QUEST_GREETING" then
        if GetNumActiveQuests() > 0 then
            SelectActiveQuest(1)
            return
        elseif GetNumAvailableQuests() > 0 then
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
        if GetNumQuestChoices() <= 1 then
            GetQuestReward(1)
        end
    end
end)