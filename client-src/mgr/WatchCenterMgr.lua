-- WatchCenterMgr.lua
-- Created by songcw Feb/07/2017
-- 观战中心管理器

WatchCenterMgr = Singleton()

local json = require('json')

-- 赛事基本信息配置
-- name 赛事名称 
-- isSpecial 是否为特殊赛事，优先选中
-- notNeedCost 是否需要花费，赛事详情界面显示花费
-- 无内测、公测时间区分时，配置startTime、endTime即可，需要区分时，按testStartTime，endStartTime格式配置
-- 此配表有顺序要求，特殊赛事需要按文档中顺序配置
local MATCH_CFG = {
    {type = CHS[4100450]}, -- 跨服帮战
    {type = CHS[3003208]}, -- 帮战
    {type = CHS[4000409]}, -- 跨服试道大会
    {type = CHS[4100451]}, -- 试道大会
    {type = CHS[5400341]}, -- 跨服竞技
    {type = CHS[7002193], isSpecial = true, notNeedCost = true, testStartTime = "20180817210000",
        testEndTime = "20180827045959", officialStartTime = "20181213210000", officialEndTime = "20190106045959"}, -- 全民PK赛
    {type = CHS[4100704]}, -- 跨服战场
    {type = CHS[4101015], isSpecial = true, notNeedCost = true, startTime = "20180521050000", endTime = "20180602045959"}, -- 名人争霸赛
}

local MINGRZB_MATCH_TYPE = {
    CHS[7150067], -- 总决赛
    CHS[7150068], -- 半决赛
    CHS[7150069], -- 八强赛
}

local QUANMPK_MATCH_TYPE = {
    CHS[7120142], -- 冠亚军之战
    CHS[7120143], -- 季殿军之战
    CHS[7150068], -- 半决赛
    CHS[7120146], -- 4强赛
    CHS[7120147], -- 8强赛
}

local m_combatsInfo = {}    -- 观战大厅，战斗列表数据

local m_combatsRecord = {}  --  战斗录像

local m_collectionCombats = nil

local COLLECT_MAX = 10

WatchCenterMgr.isRefreshData = false

-- 设置观战中心数据是否是刷新按钮刷新的
function WatchCenterMgr:setIsRefreshData(flag)
    self.isRefreshData = flag
end

-- 获取全民PK观战比赛类型
function WatchCenterMgr:getQuanmpkCombatTypeCfg()
    return QUANMPK_MATCH_TYPE
end

-- 获取名人争霸观战比赛类型
function WatchCenterMgr:getMingrzbCombatTypeCfg()
    return MINGRZB_MATCH_TYPE
end

-- 获取指定类型战斗数据
function WatchCenterMgr:getCombatDataByType(type)
    if string.match(type, CHS[4100450]) then -- 跨服帮战
        return m_combatsInfo.kfbz_combats 
    elseif string.match(type, CHS[3003208]) then -- 帮战
        return m_combatsInfo.bz_combats 
    elseif string.match(type, CHS[4000409]) then -- 跨服试道大会
        return m_combatsInfo.kfsd_combats  
    elseif string.match(type, CHS[4100451]) then -- 试道大会
        return m_combatsInfo.sd_combats
    elseif string.match(type, CHS[7002193]) then -- 全民PK赛
        return m_combatsInfo.qmpk_combats
    elseif string.match(type, CHS[4100704]) then -- 跨服战场
        return m_combatsInfo.kfzc_combats  
    elseif string.match(type, CHS[5400341]) then -- 跨服竞技
        return m_combatsInfo.kfjj_combats
    elseif string.match(type, CHS[4101015]) then -- 名人争霸赛
        return m_combatsInfo.mrzb_combats
    end
end

-- 获取默认选择特殊比赛类型
-- 优先选中排序靠前的特殊比赛，没有特殊比赛时，返回nil选择全部赛事
function WatchCenterMgr:getDefaultSpecialType()
    local cfg = MATCH_CFG
    for i = 1, #cfg do
        local matchType = cfg[i].type
        if cfg[i].isSpecial and WatchCenterMgr:canShowSpecailMatch(matchType) then
            return matchType
        end
    end
