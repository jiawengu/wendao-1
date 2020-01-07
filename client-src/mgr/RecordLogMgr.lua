-- RecordLogMgr.lua
-- created by zhengjh Apr/11/2016
-- 日志管理器

RecordLogMgr = Singleton()

-- clickgotobutto 为mainType
-- needRecodeLog 为subType 要统计次数
-- clickTimes 为 点击次数需要记录
-- time 为time分钟以内要记录
local RECOED_EVENT_INFO =
{
    ["clickgotobutton"] = {
            needRecodeLog = {
                    [CHS[3000265]] = "shim", -- 师门任务
                    [CHS[3000270]] = "chub", -- 除暴任务
                    [CHS[3000275]] = "tongtt", -- 通天塔
                    [CHS[3000279]] = "jingjc", -- 竞技场
                    [CHS[3000283]] = "bangprw", -- 帮派任务
                    [CHS[3000287]] = "shuad", -- 刷道
                    [CHS[3000291]] = "xiux", -- 修行
                    [CHS[3000295]] = "zhurwl", -- 助人为乐
                    [CHS[3000299]] = "fub", -- 副本
                    [CHS[3000303]] = "bangprctz", -- 帮派日常挑战
                    [CHS[3000306]] = "tiaozzm", -- 挑战掌门
                    [CHS[3000314]] = "baxmj", -- 八仙梦境
                    [CHS[3000693]] = "haidrq", -- 海盗入侵
                    [CHS[3000713]] = "biaoxwl", -- 镖行万里
                    [CHS[3000728]] = "shiddh", -- 试道大会
                    [CHS[3000734]] = "xuansrw", --悬赏任务
            },
            clickTimes = 20,
            time = 120,
    },

}

-- 外挂关系的key，对应 RECORD_CTRL_FOR_CG_MISSION 和  RECORD_CTRL_FOR_CG 的key, ，不同外挂，key值不能一样
local PLUG_CARE_KEY = {
    ["cgplug"] = {[1] = true, [2] = true, [3] = true, [4] = true, [5] = true, [6] = true},
    ["bxplug"] = {[7] = true, [8] = true, [9] = true},
    ["slplug"] = {[10] = true, [11] = true, [12] = true},
    ["ldplug"] = {[13] = true, [14] = true},
}

local MAX_KEY = 14   --对应 PLUG_CARE_KEY中key的最大值

-- FOR CG 外挂
-- x,y为指定分辨率720*1280分辨率下，偏移
--[[ align 对齐方式说明。
    left为该界面靠左对齐，x则为相对屏幕左边偏移
    right为该界面靠左对齐，x则为相对屏幕右边偏移
    middle为居中，x则为相对屏幕中间偏移
    key：若两个外挂需要记录的区域一样，也必须配置两个，key为对应外挂关心的key值
--]]
local RECORD_CTRL_FOR_CG_MISSION = {
    {rect = {x = 1138 - 902, y = 415, width = 235, height = 74}, key = 1, align = "right"}, -- 任务第一栏
    {rect = {x = 1138 - 902, y = 340, width = 235, height = 74}, key = 2, align = "right"}, -- 任务第二栏
    {rect = {x = 1138 - 902, y = 415, width = 235, height  = 74}, key = 14, align = "right"}, -- 任务第一栏      
}

local RECORD_CTRL_FOR_CG = {
    ["MissionDlg"] = {
        {rect = {x = 1138 - 910, y = 465 , width = 30, height = 20}, key = 1, align = "right"}, -- 任务第一栏
        {rect = {x = 1138 - 910, y = 365 , width = 30, height = 20}, key = 2, align = "right"}, -- 任务第二栏
        {rect = {x = 1138 - 930, y = 460 , width = 25, height = 25}, key = 14, align = "right"}, -- 任务第一栏        
    },

    ["NpcDlg"] = {
        {rect = {x = 1138 - 830, y = 225, width = 25, height = 20}, key = 3, align = "right"}, -- 陆压真人
        {rect = {x = 1138 - 980, y = 227, width = 20, height = 20}, key = 9, align = "right"}, -- 陆压真人
        {rect = {x = 1138 - 792, y = 220, width = 18, height = 28}, key = 12, align = "right"}, -- 陆压真人
        {rect = {x = 1138 - 885, y = 220, width = 25, height = 30}, key = 13, align = "right"}, -- 陆压真人
    },
    
    ["LordLaoZiDlg"] = {
        {rect = {x = 374 - 1138 * 0.5, y = 275, width = 16, height = 20}, key = 4, align = "middle"}, -- 答案A
        {rect = {x = 650 - 1138 * 0.5, y = 275, width = 25, height = 20}, key = 4, align = "middle"}, -- 答案B
        {rect = {x = 390 - 1138 * 0.5, y = 200, width = 20, height = 25}, key = 4, align = "middle"}, -- 答案C
        {rect = {x = 660 - 1138 * 0.5, y = 200, width = 15, height = 25}, key = 4, align = "middle"}, -- 答案d
    },
    
    ["SystemFunctionDlg"] = {
        {rect = {x = 285, y = 598, width = 16, height = 17}, key = 5, align =  "left"}, -- 主界面-刷道
        {rect = {x = 310, y = 590, width = 20, height = 20}, key = 7, align =  "left"}, -- 主界面-刷道
        {rect = {x = 290, y = 584, width = 22, height = 45}, key = 10, align =  "left"}, -- 主界面-刷道
    },
    
    ["GetTaoDlg"] = {
        {rect = {x = 755 - 1138 * 0.5, y = 190, width = 15, height = 15}, key = 6, align = "middle"}, -- 刷道界面
        {rect = {x = 725 - 1138 * 0.5, y = 190, width = 20, height = 20}, key = 8, align = "middle"}, -- 刷道界面
        {rect = {x = 699 - 1138 * 0.5, y = 190, width = 68, height = 20}, key = 11, align = "middle"}, -- 刷道界面
    },
}

-- 记录一次外挂的时间间隔
local CGPLUGIN_TIME = 7200000 -- 60 * 60 * 1000 * 2

