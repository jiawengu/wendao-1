-- QingYuanDlg.lua
-- Created by songcw
--  情缘观点答题界面

local QingYuanDlg = Singleton("QingYuanDlg", Dialog)

local ANSWER_PANEL = {"AOptionPanel", "BOptionPanel", "COptionPanel"}

local OP_RES = {
    [0] = ResMgr.ui.quest_mark,
    [1] = ResMgr.ui.option_a,
    [2] = ResMgr.ui.option_b,
    [3] = ResMgr.ui.option_c,
}

function QingYuanDlg:init(data)

--    self:setFullScreen()

    for i = 1, 3 do
        local btn = self:getControl("AButton", nil, ANSWER_PANEL[i])
        btn:setTag(i)
        self:bindTouchEndEventListener(btn, self.onAButton)
    end

    self.lockNum = 0

    -- 创建莲花小姐姐龙骨动画
    self:creatLianHuaXiaojj()

    -- 初始化选项
    self:setAnswer()
end

-- 设置界面数据
function QingYuanDlg:setData(data)
    self.data = data

    -- 设置界面标题
   -- self:setTitle(data)

    -- 设置题目
    self:setQuestionTitle(data)

    -- 初始化选项
    if self.lockNum ~= data.cur_num then
        self:setAnswer()
    end

    -- 设置选项
    self:setAnswer(data.answers)

    -- 设置心数目
    self:setHeart(data)

    -- 设置下方玩家信息
    self:setCharInfo(data)
end

-- 设置倒计时
function QingYuanDlg:onUpdate()
    if not self.data then return end

    -- 更新倒计时
    local leftTime = self.data.end_time - gf:getServerTime()
    leftTime = math.max(leftTime, 0)
    self:setLabelText("TimeLabel", leftTime .. CHS[4010199])
end

-- 设置标题
function QingYuanDlg:setTitle(data)
    local cur = data.cur_num
    local total = data.total_num
 --   self:setLabelText("TitleLabel_1", string.format("情缘观点%d/%d", cur, total))
 --   self:setLabelText("TitleLabel_2", string.format("情缘观点%d/%d", cur, total))
end

-- 创建莲花小姐姐龙骨动画
function QingYuanDlg:creatLianHuaXiaojj()
    local icon = 6019
    local panel = self:getControl("ModelPanel")
    local magic = panel:getChildByName("charPortrait")

    if magic then
        if magic:getTag() == icon then
            -- 已经有了，不需要加载
            return
        else
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
            magic:removeFromParent()
        end
    end

    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")
    magic:setPosition(panel:getContentSize().width * 0.5, -13)
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)
    magic:setRotationSkewY(180)
    magic:setScale(0.8)

    -- 不调用 DragonBonesMgr:toPlay()接口，来满足使用第一帧的需求
    --  DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    return magic
end

function QingYuanDlg:cleanup()
    -- 如果有骨骼动画时，释放相关资源
    local panel = self:getControl("ModelPanel")
    if panel then
        local magic = panel:getChildByName("charPortrait")
        if magic then
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        end
    end

    gf:CmdToServer("CMD_QYGD_CLOSE_DLG_2018")
end

function QingYuanDlg:setAnswer(answers)
    -- answers 为nil 时，初始化答案
    if not answers then
        answers = {}
        for i = 1, 3 do
            answers[i] = ""
            self:setCtrlVisible("ChoiceImage", false, ANSWER_PANEL[i])
            self:setCtrlEnabled("AButton", true, ANSWER_PANEL[i])
        end
    end

    for i, panelName in pairs(ANSWER_PANEL) do
        self:setLabelText("AnswerLabel", answers[i], panelName)
    end
end

-- 设置题目
function QingYuanDlg:setQuestionTitle(data)

    local cur = data.cur_num
    local total = data.total_num

    local title = string.format("【%d/%d】 %s", cur, total, data.title)

    self:setColorText(title, "QuestionPanel", nil, nil, nil, nil, nil, nil, nil, nil, true)
