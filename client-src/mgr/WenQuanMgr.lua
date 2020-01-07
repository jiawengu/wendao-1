-- WenQuanMgr.lua
-- Created by huangzz Jan/21/2019
-- 温泉管理器

local DefaultMapMagic = require("maps/magic/MapMagic")

WenQuanMgr = Singleton()

local THROW_SPEED = 600  -- 肥皂抛出速度 像素/s

local THROW_MAX_LENTH = 400 -- 肥皂抛出距离 像素

local FLAP_BACH_DIS = 40  -- 捶背距离
local FLAP_BACH_DIS_RANGE = {20, 60}  -- 可捶背范围

-- 肥皂抛出起始位置离角色角基准点的偏移值
local SOAP_OFFSET = {
    [1] = {-35, 25},
    [3] = {35, 25},
    [5] = {-35, 25},
    [7] = {35, 25},
}

function WenQuanMgr:init()
    self.smlzs = {}
    for _, v in pairs(DefaultMapMagic[CHS[5420361]]) do
        if string.match(v.remark, "smlz") then
            table.insert(self.smlzs, v)
        end

        if v.remark == "hululizi" then
            self.hululizi = v
        end

        if v.remark == "hulu" then
            self.hulu = v
        end
    end
end

function WenQuanMgr:setCanThrowSoap(flag)
    self.canThrowSoap = flag
end

function WenQuanMgr:isInThrowSoap()
    return self.canThrowSoap
end

function WenQuanMgr:mePlayThrowSoap(toPos, char)
    if self.isPlayAction then
        return
    end

    if Me.faAct == Const.FA_FLAPPING or Me.faAct == Const.FA_THROW_BEGIN or Me.faAct == Const.FA_THROW_END then
        return
    end

    toPos = gf:getCharTopLayer():convertToNodeSpace(toPos)
    local dis = gf:distance(Me.curX, Me.curY, toPos.x, toPos.y)
    if dis > THROW_MAX_LENTH then
        gf:ShowSmallTips(CHS[5450461])
        return
    end

    AutoWalkMgr:stopAutoWalk()
    Me:setAct(Const.FA_STAND)
    gf:frozenScreen(3000, 0, nil, true, -10)

    self.isPlayAction = true

    -- 容错
    gf:getCharTopLayer():stopAction(self.playDelay)
    self.playDelay = performWithDelay(gf:getCharTopLayer(), function()
        self.isPlayAction = false
    end, 4)

    DlgMgr:sendMsg("WenquanDlg", "setCtrlVisible", "TipsPanel", false)

    local mx, my = gf:convertToMapSpace(toPos.x, toPos.y)
    gf:CmdToServer("CMD_XCWQ_THROW_SOAP", {
        to_id = char and char:getId() or 0,
        to_x = mx,
        to_y = my,
        cookie = self:getCookie(),
    })
end

-- 扔肥皂
function WenQuanMgr:playThrowSoap(char, toPos, toChar)
    if char.faAct == Const.FA_THROW_BEGIN or char.faAct == Const.FA_THROW_END then
        return
    end

    local dir = gf:defineDirForPet(cc.p(char.curX, char.curY), toPos)
    char:setDir(dir)

    local toId = toChar and toChar:getId() or -1

    -- 扔肥皂开始动作
    char:setActAndCB(Const.FA_THROW_BEGIN, function()
        if char.faAct == Const.FA_THROW_BEGIN then
            -- 肥皂光效
            local magic = gf:createLoopMagic(ResMgr.magic.wenquan_throw_soap)
            magic:setPosition(char.curX + SOAP_OFFSET[dir][1], char.curY + SOAP_OFFSET[dir][2])
            gf:getCharTopLayer():addChild(magic)

            -- 肥皂抛物线效果
            local dis = gf:distance(char.curX, char.curY, toPos.x, toPos.y)
            local h = 50 * (dis / 400)
            local jump = cc.JumpTo:create(dis / THROW_SPEED, toPos, h, 1)

            magic:runAction(cc.Sequence:create(
                jump,
                cc.CallFunc:create(function()
                    toChar = CharMgr:getChar(toId)
                    if toChar and math.abs(toChar.curX - toPos.x) < 5 and math.abs(toChar.curY - toPos.y) < 5 then
                        -- 扔到人
                        -- 泡沫光效
                        CharMgr:MSG_PLAY_LIGHT_EFFECT({charId = toChar:getId(), effectIcon = ResMgr.magic.wenquan_throw_soap_crash})
                    
                        -- 播放受击动作
                        toChar:setActAndCB(Const.FA_DEFENSE, function()
                            if toChar.faAct == Const.FA_DEFENSE then
                                toChar:setAct(Const.FA_STAND)
                            end
                        end)
                    else
                        -- 未扔到人
                        -- 水花光效
                        local magic = gf:createSelfRemoveMagic(ResMgr.magic.swim_pos_effect, {blendMode = "add"})
                        magic:setPosition(toPos.x, toPos.y)
                        gf:getMapObjLayer():addChild(magic)
                    end
                end),
                cc.RemoveSelf:create()
            ))

            -- 扔肥皂结束动作
            char:setActAndCB(Const.FA_THROW_END, function()
                if char.faAct == Const.FA_THROW_END then
                    char:setAct(Const.FA_STAND)

                    if char:getId() == Me:getId() then
                        gf:unfrozenScreen()
                        self.isPlayAction = false
                    end
                end
            end)
        end
    end)
