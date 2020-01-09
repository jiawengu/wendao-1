-- SifqjDlg.lua
-- Created by songcw June/20/2018
-- 四方旗局

local SifqjDlg = Singleton("SifqjDlg", Dialog)

-- 棋子类型
local CHESS_TYPE = {
    NONE = 0,   -- 没有棋子
    WHITE = 1,   --
    BLACK = 2,  --
}

-- 棋子走向
local CHESS_DIR = {
    UP       = 2,       -- x 从大到小
    DOWN     = 1,       -- x 从小到大
    LEFT     = 3,       -- y 从大到小
    RIGHT    = 4,       -- y 从小到大
}

local CHESS_SIZE = 4

--------------------------------------------------------------------
--------------------------------------------------------------------
----------------    请看我 ------------------------------------------
--      服务器棋盘格式                         客户端棋子json编号
--[[
        x3  2   2   2   2                     13     14     15     16
        x2  0   0   0   0                     9      10     11     12
        x1  0   0   0   0                     5      6      7      8
        x0  1   1   1   1                     1      2      3      4
            y0  y1  y2  y3
--]]
----------------------------------------------------------------------
-----------------------------------------------------------------------

local CUR_CHESS = "curChess"

local MAX_TIME = 60 * 1000  -- 倒计时时间

local NORMAL_TIPS = {
    CHS[4200555],
    CHS[4200556],
    CHS[4200557],
    CHS[4200558],
    CHS[4200559],
    CHS[4200560],
}

function SifqjDlg:init(data)
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel")
    self:setCtrlFullClientEx("BackPanel", "ResultPanel")

    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("CloseImage", self.onCloseImage)
    self:bindListener("AgainImage", self.onAgainImage)
    self:bindListener("ExitImage", self.onExitImage)
    self:bindListener("ChatButton", self.onChatButton)

    self.selectChess = nil  -- 当前选择的棋子
    self.isCanDo = false    -- 当前是否可以走
    self.isActioning = false
    self.startTime = nil
    self.lastSendTime = nil

    self:setCtrlVisible("SelectContentPanel", false)

    self:setCtrlVisible("OtherSpeechPanel", false)
    self:setCtrlVisible("SelfSpeechPanel", false)

    self:bindFloatingEvent("SelectContentPanel")

    for i = 1, 16 do
        local panel = self:getControl("QiziPanel" .. i)
        panel:setTag(i)
        self:bindTouchEndEventListener(panel, self.onSelectChess)

        -- 快速说话
        local tipsPanel = self:getControl("Panel_" .. i)
        if tipsPanel then
            tipsPanel:setTag(i)
            self:bindTouchEndEventListener(tipsPanel, self.onSelectTips)

            self:setColorText(BrowMgr:addGenderSign(NORMAL_TIPS[i], Me:queryBasicInt("gender")), tipsPanel, nil, nil, nil, COLOR3.WHITE, 22, true)
        end
    end

    self:addMagic("SelfMagicPanel", ResMgr:getMagicDownIcon())
    self:addMagic("OtherMagicPanel", ResMgr:getMagicDownIcon())

    self:displayStart(data)

    self:hookMsg("MSG_NATIONAL_2018_SFQJ")
    self:hookMsg("MSG_MESSAGE_EX")
end

function SifqjDlg:setTopTips(tips)
    self:setColorText(tips, "TextPanel", nil, nil, nil, COLOR3.WHITE, 22, true)

    self:setLabelText("Label", "", "TitlePanel")
end

-- tag转换为服务器的坐标
function SifqjDlg:changeServerKey(tag)

    local myInfo = self:getMyCorps()
    if myInfo.corps == CHESS_TYPE.BLACK then
        tag = 16 - tag + 1
    end

    local x = math.floor( (tag - 1) / 4 )
    local y = (tag - 1) % 4
    return x, y
end

-- 根据点击的格子获得移动方向
function SifqjDlg:getDir(sender)
    if not self.selectChess then return end
    local dir = sender:getTag() - self.selectChess:getTag()
    local myInfo = self:getMyCorps()
    if myInfo.corps == CHESS_TYPE.BLACK then
        -- 我是黑子的话，需要转换下
        if dir == 1 then
            -- 向右
            return CHESS_DIR.LEFT
        elseif dir == -1 then
            -- 向左
            return CHESS_DIR.RIGHT
        elseif dir == 4 then
            -- 向上
            return CHESS_DIR.DOWN
        elseif dir == -4 then
            -- 向下
            return CHESS_DIR.UP
        end
    else
        if dir == 1 then
            -- 向右
            return CHESS_DIR.RIGHT
        elseif dir == -1 then
            -- 向左
            return CHESS_DIR.LEFT
        elseif dir == 4 then
            -- 向上
            return CHESS_DIR.UP
        elseif dir == -4 then
            -- 向下
            return CHESS_DIR.DOWN
        end
    end

    return 0
