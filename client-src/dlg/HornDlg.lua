-- HornDlg.lua
-- Created by huangzz Dec/08/2017
-- 喇叭界面

local HornDlg = Singleton("HornDlg", Dialog)

local SingleChatPanel = require("ctrl/SingleChatPanel")
local TextView = require("ctrl/TextView")

local WORD_LIMIT = 40

local chatPanel

function HornDlg:init()
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("ItemPanel", self.onItemPanel)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("ExpressionButton", self.onExpressionButton)
    
    DlgMgr:closeDlg("BagDlg")
    
    self:setItemPanel(CHS[5400319])

    self:setCtrlVisible("DelButton", false)
    
    self:setChatPanel()

    self.textView = TextView.new(self, "SearchPanel", self.root)
    self.textView:setFontColor(COLOR3.TEXT_DEFAULT)
    self.textView:bindListener(function(self, sender, event) 
        if 'ended' == event then
            self:setLastNum()
        elseif 'changed' == event then
            local text = self.textView:getText()
            local len = gf:getTextLength(text)
            
            if len > WORD_LIMIT * 2 then
                text = gf:subString(text, WORD_LIMIT * 2)
                self.textView:setText(text)
                gf:ShowSmallTips(CHS[5400041])
            else
                self.textView:showText(text)
            end

            if len > 0 then
                self:setCtrlVisible("DelButton", true)
            else
                self:setCtrlVisible("DelButton", false)
            end
            
            self:setLastNum(true)
        elseif 'began' == event then
            self:setCtrlVisible("DefaultLabel", false, "SearchPanel")
        end
    end)
    
    self:setLastNum()
    
    self:hookMsg("MSG_INVENTORY")
end

function HornDlg:setItemPanel(itemName)
    local path = ResMgr:getIconPathByName(itemName)
    self:setImage("ItemImage", path)
    self.curHornName = itemName
    

    self:setItemAmount()
end

function HornDlg:setChatPanel()
    chatPanel = SingleChatPanel.new({}, true, nil, CHAT_CHANNEL.HORN)
    function chatPanel:getInputStr()
        return HornDlg.textView:getText()
    end

    function chatPanel:setInputStr(text)
        SingleChatPanel.setInputStr(self, text)
        HornDlg.textView:setText(text)

        HornDlg:setLastNum()
    end

    function chatPanel:getWorldLimit()
        return WORD_LIMIT
    end

    function chatPanel:setDelVisible(visible)
        SingleChatPanel.setDelVisible(self, visible)
        HornDlg:setCtrlVisible("DelButton", visible)
    end

    function chatPanel:sendMessage()
        -- 若角色当前处于禁闭状态，则予以如下弹出提示
        if Me:isInJail() then
            gf:ShowSmallTips(CHS[6000214])
            return
        end

        -- 若角色等级不足，则予以如下弹出提示
        if Me:getLevel() < 30 then
            gf:ShowSmallTips(CHS[5400325])
            return
        end

        -- 若玩家被抓捕进监狱
        if Me:isInPrison() then
            gf:ShowSmallTips(CHS[7000073])
            return
        end
        
        -- 不可发送空白消息
        local text = self:getInputStr()
        if ChatMgr:textIsALlSpace(text) then
            gf:ShowSmallTips(CHS[3004013])
            return
        end

        local items = InventoryMgr:getItemByName(HornDlg.curHornName)
        if not next(items) then
            -- 无道具
            if InventoryMgr:isOnlineItem(HornDlg.curHornName) then
                gf:askUserWhetherBuyItem(HornDlg.curHornName)
            else
                gf:ShowSmallTips(string.format(CHS[5420282], HornDlg.curHornName))
            end
        else
            gf:confirm(string.format(CHS[5400323], HornDlg.curHornName), function()
                if chatPanel then
                    SingleChatPanel.sendMessage(chatPanel)
                end
            end)
        end
    end

    -- 表情界面关闭时
    function chatPanel:LinkAndExpressionDlgcleanup()
        -- 界面话还原
        DlgMgr:resetUpDlg("HornDlg")
    end

    function chatPanel:swichWordInput(sender, eventType)
        -- HornDlg.inputPanel:attachWithIME()
        HornDlg.textView:onClick(HornDlg, sender, eventType)
    end

    chatPanel:setVisible(false)
    chatPanel:setCallBack(self, "sendMessage")
    self.blank:addChild(chatPanel)
