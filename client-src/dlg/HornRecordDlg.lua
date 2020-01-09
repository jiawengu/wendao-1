-- HornRecordDlg.lua
-- Created by huangzz Dec/08/2017
-- 喇叭消息界面

local HornRecordDlg = Singleton("HornRecordDlg", Dialog)

local ChatPanel = require("ctrl/ChatPanel")

function HornRecordDlg:init()
    self:bindListener("SendButton", self.onSendButton)
    self:setChatView()
end

function HornRecordDlg:setChatView()
    local infoPanel = self:getControl("InfoPanel")
    local showPanel = self:getControl("InfoRecordPanel")
    local chatData = ChatMgr:getChatData("hornChatData")

    self.chatPanel = ChatPanel.new(chatData, showPanel:getContentSize(), true, self,{portraitScale = 0.9, charFloatOffectX = 0})
    self.chatPanel:setPosition(showPanel:getPosition())
    self.chatPanel:setAnchorPoint(showPanel:getAnchorPoint())
    infoPanel:addChild(self.chatPanel)
    
    if #chatData == 0 then 
        self:setCtrlVisible("NoticePanel", true)
    else
        self:setCtrlVisible("NoticePanel", false)
    end

    self.chatData = chatData
    
    self.lastChatNum = self:getTotalIndex()

    local function refresh ()
        self:refreshChatPanel()
    end

    schedule(self.root, refresh, 0.1)
end

function HornRecordDlg:onSendButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    gf:CmdToServer("CMD_TRY_USE_LABA", {})
end

function HornRecordDlg:refreshChatPanel()
    local totalIndex = self:getTotalIndex()
    if totalIndex == self.lastChatNum then
        return
    end
    
    if self.chatPanel:scroviewllIsIntop() == true then
        self.chatPanel:newMessage()
        self.lastChatNum = totalIndex
    else
        self.chatPanel.canRefreshByOther = false
        self.lastChatNum = totalIndex
        
        local totalNum = #self.chatData
        local startNum = math.max(0, totalNum - (totalIndex - self.lastChatNum))
        for i = startNum, totalNum do
            table.insert(self.chatPanel.lastUpLoadData, self.chatData[i])
        end
    end
    
    if #self.chatData ~= 0 then 
        self:setCtrlVisible("NoticePanel", false)
    end
end

-- 获取当前频道总的条数
function HornRecordDlg:getTotalIndex()
    if self.chatData[#self.chatData] then
        return self.chatData[#self.chatData]["index"] or 0
    else
        return 0
    end
end

function HornRecordDlg:MSG_MESSAGE_EX(data)

end

return HornRecordDlg