-- 外挂开启时间，例 RecordLogMgr.forPluginOpenTime["cgplug"] = xx,则cg外挂开启记录，记录时间为xx
RecordLogMgr.forPluginOpenTime = {}


local CHANGQI_SHUADAO_XINGWEI_TIME = 3600000 --60 * 60 * 1000

RecordLogMgr.changqiShuadaoStartTime = {}   -- 开始时间
RecordLogMgr.changqiShuadaoTouchData = {}   -- 点击数据
RecordLogMgr.changqiShuadaoCoordinate = {}   -- 日志changqsdjc_2的最大值最小值
RecordLogMgr.getRewardTimes = {fum = 0, xiangy = 0, feix = 0} -- 获取刷道任务奖励

RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes = {fum = 0, xiangy = 0, feix = 0}   -- GetTaoDlg点击次数
RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchLock = {fum = false, xiangy = false, feix = false}   -- GetTaoDlg点击次数锁

local CHANGQI_SHUADAO_JC_LIMIT_TOUCH_TIMES = 8
local CHANGQI_SHUADAO_JLJC_LIMIT_DLG_TIMES = 8
local CHANGQI_SHUADAO_JLJC_LIMIT_TOUCH_TIMES = 70

function RecordLogMgr:changqsdjljcStart()
    RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] = gfGetTickCount()
    RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"] = {}
    RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["fum"] = 0
    RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["xiangy"] = 0
    RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["feix"] = 0

    RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.fum = 0
    RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.xiangy = 0  
    RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes.feix = 0  
end

-- 日志 changqsdjljc_1 
function RecordLogMgr:paraChangqsdjljc(npcName, action)
    self.isMeActive = gfGetTickCount()

    if (npcName == CHS[3000868] and action == CHS[4200077]) 
    or (npcName == CHS[3000817] and action == "dispatch_xiangy") 
        or (npcName == CHS[3000957] and action == CHS[4000448]) then        
        if not RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] or RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] == 0 then
            RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] = -1
        end           
    end
end

function RecordLogMgr:setChangqsdjc_2TouchPos(pos)
    if not pos then self.changqsdjc_2Pos = nil end
    self.changqsdjc_2Pos = gf:deepCopy(pos)
end

-- 日志 changqsdjc_2 记录逻辑
function RecordLogMgr:paraChangqsdjc(taskName)
    --  更新最大值最小值
    local function updatePos()
        RecordLogMgr.changqiShuadaoCoordinate.minX = math.min(RecordLogMgr.changqiShuadaoCoordinate.minX, self.changqsdjc_2Pos.x)
        RecordLogMgr.changqiShuadaoCoordinate.minY = math.min(RecordLogMgr.changqiShuadaoCoordinate.minY, self.changqsdjc_2Pos.y)
        
        RecordLogMgr.changqiShuadaoCoordinate.maxX = math.max(RecordLogMgr.changqiShuadaoCoordinate.maxX, self.changqsdjc_2Pos.x)
        RecordLogMgr.changqiShuadaoCoordinate.maxY = math.max(RecordLogMgr.changqiShuadaoCoordinate.maxY, self.changqsdjc_2Pos.y)
    end
    
    -- 是否满足记录条件
    local function isMeetCondition()
    	if RecordLogMgr.changqiShuadaoCoordinate.maxX - RecordLogMgr.changqiShuadaoCoordinate.minX > 40 then
    	   return false
    	end
    	
        if RecordLogMgr.changqiShuadaoCoordinate.maxY - RecordLogMgr.changqiShuadaoCoordinate.minY > 40 then
            return false
        end
        
        return true
    end

    local function todo(key)
        if not RecordLogMgr.changqiShuadaoStartTime["changqsdjc_2"] or RecordLogMgr.changqiShuadaoStartTime["changqsdjc_2"] == 0 then
            -- 日志 changqsdjc_2 触发
            RecordLogMgr.changqiShuadaoStartTime["changqsdjc_2"] = gfGetTickCount()
            RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"] = {fum = 0, xiangy = 0, feix = 0}
            RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"][key] = 1            
            RecordLogMgr.changqiShuadaoCoordinate = {minX = self.changqsdjc_2Pos.x, minY = self.changqsdjc_2Pos.y, maxX = self.changqsdjc_2Pos.x, maxY = self.changqsdjc_2Pos.y}            
        else
            --  更新最大值最小值
            updatePos()

            if not isMeetCondition() then
                RecordLogMgr.changqiShuadaoStartTime["changqsdjc_2"] = 0
                RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"] = {}
            else 
                RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"][key] = RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"][key] + 1
            end            
        end   
    end

    todo(taskName)    
end

function RecordLogMgr:initPlug()

    -- 点击在指定位置的
    RecordLogMgr.forCGPluginData = {}    
    for wg , data in pairs(PLUG_CARE_KEY) do
        for key , _ in pairs(data) do
            RecordLogMgr.forCGPluginData[key] = 0
        end  
    end       
    
    -- 点击在有效位置
    RecordLogMgr.forCGPluginDataTotal = {}
    for wg , data in pairs(PLUG_CARE_KEY) do
        RecordLogMgr.forCGPluginDataTotal[wg] = {}
        for key , _ in pairs(data) do
            RecordLogMgr.forCGPluginDataTotal[key] = 0
        end  
    end   
end

-- 获取CG外挂记录点总点击
function RecordLogMgr:getCGPluginMissionTotalRect()
    return RECORD_CTRL_FOR_CG_MISSION
end

-- 根据key值找出对应的外挂
function RecordLogMgr:getCarePlugByKey(key)
    for wg , data in pairs(PLUG_CARE_KEY) do
        if data[key] then return wg end
    end    
end

-- 获取CG外挂记录点
function RecordLogMgr:getCGPluginPoint()
    return RECORD_CTRL_FOR_CG
end

