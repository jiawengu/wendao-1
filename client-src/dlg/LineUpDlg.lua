-- LineUpDlg.lua
-- Created by zhengjh Dec/28/2015
-- 登录排队界面

local LineUpDlg = Singleton("LineUpDlg", Dialog)

local REQUEST_TYPE = {
    COMMUNITY,
    CHANGECHANNEL
}

function LineUpDlg:init()
    self:bindListener("ChangeChannelButton", self.onChangeChannelButton)
    self:bindListener("CommunityButton", self.onCommunityButton)

    self:setCtrlVisible("ChangeChannelButton", true)
    self:setCtrlVisible("CommunityButton", true)
    self:setCtrlVisible("BKPanel_1", true)
    self:setCtrlVisible("BKPanel_2", false)

    self.curData = nil

    self.lastDistName = nil

    self:hookMsg("MSG_AAA_CONNECTED")
    self:hookMsg("MSG_L_LINE_DATA")
end

function LineUpDlg:isConnectAAA()
end

-- 刷新排队数据
function LineUpDlg:refreshInfo(data)
    self:setLabelText("DistNameLabel", Client:getWantLoginDistName())

    local waitStr
    if data.indsider_lv == -1 then
        waitStr = CHS[5400663]
    elseif -1 == data.need_wait or -2 == data.need_wait then
        -- 等待分配线路 -1 正在处理中  -2 插队玩家
        waitStr = CHS[5000292]
    else
        waitStr = data.line_name .. CHS[7000078] .. string.format(CHS[3002905], data.waitCode)
    end

    self:setLabelText("ChannelLabel", waitStr)

    if self.curData and self.curData.indsider_lv ~= data.indsider_lv then
        -- 购买会员成功，关闭界面
        DlgMgr:closeDlg("LineUpChangeChannelDlg")
    end

    if self.curData and self.curData.gold_coin ~= data.gold_coin then
        if self.curData.gold_coin and self.curData.indsider_lv >= 0 and data.gold_coin  and self.curData.gold_coin < data.gold_coin then
            -- 元宝增加，成功购买元宝
            gf:ShowSmallTips(string.format(CHS[5400682], data.gold_coin - self.curData.gold_coin))
        end

        DlgMgr:closeDlg("LineUpOnlineRechargeDlg")
    end

    local next_req_time = data.reconnet_time or 0
    local expect_time =  data.expect_time or 0
    self.keep_alive = data.keep_alive or 0
    self.curData = data
    local function update()
        if next_req_time <= 0 then
            self:requestLoginWaitInfo()
            next_req_time = math.max(10, data.reconnet_time)
        end

        next_req_time = next_req_time - 1
        Log:D(">>>>>>>>>>>>>>>>>>>> next_req_time" .. tostring(next_req_time))
        
        if data.indsider_lv and data.indsider_lv >= 0 
                and not (data.status == 2 and (data.waitCode <= 5 or -1 == data.need_wait or -2 == data.need_wait))
                and not (data.status == 1 and data.indsider_lv == 0 and data.waitCode <= 5) then
            expect_time = expect_time - 1
            self:setTimeStr(expect_time)
        end
    end

    self.root:stopAllActions()
    schedule(self.root, update, 1)

    update()

    if not data.indsider_lv or data.indsider_lv == -1 then
        self:setLabelText("WaitTimeLabel", CHS[5410274])
    elseif data.status == 2 and (data.waitCode <= 5 or -1 == data.need_wait or -2 == data.need_wait) then
        -- 服务器已满，前 5 名或插队玩家
        self:setLabelText("WaitTimeLabel", CHS[5410278])
    elseif data.status == 1 and data.indsider_lv == 0 and data.waitCode <= 5 then
        -- 服务器爆满，普通队列
        self:setLabelText("WaitTimeLabel", CHS[5410279])
    end

    DlgMgr:sendMsg("LineUpChangeChannelDlg", "updateGoldCoin", data.gold_coin)

    -- 提示
    if data.notRealLine then
        -- 尚未参与真实排队
        self:setLabelText("Label", CHS[5400664], "NotePanel")
    elseif data.indsider_lv == -1 then
        -- 获取账号信息期间
        self:setLabelText("Label", CHS[5400665], "NotePanel")
    elseif data.status == 2 then
        -- 当前服务器人数已满
        self:setLabelText("Label", CHS[5400666], "NotePanel")
	elseif (-1 == data.need_wait or -2 == data.need_wait) and data.status == 1 and data.indsider_lv == 0 then
        -- 处于充值中断队列，自身非会员，所有线路已爆满
        self:setLabelText("Label", CHS[5400667], "NotePanel")
    elseif data.expect_time < 3 * 60 then
        -- 当前排队时间在3分钟以内
        self:setLabelText("Label", CHS[5400668], "NotePanel")
    else
        -- 当前排队时间在3分钟以上且当前区组已开放微社区
        self:setLabelText("Label", CHS[5400669], "NotePanel")
    end

    if self.lastDistName ~= Client:getWantLoginDistName() then
        CommunityMgr:setCommunityURL()
        self:checkCanRequest(function()
            gf:CmdToAAAServer("CMD_L_GET_COMMUNITY_ADDRESS", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
        end)

        self.lastDistName = Client:getWantLoginDistName() 
    end
end

function LineUpDlg:requestLoginWaitInfo()
    if 1 ~= self.curData.keep_alive or not CommThread:isConnectAAA() then
        -- 没有保持连接，需要重新连接
        if DlgMgr:getDlgByName("LoginChangeDistDlg") then
            DistMgr:connetAAA(Client:getWantLoginDistName(), true, false)
        else
            DistMgr:connetAAA(Client:getWantLoginDistName(), true, true)
        end
    else
        -- 保持连接直接请求线路信息
        Client:requestLoginWaitInfo()
    end
end

-- 显示预计时间
function LineUpDlg:setTimeStr(time)
    -- 排队时间
    local waitTimeStr = ""
    local totalSencods = time

    if totalSencods < 60 then
        waitTimeStr = CHS[3002907]
    else
        local hours = math.floor(totalSencods / 3600)
        local minute = math.floor((totalSencods % 3600) / 60)
        if hours > 0 then
            waitTimeStr = waitTimeStr .. string.format(CHS[4100093], hours)
        end

        waitTimeStr = waitTimeStr .. string.format(CHS[5400655], minute)
    end

    self:setLabelText("WaitTimeLabel", waitTimeStr)
end

function LineUpDlg:checkCanRequest(callback)
    -- if self:isConnectAAA() then
        -- 没有保持连接，需要重新连接
        self.callback = callback
        DlgMgr:closeDlg("WaitDlg")
        local aaa =DistMgr:getDistInfoByName(Client:getWantLoginDistName())["aaa"]
        Client:connetAAA(aaa, nil, nil, CONNECT_TYPE.LINE_UP)
    --[[else
        callback()
    end]]
end

function LineUpDlg:onCommunityButton(sender, eventType)
    if not CommunityMgr:getCommunityURL() then
        gf:ShowSmallTips(CHS[5410319])
        return
    end

    CommunityMgr:setLastAcesss(nil, 0)
    DlgMgr:openDlgEx("CommunityDlg", {"visitor=yes"})
end

function LineUpDlg:onChangeChannelButton(sender, eventType)
    if not self.curData then return end
    -- 若当前尚未获取到账号权限，给与弹出提示
    if not self.curData.indsider_lv or self.curData.indsider_lv < 0 then
        gf:ShowSmallTips(CHS[5400672])
        return
    end

    -- 若玩家账号的权限为年卡，给与弹出提示
    if self.curData.indsider_lv >= 3 then
        gf:ShowSmallTips(CHS[5400671])
        return
    end

    self:checkCanRequest(function()
        gf:CmdToAAAServer("CMD_L_LINE_DATA", {account = Client:getAccount()}, CONNECT_TYPE.LINE_UP)
    end)
end

function LineUpDlg:onCloseButton(sender, eventType)
    -- 退出排队
    Client:cancelWaitLine()

    DlgMgr:closeDlg(self.name)
end

function LineUpDlg:cleanup()
    self.lableText = nil
    self.timeText = nil

    DlgMgr:closeDlg("LineUpChangeChannelDlg")
end

function LineUpDlg:MSG_AAA_CONNECTED(map)
    if map.result and map.connect_type == CONNECT_TYPE.LINE_UP then -- 连上aaa
        if self.callback then
            self.callback()
            self.callback = nil
        end
    end
end

function LineUpDlg:MSG_L_LINE_DATA(map)
    table.remove(map, 1) -- 第一个为普通通道信息，不需要
    local dlg = DlgMgr:openDlg("LineUpChangeChannelDlg")
    dlg:setData(map, self.curData)
    dlg:updateGoldCoin(self.curData.gold_coin)
end

return LineUpDlg
