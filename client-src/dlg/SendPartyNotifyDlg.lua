-- SendPartyNotifyDlg.lua
-- Created by songcw Mar/10/2015
-- 发送公告

local SendPartyNotifyDlg = Singleton("SendPartyNotifyDlg", Dialog)

local TYPE_EDITING = 1
local TYPE_EDIT_CANCE = 0

local notifyLimit       = 80

local SAVE_PATH = Const.WRITE_PATH .. "partyPhrase/"

local default_color = cc.c3b(86, 41, 2)

local NOTIFY_COUNT = 8

function SendPartyNotifyDlg:init()
    self:bindListener("CleanName", self.onCleanFieldButton)
    self:bindListener("SaveButton", self.onSaveButton)
    self:bindListener("SendButton", self.onSendButton)
    self:bindListener("CancelSendButton", self.onCancelSendButton)
    self:bindListener("TitleButton", function(dlg, sender, eventType)
        self:setCtrlVisible("CommonLanguePanel_1", true)
    end)
    self:bindFloatPanel("CommonLanguePanel_1")
    self.listView = self:getControl("ListView", Const.UIListView)
    self.clonePanel = self:getControl("OneRowPanel", Const.UIPanel)
    self.clonePanel:retain()
    self.clonePanel:removeFromParent()
    self.listView:removeAllItems()

    self:bindPanels()
    self.editType = TYPE_EDIT_CANCE

    self:setCtrlVisible("TextField", true)

    self:setInputText("TextField", "")
    self.pick = 0
    self.noSave = true

    -- 输入框
    self:setCtrlVisible("CleanName", false)
    local textCtrl = self:getControl("TextField")
    textCtrl:addEventListener(function(sender, eventType)
        if ccui.TextFiledEventType.insert_text == eventType then
            self:setCtrlVisible("CleanName", true)
            local str = textCtrl:getStringValue()
            if gf:getTextLength(str) > notifyLimit * 2 then
                gf:ShowSmallTips(CHS[4000224])
            end
            textCtrl:setText(tostring(gf:subString(str, notifyLimit * 2)))
        elseif ccui.TextFiledEventType.delete_backward == eventType then
            -- 判断是否为空
            local str = sender:getStringValue()
            if "" == str then
                self:setCtrlVisible("CleanName", false)
            end
        end
    end)
    -- {["帮派任务"]="为了帮派的成长，大家快来完成帮派任务吧，可以获得大量帮贡还能提升帮派等级！"}
    local default_text = PartyMgr:getPartyNotifyDef(1)
    self:setContent(default_text.title, default_text.content)
end

function SendPartyNotifyDlg:cleanup()
    self:releaseCloneCtrl("clonePanel")
    self:releaseCloneCtrl("selectEff")
end

function SendPartyNotifyDlg:setContent(key, content)
    self:setButtonText("TitleButton", key)
    self:setInputText("TextField", content)
    self:setCtrlVisible("CleanName", true)
end