-- 是否满足 CG外挂记录条件
function RecordLogMgr:isMeetCGPluginCondition(dlgName)
    local pos = GameMgr.curTouchPos
    if not pos then return end       
    local rects = RECORD_CTRL_FOR_CG[dlgName]    
 

    for _, rectInfo in pairs(rects) do    
        -- 由于记录偏移量，所以需要转化下才是正确的 x、y
        local changeRect = gf:deepCopy(rectInfo.rect)        
        if rectInfo.align == "left" then
        elseif rectInfo.align == "right" then
            changeRect.x = Const.WINSIZE.width - changeRect.x
        elseif rectInfo.align == "middle" then
            changeRect.x = Const.WINSIZE.width * 0.5 + changeRect.x
        end        
    
        -- 是否需要记录制定区域点击
        if cc.rectContainsPoint(changeRect, pos) then        
            RecordLogMgr:addCGPluginInfo(rectInfo)            
        end        
    end    
    
    
    -- 该项总点击
    if dlgName == "MissionDlg" then
        for _, missRect in pairs(RECORD_CTRL_FOR_CG_MISSION) do
            local changeRect = gf:deepCopy(missRect.rect) 
            changeRect.x = Const.WINSIZE.width - changeRect.x
            if cc.rectContainsPoint(changeRect, pos) then
                if RecordLogMgr.forPluginOpenTime[RecordLogMgr:getCarePlugByKey(missRect.key)] then
                    RecordLogMgr.forCGPluginDataTotal[missRect.key] = RecordLogMgr.forCGPluginDataTotal[missRect.key] + 1
                end
            end
        end
    else        
        for _, rectInfo in pairs(rects) do    
            if RecordLogMgr.forPluginOpenTime[RecordLogMgr:getCarePlugByKey(rectInfo.key)] then
                RecordLogMgr.forCGPluginDataTotal[rectInfo.key] = RecordLogMgr.forCGPluginDataTotal[rectInfo.key] + 1
            end
        end    
    end       
end

function RecordLogMgr:endCGPluginOnce(rectInfo)
    if not rectInfo then
        -- 没有则结束所有
        local wgEnd = {}
        for wg , data in pairs(PLUG_CARE_KEY) do            
            for key , _ in pairs(data) do
                if not wgEnd[wg] then            
                    RecordLogMgr:endCGPluginOnce({key = key})
                    wgEnd[wg] = true
                end
            end  
        end     
        return
    end

    RecordLogMgr.forPluginOpenTime[RecordLogMgr:getCarePlugByKey(rectInfo.key)] = nil
    local memo = ""
    local totalTimes = 0
    local wg = RecordLogMgr:getCarePlugByKey(rectInfo.key)
    local index = 1
    
    for i = 1, MAX_KEY do
        if PLUG_CARE_KEY[wg][i] then
            memo = memo .. index .. ":{" .. RecordLogMgr.forCGPluginData[i] .. "," .. RecordLogMgr.forCGPluginDataTotal[i] .. "};"
            totalTimes = totalTimes + RecordLogMgr.forCGPluginData[i]
            index = index + 1
        end
    end
    
    --[[
    for key, data in ipairs(PLUG_CARE_KEY[wg]) do
        memo = memo .. index .. ":{" .. RecordLogMgr.forCGPluginData[key] .. "," .. RecordLogMgr.forCGPluginDataTotal[key] .. "};"
        totalTimes = totalTimes + RecordLogMgr.forCGPluginData[key]
        index = index + 1
    end
    --]]
    
    -- 有效点击次数大于10 ，才需要发送至服务器
    if totalTimes >= 10 then
        local para1 = "(" .. Const.WINSIZE.width .. "*" .. Const.WINSIZE.height .. ")"
        gf:CmdToServer("CMD_LOG_ANTI_CHEATER", {[1] = {action = wg, para1 = para1, para2 = "", para3 = "", memo = memo}, count = 1})
    end

    -- 点击在指定位置的
    for key, data in pairs(PLUG_CARE_KEY[wg]) do
        RecordLogMgr.forCGPluginData[key] = 0
        RecordLogMgr.forCGPluginDataTotal[key] = 0
    end
end

function RecordLogMgr:addCGPluginInfo(rectInfo)
    if not RecordLogMgr.forPluginOpenTime[RecordLogMgr:getCarePlugByKey(rectInfo.key)] then
        RecordLogMgr.forPluginOpenTime[RecordLogMgr:getCarePlugByKey(rectInfo.key)] = gfGetTickCount()      
    end         

    RecordLogMgr.forCGPluginData[rectInfo.key] = RecordLogMgr.forCGPluginData[rectInfo.key] + 1    
   
    -- 间隔2小时，发送服务器
    if RecordLogMgr.forPluginOpenTime[RecordLogMgr:getCarePlugByKey(rectInfo.key)] and gfGetTickCount() - RecordLogMgr.forPluginOpenTime[RecordLogMgr:getCarePlugByKey(rectInfo.key)] > CGPLUGIN_TIME then
        RecordLogMgr.forPluginOpenTime[RecordLogMgr:getCarePlugByKey(rectInfo.key)] = nil 
        RecordLogMgr.forCGPluginDataTotal[rectInfo.key] = RecordLogMgr.forCGPluginDataTotal[rectInfo.key] + 1
        RecordLogMgr:endCGPluginOnce(rectInfo)        
    end
end
-- FOR CG 外挂end

-- 点击坐标信息
-- intervalTime 为每个intervalTime分钟服务端发送点击记录
-- clickCount每个点，点击次数为clickCount以上发送给服务端
-- pointCount为记录的点击个数的上限
-- oneClickInterval为 点击事件间隔oneClickInterval秒以为算为一个点
local TOUCH_POS_INFO = {
    ["clickmouse"] = {
        intervalTime = 60,
        clickCount = 10,
        pointCount = 100,
        oneClickInterval = 10,
    }
}