end

function SifqjDlg:cmdMoveChess(sender)
    if not self.selectChess then return end
    local x, y = self:changeServerKey(self.selectChess:getTag())
    local dir = self:getDir(sender)
    gf:CmdToServer("CMD_NATIONAL_2018_SFQJ_MOVE", {
        x = x, y = y, dir = dir
    })

    self.lastSendTime = self.data.move_end_time
    self.isCanDo = false
    self.selectChess = nil
    self.isActioning = true
end

-- 移动棋子效果
function SifqjDlg:moveChess(sender, isNoSenderCmd)
    if not self.selectChess then return end
    if sender.isMoving then return end
    sender.isMoving = true

    self.isActioning = true


    -- 获取移动的起始位置
    local boardPanel = self:getControl("QiZPanel")
    local x, y = self.selectChess:getPosition()
    x = x + self.selectChess:getContentSize().width * 0.5
    y = y + self.selectChess:getContentSize().height * 0.5

    -- 获取对应移动棋子图片
    local path
    local myInfo, otherInfo = self:getCampInfo(self.data)
    if isNoSenderCmd then
        path = self.data.drive_corps == CHESS_TYPE.WHITE and ResMgr.ui.sfqj_white_chess or ResMgr.ui.sfqj_black_chess
    else
        path = myInfo.corps == CHESS_TYPE.WHITE and ResMgr.ui.sfqj_white_chess or ResMgr.ui.sfqj_black_chess
    end

    -- add

    local sp = boardPanel:getChildByName(CUR_CHESS)
    if sp then
        sp:stopAllActions()
        sp:removeFromParent()
    end

    sp = ccui.ImageView:create(path)
    sp:setPosition(cc.p(x, y))
    sp:setName(CUR_CHESS)

    boardPanel:addChild(sp)

    -- 计算要移动的位置
    local dx = 0
    local dy = 0
    local dir = self:getDir(sender)

    if myInfo.corps == CHESS_TYPE.BLACK then
        -- 我是黑子的话，需要转换下
        if dir == CHESS_DIR.RIGHT then
            -- 向右
            dx = dx - self.selectChess:getContentSize().width
        elseif dir == CHESS_DIR.LEFT then
            -- 向左
            dx = dx + self.selectChess:getContentSize().width
        elseif dir == CHESS_DIR.UP then
            -- 向上
            dy = dy - self.selectChess:getContentSize().height
        elseif dir == CHESS_DIR.DOWN then
            -- 向下
            dy = dy + self.selectChess:getContentSize().height
        end
    else
        if dir == CHESS_DIR.RIGHT then
            -- 向右
            dx = dx + self.selectChess:getContentSize().width
        elseif dir == CHESS_DIR.LEFT then
            -- 向左
            dx = dx - self.selectChess:getContentSize().width
        elseif dir == CHESS_DIR.UP then
            -- 向上
            dy = dy + self.selectChess:getContentSize().height
        elseif dir == CHESS_DIR.DOWN then
            -- 向下
            dy = dy - self.selectChess:getContentSize().height
        end
    end

    -- 将旧棋子设置为非举起状态
    self:setUnitChessStage(CHESS_TYPE.NONE, self.selectChess)


    local curChess = sender

    if isNoSenderCmd then
        self.selectChess = nil
    end

    -- 移动的动作
    local action1 = cc.MoveBy:create(0.2, cc.p(dx, dy))

    -- 回调
    local data = self.data
    local callBackAct = cc.CallFunc:create(function()
        -- 删除移动棋子

        local sp = boardPanel:getChildByName(CUR_CHESS)
        if sp then
            sp:removeFromParent()
        end

        -- 发送移动消息
        self:cmdMoveChess(sender)

        -- 先把目标棋子设置上
        local myInfo, otherInfo = self:getCampInfo(data)
        if isNoSenderCmd then
            -- 不需要发送消息的，是对方的阵营
            self:setUnitChessStage(data.drive_corps, curChess)

        else
            -- 我移动棋子
            self:setUnitChessStage(myInfo.corps, curChess)
        end

        sender.isMoving = false

        self.isActioning = false
    end)

    local seq = cc.Sequence:create(action1, cc.DelayTime:create(0.2), callBackAct)
    sp:runAction(seq)