end

function HornDlg:setLastNum(isInput)
    if not chatPanel then return end

    local text = chatPanel:getInputStr()
    local len = gf:getTextLength(text)
    local num = WORD_LIMIT * 2 - len
    
    if not isInput then
        -- 打开键盘过程中不显示默认文字
        self:setCtrlVisible("DefaultLabel", len == 0, "SearchPanel")
    end
    
    if num <= 0 then
        self:setLabelText("NumLabel", 0, "StatisticsPanel", COLOR3.RED)
    else
        self:setLabelText("NumLabel", math.ceil(num / 2), "StatisticsPanel", COLOR3.GREEN)
    end
end

function HornDlg:setItemAmount()
    local amount = InventoryMgr:getAmountByName(self.curHornName, true)
    if amount == 0 then
        self:setLabelText("NumLabel", amount, "ItemPanel", COLOR3.RED)
    else
        self:setLabelText("NumLabel", amount, "ItemPanel", COLOR3.TEXT_DEFAULT)
    end
end

function HornDlg:onItemPanel(sender, eventType)
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(self.curHornName, rect)
end

function HornDlg:onSendButton(sender, eventType)
    chatPanel:sendMessage()
end

function HornDlg:sendMessage(text)
    local items = InventoryMgr:getItemByName(self.curHornName)
    if not next(items) then
        -- 无道具
        if InventoryMgr:isOnlineItem(self.curHornName) then
            gf:askUserWhetherBuyItem(self.curHornName)
        else
            gf:ShowSmallTips(string.format(CHS[5420282], self.curHornName))
        end
    else
        -- 安全锁判断
        if self:checkSafeLockRelease("sendMessage", text) then
            return
        end

        -- 发送聊天指令
        local data = {}
        data["channel"] = CHAT_CHANNEL.HORN
        data["compress"] = 0
        data["orgLength"] = string.len(text)
        data["msg"] = text
        data["voiceTime"] = 0
        data["token"] = ""
        data["para"] = self.curHornName

        -- 名片处理
        local param = string.match(text, "{\t..-=(..-=..-)}")
        if param then
            data["cardCount"] = 1
            data["cardParam"] = param
        end

        ChatMgr:sendMessage(data)

        return true
    end
end

function HornDlg:onDelButton(sender, eventType)
    chatPanel:setInputStr("")
    chatPanel:setDelVisible(false)
end

function HornDlg:onExpressionButton(sender, eventType)
    local dlg = DlgMgr:getDlgByName("LinkAndExpressionDlg")
    if dlg then
        DlgMgr:closeDlg("LinkAndExpressionDlg")
        return
    end

    dlg = DlgMgr:openDlg("LinkAndExpressionDlg")
    dlg:setCallObj(chatPanel)

    -- 界面上推
    local bkPanel = self:getControl("BKPanel")
    local height = math.max(0, dlg:getMainBodyHeight() - bkPanel:getPositionY())
    DlgMgr:upDlg("HornDlg", height)
end

function HornDlg:MSG_INVENTORY(data)
    self:setItemAmount()
end

function HornDlg:onDlgOpened(list)
    if not list[1] then
        return
    end

    self:setItemPanel(list[1])
end

function HornDlg:cleanup()
    DlgMgr:closeDlg("LinkAndExpressionDlg")
    
    chatPanel = nil
end

return HornDlg
