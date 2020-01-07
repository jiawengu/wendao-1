-- QuestionMgr.lua
-- created by song Sep/10/2016
-- 问卷调查管理器

QuestionMgr = Singleton()

QuestionMgr.answer = {}

QuestionMgr.questionData = {}

function QuestionMgr:setAnswer(answer, id)
    QuestionMgr.answer[id] = gf:deepCopy(answer)
end

function QuestionMgr:subMitAnswer(useTime, id)
    local data = {}
    data.id = id
    data.time_used = useTime

    local str = ""
    --for i, ctrls in pairs(QuestionMgr.answer[id]) do
    for i = 1, QuestionMgr.questionData.question_count do
        local ctrls = QuestionMgr.answer[id][i]
        if str == "" then
            str = str .. i .. ":"
        else
            str = str .. "|" .. i .. ":"
        end

        if not ctrls then
            str = str .. "nil"
        else
            local flag = true
            for j, ctrl in pairs(ctrls) do
                if ctrl.ctrlType == "CheckBox" then
                    if ctrl.value == "1" then
                        if flag then
                            str = str .. j
                            flag = false
                        else
                            str = str .. "," .. j
                        end
                    end
                else
                    str = str .. "<input>" .. ctrl.value .. "</input>"
                end
            end
        end
    end
    data.answer = str
    gf:CmdToServer("CMD_ANSWER_QUESTIONNAIRE", data)
end

function QuestionMgr:MSG_QUESTIONNAIRE_INFO(data)
    QuestionMgr.questionData = data
    local dlg = DlgMgr:openDlg("QuestionnaireDlg")
    dlg:setData(data)
end

MessageMgr:regist("MSG_QUESTIONNAIRE_INFO", QuestionMgr)