end

-- 特殊赛事页签是否可以显示
function WatchCenterMgr:canShowSpecailMatch(type)
    if type == CHS[4101015] and DistMgr:curIsTestDist() then
        -- 名人争霸，内测区不显示
        return false    
    end

    local serverTime = gf:getServerDate("%Y%m%d%H%M%S", gf:getServerTime())
    local cfg = MATCH_CFG
    for i = 1, #cfg do
        if type == cfg[i].type and cfg[i].isSpecial then
            local startTime = cfg[i].startTime
            local endTime = cfg[i].endTime 
            if not startTime then
                if DistMgr:curIsTestDist() then
                    startTime = cfg[i].testStartTime
                    endTime = cfg[i].testEndTime 
                else
                    startTime = cfg[i].officialStartTime
                    endTime = cfg[i].officialEndTime 
                end
            end

            if startTime and endTime and startTime <= serverTime and serverTime <= endTime then
                -- 当前时间在显示页签时间内
                return true
            else
                return false
            end
        end
    end

    -- 特殊赛事没有配时间默认不显示
    return false
end

-- 是否显是特殊赛事
function WatchCenterMgr:isSpecialMatch(type)
    local cfg = MATCH_CFG
    for i = 1, #cfg do
        if type == cfg[i].type then
            if cfg[i].isSpecial then
                return true
            end
        end
    end

    return false
end

-- 是否显示无需花费(特殊赛事)
function WatchCenterMgr:isFreeToWatch(type)
    local cfg = MATCH_CFG
    for i = 1, #cfg do
        if type == cfg[i].type then
            if cfg[i].notNeedCost then
                return true
            end
        end
    end

    return false
end

-- 根据直播、录像获取相关资源
function WatchCenterMgr:getWatchIconForPlayType(watchType)
    if watchType == 1 then
        return ResMgr.ui.watch_play_type1
    else
        return ResMgr.ui.watch_play_type2
    end
end

-- 获取观看类型的icon
function WatchCenterMgr:getWatchIconAndName(watchType)    
    if string.match(watchType, CHS[4100450]) then -- 跨服帮战
        return ResMgr.ui.watch_type1   
    elseif string.match(watchType, CHS[3003208]) then -- 帮战
        return ResMgr.ui.watch_type2   
    elseif string.match(watchType, CHS[4000409]) then -- 跨服试道大会
        return ResMgr.ui.watch_type3   
    elseif string.match(watchType, CHS[4100451]) then -- 试道大会
        return ResMgr.ui.watch_type4   
    elseif string.match(watchType, CHS[7002193]) then -- 全民PK赛
        return ResMgr.ui.watch_type5   
    elseif string.match(watchType, CHS[4100704]) then -- 跨服战场
        return ResMgr.ui.watch_type6   
    elseif string.match(watchType, CHS[5400341]) then -- 跨服竞技
        return ResMgr.ui.watch_type7
    elseif string.match(watchType, CHS[4101015]) then -- 名人争霸赛
        return ResMgr.ui.watch_type8
    else
        return ResMgr.ui.watch_type2
    end
end

function WatchCenterMgr:clearData(isLoginOrSwithLine)
    if not isLoginOrSwithLine then
        self.lastQueryTime = 0
    end
end

-- 查询观战赛事列表
function WatchCenterMgr:queryWatchCombats(tips)
    WatchCenterMgr.lastQueryTime = WatchCenterMgr.lastQueryTime or 0
    if gfGetTickCount() - WatchCenterMgr.lastQueryTime < 5 * 1000 then
        gf:ShowSmallTips(tips or CHS[8000008])    -- 请不要频繁刷新
        return
    end
    
    WatchCenterMgr.lastQueryTime = gfGetTickCount()
    gf:CmdToServer("CMD_REQUEST_BROADCAST_COMBAT_LIST", {})
end

