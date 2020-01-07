-- DataBaseMgr.lua
-- Created by liuhb Mar/22/2016
-- 数据库管理器

DataBaseMgr = Singleton()

-- 数据库
local DB_PATH = "save.db"

-- 所有表
local tableList = {
    -- 好友聊天记录
    ["friendChatHistory"] = {"friendGid",
                             "gid",
                             "icon",
                             "chatStr",
                             "name",
                             "time",
                             "level",
                             "index"
                            },
    -- 好友帮派数据
    ["friendParty"]       = {"gid",
                             "partyName"
                            },
    -- 逛摊收藏
    ["collect"]           = {"name",
                             "gid",
                             "id",
                             "price",
                             "status",
                             "endTime",
                             "level",
                             "unidentified",
                             --"amount",
                             },
    -- 珍宝逛摊收藏
    ["gold_collect"]       = {"name",
                            "gid",
                            "id",
                            "price",
                            "status",
                            "endTime",
                            "level",
                            "unidentified",
                            --"amount",
                            },
    -- 日常常用词
    ["dailyWord"]         = {"index",
                             "dailyStr"
                             },
    -- 公示收藏
    ["publicCollect"]     = {"name",
                             "gid",
                             "id",
                             "price",
                             "status",
                             "endTime",
                             "level",
                             "unidentified",
                             --"amount",
                             },
    -- 珍宝公示收藏
    ["gold_publicCollect"] = {"name",
                            "gid",
                            "id",
                            "price",
                            "status",
                            "endTime",
                            "level",
                            "unidentified",
                           -- "amount",
                            },
    -- 帮派公告
    ["partyNotify"]       = {"index",
                             "title",
                             "context",
                             },
    -- 自动发送消息
    ["autoMsg"]           = {"key",
                             "lastTime",
                             },
    -- 最近联系人信息
    ["tempFriendInfo"]    = {"str",
                             "date",
                             },
    -- 集市收藏
    ["marketCollect"]     = {
                             "json_para"
                            },
    -- 集市公示收藏
    ["marketPublicCollect"]     = {
        "json_para"
    },
    -- 珍宝收藏
    ["marketGoldCollect"]     = {
                            "json_para"
    },

    -- 珍宝公示收藏
    ["marketPublicGoldCollect"]     = {
        "json_para"
    },

    -- 观战中心 收藏
    ["watchCombats"] = {"json_para"},

    -- 空间文件
    ["blogFiles"] = {
        "name",
        "time",
    },

    -- 每个非安全区的提示时间
    ["SafeZoneTipTime"] = {
        "map_name",
        "lastTipTime",
    },

    -- 区域好友相关的数据
    ["cityFriendData"] = {
        "json_para"
    },

    -- Debug 数据
    ["debugData"] = {
        "update_time",
        "account",
        "gid",
        "mac",
        "type",
        "p1",
        "p2",
        "p3",
        "memo",
    },
}

-- 初始化，确保数据库存在，并且相应的表存在
function DataBaseMgr:init()
    self:assureDataBase()
end

function DataBaseMgr:close()
    DBMgr:getInstance():closeDB(GameMgr:getChatPath() .. DB_PATH)
end

-- 创建所有表
function DataBaseMgr:createAllTables()
    for tableName, paras in pairs(tableList) do
        self:createTabel(tableName, paras)
    end
end

-- 创建表
function DataBaseMgr:createTabel(tableName, paras)
    if nil == tableName or nil == paras then return end
    local tempStr = ""

    for k, v in pairs(paras) do
        tempStr = tempStr .. string.format(", `%s` text", v)
    end

    local sqlStr = string.format("create table %s(static_id integer primary key autoincrement%s)", tableName, tempStr)
    DBMgr:getInstance():exec(sqlStr)
end

-- 确保数据库
function DataBaseMgr:assureDataBase()
    if not DBMgr:getInstance():assureDB(GameMgr:getChatPath() .. DB_PATH) then
        return false
    end

    for tableName, paras in pairs(tableList) do
        if not DBMgr:getInstance():tableExsist(tableName) then
            self:createTabel(tableName, paras)
        end
    end
end

-- 创建插入语句
function DataBaseMgr:buildOneInsertSql(tableName, data)
    local paras = tableList[tableName]
    if nil == paras then
        return ""
    end

    local parasStr = ""
    local valuesStr = ""
    local values = {}
    for i = 1, #paras do
        local para = paras[i]
        if 1 == i then
            parasStr = parasStr .. string.format("`%s`", para)
            valuesStr = valuesStr .. "?"
        else
            parasStr = parasStr .. string.format(", `%s`", para)
            valuesStr = valuesStr .. ", ?"
        end

        values[string.format("%d", i)] = data[para] or ""
    end

    -- 创建语句
    local sqlStr = string.format("insert into `%s`(%s) values(%s)", tableName, parasStr, valuesStr)

    return sqlStr, gf:ConvertToUtilMappingN(values)
end

-- 插入
function DataBaseMgr:insertItem(tableName, data)
    local sqlStr, values = self:buildOneInsertSql(tableName, data)
    DBMgr:getInstance():bindInsert(sqlStr, values)
end

-- 更新
function DataBaseMgr:updateItem(tableName, dstr, limitStr)
    local sqlStr = string.format("update `%s` set %s where %s", tableName, dstr, limitStr)
    DBMgr:getInstance():exec(sqlStr)
end

-- 替换
function DataBaseMgr:replaceItem(tableName, data, limitStr)
    self:deleteItems(tableName, limitStr)
    self:insertItem(tableName, data)
end

-- 查询
function DataBaseMgr:selectItems(tableName, limitStr)
    local paras = tableList[tableName]
    if nil == paras then
        return ""
    end

    if nil ~= limitStr and "" ~= limitStr then
        limitStr = string.format("where %s", limitStr)
    else
        limitStr = ""
    end

    -- 创建语句where friendGid = '%s' order by id limit %d
    local parasStr = "`" .. gf:makeStringWithSplitChar(paras, "`,`") .. "`"
    local sqlStr = string.format("select %s from `%s` %s", parasStr, tableName, limitStr)
    local result = DBMgr:getInstance():selectForLua(sqlStr)
    local count = result:QueryInt("count")
    local data = {}

    for i = 1, count do
        local singleItem = {}
        for _, para in pairs(paras) do
            singleItem[para] = result:Query(string.format("%s_%d", para, i))
        end

        table.insert(data, singleItem)
    end

    data.count = count

    return data
end

-- 删除
function DataBaseMgr:deleteItems(tableName, limitStr)
    if nil ~= limitStr and "" ~= limitStr then
        limitStr = string.format("where %s", limitStr)
    else
        limitStr = ""
    end

    local sqlStr = string.format("delete from `%s` %s", tableName, limitStr)
    DBMgr:getInstance():exec(sqlStr)
end