-- 指定点击需要记录的信息
-- 如果是NPC对话框，需要以npc_id为key值，表中content为点击项, note为发送服务器的编码， 必要格式为 例：[12378] = {content = "离开", lastClickTime = 0}。
-- 如果是普通点击事件，则已控件名为key，必要格式例 ：["ShuadaoButton"] = {lastClickTime = 0, note = x}
local ASSIGN_CLICK = {
    ["NpcDlg"] = {
        [CHS[3000817]] = {content = "dispatch_xiangy", lastClickTime = 0, note = "3"},  -- 通灵道人-降妖
        [CHS[3000868]] = {content = CHS[4200077], lastClickTime = 0, note = "5"},  -- 陆压真人-降妖
        [CHS[3000957]] = {content = CHS[4000448], lastClickTime = 0, note = "11"},   -- 清微真人
    },

    ["SystemFunctionDlg"] = {
        ["ShuadaoButton"] = {lastClickTime = 0, note = "1"}, -- 记录主界面刷道按钮
    },

    ["GetTaoDlg"] = {
        ["XYGoButton"] = {lastClickTime = 0, note = "2", }, -- 刷道界面，降妖前往
        ["FMGoButton"] = {lastClickTime = 0, note = "4", }, -- 刷道界面，伏魔前往
        ["FeixGoButton"] = {lastClickTime = 0, note = "10", }, -- 刷道界面， 飞仙渡邪前往
    },

    ["MissionDlg"] = {
        ["TeamCheckBox"] = {lastClickTime = 0, note = "6"}, -- 主界面队伍按钮
    },

    ["CombatViewDlg"] = {
        ["ShowDialogButton"] = {lastClickTime = 0, note = "7", }, -- 战斗查看，展开
        ["TeamBtn"] = {lastClickTime = 0, note = "8", }, -- 战斗查看，队伍
    },

    ["TeamDlg"] = {
        ["StartButton"] = {lastClickTime = 0, note = "9"}, -- 队伍，开始匹配
    },
}

-- 连续点击事件触发器，触发后，根据note走相应的事件
local CONTINUE_CLICK_TRIGGER = {
    ["NpcDlg"] = {
        [CHS[3000817]] = {content = "dispatch_xiangy", note = "1"},  -- 通灵道人-降妖
        [CHS[3000868]] = {content = CHS[4200077], note = "2"},  -- 陆压真人-降妖
        [CHS[3000957]] = {content = CHS[4000448], note = "5"},  -- 飞仙渡邪
    },

    ["CombatViewDlg"] = {
        ["ShowDialogButton"] = {note = "3"}   -- 战斗中-查看-队伍-开始匹配
    },

    ["MissionDlg"] = {
        ["TeamCheckBox"] = {note = "4"}   -- 主界面队伍按钮
    },
}

-- 连续点击事件，根据 CONTINUE_CLICK_TRIGGER中的note
local CONTINUE_CLICK_TYPE = {
    ["1"] = {
        [1] = {dlgName = "SystemFunctionDlg", clickCtrlName = "ShuadaoButton",},
        [2] = {dlgName = "GetTaoDlg", clickCtrlName = "XYGoButton"},
    },

    ["2"] = {
        [1] = {dlgName = "SystemFunctionDlg", clickCtrlName = "ShuadaoButton",},
        [2] = {dlgName = "GetTaoDlg", clickCtrlName = "FMGoButton"},
    },
    ["3"] = {
        [1] = {dlgName = "CombatViewDlg", clickCtrlName = "TeamBtn",},
        [2] = {dlgName = "TeamDlg", clickCtrlName = "StartButton"},
    },
    ["4"] = {
        [1] = {dlgName = "TeamDlg", clickCtrlName = "StartButton"},
    },
    ["5"] = {
        [1] = {dlgName = "SystemFunctionDlg", clickCtrlName = "ShuadaoButton",},
        [2] = {dlgName = "GetTaoDlg", clickCtrlName = "FeixGoButton"},
    },
}

-- 集市秒拍挂
local MARKET_CHEATER = 
{   
    -- 以下三种情况必须同时满足
    
    -- 向下翻页按钮(包括集市/收藏界面)
    [1] = {
        key = "RightButton",
        clickCtrlName = "RightButton",
        dlgName = {"MarketBuyDlg", "MarketCollectionDlg"},
    },
    
    -- 购买按钮(包括集市/收藏界面)
    [2] = {
        key = "BuyButton",
        clickCtrlName = "BuyButton",
        dlgName = {"MarketBuyDlg", "MarketCollectionDlg"},
    },
    
    -- 集市商品列表/收藏界面商品列表的第一个商品所在区域
    [3] = {
        key = "zone",
        dlgName = {"MarketBuyDlg", "MarketCollectionDlg"}
    },
    
    intervalTime = 10,
    clickCount = 10,
    lastTime = 5 * 60,
}

RecordLogMgr.isContinuing = false
RecordLogMgr.completeStep = 1
RecordLogMgr.completeType = ""


RecordLogMgr.isRecordingPosForPluginGM = false
RecordLogMgr.curPositionsForPluginGM = {}
local SAVE_PATH = Const.WRITE_PATH .. "posRecord/"
local POS_MAX_LIMIT = 10000   

-- 获取指定对话框的记录点击信息
function RecordLogMgr:sendAssignClickLog(dlgName, key)
    local rcdInfo = RecordLogMgr:getAssignDataByDlgName(dlgName)
    if not rcdInfo then return end
    rcdInfo[key].lastClickTime = gfGetTickCount()

    gf:CmdToServer("CMD_LOG_ANTI_CHEATER", {[1] = {action = "clicksomebutton", para1 = rcdInfo[key].note, para2 = gf:getServerTime(), para3 = "", memo = ""}, count = 1})
end

function RecordLogMgr:sendContinueClickLog()
    if RecordLogMgr.completeType == "" then return end
    gf:CmdToServer("CMD_LOG_ANTI_CHEATER", {[1] = {action = "specificclick", para1 = RecordLogMgr.completeType, para2 = gf:getServerTime(), para3 = "", memo = ""}, count = 1})
end