-- 查询指定赛事信息
function WatchCenterMgr:queryWatchCombatById(combat_id)
    self.queryCombatId = combat_id
    gf:CmdToServer("CMD_REQUEST_BROADCAST_COMBAT_DATA", {combat_id = combat_id})
end

-- 请求查看某场战斗   combat_type 用于服务器校验是否过期
function WatchCenterMgr:lookOnWatchCombatById(combat_id, combat_type)    
    gf:CmdToServer("CMD_LOOKON_BROADCAST_COMBAT", {combat_id = combat_id, combat_type = combat_type})
end

-- 退出录像观战
function WatchCenterMgr:quitLookOnWatchCombat()
    gf:CmdToServer("CMD_QUIT_LOOKON_BROADCAST_COMBAT", {})
    BarrageTalkMgr:removeBarrageLayer()
end

-- 观战赛事列表
function WatchCenterMgr:MSG_BROADCAST_COMBAT_LIST(data)
    local isEnd = false
    if data.page == 1 then
        -- page == 1表示第一页，如果已经有数据，则清空        
        m_combatsInfo = {count = 0}
        m_combatsInfo.count = m_combatsInfo.count + data.count
        m_combatsInfo.combats = {}
        m_combatsInfo.bz_combats = {}
        m_combatsInfo.kfbz_combats = {}
        m_combatsInfo.sd_combats = {}
        m_combatsInfo.kfsd_combats = {}
        m_combatsInfo.qmpk_combats = {}
        m_combatsInfo.kfzc_combats = {}
        m_combatsInfo.kfjj_combats = {}
        m_combatsInfo.mrzb_combats = {}
    end

    -- 无论有没有比赛数据，策划要求都尝试选中特殊赛事
    if not self.defSelectMenu and not self.isRefreshData then
        self:setDefTypeMenu(self:getDefaultSpecialType())
    end

    if data.count == 0 then 
        local dlg = DlgMgr:openDlg("WatchCentreDlg")
        dlg:setWatchsInfo()
        if self.defSelectMenu then
            DlgMgr:sendMsg("WatchCentreDlg", "onSelectMenuByName", self.defSelectMenu)
            self.defSelectMenu = nil
        end
        return 
    end    

    local canShowMrzbFlag = WatchCenterMgr:canShowSpecailMatch(CHS[4101015])
    local canShowQmpkFlag = WatchCenterMgr:canShowSpecailMatch(CHS[7002193])

    for i = 1, data.count do        
        -- 保存在各个表中
        if data.combats[i].combat_type ~= CHS[4101015] or canShowMrzbFlag then
            table.insert(m_combatsInfo.combats, data.combats[i])
        end

        if string.match(data.combats[i].combat_type, CHS[4100450]) then --跨服帮战
            -- 跨服帮战表
            table.insert(m_combatsInfo.kfbz_combats, data.combats[i])
        elseif string.match(data.combats[i].combat_type, CHS[3003208]) then --帮战
            -- 帮战表
            table.insert(m_combatsInfo.bz_combats, data.combats[i])
        elseif string.match(data.combats[i].combat_type, CHS[4000409]) then --跨服试道大会
            -- 跨服试道表
            table.insert(m_combatsInfo.kfsd_combats, data.combats[i])
        elseif string.match(data.combats[i].combat_type, CHS[4100451]) then --试道大会
            -- 试道大会表
            table.insert(m_combatsInfo.sd_combats, data.combats[i])
        elseif data.combats[i].combat_type == CHS[7002193] and canShowQmpkFlag then
            -- 全民PK表
            table.insert(m_combatsInfo.qmpk_combats, data.combats[i])            
        elseif string.match(data.combats[i].combat_type, CHS[4100704]) then
            -- 跨服战场
            table.insert(m_combatsInfo.kfzc_combats, data.combats[i])
        elseif string.match(data.combats[i].combat_type, CHS[5400341]) then
            -- 跨服竞技
            table.insert(m_combatsInfo.kfjj_combats, data.combats[i])
        elseif data.combats[i].combat_type == CHS[4101015] and canShowMrzbFlag then
            -- 名人争霸赛
            table.insert(m_combatsInfo.mrzb_combats, data.combats[i])
        end
    end
    
    if data.page == data.total_page then    -- 是否接收完成        
        local function sortList(l, r)
            if l.combat_play_type < r.combat_play_type then return true end
            if l.combat_play_type > r.combat_play_type then return false end

            if l.start_time > r.start_time then return true end
            if l.start_time < r.start_time then return false end
            return false
        end    
    
        -- 排序
        table.sort(m_combatsInfo.combats, sortList)
        table.sort(m_combatsInfo.bz_combats, sortList)
        table.sort(m_combatsInfo.kfbz_combats, sortList)
        table.sort(m_combatsInfo.sd_combats, sortList)
        table.sort(m_combatsInfo.kfsd_combats, sortList)
        table.sort(m_combatsInfo.qmpk_combats, sortList)
        table.sort(m_combatsInfo.kfzc_combats, sortList)
        table.sort(m_combatsInfo.kfjj_combats, sortList)
        table.sort(m_combatsInfo.mrzb_combats, sortList)
        
        local dlg = DlgMgr:getDlgByName("WatchCentreDlg")
        if dlg then
            dlg:setWatchsInfo()
        else
            dlg = DlgMgr:openDlg("WatchCentreDlg")        
        end

        if self.defSelectMenu then
            DlgMgr:sendMsg("WatchCentreDlg", "onSelectMenuByName", self.defSelectMenu)
            self.defSelectMenu = nil
        end
    end

    WatchCenterMgr:setIsRefreshData(false)
