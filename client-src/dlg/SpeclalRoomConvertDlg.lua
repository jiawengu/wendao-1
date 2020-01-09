-- SpeclalRoomConvertDlg.lua
-- Created by songcw Dec/2018/21
-- 通天塔-神秘房间-变身舞会

local SpeclalRoomConvertDlg = Singleton("SpeclalRoomConvertDlg", Dialog)

-- 随机变幻的 icon 池
local CHANGE_ICON_POOL = {
  --  6259, 31060, 51524, 51502, 6257, 6205, 6313
    6259, 31060, 51524, 6257, 6205, 6313
}

function SpeclalRoomConvertDlg:init(data)
    self:setFullScreen()
    self:bindListener("StopButton", self.onStopButton)

    self.isStop = {}
    self.isSendCmd = false
    self.isStart = false

    -- 隐藏界面、角色
    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })

    -- 初始化变身舞会NPC
    TttSmfjMgr:initBswhNpc()

    if data and data.end_time > gf:getServerTime() then
        gf:startCountDowm(data.end_time, "start", function ( )
        end)
    end

    self:hookMsg("MSG_SMFJ_BSWH_PLAYER_ICON")
end

function SpeclalRoomConvertDlg:cleanup()
    TttSmfjMgr:clearBswhNpc()

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    Me:setVisible(true)

    gf:closeCountDown()

    self.root:stopAllActions()
end

function SpeclalRoomConvertDlg:onStopButton(sender, eventType)
    if not self.isStart then return end
    if self.isSendCmd then return end


    local char = TttSmfjMgr:getBswhNpcById(Me:getId())
    local icon = char:queryBasicInt("icon")

    local key = gfEncrypt(TttSmfjMgr:getEncrypt(icon), tostring(Me:getId()))
    gf:CmdToServer("CMD_SMFJ_BSWH_PLAYER_ICON", {str = key})
    self.isSendCmd = true
    self.isStop[Me:getId()] = true
end

function SpeclalRoomConvertDlg:changeIcon(char)
    if self.isStop[char:queryBasicInt("id")] then return end

    local iconPool = gf:deepCopy(CHANGE_ICON_POOL)
    for i, icon in pairs(iconPool) do
        if icon == char:queryBasicInt("icon") then
            table.remove( iconPool, i)
        end
    end

    local icon = iconPool[math.random(1, #iconPool)]
    char:setBasic("icon", icon)
    char.charAction:setIcon(icon)
    char:setAct(Const.FA_STAND)


    local delayTime = math.random(60, 90) * 0.01
    performWithDelay(self.root, function ()
        self:changeIcon(char)
    end, delayTime)
end

function SpeclalRoomConvertDlg:start()
    local members = TttSmfjMgr.bswhNpc
    for cId, v in pairs(members) do
        if cId ~= 1 then
            self:changeIcon(v)
        end
    end
end

function SpeclalRoomConvertDlg:MSG_SMFJ_BSWH_PLAYER_ICON(data)
    local char = TttSmfjMgr:getBswhNpcById(data.id)
    if not char then return end

    self.isStop[data.id] = true

    local icon = data.icon
    char:setBasic("icon", icon)
    char.charAction:setIcon(icon)
    char:setAct(Const.FA_STAND)
end


function SpeclalRoomConvertDlg:MSG_SMFJ_GAME_STATE(data)
    if data.status == 2 then
        self.isStart = true
        gf:startCountDowm(data.end_time, "end")
        local char = TttSmfjMgr:getBswhNpcById(1)
        if char then
            char:setChat({msg = CHS[4010307], show_time = 3}, nil, true)

        end
        self:start()
    elseif data.status == 3 then
        performWithDelay(self.root, function ()
            -- body
            self:onCloseButton()
        end, 2)
    end
end


return SpeclalRoomConvertDlg