end

function WenQuanMgr:isInFlapBackRange(dis)
    return dis <= FLAP_BACH_DIS_RANGE[2] and dis >= FLAP_BACH_DIS_RANGE[1]
end

function WenQuanMgr:gotoPlayFlapBack()
    if self.isPlayAction then
        return
    end

    if Me.faAct == Const.FA_FLAPPING or Me.faAct == Const.FA_THROW_BEGIN or Me.faAct == Const.FA_THROW_END then
        return
    end

    -- 未选中
    local toChar = self.selectChar
    if not toChar then
        gf:ShowSmallTips(CHS[5450462])
        return
    end

    -- 正在被其它玩家捶背
    if self.playChars then
        for _, v in pairs(self.playChars) do
            if v.toId == toChar:getId() then
                gf:ShowSmallTips(CHS[5400807])
                return
            end
        end
    end

    -- 正在给人捶背或扔肥皂
    if toChar.faAct == Const.FA_FLAPPING or toChar.faAct == Const.FA_THROW_BEGIN or toChar.faAct == Const.FA_THROW_END then
        gf:ShowSmallTips(CHS[5400808])
        return
    end

    AutoWalkMgr:stopAutoWalk()

    -- 距离过远
    local dis = gf:distance(Me.curX, Me.curY, toChar.curX, toChar.curY)
    if not self:isInFlapBackRange(dis) then
        local pos = self:getClickCharToPos(toChar)
        pos = gf:getMapLayer():convertToNodeSpace(pos)
        local mx, my = gf:convertToMapSpace(pos.x, pos.y)
        Me:setEndPos(mx, my)

        self.needAutoPlayFlapBack = true
        return
    end

    self:mePlayFlapBack()
end

function WenQuanMgr:mePlayFlapBack()
    if self.isPlayAction then
        return
    end

    if Me.faAct == Const.FA_FLAPPING or Me.faAct == Const.FA_THROW_BEGIN or Me.faAct == Const.FA_THROW_END then
        return
    end

    -- 未选中
    local toChar = self.selectChar
    if not toChar then
        -- gf:ShowSmallTips(CHS[5450462])
        return
    end

    -- 正在被其它玩家捶背
    if self.playChars then
        for _, v in pairs(self.playChars) do
            if v.toId == toChar:getId() then
                -- gf:ShowSmallTips(CHS[5400807])
                return
            end
        end
    end

    -- 正在给人捶背或扔肥皂
    if toChar.faAct == Const.FA_FLAPPING or toChar.faAct == Const.FA_THROW_BEGIN or toChar.faAct == Const.FA_THROW_END then
        return
    end

    -- 距离过远
    local dis = gf:distance(Me.curX, Me.curY, toChar.curX, toChar.curY)
    if not self:isInFlapBackRange(dis) then
        -- gf:ShowSmallTips(CHS[5450461])
        return
    end

    gf:frozenScreen(3000, 0, nil, true, -10)

    self.isPlayAction = true

    -- 容错
    gf:getCharTopLayer():stopAction(self.playDelay)
    self.playDelay = performWithDelay(gf:getCharTopLayer(), function()
        self.isPlayAction = false
    end, 4)

    local mx, my = gf:convertToMapSpace(toChar.curX, toChar.curY)

    gf:CmdToServer("CMD_XCWQ_MASSAGE_BACK", {
        to_id = toChar and toChar:getId() or 0,
        to_x = mx,
        to_y = my,
        cookie = self:getCookie(),
    })

    -- 取消选中角色
    self:setSelectChar()
end

function WenQuanMgr:getCookie()
    self.curCookie = self.curCookie and self.curCookie + 1 or 1
    return self.curCookie
end

-- 点击角色时要寻路到可捶背的位置
function WenQuanMgr:getClickCharToPos(char)
    local dir = gf:defineDirForPet(cc.p(char.curX, char.curY), cc.p(Me.curX, Me.curY))

    local angle = (8 - dir - 4) % 8 * 45
    local curlen = FLAP_BACH_DIS
    local x = char.curX + curlen * math.cos(math.rad(angle))
    local y = char.curY + curlen * math.sin(math.rad(angle))

    -- 选中角色
    self:setSelectChar(char)

    return gf:getMapLayer():convertToWorldSpace(cc.p(x, y))
