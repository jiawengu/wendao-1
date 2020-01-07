-- PrisonMgr.lua
-- Created by yangym Oct/14/2016
-- 监狱管理器

PrisonMgr = Singleton()

PrisonMgr.prisonerInfo = {}

-- 标记此次服务器发送数据是否完成
PrisonMgr.isPushFinished = false

function PrisonMgr:getPrisonerInfo()
    return self.prisonerInfo
end

function PrisonMgr:setPushFinished()
    self.isPushFinished = true
end

function PrisonMgr:clearData()
    self.prisonerInfo = {}
end

-- 获取某一区间的囚犯列表信息
function PrisonMgr:getPrisonerList(start, limit, prisonerInfo)
    if not prisonerInfo then
        prisonerInfo = self:getPrisonerInfo()
    end
    
    if #prisonerInfo == 0 then
        return
    end

    local retValue = {}
    local count = 0

    for i = 1, #prisonerInfo do
        if i >= start and count < limit then
            table.insert(retValue, prisonerInfo[i])
            count = count + 1
        end
    end

    if next(retValue) then
        return retValue
    end
end

function PrisonMgr:MSG_ZUOLAO_INFO(data)

    -- 如果当前接收的数据是服务器此次发送数据的第一轮，则清掉之前保存的数据
    if self.isPushFinished then
        self:clearData()
        self.isPushFinished = false
    end
    
    -- 接收到的数据有可能与已有数据重复，清除重复项
    local prisonerTemp = {}
    for i = 1, data.count do
        local isExsit = false
        for j = 1, #self.prisonerInfo do
            if self.prisonerInfo[j].gid == data[i].gid then
                isExsit = true
                break
            end
        end

        if not isExsit then
            table.insert(prisonerTemp, data[i])
        end
    end

    for i = 1, #prisonerTemp do
        table.insert(self.prisonerInfo, prisonerTemp[i])
    end

    -- 排序

    -- 增加是否为好友的比较层级
    for i = 1, #self.prisonerInfo do
        if FriendMgr:hasFriend(self.prisonerInfo[i].gid) then
            self.prisonerInfo[i].layer = 2  -- 是我的好友
        else
            self.prisonerInfo[i].layer = 1  -- 不是我的好友
        end
    end

    table.sort(self.prisonerInfo, function(l, r)
        -- 是好友则排在前面
        if l.layer > r.layer then return true end
        if l.layer < r.layer then return false end      

        -- 坐牢剩余时间长的排在前面
        if l.last_ti > r.last_ti then return true end
        if l.last_ti < r.last_ti then return false end
    end)
end

MessageMgr:regist("MSG_ZUOLAO_INFO", PrisonMgr)