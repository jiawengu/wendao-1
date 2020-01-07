-- SystemSwitchLineDlg.lua
-- Created by zhengjh Sep/10/2015
-- 换线

local SystemSwitchLineDlg = Singleton("SystemSwitchLineDlg", Dialog)
local lineSapce = 10

local SERVER_STATE =
{
    preserve = SERVER_STATUS.PRESERVER, -- 维护
    normal = SERVER_STATUS.NORMAL, -- 正常
    busy = SERVER_STATUS.BUSY, -- 繁忙
    full = SERVER_STATUS.FULL, -- 爆满
    allFull = SERVER_STATUS.ALLFULL, -- 满员
    free = SERVER_STATUS.FREE, -- 空闲
}

function SystemSwitchLineDlg:init()
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ConfrimButton", self.onConfrimButton)

    self.lineCell = self:getControl("LinePanel")
    self.lineCell:retain()
    self.lineCell:removeFromParent()

    self.selectImage = self:getControl("ChosenImage", Const.UIImage, self.lineCell)
    self.selectImage:retain()
    self.selectImage:removeFromParent()

    -- 请求线的状态
    Client:getGsList()

    self:hookMsg("MSG_REQUEST_SERVER_STATUS")
   -- self:hookMsg("MSG_L_AUTH")
    --self:hookMsg("MSG_L_SERVER_LIST")
    self:initData()

end

function SystemSwitchLineDlg:initData()
    self.lineList = Client:getLineList()
    self.lineList.count = self.lineList.count or 0
    local lineNum = self.lineList.count or 0

    local list ={}
    --[[  for i = 1, lineNum do
    local line = {}
    line.name = CHS[3003703].. i..CHS[3003704]
    table.insert(list, line)
    end]]

    local panel
    if lineNum <= 8 then
        panel = self:getControl("OneColumnPanel")
        self:initListPanel(self.lineList, self.lineCell, self.createLineCell, panel, 1)
        self:setCtrlVisible("TwoColumnPanel", false)
        self:setCtrlVisible("ThreeColumnPanel", false)
    elseif lineNum > 8 and lineNum <= 16 then
        panel = self:getControl("TwoColumnPanel")
        self:initListPanel(self.lineList, self.lineCell, self.createLineCell, panel, 2)
        self:setCtrlVisible("OneColumnPanel", false)
        self:setCtrlVisible("ThreeColumnPanel", false)
    else
        panel = self:getControl("ThreeColumnPanel")
        self:initListPanel(self.lineList, self.lineCell, self.createLineCell, panel, 3)
        self:setCtrlVisible("OneColumnPanel", false)
        self:setCtrlVisible("TwoColumnPanel", false)
    end
end

-- 初值列表数据
function SystemSwitchLineDlg:initListPanel(data, cellColne, func, panel, colunm)
    panel:removeAllChildren()
    local contentLayer = ccui.Layout:create()
    local line = math.floor(data.count / colunm)
    local left = data.count % colunm

    local columnSapce
    if colunm  == 1 then
        columnSapce = 0
    else
        columnSapce = (panel:getContentSize().width - cellColne:getContentSize().width * colunm)/(colunm - 1)
    end

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + lineSapce) - lineSapce

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = colunm
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * colunm
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * (cellColne:getContentSize().width + columnSapce)
            local y = totalHeight - (i - 1) * (cellColne:getContentSize().height + lineSapce)
            cell:setPosition(x, y)
            cell:setTag(tag)
            func(self, cell, data, tag)
            contentLayer:addChild(cell)
        end
    end

    contentLayer:setContentSize(panel:getContentSize().width, totalHeight)
    local scroview = ccui.ScrollView:create()
    scroview:setContentSize(panel:getContentSize())
    scroview:setDirection(ccui.ScrollViewDir.vertical)
    scroview:addChild(contentLayer)
    scroview:setInnerContainerSize(contentLayer:getContentSize())
    scroview:setTouchEnabled(false)
    scroview:setClippingEnabled(true)
    scroview:setBounceEnabled(true)
    contentLayer:setTouchEnabled(true)

    if totalHeight < scroview:getContentSize().height then
        contentLayer:setPositionY((scroview:getContentSize().height  - totalHeight) / 2 )
    end

    panel:addChild(scroview)

    -- 线路大于24条时，需要增加下拉箭头特效
    if self.lineList.count > 24 then
        self.scroview = scroview
        self:updateArrowMagic()
        scroview:addEventListener(function()
            self:updateArrowMagic()
        end)
    end
end