end

function SifqjDlg:setTime(ti)
    local clr = COLOR3.RED
    if ti > 10 and ti <= 40 then
        clr = COLOR3.YELLOW
    elseif ti > 40 then
        clr = COLOR3.GREEN
    end

    self:setLabelText("Label_1", ti, "TimePanel", clr)
    local unit = self:getControl("Label_2", nil, "TimePanel")
    unit:setColor(clr)
end

function SifqjDlg:onUpdate()
    if not self.data or self.data.is_pvp ~= 1 then return end   -- 没有数据、pve不更新

    if self.data.start_time <= 0 then return end

    if not self.startTime then return end                       -- 没有时间不更新
    if self:getCtrlVisible("ResultPanel") then return end       -- 结束了不更新

    -- 没有这个判断会出现 -0
    if gfGetTickCount() > self.startTime then
        self.startTime = gfGetTickCount()
    end

    local disTime = math.ceil((self.startTime - gfGetTickCount()) / 1000 )
    disTime = math.min(disTime, 60)
    disTime = math.max(disTime, 0)

    self:setTime(disTime)

    if disTime <= 0 then
        self.startTime = nil
    end


    local myInfo = self:getMyCorps()
    if disTime <= 0 and self.data.move_corps == myInfo.corps then
        self.startTime = nil

        if self.isActioning then
            -- 如果在主动落子动画过程中，不发送消息等移动结束了自己会发
        else
            gf:CmdToServer("CMD_NATIONAL_2018_SFQJ_MOVE", {
                x = 0, y = 0, dir = 0
            })
        end
    end
end

-- 检测是否合法的步
function SifqjDlg:isValidStep(sender)
    if not self.selectChess then return end
    if sender.stage ~= CHESS_TYPE.NONE then return end

    local destStepTag = sender:getTag()
    local last = self.selectChess:getTag()
    if math.abs(destStepTag - last) == 1 or math.abs(destStepTag - last) == 4 then
        return true
    end

    return
end

-- 将所有棋子置为非拿状态
function SifqjDlg:resetAllChess()
    for i = 1, 16 do
        local sender = self:getControl("QiziPanel" .. i)
        local stage = sender.stage

        if stage == CHESS_TYPE.WHITE then
            -- 我的棋子
            self:setCtrlVisible("Image_1", true, sender)
            self:setCtrlVisible("Image_2", false, sender)

            self:setCtrlVisible("Image_3", false, sender)
            self:setCtrlVisible("Image_4", false, sender)
        elseif stage == CHESS_TYPE.BLACK then
            -- 对方的棋子
            self:setCtrlVisible("Image_1", false, sender)
            self:setCtrlVisible("Image_2", false, sender)

            self:setCtrlVisible("Image_3", true, sender)
            self:setCtrlVisible("Image_4", false, sender)
        else
            -- 没有棋子
            self:setCtrlVisible("Image_1", false, sender)
            self:setCtrlVisible("Image_2", false, sender)

            self:setCtrlVisible("Image_3", false, sender)
            self:setCtrlVisible("Image_4", false, sender)
        end
    end
end

function SifqjDlg:onSelectTips(sender, eventType)

    local data = {}
    data.channel = CHAT_CHANNEL.TEAM
    data.compress = 0
    data.msg = BrowMgr:addGenderSign(NORMAL_TIPS[sender:getTag()], Me:queryBasicInt("gender"))

    ChatMgr:sendMessage(data)

    self:setCtrlVisible("SelectContentPanel", false)

end


function SifqjDlg:onSelectChess(sender, eventType)
    -- 播放动画过程，直接返回
    if self.isActioning or self.isOtherActioning then return end

    -- 移动棋子
    if self.selectChess and self.selectChess.isMoving then return end


    -- 将所有棋子置为非拿状态
    self:resetAllChess()
    local myInfo, otherInfo = self:getCampInfo(self.data)

    if sender.stage ~= myInfo.corps and sender.stage ~= CHESS_TYPE.NONE then
        local myCorpsStr = myInfo.corps == 1 and CHS[4010158] or CHS[4010159]
        local otherCorpsStr = myCorpsStr == CHS[4010158] and CHS[4010159] or CHS[4010158]
        gf:ShowSmallTips(string.format(CHS[4010160], myCorpsStr, otherCorpsStr))
        return
    end

    -- 当前由#Y%s#n落子。
    if not self.isCanDo and sender.stage ~= CHESS_TYPE.NONE then
        gf:ShowSmallTips(string.format(CHS[4010161], otherInfo.name))
        return
    end

    if not self.isCanDo then
        -- 该情况可能动画未播放完

        return
    end

    if self.data.is_pvp == 1 and self.lastSendTime == self.data.move_end_time then

        return
    end

    -- 是否已经举起棋子了
    if self.selectChess then
        if self:isValidStep(sender) then
            --self:moveChess(sender)  -- 先移动棋子，在发送消息
            -- 发送移动消息
            self:cmdMoveChess(sender)

        else
            self.selectChess = nil  -- 若 self:isValidStep(sender) == true 需要在延迟动画结束后才设置为 nil
        end
        return
    end

    -- 拿起该棋子

    self.selectChess = sender
    self:takeOffChess(sender)