end

function WatchCenterMgr:setDefTypeMenu(typeMenu)
    self.defSelectMenu = typeMenu
end

function WatchCenterMgr:getCombats()
    return m_combatsInfo
end

-- 获取指定位置的战斗
function WatchCenterMgr:getCombatsByIndex(start, count, combat_type)
    if combat_type == CHS[4300219] then
        return WatchCenterMgr:getCollectionsCombats()
    end

    if not m_combatsInfo or not next(m_combatsInfo) then return end
    local data = {}
    for i = start, start + count - 1 do   
        if string.match(combat_type, CHS[4100450]) then -- 跨服帮战
            if m_combatsInfo.kfbz_combats[i] then
                table.insert(data, m_combatsInfo.kfbz_combats[i])
            end       
        elseif string.match(combat_type, CHS[3003208]) then -- 帮战  
            if m_combatsInfo.bz_combats[i] then
                table.insert(data, m_combatsInfo.bz_combats[i])
            end  
        elseif string.match(combat_type, CHS[4000409]) then -- 跨服试道大会
            if m_combatsInfo.kfsd_combats[i] then
                table.insert(data, m_combatsInfo.kfsd_combats[i])
            end  
        elseif string.match(combat_type, CHS[4100451]) then -- 试道大会
            if m_combatsInfo.sd_combats[i] then
                table.insert(data, m_combatsInfo.sd_combats[i])
            end       
        elseif string.match(combat_type, CHS[7002193]) then -- 全民PK赛
            if m_combatsInfo.qmpk_combats[i] then
                table.insert(data, m_combatsInfo.qmpk_combats[i])
            end
        elseif string.match(combat_type, CHS[4100704]) then -- 跨服战场
            if m_combatsInfo.kfzc_combats[i] then
                table.insert(data, m_combatsInfo.kfzc_combats[i])
            end    
        elseif string.match(combat_type, CHS[5400341]) then -- 跨服竞技
            if m_combatsInfo.kfjj_combats[i] then
                table.insert(data, m_combatsInfo.kfjj_combats[i])
            end
        elseif string.match(combat_type, CHS[4101015]) then -- 名人争霸赛
            if m_combatsInfo.mrzb_combats[i] then
                table.insert(data, m_combatsInfo.mrzb_combats[i])
            end
        else
            if m_combatsInfo.combats[i] then
                table.insert(data, m_combatsInfo.combats[i])
            end
        end           
    end
    
    return data