function SystemSwitchLineDlg:updateArrowMagic()
    if self.scroview then
        if self.scroview:getInnerContainer():getPositionY() < 0 then
            self:addMagic("MagicPanel", ResMgr:getMagicDownIcon())
        else
            self:removeMagic("MagicPanel", ResMgr:getMagicDownIcon())
        end
    end
end

function SystemSwitchLineDlg:addSelcelImage(item)
    self.selectImage:removeFromParent()
    item:addChild(self.selectImage)
end

function SystemSwitchLineDlg:createLineCell(cell, data, tag)
    local severName = "server" .. tag
    local lineNameLabel = self:getControl("LineNameLabel", nil, cell)
    lineNameLabel:setString(self:getServerShowStr(data[severName]))

    -- 状态
    local stateImage = self:getControl("StateImage_1", nil, cell)
    stateImage:loadTexture(DistMgr:getServerStateImage(data["status"..tag]))

    -- 状态(爆满，满员)
    local stateImage2 = self:getControl("StateImage_2", nil, cell)
    if data["status"..tag] == SERVER_STATE.full or data["status"..tag] == SERVER_STATE.allFull then
        stateImage2:loadTexture(DistMgr:getServerFullStateExtraImg(data["status"..tag]))
    elseif data["status"..tag] == SERVER_STATE.free then -- 空闲
        stateImage2:loadTexture(DistMgr:getServerFullStateExtraImg(data["status"..tag]))
    else
        stateImage2:setVisible(false)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if data[severName] ~= GameMgr:getServerName() then
                if self.selectServerName == severName  then
                    self:switchLine()
                else
                    self:addSelcelImage(cell)
                    self.selectServerName = severName
                    self.selectTag = tag
                end
            end
        end
    end

    if data[severName] == GameMgr:getServerName() then
        self:setCtrlVisible("CurrentImage", true, cell)
        self:setCtrlVisible("MaintenanceImage", true, cell)
    elseif  data["status"..tag] == SERVER_STATE.free or data["status"..tag] == SERVER_STATE.preserve then -- 空闲状态  和维护状态
        self:setCtrlVisible("MaintenanceImage", true, cell)
    end

    cell:addTouchEventListener(listener)
end

function SystemSwitchLineDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function SystemSwitchLineDlg:onConfrimButton(sender, eventType)
   -- Client:enterLine(lineName)
   if not self.selectServerName then
        gf:ShowSmallTips(CHS[3003705])
        return
   end
   self:switchLine()
end

function SystemSwitchLineDlg:getServerShowStr(serverName)
    return DistMgr:getServerShowStr(serverName)
end

function SystemSwitchLineDlg:switchLine()
    -- 在换线中，防止点击两次
    if self.selectTag then
        local serverShowName = self.lineList["server"..self.selectTag]
        if self.lineList["status"..self.selectTag] == SERVER_STATE.preserve then -- 维护
            gf:ShowSmallTips(serverShowName..CHS[3003707])
            return
        elseif self.lineList["status"..self.selectTag] == SERVER_STATE.full then
            if  Me:isTeamLeader() and  TeamMgr:getTeamNum() > 1 then
                gf:ShowSmallTips(serverShowName..CHS[3003708])
                return
            else
                if not Me:isVip() then
                    gf:ShowSmallTips(serverShowName..CHS[3003709])
                    return
                end
            end
        elseif self.lineList["status"..self.selectTag] == SERVER_STATE.allFull then --满员
            gf:ShowSmallTips(serverShowName..CHS[3003710])
            return
        elseif self.lineList["status"..self.selectTag] == SERVER_STATE.free then -- 空闲
            gf:ShowSmallTips(serverShowName..CHS[3003711])
            return
        end
    end

    --gf:CmdToServer("CMD_LOGOUT")
    --CommThread:stop()
    --DistMgr:connetAAA(GameMgr.dist, true, true)
    --Client:setEnterLineServerName(self.lineList[self.selectServerName])
    DistMgr:swichLine(self.lineList[self.selectServerName])
end

-- aaa链接成功
function SystemSwitchLineDlg:MSG_L_AUTH(map)
    if map["result"] == 1 then
        Client:tryLogin()
    else
        gf:ShowSmallTips(map["msg"])
    end
end

-- 刷新线信息
function SystemSwitchLineDlg:MSG_REQUEST_SERVER_STATUS()
    if Client:getIsLineInfoChange() then
        self:initData()
    end
end

function SystemSwitchLineDlg:cleanup()
    self.selectServerName = nil
    self.selectTag = nil
    self:releaseCloneCtrl("lineCell")
    self:releaseCloneCtrl("selectImage")
    self.inSwichLine = nil
    self.scroview = nil
end


return SystemSwitchLineDlg