end

function SifqjDlg:getCampInfo(data)
    local myInfo, otherInfo

    for _, info in pairs(data.corps_info) do
        if info.gid == Me:queryBasic("gid") then
            myInfo = info
        else
            otherInfo = info
        end
    end

    return myInfo, otherInfo
end

function SifqjDlg:creatCharDragonBones(icon, panelName, root)
    local panel = self:getControl(panelName, nil, root)
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
    if root ~= "OtherPanel" then
        magic:setRotationSkewY(180)
    end
    magic:setScale(0.8)

    -- 不调用 DragonBonesMgr:toPlay()接口，来满足使用第一帧的需求
    --  DragonBonesMgr:toPlay(dbMagic, "stand", 0)
    return magic
end

-- 设置阵营
function SifqjDlg:setCamp(data)

    local myInfo, otherInfo = self:getCampInfo(data)

    local function setShape(info, panelName)
        -- body
        local panel = self:getControl(panelName)
        self:setLabelText("NameLabel_1", info.name, panel)
        self:setLabelText("NameLabel_2", info.name, panel)
        local iconPath = ResMgr:getBigPortrait(info.icon)
      --  self:setImage("ShapeImage", iconPath, panel)
        self:creatCharDragonBones(info.icon, "ShapePanel", panelName)

        if info.corps == 1 then
            self:setImage("Image", ResMgr.ui.sfqj_white_flag, panel)
        else
            self:setImage("Image", ResMgr.ui.sfqj_black_flag, panel)
        end

        local image = self:getControl("ShapeImage", nil, panel)
        if info.is_leave == 1 then
            gf:grayImageView(image)
        else
            gf:resetImageView(image)
        end
    end

    -- 我
    setShape(myInfo, "SelfPanel")

    -- 对方
    setShape(otherInfo, "OtherPanel")
end

-- 开始时界面
function SifqjDlg:displayStart(data)
    if not data then return end

    self:setCtrlVisible("ResultPanel", false)

    for i = 1, 16 do
        self:setUnitChessStage(CHESS_TYPE.NONE, self:getControl("QiziPanel" .. i))
    end

    if data.is_pvp == 1 then
        if TeamMgr:getLeaderId() == Me:getId() then
            self:setCtrlVisible("StartButton", true)
            self:setCtrlVisible("WaitImage", false)
        else
            self:setCtrlVisible("StartButton", false)
            self:setCtrlVisible("WaitImage", true)
        end

        self:setTopTips(CHS[4101151])   -- 落子时间为60秒
    else
        self:setCtrlVisible("StartButton", true)
        self:setCtrlVisible("WaitImage", false)

        self:setTopTips(CHS[4010146])   -- 落子没有时间限制
    end

    self:setCtrlVisible("TimePanel", data.is_pvp == 1)

    self:setCtrlVisible("SelfMagicPanel", false)
    self:setCtrlVisible("OtherMagicPanel", false)
end

-- 重置棋盘
function SifqjDlg:resetBoard()
    -- 我的棋子
    for i = 1, 4 do
        self:setUnitChessStage(CHESS_TYPE.WHITE, self:getControl("QiziPanel".. i))
    end

    -- 中间没有的
    for i = 5, 12 do
        self:setUnitChessStage(CHESS_TYPE.NONE, self:getControl("QiziPanel" .. i))
    end

    -- 对方
    for i = 13, 16 do
        self:setUnitChessStage(CHESS_TYPE.BLACK, self:getControl("QiziPanel" .. i))
    end
end