end

-- 获取特殊赛事子类型的所有战斗
-- 返回 list: {[1] = {3局2胜表}, [2] = {3局2胜表}, ... }
function WatchCenterMgr:getSpecialCombat(type, subType, leaderName)
    local data = m_combatsInfo.mrzb_combats
    if type == CHS[7002193] then
        data = m_combatsInfo.qmpk_combats
    end

    if not data or #data == 0 then return {} end

    -- 先找出子类型对应的比赛
    local subTypeData = {}
    for i = 1, #data do
        if data[i].combat_sub_type == subType
            and (not leaderName or leaderName == data[i].att_name) then
            table.insert(subTypeData, data[i])
        end
    end

    -- 根据攻击方区组名，队长名，对比赛进行分组
    local groupNum = 1
    local subTypeList = {}
    for i = 1, #subTypeData do
        local findFlag = false
        for j = 1, #subTypeList do
            local subListInfo = subTypeList[j][1]
            if subTypeData[i].att_dist == subListInfo.att_dist and subTypeData[i].att_name == subListInfo.att_name then
                -- 找到了同一组比赛，插入
                table.insert(subTypeList[j], subTypeData[i])
                findFlag = true
            end
        end

        -- 没有找到同组比赛，插入
        if not findFlag then
            subTypeList[groupNum] = {}
            table.insert(subTypeList[groupNum], subTypeData[i])
            groupNum = groupNum + 1
        end
    end

    return subTypeList
end

-- 查询某场战斗的信息
function WatchCenterMgr:getCombatsDataById(combat_id)
    if m_combatsInfo and m_combatsInfo.combats then
        for i = 1, m_combatsInfo.count do
            if m_combatsInfo.combats[i].combat_id == combat_id then
                return m_combatsInfo.combats[i]
            end
        end
    end
end

-- 观众中心，根据队长、赛事类型查询数据
function WatchCenterMgr:getDataByCaptainAndCombatType(captain, combat_type)
    if not m_combatsInfo or not next(m_combatsInfo) then return end
    local data = {}
    
    local compareCombatType 
    if combat_type == CHS[4100452] then -- 跨服试道大会
        compareCombatType = CHS[4300026]
    else
        compareCombatType = combat_type
    end
    
    
    if combat_type == CHS[4300219] then
        local retWars = WatchCenterMgr:getCollectionsCombats()
        for i = 1, #retWars do
            local combatInfo = retWars[i]        
            if (string.match(combatInfo.att_name, captain) or string.match(combatInfo.def_name, captain)) then
                table.insert(data, combatInfo)
            end
        end
    
        return data
    end
    
    
    for i = 1, m_combatsInfo.count do
        local combatInfo = m_combatsInfo.combats[i]        
        if (string.match(combatInfo.att_name, captain) or string.match(combatInfo.def_name, captain)) 
            and (string.match(combatInfo.combat_type, compareCombatType) or combat_type == CHS[4000410]) then
            table.insert(data, m_combatsInfo.combats[i])
        end
    end

    return data
end

-- 获取观战中心中，当前观战的战斗数据
function WatchCenterMgr:getCombatData()
    if self.combatData then
        -- 直播                
        return self.combatData
    end
    
    if WatchRecordMgr:getCurReocrdCombatId() then
        -- 录像
        return {combat_id = WatchRecordMgr:getCurReocrdCombatId()}
    end
end

function WatchCenterMgr:MSG_LOOKON_BROADCAST_COMBAT_STATUS(data)
    if data.combat_id == "" then
        self.combatData = nil
    else
        self.combatData = data
        self.combatData.isNow = true
    end
end

function WatchCenterMgr:MSG_BROADCAST_COMBAT_DATA(data)
    if self.queryCombatId ~= data.combat_id then return end
    local dlg = DlgMgr:openDlg("WatchCentreDetailsDlg")
    dlg:setData(data)
end

