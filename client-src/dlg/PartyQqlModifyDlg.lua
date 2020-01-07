-- PartyQqlModifyDlg.lua
-- Created by songcw Mar/24/2015
-- 帮派智多星设置界面（原圈圈了设置界面）

local NumImg = require('ctrl/NumImg')

local PartyQqlModifyDlg = Singleton("PartyQqlModifyDlg", Dialog)

local HOUR_MAX = 23
local HOUR_MIN = 0
local MINUTE_MAX = 59
local MINUTE_MIN = 0

local SERVER_STATE =
    {
        preserve = 1, -- 维护
        normal = 2, -- 正常
        busy = 3, -- 繁忙
        full = 4, -- 爆满
        allFull = 5, -- 满员
        free = 6, -- 空闲
    }

function PartyQqlModifyDlg:init()
    self:bindListener("SaveButton", self.onSaveButton)
    self:bindListener("ServerBKImage", self.onExpendButton)
    self:bindListener("ExpendButton", self.onExpendButton)
    self:bindListener("HelpBKImage", self.onExpendButton)
    self:bindListener("ExpendButton2", self.onExpendButton)
    self:bindListener("HardBKImage", self.onExpendButton)
    self:bindListener("ExpendButton3", self.onExpendButton)
    self:bindListener("SetButton", self.onExpendButton)
    self:bindListener("TimeBKImage", self.onExpendButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("InfoButton", self.onInfoButton)
    
    for i = 1, 3 do
        self:bindListener("HardPanel" .. i, self.onHardPanel, "HardPanel")
    end
    
    for i = 1, 4 do
        self:bindListener("HelpPanel" .. i, self.onHelpPanel, "HelpPanel")
    end
    
    self.itemPanel = self:getControl("LinePanel_1")
    self.itemPanel:retain()
    self.itemPanel:removeFromParent()
    
    local statePanel = self:getControl("OpenStatePanel")
    self.isOn = (PartyMgr:getZdxOpenType() == 1) 
    self:createSwichButton(statePanel, self.isOn, self.onCheckBox, nil, self.isLimtSwich)
    self:onCheckBox(self.isOn, nil, true)
    
    self:hookMsg("MSG_PARTY_INFO")
    self:hookMsg("MSG_REQUEST_SERVER_STATUS")
    self:hookMsg("MSG_PARTY_ZHIDUOXING_INFO") 
    
    -- 更新线信息
    Client:getGsList()
    local listView = self:getControl("ListView")
    listView:removeAllChildren()
    self.isShowTips = false
    self:MSG_REQUEST_SERVER_STATUS()
    
    -- 设置自动开启时间
    self.selectHours, self.selectMinutes = PartyMgr:getZdxAutoStartTime() 
    self:setAutoStartTime(self.selectHours, self.selectMinutes)
    
    -- 设置求助等级
    self:setAutoHelpLevel(PartyMgr:getZdxAutoHelpLevel() or 0)
    
    -- 设置难度
    self:setAutoHardLevel(PartyMgr:getZdxAutoHardLevel() or 0)
    
    self.numPanel = self:getControl("SingelPanel")
    self.numPanel:retain()
    self.numPanel:removeFromParent()
    self.minList = self:resetListView("MinListView", 0, ccui.ListViewGravity.centerHorizontal)
    self.maxList = self:resetListView("MaxListView", 0, ccui.ListViewGravity.centerHorizontal)
    
    self:setTimeList()
end

function PartyQqlModifyDlg:isLimtSwich(isOn)
    if not PartyMgr:partyZdxOpenCondition() then return true end 
    if self.selectLine == 0 then
        gf:ShowSmallTips(CHS[3003261])
        return true 
    end
    
    if not isOn then
        gf:confirm(CHS[5410129], function()
            self:switchButtonStatus(self:getControl("OpenStatePanel"), not isOn)
            self:onCheckBox(not isOn, nil)
        end)
    else
        return false
    end
    
    return true
end

function PartyQqlModifyDlg:setInfo(str)
--    self:setLabelText("NoteLabel", string.format(CHS[4000267], str))
end

function PartyQqlModifyDlg:onSelectLine(sender, eventType, isInit)
    local tag = sender:getTag()
    local severName = "server" .. sender:getTag()
    if not Client.lineList[severName] then return end
    if Client.lineList["status" .. tag] == SERVER_STATE.preserve then -- 维护
        gf:ShowSmallTips(Client.lineList[severName]..CHS[6200021])       
        return  
    end  

    self:setColorText(self:getServerShowStr(Client.lineList[severName]), "TextPanel1", nil, nil, nil, COLOR3.WHITE, 21, true)
    self:setCtrlVisible("NoteLabel1", false)
    self:setCtrlVisible("SelectLinePanel", false)
    
    if isInit then return end
    self.selectLine = Client.lineList["id" .. tag]   
    PartyMgr:setZdxOpenType(4, self.selectLine)
    
    if PartyMgr:getZdxOpenType() ~= 1 then
        gf:ShowSmallTips(CHS[3003262])
    end
end

function PartyQqlModifyDlg:onExpendButton(sender, eventType)
    local name = sender:getName()
    if name == "ExpendButton" or name == "ServerBKImage" then
        -- 线路
        local selevtPanel = self:getControl("SelectLinePanel")
        selevtPanel:setVisible(not selevtPanel:isVisible()) 
        self:setCtrlVisible("HelpPanel", false)
        self:setCtrlVisible("HardPanel", false)
        self:setCtrlVisible("TimeSettingPanel", false)
    elseif name == "ExpendButton2" or name == "HelpBKImage" then
        -- 求助级别
        local halpPanel = self:getControl("HelpPanel")
        halpPanel:setVisible(not halpPanel:isVisible())
        self:setCtrlVisible("SelectLinePanel", false)
        self:setCtrlVisible("HardPanel", false)
        self:setCtrlVisible("TimeSettingPanel", false)
    elseif name == "ExpendButton3" or name == "HardBKImage" then
        -- 难度
        local hardPanel = self:getControl("HardPanel")
        hardPanel:setVisible(not hardPanel:isVisible())
        self:setCtrlVisible("SelectLinePanel", false)
        self:setCtrlVisible("HelpPanel", false)
        self:setCtrlVisible("TimeSettingPanel", false)
    elseif name == "SetButton" or name == "TimeBKImage" then
        -- 时间
        self:setCtrlVisible("TimeSettingPanel", true)
        self:setCtrlVisible("HardPanel",false)
        self:setCtrlVisible("SelectLinePanel", false)
        self:setCtrlVisible("HelpPanel", false)
    end
end

-- 选择求助等级
function PartyQqlModifyDlg:onHelpPanel(sender, eventType)
    local level = tonumber(string.match(sender:getName(), "(%d)$"))
    local function setHelpLevel()
        if DlgMgr:isDlgOpened("PartyQqlModifyDlg") then
            self:setAutoHelpLevel(level)
            PartyMgr:setZdxOpenType(7, level)
        end
    end
    
    if level < 4 then
        gf:confirm(string.format(CHS[5420225] .. CHS[5420229], self:getHelpLevelStr(level)), setHelpLevel)
    else
        gf:confirm(string.format(CHS[5420225], self:getHelpLevelStr(level)), setHelpLevel)
    end
end

-- 选择难度
function PartyQqlModifyDlg:onHardPanel(sender, eventType)
    local level = string.match(sender:getName(), "(%d)$")
    self:setAutoHardLevel(tonumber(level))
    PartyMgr:setZdxOpenType(6, level)
end

function PartyQqlModifyDlg:onSaveButton(sender, eventType)
    if self.selectLine == 0 then
        gf:ShowSmallTips(CHS[3003263])
        return 
    end
    
    if self.selectLine == PartyMgr:getPartyZdxOpenLine() or self.isOn == (PartyMgr:getZdxOpenType() == 1) then
        -- 设置保持一致
        gf:ShowSmallTips(CHS[3003264])
        return
    end
    if self.isOn then
        PartyMgr:setZdxOpenType(1, self.selectLine)
    else
        PartyMgr:setZdxOpenType(2, self.selectLine)
    end

end

function PartyQqlModifyDlg:onCheckBox(isOn, key, isInit)
    if isOn then
        self:setCtrlVisible("AutoTimePanel", true)
        self:setCtrlVisible("ManualTimePanel", false)
        self:setLabelText("OpenLabel", CHS[3003266])     
        
        if not isInit then
            PartyMgr:setZdxOpenType(1, self.selectLine)   
        end
    else
        self:setCtrlVisible("AutoTimePanel", false)
        self:setCtrlVisible("ManualTimePanel", true)
        self:setLabelText("OpenLabel", CHS[3003267])
        if not isInit then
            PartyMgr:setZdxOpenType(2, self.selectLine)   
        end
    end    

    self.isOn = isOn
end

-- 创建数字图片对象
function PartyQqlModifyDlg:createTimeItem(level)
    if not self.numPanel then
        return
    end

    local itemContentSize = self.numPanel:getContentSize()

    local ctrl = ccui.Layout:create()
    ctrl:setContentSize(itemContentSize)
    local img = NumImg.new('white_25_black', level)
    img:setPosition(itemContentSize.width / 2, itemContentSize.height / 2)
    ctrl:addChild(img)

    return ctrl
end

function PartyQqlModifyDlg:setTimeList()
    -- 前后各加2个空位
    for i = HOUR_MIN - 2, HOUR_MAX + 2  do
        local item
        if i < HOUR_MIN or i > HOUR_MAX then
            item = self.numPanel:clone()
        else
            if i < 10 then
                item = self:createTimeItem("0" .. i)
            else
                item = self:createTimeItem(i)
            end
        end

        self.minList:pushBackCustomItem(item)
    end
    
    for i = MINUTE_MIN - 2, MINUTE_MAX + 2 do
        local item
        if i < MINUTE_MIN or i > MINUTE_MAX then
            item = self.numPanel:clone()
        else
            if i < 10 then
                item = self:createTimeItem("0" .. i)
            else
                item = self:createTimeItem(i)
            end
        end

        self.maxList:pushBackCustomItem(item)
    end
    
    local labelSize = self.numPanel:getContentSize()
    
    local function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local delay = cc.DelayTime:create(0.15)
            local func = cc.CallFunc:create(function()
                local scrollHeight = sender:getInnerContainer():getContentSize().height - sender:getContentSize().height
                local _, offY = sender:getInnerContainer():getPosition()
                local befPercent = offY / (scrollHeight) * 100 + 100
                local absOff = math.abs(offY)
                
                -- 区分分钟滑动，还是小时滑动
                local numMax, numMin
                if sender == self.minList then
                    numMax = HOUR_MAX
                    numMin = HOUR_MIN
                else
                    numMax = MINUTE_MAX
                    numMin = MINUTE_MIN
                end
                
                local num = numMax - math.floor(absOff / labelSize.height + 0.5)
                local percent = ((num - numMin) * labelSize.height) / (scrollHeight) * 100
                if befPercent ~= percent and num >= numMin and num <= numMax then
                    sender:scrollToPercentVertical(percent, 0.5, false)
                    if sender == self.minList then
                        self.selectHours = num
                    else
                        self.selectMinutes = num
                    end
                end
            end)
            sender:stopAllActions()
            sender:runAction(cc.Sequence:create(delay, func))
        end
    end
    
    self.minList:addScrollViewEventListener(scrollListener)
    self.maxList:addScrollViewEventListener(scrollListener)
      
    if not self.selectHours then self.selectHours = 12 end
    if not self.selectMinutes then self.selectMinutes = 35 end
    
    local labelSize = self.numPanel:getContentSize()
    local minY = self.selectHours * labelSize.height
    local maxY = self.selectMinutes * labelSize.height
    performWithDelay(self.root,function ()
        if not self.minList or not self.maxList then 
            return 
        end

        self.minList:getInnerContainer():setPositionY(minY)
        self.maxList:getInnerContainer():setPositionY(maxY)
        self.minList:requestRefreshView()
        self.maxList:requestRefreshView()
    end, 0)
end

function PartyQqlModifyDlg:onConfirmButton(sender, eventType)
    self:setCtrlVisible("TimeSettingPanel", false)
    
    local labelSize = self.numPanel:getContentSize()
    local _, offY = self.minList:getInnerContainer():getPosition()
    self.selectHours = HOUR_MAX - math.floor(math.abs(offY) / labelSize.height + 0.5)
    _, offY = self.maxList:getInnerContainer():getPosition()
    self.selectMinutes = MINUTE_MAX - math.floor(math.abs(offY) / labelSize.height + 0.5)
    
    self:setAutoStartTime(self.selectHours, self.selectMinutes)
    
    PartyMgr:setZdxOpenType(5, string.format("%02d:%02d", self.selectHours, self.selectMinutes))
end

function PartyQqlModifyDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("ZhiDuoXingInfoDlg")
end


function PartyQqlModifyDlg:setAutoStartTime(hours, minutes)
    if not hours then 
        hours = 12 
    end
    if not minutes then 
        minutes = 35 
    end
    
    if hours < 10 then
        hours = "0" .. hours
    end

    if minutes < 10 then
        minutes = "0" .. minutes
    end

    self:setLabelText("TimeLabel_2", hours .. ":" .. minutes)
end

function PartyQqlModifyDlg:getHelpLevelStr(helpLevel)
    local str
    if helpLevel == 0 then 
        str = ""
    elseif helpLevel == 1 then
        str = CHS[5420222]
    elseif helpLevel == 2 then
        str = CHS[5420223]
    elseif helpLevel == 3 then
        str = CHS[5420224]
    elseif helpLevel == 4 then
        str = CHS[5420221]
    end
    
    return str
end

function PartyQqlModifyDlg:setAutoHelpLevel(helpLevel)
    -- 未配置求助时，默认显示不开放
    helpLevel = helpLevel == 0 and 4 or helpLevel
    local str = self:getHelpLevelStr(helpLevel)

    self:setColorText(str, "TextPanel2", nil, nil, nil, COLOR3.WHITE, 21, true)
    self:setCtrlVisible("NoteLabel2", helpLevel == 0)
    self:setCtrlVisible("HelpPanel", false)
end

function PartyQqlModifyDlg:getHardLevelStr(hardLevel)
    local str
    if hardLevel == 0 then 
        str = ""
    elseif hardLevel == 1 then
        str = CHS[5420226]
    elseif hardLevel == 2 then
        str = CHS[5420227]
    elseif hardLevel == 3 then
        str = CHS[5420228]
    end

    return str
end

function PartyQqlModifyDlg:setAutoHardLevel(hardLevel)
    -- 未配置难度时，默认显示普通难度
    hardLevel = hardLevel == 0 and 2 or hardLevel
    local str = self:getHardLevelStr(hardLevel)
    
    self:setColorText(str, "TextPanel3", nil, nil, nil, COLOR3.WHITE, 21, true)
    self:setCtrlVisible("NoteLabel3", hardLevel == 0)
    self:setCtrlVisible("HardPanel", false)
end

function PartyQqlModifyDlg:MSG_PARTY_INFO()
    if PartyMgr:getZdxOpenType() == 1 then
        self:setCheck("CheckBox", true)
        self:setInfo(CHS[4000271])
    else
        self:setCheck("CheckBox", false)
        self:setInfo(CHS[4000272])
    end
    
    self.selectLine = PartyMgr:getPartyZdxOpenLine()
end

-- 刷新线信息
function PartyQqlModifyDlg:MSG_REQUEST_SERVER_STATUS()
    -- 设置上次选中的线
    local data = Client:getLineList()
    self.selectLine = PartyMgr:getPartyZdxOpenLine()
    if self.selectLine ~= 0 and DistMgr:isServerIdExsit(self.selectLine)then
        local sender = ccui.Button:create()
        sender:setTag(DistMgr:getIndexByServerId(self.selectLine) or 1)        self:onSelectLine(sender, nil, true)
    elseif self.selectLine ~= 0 and not DistMgr:isServerIdExsit(self.selectLine) and not self.isShowTips then
        self.isShowTips = true
        gf:ShowSmallTips(CHS[6400032])
        PartyMgr:setZdxOpenType(4, 0) 
        PartyQqlModifyDlg:onCheckBox(false, nil, true)
        self:switchButtonStatus(self:getControl("OpenStatePanel"), false)   
    end
    
    -- 设置线列表
    local listView = self:getControl("ListView")
    listView:removeAllChildren()
    for i = 1, data.count do
        local cell = self.itemPanel:clone()
        local stateImage = self:getControl("StateImage_1", nil, cell)
        stateImage:loadTexture(DistMgr:getServerStateImage(data["status" .. i]))
        
        -- 状态(爆满，满员)
        local stateImage2 = self:getControl("StateImage_2", nil, cell)
        if data["status"..i] == SERVER_STATE.full or data["status"..i] == SERVER_STATE.allFull then
            stateImage2:loadTexture(DistMgr:getServerFullStateExtraImg(data["status"..i]))
        elseif data["status"..i] == SERVER_STATE.free then -- 空闲
            stateImage2:loadTexture(DistMgr:getServerFullStateExtraImg(data["status"..i]))
        else
            stateImage2:setVisible(false)
        end
        
        local severName = "server" .. i
        local lineNameLabel = self:getControl("LineNameLabel", nil, cell)
        lineNameLabel:setString(self:getServerShowStr(data[severName]))
        listView:pushBackCustomItem(cell)
        
        cell:setTag(i)
        self:bindTouchEndEventListener(cell, self.onSelectLine)
    end
end

function PartyQqlModifyDlg:getServerShowStr(serverName)
    return DistMgr:getServerShowStr(serverName)
end

function PartyQqlModifyDlg:MSG_PARTY_ZHIDUOXING_INFO(data)
    self:setAutoHelpLevel(data.help_level)
    self:setAutoHardLevel(data.hard_level)
end

function PartyQqlModifyDlg:cleanup()
    self:releaseCloneCtrl("itemPanel")
    self:releaseCloneCtrl("numPanel")
end

return PartyQqlModifyDlg