end

-- 捶背
function WenQuanMgr:playFlapBack(char, toChar)
    local dis = gf:distance(char.curX, char.curY, toChar.curX, toChar.curY)

    if toChar.faAct ~= Const.FA_STAND or not self:isInFlapBackRange(dis) then
        return
    end

    local dir = gf:defineDirForPet(cc.p(char.curX, char.curY), cc.p(toChar.curX, toChar.curY))

    char:setAct(Const.FA_STAND)
    char:setDir(dir)
    toChar:setDir(dir)

    if not self.playChars then self.playChars = {} end

    -- 保存信息，在 update 中检测被捶对象是否有
    self.playChars[char:getId()] = {toId = toChar:getId(), dir = toChar:getDir(), curX = toChar.curX, curY = toChar.curY}

    char:setActAndCB(Const.FA_FLAPPING, function()
        self:stopFlapBack(char)
    end)
end

function WenQuanMgr:stopFlapBack(char)
    char:setAct(Const.FA_STAND)
    self.playChars[char:getId()] = nil
    if char:getId() == Me:getId() then
        gf:unfrozenScreen()
        self.isPlayAction = false
    end
end

function WenQuanMgr:getSelectImg()
    if not self.selectImg then
        self.selectImg = cc.Sprite:create(ResMgr.ui.select_arrows)
        self.selectImg:setPosition(0, 70)
        self.selectImg:setFlipY(true)
        self.selectImg:retain()

        local action = cc.Sequence:create(
            cc.MoveBy:create(0.45, cc.p(0, 10)),
            cc.MoveBy:create(0.45, cc.p(0, -10))
        )

        self.selectImg:runAction(cc.RepeatForever:create(action))
    end

    return self.selectImg
end

function WenQuanMgr:setSelectChar(char)
    self.selectChar = char
    local selectImg = self:getSelectImg()
    selectImg:removeFromParent(false)
    if char then
        char:addToTopLayer(selectImg)
    end

    if not char then
        self.needAutoPlayFlapBack = false
    end
end

-- 温泉地图内的移动速度
function WenQuanMgr:getPlayerSpeed()
    return self.playerSpeed or 0.2
end

function WenQuanMgr:update()
    -- 点击捶背按钮，到达目的地时需自动捶背
    if self.needAutoPlayFlapBack and Me:isStandAction() then
        self:mePlayFlapBack()
        self.needAutoPlayFlapBack = false
    end

    -- 由于延时，可能受到捶背消息时，角色还未走到目的地
    if self.waitPlayChars then
        for id, toId in pairs(self.waitPlayChars) do
            local toChar = CharMgr:getChar(toId)
            local char = CharMgr:getChar(id)
            if not char or not toChar then
                self.waitPlayChars[id] = nil
            elseif char:isStandAction() then
                self:playFlapBack(char, toChar)
                self.waitPlayChars[id] = nil
            end
        end
    end

    -- 处理中途停止捶背的情况
    if self.playChars then
        for id, info in pairs(self.playChars) do
            local toChar = CharMgr:getChar(info.toId)
            local char = CharMgr:getChar(id)
            if not char or char.faAct ~= Const.FA_FLAPPING then
                self.playChars[id] = nil
            elseif not toChar then
                self:stopFlapBack(char)
            elseif toChar.curX ~= info.curX or toChar.curY ~= info.curY or info.dir ~= toChar:getDir() then
                self:stopFlapBack(char)
            end
        end
    end
end

function WenQuanMgr:MSG_ENTER_ROOM(map)
    if MapMgr:isInYuLuXianChi() then
        self.isInYuLuXianChi = true
        GameMgr:registFrameFunc(FRAME_FUNC_TAG.WENQUAN_UPDATE, self.update, self, true)

        self.useYLJH = nil
    elseif self.isInYuLuXianChi then
        DlgMgr:closeDlg("WenquanDlg")
        GuideMgr:refreshMainIcon()

        WenQuanMgr:clearData()
    end
end

-- 通知场景信息
function WenQuanMgr:MSG_XCWQ_DATA(data)
    DlgMgr:sendMsg("SystemFunctionDlg", "clearAllIcon")
    GuideMgr:refreshMainIcon()

    local dlg = DlgMgr:openDlg("WenquanDlg")
    dlg:setData(data)

    if data.water_temp < 30 then
        self.playerSpeed = 0.05
    elseif data.water_temp > 50 then
        self.playerSpeed = 0.15
    else
        self.playerSpeed = 0.1
    end

    self.wenquanData = data

    self:setMapMagic(not string.isNilOrEmpty(data.player_name))
