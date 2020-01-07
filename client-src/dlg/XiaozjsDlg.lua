-- XiaozjsDlg.lua
-- Created by huangzz Feb/02/2019
-- 小舟竞赛主界面

local XiaozjsDlg = Singleton("XiaozjsDlg", Dialog)

local STATUS = {
    WAIT = 1,
    START = 2,
    END = 3
}

local TOTAL_DIS = 3600

local DEF_SPEED = 20

local AUTO_DIS = 250

local SMALL_DIS = 220

local GUIDE_SPACE = 52

function XiaozjsDlg:init()
    self:setFullScreen()

    self:setCtrlFullClient("FullPanel")
    self:setCtrlFullClient("RBlackPanel")

    self:bindListener("HideButton", self.onHideButton)
    self:bindListener("UpButton", self.onUpButton)
    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:bindListener("lowerButton", self.onlowerButton)

    self.dirImg = self:retainCtrl("Image_1", "GuidePanel")

    local fullPanel = self:getControl("FullPanel")
    self.winSize = fullPanel:getContentSize()
    self.shipSize = self:getControl("ShipPanel_1"):getContentSize()

    self.guideAns = nil

    self.runState = nil

    self:createRiverWay()

    self:setCtrlVisible("AutoGuidePanel", false)
    local numImg = self:createCountDown(10, "CountDownPanel")
    numImg:setScale(0.3, 0.3)

    self:hookMsg("MSG_SUMMER_2019_XZJS_FRAME")
    self:hookMsg("MSG_SUMMER_2019_XZJS_DATA")
    self:hookMsg("MSG_SUMMER_2019_XZJS_OPERATE")
    self:hookMsg("MSG_SUMMER_2019_XZJS_RESULT")
end

-- 创建倒计时
function XiaozjsDlg:createCountDown(time, ctrlName)
    self:setCtrlVisible(ctrlName, false)
    return Dialog.createCountDown(self, time, ctrlName)
end

function XiaozjsDlg:startCountDown(time, ctrlName)
    self:setCtrlVisible(ctrlName, true)
    local numImg = Dialog.startCountDown(self, time, ctrlName, nil, function(numImg)
        -- self:setCtrlVisible(ctrlName, false)
    end)
end

function XiaozjsDlg:createRiverWay()
    local totalWidth = 0
    local panel = self:getControl("MapPanel")

    --河道左边缘
    local size = panel:getContentSize()
    local sprite = cc.Sprite:create(ResMgr.ui.xiaozjs_riverway_start)
    sprite:setAnchorPoint(0, 0.5)
    sprite:setPosition(0, size.height / 2)
    panel:addChild(sprite)

    local size1 = sprite:getContentSize()
    totalWidth = totalWidth + size1.width

    -- 中间河道
    for i = 1, 3 do
        local sprite = cc.Sprite:create(ResMgr.ui.xiaozjs_riverway_mid)
        local size2 = sprite:getContentSize()
        sprite:setAnchorPoint(0, 0.5)
        sprite:setPosition(totalWidth, size.height / 2)
        panel:addChild(sprite)

        totalWidth = totalWidth + size2.width
    end

    -- 河道右边缘
    local sprite = cc.Sprite:create(ResMgr.ui.xiaozjs_riverway_end)
    sprite:setAnchorPoint(0, 0.5)
    sprite:setPosition(totalWidth, size.height / 2)
    panel:addChild(sprite)

    local size3 = sprite:getContentSize()
    totalWidth = totalWidth + size3.width

    self.totalWidth = totalWidth

    -- 画起点线
    local sprite = cc.Sprite:create(ResMgr.ui.xiaozjs_riverway_line)
    sprite:setPosition((self.totalWidth - TOTAL_DIS) / 2, size.height / 2)
    panel:addChild(sprite)

    -- 画终点线
    local sprite = cc.Sprite:create(ResMgr.ui.xiaozjs_riverway_line)
    sprite:setPosition(self.totalWidth / 2 + TOTAL_DIS / 2, size.height / 2)
    panel:addChild(sprite)

    self.startPosX = math.floor((self.totalWidth - TOTAL_DIS) / 2)

    -- 初始化起跑点
    for i = 1, 3 do
        ship = self:getControl("ShipPanel_" .. i)
        ship:setTag(i)
        ship:setAnchorPoint(1, 0)

        self:setShipPos(0, ship)
    end
end