-- 设置棋子阵营
function SifqjDlg:setUnitChessStage(stage, panel)
    if stage == CHESS_TYPE.WHITE then
        -- 我的棋子
        self:setCtrlVisible("Image_1", true, panel)
        self:setCtrlVisible("Image_2", false, panel)

        self:setCtrlVisible("Image_3", false, panel)
        self:setCtrlVisible("Image_4", false, panel)
    elseif stage == CHESS_TYPE.BLACK then
        -- 对方的棋子
        self:setCtrlVisible("Image_1", false, panel)
        self:setCtrlVisible("Image_2", false, panel)

        self:setCtrlVisible("Image_3", true, panel)
        self:setCtrlVisible("Image_4", false, panel)
    else
        -- 没有棋子
        self:setCtrlVisible("Image_1", false, panel)
        self:setCtrlVisible("Image_2", false, panel)

        self:setCtrlVisible("Image_3", false, panel)
        self:setCtrlVisible("Image_4", false, panel)
    end

    panel.stage = stage
end

-- 设置棋谱信息
-- info 为数组
function SifqjDlg:setChessInfo(data, isOnlySet)

--      服务器棋盘格式                         客户端棋子json编号
--[[
        x3  2   2   2   2                     13     14     15     16
        x2  0   0   0   0                     9      10     11     12
        x1  0   0   0   0                     5      6      7      8
        x0  1   1   1   1                     1      2      3      4
            y0  y1  y2  y3
--]]
    -- 将服务器数据转化下
    local ret = {}
    local info = data.chessData
    for x = 1, CHESS_SIZE do
        for y = 1, CHESS_SIZE do
            table.insert(ret, info[x][y])
        end
    end

    local myInfo = self:getMyCorps()

    local moveRet = false
    -- 如果有移动棋子，检测下是不是对方下子，是的话，要有落子动作！！！烦
	-- 体验后版本增加了倒计时，所以所有动画都放在服务器消息来了在播放！所以，if 1 then
    --if (data.drive_corps > 0 and data.drive_corps ~= myInfo.corps) or data.is_auto == 1 then
    if 1 then
        local x = data.drive_x
        local y = data.drive_y
        local key = x * 4 + y + 1


        if data.drive_dir == CHESS_DIR.UP then
            moveRet = key + 4
        elseif data.drive_dir == CHESS_DIR.DOWN then
            moveRet = key - 4
        elseif data.drive_dir == CHESS_DIR.LEFT then
            moveRet = key - 1
        elseif data.drive_dir == CHESS_DIR.RIGHT then
            moveRet = key + 1
        end

        --
        if isOnlySet then
            -- 只设置棋盘不需要修改值
        else
            ret[moveRet] = 0
            for i = 1, data.eat_count do
                local ex, ey = data.eatData[i].eat_x, data.eatData[i].eat_y
                local temp = ex * 4 + ey + 1
                ret[temp] = data.eatData[i].eat_corps
            end
        end
    end

    if myInfo.corps == CHESS_TYPE.BLACK then
        -- 设置棋子
        local key = 0
        for i = 16, 1, -1 do
            key = key + 1
            self:setUnitChessStage(ret[key], self:getControl("QiziPanel" .. i))
        end
    else
        -- 设置棋子
        local key = 0
        for i = 1, 16 do
            key = key + 1
            self:setUnitChessStage(ret[key], self:getControl("QiziPanel" .. i))
        end
    end

    -- 如果只是设置，不需要动画，返回
    if isOnlySet then return end

    if moveRet then
        -- 对方移动需要播放动画
        self.isOtherActioning = true

        local key = data.drive_x * 4 + data.drive_y + 1
        if myInfo.corps == CHESS_TYPE.BLACK then
            key = 16 - key + 1
            moveRet = 16 - moveRet + 1
        end
        local sender = self:getControl("QiziPanel" .. key)
        sender.stage = data.drive_corps

        self.selectChess = sender

        self:takeOffChess(sender)

        local retChess = self:getControl("QiziPanel" .. moveRet)
        self:moveChess(retChess, true)

        performWithDelay(sender, function ( )
           -- 设置吃子效果
            self:setEatChessEffect(data)
        end, 0.7)

    else
        -- 设置吃子效果
        self:setEatChessEffect(data)
    end
end