-- 获取指定对话框的记录点击信息
function RecordLogMgr:getAssignDataByDlgName(dlgName)

    if Me:queryBasicInt("level") < 45 then return end
    if not Me:isTeamLeader() then return end
    if not GetTaoMgr.scoreData or GetTaoMgr.scoreData.score < 2100 then return end
    local limitAct = ActivityMgr:getLimitActivityDataByName(CHS[3000739])
    if ActivityMgr:isCurActivity(limitAct)[1] then return end

    if not ASSIGN_CLICK[dlgName] then return end
    return ASSIGN_CLICK[dlgName]
end

-- 获取触发连续点击信息
function RecordLogMgr:getTiggerDataByDlgName(dlgName)
    if not CONTINUE_CLICK_TRIGGER[dlgName] then return end
    return CONTINUE_CLICK_TRIGGER[dlgName]
end

-- 获取触发连续点击步骤信息
function RecordLogMgr:getTiggerStepByDlgName(step)
    if RecordLogMgr.completeType == "" then return end

    if not CONTINUE_CLICK_TYPE[RecordLogMgr.completeType] or not CONTINUE_CLICK_TYPE[RecordLogMgr.completeType][step] then return end
    return CONTINUE_CLICK_TYPE[RecordLogMgr.completeType][step]
end

function RecordLogMgr:cleanContinueClick()
    RecordLogMgr.completeStep = 1
    RecordLogMgr.isContinuing = false
    RecordLogMgr.completeType = ""
end

function RecordLogMgr:tiggerStart(dlgName, key)
    local tiggerInfo = RecordLogMgr:getTiggerDataByDlgName(dlgName)
    RecordLogMgr.isContinuing = true
    RecordLogMgr.completeType = tiggerInfo[key].note
end

function RecordLogMgr:nextStep()
    RecordLogMgr.completeStep = RecordLogMgr.completeStep + 1
    if RecordLogMgr.completeStep > #CONTINUE_CLICK_TYPE[RecordLogMgr.completeType] then
        RecordLogMgr:sendContinueClickLog()
        RecordLogMgr:cleanContinueClick()
    end
end


-- 统计点击事件
function RecordLogMgr:addClickAction(mainType, subType)
    local clickInfo = self:getOneMainTypeInfo(mainType)
    if not self[mainType] then
        self[mainType] = {}
    end
    if clickInfo and clickInfo["needRecodeLog"] and clickInfo["needRecodeLog"][subType] then
        if not self[mainType].clickGoOnTimes then
            self[mainType].clickGoOnTimes = 1
            self[mainType].firstClickGoOnTime = gf:getServerTime()
            self:addOneRecode(mainType, subType)
        elseif self[mainType].clickGoOnTimes + 1 >= clickInfo["clickTimes"] then
            if gf:getServerTime() - self[mainType].firstClickGoOnTime < clickInfo["time"] * 60 then
                -- 发送指令记录
                self:addOneRecode(mainType, subType)
                self:sendLogToServer(mainType)
            end

            self[mainType].clickGoOnTimes = nil
            self[mainType].clickEvents = {}
        else
            self[mainType].clickGoOnTimes = self[mainType].clickGoOnTimes + 1
            self:addOneRecode(mainType, subType)
        end
    end
end

function RecordLogMgr:getOneMainTypeInfo(mainType)
    return RECOED_EVENT_INFO[mainType]
end

function RecordLogMgr:addOneRecode(mainType, subType)
    if not self[mainType].clickEvents then
        self[mainType].clickEvents = {}
    end

    local clickInfo = self:getOneMainTypeInfo(mainType)
    local oneClickEvent = {}
    oneClickEvent.action = mainType
    oneClickEvent.para1 = clickInfo["needRecodeLog"][subType]
    oneClickEvent.para2 = gf:getServerTime()
    oneClickEvent.para3 = ""
    oneClickEvent.memo = ""
    table.insert(self[mainType].clickEvents, oneClickEvent)
end

function RecordLogMgr:sendLogToServer(mainType)
    if not self[mainType].clickEvents then return end
    local count = #self[mainType].clickEvents
    self[mainType].clickEvents.count = count
    if count <= 0 then
        return
    end

    gf:CmdToServer("CMD_LOG_ANTI_CHEATER", self[mainType].clickEvents)
end


function RecordLogMgr:addTouchAction(mainType)
    local key = math.floor(GameMgr.curTouchPos.x) .. "," .. math.floor(GameMgr.curTouchPos.y)

    Log:D("click point:"..key)

    local touchPosInfo = self:getOneTouchInfoByMainType(mainType)

    if not self[mainType] then
        self[mainType] = {}
    end

    if not self[mainType].clickEvents then
        self[mainType].clickEvents = {}
        self[mainType].startRecordTime = gf:getServerTime()
    end


    local isExist = false
    for i = 1, #self[mainType].clickEvents do
        local oneInfo = self[mainType].clickEvents[i]
        if oneInfo.para1 == key then
            if gf:getServerTime() >=  oneInfo.lastRecordTime + touchPosInfo["oneClickInterval"] then -- 同一个点10秒需要记录
                oneInfo.count = oneInfo.count + 1
                oneInfo.lastRecordTime = gf:getServerTime()
            end
            isExist = true
            break
        end
    end

    if not isExist then
        if #self[mainType].clickEvents >= touchPosInfo["pointCount"] then
            self:removeOneTouchRecord(self[mainType].clickEvents)
        end

        self:addOneTouchRecord(mainType, key)
    end
end