-- 设置船的位置
function XiaozjsDlg:setShipPos(x, ship)
    ship.realX = x + self.startPosX

    -- 设置船的位置
    ship:setPositionX(x + self.startPosX)

    local tag = ship:getTag()

    -- 设置右上角旗子位置
    local startX = 21
    local img = self:getControl("FlagImage_" .. tag)
    local fx = math.floor(x * SMALL_DIS / TOTAL_DIS)
    img:setPositionX(fx + 21)

    -- 设置底图位置
    if tag == 3 then
        local panel = self:getControl("MapPanel")
        local midX = Const.WINSIZE.width / Const.UI_SCALE / 2
        local mapX = math.max(math.min(0, midX - (x + self.startPosX - self.shipSize.width / 2)), Const.WINSIZE.width / Const.UI_SCALE - self.totalWidth)
        panel:setPositionX(mapX)
    end
end

-- 获取船当前的位置
function XiaozjsDlg:getShipPos(ship)
    if not ship then return 0 end
    return (ship.realX or ship:getPositionX()) - self.startPosX
end

-- 刷新耗时
function XiaozjsDlg:updateTime(hasTime)
    local m = math.floor(hasTime / 60)
    local s = hasTime % 60
    self:setLabelText("TimeLabel_2", string.format(CHS[5450469], m, s))
end

function XiaozjsDlg:updateShipsPos(dt)
    -- 刷新船的位置
    if self.runState == STATUS.WAIT then
        return
    end

    if not self.curFrame then return end

    local curTime = gfGetTickCount()
    for no = 1, 3 do
        local panel = self.ships[no]
        local info = self.curFrame.frame_info[no]
        local curX = self:getShipPos(panel)
        if info and curX < info.to_distance and curX < TOTAL_DIS + AUTO_DIS then
            if self.curFrame.endTime <= curTime then
                curX = info.to_distance
            else
                local speed = (info.to_distance - curX) / (self.curFrame.endTime - curTime) * 1000
                curX = speed * dt + curX
            end

            self:setShipPos(curX, panel)

            self.notMoveCount[no] = 0
        elseif self.clientDis and self.clientDis[no] then
            -- 处理客户端自己造的距离
            local info = self.clientDis[no]
            if curX < info.to_distance and info.endTime > curTime then
                local speed = (info.to_distance - curX) / (info.endTime - curTime) * 1000
                local x = speed * dt + curX
                self:setShipPos(x, panel)
            else
                if curX < info.to_distance then
                    self:setShipPos(info.to_distance, panel)
                end

                self.clientDis[no] = nil
            end

            -- 播未加速光效
            local img = self:getControl("ShipImage", nil, panel)
            self:removeMagic(img, ResMgr.magic.xiaozjs_speedup_wave)
            self:addMagic(img, ResMgr.magic.xiaozjs_def_wave, {extraPara = {blendMode = "add"}})

            self.notMoveCount[no] = 0
        else
            if not self.notMoveCount[no] then self.notMoveCount[no] = 0 end

            self.notMoveCount[no] = self.notMoveCount[no] + 1
            if self.notMoveCount[no] > 5 then
                -- 停住了，移除光效
                local img = self:getControl("ShipImage", nil, panel)
                self:removeMagic(img, ResMgr.magic.xiaozjs_def_wave)
                self:removeMagic(img, ResMgr.magic.xiaozjs_speedup_wave)
            end
        end
    end
end

function XiaozjsDlg:onUpdate(dt)
    -- 刷新船的位置
    self:updateShipsPos(dt)
end

function XiaozjsDlg:doGuideFadeOut()
    local panel = self:getControl("GuidePanel")
    for i = 1, #self.guideAns do
        local cell = panel:getChildByTag(i)
        cell:runAction(cc.Spawn:create(
                            cc.DelayTime:create(0.2),
                            cc.ScaleTo:create(0.1, 1.8),
                            cc.FadeOut:create(0.1)
                        ))
    end
end

-- 检查输入指令是否正确，并通知服务端
function XiaozjsDlg:checkDir(dir, sender)
    if self.runState == STATUS.WAIT then
        gf:ShowSmallTips(CHS[5410329])
        return
    end

    if not self.guideAns then return end

    local hasChange = false
    for i = 1, #self.guideAns do
        if self.guideAns[i] == 0 then
            local panel = self:getControl("GuidePanel")
            local cell = panel:getChildByTag(i)
            if self.guideData[i].dir == dir then
                cell:loadTexture(ResMgr.ui.xiaozjs_dir_flag_right)
                self.guideAns[i] = 1
            else
                cell:loadTexture(ResMgr.ui.xiaozjs_dir_flag_err)
                self.guideAns[i] = 2
            end

            hasChange = true
            if i == 6 then
                self:doGuideFadeOut()
            end
            break
        end
    end

    if hasChange then
        gf:CmdToServer("CMD_SUMMER_2019_XZJS_OPERATE", self.guideAns)

        -- 点击按钮光效
        self:removeMagic(sender, ResMgr.magic.xiaozjs_click_btn)
        self:addMagic(sender, ResMgr.magic.xiaozjs_click_btn, {isOnce = true, extraPara = {blendMode = "add"}})
    end