-- 是否在观战中心中看战斗
function WatchCenterMgr:isCombatInWatchCenter()
    local data = WatchCenterMgr:getCombatData()
    if not data or not next(data) then
        return false
    end 
    
    return true
end

-- 是否已经收藏了
function WatchCenterMgr:isCollected(combat_id)
    local collections = WatchCenterMgr:getCollectionsCombats()  
    for i, data in pairs(collections) do
        if data.combat_id == combat_id then return true end
    end
    
    return false
end

-- 增加收藏
function WatchCenterMgr:addCollectionCombat(combat_id)
    local collections = WatchCenterMgr:getCollectionsCombats()    
    if #collections >= COLLECT_MAX then
        gf:ShowSmallTips(CHS[4300222])
        return
    end
    
    if WatchCenterMgr:isCollected(combat_id) then
        return
    end
    
    local data = WatchCenterMgr:getCombatsDataById(combat_id)
    data.time = os.time()
    
    table.insert(collections, data)
    
    DataBaseMgr:deleteItems("watchCombats")
    for id, data in pairs(collections) do
        local str = json.encode(data) 
        DataBaseMgr:insertItem("watchCombats", {json_para = str})    
    end
    
    return true
end

-- 取消收藏
function WatchCenterMgr:removeCollectionsCombats(combat_id)
    local collections = WatchCenterMgr:getCollectionsCombats() 
    for i = 1, #collections do
        if collections[i].combat_id == combat_id then
            table.remove(collections, i)
            break
        end
    end

    -- 取消收藏时，检查过期的特殊赛事，防止本地数据库以后太多冗余数据量
    local retCollections = {}
    for i = 1, #collections do
        if not WatchCenterMgr:isSpecialMatch(collections[i].combat_type)
            or WatchCenterMgr:canShowSpecailMatch(collections[i].combat_type) then
            -- 非特殊赛事，或可以显示的特殊赛事，则加入
            table.insert(retCollections, collections[i])
        end
    end

    DataBaseMgr:deleteItems("watchCombats")
    for id, data in pairs(retCollections) do
        local str = json.encode(data) 
        DataBaseMgr:insertItem("watchCombats", {json_para = str})    
    end

    return true
end

-- 获取收藏
function WatchCenterMgr:getCollectionsCombats()
    local ret = {}
    local dataPara = DataBaseMgr:selectItems("watchCombats")
    for i = 1, dataPara.count do
        local goodsData = json.decode(dataPara[i].json_para)  
        if not WatchCenterMgr:isSpecialMatch(goodsData.combat_type)
            or WatchCenterMgr:canShowSpecailMatch(goodsData.combat_type) then
            -- 非特殊赛事，或可以显示的特殊赛事，则加入
            table.insert(ret, goodsData)
        end
    end

    table.sort(ret, function(l, r)
        if l.time > r.time then return true end
        if l.time < r.time then return false end
    end)
    
    return ret
end

function WatchCenterMgr:MSG_RECORDED_COMBAT_INVALID(data)
    if WatchCenterMgr:isCollected(data.combat_id) then
        WatchCenterMgr:removeCollectionsCombats(data.combat_id)
        DlgMgr:sendMsg("WatchCentreDlg", "onSelectMenuByName", CHS[4300219])
    end
end

function WatchCenterMgr:canShowShareAndBarrage()
    local data = WatchCenterMgr:getCombatData()
    if data then
        if self.notShowShareAndBarrageId == data.combat_id then
            return false
        end
        
        return true
    end
end

function WatchCenterMgr:setNotShowShareAndBarrage(id)
    self.notShowShareAndBarrageId = id
end

MessageMgr:regist("MSG_RECORDED_COMBAT_INVALID", WatchCenterMgr)
MessageMgr:regist("MSG_BROADCAST_COMBAT_DATA", WatchCenterMgr)
MessageMgr:regist("MSG_BROADCAST_COMBAT_LIST", WatchCenterMgr)
MessageMgr:regist("MSG_LOOKON_BROADCAST_COMBAT_STATUS", WatchCenterMgr)