function RecordLogMgr:removeOneTouchRecord(touchInfoEvents)
    local function sortTouchInfo(l, r)
        if l.count > r.count then return true end
        if l.count < r.count then return false end

        return l.lastRecordTime > r.lastRecordTime
    end

    table.sort(touchInfoEvents, sortTouchInfo)
    table.remove(touchInfoEvents, #touchInfoEvents)
end

function RecordLogMgr:addOneTouchRecord(mainType, key)
    local info = {}
    info.action = mainType
    info.para1 = key
    info.para2 = 1
    info.para3 = Const.WINSIZE.width .. "*" .. Const.WINSIZE.height
    info.memo = ""
    info.count = 1
    info.lastRecordTime = gf:getServerTime()
    table.insert(self[mainType].clickEvents, info)
end

function RecordLogMgr:setOneTouchRecordMemo(mainType, memo)
    if not self[mainType] or not self[mainType].clickEvents then return end
    local clickEvents = self[mainType].clickEvents
    local key = math.floor(GameMgr.curTouchPos.x) .. "," .. math.floor(GameMgr.curTouchPos.y)

    for i = 1, #clickEvents do
        local oneInfo = clickEvents[i]
        if oneInfo.para1 == key then
            oneInfo.memo = memo
        end
    end
end

function RecordLogMgr:getOneTouchInfoByMainType(mainType)
    return TOUCH_POS_INFO[mainType]
end

function RecordLogMgr:update()
    for k, _ in pairs(TOUCH_POS_INFO) do
        local touchPosInfo = self:getOneTouchInfoByMainType(k)
        if self[k] and gf:getServerTime() - self[k].startRecordTime >= touchPosInfo["intervalTime"] * 60 then
            self:sendTouchsLogToServer(k)
            self:cleanTouchInfo(k)
        end
    end
    
    -- 集市秒拍挂检测
    self:checkMarketCheater()
    
    -- 不使用如意刷道令长期刷道疑似外挂的行为  日志key changqsdjc_2
    if RecordLogMgr.changqiShuadaoStartTime["changqsdjc_2"] and RecordLogMgr.changqiShuadaoStartTime["changqsdjc_2"] ~= 0 then
        local isMeetTime = gfGetTickCount() - RecordLogMgr.changqiShuadaoStartTime["changqsdjc_2"] >= CHANGQI_SHUADAO_XINGWEI_TIME
        
        local count = RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"]["fum"] + RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"]["xiangy"] + RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"]["feix"]
        local isMeetTouchTime = count >= CHANGQI_SHUADAO_JC_LIMIT_TOUCH_TIMES
    
        if isMeetTime and isMeetTouchTime then
            local para1 = string.format("fum:%d,xiangy:%d,feix:%d", RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"]["fum"], RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"]["xiangy"], RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"]["feix"])
            gf:CmdToServer("CMD_LOG_ANTI_CHEATER", {[1] = {action = "changqsdjc_2", para1 = para1, para2 = "", para3 = "", memo = RecordLogMgr:getTeamGids()}, count = 1})
        end
        
        if isMeetTime then       
            RecordLogMgr.changqiShuadaoStartTime["changqsdjc_2"] = 0
            RecordLogMgr.changqiShuadaoTouchData["changqsdjc_2"] = {}
        end
    end
    
    -- 不使用如意刷道令长期刷道疑似外挂的行为  日志key changqsdjljc_1
    if RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] and RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] > 0 then
        local isMeetTime = gfGetTickCount() - RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] >= CHANGQI_SHUADAO_XINGWEI_TIME
  
        local touchTimes1 = RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["fum"] + RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["xiangy"] + RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["feix"]
        local isMeetTouchTime = touchTimes1 >= CHANGQI_SHUADAO_JLJC_LIMIT_TOUCH_TIMES
        local touchTimes2 = RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes["fum"] + RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes["xiangy"] + RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes["feix"]
        local isGetTaoDlgTimes = touchTimes2 >= CHANGQI_SHUADAO_JLJC_LIMIT_DLG_TIMES
        local isGetRewardTimes = (RecordLogMgr.getRewardTimes.fum + RecordLogMgr.getRewardTimes.xiangy + RecordLogMgr.getRewardTimes.feix) >= CHANGQI_SHUADAO_JLJC_LIMIT_TOUCH_TIMES

        if isMeetTime and isMeetTouchTime and isGetTaoDlgTimes and isGetRewardTimes then
            local para1 = string.format("fum:%d,xiangy:%d,feixdx:%d", RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["fum"], RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["xiangy"], RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"]["feix"])
            local para2 = string.format("fum:%d,xiangy:%d,feixdx:%d", RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes["fum"], RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes["xiangy"], RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes["feix"])
            gf:CmdToServer("CMD_LOG_ANTI_CHEATER", {[1] = {action = "changqsdjljc_1", para1 = para1, para2 = para2, para3 = "", memo = RecordLogMgr:getTeamGids()}, count = 1})            
        end
        
        if isMeetTime then
            RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] = 0
            RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"] = {fum = 0, xiangy = 0, feix = 0}
            RecordLogMgr.changqiShuadaoJLJCGetTaoDlgTouchTimes = {fum = 0, xiangy = 0, feix = 0}         
        end
    end
    -- 标记容错处理，时间长了设置回nil
    if self.isMeActive and gfGetTickCount() - self.isMeActive > 2000 then
        self.isMeActive = nil
    end
    
end

function RecordLogMgr:getTeamGids()
    local ret = ""
    for i = 1, TeamMgr.members_ex.count do
        if i == 1 then
            ret = string.format("team_leader:%s,team_gid:{", TeamMgr.members_ex[1].gid)
        else
            ret = ret .. TeamMgr.members_ex[i].gid
            
            if i == TeamMgr.members_ex.count then
                ret = ret .. "}"
            else
                ret = ret .. ","
            end
        end
    end
    
    return ret
end