end

function XiaozjsDlg:onUpButton(sender, eventType)
    self:checkDir(1, sender)
end

function XiaozjsDlg:onLeftButton(sender, eventType)
    self:checkDir(4, sender)
end

function XiaozjsDlg:onRightButton(sender, eventType)
    self:checkDir(2, sender)
end

function XiaozjsDlg:onlowerButton(sender, eventType)
    self:checkDir(3, sender)
end

function XiaozjsDlg:onCloseButton(sender, eventType)
    if self.runState == STATUS.WAIT then
        gf:confirm(CHS[5410330], function()
            gf:CmdToServer("CMD_SUMMER_2019_XZJS_QUIT_GAME", {})
        end)
    else
        gf:confirm(CHS[5400799], function()
            gf:CmdToServer("CMD_SUMMER_2019_XZJS_QUIT_GAME", {})
        end)
    end
end

function XiaozjsDlg:onHideButton(sender, eventType)
    self:setCtrlVisible("RulePanel", false)
end

function XiaozjsDlg:cleanup()
    DlgMgr:closeDlg("XiaozjsjlDlg")
end

-- 通知游戏数据
function XiaozjsDlg:MSG_SUMMER_2019_XZJS_DATA(data)
    DlgMgr:closeDlg("XiaozjsgzDlg")

    local time = math.min(20, math.max(data.start_time - gf:getServerTime(), 0))
    local numImg = self:createCountDown(time, "NumPanel")
    numImg:setScale(0.6, 0.6)
    self:startCountDown(time, "NumPanel")

    self:setCtrlVisible("RulePanel", true)
    self:setCtrlVisible("StartPanel", true)

    self.basicData = data
    self.runState = STATUS.WAIT   -- 赛跑状态 1 倒计时 2 开跑 0 结束或未开始
    self.frameQueue = {}
    self.curFrame = nil           -- 
    self.clientDis = nil
    self.ships = {}

    self.notMoveCount = {}
    
    self.hasReceiveFrameCou = 0  -- 标记收到第几条帧数据
    
    self.lastFrameTotalTime = nil  -- 存储执行到上一帧要花费的时间

    self.notUpdateTime = false

    local index = 1
    for i = 1, 3 do
        local v = data.ship_info[i]
        if v and v.name == Me:getShowName() then
            self:setShipInfo(3, v, COLOR3.GREEN, i)
            self.myNo = i
        else
            self:setShipInfo(index, v, COLOR3.WHITE, i)
            index = index + 1
        end
    end
end

-- 显示单个小船
function XiaozjsDlg:setShipInfo(index, data, color3, no)
    local panel = self:getControl("ShipPanel_" .. index)
    if data then
        self:setImage("HeadImage", ResMgr:getSmallPortrait(data.icon), panel)

        self:setLabelText("NameLabel", data.name, panel, color3)

        local size = self:getControl("NameLabel", nil, panel):getContentSize()
        local bkImg = self:getControl("NameBkImage", nil, panel)
        -- bkImg:setContentSize(math.max(size.width + 8, 130), bkImg:getContentSize().height)

        panel:setVisible(true)
    else
        panel:setVisible(false)
    end

    self.ships[no] = panel
end


function XiaozjsDlg:stopRunGame()
    self.runState = STATUS.END  -- 标记比赛结束
end

