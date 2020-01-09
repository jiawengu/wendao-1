-- ZhidbcDlg.lua
-- Created by huangzz Nov/29/2018
-- 智斗百草界面

local ZhidbcDlg = Singleton("ZhidbcDlg", Dialog)

local ITEM_INFO = {
    {name = CHS[5450377], desc = CHS[5450399], icon = 7953},
    {name = CHS[5450378], desc = CHS[5450400], icon = 7954},
    {name = CHS[5450379], desc = CHS[5450401], icon = 7955},
    {name = CHS[5450380], desc = CHS[5450402], icon = 7956},
    {name = CHS[5450381], desc = CHS[5450403], icon = 7972},
    {name = CHS[5450382], desc = CHS[5450404], icon = 7959},
    {name = CHS[5450383], desc = CHS[5450405], icon = 7961},
    {name = CHS[5450384], desc = CHS[5450406], icon = 7962},
    {name = CHS[5450385], desc = CHS[5450407], icon = 7963},
    {name = CHS[5450386], desc = CHS[5450408], icon = 7964},
    {name = CHS[5450387], desc = CHS[5450409], icon = 7965},
    {name = CHS[5450388], desc = CHS[5450410], icon = 7966},
    {name = CHS[5450389], desc = CHS[5450411], icon = 7967},
    {name = CHS[5450390], desc = CHS[5450412], icon = 7968},
    {name = CHS[5450391], desc = CHS[5450413], icon = 7970},
    {name = CHS[5450392], desc = CHS[5450414], icon = 7971},
    {name = CHS[5450393], desc = CHS[5450415], icon = 7973},
    {name = CHS[5450394], desc = CHS[5450416], icon = 7974},
    {name = CHS[5450395], desc = CHS[5450417], icon = 7975},
    {name = CHS[5450396], desc = CHS[5450418], icon = 7976},
    {name = CHS[5450397], desc = CHS[5450419], icon = 7977},
    {name = CHS[5450398], desc = CHS[5450420], icon = 7978},
}

local NPC_ICON = 06018
local WORD_LIMIT = 6

function ZhidbcDlg:init()
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("SubmitButton", self.onSubmitButton)

    self:bindListener("TextPanel", self.onTextPanel)

    self:creatCharDragonBones()

    self.needWaitMsg = false

    self:initView()

    self:hookMsg("MSG_DW_2019_ZDBC_DATA")
end

function ZhidbcDlg:creatCharDragonBones()
    local panel = self:getControl("ModelPanel")
    local dbMagic = DragonBonesMgr:createCharDragonBones(NPC_ICON, string.format("%05d", NPC_ICON))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")
    magic:setPosition(panel:getContentSize().width * 0.5 - 10, -50)
    magic:setTag(icon)
    panel:addChild(magic)

    DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    self.dbMagic = dbMagic
    return magic
end

-- 初始化列表
function ZhidbcDlg:initView()
    -- 初始化编辑框
    self:setCtrlVisible("DelButton", false, "AnswerPanel")
    self:setLabelText("TextLabel", "", "AnswerPanel")
    self:setCtrlVisible("DefaultLabel", true, "AnswerPanel")
    --[[self.inputCtrl = self:createEditBox("TextPanel", "AnswerPanel", nil, function(sender, type)
        if "end" == type then
        elseif "changed" == type then
            if not self.inputCtrl then return end
            local content = self.inputCtrl:getText()
            local len = gf:getTextLength(content)
            if len > WORD_LIMIT * 2 then
                content = gf:subString(content, WORD_LIMIT * 2)
                self.inputCtrl:setText(content)
                gf:ShowSmallTips(CHS[5400041])
            end

            if len == 0 then
                self:setCtrlVisible("DelButton", false, "AnswerPanel")
            else
                self:setCtrlVisible("DelButton", true,  "AnswerPanel")
            end
        end
    end)

    self.inputCtrl:setFontColor(COLOR3.TEXT_DEFAULT)
    self.inputCtrl:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.inputCtrl:setFont(CHS[3003794], 23)
    self.inputCtrl:setPlaceHolder(CHS[5410324])
    self.inputCtrl:setPlaceholderFontSize(21)
    self.inputCtrl:setPlaceholderFontColor(cc.c3b(128, 128, 128))]]
end

function ZhidbcDlg:setText(text)
    self:setCtrlVisible("DelButton", true, "AnswerPanel")
    self:setLabelText("TextLabel", text, "AnswerPanel")
    self:setCtrlVisible("DefaultLabel", false, "AnswerPanel")

    -- self.inputCtrl:setText(text)
end

function ZhidbcDlg:onDelButton(sender, eventType)
    -- self.inputCtrl:setText("")
    self:setLabelText("TextLabel", "", "AnswerPanel")
    self:setCtrlVisible("DelButton", false, "AnswerPanel")
    self:setCtrlVisible("DefaultLabel", true, "AnswerPanel")
end

function ZhidbcDlg:onSubmitButton(sender, eventType)
    if not self.data then return end

    if self.needWaitMsg then return end

    local content = self:getLabelText("TextLabel", "AnswerPanel")
    if string.isNilOrEmpty(content) then
        gf:ShowSmallTips(CHS[5450422])
        return
    end

    gf:CmdToServer("CMD_DW_2019_ZDBC_COMMIT", {answer = content})
    self.needWaitMsg = true
end

function ZhidbcDlg:onTextPanel(sender, eventType)
    local dlg = DlgMgr:getDlgByName("BaiCPDlg")
    if dlg then
        dlg:reopen()
    else
        DlgMgr:openDlgEx("BaiCPDlg", true)
    end
end

function ZhidbcDlg:MSG_DW_2019_ZDBC_DATA(data)
    self.data = data
    self.needWaitMsg = false
    local str = string.format(CHS[5450424], data.tm_num + 1, ITEM_INFO[data.index].name, 3 - data.dt_num)
    if data.type == "start" then
        -- 刚打开界面时
        self:setLabelText("QuestionLabel", str)
    elseif data.type == "next_question" then
        -- 下一道题目
        local label = self:getControl("QuestionLabel")
        local action = cc.Sequence:create(
            cc.FadeOut:create(1),
            cc.CallFunc:create(function()
                label:setString(str)
            end),
            cc.FadeIn:create(1)
        )

        label:runAction(action)
        self:onDelButton()
    elseif data.type == "next_answer" then
        -- 下一次答题机会
        local label = self:getControl("QuestionLabel")
        label:stopAllActions()
        label:setString(str)
    elseif data.type == "stop" then
        -- 游戏结果
        self:onCloseButton()
    end
end

function ZhidbcDlg:getItemsInfo()
    return ITEM_INFO
end

function ZhidbcDlg:cleanup()
    gf:CmdToServer("CMD_DW_2019_ZDBC_FINISH", {})

    DlgMgr:closeDlg("BaiCPDlg")

    if self.dbMagic then
        DragonBonesMgr:removeUIDragonBonesResoure(NPC_ICON, string.format("%05d", NPC_ICON))
        self.dbMagic = nil
    end
end

return ZhidbcDlg
