-- InnEventDlg.lua
-- Created by songcw Apr/20/2018
-- 客栈-砍价小游戏

local InnEventDlg = Singleton("InnEventDlg", Dialog)

local MAX_TIME_SECOND = 10

function InnEventDlg:init()
    self:bindListener("SmallButton", self.onSmallButton)
    self:bindListener("BigButton", self.onBigButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("ComeInButton", self.onComeInButton)

    self:setCtrlVisible("StartPanel", true)
    self:setCtrlVisible("EndPanel", false)

    self.bigButton = self:retainCtrl("BigButton")
    self.smallButton = self:retainCtrl("SmallButton")
    self.numPanel = self:retainCtrl("NumPanel")


    self:setLabelText("TimeLabel", string.format(CHS[4200423], MAX_TIME_SECOND))
    self:setProgressBar("ProgressBar", 100, 100)

    self:hookMsg("MSG_HEISHI_KANJIA_INFO")

    self.data = nil
    self.startTickCount = nil
    self.pauseAddTime = 0
    self.lastBtn = nil
    self.isOver = false

    self:setFullScreen()
end

function InnEventDlg:gameOver()
    self:setCtrlVisible("CloseButton", false)
    self:setCtrlVisible("EndPanel", true)
    self:removeBtns()
    local youhui = self.data.orgPrice - self.data.price
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, youhui, false, LOCATE_POSITION.LEFT_TOP, 25, "EndPanel")

    self.isOver = true
end

function InnEventDlg:onUpdate()
    if not self.data then return end
    if self.data.isStart ~= 1 then return end

    if not self.startTickCount then return end


    self:setProgressBar("ProgressBar", MAX_TIME_SECOND * 1000 - (gfGetTickCount() - self.startTickCount - self.pauseAddTime), MAX_TIME_SECOND * 1000)
    local s = math.min(MAX_TIME_SECOND, math.ceil((MAX_TIME_SECOND * 1000 - (gfGetTickCount() - self.startTickCount - self.pauseAddTime)) / 1000))
    s = math.max(0, s)
    self:setLabelText("TimeLabel", string.format(CHS[4200423], s))

    if MAX_TIME_SECOND * 1000 - (gfGetTickCount() - self.startTickCount - self.pauseAddTime) <= 0 then
      --  gf:CmdToServer("CMD_HEISHI_KANJIA_QUIT", {})

        if not self:getCtrlVisible("EndPanel") then
            self:gameOver()
        end
    end

end

function InnEventDlg:removeBtns()
    for i = 1, 4 do
        local panel = self:getControl("RoundPanel" .. i)
        local btn1 = panel:getChildByTag(1)
        if btn1 then btn1:removeFromParent() end

        local btn2 = panel:getChildByTag(2)
        if btn2 then btn2:removeFromParent() end
    end
end

function InnEventDlg:onSmallButton(sender, eventType)
    gf:CmdToServer("CMD_HEISHI_KANJIA", {kanjia = 0})
    self.lastBtn = {}
    self.lastBtn.pos = {x = sender:getPositionX(), y = sender:getPositionY()}
    self.lastBtn.kanjia = 0
    self.lastBtn.parentName = sender:getParent():getName()
    self:removeBtns()
end

function InnEventDlg:onBigButton(sender, eventType)
    gf:CmdToServer("CMD_HEISHI_KANJIA", {kanjia = 1})
    self.lastBtn = {}
    self.lastBtn.pos = {x = sender:getPositionX(), y = sender:getPositionY()}
    self.lastBtn.kanjia = 1
    self.lastBtn.parentName = sender:getParent():getName()
    self:removeBtns()
end


function InnEventDlg:onComeInButton(sender, eventType)
    gf:CmdToServer("CMD_HEISHI_KANJIA_QUIT", {})
    DlgMgr:closeDlg(self.name)

    local npc = CharMgr:getCharByName(CHS[4200527])
    if npc then
        CharMgr:openNpcDlg(npc:getId())
    end
end


function InnEventDlg:onStartButton(sender, eventType)

    self:setCtrlVisible("StartPanel", false)

    gf:CmdToServer("CMD_HEISHI_KANJIA_START", {})
end

