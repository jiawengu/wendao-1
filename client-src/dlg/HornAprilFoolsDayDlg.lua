-- HornAprilFoolsDayDlg.lua
-- Created by huangzz Oct/31/2018
-- 愚人节喇叭界面

local HornAprilFoolsDayDlg = Singleton("HornAprilFoolsDayDlg", Dialog)

local SingleChatPanel = require("ctrl/SingleChatPanel")
local TextView = require("ctrl/TextView")

local WORD_LIMIT = 40

local chatPanel

local NPCS = {
    {name = CHS[3000795], icon = 06010}, -- 多闻道人
    {name = CHS[5400731], icon = 06018}, -- 黄仨儿
    {name = CHS[5400737], icon = 06019}, -- 莲花姑娘
    {name = CHS[5400743], icon = 06033}, -- 杨镖头
    {name = CHS[3000881], icon = 06052}, -- 文殊天尊
    {name = CHS[3000911], icon = 06053}, -- 云中子
    {name = CHS[3000918], icon = 06054}, -- 龙吉公主
    {name = CHS[3000904], icon = 06055}, -- 太乙真人
    {name = CHS[3000926], icon = 06056}, -- 石矶娘娘
    {name = CHS[3000854], icon = 06057}, -- 蒙面
    {name = CHS[3000804], icon = 06059}, -- 乐善施
    {name = CHS[3000865], icon = 06060}, -- 月老
    {name = CHS[4200142], icon = 06079}, -- 东海龙王
    {name = CHS[3000852], icon = 06091}, -- 神算子
    {name = CHS[3000849], icon = 06231}, -- 无名剑客
}

function HornAprilFoolsDayDlg:init()
    self:bindListener("SelectButton", self.onSelectButton)
    self:bindListener("UserButton", self.onUserButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("ExpressionButton", self.onExpressionButton)
    
    self:setChatPanel()

    self.textView = TextView.new(self, "TextPanel", self.root, 20)
    self.textView:setFontColor(COLOR3.TEXT_DEFAULT)
    self.textView:bindListener(function(self, sender, event)
        if 'changed' == event then
            local text = self.textView:getText()
            local len = gf:getTextLength(text)
            
            if len > WORD_LIMIT * 2 then
                text = gf:subString(text, WORD_LIMIT * 2)
                gf:ShowSmallTips(CHS[5400041])
            end

            self:setBoxText(text)
        end
    end)

    self:setBoxText("")

    self.userPanel = self:retainCtrl("UserPanel")
    self:initNpcList()
end

function HornAprilFoolsDayDlg:setBoxText(text)
    if text and text ~= "" then
        self:setCtrlVisible("DelButton", true)
        self:setCtrlVisible("DefaultLabel", false)
    else
        self:setCtrlVisible("DelButton", false)
        self:setCtrlVisible("DefaultLabel", true)
    end

    self.textView:setText(text)
end

function HornAprilFoolsDayDlg:setChatPanel()
    chatPanel = SingleChatPanel.new({}, true, nil, CHAT_CHANNEL.HORN)
    local this = self
    function chatPanel:getInputStr()
        return this.textView:getText()
    end

    function chatPanel:setInputStr(text)
        SingleChatPanel.setInputStr(self, text)
        this:setBoxText(text)
    end

    function chatPanel:getWorldLimit()
        return WORD_LIMIT
    end

    function chatPanel:setDelVisible(visible)
        SingleChatPanel.setDelVisible(self, visible)
        this:setCtrlVisible("DelButton", visible)
    end

    -- 表情界面关闭时
    function chatPanel:LinkAndExpressionDlgcleanup()
        -- 界面话还原
        DlgMgr:resetUpDlg("HornAprilFoolsDayDlg")
    end

    function chatPanel:swichWordInput(sender, eventType)
        this.textView:onClick(this, sender, eventType)
    end

    function chatPanel:sendMessage()
        -- 不可发送空白消息
        local text = self:getInputStr()
        if ChatMgr:textIsALlSpace(text) then
            gf:ShowSmallTips(CHS[3004013])
            return
        end

        if SingleChatPanel.sendMessage(self) then
            this:onCloseButton()
        end
    end


    chatPanel:setVisible(false)
    chatPanel:setCallBack(self, "sendMessage")
    self.blank:addChild(chatPanel)
end

function HornAprilFoolsDayDlg:initNpcList()
    local size = self.userPanel:getContentSize()
    local panel = self:getControl("ListPanel")
    for i = 1, #NPCS do
        local cell = self.userPanel:clone()
        local x = 5 + (i - 1) % 3 * size.width
        local y = 10 + (5 - math.ceil(i / 3)) * size.height
        cell:setPosition(x, y)
        self:setLabelText("NameLabel", NPCS[i].name, cell)
        self:setImage("IconImage", ResMgr:getSmallPortrait(NPCS[i].icon), cell)
        panel:addChild(cell)

        cell.data = NPCS[i]
    end

    self.selectNpc = nil
    self:setCtrlVisible("NameLabel", false, "SelectButton")
    self:setCtrlVisible("IconImage", false, "SelectButton")
    self:setCtrlVisible("TipLabel", true, "SelectButton")
end

function HornAprilFoolsDayDlg:onSelectButton(sender, eventType)
    self:setCtrlVisible("ListPanel", true)
end

function HornAprilFoolsDayDlg:onUserButton(sender, eventType)
    local data = sender:getParent().data
    if data then
        self.selectNpc = data
        self:setLabelText("NameLabel", data.name, "SelectButton")
        self:setImage("IconImage", ResMgr:getSmallPortrait(data.icon), "SelectButton")
        self:setCtrlVisible("NameLabel", true, "SelectButton")
        self:setCtrlVisible("IconImage", true, "SelectButton")
        self:setCtrlVisible("TipLabel", false, "SelectButton")
    end

    self:setCtrlVisible("ListPanel", false)
end

function HornAprilFoolsDayDlg:onSendButton(sender, eventType)
    chatPanel:sendMessage()
end

function HornAprilFoolsDayDlg:sendMessage(text)
    -- 不可发送空白消息
    if ChatMgr:textIsALlSpace(text) then
        gf:ShowSmallTips(CHS[3004013])
        return
    end

    -- 名片
    local param = string.match(text, "{\t..-=(..-=..-)}")
    if param then
        gf:ShowSmallTips(CHS[5410325])
        return
    end

    if not self.selectNpc then
        gf:ShowSmallTips(CHS[5450365])
        return
    end

    DlgMgr:reopenDlg("ChannelDlg")
    DlgMgr:openDlgWithParam(string.format("ChannelDlg=%d", CHAT_CHANNEL.WORLD))

    local data = {}
    data["npc"] = self.selectNpc.name
    data["content"] = text

    gf:CmdToServer("CMD_USE_FOOLS_DAY_LABA", data)

    return true
end

function HornAprilFoolsDayDlg:onDelButton(sender, eventType)
    chatPanel:setInputStr("")
    chatPanel:setDelVisible(false)
end

function HornAprilFoolsDayDlg:onExpressionButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(chatPanel, "hornFools")

    -- 界面上推
    local bkPanel = self:getControl("BKPanel")
    local height = math.max(0, dlg:getMainBodyHeight() - bkPanel:getPositionY())
    DlgMgr:upDlg("HornAprilFoolsDayDlg", height)
end

function HornAprilFoolsDayDlg:cleanup()
    DlgMgr:closeDlg("LinkAndExpressionDlg")
    
    chatPanel = nil
end

return HornAprilFoolsDayDlg