-- 集市秒拍挂检测
function RecordLogMgr:checkMarketCheater()
    -- 如果连续5分钟每10秒都会产生“异常”，则认为是集市秒拍挂
    -- 异常必须满足一下以下所有情况：集市和收藏的向下翻页按钮/购买按钮点击超过10次，集市商品列表第一个商品所在区域（没有商品时的空白区域点击也算）超过10次
    if not self.marketCheaterData then
        self.marketCheaterData = {}
    end
    
    local nowTime = gf:getServerTime()
    if not self.marketCheaterLastRecordTime then
        self.marketCheaterLastRecordTime = nowTime
    end
    
    if nowTime - self.marketCheaterLastRecordTime > MARKET_CHEATER.intervalTime then
        -- 判断这10秒是否产生了异常
        local isCheaterInIntervalTime = self:isMarketCheaterInIntervalTime()
        
        -- 保存这10秒异常的结果，最多只保存近5分钟数据
        local maxDataNum = MARKET_CHEATER.lastTime / MARKET_CHEATER.intervalTime
        if #self.marketCheaterData >= maxDataNum then
            table.remove(self.marketCheaterData, 1)
        end
        
        if isCheaterInIntervalTime then
            table.insert(self.marketCheaterData, 1)
        else
            table.insert(self.marketCheaterData, 0)
        end
        
        -- 清除这10秒的数据，准备存储下10秒的数据
        self.marketCheaterLastRecordTime = nowTime
        self.marketCheaterClickTimesData = {}
        
        -- 判断近5分钟是否每个10秒都产生异常
        if #self.marketCheaterData == maxDataNum then
            local cheaterTimesInSum = 0
            for i = 1, #self.marketCheaterData do
                cheaterTimesInSum = cheaterTimesInSum + self.marketCheaterData[i]
            end
            
            if cheaterTimesInSum == maxDataNum then
                -- 满足集市秒拍挂的判定条件，向服务器发日志
                gf:CmdToServer("CMD_LOG_ANTI_CHEATER", {[1] = {action = "jismpg"}, count = 1})
                
                -- 重置相关数据
                self.marketCheaterData = {}
            end
        end
    end
end

function RecordLogMgr:getMarketCheaterCtrlInfo(dlgName)
    local ctrlTable = {}
    for i = 1, #MARKET_CHEATER do
        local dlgs = MARKET_CHEATER[i].dlgName
        local ctrlName = MARKET_CHEATER[i].clickCtrlName
        if dlgs and ctrlName then
            for j = 1, #dlgs do
                if dlgName == dlgs[j] then
                    ctrlTable[ctrlName] = ctrlName
                end
            end
        end
    end
    
    return ctrlTable
end

function RecordLogMgr:setMarketCheaterClickTimesData(key, dlgName)
    -- 如果对话框名不匹配，则为无效数据
    local isValidData = false
    for i = 1, #MARKET_CHEATER do
        if MARKET_CHEATER[i].key == key then
            local dlgs = MARKET_CHEATER[i].dlgName
            for j = 1, #dlgs do
                if dlgs[j] == dlgName then
                    isValidData = true
                end
            end
        end
    end
    
    if not isValidData then
        return
    end
    
    if not self.marketCheaterClickTimesData then
        self.marketCheaterClickTimesData = {}
    end
    
    if self.marketCheaterClickTimesData[key] then
        self.marketCheaterClickTimesData[key] = self.marketCheaterClickTimesData[key] + 1
    else
        self.marketCheaterClickTimesData[key] = 1
    end
end

function RecordLogMgr:isMarketCheaterInIntervalTime()
    if not self.marketCheaterClickTimesData then
        return false
    end
    
    for i = 1, #MARKET_CHEATER do
        local key = MARKET_CHEATER[i].key
        local clickCountOfKey = self.marketCheaterClickTimesData[key]
        if not clickCountOfKey or clickCountOfKey < MARKET_CHEATER.clickCount then
            return false
        end
    end
    
    return true
end

function RecordLogMgr:sendTouchsLogToServer(mainType)
    if not self[mainType].clickEvents or Me:isInJail() then return end  -- 坐天牢不发送记录
    local touchPosInfo = self:getOneTouchInfoByMainType(mainType)
    local clickEvents = {}
    for i = 1, #self[mainType].clickEvents do
        local info = self[mainType].clickEvents[i]
        if info.count >= touchPosInfo["clickCount"] then
            info.para2 = info.count
            table.insert(clickEvents, info)
        end
    end

    self[mainType].clickEvents = nil
    self[mainType].clickEvents = clickEvents
    self:sendLogToServer(mainType)
end

function RecordLogMgr:cleanTouchInfo(mainType)
    self[mainType] = nil
end

function RecordLogMgr:sendAllTouchLog()
    for k,v in pairs(TOUCH_POS_INFO) do
        self:sendTouchsLogToServer(k)
    end
end

function RecordLogMgr:cleanup()
    for k,v in pairs(RECOED_EVENT_INFO) do
        if self[k] then
            self[k].clickGoOnTimes = nil
            self[k].clickEvents = {}
        end
    end

    for k,v in pairs(TOUCH_POS_INFO) do
        self:cleanTouchInfo(k)
    end

    -- 退回登录界面，gfGetTickCount() 会被重置，故就的时间数据也要清除
    for _, info in pairs(ASSIGN_CLICK) do
        for _, v in pairs(info) do
            v.lastClickTime = 0
        end
    end
    
    self:endCGPluginOnce()
end

-- 开始记录。清空表，设置状态
function RecordLogMgr:startRocordPos()
    RecordLogMgr.isRecordingPosForPluginGM = true
    RecordLogMgr.curPositionsForPluginGM = {}
end

function RecordLogMgr:addPosForPosRecordCtrlName(str)
    if not RecordLogMgr.isRecordingPosForPluginGM then return end
    if not RecordLogMgr.curPositionsForPluginGM or not next(RecordLogMgr.curPositionsForPluginGM) then return end
    
    local index = #RecordLogMgr.curPositionsForPluginGM 
    if RecordLogMgr.curPositionsForPluginGM[index] then
        RecordLogMgr.curPositionsForPluginGM[index] = RecordLogMgr.curPositionsForPluginGM[index] .. ";" .. str
    end
end

-- 增加一个记录点
function RecordLogMgr:addPosForPosRecord(pos)
    if not RecordLogMgr.isRecordingPosForPluginGM then return end
    
    local posStr = math.floor(pos.x) .. "," .. math.floor(pos.y) .. ";" .. os.time() .. ";" .. os.date("%d日%H时%M分%S秒", os.time())
    table.insert(RecordLogMgr.curPositionsForPluginGM, posStr)
    if #RecordLogMgr.curPositionsForPluginGM >= POS_MAX_LIMIT then
        DlgMgr:closeDlg("RecordPosDlg")
        RecordLogMgr:endOnceRecord()        
    end
    
 
    RecordLogMgr:addPosEffrct( pos.x, pos.y)
