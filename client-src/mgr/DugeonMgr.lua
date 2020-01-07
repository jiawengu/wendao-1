-- DugeonMgr.lua
-- Created by songcw Mar/11/2015
-- 负责管理副本

DugeonMgr = Singleton()

DUGEON_TEPR = {
    DUGEON_CREATE = 30000,
    DUGEON_BOUNS  = 30001,
}

local dugeonsInfo = {
        [1] = {
            name = CHS[4000326],
            monster = CHS[4000327],
            icon = 06257,
            limitLevel = 30,
            introduce = CHS[4000328],
        },

        [2] = {
            name = CHS[4000332],
            monster = CHS[4000333],
            icon = 06258,
            limitLevel = 75,
            introduce = CHS[4000334],
        },

        [3] = {
            name = CHS[4000329],
            monster = CHS[4000330],
            icon = 06260,
            limitLevel = 90,
            introduce = CHS[4000331],
        },
        
        [4] = {
            name = CHS[4100554],
            monster = CHS[4100555],
            icon = 20008,
            limitLevel = 110,
            introduce = CHS[4100556],
        },



        ["tips"] = CHS[4000335],
}

local DUGEON_MAPNAME = require(ResMgr:getCfgPath('UnFlyAutoWalkMapName.lua'))

-- 获取指定副本信息
function DugeonMgr:getDugeonInfoByIndex(index)
    return dugeonsInfo[index]
end

-- 获取指定副本tips
function DugeonMgr:getDugeonTips()
    return dugeonsInfo["tips"]
end

-- 创建副本
function DugeonMgr:createDugeon(name)
    gf:sendGeneralNotifyCmd(DUGEON_TEPR.DUGEON_CREATE, name)
end

-- 打开副本奖励－宝箱
function DugeonMgr:openBox(index, cost)
    cost = cost or 0
    local coin = Me:queryBasicInt('gold_coin') + Me:queryBasicInt('silver_coin')
    if coin < cost then
        gf:askUserWhetherBuyCoin()
        return
    end
    gf:sendGeneralNotifyCmd(DUGEON_TEPR.DUGEON_BOUNS, index)
end

-- 判断是在副本中
function DugeonMgr:isInDugeon(targetName)
    if not MapMgr.mapData then return end 
    
    if not targetName then targetName = MapMgr.mapData.map_name end

    local bRetValue = false

    for _, mapTable in pairs(DUGEON_MAPNAME) do
        for _, mapName in pairs(mapTable) do
            if targetName == mapName then
                bRetValue = true
                break
            end
        end
    end

    return bRetValue
end