-- 设置落子提示，界面上方，头像上方
function SifqjDlg:setLuoZiInfo(data)
    local myInfo, otherInfo = self:getCampInfo(data)

    -- 正常 myInfo 不会为nil，容错下
    if not myInfo then return end

    -- 顶部
    local info = self:getCurPlayerByCorps(data.move_corps)
    if info then
        self:setTopTips(string.format(CHS[4010147], self:getCurPlayerByCorps(data.move_corps).name))
    else
        self:setTopTips("")
    end

    if self:getCtrlVisible("ResultPanel") then
        self:setCtrlVisible("SelfMagicPanel", false)
        self:setCtrlVisible("OtherMagicPanel", false)
    else
        self:setCtrlVisible("SelfMagicPanel", data.move_corps == myInfo.corps)
        self:setCtrlVisible("OtherMagicPanel", data.move_corps ~= myInfo.corps)
    end

    if data.move_corps == 0 then
        self:setCtrlVisible("SelfMagicPanel", false)
        self:setCtrlVisible("OtherMagicPanel", false)
    end

    if data.is_pvp == 1 then
        self.startTime = gfGetTickCount() + MAX_TIME

        -- 时间做些容错，防止切后台等行为
        if gf:getServerTime() + MAX_TIME / 1000 >= data.move_end_time then

            self.startTime = (data.move_end_time - gf:getServerTime() - 2) * 1000 + gfGetTickCount()  -- 减2因为，服务器同错时间5秒，表现好一点，减2秒，还有3秒动画时间差不多
        end
    end
end

function SifqjDlg:onNoteButton(sender, eventType)
    DlgMgr:openDlg("SifqjRuleDlg")
end

function SifqjDlg:onStartButton(sender, eventType)
    gf:CmdToServer("CMD_NATIONAL_2018_SFQJ", {
        op_type = "start",
    })
end

function SifqjDlg:onAgainImage(sender, eventType)
    if not self.data then return end
    local myInfo, otherInfo = self:getCampInfo(self.data)

    gf:CmdToServer("CMD_NATIONAL_2018_SFQJ", {
        op_type = "reset",
    })

    if otherInfo.is_leave == 1 then
        DlgMgr:closeDlg(self.name)
    end
end