end

function WenQuanMgr:setMapMagic(useYLJH)
    if self.useYLJH == useYLJH then
        return
    end

    self.useYLJH = useYLJH
    if self.smlzs then
        for i = 1, #self.smlzs do
            self.smlzs[i].notShowMagic = not useYLJH
        end
    end

    if self.hulu then
        self.hulu.notShowMagic = useYLJH
    end

    if self.hululizi then
        self.hululizi.notShowMagic = not useYLJH
    end

    if MapMgr:getCurrentMapName() == CHS[5420361] then
        MapMagicMgr:setMagicByRemark(nil, {reload = true, notReloadMap = true})
    end
end

-- 广播丢肥皂动作
function WenQuanMgr:MSG_XCWQ_THROW_SOAP(data)
    local char = CharMgr:getChar(data.from_id)
    local toChar = CharMgr:getChar(data.to_id)
    local x, y = gf:convertToClientSpace(data.to_x, data.to_y)
    local pos = cc.p(x, y)
    if toChar then
        pos.x = toChar.curX
        pos.y = toChar.curY
    end

    if not char then
        return
    end

    self:playThrowSoap(char, pos, toChar) 
end

-- 广播捶背动作
function WenQuanMgr:MSG_XCWQ_MASSAGE_BACK(data)
    local char = CharMgr:getChar(data.from_id)
    local toChar = CharMgr:getChar(data.to_id)
    if not toChar or not char then
        return
    end

    if char:isWalkAction() then
        if not self.waitPlayChars then self.waitPlayChars = {} end

        self.waitPlayChars[char:getId()] = toChar:getId()
        return
    end

    self:playFlapBack(char, toChar)
end

function WenQuanMgr:MSG_XCWQ_ACTION_FAIL(data)
    if self.curCookie == data.cookie then
        gf:unfrozenScreen()
        self.isPlayAction = false
    end
end

function WenQuanMgr:MSG_XCWQ_RECORD(data)
    self.gameRecord = data
end

function WenQuanMgr:MSG_XCWQ_ONE_RECORD(data)
    if not self.gameRecord then return end
    if data.from_name == Me:getName() then
        table.insert(self.gameRecord.att_info, {type = data.type, player_name = data.to_name, player_gid = data.to_gid})

        if #self.gameRecord.att_info > 60 then
            table.remove(self.gameRecord.att_info, 1)
        end
    else
        table.insert(self.gameRecord.def_info, {type = data.type, player_name = data.from_name, player_gid = data.from_gid})

        if #self.gameRecord.def_info > 60 then
            table.remove(self.gameRecord.def_info, 1)
        end
    end
end

function WenQuanMgr:MSG_XCWQ_OPEN_YLJH_DLG(data)
    DlgMgr:openDlgEx("WenquanjhDlg", {coin = data.coin, player = self.wenquanData.player_gid})
end

function WenQuanMgr:MSG_USE_YLJH(data)
    DlgMgr:sendMsg("WenquanDlg", "playUseYLJHAction", data.name)
    
    PlayActionsMgr:MSG_ANIMATE_IN_UI({
        id = 0,
        effect_no = 01471,
        order = 0,
        locate = 0,
        loops = 1,
        interval = 0,
        during = 0
    })
end

function WenQuanMgr:clearData()
    self.curCookie = nil
    self.gameRecord = nil
    self:setSelectChar()
    self.playChars = nil
    self.isPlayAction = nil
    self.canThrowSoap = nil
    self.wenquanData = nil

    if self.selectImg then
        self.selectImg:cleanup()
        self.selectImg:release()
        self.selectImg = nil
    end

    GameMgr:unRegistFrameFunc(FRAME_FUNC_TAG.WENQUAN_UPDATE)
end


WenQuanMgr:init()

MessageMgr:hook("MSG_ENTER_ROOM", WenQuanMgr, "WenQuanMgr")
MessageMgr:regist("MSG_XCWQ_DATA", WenQuanMgr)
MessageMgr:regist("MSG_XCWQ_THROW_SOAP", WenQuanMgr)
MessageMgr:regist("MSG_XCWQ_MASSAGE_BACK", WenQuanMgr)
MessageMgr:regist("MSG_XCWQ_ACTION_FAIL", WenQuanMgr)
MessageMgr:regist("MSG_XCWQ_RECORD", WenQuanMgr)
MessageMgr:regist("MSG_XCWQ_ONE_RECORD", WenQuanMgr)
MessageMgr:regist("MSG_XCWQ_OPEN_YLJH_DLG", WenQuanMgr)
MessageMgr:regist("MSG_USE_YLJH", WenQuanMgr)