-- 通知游戏帧数据
function XiaozjsDlg:MSG_SUMMER_2019_XZJS_FRAME(data)
    if not self.runState then
        -- 游戏未开始，异常收到的帧数据直接丢弃
        return
    end

    -- 处理船提前退出的船
    if self.runState ~= STATUS.END or not self.ships[self.myNo] or self.ships[self.myNo].isArrive then
        -- 自己的船没到终点提前退出，其它玩家提前退出时不移除
        for i = 1, 3 do
            if not data.frame_info[i] then
                if self.ships[i] and not self.ships[i].isArrive then
                    -- 已到达终点的船不移除
                    self.ships[i]:setVisible(false)
                end
            elseif data.frame_info[i].to_distance >= TOTAL_DIS then
                if self.ships[i] then
                    self.ships[i].isArrive = true
                end
            end
        end
    end

    if data.seq == 0 then
        return
    end

    self.hasReceiveFrameCou = self.hasReceiveFrameCou + 1

    table.insert(self.frameQueue, data)
    if self.hasReceiveFrameCou == 1 then
        -- 初始化起跑点
        for no, v in pairs(data.frame_info) do
            local panel = self.ships[no]
            self:setShipPos(v.from_distance, panel)
        end

        self:setCtrlVisible("RulePanel", false)
        self:setCtrlVisible("StartPanel", false)
    elseif self.hasReceiveFrameCou == 3 then
        self.runState = STATUS.START
    end

    if self.hasReceiveFrameCou > 3 then
        -- 修复位置
        for no, v in pairs(self.frameQueue[1].frame_info) do
            local panel = self.ships[no]
            local x = self:getShipPos(panel)
            if panel and v.from_distance > x and x < TOTAL_DIS then
                self:setShipPos(v.from_distance, panel)
            end
        end
 
        table.remove(self.frameQueue, 1)
    end

    self.curFrame = data
    self.curFrame.endTime = gfGetTickCount() + 200 * 2 + data.frame_interval

    if self.runState ~= STATUS.WAIT then
        for no, v in pairs(data.frame_info) do
            -- 播放水波光效
            local panel = self.ships[no]
            local img = self:getControl("ShipImage", nil, panel)
            if self:getShipPos(panel) < TOTAL_DIS + AUTO_DIS then
                if v.effect_type == 1 then
                    -- 播加速光效
                    self:removeMagic(img, ResMgr.magic.xiaozjs_def_wave)
                    self:addMagic(img, ResMgr.magic.xiaozjs_speedup_wave, {extraPara = {blendMode = "add"}})
                else
                    -- 播未加速光效
                    self:removeMagic(img, ResMgr.magic.xiaozjs_speedup_wave)
                    self:addMagic(img, ResMgr.magic.xiaozjs_def_wave, {extraPara = {blendMode = "add"}})
                end
            end

            -- 处理到达终点时要再走一段距离
            if v.to_distance >= TOTAL_DIS then
                if not self.clientDis then self.clientDis = {} end
                if v.to_distance < TOTAL_DIS + AUTO_DIS then
                    self.clientDis[no] = {}
                    self.clientDis[no].to_distance = TOTAL_DIS + AUTO_DIS
                    self.clientDis[no].endTime = data.endTime + (TOTAL_DIS + AUTO_DIS - v.to_distance) / DEF_SPEED * 1000
                else
                    self.clientDis[no] = nil
                end
            end
        end
    end

    if not self.notUpdateTime then
        self:updateTime(data.has_time)
    end

    if data.frame_info[self.myNo] and data.frame_info[self.myNo].to_distance >= TOTAL_DIS then
        self.notUpdateTime = true
    end
end

function XiaozjsDlg:MSG_SUMMER_2019_XZJS_OPERATE(data)
    self.guideAns = {}
    self.guideAns.no = data.no
    
    if self.notUpdateTime then
        return
    end

    -- 创建指令
    local panel = self:getControl("GuidePanel")
    panel:removeAllChildren()
    local size = panel:getContentSize()
    local startX = size.width / 2 - (data.count - 1) / 2 * GUIDE_SPACE
    for i = 1, data.count do
        local cell = self.dirImg:clone()
        cell:setTag(i)
        cell:setPositionX(startX + (i - 1) * GUIDE_SPACE)
        cell:setRotation((data[i].dir - 1) * 90)
        if data[i].status == 1 then
            cell:loadTexture(ResMgr.ui.xiaozjs_dir_flag_right)
        elseif data[i].status == 2 then
            cell:loadTexture(ResMgr.ui.xiaozjs_dir_flag_err)
        else
            cell:loadTexture(ResMgr.ui.xiaozjs_dir_flag_def)
        end

        table.insert(self.guideAns, data[i].status)
        panel:addChild(cell)
    end

    self.guideData = data

    -- 输入指令倒计时
    self:startCountDown(data.left_time, "CountDownPanel")

    self:setLabelText("Label_2", string.format(CHS[5410103], data.total_time), "InforPanel_1")

    self:setCtrlVisible("GuidePanel", true, "AutoGuidePanel")
    self:setCtrlVisible("AutoGuidePanel", true)
end

function XiaozjsDlg:MSG_SUMMER_2019_XZJS_RESULT(data)
    if data.rank == 0 then
        DlgMgr:closeDlg("XiaozjsDlg")
        return
    end

    local dlg = DlgMgr:openDlg("XiaozjsjlDlg")
    dlg:setData(data)

    self:updateTime(data.has_time)
    self.notUpdateTime = true

    self.runState = STATUS.END

    self:setCtrlVisible("AutoGuidePanel", false)
end

return XiaozjsDlg