end

function RecordLogMgr:addPosEffrct(x, y)
    if not self.image then
        -- 创建image
        self.image = ccui.ImageView:create(ResMgr.ui.touch_pos)
        self.image:retain()  
    end
    
    self.image:removeFromParent()
    self.image:stopAllActions()

    -- 闪烁动作
    local blink = cc.Blink:create(2, 7)
    self.image:runAction(blink)

    -- 设置位置，放进先关场景
    self.image:setPosition(x, y)
    
    gf:getTopLayer():addChild(self.image)

    performWithDelay(self.image, function ()
        self.image:removeFromParent()
        
        local dlg = DlgMgr:getDlgByName("RecordPosDlg")
        if not dlg then
            self.image:stopAllActions()
            self.image:release()
            self.image = nil
        end
        
    end, 2)
end

function RecordLogMgr:getPosRecordFile(fileName)
    local allInfoFullPath, path = RecordLogMgr:getFileNamePath(fileName)
    local allInfoTab = {}
    if cc.FileUtils:getInstance():isFileExist(allInfoFullPath) then
        allInfoTab = dofile(allInfoFullPath)
    end
    
    return allInfoTab
end

function RecordLogMgr:endOnceRecord()
    RecordLogMgr.isRecordingPosForPluginGM = false

    local curFileName = os.date("%Y%m%d%H%M%S", gf:getServerTime())
    local curTime = os.date("%Y%m%d%H%M%S", os.time())
    -- 目录下保存
    local allInfoFullPath, path = RecordLogMgr:getFileNamePath("fileName")
    local allInfoTab = RecordLogMgr:getPosRecordFile("fileName")
    table.insert(allInfoTab, curTime)
    self:saveFileByTab(allInfoTab, path)
    
    -- 保存记录点文件
    local posFullPath, posPath = RecordLogMgr:getFileNamePath(curTime)
    self:saveFileByTab(RecordLogMgr.curPositionsForPluginGM, posPath)
    
    local tipMsg = string.format(CHS[4400016], curTime, posPath)
    gf:ShowSmallTips(tipMsg)
    ChatMgr:sendMiscMsg(tipMsg)    
    DlgMgr:openDlg("GMManageDlg")
end

function RecordLogMgr:saveFileByTab(destTab, filePath)
    local control = ""
    for _, value in pairs(destTab) do
        control = control .. "'" .. value .. "'" .. ",\n"
    end
    
    local info1 = CHS[4300228] -- "-- 格式说明 'x,y;time1;time2;dlgName:ctrl'",
    local info2 = CHS[4300229] -- "\n-- x,y 对应的坐标"
    local info3 = CHS[4300230] -- "\n-- time1 时间戳； time2时间戳对应的日期"
    local info4 = CHS[4300231] -- "\n-- dlgName:ctrl  对话框：控件名    如果点击的地方没有绑定相关点击事件，则为空"
    local info5 = CHS[4300232] -- "\n-- 对话框控件对应的绑定事件可能不全，需求再提"
    local ret = info1 .. info2 .. info3 .. info4 .. "\nreturn {\n" .. control
    ret = ret .. "}"
    gfSaveFile(ret, filePath)
end

function RecordLogMgr:getFileNamePath(fileName)
    local gid = Me:queryBasic("gid")
    local fullPath = cc.FileUtils:getInstance():getWritablePath() .. SAVE_PATH .. gid .. "/" .. fileName .. ".lua"
    local path = SAVE_PATH .. gid .. "/" .. fileName .. ".lua"
    return fullPath, path 
end

function RecordLogMgr:MSG_TASK_PROMPT(data)    
    -- 如果只是刷新任务信息，那 self.changqsdjc_2Pos == nil
    if not self.changqsdjc_2Pos then return end

    local function changqsdjljc_1(key)
        if not self.isMeActive then return end
        if not RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] or RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] == 0 then return end
        
        if RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] == -1 then
            RecordLogMgr:changqsdjljcStart()          
        end 

        RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"][key] = RecordLogMgr.changqiShuadaoTouchData["changqsdjljc_1"][key] + 10
    end

    for i = 1, data.count do
        if data[i].task_type == CHS[4000291] then
            local times = string.match(data[i].show_name, "(%d+)")
            if times == "1" then
                changqsdjljc_1("fum")
                                
                -- changqsdjc_2
                RecordLogMgr:paraChangqsdjc("fum")
            end
        elseif data[i].task_type == CHS[4000290] then
            local times = string.match(data[i].show_name, "(%d+)")
            if times == "1" then
                changqsdjljc_1("xiangy")
                                 
                -- changqsdjc_2
                RecordLogMgr:paraChangqsdjc("xiangy")
            end
        elseif data[i].task_type == CHS[4000444] then
            local times = string.match(data[i].show_name, "(%d+)")
            if times == "1" then
                changqsdjljc_1("feix")

                RecordLogMgr:paraChangqsdjc("feix")
            end
        end
    end
    
    RecordLogMgr:setChangqsdjc_2TouchPos()
    self.isMeActive = false
end

function RecordLogMgr:MSG_SHUADAO_BONUS_TYPE(data)
    if not RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] or RecordLogMgr.changqiShuadaoStartTime["changqsdjljc_1"] <= 0 then return end
    if data.bonus_type == "fum" then        
        RecordLogMgr.getRewardTimes.fum = RecordLogMgr.getRewardTimes.fum + 1     
    elseif data.bonus_type == "feixdj" then   
        RecordLogMgr.getRewardTimes.feix = RecordLogMgr.getRewardTimes.feix + 1
    else
        RecordLogMgr.getRewardTimes.xiangy = RecordLogMgr.getRewardTimes.xiangy + 1
    end    
end

MessageMgr:regist("MSG_SHUADAO_BONUS_TYPE", RecordLogMgr)
MessageMgr:hook("MSG_TASK_PROMPT", RecordLogMgr, "RecordLogMgr")

return RecordLogMgr