function SifqjDlg:onExitImage(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

function SifqjDlg:onChatButton(sender, eventType)
    self:setCtrlVisible("SelectContentPanel", true)
end

function SifqjDlg:cleanup()
    gf:CmdToServer("CMD_NATIONAL_2018_SFQJ", {
        op_type = "quit",
    })

    local function cleanDragon(panelName)
        -- body
        -- 如果有骨骼动画时，释放相关资源
        local panel = self:getControl("ShapePanel", nil, "OtherPanel")
        if panel then
            local magic = panel:getChildByName("charPortrait")

            if magic then
                DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
            end
        end
    end

    cleanDragon("OtherPanel")
    cleanDragon("SelfPanel")
end

function SifqjDlg:onCloseButton(sender, eventType)
    local tips = CHS[4010148]

    if self.data and self.data.is_pvp == 1 and self.data.start_time > 0 and self.data.win_corps <= 0 then
        tips = CHS[4101150]
    end

    gf:confirm(tips, function ()
        -- body
        DlgMgr:closeDlg(self.name)
    end)
end


-- 获取我的阵营信息
function SifqjDlg:getMyCorps()
    for i = 1, 2 do
        if self.data.corps_info[i].gid == Me:queryBasic("gid") then
            return self.data.corps_info[i]
        end
    end
end

-- 获取当前落子方
function SifqjDlg:getCurPlayerByCorps(corps)
    for i = 1, 2 do
        if corps == i then
            return self.data.corps_info[i]
        end
    end
end

-- 显示字符串
function SifqjDlg:setColorText(str, panelName, root, marginX, marginY, defColor, fontSize, inCenter, isPunct)

    marginX = marginX or 0
    marginY = marginY or 0
    root = root or self.root
    fontSize = fontSize or 20
    defColor = defColor or COLOR3.TEXT_DEFAULT

    local panel
    if type(panelName) == "string" then
        panel = self:getControl(panelName, Const.UIPanel, root)
    else
        panel = panelName
    end

    panel:removeAllChildren()

    local size = panel:getContentSize()
    local textCtrl = CGAColorTextList:create()
    textCtrl:setFontSize(fontSize)
    textCtrl:setString(str)
    textCtrl:setContentSize(size.width - 2 * marginX, 0)
    textCtrl:setDefaultColor(defColor.r, defColor.g, defColor.b)
    if textCtrl.setPunctTypesetting then
        textCtrl:setPunctTypesetting(true == isPunct)
    end
    textCtrl:updateNow()

    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()

    if inCenter then
        textCtrl:setPosition((size.width - textW) / 2,(size.height + textH) * 0.5 )
    else
        textCtrl:setPosition(marginX, textH + marginY)
    end

    local textNode = tolua.cast(textCtrl, "cc.LayerColor")
    panel:addChild(textNode, textNode:getLocalZOrder(), Dialog.TAG_COLORTEXT_CTRL)

end

function SifqjDlg:getUseTime(ti)
    local h = math.floor( ti / 3600 )
    local hStr = h == 0 and "" or string.format( CHS[4100093], h)

    local m = math.floor( ti % 3600 / 60 )
    local mStr = m == 0 and "" or string.format( CHS[4010041], m)

    local s = ti % 60
    local sStr = s == 0 and "" or string.format( CHS[4200423], s)

    return hStr .. mStr .. sStr
end

function SifqjDlg:onCloseImage(sender, eventType)
    self:setCtrlVisible("ResultPanel", false)
    if not self.data then return end
    if self.data.is_pvp == 1 then
        self:setTopTips(CHS[4101151])   -- 落子时间为60秒
        self.startTime = nil
        self:setTime(60)
        local myInfo, otherInfo = self:getCampInfo(self.data)
        if otherInfo.is_leave == 1 then
            DlgMgr:closeDlg(self.name)
        else
            gf:CmdToServer("CMD_NATIONAL_2018_SFQJ", {
                op_type = "reset",
            })

            if TeamMgr:getLeaderId() ~= Me:getId() then
                self:setCtrlVisible("WaitImage", true)
                for i = 1, 16 do
                    self:setUnitChessStage(CHESS_TYPE.NONE, self:getControl("QiziPanel" .. i))
                end
            end
        end
    else
        DlgMgr:closeDlg(self.name)
    end
end

function SifqjDlg:takeOffChess(sender)
    local stage = sender.stage
    if stage == CHESS_TYPE.WHITE then
        -- 我的棋子
        self:setCtrlVisible("Image_1", false, sender)
        self:setCtrlVisible("Image_2", true, sender)

        self:setCtrlVisible("Image_3", false, sender)
        self:setCtrlVisible("Image_4", false, sender)
    elseif stage == CHESS_TYPE.BLACK then
        -- 对方的棋子
        self:setCtrlVisible("Image_1", false, sender)
        self:setCtrlVisible("Image_2", false, sender)

        self:setCtrlVisible("Image_3", false, sender)
        self:setCtrlVisible("Image_4", true, sender)
    else
        -- 没有棋子
        self:setCtrlVisible("Image_1", false, sender)
        self:setCtrlVisible("Image_2", false, sender)

        self:setCtrlVisible("Image_3", false, sender)
        self:setCtrlVisible("Image_4", false, sender)
        self.selectChess = nil
    end
end

function SifqjDlg:setEatChessEffect(data)
    if data.eat_count <= 0 then
        self.isActioning = false
        self.isOtherActioning = false
        self:setLuoZiInfo(data)
        return
    end
    for i = 1, data.eat_count do
        local key = data.eatData[i].eat_x * 4 + data.eatData[i].eat_y + 1

        local myInfo = self:getMyCorps()
        if myInfo.corps == CHESS_TYPE.BLACK then
            key = 16 - key + 1
        end

        local panel = self:getControl("QiziPanel" .. key)

        self:setUnitChessStage(0, panel)
        local sp = data.eatData[i].eat_corps == 1 and "Image_1" or "Image_3"
        local blink = cc.Blink:create(1.2, 2)
        local ctrl = self:getControl(sp, nil, panel)

        -- 回调
        local callBackAct = cc.CallFunc:create(function()
            self.isActioning = false
            self.isOtherActioning = false
            self:setLuoZiInfo(data)
        end)

        ctrl:runAction(cc.Sequence:create(blink, callBackAct))
        --ctrl:runAction(cc.Sequence:create(blink), callBackAct)
    end
end

function SifqjDlg:setResult(data)
    self.startTime = nil
    self:setCtrlVisible("ResultPanel", true)
    local info = self:getCurPlayerByCorps(data.win_corps)
    self:setCtrlVisible("ExitImage", false, "ResultPanel")
    self:setCtrlVisible("AgainImage", false, "ResultPanel")
    self:setCtrlVisible("CloseImage", false, "ResultPanel")

    self:setCtrlVisible("SelfMagicPanel", false)
    self:setCtrlVisible("OtherMagicPanel", false)

    if info.gid == Me:queryBasic("gid") then
        -- 我赢
        self:setCtrlVisible("Image_3_1", true, "ResultPanel")
        self:setCtrlVisible("Image_3_2", false, "ResultPanel")
        self:setCtrlVisible("Image_4", true, "ResultPanel")

        if data.is_pvp == 1 then
            if TeamMgr:getLeaderId() == Me:getId() then
                self:setCtrlVisible("ExitImage", true, "ResultPanel")
                self:setCtrlVisible("AgainImage", true, "ResultPanel")
            else
                self:setCtrlVisible("CloseImage", true, "ResultPanel")
            end
        else
            self:setCtrlVisible("CloseImage", true, "ResultPanel")
        end

    else
        -- 我输
        self:setCtrlVisible("Image_3_1", false, "ResultPanel")
        self:setCtrlVisible("Image_3_2", true, "ResultPanel")
        self:setCtrlVisible("Image_4", false, "ResultPanel")

        if data.is_pvp == 1 then
            if TeamMgr:getLeaderId() == Me:getId() then
                self:setCtrlVisible("ExitImage", true, "ResultPanel")
                self:setCtrlVisible("AgainImage", true, "ResultPanel")
            else
                self:setCtrlVisible("CloseImage", true, "ResultPanel")
            end
        else
            self:setCtrlVisible("ExitImage", true, "ResultPanel")
            self:setCtrlVisible("AgainImage", true, "ResultPanel")
        end
    end


    local ti = data.end_time - data.start_time
  --  local timePanel = self:getControl("TaoPanel", nil, scorePanel)
    self:setLabelText("NumLabel", string.format(CHS[4010149], self:getUseTime(ti)), "UseTimePanel")
    local itemPanel = self:getControl("ItemPanel", nil, scorePanel)
    local myInfo = self:getMyCorps()
    self:setLabelText("NumLabel", string.format(CHS[4010150], myInfo.moves), "StepPanel")
end


-- 获取当前落子方
function SifqjDlg:MSG_NATIONAL_2018_SFQJ(data)
    self:stopAllChessAction()
    if self.data and data.move_corps > 0 then
        -- 如果有堆积的消息，直接设置界面

        self:setChessInfo(self.data, true)
    end

    self.data = data
    self.isCanDo = false
    self.selectChess = false
    self.startTime = nil

    self:setCtrlVisible("ChatButton", data.is_pvp == 1)

    self:setCamp(data)

    if data.start_time <= 0 then
        -- 开始游戏界面
        self:displayStart(data)
    else
        self:setCtrlVisible("StartButton", false)
        self:setCtrlVisible("WaitImage", false)

        self:setChessInfo(data)
        -- 根据是否出胜负显示界面
        if data.win_corps > 0 then

            -- 出胜负了
            if data.eat_count <= 0 then
                self:setResult(data)
            else
                -- 延迟是为了动画播放完
                performWithDelay(self.root, function ()
                    self:setResult(data)
                end, 2)
            end
        else
            -- 还没有胜负
            if self:getCurPlayerByCorps(data.move_corps).name == Me:queryBasic("name") then
                self.isCanDo = true
            end
        end
    end
end

function SifqjDlg:stopAllChessAction()
    for i = 1, 16 do
        local panel = self:getControl("QiziPanel" .. i)
        local sp1 = self:getControl("Image_1", nil, panel)
        local sp3 = self:getControl("Image_3", nil, panel)

        self:setUnitChessStage(CHESS_TYPE.NONE, panel)
        panel.isMoving = false

        sp1:stopAllActions()
        sp3:stopAllActions()

        sp1:setVisible(false)
        sp3:setVisible(false)
        panel:stopAllActions()
    end

    self.root:stopAllActions()
    local boardPanel = self:getControl("QiZPanel")
    local sp = boardPanel:getChildByName(CUR_CHESS)
    if sp then
        sp:stopAllActions()
        sp:removeFromParent()
    end
end

function SifqjDlg:MSG_MESSAGE_EX(data)
    if data["channel"] ~= CHAT_CHANNEL.TEAM then
        -- 只有当前频道和队伍频道才弹冒泡
        return
    end
    if not self.data then return end
    local myInfo, otherInfo = self:getCampInfo(self.data)
    if myInfo.gid == data.gid then
        self:setColorText(data.msg, "InfoPanel", "SelfSpeechPanel", nil, nil, COLOR3.TEXT_DEFAULT, 22, true)
        local panel = self:getControl("SelfSpeechPanel")
        panel:setVisible(true)
        panel:stopAllActions()
        performWithDelay(panel, function ( )
            -- body
            panel:setVisible(false)
        end, 5)
    elseif otherInfo.gid == data.gid then
        self:setColorText(data.msg, "InfoPanel", "OtherSpeechPanel", nil, nil, COLOR3.TEXT_DEFAULT, 22, true)
        local panel = self:getControl("OtherSpeechPanel")
        panel:setVisible(true)
        panel:stopAllActions()
        performWithDelay(panel, function ( )
            -- body
            panel:setVisible(false)
        end, 5)
    end
end

return SifqjDlg
