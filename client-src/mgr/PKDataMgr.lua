-- PKDataMgr.lua
-- Created by sujl, Sept/23/2016
-- PK数据

PKDataMgr = Singleton()

PKDataMgr.allData = {}

function PKDataMgr:clearData()
    self.allData = {}
end

function PKDataMgr:getDataByType(type, start, count)
    if not self.allData or not self.allData[type] then return {} end

    local allDatas = self.allData[type]
    if start and count then
        local datas = {}
        for i = start, math.min(start + count - 1, #allDatas) do
            table.insert(datas, allDatas[i])
        end

        return datas
    else
        return self.allData[type]
    end
end

function PKDataMgr:clearDataByType(type)
    if not type then return end
    self.allData[type] = nil
end

function PKDataMgr:requestPkInfo(type, para1, para2)
    if not type then return end

    self.allData[type] = nil
    gf:CmdToServer('CMD_REQUEST_PK_INFO', {
        ["type"] = type,
        ["para1"] = para1,
        ["para2"] = para2
    })
end

function PKDataMgr:MSG_PK_RECORD(data)
    local list = self.allData[data.type] or {}

    for _, v in ipairs(data.list) do
        table.insert(list, v)
    end

    table.sort(list, function(l, r)
        return l.update_time > r.update_time
    end)

    self.allData[data.type] = list
end

function PKDataMgr:MSG_RECORD_INFO(data)
    for _, v in pairs(self.allData) do
        for _, v in pairs(v) do
            if v and data.list[v.gid] then
                v.server_name = data.list[v.gid]
            end
        end
    end
end

function PKDataMgr:MSG_PK_FINGER(data)
    local list = {}

    for _, v in ipairs(data.list) do
        table.insert(list, v)
    end

    self.allData["search_pk"] = list
end

-- 给提示并且打标记
function PKDataMgr:sendMiscAndMark(map_name, curTi, limitStr)
    -- 没有数据，说明是本客户端第一次进入
    DataBaseMgr:replaceItem("SafeZoneTipTime", {
        map_name    = map_name, -- 地图名字
        lastTipTime = curTi     -- 服务器当前时间
    }, limitStr)

    -- 发送杂项提示
    ChatMgr:sendMiscMsg(CHS[5000287])
end

-- 检查玩家地图
function PKDataMgr:checkUnSafeZone(data)
    if data.is_safe_zone == 1 then
        -- 安全区不需要提醒
        return
    end

    if Me:getLevel() < Const.PK_OPEN_LEVEL then
        -- 玩家等级<70，不会被PK，不需要提醒
        return
    end

    local limitStr = string.format("map_name='%s'", data.map_name)
    local curTi = gf:getServerTime()

    -- 检查是否是今天第一次进入非安全区
    local tipData = DataBaseMgr:selectItems("SafeZoneTipTime", limitStr)
    if tipData.count <= 0 then
        self:sendMiscAndMark(data.map_name, curTi, limitStr)
    else
        for i = 1, tipData.count do
            local oneData = tipData[i] or {}
            if not gf:isSameDay5(curTi, oneData.lastTipTime or 0) then
                -- 不是同一天
                self:sendMiscAndMark(data.map_name, curTi, limitStr)
                break
            end
        end
    end
end

-- 进入房间消息
function PKDataMgr:MSG_ENTER_ROOM(data)
    if not GameMgr:isEnterGameOK() then
        -- 还没进入游戏，玩家数据未初始化完成，不能进行判断
        return
    end

    if DlgMgr:isDlgOpened("LingyzmDlg") then
        return
    end

    self:checkUnSafeZone(data)
end

-- 进入游戏
function PKDataMgr:MSG_ENTER_GAME(data)
    if not MapMgr.mapData then return end
    self:checkUnSafeZone(MapMgr.mapData)
end

MessageMgr:regist("MSG_PK_RECORD", PKDataMgr)
MessageMgr:regist("MSG_RECORD_INFO", PKDataMgr)
MessageMgr:regist("MSG_PK_FINGER", PKDataMgr)
MessageMgr:hook("MSG_ENTER_ROOM", PKDataMgr, "PKDataMgr")
MessageMgr:hook("MSG_ENTER_GAME", PKDataMgr, "PKDataMgr")