end

function QingYuanDlg:setColorText(str, panelName, defColor)
    defColor = defColor or COLOR3.TEXT_DEFAULT
    local panel = self:getControl(panelName, Const.UIPanel, root)
    if not panel then return end

    panel:removeAllChildren()

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(19)
    textCtrl:setString(str, true)
    textCtrl:setContentSize(size.width, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    textCtrl:updateNow()

    local textW, textH = textCtrl:getRealSize()
    local node = tolua.cast(textCtrl, "cc.LayerColor")
    node:setTag(COLORTEXT_TAG)
    node:setAnchorPoint(0, 0)
    node:setPosition(0, size.height - textH)
    panel:addChild(node)
    return node, textW
end

function QingYuanDlg:setHeart(data)
    -- 残缺的
    self:setLabelText("PoXinLabel", data.canq_heart)

    -- 完整的
    self:setLabelText("WanXinLabel", data.wanz_heart)
end

function QingYuanDlg:setCharInfo(data)
    local leftPanel = self:getControl("LeftInforPanel")
    local rightPanel = self:getControl("RightInforPanel")

    -- 我的名字
    self:setLabelText("NameLabel", Me:queryBasic("name"), rightPanel)

    -- 你的名字
    self:setLabelText("NameLabel", data.other_name, leftPanel)

    -- 我的头像
    local myPath = ResMgr:getCirclePortraitPathByIcon(Me:queryBasicInt("org_icon"))
    self:setImage("PortraitImage", myPath, rightPanel)

    -- 你的头像
    local otherPath = ResMgr:getCirclePortraitPathByIcon(data.other_icon)
    self:setImage("PortraitImage", otherPath, leftPanel)


    -- 我的选项
    self:setCtrlVisible("DoubtImage", data.my_op == 0, rightPanel)
    self:setCtrlVisible("ChoiceLabel", data.my_op ~= 0, rightPanel)
    self:setLabelText("ChoiceLabel", CHS[4010126], rightPanel)

    -- 你的选项
    self:setCtrlVisible("DoubtImage", data.other_op == 0, leftPanel)
    self:setCtrlVisible("ChoiceLabel", data.other_op ~= 0, leftPanel)
    self:setLabelText("ChoiceLabel", CHS[4010126], leftPanel)

    if data.my_op ~= 0 and data.other_op ~= 0 then
        self:setLabelText("ChoiceLabel", self:getABCD(data.my_op), rightPanel)
        self:setLabelText("ChoiceLabel", self:getABCD(data.other_op), leftPanel)
    end

    -- 作答情况
    if data.my_op == 0 then
        self:setLabelText("InformationLabel_1", CHS[4010200])
    else
        if data.other_op == 0 then
            self:setLabelText("InformationLabel_1", CHS[4010201])
        else
            self:setLabelText("InformationLabel_1", "")
        end
    end

end

function QingYuanDlg:getABCD(answer)
    if answer == 1 then
        return "A"
    elseif answer == 2 then
        return "B"
    elseif answer == 3 then
        return "C"
    elseif answer == 4 then
        return "D"
    end
end

function QingYuanDlg:onAButton(sender, eventType)
    if not self.data then return end
    --[[
    if self.lockNum == self.data.cur_num then
        gf:ShowSmallTips("答案不可修改。")
        return
    end
--]]
    for i = 1, 3 do
        self:setCtrlEnabled("AButton", false, ANSWER_PANEL[i])

    end

    self.lockNum = self.data.cur_num
    gf:CmdToServer("CMD_QYGD_SELECT_ANSWER_2018", {titleNum = self.data.cur_num, option = sender:getTag()})

 --   self:setCtrlEnabled(sender:getName(), false, sender:getParent():getName())

    self:setCtrlVisible("ChoiceImage", true, sender:getParent():getName())
end

return QingYuanDlg