function InnEventDlg:randomPos(rType)
    local function createPos(panelIndex, btn)
        local x, y
        local panel = self:getControl("RoundPanel" .. panelIndex)

        if panelIndex == 1 then
            y = math.random(btn:getContentSize().height * 0.5, panel:getContentSize().height)
        elseif panelIndex == 4 then
            y = math.random(0, panel:getContentSize().height - btn:getContentSize().height * 0.4)
        else
            y = math.random(0, panel:getContentSize().height)
        end

        x = math.random(btn:getContentSize().width * 0.5, panel:getContentSize().width - btn:getContentSize().width * 0.5)

        return {x = x, y = y}
    end

    local function addButton(btn, tag)
        local panelIndex = math.random(1, 4)
        local panel = self:getControl("RoundPanel" .. panelIndex)
        local pos = createPos(panelIndex, btn)
        local sBtn = btn:clone()
        sBtn:setPosition(pos)
        sBtn:setTag(tag)
        panel:addChild(sBtn)
        return self:getBoundingBoxInWorldSpace(sBtn)
    end

    self:removeBtns()


    if rType == 1 then
        -- 1个小刀

        addButton(self.smallButton, 1)
    elseif rType == 2 then
        -- 1个大刀

        addButton(self.bigButton, 1)
    elseif rType == 3 then
        -- 1个小刀+1个大刀

        local rect1 = addButton(self.smallButton, 1)
        local rect2 = addButton(self.bigButton, 2)
        if cc.pGetDistance(rect1, rect2) <= 150 then
            self:randomPos(rType)
        end
    elseif rType == 4 then
        -- 2个小刀

        local rect1 = addButton(self.smallButton, 1)
        local rect2 = addButton(self.smallButton, 2)
        if cc.pGetDistance(rect1, rect2) <= 150 then
            self:randomPos(rType)
        end
    elseif rType == 5 then
        -- 2个大刀

        local rect1 = addButton(self.bigButton, 1)
        local rect2 = addButton(self.bigButton, 2)
        if cc.pGetDistance(rect1, rect2) <= 150 then
            self:randomPos(rType)
        end
    end
end

function InnEventDlg:MSG_HEISHI_KANJIA_INFO(data)


    if self.data and self.data.isStart == 0 and data.isStart == 1 then
        self.startTickCount = self.startTickCount or gfGetTickCount()
        MAX_TIME_SECOND = data.totalTime
    end

    self.data = data

    -- 道具名
    self:setLabelText("ItemNameLabel", data.itemName)

    -- icon
    self:setImage("ItemImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(data.itemName)))

    self:setNumImgForPanel("ItemCountPanel", ART_FONT_COLOR.NORMAL_TEXT, data.itemsCount, false, LOCATE_POSITION.RIGHT_BOTTOM, 21)

    -- 现价
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, data.price, false, LOCATE_POSITION.LEFT_TOP, 23, "PricePanel")

    -- 原价
    self:setNumImgForPanel("OrgValuePanel", ART_FONT_COLOR.DEFAULT, data.orgPrice, false, LOCATE_POSITION.LEFT_TOP, 23)

    local youhui = data.orgPrice - data.price
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, youhui, false, LOCATE_POSITION.LEFT_TOP, 25, "EndPanel")

    -- 倒计时
  --  self:setLabelText("TimeLabel", "8秒")

    if data.isStart == 1 and not self.isOver then
        self:randomPos(data.type)
    end

    if data.lastCutPrice > 0 and self.lastBtn then
        local numPanel = self.numPanel:clone()
        self:setNumImgForPanel(numPanel, ART_FONT_COLOR.GREEN, -data.lastCutPrice, true, LOCATE_POSITION.MID, 30, "PricePanel")
        local panel = self:getControl(self.lastBtn.parentName)
        if self.lastBtn.kanjia == 0 then
            numPanel:setPosition(self.lastBtn.pos.x - numPanel:getContentSize().width * 0.5, self.lastBtn.pos.y + self.smallButton:getContentSize().height * 0.5)
        else
            numPanel:setPosition(self.lastBtn.pos.x - numPanel:getContentSize().width * 0.5, self.lastBtn.pos.y + self.bigButton:getContentSize().height * 0.5)
        end
        panel:addChild(numPanel)

        local move = cc.MoveBy:create(0.3, cc.p(0, 30))

        local removeAct = cc.CallFunc:create(function()
            numPanel:removeFromParent()
        end)

        numPanel:runAction(cc.Sequence:create(cc.Spawn:create(cc.FadeOut:create(0.3), move), removeAct))
    end

    -- 优化价格
    local youhui = data.orgPrice - data.price
    self:setNumImgForPanel("ValuePanel", ART_FONT_COLOR.DEFAULT, youhui, false, LOCATE_POSITION.LEFT_TOP, 25, "EndPanel")
end

function InnEventDlg:cleanup()
    -- 尝试关闭确认框
    DlgMgr:closeDlg("ConfirmDlg")
end

function InnEventDlg:onCloseButton(sender)
    if not self.data then DlgMgr:closeDlg(self.name) end

    if self.data.isStart == 1 then
       gf:CmdToServer("CMD_HEISHI_KANJIA_PAUSE", {})
        self.data.isStart = 0
        self.pauseStartTime = gfGetTickCount()
        gf:confirm(string.format(CHS[4010075], self.data.price), function()
            gf:CmdToServer("CMD_HEISHI_KANJIA_QUIT", {})
            self:gameOver()
        end, function()
            gf:CmdToServer("CMD_HEISHI_KANJIA_START", {})
            self.pauseAddTime = self.pauseAddTime + gfGetTickCount() - self.pauseStartTime
          --  gf:ShowSmallTips(self.pauseAddTime)
        end)
    else
        DlgMgr:closeDlg(self.name)
    end
end

return InnEventDlg