function SendPartyNotifyDlg:bindFloatPanel(name)
    local panel = self:getControl(name, Const.UIPanel)
    if not panel then return end

    local function onTouchBegan(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d, name:%s", touchPos.x, touchPos.y, event:getCurrentTarget():getName())

        if not panel or not panel:isVisible() then
            return false
        end

        touchPos = panel:getParent():convertToNodeSpace(touchPos)
        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        return true

    end

    local function onTouchMove(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()

    end

    local function onTouchEnd(touch, event)
        local eventCode = event:getEventCode()
        local touchPos = touch:getLocation()
        Log:D("location : x = %d, y = %d", touchPos.x, touchPos.y)

        local box = panel:getBoundingBox()
        if nil == box then
            return false
        end

        panel:setVisible(false)
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 获取一级二菜单选中光效
function SendPartyNotifyDlg:getSelectEff()
    if nil == self.selectEff then
        -- 创建选择框
        local img = self:getControl("Image", Const.UIImage)
        img:retain()
        img:setVisible(true)
        img:setPosition(0, 0)
        img:setAnchorPoint(0, 0)
        self.selectEff = img
    end

    self.selectEff:removeFromParent(false)

    return self.selectEff
end

function SendPartyNotifyDlg:bindPanels(index)
    self.listView:removeAllItems()
    -- 绑定默认
    for i = 1, 6 do
        local defalut = PartyMgr:getPartyNotifyDef(i)
        local panel = self.clonePanel:clone()
        self:setLabelText("TitleLabel", defalut.title, panel)
        panel:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:setContent(defalut.title, defalut.content)
                self:setCtrlVisible("CommonLanguePanel_1", false)
                self.noSave = true
            end
        end)
        self:setCtrlVisible("DelImage", false, panel)
        self:setCtrlVisible("AddImage", false, panel)
        self:setCtrlVisible("ShowDelImage", false, panel)
        self:setCtrlVisible("ShowAddImage", false, panel)
        self.listView:pushBackCustomItem(panel)
    end
    local default_count = 1
    for i = 1, NOTIFY_COUNT do
        -- 是否有保存的编辑语
        local data = DataBaseMgr:selectItems("partyNotify", string.format("`index`=%d", i))
        if data.count > 0 then
            local phrase = {}
            phrase[data[1].title] = data[1].context
            for keyName, content in pairs(phrase) do
                local panel = self.clonePanel:clone()
                self:setLabelText("TitleLabel", keyName, panel)
                panel:addTouchEventListener(function(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        self:setContent(keyName, content)
                        self:setCtrlVisible("CommonLanguePanel_1", false)
                        self.noSave = false
                        self.index = i
                    end
                end)
                self:setCtrlVisible("DelImage", true, panel)
                self:setCtrlVisible("AddImage", false, panel)
                self:setCtrlVisible("ShowDelImage", true, panel)
                self:setCtrlVisible("ShowAddImage", false, panel)
                self.listView:pushBackCustomItem(panel)
                self:bindListener("DelImage", function(dlg, sender, eventType)
                    self:delPanel(i)
                end, panel)
                default_count = default_count + 1

                if index and i == index then
                    self.index = index
                    self:setContent(keyName, "")
                    self:setCtrlVisible("CommonLanguePanel_1", false)
                    self.noSave = false
                end
            end
        end
    end

    if default_count <= 8 then
        local item = self.clonePanel:clone()
        self:setLabelText("TitleLabel", CHS[3003614], item)
        self:setCtrlVisible("AddImage", true, item)
        self:setCtrlVisible("DelImage", false, item)
        self:setCtrlVisible("ShowDelImage", false, item)
        self:setCtrlVisible("ShowAddImage", true, item)
        item:addTouchEventListener(function(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local dlg = DlgMgr:openDlg("AddPartyNotifyDlg")
                local index = self:getAddNotifyIndex()
                dlg:setTitileAndContent(nil, nil, index)
            end
        end)
        self.listView:pushBackCustomItem(item)
    end

end

function SendPartyNotifyDlg:getAddNotifyIndex()
    local default_count = 1
    for i = 1, NOTIFY_COUNT do
        -- 是否有保存的编辑语
        local data = DataBaseMgr:selectItems("partyNotify", string.format("`index`=%d", i))
        if data.count > 0 then
            local phrase = {}
            phrase[data[1].title] = data[1].context
            if not next(phrase) then
                return i
            end
        else
            return i
        end

        default_count = i + 1
    end

end

function SendPartyNotifyDlg:editCurInfo(sender, eventType)
    self:setCtrlVisible("TextField", true)

    self:setCtrlVisible("InformationPanel", false)
end

function SendPartyNotifyDlg:delPanel(index)
    DataBaseMgr:deleteItems("partyNotify", string.format("`index`=%d", index))
    self:bindPanels()
end

function SendPartyNotifyDlg:onCleanFieldButton(sender, eventType)
    self:setInputText("TextField", "")
    self:setCtrlVisible("CleanFieldButton", false)
end

function SendPartyNotifyDlg:onSaveButton(sender, eventType)

    if self.noSave then
        gf:ShowSmallTips(CHS[3003615])
        return
    end

    -- 标题非空判断
    local titilePanel = self:getControl("NamePanel")
    local title = self:getButtonText("TitleButton")
    if title == "" then
        return
    end

    -- 敏感词判断
    local content = self:getInputText("TextField")

    local title, titleFilt = gf:filtText(title)
    local content, contentFilt = gf:filtText(content)
    if titleFilt or contentFilt then
        --gf:ShowSmallTips("你的输入中含有非法字符，无法保存。")
        return
    end

    local title = self:getButtonText("TitleButton")
    local content = self:getInputText("TextField")

    DataBaseMgr:deleteItems("partyNotify", string.format("`index`=%d", self.index))
    local data = {}
    data.index = self.index
    data.title = title
    data.context = content
    DataBaseMgr:insertItem("partyNotify", data)

    self:bindPanels()

    gf:ShowSmallTips(CHS[3003616])
end

function SendPartyNotifyDlg:onModifyButton(sender, eventType)
    if self.editType == TYPE_EDIT_CANCE then
        self:setLabelText("Label_1", CHS[4000205], sender)
        self:setLabelText("Label_2", CHS[4000205], sender)
        self.editType = TYPE_EDITING
    else
        self:setLabelText("Label_1", CHS[4000204], sender)
        self:setLabelText("Label_2", CHS[4000204], sender)
        self.editType = TYPE_EDIT_CANCE
    end

    --self:setDesc(self:getInputText("TextField"))
    self:setCtrlVisible("TextField", false)
    self:setCtrlVisible("InformationPanel", true)
end

function SendPartyNotifyDlg:onSendButton(sender, eventType)
    local text = self:getInputText("TextField")
    local title = self:getButtonText("TitleButton")
    if not title or title == "" or text == nil or text == "" then
        gf:ShowSmallTips(CHS[3003617])
        return
    end

    local temp, titleFilt = gf:filtText(title)
    local content, contentFilt = gf:filtText(text)
    if titleFilt or contentFilt then
        --gf:ShowSmallTips("你的输入中含有非法字符，无法保存。")
        return
    end

    gf:CmdToServer("CMD_PARTY_SEND_MESSAGE", {
        title = title or "",
        msg = text
    })
end

function SendPartyNotifyDlg:onCancelSendButton(sender, eventType)
    self:onCloseButton()
end

return SendPartyNotifyDlg
