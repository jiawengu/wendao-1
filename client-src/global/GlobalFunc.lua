-- created by cheny Oct/14/2014
-- 全局函数

require("bitExtend")
local StringBuilder = require "core/StringBuilder"
local Magic = require('animate/Magic')
local ItemInfo = require ("cfg/ItemInfo")
local has8DirIcon = require("cfg/has8dirIcon")
local SmallAttrTip = require("ctrl/SmallAttrTip")
local idReginCode = require("cfg/IdRegionCode")
local NpcMenuOrder = require("cfg/NpcMenuOrder.lua")
local FightNeedCloseDlg = require("cfg/FightNeedCloseDlg.lua")
local List = require("core/List")
local json = require("json")

-- 2 的 32 次方
local I2POW32 = 2 ^ 32

local ONE_DAY = 24 * 60 * 60

local ONE_HOUR = 60 * 60

-- 用于计算平均移动时间的帧数
local MOVE_COUNT = 9

-- 单帧最小的时间
local MIN_FRAME_TIME = math.floor(1000 / Const.FPS)

-- 单帧最大的时间
local MAX_FRAME_TIME = 70

gf = {}

local CHAR_ACTIONS = {"stand", "walk", "attack", "defense", "parry", "cast", "die", "baibai", "yongbao",
    "jiaobei", "qinqin", "snuggle", "show", "bow", "clean", "stand2", "sit", "eat", "stand3", "stand4", "attack2", "flapping", "throw", "cry"}
local CHAR_STR2ACTIONS = {}

local function initCharAction()
    for i, v in ipairs(CHAR_ACTIONS) do
        CHAR_STR2ACTIONS[v] = i - 1
    end
end
initCharAction()

-- 判断是否有错误,否则捕获并抛出走正常流程
function catch(func, callback)
    local s, e = xpcall(func, __G__TRACKBACK__)
    if not s then
        if callback and "function" == type(callback) then
            callback()
        end
    end
end

local function _formatValue(v)
    if 'string' == type(v) then
        if 'function' == type(gfConvertToCString) and 'function' == type(gfConvertBufferToString) and #v > #gfConvertToCString(v) then
            -- buffer
            return string.format("%s", gfConvertBufferToString(v))
        else
            return string.format("'%s'", tostring(v))
        end
    else
        return tostring(v)
    end
end

local function indent(c)
    local indent = ""
    for k = 1, c do
        indent = indent .. "    "
    end
    return indent
end

function tostringex(v, m, i, l)
    if not m then m = {} end
    if nil == i then i = 1 end
    local ret = ""
    l = l or 3

    if m[v] then
        ret = m[v]
    elseif type(v) == "table" then
        local t = ""
        m[v] = _formatValue(v)
        for k, v1 in pairs(v) do
            if type(v1) ~= 'function' then
                if i < l then
                    t = t .. indent(i) .. tostring(k) .. ":" .. tostringex(v1, m, i + 1, l) .. ',\n'
                else
                    t = t .. indent(i) .. tostring(k) .. ":" .. _formatValue(v1) .. ',\n'
                end
            end
        end
        ret = "\n" .. indent(i - 1) .. "{\n" .. t .. indent(i - 1) .. "}"
    else
        ret = _formatValue(v)
    end

    return ret
end

-- 发送命令给服务器
function gf:CmdToServer(cmd, data, type)
    Client:pushDebugInfo(string.format("CmdToServer:%s   %s", cmd,  inspect(data)))
    local conn = CommThread:getConnection(type)
    if conn ~= nil then
        conn:sendCmdToServer(cmd, data)
    end

    -- 尝试记录战斗中的消息
    DebugMgr:recordFightMsg(cmd, data)
end

-- 发送aaa命令
function gf:CmdToAAAServer(cmd, data, type)
    local conn = CommThread:getConnectionAAA(type)
    if conn ~= nil then
        conn:sendCmdToServer(cmd, data)
    end
end

function gf:SendCmd(data)
    local cmd = data.CMD
    if nil == cmd then return end
    gf:CmdToServer(cmd,data)
end

-- 递归输出map
function gf:PrintMap(map)
    local function printMap(map, key, level)
        if nil == map then
            Log:D("null mapping.")
            return
        end

        level = level or 0
        local buf = StringBuilder.new()
        if (level > 0) then
            buf:add(string.rep("----", level))
            buf:add(" " .. tostring(key) .. "=")
        end
        buf:add("{ ")
        for k, v in pairs(map) do
            if type(v) == "string" or type(v) == "number" then
                buf:add(k .. "=" .. v .. ", ")
            elseif type(v) == "boolean" then
                buf:add(k .. "=" .. tostring(v) .. ", ")
            elseif type(v) == "table" then
                printMap(v, k, level + 1)
            end
        end
        buf:add(" }")
        Log:D("%s", buf:toString())
    end
    printMap(map)
end

-- 发送通用的通知命令
function gf:sendGeneralNotifyCmd(notifyType, para1, para2)

    gf:CmdToServer('CMD_GENERAL_NOTIFY', {
        type  = notifyType,
        para1 = tostring(para1 or ""),
        para2 = tostring(para2 or "")
    })
end

-- 计算两点距离
function gf:distance(x1,y1, x2,y2)
    return math.sqrt((x1-x2)*(x1-x2) + (y1-y2)*(y1-y2))
end

-- 判断两点的偏移是否满足要求
function gf:inOffset(x1, y1, x2, y2, offset)
    local ptOffset = math.max(math.abs(x1 - x2), math.abs(y1 - y2))

    return ptOffset <= offset
end

function gf:isOutDistance(x1, y1, x2, y2, dis)
    return (x1-x2)*(x1-x2) + (y1-y2)*(y1-y2) > dis * dis
end

-- 向量归一化
function gf:Normalize(x, y)
    local dist = gf:distance(0,0, x,y)
    if dist == 0 then return 0,0 end
    return x/dist, y/dist
end

-- 判断点是否在note内部
function gf:IsInside(node, x, y)
    local pt = node:getParent():convertToNodeSpace(CCPoint(x, y))
    return node:boundingBox():containsPoint(pt)
end

-- 是否为 GD
function gf:isGD()
    return Me:queryBasicInt("privilege") >= PRIVILEGE.DEBUGGER
end

-- 设置 me 为 GD
function gf:setMeAsGD()
    Me:setBasic("privilege", PRIVILEGE.DEBUGGER)
end

-- 主循环调度
function gf:Schedule(func, interval)
    interval = interval or 0
    local scheduler = cc.Director:getInstance():getScheduler()
    return scheduler:scheduleScriptFunc(func, interval, false)
end

-- 取消主循环调度
function gf:Unschedule(entryId)
    local scheduler = cc.Director:getInstance():getScheduler()
    scheduler:unscheduleScriptEntry(entryId)
end

function gf:ShowSmallTips(strUTF8)
    SmallTipsMgr:addTip(strUTF8)
end

-- 显示属性提示信息
function gf:ShowAttrSmallTips(attrData)
    local tip = SmallAttrTip:create()
    tip:addTip(attrData)
end

-- 获取顶层场景
function gf:GetTopScene()
    return tolua.cast(gfGetTopScene(), "cc.Scene")
end

-- 获取下一个场景
function gf:GetNextScene()
    return tolua.cast(gfGetNextScene(), "cc.Scene")
end

-- 检测当前状态是否可以退出
function gf:CheckCanLogout()
    if GAME_RUNTIME_STATE.LOGINING == GameMgr:getGameState() then
        return false
    end

    return true
end

function gf:isLockScreen()
    if DlgMgr:isDlgOpened("LockScreenDlg") then
        return true
    end

    return false
end

-- 结束游戏
function gf:EndGameEx()
    if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() or GameMgr.isStop then
        return
    end

    if GameMgr.isAntiCheat then
        gf:ShowSmallTips(CHS[2000085])
        return
    end

    if DlgMgr:isDlgOpened("BiggerConfirmDlg") then -- 如果有免责确认不弹出退出确认框
        return
    end

	-- CG外挂记录
    RecordLogMgr:endCGPluginOnce()

    -- 有些渠道不需要弹出游戏的退出框
    if LeitingSdkMgr:needNotShowGameQuitDlg() then
        -- 要调用渠道的退出接口
        LeitingSdkMgr:quit()
        return
    end

    local dlg = DlgMgr.dlgs["ConfirmDlg"]
    if dlg and dlg.root:getTag() == CONFIRM_TYPE.EXIT_GAME then
        DlgMgr:closeDlg("ConfirmDlg")
    else
        if not gf:CheckCanLogout() then
            return
        end

        if gf:isLockScreen() then
            local dlg = DlgMgr.dlgs["LockScreenDlg"]
            dlg:showTipImage()
            return
        end

        if gf:isAndroid() or gf:isWindows() then
            dlg = gf:confirm(CHS[3003803], function()
                if gf:isWindows() then
                    gf:EndGame(LOGOUT_CODE.LGT_ESC_QUIT)
                else
                    LeitingSdkMgr:quit()
                end
            end, nil, nil, nil, CONFIRM_TYPE.EXIT_GAME)
            if dlg then
                dlg:setGlobalZorder(Const.ZORDER_TOPMOST + 1)
            end
        end
    end
end

-- 结束游戏
function gf:EndGame(code)
    if GAME_RUNTIME_STATE.QUIT_GAME == GameMgr:getGameState() then
        return
    end

    gf:CmdToServer("CMD_LOGOUT", {reason = code})
    CommThread:stop()

    -- 开始推送
    LocalNotificationMgr:addAllNotification()

    DlgMgr:openDlg("WaitDlg")

    onDestroyGame(true)
end

function gf:getStringChar(str, idx)
    return string.char(string.byte(str,idx))
end

-- 根据UTF8编码第一个字节，获取一个UTF8字符所占字节数
function gf:getUTF8Bytes(ch)
    if ch < 0xC0 then return 1
    elseif ch >= 0xC0 and ch < 0xE0 then return 2
    elseif ch >= 0xE0 and ch < 0xF0 then return 3
    elseif ch >= 0xF0 and ch < 0xF8 then return 4
    elseif ch >= 0xF8 and ch < 0xFC then return 5
    else return 6 end
end

-- 是否是UTF8编码的第一个字节
function gf:isUTF8FirstChar(ch)
    return ch >= 0xC0
end

-- 是否是UTF8编码的末字节
function gf:isUTF8LastChar(ch)
    return ch > 0x80 and ch < 0xC0
end

-- 角色是否存在
function gf:isCharExist(icon)
    local file = ResMgr:getCharCartoonPath(icon)

    if (cc.FileUtils:getInstance():isFileExist(file) or cc.FileUtils:getInstance():isFileExist(gf:getFileName(file) .. ".luac")) then
        return true
    end

    local IconColorScheme = require(ResMgr:getCfgPath("IconColorScheme.lua"))
    if IconColorScheme[icon] then
        icon = IconColorScheme[icon].org_icon
        file = ResMgr:getCharCartoonPath(icon)
        if (cc.FileUtils:getInstance():isFileExist(file) or cc.FileUtils:getInstance():isFileExist(gf:getFileName(file) .. ".luac")) then
            return true
        end
    end

    return false
end

-- load  lua文件，不存在返回nil 。直接require(path)，如果文件不存在会卡很久
function gf:loadLuaFile(path)
    local file = nil
    if pcall(function() file = require(path) end) then

    end

    return file
end

-- 将lua的table转换为CUtilMapping（不推荐使用，推荐使用gf:ConvertToUtilMappingN）
function gf:ConvertToUtilMapping(map)
    local ret = CUtilMapping:create()
    if map ~= nil then
        for k, v in pairs(map) do
            if type(k) == "string" and (type(v) == "string" or type(v) == "number") then
                if type(v) == "number" and v < 0 then
                    v = gf:uint(v)
                end

                ret:Set(k, v)
            end
        end
    end
    return ret
end

-- 将lua的table转换为CUtilMapping（推荐使用）
function gf:ConvertToUtilMappingN(map)
    local ret = CUtilMapping:create()
    if map ~= nil then
        for k, v in pairs(map) do
            if type(k) == "string" then
                if type(v) == "string" then
                    ret:SetString(k, v)
                elseif type(v) == "number" then
                    if v < 0 then
                        v = gf:uint(v)
                    end

                    ret:SetInt(k, v)
                end
            end
        end
    end

    return ret
end

-- 通过字符串调用函数"global_func" or "class:func"
function gfCallFunc(funcname, para)
    if nil == funcname or type(funcname) ~= "string" then
        return ""
    end

    local function temp()
        local pos = gf:findStrByByte(funcname, ':')
        local func = nil
        local class = nil
        if pos ~= nil then
            -- 调用类函数
            class = _G[string.sub(funcname, 1, pos - 1)]
            if class ~= nil then
                func = class[string.sub(funcname, pos + 1, -1)]
            end
        else
            -- 调用全局函数
            func = _G[funcname]
        end
        if nil == func then
            Log:W("Call " .. funcname .. " error.")
        else
            if class ~= nil then
                return func(class, para)
            else
                return func(para)
            end
        end

        return 0
    end
    local r1, r2 = xpcall(temp, __G__TRACKBACK__)
    if not r2 then r2 = 0 end

    -- C++ 层是按 string 来取的，所以要转一下
    return tostring(r2)
end

function gfCallFuncEx(funcname, ...)
    if nil == funcname or type(funcname) ~= "string" then
        return ""
    end

    local arg = { ... }

    local function temp()
        local pos = gf:findStrByByte(funcname, ':')
        local func = nil
        local class = nil
        if pos ~= nil then
            -- 调用类函数
            class = _G[string.sub(funcname, 1, pos - 1)]
            if class ~= nil then
                func = class[string.sub(funcname, pos + 1, -1)]
            end
        else
            -- 调用全局函数
            func = _G[funcname]
        end
        if nil == func then
            Log:W("Call " .. funcname .. " error.")
        else
            if class ~= nil then
                return func(class, arg[1], arg[2], arg[3], arg[4], arg[5], arg[6])
            else
                return func(arg[1], arg[2], arg[3], arg[4], arg[5], arg[6])
            end
        end

        return 0
    end
    local r1, r2 = xpcall(temp, __G__TRACKBACK__)
    if not r2 then r2 = 0 end

    -- C++ 层是按 string 来取的，所以要转一下
    return tostring(r2)
end

function gf:getDirStr(dir)
    local dirMap = {
        CHS[5450358],
        CHS[5450359],
        CHS[5450352],
        CHS[5450353],
        CHS[5450354],
        CHS[5450355],
        CHS[5450356],
        CHS[5450357],
    }

    return dirMap[dir + 1]
end

-- 计算方向
function gf:defineDir(from, to, icon)
    local has8Dir = gf:has8Dir(icon)
    if not has8Dir then
        -- 无 8 方向的均为 4 方向，与宠物一样
        return gf:defineDirForPet(from, to)
    end

    local radian = cc.pToAngleSelf(cc.pSub(to, from))
    local dir = math.floor((math.pi - radian) / math.pi * 4 + 0.5) % 8
    return dir
end

-- 计算宠物的方向
function gf:defineDirForPet(from, to)
    local radian = cc.pToAngleSelf(cc.pSub(to, from))
    local dir = math.floor((math.pi - radian) / math.pi * 2) % 4
    return dir * 2 + 1
end

-- 获取天气动画层
function gf:getWeatherAnimLayer()
    return GameMgr.weatherAnimLayer
end

-- 获取天气层
function gf:getWeatherLayer()
    return GameMgr.weatherLayer
end

-- 获取地图层
function gf:getMapLayer()
    return GameMgr.mapLayer
end

-- 获取地图背景层
function gf:getMapBgLayer()
    return GameMgr.mapBgLayer
end

-- 获取地表物件层
function gf:getMapObjLayer()
    return GameMgr.mapObjLayer
end

-- 获取地表摆放层
function gf:getPuttingObjLayer()
    return GameMgr.puttingObjLayer
end

-- 获取地表动画层
function gf:getMapEffectLayer()
    return GameMgr.mapEffectLayer
end

-- 获取角色层
function gf:getCharLayer()
    return GameMgr.charLayer
end

-- 获取角色底层
function gf:getCharBottomLayer()
    return GameMgr.charBottomLayer
end

-- 获取角色中间层
function gf:getCharMiddleLayer()
    return GameMgr.charMiddleLayer
end

-- 获取角色顶层
function gf:getCharTopLayer()
    return GameMgr.charTopLayer
end

-- 获取顶层，检测点击事件
function gf:getTopLayer()
    return GameMgr.topLayer
end

-- 获取 UI 层
function gf:getUILayer()
    return GameMgr.uiLayer
end

-- 获取角色动画名称
function gf:getActionStr(act)
    if act == nil or act <= Const.SA_NONE or act >= Const.SA_NUM then
        return nil
    end
    return CHAR_ACTIONS[act + 1]
end

function gf:getActionByStr(actStr)
    if string.isNilOrEmpty(actStr) then return end

    return CHAR_STR2ACTIONS[actStr]
end

-- 获取某个模型的所有动作
function gf:getAllActionByIcon(icon, excepts)
    local cartoonInfo = require(ResMgr:getCharCartoonPath(icon)) or {}
    local actions = {}
    for k, _ in pairs(cartoonInfo) do
        local act = self:getActionByStr(k)
        if not excepts or not excepts[act] then
            table.insert(actions, act)
        end
    end

    return actions
end

-- 将地图坐标(mapX, mapY)转换为客户端显示时使用的坐标
function gf:convertToClientSpace(mapX, mapY)
    return mapX * Const.PANE_WIDTH + Const.PANE_WIDTH / 2, GameMgr:getSceneHeight() - mapY * Const.PANE_HEIGHT - Const.PANE_HEIGHT / 2
end

-- 将客户端显示时使用的坐标转换为地图坐标
function gf:convertToMapSpace(x, y)
    return math.floor(x / Const.PANE_WIDTH), math.floor((GameMgr:getSceneHeight() - y) / Const.PANE_HEIGHT)
end

function gf:convertToMapSpaceEx(x, y)
    return math.floor(x / Const.PANE_WIDTH + 0.5), math.floor((GameMgr:getSceneHeight() - y) / Const.PANE_HEIGHT + 0.5)
end

-- 获取场景中的对象的 zorder
function gf:getObjZorder(y)
    return GameMgr:getSceneHeight() - y
end

function gf:hasBrow(key)
    -- vip表情
    if tonumber(key) then
        if tonumber(key) >= Const.VIPBROW_STARTINDEX and tonumber(key) <= Const.VIPBROW_ENDINDEX then
            return 1
        end
    end

    local cartoon = require "brow/Cartoon.lua"
    local brow = cartoon[key]
    if brow == nil then
        return 0
    else
        return 1
    end
end

function gf:isVipExpression()

end

--
function gf:replaceVipStr(str)
    if GameMgr.isIOSReview then
        str = string.gsub(str, CHS[3003804], CHS[3003805])
        str = string.gsub(str, CHS[3003806], CHS[3003807])
        str = string.gsub(str, CHS[3003808], CHS[3003809])
    end

    return str
end

function gf:getVipStr(level, leftTime)
    local leftStr = ""
    local leftTime = gf:uint(leftTime)
    if leftTime and leftTime - gf:getServerTime() > 0 then
        leftStr = string.format(CHS[4000408], math.ceil((leftTime - gf:getServerTime()) / ONE_DAY))
    elseif leftTime and leftTime - gf:getServerTime() <= 0 then
		-- 当有剩余时间，并且剩余时间小于0。则当做过期，直接返回 "无"
        return CHS[5000059]
    end

    local str = CHS[5000059]
    if level == 1 then
        str = CHS[3001790] .. leftStr
    elseif level == 2 then
        str = CHS[3001793] .. leftStr
    elseif level == 3 then
        str = CHS[3001796] .. leftStr
    end
    return str
end

-- 输出到聊天窗口
function gf:logToChatDlg(strContent)
    local dlg = DlgMgr:getDlgByName("ChatDlg")

    if dlg then
        local data = {}
        data.chatStr = "#ichannel/ChannelIcon0001.png#i[DEBUG_INFO]" .. strContent
        data.show_extra = false
        table.insert(dlg.chatTabel, data)
        dlg:loadInitData()
    end
end

function gf:getBrowInterval(key)
    -- vip表情
    if tonumber(key) then
        if tonumber(key) >= Const.VIPBROW_STARTINDEX and tonumber(key) <= Const.VIPBROW_ENDINDEX then
            return 200
        end
    end

    local cartoon = require "brow/Cartoon.lua"
    local brow = cartoon[key]
    if brow == nil then
        return ""
    else
        return tonumber(brow.rate) or 200
    end
end

-- 创建骨骼动画
-- icon
-- actName 播放动作名称
-- panel 需要add的panel
-- callback 动画播放完成的回调
-- cbPara 回调的参数
function gf:createArmatureOnceMagic(icon, actName, panel, callback, dlg, cbPara, posX, posY, zOrder)

    local magic = ArmatureMgr:createArmature(icon)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
            magic = nil

            if callback and "function" == type(callback) then callback(dlg, cbPara) end
        end
    end
    magic:setName(actName)
    panel:addChild(magic)
    local size = panel:getContentSize()
--    magic:setAnchorPoint(0.5, 0.5)
    posX = posX or size.width * 0.5
    posY = posY or size.height * 0.5
    magic:setPosition(posX, posY)
    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(actName)
    if zOrder then
        magic:setLocalZOrder(zOrder)
    end
    return magic
end

-- 创建循环播放骨骼动画
-- 粒子名称，particle.name:动画名，particle.action:动作名
-- ctrl 需要add的控件
-- resTag 动画资源标记，有些需要在特定情况下通过标记移除动画
-- pX, pY 设置的位置，与锚点配合调整位置
function gf:createArmatureMagic(particle, ctrl, resTag, pX, pY)
    if ctrl:getChildByTag(resTag) then
        -- 如果光效已存在，不重新创建
        return
    end

    if not pX then
        pX = 0
    end

    if not pY then
        pY = 0
    end

    local magic = ArmatureMgr:createArmature(particle.name)
    local ctrlSize = ctrl:getContentSize()
    local pos = cc.p(ctrlSize.width / 2 + pX, ctrlSize.height / 2 + pY)
    magic:setPosition(pos)
    ctrl:addChild(magic)
    magic:getAnimation():play(particle.action)
    magic:setTag(resTag)

    return true
end

-- 创建循环播放的光效
function gf:createLoopMagic(icon, magicType, extraPara)
    return Magic.new(icon, nil, magicType, extraPara)
end

-- 创建播放完成后自动释放的光效
function gf:createSelfRemoveMagic(icon, extraPara)
    return Magic.new(icon, true, nil, extraPara)
end

-- 创建播放完成后执行回调函数的光效
function gf:createCallbackMagic(icon, callback, extraPara)
    return Magic.new(icon, callback, nil, extraPara)
end

-- 绑定长按事件
function gf:bindLongTouchListener(node, OneSecondLaterFunc, clickFun)
    if type(node) ~= "userdata" then
        return
    end

    if not node then
        Log:W("Dialog:bindListViewListener no control " .. self.name)
        return
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.began then

            local callFunc = cc.CallFunc:create(function()
                node:stopAction(node.longPress)
                node.longPress = nil
                if not sender:isHighlighted() then
                    -- 会响应 canceled 事件，不处理长按回调
                    return
                end


                OneSecondLaterFunc(node, sender, eventType)
            end)
            self.node =node
            node.longPress = cc.Sequence:create(cc.DelayTime:create(GameMgr:getLongPressTime()),callFunc)
            node:runAction(node.longPress)
        elseif eventType == ccui.TouchEventType.ended then
            if node.longPress ~= nil then
                node:stopAction(node.longPress)
                node.longPress = nil
                if type(clickFun) == "function" then
                    clickFun(self, sender, eventType)
                    return
                end
            end
        elseif eventType == ccui.TouchEventType.canceled then
            if node.longPress ~= nil then
                node:stopAction(node.longPress)
                node.longPress = nil
            end
        end
    end

    node:addTouchEventListener(listener)
end

-- 绑定触摸事件
function gf:bindTouchListener(node, func, event, isNotSwallow)
    if nil == node or nil == func then return end

    local listener = cc.EventListenerTouchOneByOne:create()

    if isNotSwallow then
        listener:setSwallowTouches(false) -- 开启事件始终往后传递
    else
        listener:setSwallowTouches(true) -- 允许 began 事件中返回 true 时将事件吞掉
    end
    listener:registerScriptHandler(func, cc.Handler.EVENT_TOUCH_BEGAN)
    if event ~= nil then
        if type(event) == "number" then
            listener:registerScriptHandler(func, event)
        elseif type(event) == "table" then
            for k, v in pairs(event) do
                listener:registerScriptHandler(func, v)
            end
        end
    end
    local dispatcher = node:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, node)
end

-- 发送战斗命令
function gf:sendFightCmd(acterId, victimId, actionType, para, para1, para2, para3)
    if Me:queryBasicInt('c_enable_input') == 0 then return end
    if FIGHT_ACTION.CATCH_PET == actionType then
        -- 捕捉宠物
        if not BattleSimulatorMgr:isRunning() then
            gf:CmdToServer('CMD_C_CATCH_PET', {id = victimId})
        else
            gf:sendDoActionToBattleSimulator('CMD_C_CATCH_PET', {id = victimId})
        end
    elseif FIGHT_ACTION.FLEE == actionType then
        if not BattleSimulatorMgr:isRunning() then
            gf:CmdToServer('CMD_C_FLEE', {})
        else
            gf:sendDoActionToBattleSimulator('CMD_C_FLEE', {})
        end
    else
        --  cyq todo 获取自定义的战斗对话
        local talkInfo = ""

        -- cyq todo 为战斗中自定义表情增加性别标志

        if not BattleSimulatorMgr:isRunning() then
            gf:CmdToServer('CMD_C_DO_ACTION', {
                id         = acterId,
                victim_id  = victimId,
                action     = actionType,
                para       = para,
                skill_talk = talkInfo,
                para1      = para1,
                para2      = para2,
                para3      = para3,
            })
        else
            gf:sendDoActionToBattleSimulator('CMD_C_DO_ACTION', {
                id         = acterId,
                victim_id  = victimId,
                action     = actionType,
                para       = para,
                skill_talk = talkInfo
            })
        end

        if FIGHT_ACTION.CAST_MAGIC == actionType then
            -- 设置人物/宠物默认技能
            if Me:queryBasicInt('c_attacking_id') == Me:getId() then
                Me:setBasic('def_me_skill', para)
            else
                local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
                if pet then
                    pet:setBasic('def_pet_skill', para)
                end
            end
        end
    end
end

-- 关闭部分确认框
function gf:closeSomeConfirm()
    gf:closeConfirmByType("jiuqu_bianshen")
    gf:closeConfirmByType("pet_oper")
end

-- 根据类型来关闭确认框
function gf:closeConfirmByType(dlgType)
    local dlg = DlgMgr:getDlgByName("ConfirmDlg")
    if not dlg then return end

    if dlg.confirm_type == dlgType then
        -- 九曲玲珑笔需要关闭
        dlg:onCloseButton()
    end
end

-- 确认框
-- dlgTag 在const.lua中的CONFIRM_TYPE，确保唯一。对确认框无需标记则不用理会
-- enterCombatNeedColse 进战斗该确认需不要关闭
-- onlyConfirm 若为真，仅显示确认按钮，不显示取消按钮
-- confirm_type 用于一些确认框行为，例如值为 "jiuqu_bianshen"，该情况下，换下要关闭
function gf:confirm(tip, onConfirm, onCancel, needInput, hourglassTime, dlgTag,
                    enterCombatNeedColse, onlyConfirm, confirm_type, showMode, countDownTips, no_close_btn)
    return gf:confirmEx(tip, nil, onConfirm, nil, onCancel, needInput, hourglassTime,
                    dlgTag, enterCombatNeedColse, onlyConfirm, confirm_type, showMode, countDownTips, no_close_btn)
end

function gf:confirmEx(tip, confirmText, onConfirm, cancelText, onCancel, needInput,
                        hourglassTime, dlgTag, enterCombatNeedColse, onlyConfirm,
                        confirm_type, showMode, countDownTips, no_close_btn)

    -- 弹出确认框的时候关闭需要关闭的对话框
    if DlgMgr:getDlgByName("DeadRemindDlg") then
        DlgMgr:closeDlg("DeadRemindDlg")
    end

    if DlgMgr:isDlgOpened("ConfirmDlg") then
        -- 如果确认框已经存在
        local dlg = DlgMgr.dlgs["ConfirmDlg"]
        if dlg.root and dlg.root:getTag() == CONFIRM_TYPE.FROM_SERVER then
            -- 当前打开的确认框为服务器要求弹出的
            if dlgTag == CONFIRM_TYPE.FROM_SERVER then
                -- 即将打开的确认框也是由服务器要求弹出的，不对已经打开的确认框处理（由服务器处理）
            else
                -- 即将打开的确认框由客户端自主弹出，先对已经打开的确认框执行取消操作
                dlg:onCancelButton()
            end
        else
            -- 上一个客户端直接取消
            -- 暂不处理取消中弹出另外一个确认框的情况(WDSY-22835)
            dlg:onCancelButton()
        end
    end

    local dlg = DlgMgr:openDlg("ConfirmDlg")
    if dlg then
        dlg:setConfirmType(confirm_type)
        dlg:setTip(tip)
        dlg.onConfirm = onConfirm
        dlg.onCancel = onCancel
        dlg:setInput(needInput)
        dlg:setHourglass(hourglassTime)
        dlg:setCountDownTips(countDownTips)
        dlg:updateLayout()

        if onlyConfirm then
            dlg:setOnlyConfirm()
        end

        dlg:setDlgMode(showMode)

        dlg:setEnterCombatIsNeedClose(enterCombatNeedColse)

        if confirmText then
            dlg:setConfirmLabel(confirmText)
        end

        if cancelText then
            dlg:setCancelLabel(cancelText)
        end

        if dlgTag then
            dlg.root:setTag(dlgTag)
        else
            dlg.root:setTag(0)
        end

        if no_close_btn then
            -- 不显示关闭按钮
            dlg:setCloseButtonVisible(false)
        end
    end

    return dlg
end

-- 道行字符串
function gf:getTaoStr(tao, taoPoint)
    taoPoint = taoPoint or 0
    if tao <= 0 and taoPoint <= 0 then
        -- 无道行
        return CHS[34048]
    end

    local year = math.floor(tao / Const.ONE_YEAR_TAO)
    local day = tao % Const.ONE_YEAR_TAO

    local sb = StringBuilder.new()
    if year ~= 0 then
        -- 年
        sb:add(string.format(CHS[34049], year))
    end

    if day ~= 0 then
        -- 天
        sb:add(string.format(CHS[34050], day))
    end

    if taoPoint ~= 0 then
        -- 点
        sb:add(taoPoint .. CHS[3000017])
    end

    return sb:toString()
end

-- 对齐
function gf:align(node, size, relativeAlign)
    local pos = cc.p(0, 0)
    local anchor = cc.p(0, 0)
    if relativeAlign == ccui.RelativeAlign.alignParentTopLeft then
        -- 上左
        pos = cc.p(0, size.height)
        anchor = cc.p(0, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentTopCenterHorizontal then
        -- 上中
        pos = cc.p(size.width/2, size.height)
        anchor = cc.p(0.5, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentTopRight then
        -- 上右
        pos = cc.p(size.width, size.height)
        anchor = cc.p(1, 1)
    elseif relativeAlign == ccui.RelativeAlign.alignParentLeftCenterVertical then
        -- 中左
        pos = cc.p(0, size.height/2)
        anchor = cc.p(0, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.centerInParent then
        -- 中
        pos = cc.p(size.width/2, size.height/2)
        anchor = cc.p(0.5, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.alignParentRightCenterVertical then
        -- 中右
        pos = cc.p(size.width, size.height/2)
        anchor = cc.p(1, 0.5)
    elseif relativeAlign == ccui.RelativeAlign.alignParentLeftBottom then
    -- 下左（默认）
    elseif relativeAlign == ccui.RelativeAlign.alignParentBottomCenterHorizontal then
        -- 下中
        pos = cc.p(size.width/2, 0)
        anchor = cc.p(0.5, 0)
    elseif relativeAlign == ccui.RelativeAlign.alignParentRightBottom then
        -- 下右
        pos = cc.p(size.width, 0)
        anchor = cc.p(1, 0)
    end

    node:ignoreAnchorPointForPosition(false)
    node:setAnchorPoint(anchor)
    node:setPosition(pos)
end

-- 得到宠物名字
function gf:getPetName(pet, isShowRawName)
    if nil == pet then
        return
    end

    -- 根据宠物类型类显示不同的名字
    local name = ""

    if not isShowRawName then
        name = pet.name or pet:query("name")
    else
        name = pet.raw_name or pet:query("raw_name")
    end

    local rank = pet.rank or pet:queryInt("rank")
    local ride = pet.mount_type or pet:queryInt("mount_type")

    if ride ~= 0 then
        -- 骑宠
        if (MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == ride) then
            -- 精怪
            name = name .. CHS[1001432]
        elseif (MOUNT_TYPE.MOUNT_TYPE_YULING == ride) then
            -- 御灵
            name = name .. CHS[1001433]
        end
        return name
    end

    if rank == Const.PET_RANK_WILD then
        name = name .. CHS[33814]
    elseif rank == Const.PET_RANK_BABY then
        if pet.eclosion and pet.eclosion == 2 then
            name = name .. CHS[4100998]
        elseif pet.enchant and pet.enchant == 2 then
            name = name .. CHS[4000390]
        elseif pet.queryInt and type(pet.queryInt) == "function" and pet:queryInt("eclosion") == 2 then
            name = name .. CHS[4100998]
        elseif pet.queryInt and type(pet.queryInt) == "function" and pet:queryInt("enchant") == 2 then
            name = name .. CHS[4000390]
        elseif pet.rebuild_level then
            -- rebuild_level代表其被强化情况，包括phy/mag，目前出现于集市列表数据中
            if pet.rebuild_level > 0 then
                name = name .. CHS[33815]
            else
                name = name .. CHS[33816]
            end
        elseif pet.phy_rebuild_level or pet.mag_rebuild_level then
            if pet.phy_rebuild_level > 0 or pet.mag_rebuild_level > 0 then
                name = name .. CHS[33815]
            else
                name = name .. CHS[33816]
            end
        else
            if pet:queryInt("phy_rebuild_level") > 0 or
                pet:queryInt("mag_rebuild_level") > 0  then
                name = name .. CHS[33815]
            else
                name = name .. CHS[33816]
            end
        end

    elseif rank == Const.PET_RANK_ELITE then
        name = name .. CHS[33817]
    elseif rank == Const.PET_RANK_EPIC then
        name = name .. CHS[33818]
    elseif rank == Const.PET_RANK_GUARD then
        name = name .. CHS[102432]
    end
    return name
end

function gf:getPetRankDesc(pet)
    if not pet then return end

    local ride = pet.mount_type or pet:queryInt("mount_type")
    if ride ~= 0 then
        -- 骑宠
        if MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == ride then
            -- 精怪
            return CHS[6000519]
        elseif MOUNT_TYPE.MOUNT_TYPE_YULING == ride then
            -- 御灵
            return CHS[6000520]
        end
    end

    local rank = pet:queryInt("rank")
    if rank == Const.PET_RANK_WILD then
        return CHS[3003810]
    elseif rank == Const.PET_RANK_BABY then
        if PetMgr:isYuhuaCompleted(pet) then
            -- 羽化
            return CHS[4100999]
        elseif pet:queryInt("enchant") == 2 then
            return CHS[4300063]
        elseif pet:queryInt("phy_rebuild_level") > 0 or
            pet:queryInt("mag_rebuild_level") > 0 then
            return CHS[3003811]
        else
            return CHS[3003812]
        end
    elseif rank == Const.PET_RANK_ELITE then
        return CHS[3003813]
    elseif rank == Const.PET_RANK_EPIC then
        return CHS[3003814]
    elseif rank == Const.PET_RANK_GUARD then
        return CHS[3003815]
    end
end

function gf:getPolar(polar)
    if polar == POLAR.METAL then
        return CHS[34308]
    elseif polar == POLAR.WOOD then
        return CHS[34309]
    elseif polar == POLAR.WATER then
        return CHS[34310]
    elseif polar == POLAR.FIRE then
        return CHS[34311]
    elseif polar == POLAR.EARTH then
        return CHS[34312]
    else
        return CHS[34048]
    end
end

function gf:getCardTypeChs(cardType)
    if cardType == CARD_TYPE.MONSTER then
        return CHS[4100082]
    elseif cardType == CARD_TYPE.ELITE then
        return CHS[4100083]
    elseif cardType == CARD_TYPE.BOSS then
        return CHS[4100084]
    elseif cardType == CARD_TYPE.EPIC then
        return CHS[5450056]
    end
end

-- 根据门派获取相性描述
function gf:getPolarByFamily(family)
    local polar = FAMILYTOPOLAR[family]
    if nil == polar then return end

    return gf:getPolar(polar)
end

-- 根据相性获取门派
function gf:getPolarDesc(polar)
    if polar == POLAR.METAL then
        return CHS[3003816]
    elseif polar == POLAR.WOOD then
        return CHS[3003817]
    elseif polar == POLAR.WATER then
        return CHS[3003818]
    elseif polar == POLAR.FIRE then
        return CHS[3003819]
    elseif polar == POLAR.EARTH then
        return CHS[3003820]
    else
        return CHS[3003816]
    end
end

-- 根据相性获取对应头像
-- getSmallPortrait
function gf:getHeadImgByPolar(polar, gender)
    gender = gender or 1
    return ResMgr:getIconByPolarAndGender(polar, gender)
end

function gf:getIntPolar(polar)
    if polar == CHS[34308] then
        return POLAR.METAL
    elseif polar == CHS[34309] then
        return POLAR.WOOD
    elseif polar == CHS[34310] then
        return POLAR.WATER
    elseif polar == CHS[34311] then
        return POLAR.FIRE
    elseif polar == CHS[34312] then
        return POLAR.EARTH
    else
        return 0
    end
end

-- 获得属性的内景地图名称
function gf:getInsidePolarMap(polar)
    if polar == POLAR.METAL then
        return CHS[3003821]
    elseif polar == POLAR.WOOD then
        return CHS[3003822]
    elseif polar == POLAR.WATER then
        return CHS[3003823]
    elseif polar == POLAR.FIRE then
        return CHS[3003824]
    elseif polar == POLAR.EARTH then
        return CHS[3003825]
    else
        return CHS[34048]
    end
end

-- 通过传入的地图名称判断是不是5大门派地图
function gf:isPolarMap(mapName)
    if mapName == CHS[6000066]
      or mapName == CHS[6000067]
      or mapName == CHS[6000068]
      or mapName == CHS[6000069]
      or mapName == CHS[6000070] then
        return true
    else
        return false
    end
end

-- 获得属性的地图名称
function gf:getPolarMap(polar)
    if polar == POLAR.METAL then
        return CHS[6000066]            -- "五龙山"
    elseif polar == POLAR.WOOD then
        return CHS[6000067]            -- "终南山"
    elseif polar == POLAR.WATER then
        return CHS[6000068]            -- "凤凰山"
    elseif polar == POLAR.FIRE then
        return CHS[6000069]            -- "乾元山"
    elseif polar == POLAR.EARTH then
        return CHS[6000070]            -- "骷髅山"
    else
        return CHS[34048]
    end
end

-- 获取相性的掌门
function gf:getPolarLeader(polar)
    if polar == POLAR.METAL then
        return CHS[3003826]
    elseif polar == POLAR.WOOD then
        return CHS[3003827]
    elseif polar == POLAR.WATER then
        return CHS[3003828]
    elseif polar == POLAR.FIRE then
        return CHS[3003829]
    elseif polar == POLAR.EARTH then
        return CHS[3003830]
    end
end

-- 获取相性的NPC
function gf:getPolarNPC(polar)
    if polar == POLAR.METAL then
        return CHS[6000118]
    elseif polar == POLAR.WOOD then
        return CHS[6000119]
    elseif polar == POLAR.WATER then
        return CHS[6000120]
    elseif polar == POLAR.FIRE then
        return CHS[6000121]
    elseif polar == POLAR.EARTH then
        return CHS[6000122]
    else
        return CHS[34048]  -- "无"
    end
end

--  获取守护类型
function gf:geGuardRank(rank)
    if rank == GUARD_RANK.TONGZI then
        return CHS[6000029]
    elseif rank == GUARD_RANK.ZHANGLAO then
        return CHS[6000031]
    elseif rank == GUARD_RANK.SHENLING then
        return CHS[6000030]
    end
end

-- 是否显示为元婴/血婴
function gf:isBabyShow(icon)
    return icon == ResMgr.icon.yuanying or icon == ResMgr.icon.xueying
end

-- 尝试转换光效标号
function gf:tryConvertMagicKey(magicKey, icon)
    if self:isBabyShow(icon) then
        if magicKey == ResMgr.magic.xian then
            return ResMgr.magic.yuanying
        elseif magicKey == ResMgr.magic.mo then
            return ResMgr.magic.xueying
        end
    else
        if magicKey == ResMgr.magic.yuanying then
            return ResMgr.magic.xian
        elseif magicKey == ResMgr.magic.xueying then
            return ResMgr.magic.mo
        end
    end

    return magicKey
end

function gf:getGBKStringLen(str)
    local gbk = gfUTF8ToGBK(str)
    return string.len(gbk)
end

-- 悬浮提示
-- x, y为悬浮框顶部中心点所在位置
function gf:showTipInfo(str, node, width)
    local rect = node:getBoundingBox()
    local pt = node:convertToWorldSpace(cc.p(0, 0))
    rect.x = pt.x
    rect.y = pt.y
    rect.width = rect.width * Const.UI_SCALE
    rect.height = rect.height * Const.UI_SCALE

    local dlg = DlgMgr:openDlg("FloatingFrameDlg")
    dlg:setText(str, width or 350)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function gf:showTipInfoByPos(str, rect, pt)
    rect.x = pt.x
    rect.y = pt.y
    rect.width = rect.width * Const.UI_SCALE
    rect.height = rect.height * Const.UI_SCALE

    local dlg = DlgMgr:openDlg("FloatingFrameDlg")
    dlg:setText(str, 350)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

-- 设置字体描边
-- control 要描边的控件
-- color4b 要描边的颜色
-- fontSize 描边像素大小
function gf:setLabelOutline(control, color4b, fontSize)
    control:getVirtualRenderer():enableOutline(color4b, fontSize)
end

-- 第三个返回值字体描边颜色
function gf:getMoneyDesc(money, returnColor)
    local moneyAbs = math.abs(money)
    -- 字符串拼接
    local str = string.format("%s", moneyAbs)
    local len = string.len(str)
    local moneyStr
    local pos = len % 3
    if pos == 0 then
        moneyStr = string.format("%s", string.sub(str, 1, 3))
        pos = 3
    else
        moneyStr = string.format("%s", string.sub(str, 1, pos))
    end

    while pos < len do
        moneyStr = string.format("%s,%s", moneyStr, string.sub(str, pos + 1, pos + 3))
        pos = pos + 3
    end

    -- 颜色处理
    if money < 0 then
        moneyStr = string.format("-%s", moneyStr)
    end

    if moneyAbs < 100000 then
        --白色  ------暂时白色改成这  吕
        if returnColor then
            return moneyStr, cc.c3b(109, 118, 178), cc.c4b(166, 143, 123, 255)
        else
            return "#c6D76B2" .. moneyStr .. "#n"
        end
    elseif moneyAbs < 1000000 then
        --绿色
        if returnColor then
            return moneyStr, COLOR3.GREEN, cc.c4b(156, 134, 115, 255)
        else
            return "#G" .. moneyStr .. "#n"
        end
    elseif moneyAbs < 10000000 then
        --紫色
        if returnColor then
            return moneyStr, COLOR3.PURPLE, cc.c4b(242, 230, 218, 255)
        else
            return "#O" .. moneyStr .. "#n"
        end
    elseif moneyAbs < 100000000 then
        --黄色
        if returnColor then
            return moneyStr, COLOR3.YELLOW, cc.c4b(166, 116, 91, 255)
        else
            return "#y" .. moneyStr .. "#n"
        end
    elseif moneyAbs < 1000000000 then
        --红色
        if returnColor then
            return moneyStr, COLOR3.RED, cc.c4b(242, 214, 194, 255)
        else
            return "#R" .. moneyStr .. "#n"
        end
    else
        --蓝色
        if returnColor then
            return moneyStr, COLOR3.BLUE, cc.c4b(166, 116, 255, 255)
        else
            return "#B" .. moneyStr .. "#n"
        end
    end
end

-- 获取金钱对应美术字的颜色,有小数点 num 为小数点位数
function gf:getArtFontMoneyDescByPoint(money, num)
    local floorMoney, artColor = gf:getArtFontMoneyDesc(money)
    if not num then return floorMoney, artColor end

    local temp, point = math.modf(money)   -- lua 中计算，经常会遇到   例如：值为12   却为12.1111这样，防止误差
    local weiCount =  math.pow(10, num + 1)
    point = math.floor(point * weiCount + 0.0001)    -- 精度可能存在误差，所以加上 0.0001 用于校正
    if math.floor(point % 10) ~= 0 then
        point = point + 10
    end

    -- 如果整数位进1时，导致整数位进1，整数位 + 1，point相应处理
    if point >= weiCount then
        floorMoney = gf:getArtFontMoneyDesc(money + 1)
        point = point - weiCount
    end

    -- 舍弃末位
    point = math.floor(point / 10)

    -- 补全0
    local pKey = "%0" .. num .. "d"
    local destPoint = string.format( pKey, point)

    -- 计算小数点第一个末位不为 0的位置
    local len = string.len(destPoint)
    local pos = 0
    for i = len, 1, -1 do
        if string.sub(destPoint, i, i) ~= "0" then
            pos = i
            break
    end
    end

    if pos ~= 0 then
        local retPoint = string.sub(destPoint, 1, pos)
        return floorMoney .. "." .. retPoint
    else
        -- 小数点为 0的情况
        return floorMoney
    end
end

-- 获取金钱对应美术字的颜色
function gf:getArtFontMoneyDesc(money)
    -- 字符串拼接
    -- money = 1.9 * 10000 * 3，直接用math.floor(math.abs(money))会得到56999，而期望得到的是57000
    -- math.floor(math.abs((tonumber(tostring(money))))) = 57000
    local moneyAbs = math.floor(math.abs((tonumber(tostring(money)))))

    local str = string.format("%s", moneyAbs)
    local len = string.len(str)
    local moneyStr
    local pos = len % 3
    if pos == 0 then
        moneyStr = string.format("%s", string.sub(str, 1, 3))
        pos = 3
    else
        moneyStr = string.format("%s", string.sub(str, 1, pos))
    end
    while pos < len do
        moneyStr = string.format("%s,%s", moneyStr, string.sub(str, pos + 1, pos + 3))
        pos = pos + 3
    end
    -- 颜色处理
    if money < 0 then
        moneyStr = string.format("-%s", moneyStr)
    end

    if moneyAbs < 100000 then
        --白色
        return moneyStr, ART_FONT_COLOR.DEFAULT
    elseif moneyAbs < 1000000 then
        --绿色
        return moneyStr, ART_FONT_COLOR.GREEN
    elseif moneyAbs < 10000000 then
        --紫色
        return moneyStr, ART_FONT_COLOR.PURPLE
    elseif moneyAbs < 100000000 then
        --黄色
        return moneyStr, ART_FONT_COLOR.YELLOW
    elseif moneyAbs < 1000000000 then
        --红色
        return moneyStr, ART_FONT_COLOR.RED
    else
        --蓝色
        return moneyStr, ART_FONT_COLOR.BLUE
    end
end

-- 将 32 位的有符号数转换为对应的无符号数
function gf:uint(i32)
    i32 = tonumber(i32)
    if i32 >= 0 then
        return i32
    end

    return I2POW32 + i32
end

function gf:grayCheckSelectImageView(imageView)
    if not imageView then
        return
    end

    -- 选中
    local ctrl = imageView:getVirtualSelectedRenderer()
    if not ctrl then return end

    local childs = ctrl:getChildren()
    for i = 1, #childs do
        childs[i]:setGLProgramState(ShaderMgr:getGrayShader())
    end

    ctrl:setGLProgramState(ShaderMgr:getGrayShader())

    -- 点击
    local ctrlDown = imageView:getVirtualButtonDownRenderer()
    if not ctrlDown then return end

    local childs2 = ctrlDown:getChildren()
    for i = 1, #childs2 do
        childs2[i]:setGLProgramState(ShaderMgr:getGrayShader())
    end

    ctrlDown:setGLProgramState(ShaderMgr:getGrayShader())
end

function gf:resetCheckSelectImageView(imageView)
    if not imageView then
        return
    end

    local ctrl = imageView:getVirtualSelectedRenderer()
    if not ctrl then return end

    local childs = ctrl:getChildren()
    for i = 1, #childs do
        childs[i]:setGLProgramState(ShaderMgr:getRawShader())
    end

    ctrl:setGLProgramState(ShaderMgr:getRawShader())

    local ctrl2 = imageView:getVirtualButtonDownRenderer()
    if not ctrl2 then return end

    local childs2 = ctrl2:getChildren()
    for i = 1, #childs2 do
        childs2[i]:setGLProgramState(ShaderMgr:getRawShader())
    end

    ctrl2:setGLProgramState(ShaderMgr:getRawShader())
end

-- 置灰
function gf:grayImageView(imageView)
    if not imageView then
        return
    end

    local ctrl = imageView:getVirtualRenderer()
    if not ctrl then return end

    local childs = ctrl:getChildren()
    for i = 1, #childs do
        childs[i]:setGLProgramState(ShaderMgr:getGrayShader())
    end

    ctrl:setGLProgramState(ShaderMgr:getGrayShader())

    imageView.isGray = true
end

-- 将控件重置到初始状态
function gf:resetImageView(imageView)
    if not imageView then
        return
    end

    local ctrl = imageView:getVirtualRenderer()
    if not ctrl then return end

    local childs = ctrl:getChildren()
    for i = 1, #childs do
        childs[i]:setGLProgramState(ShaderMgr:getRawShader())
    end

    ctrl:setGLProgramState(ShaderMgr:getRawShader())

    imageView.isGray = false
end

-- 设置控件点击与置灰
function gf:grayCtrlAndTouchEnabled(ctrl, flag)
    if not ctrl then return end
    ctrl:setTouchEnabled(flag)
    if flag then
        gf:resetImageView(ctrl)
    else
        gf:grayImageView(ctrl)
    end
end

-- 查找字符串中#P、#Z指向的目的地
function gf:findDest(str)
    if not str or string.len(str) == 0 then return end

    local r  = AutoWalkMgr:getDest(str)
    if r then
        r.x = tonumber(r.x)
        r.y = tonumber(r.y)

		r.orgStr = str
    end

    return r

        --[[ local r = {}

        repeat
        -- 匹配#P某NPC|场景(xxx,yyy)|$0#P
        r.npc,r.map,r.x,r.y,r.action = string.match(str, "#P(.+)|(.+)%((%d+),(%d+)%)|($0)#P")
        if r.npc ~= nil then break end

        -- 匹配#P某NPC名称|场景(xxx,yyy)#P
        r.npc,r.map,r.x,r.y = string.match(str, "#P(.+)|(.+)%((%d+),(%d+)%)#P")
        if r.npc ~= nil then break end


        -- 匹配#P某NPC|$1#P
        r.npc,r.action = string.match(str, "#P(.+)|($%d+)#P")
        _,r.map = MapMgr:getNpcByName(r.npc)
        if r.npc ~= nil then break end

        -- 匹配#P某NPC名称#P
        r.npc = string.match(str, "#P(.+)#P")
        _,r.map = MapMgr:getNpcByName(r.npc)
        r.action = "$0"
        if r.npc ~= nil then break end

        -- 匹配#Z某场景|场景(xxx,yyy)|$1#Z
        r.map,r.x,r.y,r.action = string.match(str, "#Z.+|(.+)%((%d+),(%d+)%)|($1)#Z")
        if r.map ~= nil then break end

        -- 匹配#Z某场景名称|场景(xxx,yyy)#Z
        r.map,r.x,r.y = string.match(str, "#Z.+|(.+)%((%d+),(%d+)%)#Z")
        if r.map ~= nil then break end

        -- 匹配#Z场景别名|场景|($0或$1)#Z
        r.map,r.action = string.match(str, "#Z.+|(.+)|(.+)#Z")
        if r.map ~= nil then
        if r.map == MapMgr:getCurrentMapName() then
        -- 当前地图，使用 me 的位置即可
        r.x, r.y = gf:convertToMapSpace(Me.curX, Me.curY)
        else
        r.x, r.y = MapMgr:flyPosition(r.map)
        end

        break
        end


        -- 匹配#Z场景(xxx,yyy)#Z
        r.map,r.x,r.y = string.match(str, "#Z(.+)%((%d+),(%d+)%)#Z")
        if r.map ~= nil then break end

        -- 匹配#Z某场景#Z
        r.map = string.match(str, "#Z(.+)#Z")
        if r.map ~= nil then break end

        return
        until true

        r.x = tonumber(r.x)
        r.y = tonumber(r.y)
        return r]]
end

-- 需要cash金钱，最低购买的金钱和所花费的元宝
function gf:toBuyCash(cash)
    local quota6 = math.floor(cash / SilverToCash[6].cash)
    local quota5 = math.floor((cash - quota6 * SilverToCash[6].cash) / SilverToCash[5].cash)
    local quota4 = math.floor((cash - quota6 * SilverToCash[6].cash - quota5 * SilverToCash[5].cash) / SilverToCash[4].cash)
    local quota3 = math.floor((cash - quota6 * SilverToCash[6].cash - quota5 * SilverToCash[5].cash - quota4 * SilverToCash[4].cash) / SilverToCash[3].cash)
    local quota2 = math.floor((cash - quota6 * SilverToCash[6].cash - quota5 * SilverToCash[5].cash - quota4 * SilverToCash[4].cash - quota3 * SilverToCash[3].cash) / SilverToCash[2].cash)
    local quota1 = math.ceil((cash - quota6 * SilverToCash[6].cash - quota5 * SilverToCash[5].cash - quota4 * SilverToCash[4].cash - quota3 * SilverToCash[3].cash - quota2 * SilverToCash[2].cash) / SilverToCash[1].cash)

    local getMoney = quota1 * SilverToCash[1].cash + quota2 * SilverToCash[2].cash + quota3 * SilverToCash[3].cash + quota4 * SilverToCash[4].cash + quota5 * SilverToCash[5].cash + quota6 * SilverToCash[6].cash
    local costSilver = quota1 * SilverToCash[1].silver + quota2 * SilverToCash[2].silver + quota3 * SilverToCash[3].silver + quota4 * SilverToCash[4].silver + quota5 * SilverToCash[5].silver + quota6 * SilverToCash[6].silver

    return getMoney, costSilver
end

-- 检查金钱加上代金券是否足够, 用于先扣代金券再扣金钱的操作
function gf:checkHasEnoughMoney(amount)
    local cash = Me:queryBasicInt("cash")
    local voucher = Me:queryBasicInt("voucher")

    if voucher >= amount then
        return true
    end

    if (voucher < amount) and ((amount - voucher) <= cash) then
        return true
    end
    if amount > cash + voucher then
        self:askUserWhetherBuyCash(amount - cash - voucher)
        return false
    end
end

-- 检查当前货币类型是否足够支付
function gf:checkCurMoneyEnough(amount, func, canOnlyBuyByCash)
    local useMoneyType = Me:queryBasicInt("use_money_type")
    local cash = Me:queryBasicInt("cash")
    local voucher = Me:queryBasicInt("voucher")
    if MONEY_TYPE.CASH == useMoneyType then
        -- 金钱
        if cash >= amount then
            -- 金钱足够
            return true
        elseif canOnlyBuyByCash then
            -- 金钱不够，且只能用金钱购买
            gf:askUserWhetherBuyCash()
            return false
        elseif voucher >= amount then
            -- 代金券足够，询问是否切换
            gf:confirm(CHS[3003831], function()
                -- 切换模式
                CharMgr:setUseMoneyType(MONEY_TYPE.VOUCHER)

                -- 切换之后的回调函数
                if "function" == type(func) then
                    func()
                end
            end)

            return false
        end
    elseif MONEY_TYPE.VOUCHER == useMoneyType then
        -- 代金券
        if canOnlyBuyByCash then  -- 商品只能用金钱购买
            gf:confirm(CHS[7000135], function()
                CharMgr:setUseMoneyType(MONEY_TYPE.CASH)

                -- 切换之后的回调函数
                if "function" == type(func) then
                    func()
                end
            end)

            return false
        elseif voucher >= amount then
            -- 代金券足够
            return true
        elseif cash >= amount then
            -- 金钱足够，询问是否切换
            gf:confirm(CHS[3003832], function()
                -- 切换模式
                CharMgr:setUseMoneyType(MONEY_TYPE.CASH)

                -- 切换之后的回调函数
                if "function" == type(func) then
                    func()
                end
            end)

            return false
        end
    end
end

-- 检查消耗品是否满足, isNoTip == true,直接返回结果不需要提示xx不足
function gf:checkCostIsEnough(cash, items, isNoTip)
    local ownCash = Me:queryInt("cash")
    local cashIsEnough = (ownCash >= cash)

    local itemsTab = {}
    if type(items) == "string" then
        itemsTab = {[items] = 1}
    elseif type(items) == "table" then
        itemsTab = items
    elseif items == nil then
    else
        return false
    end

    local itemIsEnough = true
    for name, num in pairs(itemsTab) do
        local haveItemCount = InventoryMgr:getAmountByName(name)
        if num > haveItemCount then itemIsEnough = false end
    end

    -- 如果不需要提示
    if isNoTip then
        if not cashIsEnough or not itemIsEnough then
            return false
        end
        return true
    end

    if not itemIsEnough then
        self:askUserWhetherBuyItem(itemsTab)
        return false
    elseif not cashIsEnough then
        self:askUserWhetherBuyCash(cash - ownCash)
        return false
    end

    return true
end

-- 道具金钱都不足
function gf:askUserWhetherBuyMoneyAndItem(cash, items, isExBag)
    if items == nil then return end
    if cash <= 0 then self:askUserWhetherBuyItem(items, isExBag) return end

    local itemsTab = {}
    if type(items) == "string" then
        itemsTab = {[items] = 1}
    elseif type(items) == "table" then
        itemsTab = items
    else
        return
    end

    local count = 0

    -- 检查是否是商城道具   依据iteminfo.lua中有没有配coin元宝价格字段
    for name, num in pairs(itemsTab) do
        if ItemInfo[name].coin == nil then
            gf:ShowSmallTips(CHS[3003833])
            return
        end
    end

    local need = {}

    -- 购买金钱字符串
    local haveCash = Me:queryInt("cash")
    local buyCash = 0
    local buyCashPayGold = ""
    if isExBag then
        buyCash, buyCashPayGold = self:toBuyCash(cash)
        need.cash = buyCash
    else
        if haveCash < cash then
            buyCash, buyCashPayGold = self:toBuyCash(cash - haveCash)
            need.cash = buyCash
        end
    end

    local buyCashStr = ""
    if buyCash ~= 0 then
        buyCashStr = "#R" .. buyCashPayGold .. CHS[3003834] .. self:getMoneyDesc(buyCash) .. CHS[3003835]
    end

    -- 拼接物品
    local itemsStr = ""
    for name, num in pairs(itemsTab) do
        if isExBag then
            -- 不要扣除背包中
            need[name] = num
            local payCoin = need[name] * (ItemInfo[name].coin or 1)
            local coinType = ItemInfo[name].coinType or ""
            count = count + 1
            if count ~= 1 then
                itemsStr = itemsStr .. ",#R" .. payCoin .. "#n" .. coinType .. CHS[3003836] .. "#R" .. need[name] .. "#n" .. InventoryMgr:getUnit(name) .. "#R" .. name .. "#n"
            else
                itemsStr = itemsStr .. "#R" .. payCoin .. "#n" .. coinType .. CHS[3003836] .. "#R" .. need[name] .. "#n" .. InventoryMgr:getUnit(name) .. "#R" .. name .. "#n"
            end
        else
            local have = InventoryMgr:getAmountByName(name)
            if have < num then
                need[name] = num - have
                local payCoin = need[name] * (ItemInfo[name].coin or 1)
                local coinType = ItemInfo[name].coinType or ""
                count = count + 1
                if count ~= 1 then
                    itemsStr = itemsStr .. ",#R" .. payCoin .. "#n" .. coinType .. CHS[3003836] .. "#R" .. need[name] .. "#n" .. InventoryMgr:getUnit(name) .. "#R" .. name .. "#n"
                else
                    itemsStr = itemsStr .. "#R" .. payCoin .. "#n" .. coinType .. CHS[3003836] .. "#R" .. need[name] .. "#n" .. InventoryMgr:getUnit(name) .. "#R" .. name .. "#n"
                end
            else
                -- 自己拥有的个数足够
                return
            end
        end
    end
    need.count = count
    if itemsStr ~= "" then itemsStr = itemsStr .. "?" end

    if need.count ~= 0 then
        gf:confirm(string.format(CHS[4000347], buyCashStr .. itemsStr), function()
            gf:CmdToServer("CMD_BATCH_BUY", need)
        end)
        return true
    else
        return false
    end
end

-- 道具不足时询问是否购买道具的通用处理
function gf:askUserWhetherBuyItem(items, noTip, from, noCheckCoin)
    local itemsTab = {}
    if type(items) == "string" then
        itemsTab = {[items] = 1}
    elseif type(items) == "table" then
        itemsTab = items
    else
        return
    end

    -- 检查是否是商城道具   依据iteminfo.lua中有没有配coin元宝价格字段
    if not noCheckCoin then
        for name, num in pairs(itemsTab) do
            if InventoryMgr:getItemInfoByName(name).coin == nil then
                gf:ShowSmallTips(CHS[3003833])
                return
            end
        end
    end

    if not noTip then
        gf:ShowSmallTips(CHS[2000091])
    end

    OnlineMallMgr:openOnlineMall("ConvenientBuyDlg", nil, itemsTab, from)
end

-- 游戏币不足时询问是否购买游戏币  cash为需要花费的金钱
function gf:askUserWhetherBuyCash(cash)

    gf:confirm(CHS[3003838], function()
        gf:showBuyCash()
    end)

end

-- 购买游戏币
function gf:showBuyCash()
    OnlineMallMgr:openOnlineMall("OnlineMallExchangeMoneyDlg")
end

-- 检测金钱、银元宝、金元宝是否足够
function gf:checkEnough(payType, value)
    if payType == "cash" then
        if value > Me:queryBasicInt("cash") then
            gf:askUserWhetherBuyCash()
            return
        end
    elseif payType == "gold" then
        if value > Me:queryBasicInt('gold_coin') then
            gf:askUserWhetherBuyCoin("gold_coin")
            return
        end
    elseif payType == "silver" then
        if value > Me:getTotalCoin() then
            gf:askUserWhetherBuyCoin()
            return
        end
    end

    return true
end

-- 金元宝不足时询问是否充值
function gf:askUserWhetherBuyCoin(coinType)
    local str = CHS[3000114]
    if coinType == "gold_coin" then
        str = CHS[4000359]
    elseif coinType == "silver_coin" then
        str = CHS[3003839]
    end

    gf:confirm(str, function()
        OnlineMallMgr:openRechargeDlg()
    end)
end

-- 创建ccui.Text控件
function gf:createUIText(str)
    local text = ccui.Text:create()
    text:setString(str)
    text:setFontSize(Const.DEFAULT_FONT_SIZE)
    return text
end

-- 获取extra中组属性总值
function gf:getExtraGroupValue(item, key)
    local extra = item.extra
    if nil == extra then return 0 end

    local value = 0
    for i = Const.FIELDS_NORMAL, Const.FIELDS_MAX do
        local tmp = extra[string.format("%s_%d", key, i)]
        if type(tmp) == "number" then
            value = value + tmp
        end
    end
    return value
end

-- 获取客户端所在时区，西时区用负数表示
function gf:getClientTimeZone()
    -- 怀疑使用 0 计算在个别设备/模拟器上会有偏差（如：本应该整 8 点的结果却是 7:59:59）
    -- 故尝试使用 60 进行计算，详见：WDSY-21394
    local timeInfo = os.date("*t", 60)
    if timeInfo.year == 1969 then
        return timeInfo.hour - 24
    end

    return timeInfo.hour
end

-- 获取服务器日期信息
function gf:getServerDate(fmt, t)
    local timeDiff = (GameMgr.serverTimeZone - GameMgr.clientTimeZone) * 3600
    return os.date(fmt, t + timeDiff)
end

-- 根据服务器日期获取时间戳
function gf:getTimeByServerZone(date)
    local timeDiff = (GameMgr.serverTimeZone - GameMgr.clientTimeZone) * 3600
    return os.time(date) - timeDiff
end

-- 获取服务器时间（相对于1970年1月1日08:00）的秒数
function gf:getServerTime()
    if (GameMgr.serverTime == nil or GameMgr.clientTime == nil) and GameMgr.initDataDone then
        -- 请求更新服务器时间
        gf:CmdToServer("CMD_ASK_SERVER_TIME", {})
    end

    if GameMgr.serverTime == nil or GameMgr.clientTime == nil then
        return os.time()
    end

    return GameMgr.serverTime + math.floor((gfGetTickCount() - GameMgr.clientTime) / 1000)
end

-- 过滤敏感词
function gf:filtText(text, gid, notShowTips)
    if GMMgr:isGM() then
        return text, false
    end

    local haveFilt = false
    local filtTextStr = gfFiltrate(text, true)

    if filtTextStr ~= "" then
        if not notShowTips  and (Me:queryBasic("gid") == gid or not gid)  then -- 非自己或者notShowTips = true 不弹出提示
            gf:ShowSmallTips(CHS[6000033])
        end

        haveFilt = true
    else
        filtTextStr =text
    end

    return filtTextStr, haveFilt
end

-- 转义一个颜色字符串中指定的标记，使其成为普通字符
-- isLast: true(最后一个) 默认(最前面一个)
function gf:excapeOneFlagInColorString(colorStr, str, isLast)
    local _, colorStrArray = gf:excapeFlagInColorString(colorStr, str)
    if not colorStrArray then
        return colorStr
    end

    local lenth = #colorStrArray
    if lenth > 0 and lenth % 2 == 0 then
        -- 数组长度为偶数时，说明str标记的数量为奇数个，此时需要做转义
        if isLast then
            table.insert(colorStrArray, lenth, "#")
        else
            table.insert(colorStrArray, 2, "#")
        end

        return table.concat(colorStrArray), true
    else
        return colorStr
    end
end

-- 将颜色字符串中指定的标记转义掉，使其成为普通字符
-- 例如：str 中包含 i 表示要将 colorStr 中 #i 转为 ##i，这样控件中最终显示的就是字符串 #i
-- 返回: 被转义后的字符串，被转义的特殊字符数量
function gf:excapeFlagInColorString(colorStr, str)
    if string.len(str) < 1 then
        Log:D('Invalid arg str:' .. str .. ' in gf:excapeFlagInColorString')
        return colorStr
    end

    local charCodes = {}
    for i = 1, string.len(str) do
        charCodes[i] = string.byte(str, i)
    end

    local len = string.len(colorStr)
    local strArray = {}
    local flag = false
    local lastPos = 1
    for i = 1, len do
        local tmp = string.byte(colorStr, i)
        if tmp == 35 then
            -- tmp 为 #
            flag = not flag
        else
            if flag then
                for _, v in pairs(charCodes) do
                -- 找到了要转义的标记
                    if tmp == v then
                table.insert(strArray, string.sub(colorStr, lastPos, i - 1))
                lastPos = i
            end
                end
            end

            flag = false
        end
    end

    if #strArray == 0 then
        -- 没有要转义的标记
        return colorStr
    end

    table.insert(strArray, string.sub(colorStr, lastPos))
    return table.concat(strArray, '#'), strArray
end

-- 过滤玩家输入的部分颜色字符串（#P、#Z、#@）
function gf:filterPlayerColorText(str)
    str = gf:excapeFlagInColorString(str, "PZ@")

    return str
end

-- 根据gid获取显示id
function gf:getShowId(gid)
    if nil == gid then return end

    return string.sub(gid, 5, 14)
end

-- 分割字符串
function gf:split(s, delim)
    if not s or type(delim) ~= "string" or string.len(delim) <= 0 then
        return
    end

    local start = 1
    local t = {}
    while true do
        local pos = gf:findStrByByte(s, delim, start) -- plain find
        if not pos then
            break
        end

        table.insert (t, string.sub (s, start, pos - 1))
        start = pos + string.len (delim)
    end
    table.insert (t, string.sub (s, start))

    return t
end

-- 一个汉字按两个字节来算
function gf:getTextLength(text)
    local index = 1
    local byteValue = string.byte(text, index)
    local len = string.len(text)
    local changeLength = 0  -- 字符串中的字符长度(一个汉字两个字符)
    local num = 0   -- 字符串中的字数

    while len >= index do
        local byteValue = string.byte(text, index)
        local len = gf:getUTF8Bytes(byteValue)
        index = index + len

        if len > 2 then
            changeLength = changeLength + 2
        else
            changeLength = changeLength + len
        end

        num = num + 1
    end

    return changeLength, num
end

-- 根据长度截取字符串，中文字符按两个字节算
function gf:subString(str, lenLimit)
    local len = string.len(str)
    local filterStr
    local index = 1
    local sstr = ""

    while index <= len do
        local byteValue = string.byte(str, index)
        local strLen = gf:getUTF8Bytes(byteValue)
        sstr = sstr .. string.sub(str, index, index + strLen - 1)
        if gf:getTextLength(sstr) > lenLimit then break end
        filterStr = sstr
        index = index + strLen
    end

    return filterStr
end

-- 过滤控制字符
function gf:filterControlChar(str)
    local len = string.len(str)
    local index = 1
    local sstr = ""

    while index <= len do
        local byteValue = string.byte(str, index)
        local strLen = gf:getUTF8Bytes(byteValue)

        if strLen > 1 or (byteValue >= 32 and byteValue ~= 127) then
            sstr = sstr .. string.sub(str, index, index + strLen - 1)
        end

        index = index + strLen
    end

    return sstr
end

-- 根据字数截取字符串，字符、汉字都按单个字算
function gf:subStringByNum(str, numLimit)
    local len = string.len(str)
    local filterStr
    local index = 1
    local sstr = ""
    local num = 0

    while index <= len and num < numLimit do
        local byteValue = string.byte(str, index)
        local strLen = gf:getUTF8Bytes(byteValue)
        sstr = sstr .. string.sub(str, index, index + strLen - 1)
        filterStr = sstr
        index = index + strLen
        num = num + 1
    end

    return filterStr
end

function gf:subStringByCharLen(str, lenLimit)
    local len = string.len(str)
    local filterStr
    local index = 1
    local sstr = ""
    local lenLeft = lenLimit

    while index <= len do
        if lenLeft <= 0 then break end
        local byteValue = string.byte(str, index)
        local strLen = gf:getUTF8Bytes(byteValue)
        sstr = sstr .. string.sub(str, index, index + strLen - 1)
        lenLeft = lenLeft - 1
        filterStr = sstr
        index = index + strLen
    end

    return filterStr, index <= len
end

-- 将文本转化成字符列表
function gf:convertTextToCharList(text)
    local list = {}

    local len = string.len(text)
    local index = 1
    local subStr = ""

    while index <= len do
        local byteValue = string.byte(text, index)
        local strLen = gf:getUTF8Bytes(byteValue)
        subStr = string.sub(text, index, index + strLen - 1)
        table.insert(list, subStr)
        index = index + strLen
    end

    return list
end

-- 是否满足gid搜索条件
function gf:isMeetSearchByGid(text)
    if string.len(tostring(text)) ~= 10 then
        return false
    end

    local index = 1
    local byteValue = string.byte(text, index)
    local len = string.len(text)

    while len >= index do
        local byteValue = string.byte(text, index)

        if byteValue >= 48 and byteValue <= 57 then
            -- 0:48    9:57
            index = index + 1
        elseif byteValue >= 97 and byteValue <= 102 then
            index = index + 1
        elseif byteValue >= 65 and byteValue <= 70 then
            index = index + 1
        else
            return false
        end
    end

    return true
end

--
function gf:isOnlyLetterDigital(text)
    local index = 1
    local byteValue = string.byte(text, index)
    local len = string.len(text)

    while len >= index do
        local byteValue = string.byte(text, index)

        if byteValue >= 48 and byteValue <= 57 then
            -- 0:48    9:57
            index = index + 1
        elseif byteValue >= 97 and byteValue <= 122 then
            index = index + 1
        elseif byteValue >= 65 and byteValue <= 90 then
            index = index + 1
        else
            return false
        end
    end

    return true
end

-- 获取两个字符串中间字段
function gf:getStringMid(str, startStr, endStr)
    local pos1 = gf:findStrByByte(str, startStr)
    if not pos1 then return "" end
    local tempStr = string.sub(str, pos1 + string.len(startStr), -1)
    local pos2 = gf:findStrByByte(tempStr, endStr)
    if not pos2 then return "" end
    return string.sub(tempStr, 1, pos2 - 1)
end

-- 解析特殊字符串，目前包括“自动寻路”和“打开对话框”
function gf:doActionByColorText(str, taskInfo)
    if not str then
        return
    end

    local dest = gf:findDest(str)
    if dest then
        if taskInfo then
        -- 自动寻路
            dest.curTaskWalkPath = {}
            dest.curTaskWalkPath.task_type = taskInfo.task_type
            dest.curTaskWalkPath.task_prompt = taskInfo.task_prompt
        end

        AutoWalkMgr:beginAutoWalk(dest)
    else
        -- 解析打开对话框
        local tempStr = string.match(str, "#@.+#@")
        if tempStr then
            -- 解析#@道具名|FastUseItemDlg=道具名
            tempStr = string.match(tempStr, "|.+=.+")
        end
        if tempStr then
            tempStr = string.sub(tempStr, 2)
            tempStr = string.sub(tempStr, 1, -3)
            DlgMgr:openDlgWithParam(tempStr)
        end
    end
end

-- CGAColorTextList控件点击事件
-- para, 值为对话框名或nil， 如果为网址相关，有值表示支持网页    如果是可复制类，有值表示是邮件入口
function gf:onCGAColorText(textCtrl, sender, bindTask, para)
    -- GM处于监听状态下
    if GMMgr:isStaticMode() then
        gf:ShowSmallTips(CHS[3003840])
        return
    end

    local csParam = textCtrl:getCsParam()
    local csType = textCtrl:getCsType()

    if  csType == CONST_DATA.CS_TYPE_URL then
        if not para then return end
        gf:processUrlTypeStr(csParam, textCtrl:getString(), para)
    elseif csType == CONST_DATA.CS_TYPE_ZOOM then
        local autoWalkInfo = gf:findDest("#Z" .. csParam.. "#Z")
        autoWalkInfo.curTaskWalkPath = bindTask
        AutoWalkMgr:beginAutoWalk(autoWalkInfo)
    elseif csType == CONST_DATA.CS_TYPE_NPC then
        local autoWalkInfo = gf:findDest("#P" .. csParam.. "#P")
        autoWalkInfo.curTaskWalkPath = bindTask
        AutoWalkMgr:beginAutoWalk(autoWalkInfo)
    elseif csType == CONST_DATA.CS_TYPE_STRING then
       -- gf:ShowSmallTips(textCtrl:getTextContant())

        if bindTask and bindTask.task_type == CHS[4010130] then
            if bindTask.task_extra_para == "3" then
                -- S3状态
                local item = InventoryMgr:getItemByClass(ITEM_CLASS.BAIHE_HUA)[1]
                if not item then return end
                InventoryMgr:applyItem(item.pos, 1)  -- 使用该道具
            elseif bindTask.task_extra_para == "1" then
                gf:CmdToServer("CMD_TEACHER_2018_LXES_APPLY_ZZ", {})
                return
            end
        end
    elseif csType  == CONST_DATA.CS_TYPE_CARD then
        if not sender then return end
        local rect = sender:getBoundingBox()
        local pt = sender:convertToWorldSpace(cc.p(0, 0))
        rect.x = pt.x
        rect.y = pt.y
        rect.width = rect.width * Const.UI_SCALE
        rect.height = rect.height * Const.UI_SCALE

        local houseId = string.match(csParam, "fishHomeInfo=(.+)")
        if houseId then
            -- 居所钓鱼，夫妻邀请对方钓鱼的特殊处理
            local destStr = "#Z" .. CHS[7002319] .. "-" .. CHS[7002330] .. "|H=" .. houseId .. "|Dlg=HomeFishingDlg#Z"
            AutoWalkMgr:beginAutoWalk(gf:findDest(destStr))
        elseif string.match(csParam, "worldCupInfo") then
            gf:CmdToServer("CMD_WORLD_CUP_2018_PLAY_TABLE")
        elseif string.match(csParam, "teacher_2018=") then
            local para = string.match(csParam, "teacher_2018=(.+)")
            gf:CmdToServer("CMD_TEACHER_2018_HELP", {desc = para})
        elseif string.match(csParam, "charCard:") then
            local gid = string.match(csParam, "charCard:(.+)")
            FriendMgr:requestCharMenuInfo(gid, "isOpen", nil, 1)
        elseif string.match(csParam, "matchMaking=") then
            local gid = string.match(csParam, "matchMaking=(.+)")
            gf:CmdToServer("CMD_MATCH_MAKING_REQ_DETAIL", { gid = gid, isOpen = 1})
        elseif string.match(csParam, "innInfo=me") then
            -- 客栈临时npc对话，寻路处理
            if CHS[7190182] == MapMgr:getCurrentMapName() then
                gf:ShowSmallTips(CHS[7120075])
            else
                AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[4010076]))
            end
        elseif string.match(csParam, "KidInfoDlg=") then
            local id = string.match(csParam, "KidInfoDlg=(.+)")
            DlgMgr:openDlgEx("KidInfoDlg", {selectId = id})
        elseif string.match(csParam, "petExplore=me") then
            -- 宠物探险临时npc对话，寻路处理
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[7190588]))
        elseif string.match(csParam, "good_voice_id:(.+)") then

            if GameMgr:IsCrossDist() then return end

            local voice_id = string.match(csParam, "good_voice_id:(.+)")
            gf:CmdToServer("CMD_GOOD_VOICE_QUERY_VOICE", {voice_id = voice_id, requestSeasonData = 1})
        elseif string.match(csParam, CHS[7120231]) then
            local kidCid = string.match(csParam, CHS[7120231].."(.*)")
            if kidCid then
                ChatMgr:sendCardInfo(kidCid, rect)
            end
        else
            local content = textCtrl:getString()
            if string.match(content, CHS[4300484]) or string.match(content, CHS[4300485]) then
                -- 集市、珍宝要发送上一次排序方式
                local temp = {}
                if string.match(content, CHS[4300484]) then
                    -- 集市
                    temp.sell_sort = {}
                    local sellData = MarketMgr:getMarketLastSelectStateData("MarketBuyDlg")
                    if sellData and next(sellData) then
                        temp.sell_sort.key = sellData.sortType
                        temp.sell_sort.type = sellData.upSort and 1 or 2
                    else
                        temp.sell_sort.key = "price"
                        temp.sell_sort.type = 1
                    end

                    -- 公示
                    temp.show_sort = {}
                    local publicData = MarketMgr:getMarketLastSelectStateData("MarketPublicityDlg")
                    if publicData and next(publicData) then
                        temp.show_sort.key = publicData.sortType
                        temp.show_sort.type = publicData.upSort and 1 or 2
                    else
                        temp.show_sort.key = "price"
                        temp.show_sort.type = 1
                    end
                else
                    -- 珍宝逛摊
                    temp.sell_sort = {}
                    local sellData = MarketMgr:getMarketLastSelectStateData("MarketGoldBuyDlg")
                    if sellData and next(sellData) then
                        temp.sell_sort.key = sellData.sortType
                        temp.sell_sort.type = sellData.upSort and 1 or 2
                    else
                        temp.sell_sort.key = "price"
                        temp.sell_sort.type = 1
                    end

                    -- 公示
                    temp.show_sort = {}
                    local publicData = MarketMgr:getMarketLastSelectStateData("MarketGlodPublicityDlg")
                    if publicData and next(publicData) then
                        temp.show_sort.key = publicData.sortType
                        temp.show_sort.type = publicData.upSort and 1 or 2
                    else
                        temp.show_sort.key = "price"
                        temp.show_sort.type = 1
                    end
                end

                local para2 = json.encode(temp)
                ChatMgr:sendCardInfo(csParam, rect, para2)
            else
            ChatMgr:sendCardInfo(csParam, rect)
        end
        end
    elseif csType  == CONST_DATA.CS_TYPE_TEAM then
        local str = csParam
        local content = textCtrl:getTextContant()
        local list = gf:split(str, "|") --  #T代为提交|keystr#T
        local pos = gf:findStrByByte(str, "|")
        if not pos then return end

        -- local cutStr = string.sub(str, pos + 1, -1)
        -- local posEnd = gf:findStrByByte(cutStr, "|")

        if list[1] == "" and list[2] == "copy" and para then
            -- list[1]默认显示蓝色。但是如果复制多信息的，需要紫色，所以这个为空
            local menus = {}
            for i = 3, #list do
                table.insert( menus, list[i] )
            end

            BlogMgr:showButtonList(nil, nil, "copy_content", nil, menus)


        elseif list[1] == CHS[6000445] and list[2] then -- 申请入队
            local name = list[2]--string.sub(cutStr, 0, posEnd - 1)
            local gid = list[3]
            if not string.isNilOrEmpty(gid) and Me:queryBasic("gid") == gid then
                return
            end

            local minLevelStr, maxLevelStr = string.match(content, CHS[7002087])
            local minTaoStr, maxTaoStr = string.match(content, CHS[5410211])
            local polarsStr = string.match(content, CHS[5410212])
            local minLevel = tonumber(minLevelStr)
            local maxLevel = tonumber(maxLevelStr)
            local meLevel = Me:getLevel()
            if minLevel > 0 and maxLevel > 0 and (meLevel > maxLevel or meLevel < minLevel) then
                gf:ShowSmallTips(CHS[7002086])
                return
            end

            local minTao = tonumber(minTaoStr) or 0
            local maxTao = tonumber(maxTaoStr) or 0
            local myTao = math.floor(Me:queryInt("tao") / Const.ONE_YEAR_TAO)
            if minTao > 0 and maxTao > 0 and (myTao > maxTao or myTao < minTao) then
                gf:ShowSmallTips(CHS[5410213])
                return
            end

            local polars = gf:split(polarsStr, "、") or {}
            local myPolar = Me:queryBasicInt("polar")
            local checkPolar = true
            local cou = #polars
            if cou > 0 and polars[1] ~= CHS[5400368]then
                checkPolar = false
                for i = 1, cou do
                    local polar = gf:getIntPolar(polars[i])
                    if myPolar == polar then
                        checkPolar = true
                        break
                    end
                end
            end

            if not checkPolar then
                gf:ShowSmallTips(CHS[5410214])
                return
            end

            gf:CmdToServer("CMD_REQUEST_JOIN", {
                peer_name = name,
                ask_type = Const.REQUEST_JOIN_TEAM,
            })
        elseif list[1] == CHS[6000444] and list[2] then -- 代为提交
            gf:CmdToServer("CMD_PARTY_HELP", {keyStr = list[2]})
        elseif list[1] == CHS[6400091] and list[2] then --申请协助(帮派)
            gf:CmdToServer("CMD_REQUEST_PH_CARD_INFO", {keyStr = list[2]})
        elseif list[1] == CHS[4010385] then -- 文曲星答题
            local temp = gf:split(list[2], "$")
            gf:CmdToServer("CMD_WQX_HELP_ANSWER_QUESTION", {char_gid = temp[1], help_id = temp[2], select_index = 0})
        end

    elseif csType  == CONST_DATA.CS_TYPE_CALL then -- 在当前频道喊话
        if GameMgr.inCombat then
            gf:ShowSmallTips(CHS[3003841])
            return
        elseif Me:isLookOn() then
            gf:ShowSmallTips(CHS[3003842])
            return
        end

        local tip = string.match(csParam, "Tipnow=(.+)")
        if tip then
            gf:ShowSmallTips(tip)
        else
            ChatMgr:sendCurChannelMsg(csParam)
        end
    elseif csType == CONST_DATA.CS_TYPE_DLG then
        if GameMgr.inCombat or Me:isLookOn() then
            for _, v in ipairs(FightNeedCloseDlg) do
                if string.match(csParam, v) then
                    if GameMgr.inCombat then
                        gf:ShowSmallTips(CHS[3003841])
                    elseif Me:isLookOn() then
                        gf:ShowSmallTips(CHS[3003842])
                    end

                    return
                end
            end
        end

        if csParam == "PartyShopDlg" then
            if Me:queryBasic("party/name") == "" then
                gf:ShowSmallTips(CHS[3003843])
                return
            end

            gf:CmdToServer("CMD_REFRESH_PARTY_SHOP", { type = 0 })
        elseif csParam == "ArenaStoreDlg" then
            ArenaMgr:openArenaStore()
        elseif csParam == "OnlineMallVIPDlg" then
            if DlgMgr.dlgs["OnlineMallTabDlg"] then
                -- 如果OnlineMallTabDlg打开
                local dlg = DlgMgr.dlgs["OnlineMallTabDlg"]
                dlg:onSelected(dlg:getControl("VIPCheckBox"))
                dlg:setSelectDlg("OnlineMallTabDlg")
            else
                OnlineMallMgr:openOnlineMall("OnlineMallVIPDlg")
            end
        elseif csParam == "OnlineGiftDlg"
              or csParam == "DailySignDlg" then
            GiftMgr:openGiftDlg(csParam)
        elseif string.match(csParam, "OnlineMallDlg.*")then
            local selectName = string.match(csParam, "OnlineMallDlg=(.*)")
            if selectName then
                OnlineMallMgr:openOnlineMall("OnlineMallDlg", nil, {[selectName] = 1})
            else
                OnlineMallMgr:openOnlineMall("OnlineMallDlg")
            end
        elseif string.match(csParam, "PartyShopDlg.*")then
            -- 帮派商店需要发消息给服务器，有服务器通知打开对话框
            PartyMgr:refreshPartyShop(0)
            local selectName = string.match(csParam, "PartyShopDlg=(.*)")
            if selectName then
                PartyMgr:setPartyShopSelectItem(selectName)
            end
        elseif string.match(csParam, "JuBaoZhaiDlg.*")then
            -- 虽然 JuBaoZhaiDlg 界面已经替换了，但是防止服务器下发旧的，依然保留。该情况不会打开界面
            local param = csParam
            local paramList = gf:split(param, "=")
            if paramList and paramList[2] then
                local snapshotInfo = gf:split(paramList[2], ":")
                TradingMgr:tradingSnapshot(snapshotInfo[1], "snapshot", 1)
            end
        elseif string.match(csParam, "ChargeGiftPerMonthDlg") then
            GiftMgr:setLastIndex("WelfareButton16")
            local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
            dlg:onGiftsButton(dlg:getControl("GiftsButton"))
        elseif string.match(csParam, "RenameDiscountDlg") then
            GiftMgr:setLastIndex("WelfareButton18")
            local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
            dlg:onGiftsButton(dlg:getControl("GiftsButton"))
        elseif string.match(csParam, "WelfareDlg.*")then
            local param = csParam
            local paramList = gf:split(param, "=")
            if paramList and paramList[2] and paramList[2] == CHS[4200324] then
                GiftMgr:setLastIndex("WelfareButton8")
                local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
                dlg:onGiftsButton(dlg:getControl("GiftsButton"))
            elseif paramList and paramList[2] and paramList[2] == CHS[4200333] then
                GiftMgr:setLastIndex("WelfareButton14")
                local dlg = DlgMgr:getDlgByName("SystemFunctionDlg")
                dlg:onGiftsButton(dlg:getControl("GiftsButton"))
            end
		elseif string.match(csParam, "FriendDlg.*")then
            -- 邮件中聚宝斋
            local param = csParam
            local paramList = gf:split(param, "=")
            if paramList[2] then
                local info = json.decode(paramList[2])
                DlgMgr:closeDlg("SystemMessageShowDlg")
                local friend = FriendMgr:getFriendByGid(info.gid)
                local dlg = FriendMgr:openFriendDlg()
                if friend then
                    local data = {name = friend:queryBasic("char"), gid = info.gid, icon = friend:queryBasicInt("icon")}
                    dlg:setChatInfo(data)
                else
                    dlg:setChatInfo(info)
                end
                dlg:sendMsg(string.format(CHS[4300254], Me:queryBasic("name")))
			end
        else
            local param = csParam
            local paramList = gf:split(param, "=")
            if paramList and #paramList > 0
                and not cc.FileUtils:getInstance():isFileExist(string.format("dlg/%s.luac", paramList[1]))
                and not cc.FileUtils:getInstance():isFileExist(string.format("dlg/%s.lua", paramList[1])) then
                return
            end
           DlgMgr:openDlgWithParam(paramList)
        end
    end

    return csType
end

-- 处理带有url的字符串
function gf:processUrlTypeStr(str, orgStr, dlgName)
    local paraTable = {}
    local para, url = string.match(str, "(.+)http(.+)")
    if not para and not url then
        -- 说明str中没有"http",没有参数，认为str为url
        url = str
    else
        url = "http" .. url

        local paraArray = string.split(para, "|")
        if not paraArray then
            paraArray = {para}
        end

        for i = 1, #paraArray do
            local type, pa = string.match(paraArray[i], "(.+)=(.+)")
            paraTable[type] = tonumber(pa)
        end
    end

    local chsDes = string.match(orgStr, "#url(.*)%[") or ""

    local para
    if paraTable["SafeLock"] == 1 then
        para = { dlgName = dlgName, checkSafeLock = (paraTable["SafeLock"] == 1) }
    end

    if paraTable["GatherAccount"] == 1 and gf:isAndroid() then
        -- 安卓需要平台上报(游戏标识,渠道编号,渠道账号)
        url = url .. "?" .. string.format(CHS[7150036], "wd", LeitingSdkMgr.loginInfo.channelNo, LeitingSdkMgr.loginInfo.userId, string.lower(gfGetMd5(string.format("%s%%%s%%%s%%%s", LeitingSdkMgr.loginInfo.channelNo, "wd", LeitingSdkMgr.loginInfo.userId, "leiting"))))
        gf:openUrlByType(OPEN_URL_TYPE.DEFAULT, url, chsDes, para)
    else
        if paraTable["AccessType"] then
            gf:openUrlByType(paraTable["AccessType"], url, chsDes, para)
        else
            gf:openUrlByType(OPEN_URL_TYPE.DEFAULT, url, chsDes, para)
        end
    end
end

-- 打开url
-- type = 1, 离开游戏使用默认浏览器打开
-- type = 2, 使用游戏内界面打开(webView)
function gf:openUrlByType(type, url, chs, para)
    local function _openUrlByType(type, url, chs)
    if type and tonumber(type) == OPEN_URL_TYPE.WEB_DLG then
        DlgMgr:openDlgEx("WebDlg", {url = url})
    elseif type and tonumber(type) == OPEN_URL_TYPE.WSQ_BBS then     -- 若已经登录，需要自动登录，否则游客模式
        CommunityMgr:openCommunityDlgByUrl(url)
    else
        gf:confirm(string.format(CHS[7150034], chs),function ()
            DeviceMgr:openUrl(url)
        end)
    end
    end

    if para and para.checkSafeLock and para.dlgName and SafeLockMgr:isToBeRelease() then
        -- 需要检测安全锁
        SafeLockMgr:addModuleContinueCb(para.dlgName, function(dlg)
            _openUrlByType(type, url, chs)
        end)
    else
        _openUrlByType(type, url, chs)
    end
end

-- 设置小红点缩放比例
function gf:setRedDotScale(ctrl, scale)
    local curRedDot = ctrl:getChildByTag(Const.TAG_RED_DOT)
    if not curRedDot then
        return
    end

    curRedDot:setScale(scale)

    if ctrl and ctrl.requestDoLayout and type(ctrl.requestDoLayout) == "function" then
        ctrl:requestDoLayout()
    end
end

function gf:setRedDotBlink(ctrl)
    if nil == ctrl or "userdata" ~= type(ctrl) then
        Log:W("can not find the widgt : " .. ctrl)
        return
    end

    -- 判断是否存在小红点
    local curRedDot = ctrl:getChildByTag(Const.TAG_RED_DOT)
    if nil == curRedDot then
        return
    end

    curRedDot:stopAllActions()
    local fadeIn = cc.FadeIn:create(0.3)
    local delay = cc.DelayTime:create(0.3)
    local fadeOut = cc.FadeOut:create(0.3)
    local eveAct = cc.RepeatForever:create(cc.Sequence:create(fadeIn, delay, fadeOut))
    curRedDot:runAction(eveAct)
    --[[
    local blinkAct = cc.Blink:create(1, 2)
    local eveAct = cc.RepeatForever:create(blinkAct)
    curRedDot:runAction(eveAct)
    --]]
end

-- 给图标添加小红点
function gf:setCtrlRedDot(ctrl)
    if nil == ctrl or "userdata" ~= type(ctrl) then
        Log:W("can not find the widgt : " .. ctrl)
        return
    end

    -- 判断是否存在小红点
    local curRedDot = ctrl:getChildByTag(Const.TAG_RED_DOT)
    if nil ~= curRedDot then
        return curRedDot
    end

    -- 创建小红点
    local redDot = cc.Sprite:create(ResMgr.ui.red_dot)
    redDot:setTag(Const.TAG_RED_DOT)
    ctrl:addChild(redDot)

    local ctrlContentSize = ctrl:getContentSize()
    gf:align(redDot, ctrlContentSize, ccui.RelativeAlign.alignParentTopRight)

    return redDot
end

-- 移除小红点
function gf:removeCtrlRedDot(ctrl, isCleanup)
    if nil == ctrl or "userdata" ~= type(ctrl) then
        return
    end

    -- 获取小红点
    local redDot = ctrl:getChildByTag(Const.TAG_RED_DOT)
    if nil ~= redDot then
        -- 移除
        redDot:removeFromParentAndCleanup(isCleanup)

        if not isCleanup then
            -- 如果没有清除数据，则返回小红点
            return redDot
        end
    end
end

-- 在头像上添加跨服标识
function gf:addKuafLogo(ctrl, notScale)
    if nil == ctrl or "userdata" ~= type(ctrl) then
        Log:W("can not find the widgt : " .. ctrl)
        return
    end

    -- 判断是否已创建
    local img = ctrl:getChildByTag(Const.TAG_KUAF_LOGO)
    if img then
        return
    end

    -- 创建
    local img = cc.Sprite:create(ResMgr.ui.kuaf_logo)
    if not notScale then
        img:setScale(0.8, 0.8)
    end

    img:setTag(Const.TAG_KUAF_LOGO)
    ctrl:addChild(img)

    local ctrlContentSize = ctrl:getContentSize()
    gf:align(img, ctrlContentSize, ccui.RelativeAlign.alignParentTopRight)
end

-- 移除跨服标识
function gf:removeKuafLogo(ctrl)
    if nil == ctrl or "userdata" ~= type(ctrl) then
        return
    end

    local img = ctrl:getChildByTag(Const.TAG_KUAF_LOGO)
    if img then
        -- 移除
        img:removeFromParent()
    end
end

-- 深度复制表结构，仅限表结构
function gf:deepCopy(from)
    if type(from) ~= "table" then
        return
    end

    return clone(from)
end

function gf:sendDoActionToBattleSimulator(msg, data)
    BattleSimulatorMgr:sendCombatDoActionToBattleSimulator(msg, data)
end

-- 使用某个字符拼接字符串
function gf:makeStringWithSplitChar(table, splitChar)
    local str = ""
    str = table[1]
    for i = 2, #table do
        str = str .. splitChar
        str = str .. table[i]
    end

    return str
end

-- 创建一个相同字符的拼接字符串
function gf:makeSimilarStringWithSplitChar(similarChar, count, splitChar)
    local str = ""
    str = similarChar
    for i = 2, count do
        str = str .. splitChar
        str = str .. similarChar
    end

    return str
end

-- delims 分割符表    {%$...}
-- 返回 第一个元素没有分割符，其他元素有带有分隔符的
function gf:splitBydelims(s, delims)
    local index = 1
    local splitTable = {}
    local pos = 1

    while index <= string.len(s) do
        local charValue = string.sub(s, index, index)
        local delimLength = self:valueIsInTable(s, index, delims)

        if delimLength then
            local str = string.sub(s, pos, index - 1)
            table.insert(splitTable, str)
            pos =  index
            index = index + delimLength - 1
        end

        index = index + 1
    end

    table.insert(splitTable, string.sub(s, pos))
    return splitTable
end

function gf:valueIsInTable(s, index, table)
    for i = 1 , #table do
        local lenth = string.len(table[i])
        local str = string.sub(s, index, index + lenth - 1)
        if str == table[i] then
            return lenth
        end
    end

    return nil
end

-- 是否是 ios
function gf:isIos()
    if not gf.platform then
        gf.platform = cc.Application:getInstance():getTargetPlatform()
    end

    return gf.platform == cc.PLATFORM_OS_IPAD or gf.platform == cc.PLATFORM_OS_IPHONE
end

-- 是否是 android
function gf:isAndroid()
    if not gf.platform then
        gf.platform = cc.Application:getInstance():getTargetPlatform()
    end

    return gf.platform == cc.PLATFORM_OS_ANDROID
end

-- 是否是 win
function gf:isWindows()
    if not gf.platform then
        gf.platform = cc.Application:getInstance():getTargetPlatform()
    end

    return gf.platform == cc.PLATFORM_OS_WINDOWS
end

-- 是否是8方向的角色
function gf:has8Dir(icon)
    if has8DirIcon[icon] ~= nil then
        return has8DirIcon[icon]
    end

    if icon > 860000 and icon < 880000 then
        -- 套装形象含有 8 方向
        return true
    end

    return false
end

-- 将限制时间转换成文本(最小单位为天)
function gf:converToLimitedTimeDay(gift)
    local str = ""
    local day = 0

    -- 由于client和server的serverTime存在着延迟，所以gf:getServerTime()需要补偿5s
    local limitTime = -gift - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)

    if tonumber(gift) == 2 then
        str = CHS[3003844]
        day = 9999
    elseif limitTime > 0 then
        day = math.ceil(limitTime / (ONE_DAY))
        -- 限制交易时间上限为60，向上取整可能误差导致61
        if day > Const.LIMIT_MIX then day = Const.LIMIT_MIX end

        if day >= 1 then
            str = str .. tostring(day) .. CHS[3003845]
        end
    end

    if str ~= "" then
        str = CHS[3003848] .. str
        return str, day
    end

    return "", day
end

-- 将限制时间转换成文本
function gf:converToLimitedTime(gift)
    local str = ""
    local day = 0
    local hour = 0
    local min = 0

    -- 由于client和server的serverTime存在着延迟，所以gf:getServerTime()需要补偿5s
    local originLimitTime = -gift - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
    local limitTime = originLimitTime

    if tonumber(gift) == 2 then
        str = CHS[3003844]
        day = 9999
    elseif limitTime > 0 then
        day = math.ceil(limitTime / (ONE_DAY))
        -- 限制交易时间上限为60，向上取整可能误差导致61
        if day > Const.LIMIT_MIX then day = Const.LIMIT_MIX end
        limitTime = limitTime % (ONE_DAY)
        hour = math.ceil(limitTime / (60 * 60))
        limitTime = limitTime % (60 * 60)
        min = 1
        if limitTime / 60 < 1 then
            min = 1
        else
            min = math.ceil(limitTime / 60)
        end

        if day > 1 then
            str = str .. tostring(day) .. CHS[3003845]
        elseif hour > 1 then
            str = str .. tostring(hour) .. CHS[3003846]
        elseif min > 0 then
            str = str .. tostring(min) .. CHS[3003847]
        end

        -- 特殊情况处理（整天/整小时）{math.ceil操作导致无法确认是/不是向上取整得到的一天/一小时}
        if originLimitTime == ONE_DAY then
            str = tostring(day) .. CHS[3003845]
        elseif originLimitTime == ONE_HOUR then
            str = tostring(hour) .. CHS[3003846]
        end
    end

    if str ~= "" then
        str = CHS[3003848] .. str
        return str, day, hour, min
    end

    return "", day, hour, min
end

-- 将限时时间转换成文本
function gf:convertTimeLimitedToStr(deadline)
    local str = ""
    local day = 0
    local hour = 0
    local min = 0

    -- 由于client和server的serverTime存在着延迟，所以gf:getServerTime()需要补偿5s
    local originLimitTime = deadline - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
    local limitTime = originLimitTime
    if limitTime > 0 then
        day = math.ceil(limitTime / (ONE_DAY))
        -- 限制交易时间上限为60，向上取整可能误差导致61
        if day > Const.LIMIT_MIX then day = Const.LIMIT_MIX end
        limitTime = limitTime % (ONE_DAY)
        hour = math.ceil(limitTime / (60 * 60))
        limitTime = limitTime % (60 * 60)
        min = 1
        if limitTime / 60 < 1 then
            min = 1
        else
            min = math.ceil(limitTime / 60)
        end

        if day > 1 then
            str = str .. tostring(day) .. CHS[3003845]
        elseif hour > 1 then
            str = str .. tostring(hour) .. CHS[3003846]
        elseif min > 0 then
            str = str .. tostring(min) .. CHS[3003847]
        end

        -- 特殊情况处理（整天/整小时）{math.ceil操作导致无法确认是/不是向上取整得到的一天/一小时}
        if originLimitTime == ONE_DAY then
            str = tostring(day) .. CHS[3003845]
        elseif originLimitTime == ONE_HOUR then
            str = tostring(hour) .. CHS[3003846]
        end
    end

    if str ~= "" then
        str = CHS[7002285] .. str
        return str, day, hour, min
    end

    return "", day, hour, min
end

-- 添加ui层级动画效
-- icon 光效id
-- pos 播放位置
function gf:addMagicToUILayer(iconOrArmature, pos)
    local uiLayer = gf:getUILayer()
    local magic = nil
    local isArmature = false

    if "number" ~= type(iconOrArmature) then
        isArmature = true
    end

    if isArmature then
        magic = ArmatureMgr:createArmature(iconOrArmature.name)
    else
        magic = gf:createSelfRemoveMagic(iconOrArmature)
    end

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
        end
    end

    local toPos = uiLayer:convertToNodeSpace(pos)
    magic:setPosition(pos)

    -- 需要对特效进行缩放
    local designSize = cc.Director:getInstance():getOpenGLView():getDesignResolutionSize()
    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local deviceWidth = frameSize["width"]
    local deviceHeight = frameSize["height"]

    if designSize["height"] == 768 then
        magic:setScaleY(810 / 640)
    else
        if deviceHeight == 768 then
            magic:setScaleY(1 / Const.UI_SCALE + 0.03)
        else
            magic:setScaleY(1 / Const.UI_SCALE)
        end
    end

    uiLayer:addChild(magic)
    if isArmature then
        magic:getAnimation():setMovementEventCallFunc(func)
        magic:getAnimation():play(iconOrArmature.action)
    end

    return magic
end

-- 在当前UILayer指定位置创建龙骨动画并播放
-- icon 龙骨动画id
-- armatureName 动画名
-- actName 动作名
-- px,py UILayer位置
-- times 动画播放次数
function gf:createDragonBonesToUILayer(icon, armatureName, actName, px, py, times)
    if not px then
        px = 0
    end

    if not py then
        py = 0
    end

    if not times then
        times = 1
    end

    local uiLayer = gf:getUILayer()

    local dragonArmature = uiLayer:getChildByTag(icon)
    if dragonArmature then
        uiLayer:removeChildByTag(icon)
        DragonBonesMgr:removeUIDragonBonesResoure(icon, armatureName)
    end

    local dragonArmature = DragonBonesMgr:createUIDragonBones(icon, armatureName)
    local nodeDragonArmature = tolua.cast(dragonArmature, "cc.Node")
    uiLayer:addChild(nodeDragonArmature)
    local layerSize = uiLayer:getContentSize()
    nodeDragonArmature:setPosition(layerSize.width / 2 + px, layerSize.height / 2 + py)
    nodeDragonArmature:setTag(icon)

    DragonBonesMgr:toPlay(dragonArmature, actName, times)
end

-- 图片左上角增加npc标识
function gf:addNpcLogo(ctrl)
    if not ctrl then return end
    local sp = ctrl:getChildByName("NpcLogo")
    if sp then return end
    local sp = cc.Sprite:create(ResMgr.ui.npc_image_tag)
    local size = ctrl:getContentSize()
    local spSize = sp:getContentSize()
    sp:setAnchorPoint(0, 1)
    sp:setPosition(0, size.height)
    sp:setName("NpcLogo")
    ctrl:addChild(sp)
end

-- 当前时间跟目标时间是否是同一天
function gf:isSameDay(curTi, ti)
    if math.abs(curTi - ti) > 24 * 3600
        or gf:getServerDate("%d", curTi) ~= gf:getServerDate("%d", ti) then
        return false
    end

    return true
end

-- 是否是同一天，以05:00为准
function gf:isSameDay5(t1, t2)
    return gf:isSameDay(t1 - 18000, t2 - 18000);
end

function gf:getThisMonthDays(time)
    local y = tonumber(gf:getServerDate("%y", time))
    local m = tonumber(gf:getServerDate("%m", time))
    local mDay = 31
    if m == 2 then
        if y % 400 == 0 or (y % 100 ~= 0 and y % 4 == 0) then
            mDay = 29
        else
            mDay = 28
        end
    elseif m <= 7 then
        if m % 2 == 0 then
            mDay = 30
        end
    elseif m % 2 == 1 then
        mDay = 30
    end

    return mDay
end

-- 解析菜单项
function gf:parseMenu(content, npcName)
    local menu = {}
    local len = string.len(content)
    local text = ""
    local instruction = ""
    local count = 0
    local ignorenext = false
    local tempMenu = {}
    for pos = 1, len, 1 do
        if ignorenext then
            ignorenext = false
        else
            local byte1, byte2 = string.byte(content, pos, pos + 1)
            local ch1 = string.char(byte1)
            if gf:isUTF8FirstChar(byte1) or gf:isUTF8LastChar(byte1) then
                text = text .. ch1
            else
                if ch1 == '\r' then
                elseif ch1 == '[' then
                    instruction = instruction .. text
                    text = ch1
                elseif ch1 == ']' then
                    text = text .. ch1
                    text, _ = string.gsub(text,"\n","")
                    if text ~= "[DEFAULT/DEFAULT]" then
                        count = count + 1
                    end
                    if gf:findStrByByte(text, CHS[3003849]) then  -- "【"
                        table.insert(tempMenu, {text = text, order = TaskMgr:getTaskType(text) + count * 0.01})
                    else
                        local maxNumOfTaskType = 0
                        for k, v in pairs(TASK_TYPE) do
                            if v > maxNumOfTaskType then
                                maxNumOfTaskType = v
                            end
                        end

                        table.insert(tempMenu, {text = text, order = maxNumOfTaskType + count})
                    end
                    text = ""
                    if byte2 ~= nil then
                        if string.char(byte2) == '\n' then
                            ignorenext = true
                        end
                    end
                else
                    text = text .. ch1
                end
            end
        end
    end

    if string.len(text) > 0 then
        instruction = instruction .. text
    end

    menu.count = count
    menu.instruction = instruction

    if npcName and NpcMenuOrder[npcName] then
        local menuOrders = NpcMenuOrder[npcName]
        for i, v in pairs(tempMenu) do
            for key, oInfo in pairs(menuOrders) do
                if string.match( v.text, key) then
                    if oInfo.order then
                        v.order = oInfo.order
                    end

                    if oInfo.addOrder then
                        v.order = v.order + oInfo.addOrder
                    end
                end
            end
        end
    end

    table.sort(tempMenu, function(l, r)
        local lOrder = math.floor(l.order)
        local rOrder = math.floor(r.order)

        if lOrder < rOrder then return true end
        if lOrder > rOrder then return false end

        return l.order < r.order
    end)

    for i, v in pairs(tempMenu) do
        menu[i] = v.text

    end


    return menu
end

-- 1、 菜单条目格式：[菜单条目文字] 或 [!菜单条目文字] 或 [!*菜单条目文字]
-- ! 表示需要携带一个字符串参数
-- * 表示需要携带的字符串参数输入时以密码方式输入
-- !* 均不实现在菜单栏
-- 2、菜单条目文字中不会含有\n
function gf:parseMenuText(text)
    local len = string.len(text)
    if nil == text or len <= 2 then return end

    if gf:getStringChar(text,1) ~= '[' or gf:getStringChar(text,-1) ~= ']' then
        return
    end

    text = string.sub(text, 2, -2)
    local ch1 = gf:getStringChar(text, 1)

    local menuItemFlag = nil
    if ch1 == MENUITEM_FLAG.DIRECT_SELECTED then
        -- 直接被选择的标志
        menuItemFlag = MIF.DIRECT_SELECTED
    elseif ch1 == MENUITEM_FLAG.CRAY_DRAW then
        -- 灰色显示（不可选）
        menuItemFlag = MIF.CRAY_DRAW
    elseif ch1 == MENUITEM_FLAG.OKCANCEL then
        -- 弹出确定及取消按钮
        menuItemFlag = MIF.OKCANCEL
    elseif ch1 == MENUITEM_FLAG.PASSWORD then
        -- 密码显示
        menuItemFlag = MIF.PASSWORD
    else
        -- 默认
        menuItemFlag = MIF.NONE
    end

    -- 获取显示字符串
    local startPos = nil
    local ch1 = gf:getStringChar(text, 1)
    if  ch1 == MENUITEM_FLAG.DIRECT_SELECTED or
        ch1 == MENUITEM_FLAG.CRAY_DRAW or
        ch1 == MENUITEM_FLAG.OKCANCEL then
        startPos = 2
    else
        startPos = 1
    end

    local pos = gf:findStrByByte(text, '/')
    local endPos = nil
    if pos ~= nil then
        endPos = pos - 1
    else
        -- 获取内容
        local posTemp = gf:findStrByByte(text, '/') or 0
        local len = string.len(text)
        local format = nil
        for i = posTemp, len do
            if gf:getStringChar(text, i) == '#' then
                for _, v in ipairs(MENUITEM_FORMATS) do
                    local substr = string.sub(text, i, i+string.len(v)-1)
                    if v == substr then
                        format = v
                        posTemp = i
                    end
                end
            end
        end

        if menuItemFlag ~= MIF.NONE and format ~= nil then
            endPos = posTemp - 1
        else
            endPos = string.len(text)
        end
    end

    local strDraw = string.sub(text, startPos, endPos)

    -- 获取动作
    if nil ~= text then
        pos = gf:findStrByByte(text, '/')
        if pos ~= nil then
            startPos = pos + 1
        end
    end

    if nil ~= gf:findStrByByte(text, '/') then
        if format ~= nil then
            endPos = posTemp - 1
        else
            endPos = string.len(text)
        end
    end

    local action = string.sub(text, startPos, endPos)

    return strDraw, action
end

-- 播放成功或者失败光效
function gf:displaySuccessOrFaildMagic(isSuc)
    local  worldPos = {}
    worldPos.x = Const.WINSIZE.width / Const.UI_SCALE * 0.5
    worldPos.y = Const.WINSIZE.height / Const.UI_SCALE * 0.6
    if isSuc then
        --gf:addMagicToUILayer(ResMgr.magic.results_succed, worldPos)
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.results_succed.name, ResMgr.ArmatureMagic.results_succed.action, gf:getUILayer())
    else
        --gf:addMagicToUILayer(ResMgr.magic.results_failure, worldPos)
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.results_failure.name, ResMgr.ArmatureMagic.results_failure.action, gf:getUILayer())
    end
end

-- 冻屏效果
-- limitTime : 为冻屏期间两次点击的间隔，
--         如果这个值小于等于0 ，那么就自己调用gf:unfrozenScreen()解除冻屏吧！
-- totalTime : 冻屏时间上限 默认为5秒
function gf:frozenScreen(limitTime, opacity, totalTime, notResetWhenClick, zOrder)
    limitTime = limitTime or 0
    opacity = opacity or 0
    totalTime = totalTime or 5000 -- 没有totalTime时，默认设置最大冻屏时间上限为5秒
    zOrder = zOrder or Const.ZORDER_TOPMOST + 1

    local uiLayer = gf:getUILayer()
    local frozenScreenLayer = uiLayer:getChildByTag(Const.TAG_FROZEN)
    if nil ~= frozenScreenLayer then
        -- 如果已经存在
        frozenScreenLayer:setVisible(true)
            frozenScreenLayer:setOpacity(opacity)


        frozenScreenLayer.lastTouchTime = gfGetTickCount()
        frozenScreenLayer.isEnd = nil
        frozenScreenLayer.limitTime = limitTime
        frozenScreenLayer.totalTime = totalTime
        frozenScreenLayer.frozenBeginTime = gfGetTickCount()
        frozenScreenLayer.notResetWhenClick = notResetWhenClick
        frozenScreenLayer:setLocalZOrder(zOrder)
        if "function" == type(frozenScreenLayer.onDealTouch) then
            frozenScreenLayer.onDealTouch()
        end

        return frozenScreenLayer
    end

    -- 创建层
    frozenScreenLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 0))
    frozenScreenLayer:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    frozenScreenLayer:setTag(Const.TAG_FROZEN)
        frozenScreenLayer:setOpacity(opacity)

    uiLayer:addChild(frozenScreenLayer)
    frozenScreenLayer:setLocalZOrder(zOrder) -- 设置为最高层次

    -- 添加回调函数
    local function onDealTouch(touch, event)
        if not frozenScreenLayer:isVisible() then
            return false
        end

        if 0 >= frozenScreenLayer.limitTime then
            return true
        end

        local frozenBeginTime = frozenScreenLayer.frozenBeginTime
        local totalTime = frozenScreenLayer.totalTime
        if frozenScreenLayer.isEnd or gfGetTickCount() - frozenBeginTime >= totalTime then
            return false
        end

        if frozenScreenLayer.notResetWhenClick and touch then
            return true
        end

        -- 解冻
        local func = cc.CallFunc:create(function()
            gf:unfrozenScreen()
        end)

        local leftTime = math.max(0, totalTime - gfGetTickCount() + frozenBeginTime) / 1000
        local delayAction = cc.DelayTime:create(math.min(frozenScreenLayer.limitTime / 1000, leftTime))
        frozenScreenLayer:stopAllActions()
        frozenScreenLayer:runAction(cc.Sequence:create(delayAction, func))

        return true
    end

    -- 添加点击事件
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onDealTouch, cc.Handler.EVENT_TOUCH_BEGAN)
    local dispatcher = frozenScreenLayer:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, frozenScreenLayer)
    frozenScreenLayer:setAnchorPoint(0, 0)
    frozenScreenLayer:setPosition(0, 0)
    frozenScreenLayer.lastTouchTime = gfGetTickCount()
    frozenScreenLayer.onDealTouch = onDealTouch
    frozenScreenLayer.limitTime = limitTime
    frozenScreenLayer.totalTime = totalTime
    frozenScreenLayer.frozenBeginTime = gfGetTickCount()
    frozenScreenLayer.notResetWhenClick = notResetWhenClick
    frozenScreenLayer.isEnd = nil

    -- 先执行一次
    onDealTouch()

    return frozenScreenLayer
end

-- 解除冻屏效果
function gf:unfrozenScreen()
    local uiLayer = gf:getUILayer()
    local frozenScreenLayer = uiLayer:getChildByTag(Const.TAG_FROZEN)
    if not frozenScreenLayer then return end

    frozenScreenLayer.isEnd = true

    local fadeAction = cc.FadeOut:create(0.5)
    local func = cc.CallFunc:create(function()
        frozenScreenLayer:setVisible(false)
    end)

    frozenScreenLayer:stopAllActions()
    frozenScreenLayer:runAction(cc.Sequence:create(fadeAction, func))
end

-- 检测名称是否合法,不能与gid相似
function gf:checkRename(name)
    if gf:getTextLength(name) == 10 then
        local index = 1
        local byteValue = string.byte(name, index)
        local len = string.len(name)
        local retValue = false
        while len >= index do
            local byteValue = string.byte(name, index)

            if (byteValue >= 48 and byteValue <= 57) or
                (byteValue >= 65 and byteValue <= 70) or
                (byteValue >= 97 and byteValue <= 102) then
                index = index + 1
            else
                retValue = true
                break
            end
        end

        return retValue
    end

    return true
end

-- 上传错误信息
function gf:ftpUploadError(err)
    if DistMgr and DistMgr:curIsTestDist() and string.match(err, "ASSERT FAILED ON LUA EXECUTE:") then
        gf:ftpUploadLog(err)
    else
        gf:ftpUploadEx(err)
    end
end

-- 上传客户端错误到服务器
function gf:ftpUploadEx(strErr)
    local ftpUrl = cc.UserDefault:getInstance():getStringForKey("FtpHost", "")
    local user = cc.UserDefault:getInstance():getStringForKey("FtpUser", "atm")
    local pwd = cc.UserDefault:getInstance():getStringForKey("FtpPwd",  "")
    local port = cc.UserDefault:getInstance():getStringForKey("FtpPort",  "")
    local account = cc.UserDefault:getInstance():getStringForKey("user",  "")

    local fun = 'ftpUploadEx'
    local v = fun .. ":nil"
    if gf:isAndroid() then
        local luaj = require('luaj')
        local className = 'com/gbits/CrashHandler'
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;)V"
        local args = {}
        args[1] = ftpUrl
        args[2] = port
        args[3] = user
        args[4] = pwd
        args[5] = account
        args[6] = strErr
        local ok = luaj.callStaticMethod(className, fun, args, sig)
        v = tostring(ok)

    elseif gf:isIos() then
        local luaoc = require('luaoc')
        local args = {account = account, err = strErr}
        local ok = luaoc.callStaticMethod('UncaughtExceptionHandler', fun, args)
        v = tostring(ok)
    else
        local dlg = DlgMgr:openDlg("GMDebugTipsDlg")
        if dlg ~= nil then
            dlg:setErrStr(strErr)
        end
    end
end

-- 上传客户端错误到服务器
function gf:ftpUploadLog(strErr, count)
    if not gf:gfIsFuncEnabled(FUNCTION_ID.FTP_UPLOAD_LOG) then return end

    local ftpUrl = cc.UserDefault:getInstance():getStringForKey("FtpHost", "")
    local user = cc.UserDefault:getInstance():getStringForKey("FtpUser", "atm")
    local pwd = cc.UserDefault:getInstance():getStringForKey("FtpPwd",  "")
    local port = cc.UserDefault:getInstance():getStringForKey("FtpPort",  "")
    local account = cc.UserDefault:getInstance():getStringForKey("user",  "")

    if not count then count = 200 end

    local fun = 'ftpUploadLog'
    local v = fun .. ":nil"
    if gf:isAndroid() then
        local luaj = require('luaj')
        local className = 'com/gbits/CrashHandler'
        local sig = "(Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;Ljava/lang/String;I)V"
        local args = {}
        args[1] = ftpUrl
        args[2] = port
        args[3] = user
        args[4] = pwd
        args[5] = account
        args[6] = strErr
        args[7] = count
        local ok = luaj.callStaticMethod(className, fun, args, sig)
        v = tostring(ok)
    elseif gf:isIos() then
        local luaoc = require('luaoc')
        local args = {account = account, err = strErr}
        local ok = luaoc.callStaticMethod('UncaughtExceptionHandler', fun, args)
        v = tostring(ok)
    else
        local dlg = DlgMgr:openDlg("GMDebugTipsDlg")
        if dlg ~= nil then
            dlg:setErrStr(strErr)
    end
    end
end



-- 是否是贵重物品
function gf:isExpensive(item, isPet)
    if isPet then
        if PetMgr:isTimeLimitedPet(item) then
            return false
        end

        -- 是否变异，神兽宠物判断
        local rank = item:queryInt('rank')
        if rank == Const.PET_RANK_ELITE or rank == Const.PET_RANK_EPIC then
            -- 存在非变异的宠物
            return true
        end

        if PetMgr:isYuhuaCompleted(item) then return true end

        local mount_type = item:queryInt("mount_type")
        local level = item:queryInt("capacity_level")

        -- 精怪/御灵
        if (MOUNT_TYPE.MOUNT_TYPE_JINGGUAI == mount_type or MOUNT_TYPE.MOUNT_TYPE_YULING == mount_type) and level >= 6 then
            return true
        end

        -- 强化度
        local petPolar = item:queryBasicInt("polar")
        local level = 0
        if petPolar > 0 then
            level = item:queryInt("mag_rebuild_level")
        else
            level = item:queryInt("phy_rebuild_level")
        end
        if level >= 5 then return true end
    end

    -- 限时不是贵重物品
    if InventoryMgr:isTimeLimitedItem(item) then
        return false
    end

    if item.item_type == ITEM_TYPE.EQUIPMENT then
        -- 如果是装备
        if EquipmentMgr:isJewelry(item) then
            -- 附加属性所有技能上升 >= 5或者所有相性>=3则是贵重物品
            if item.extra then
                if EquipmentMgr:jewelryIsExpensive(item) then
                    return true
                end
            end
        else
            -- 改造等级大于等于6
            if item.rebuild_level and item.rebuild_level >= 6 then
                return true
            end
        end
    end

    -- 法宝到达10级
    if item.item_type == ITEM_TYPE.ARTIFACT then
        if item.level >= 10 then
            return true
        end
    end

    return false
end

-- 未找到的情况，返回原字符串和false
function gf:replaceStr(str, patt, retStr)
    local startPos, endPos = gf:findStrByByte(str, patt)
    if not startPos then
        return str, false
    end

    local str1 = string.sub(str, 1, startPos - 1)
    local str2 = string.sub(str, endPos + 1, -1)
    return str1 .. retStr .. str2, true
end

-- 根据字节来查找字符串
function gf:findStrByByte(str, patt, s)
    local startPos = s or 1
    local charF, charE
    for i = startPos, string.len(str) - string.len(patt) + 1 do
        local flag = true
        for j = 1, string.len(patt) do
            if string.byte(str, i + j - 1) ~= string.byte(patt, j) then
                flag = false
                break
            end
        end

        if flag then
            -- 找到了
            charF = i
            charE = i + string.len(patt) - 1
            break
        end
    end

    return charF, charE
end

function gf:getGiftInfo()
    local giftKey = Me:queryBasicInt("gift_key")
    if not giftKey or "number" ~= type(giftKey) then
        return -1, -1
    end

    local decile = math.floor(giftKey % 100 / 10)
    local value = 0
    if 1 == decile then
        value = Me:getId()
    elseif 2 == decile then
        value = Me:queryBasicInt("extra_life")
    elseif 3 == decile then
        value = Me:queryBasicInt("extra_mana")
    elseif 4 == decile then
        value = Me:queryBasicInt("backup_loyalty")
    elseif 5 == decile then
        value = Me:queryBasicInt("double_points")
    elseif 6 == decile then
        value = Me:queryBasicInt("store_exp")
    elseif 7 == decile then
        value = Me:queryBasicInt("exp")
    elseif 8 == decile then
        value = Me:queryBasicInt("pot")
    elseif 9 == decile then
        value = Me:queryBasicInt("cash")
    elseif 0 == decile then
        value = 0
    end

    if value < 0 then
        -- 值不能小于 0
        value = -value
    end

    return giftKey, value
end

function gf:getGiftValue(ans)
    local giftKey = Me:queryBasicInt("gift_key")
    if not giftKey or "number" ~= type(giftKey) then
        return ans
    end

    local decile = math.floor(giftKey % 100 / 10)
    if 0 == decile then
        return ans
    end

    local value = 0
    if 1 == decile then
        value = Me:getId()
    elseif 2 == decile then
        value = Me:queryBasicInt("extra_life")
    elseif 3 == decile then
        value = Me:queryBasicInt("extra_mana")
    elseif 4 == decile then
        value = Me:queryBasicInt("backup_loyalty")
    elseif 5 == decile then
        value = Me:queryBasicInt("double_points")
    elseif 6 == decile then
        value = Me:queryBasicInt("store_exp")
    elseif 7 == decile then
        value = Me:queryBasicInt("exp")
    elseif 8 == decile then
        value = Me:queryBasicInt("pot")
    elseif 9 == decile then
        value = Me:queryBasicInt("cash")
    end

    if value < 0 then
        -- 值不能小于 0
        value = -value
    end

    return bit.bxor(value % 10000 + value % 10000 * 10000, ans)
end

-- 设置备用装备效果（置灰+蒙阴影）
function gf:addEffectForBackEquip(imgCtl)
    gf:grayImageView(imgCtl)
    local grayLayer = imgCtl:getChildByName("grayLayerForBackEquip")
    if not grayLayer then
        grayLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 50))
        grayLayer:setContentSize(imgCtl:getContentSize())
        grayLayer:setName("grayLayerForBackEquip")
        grayLayer:setOpacity(30)
        imgCtl:addChild(grayLayer)
    end
end

-- 移除备用装备阴影
function gf:removeEffectForBackEquip(imgCtl)
    local grayLayer = imgCtl:getChildByName("grayLayerForBackEquip")
    if grayLayer then
        grayLayer:removeFromParent()
    end
end

-- 蒙红效果
function gf:addRedEffect(imgCtrl)
    local redLayer = cc.LayerColor:create(cc.c4b(255, 0, 0, 50))
    redLayer:setContentSize(imgCtrl:getContentSize())
    redLayer:setName("redLayer")
    redLayer:setOpacity(100)
    imgCtrl:addChild(redLayer)
end

-- 移除蒙红效果
function gf:removeRedEffect(imgCtrl)
    local redLayer = imgCtrl:getChildByName("redLayer")
    if redLayer then
        redLayer:removeFromParent()
    end
end

-- 获取今天的服务器0点时间（也就是5点）
function gf:getServerTodayZeroTime()
    local curTimeList = gf:getServerDate("*t", self:getServerTime())
    local zeroTimeList = curTimeList
    zeroTimeList["hour"] = 5
    zeroTimeList["min"] = 0
    zeroTimeList["sec"] = 0

    local timeDiff = (GameMgr.serverTimeZone - GameMgr.clientTimeZone) * 3600
    return os.time(zeroTimeList) - timeDiff
end

-- 获取本周一服务0点时间
function gf:getServerCurMonDayZeroTime()
    local timeList = gf:getServerDate("*t", self:getServerTime())

    local day = timeList["day"]
    if timeList["wday"] == 1 then  -- 当前为周日，本周一在六天前
        day = day - 6
    elseif timeList["wday"] == 2 and timeList["hour"] < 5 then  -- 当前为周一，但尚未到5点，本周一在一周前
        day = day - 7
    else
        day = day - (timeList["wday"] - 2) --其他情况，本周一在(timeList["wday"] - 2)天前
    end

    timeList["day"] = day
    timeList["hour"] = 5
    timeList["min"] = 0
    timeList["sec"] = 0
    timeList["wday"] = 2

    local timeDiff = (GameMgr.serverTimeZone - GameMgr.clientTimeZone) * 3600
    return os.time(timeList) - timeDiff
end

function gf:getGenderChs(gender)
    if gender == GENDER_TYPE.MALE then
        return CHS[3000254]
    elseif gender == GENDER_TYPE.FEMALE then
        return CHS[3000257]
    else
        return CHS[2000534]
    end
end

-- 根据头像获取性别
function gf:getGenderByIcon(icon)
    local gender = "1"
    if icon == 6001 then
        gender = "1"
    elseif icon == 6002 then
        gender = "2"
    elseif icon == 6003 then
        gender = "2"
    elseif icon == 6004 then
        gender = "1"
    elseif icon == 6005 then
        gender = "1"
    elseif icon == 07001 then
        gender = "2"
    elseif icon == 07002 then
        gender = "1"
    elseif icon == 07003 then
        gender = "1"
    elseif icon == 07004 then
        gender = "2"
    elseif icon == 07005 then
        gender = "2"
    end

    return gender
end

function gf:getPolarAndGenderByIcon(icon)
    local gender = gf:getGenderByIcon(icon)
    return icon % 10, tonumber(gender)
end

-- 根据性别和相性获取头像
function gf:getIconByGenderAndPolar(gender, polar)
    local icon = 6001
    if gender == 1 then
        if polar == 1 then
            icon = 6001
        elseif polar == 2 then
            icon = 7002
        elseif polar == 3 then
            icon = 7003
        elseif polar == 4 then
            icon = 6004
        elseif polar == 5 then
            icon = 6005
        end
    else
        if polar == 1 then
            icon = 7001
        elseif polar == 2 then
            icon = 6002
        elseif polar == 3 then
            icon = 6003
        elseif polar == 4 then
            icon = 7004
        elseif polar == 5 then
            icon = 7005
        end
    end

    return icon
end

function gf:getIconNameByIcon(icon)
    local str
    local polar = icon % 10
    if polar == 1 then
        str = CHS[6000311]
    elseif polar == 2 then
        str = CHS[6000312]
    elseif polar == 3 then
        str = CHS[6000313]
    elseif polar == 4 then
        str = CHS[6000314]
    else
        str = CHS[6000315]
    end

    if gf:getGenderByIcon(icon) == "1" then
        str = str .. CHS[5000066]
    else
        str = str .. CHS[5000067]
    end

    return str
end

-- 是否显示套装
function gf:isShowSuit()
    local gameSetting = SystemSettingMgr:getSettingStatus("sight_scope")
    return GAME_EFFECT.LOW ~= gameSetting
end

-- 是否显示武器
function gf:isShowWeapon()
    local gameSetting = SystemSettingMgr:getSettingStatus("sight_scope")
    return GAME_EFFECT.LOW ~= gameSetting
end

-- 是否显示骑乘
function gf:isShowRidePet()
    local gameSetting = SystemSettingMgr:getSettingStatus("sight_scope")
    return GAME_EFFECT.LOW ~= gameSetting
end

-- 是否显示仙魔光效
function gf:isShowCharUpgradeMagic()
    local gameSetting = SystemSettingMgr:getSettingStatus("sight_scope")
    return GAME_EFFECT.LOW ~= gameSetting
end

-- 根据头像获取相性
function gf:getPloarByIcon(icon)
    local polar = 1
    if icon == 6001 or icon == 07001 then
        polar = 1
    elseif icon == 6002 or icon == 07002 then
        polar = 2
    elseif icon == 6003 or icon == 07003 then
        polar = 3
    elseif icon == 6004 or icon == 07004 then
        polar = 4
    elseif icon == 6005 or icon == 07005 then
        polar = 5
   end

    return polar
end


-- 根据长度来截取字符，超过用...表示
function gf:getTextByLenth(text, lenth)
    if self:getTextLength(text) > lenth then
        text = self:subString(text, lenth) .. "..."
    end

    return text
end

-- 根据字数来截取字符串，超过用...表示
function gf:getTextByNum(text, limitNum)
    local lenth, num = self:getTextLength(text)
    if num > limitNum then
        text = self:subStringByNum(text, limitNum) .. "..."
    end

    return text
end

function gf:getTextByCharLength(text, length)
    if #text > length then
        local newtext, hasLeft = self:subStringByCharLen(text, length)
        if hasLeft then
            text = newtext .. "..."
        else
            text = newtext
        end
    end
    return text
end

function gf:decodeURI(s)
    s = string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
    return s
end

function gf:encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

if string then
    string.split = function(s, p)
        local rt = {}
        string.gsub(s, '[^' .. p .. ']+', function(w) table.insert(rt, w) end)
        return rt
    end

    string.trim = function(s)
        return string.gsub(s, "^%s*(.-)%s*$", "%1")
    end

    string.isNilOrEmpty = function(s)
        return nil == s or "" == s
    end
end

function gf:getVersionValue(version)
    local b, e, ver = string.find(version, "^(%d+%.%d+)")
    if ver then
        local versionData = string.split(version, ".")
        if versionData and #versionData >= 3 then
            return ver, versionData[3]
        else
            return ver, "0"
        end
    end

    return "0", "0"
end

function gf:CheckMemory()
    if DeviceMgr:isLowMemory() and didReceiveMemoryWarnging and 'function' == type(didReceiveMemoryWarnging) then
        -- 触发内存警戒，尝试回收内存
        didReceiveMemoryWarnging()
    end
end

-- 判断一个函数c++是否生效
function gf:gfIsFuncEnabled(funcId)
    if 'function' == type(gfIsFuncEnabled) and 'number' == type(funcId) then
        return gfIsFuncEnabled(funcId)
    end

    return false
end

-- 数组是否为nil或无数据
function gf:isNullOrEmpty(o)
    if o and #o > 0 then
        return false
    else
        return true
    end
end

-- 计算身份证号校验码
function gf:getIdChecksum(id)
    if 'string' ~= type(id) then return end
    if 18 ~= #id then return end

    local sum = 0
    local coes = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2}
    local n
    for i = 1, #id - 1 do
        n = tonumber(id:sub(i, i))
        if not n then return end
        sum= sum + n * coes[i]
    end

    local index = sum % 11
    local values= { '1', '0', 'X', '9', '8', '7', '6', '5', '4', '3', '2' }
    return values[index + 1]
end

function gf:isLeapYear(year)
    year = tonumber(year)
    if not year then return false end
    if 0 == year % 100 then
        return 0 == year % 400
    else
        return 0 == year % 4
    end
end

-- 是否合法的身份证号
function gf:isValidIdCode(id)
    if 'string' ~= type(id) then return false end
    if 18 ~= #id and 15 ~= #id then return false end

    -- 取区域码
    local regionId = tonumber(id:sub(1, 2))
    if not regionId or not idReginCode[regionId] then return false end

    -- 取年月日
    local year = 0
    local mon = 0
    local day = 0
    if 18 == #id then
        year = tonumber(id:sub(7, 10)) or 0
        mon = tonumber(id:sub(11, 12)) or 0
        day = tonumber(id:sub(13, 14)) or 0
    elseif 15 == #id then
        year = 1900 + tonumber(id:sub(7, 8)) or 0
        mon = tonumber(id:sub(9, 10)) or 0
        day = tonumber(id:sub(11, 12)) or 0
    end
    if year <= 1900 or year >= 2100 then return false end
    if mon < 1 or mon > 12 then return false end

    local days = { 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31 }
    local checkDay = days[mon]
    if 2 == mon and gf:isLeapYear(year) then
        checkDay = 29
    end

    if day < 1 or day > checkDay then return false end
    if 15 == #id then return true end
    local checksum = gf:getIdChecksum(id)
    if not checksum then return false end
    return checksum:lower() == id:sub(18, 18):lower()
end

-- 获取当前帧的时间，避免一帧内频繁计算
function gf:getTickCount(checkUpdate)
    if checkUpdate or not self._curFrameTickCount then
        self._curFrameTickCount = gfGetTickCount()
    end

    if checkUpdate then
        if self._resetFrameCost then
            -- 需要重置帧消耗
            self._frameDetla = nil
            self._totalFrames = nil
            self._totalTime = nil
            self._lastFrameTickCount = nil
            self._resetFrameCost = nil
            self._lastCalcFrameTimes = nil
        end

        if self._lastFrameTickCount then
            self._frameDetla = math.min(math.max(self._curFrameTickCount - self._lastFrameTickCount, MIN_FRAME_TIME), MAX_FRAME_TIME)
        else
            self._frameDetla = 0
        end

        if self._frameDetla > 0 and self._frameDetla <= MAX_FRAME_TIME  then
            if not self._lastCalcFrameTimes then self._lastCalcFrameTimes = List.new() end
            local frontTime = 0
            if self._lastCalcFrameTimes:size() >= MOVE_COUNT then frontTime = self._lastCalcFrameTimes:popFront() end
            self._lastCalcFrameTimes:pushBack(self._frameDetla)

            -- self._totalFrames = (self._totalFrames or 0) + 1
            self._totalFrames = self._lastCalcFrameTimes:size()
            self._totalTime = (self._totalTime or 0) + self._frameDetla - frontTime
            self._avgTime = self._totalTime / self._totalFrames
        else
            self._totalFrames = 0
            self._totalTime = 0
            self._avgTime = 0
            self._lastCalcFrameTimes = nil
        end

        self._lastFrameTickCount = self._curFrameTickCount
    end

    return self._curFrameTickCount, self._frameDetla, self._totalFrames, self._totalTime, self._avgTime
end

-- 重置上一帧的时间
function gf:resetLastFrameTick()
    self._lastFrameTickCount = nil
end

-- 重置帧时间消耗及帧数
function gf:resetFrameCost()
    self._resetFrameCost = true
end

-- 计算ob从当前位置到(mapX, mapY)是否有路可走
function gf:findPath(ob, mapX, mapY, orgX, orgY)
    if mapX == nil or mapY == nil then return end
    if not ob and (not orgX or not orgY) then return end

    -- 有可能传进来的地图坐标超出了范围，需要进行修正
    mapX, mapY = MapMgr:adjustPosition(mapX, mapY)

    local pos = GObstacle:Instance():GetNearestPos(mapX, mapY)

    if 0 ~= pos then
        mapX, mapY = math.floor(pos / 1000), pos % 1000
    end

    local curX, curY
    if ob then
        curX, curY = ob.curX, ob.curY
    else
        curX, curY = orgX, orgY
    end

    local endX, endY = gf:convertToClientSpace(mapX, mapY)

    -- GObstacle:Instance():FindPath 中是以原始大小进行计算的，所以需要进行换算
    local sceneH = GameMgr:getSceneHeight()
    local rawBeginX = math.floor(curX / Const.MAP_SCALE)
    local rawBeginY = math.floor((sceneH - curY) / Const.MAP_SCALE)
    local rawEndX = math.floor(endX / Const.MAP_SCALE)
    local rawEndY = math.floor((sceneH - endY) / Const.MAP_SCALE)

    local badpath = false
    local paths = GObstacle:Instance():FindPath(rawBeginX, rawBeginY, rawEndX, rawEndY)
    local count = paths:QueryInt("count")
    if count > 1 then
        local dx = paths:QueryInt(string.format("x%d", count)) * Const.MAP_SCALE
        local dy = sceneH - paths:QueryInt(string.format("y%d", count)) * Const.MAP_SCALE

        local distX = math.abs(endX - dx)
        local distY = math.abs(endY - dy)
        if distX + distY > (Const.PANE_WIDTH + Const.PANE_HEIGHT) * 3 then
            -- 目标点与寻路点距离太远了，标记为寻路失败
            badpath = true
        end
    else
        -- 标记为寻路失败
        badpath = true
    end

    return badpath, paths
end

local myTraceback = function(level)
    local ret = ""
    -- local level = 3
    if not level then level = 3 end
    ret = ret .. "stack traceback: "
    while true do
        -- get stack info
        local info = debug.getinfo(level, "Sln")
        if not info then break end

        if info.what == "C" then
            -- C function
            ret = ret .. tostring(level) .. "C function\n"
        else
            -- Lua function
            ret = ret .. string.format("%s:%d in `%s`\n", info.short_src, info.currentline, info.name or "")
        end

        -- MessageMgr.lua 中的函数不要获取变量信息，因为信息内容太大了，且基本上比较固定
        local noGetLocalVars = string.find(info.short_src, "MessageMgr.lua")
        -- get local vars
        local i = 1
        while not noGetLocalVars do
            local name, value = debug.getlocal(level, i)
            if not name then break end

            ret = ret .. "  " .. name .. " = " .. tostringex(value) .. "\n"

            i = i + 1
        end

        level = level + 1
    end

    return ret
end

-- for CCLuaEngine traceback
-- 覆盖main.lua中的__G__TRACKBACK__，用于补丁情况下的功能更新
function __G__TRACKBACK__(msg, level)
    local logMsg = tostring(msg) .. "\n" .. myTraceback(level)
    local dist

    -- 显示设备和用户信息
    logMsg = logMsg .. ">>>>>>>>>>>>>>>>>\n"
    if DeviceMgr then
        local termInfo = DeviceMgr:getTermInfo()
        local osVer = DeviceMgr:getOSVer()
        logMsg = string.format("%sterm_info:%s, os_ver:%s\n", logMsg, termInfo and termInfo or "unknown", osVer and osVer or "unknown")
    end
    if cc.UserDefault:getInstance() then
        dist = cc.UserDefault:getInstance():getStringForKey("lastLoginDist")
        logMsg = string.format("%sdist:%s, version:%s\n", logMsg, dist,
            cc.UserDefault:getInstance():getStringForKey("local-version"))
    end

    if CommThread then
        local hasConnect = false
        local ip = CommThread:getConnectionAAAIp()
        if ip then
            -- 连接 aaa
            logMsg = string.format("%sconnect aaa:%s\n", logMsg, ip)
            hasConnect = true
        end

        local ip = CommThread:getConnectionIp()
        if ip then
            -- 链接 gs
            local distName
            local serverName = ""
            if GameMgr.isEnterGame then
                -- 未收到 MSG_ENTER_GAME 前没有线路信息，不用输出
                serverName = GameMgr:getServerName()
            end

            logMsg = string.format("%sconnect gs:%s %s\n", logMsg, ip, serverName)
            hasConnect = true
        end

        if not hasConnect then
            logMsg = string.format("%s%s\n", logMsg, "connect non")
        end
    end

    -- 组织显示的内容
    local showText = {}
    showText.time = gf:getServerDate("%Y/%m/%d %H:%M:%S", gf:getServerTime())
    logMsg = string.format("%sdate:%s", logMsg, showText.time)

    if GameMgr and 'function' == type(GameMgr.isInBackground) then
        logMsg = string.format("%s, background:%s", logMsg, tostring(GameMgr:isInBackground()))
    end

    -- 显示日志
    Log:E("%s", logMsg)

    if Me then
        showText.id = Me:getShowId()
        showText.name = Me:getName()
        end

    if dist then
        local list = gf:split(dist, ",")
        showText.dist = list[1]
    end

    -- 显示到调试界面中
    if GameMgr.networkState == NET_TYPE.WIFI then
        gf:ftpUploadError(logMsg)

        if gf:isIos() or gf:isAndroid() then
            local dlg = DlgMgr:openDlg("UnknownErrorDlg")
            if dlg then
            dlg:setData(showText, function()
                DlgMgr:preventDlg()
            end)
        end
        end
    else
        if not DlgMgr:isDlgOpened("UnknownErrorDlg") then
        local dlg = DlgMgr:openDlg("UnknownErrorDlg")
        if dlg then
        dlg:setData(showText, function()
            gf:ftpUploadError(logMsg)
            DlgMgr:preventDlg()
        end)
        end
    end
    end

    logMsg = logMsg.."\n-------- __G__TRACKBACK__ >>>>>>>>"
	return msg
end

gfTraceback = myTraceback

-- 协程模块
local coSeqMap = {}

-- 协程函数
function startCoroutine(func, ...)
    local co = coroutine.create(func)
    coroutine.resume(co, ...)
    return co
end

function stopCoroutine(co)
    if not co then return end
    local coId = tostring(co)
    local coMap = coSeqMap[coId]
    if coMap and coMap.node and coMap.action then
        if coMap.event then
            coMap.node:unregisterScriptHandler()
        end
        coMap.node:stopAction(coMap.action)
    end
    coSeqMap[coId] = nil
end

-- 协程的yield函数
function yield(time, parent)
    local co = coroutine.running()
    if not co then return end

    if not parent then parent = gf:getUILayer() end
    time = time and time or 0

    if parent then
        local node = parent:getChildByName("_COROUTINE_NODE")
        if not node then
            node = cc.Node:create()
            node:setName("_COROUTINE_NODE")
            parent:addChild(node)
        end
        local function delayProcess(node, callback, delay)
            local delay = cc.DelayTime:create(delay)
            local sequence = cc.Sequence:create(delay, cc.CallFunc:create(callback))
            return node:runAction(sequence)
        end
        local action = delayProcess(node, function()
            coSeqMap[tostring(co)] = nil
            coroutine.resume(co)
        end, time)
        local function onNodeEvent(event)
            if Const.NODE_CLEANUP == event then
                if node then
                    node:unregisterScriptHandler()
                end
                if coSeqMap then
                    coSeqMap[tostring(co)] = nil
                end
            end
        end
        node:registerScriptHandler(onNodeEvent)

        coSeqMap[tostring(co)] = { ['node'] = node, ['action'] = action, ['event'] = onNodeEvent }
    end

    coroutine.yield()
end

function gf:convertStrToTime(timeStr)
    -- 时间配置有两种格式，举例：3600 或者  2016-11-30-23:59:59
    local time
    if tonumber(timeStr) then
        time = gf:getServerTime() + tonumber(timeStr)
    else
        local list = gf:splitBydelims(timeStr,{"-", ":", " "})
        for i = 1, #list do
            local ch = string.sub(list[i], 1, 1)
            if ch == "-" or ch == ":" or ch == " " then
                list[i] = string.sub(list[i], 2, string.len(list[i]))
            end
        end

        time = os.time({year = tonumber(list[1]), month = tonumber(list[2]),
                        day = tonumber(list[3]), hour = tonumber(list[4]), min = tonumber(list[5]), sec = tonumber(list[6])})
    end

    return time
end

-- 构建任务日志
function gf:buildTaskLog(id, name, status, detail)
    return {
        task_id = id,
        task_name = name,
        status = tostring(status),
        task_detail = detail or "",
    }
end

-- 是否拥有某个称谓
function gf:isChengWeiExist(str)
    for i = 1, Me:queryBasicInt("title_num") do
        if Me:queryBasic(string.format("title%d", i)) == str and str ~= "" then
            return true
        end
    end
    return false
end

function gf:addCleanupEvent(node, func)
    if not node then return end

    local function onNodeEvent(event)
        if "cleanup" == event and func and 'function' == type(func) then
            func(node)
            gf:ftpUploadEx("------------->invalid cleanup:\n" .. myTraceback())
        end
    end

    node:registerScriptHandler(onNodeEvent)
end

function gf:removeCleanupEvent(node)
    if not node then return end

    node:unregisterScriptHandler()
end

function gf:getFileName(str)
    local idx = string.match(str, ".+()%.%w+$")
    if idx then
        return string.sub(str, 1, idx - 1)
    else
        return str
    end
end

-- 1 转化 一，一转化1
function gf:changeNumber(num)
    local cn = {
        [0] = CHS[5400355],
        [1] = CHS[6000055],
        [2] = CHS[6000056],
        [3] = CHS[6000057],
        [4] = CHS[6000058],
        [5] = CHS[6000059],
        [6] = CHS[6000060],
        [7] = CHS[6000061],
        [8] = CHS[6000062],
        [9] = CHS[6000063],
        [10] = CHS[6000064],
        [11] = CHS[4300250],
        [12] = CHS[4300251],

        [CHS[6000055]] = 1,
        [CHS[6000056]] = 2,
        [CHS[6000057]] = 3,
        [CHS[6000058]] = 4,
        [CHS[6000059]] = 5,
        [CHS[6000060]] = 6,
        [CHS[6000061]] = 7,
        [CHS[6000062]] = 8,
        [CHS[6000063]] = 9,
        [CHS[6000064]] = 10,
    }

    if tonumber(num) then   -- 好像会传 "1"
        local n = tonumber(num)
        return cn[n]
    else
        return cn[num]
    end
end

-- 数值转汉字，目前只到万
function gf:changeNumToChinese(num)
    local c, n
    local w = 0
    local str = ""
    local hasZero = false
    local cn = {
        [1] = CHS[6000064], -- 十
        [2] = CHS[5400354], -- 百
        [3] = CHS[5400356], -- 千
        [4] = CHS[5400357], -- 万
    }
    while num > 0 do
        c = num % 10

        if c > 0 and w > 0 then
            str = cn[w] .. str
        end

        if c ~= 0 then
            -- 十 前不显示 一
            if not(num == 1 and w == 1) then
                str = gf:changeNumber(c) .. str
            end

            hasZero = false
        else
            -- 连续多个 零，只显示一个零
            if str ~= "" and not hasZero then
                str = gf:changeNumber(c) .. str
                hasZero = true
            end
        end

        num = math.floor(num / 10)
        w = w + 1
    end

    return str
end

function gf:getFileExt(str)
    return string.match(str, ".+%.(%w+)$")
end

function gf:isFileExist(filePath)
    local ext = gf:getFileExt(filePath)
    if 'png' == ext and not cc.FileUtils:getInstance():isAbsolutePath(filePath) then
        local fileName = gf:getFileName(filePath)
        if not cc.FileUtils:getInstance():isFileExist(fileName .. ".epg") then
            return cc.FileUtils:getInstance():isFileExist(filePath)
        else
            return true
        end
    else
        return cc.FileUtils:getInstance():isFileExist(filePath)
    end
end

-- 设置技能、小图头像、道具显示大小（图片资源有可能64 * 64 或 96 * 96，统一设置成 64 * 64，）
function gf:setItemImageSize(img, isNotImg)
    self:setImageSizeCommon(img, isNotImg, Const.ITEMIMAGE_CONTENTSIZE, Const.ITEMIMAGE_SHOWSIZE)
end

-- 设置奖励小图标大小（图片资源 96 * 96，统一设置成 48 * 48）
function gf:setSmallRewardImageSize(img, isNotImg)
    self:setImageSizeCommon(img, isNotImg, Const.ITEMIMAGE_CONTENTSIZE, Const.SMALLREWARD__SHOWSIZE)
end

-- 设置法宝、顿悟技能标记图片显示大小（图片资源30 * 30，统一设置成 20 * 20的显示大小）
function gf:setSkillFlagImageSize(img, isNotImg)
    self:setImageSizeCommon(img, isNotImg, Const.SKILLFLAGIMAGE_CONTENTSIZE, Const.SKILLFLAGIMAGE_SHOWSIZE)
end

function gf:setImageSizeCommon(img, isNotImg, contentSize, showSize)
    if not img then
        return
    end

    local size = img:getContentSize()
    if contentSize.height ~= size.height and contentSize.width ~= size.width then
        return
    end

    if isNotImg then
        -- 可能是 Sprite 控件
        img:setScale(showSize.height / contentSize.height)
    else
        img:ignoreContentAdaptWithSize(false)
        img:setContentSize(showSize)
    end
end

-- 遮挡层，盖住整个屏幕，
function gf:creatCoverLayer()
    local coverLayer = gf:getUILayer():getChildByTag(Const.TAG_COVER_LAYER)
    if nil == coverLayer then
        -- 创建layer层
        coverLayer = cc.Layer:create()

        -- 添加标签
        coverLayer:setTag(Const.TAG_COVER_LAYER)

        -- 设置指引层的层级
        coverLayer:setLocalZOrder(Const.ZORDER_TOPMOST)
        coverLayer:setGlobalZOrder(Const.ZORDER_TOPMOST)

        coverLayer:setVisible(true)

        gf:getUILayer():addChild(coverLayer)

        gf:bindTouchListener(coverLayer, function(touch, event)
            local touchPos = touch:getLocation()
            if not coverLayer:isVisible() then
                return false
            end

            if Me:isInCombat() then
                return false
            end

            if Me.hasZuiXinWu and DlgMgr:isCanSeeMain() then
                -- 触发醉心雾时，点击屏幕时，角色要走到的位置改为不是点击位置，且点击屏幕控件不响应
                -- 弹出非主界面对话框时，不截掉事件

                local changedTouch = {}

                -- 重新计算角色要走的位置
                local location = {x = Const.WINSIZE.width - touchPos.x,
                    y = Const.WINSIZE.height - touchPos.y}
                function changedTouch:getLocation()
                    return location
                end

                local time = gf:getServerTime()
                if not self.lastTipsTime or time - self.lastTipsTime >= 3 then
                    gf:ShowSmallTips(CHS[5400052])
                    self.lastTipsTime = time
                end

                local map = GameMgr.scene.map
                if not map then
                    return false
                end

                if event:getEventCode() == cc.EventCode.BEGAN then
                    map:onMap(changedTouch, event)
                    return true
                end

                return map:onMap(changedTouch, event)
            end

            return false
        end, {
            cc.Handler.EVENT_TOUCH_BEGAN,
            cc.Handler.EVENT_TOUCH_MOVED,
            cc.Handler.EVENT_TOUCH_ENDED
        }, false)
    end
end

-- 调用 java 函数
local callJavaFun = function(cls, fun, sig, ...)
    local luaj = require('luaj')
    local className = cls
    local ok, ret = luaj.callStaticMethod(className, fun, { ... }, sig)
    if ok then
        return ret
    else
        Log:I('fun: ' .. fun .. ' ret: ' .. ret)
    end
end

-- 调用ios函数
local callOCFun = function (cls, fun, ...)
    local luaoc = require('luaoc')
    local ok = nil
    local arg = { ... }
    local ret = nil

    local t = {}
    for i, v in ipairs(arg) do
        t[string.format("arg%d", i)] = v
    end

    if #arg > 0 then
        ok, ret = luaoc.callStaticMethod(cls, fun, t)
    else
        ok, ret = luaoc.callStaticMethod(cls, fun)
    end

    if ok then
        return ret
    else
        Log:I('fun: ' .. fun .. ' ret: ' .. ret)
    end
end

function gf:callPlatformFun(jcls, sig, ocls, func, args)
    if gf:isAndroid() then
        return callJavaFun(jcls, func, sig, args)
    elseif gf:isIos() then
        return callOCFun(ocls, func, args)
    end
end

-- 由于成就系统中，好友分享，策划期望剪切板中保存的时显示信息，例如 :  [无名小卒]
-- 可是实际发送时，信息为：例    {无名小卒=成就=101001}
-- 就需要str表示需要显示的  [无名小卒]，para表示相关具体信息     {无名小卒=成就=101001}
function gf:copyTextToClipboardEx(str, para)
    gf:copyTextToClipboard(str)
    self.clipBoardPara = para
end

-- 复制到剪贴板
function gf:copyTextToClipboard(str)
    if gf:isWindows() then
        gfCopyTextToClipboard(str)
    else
    gf:callPlatformFun("org/cocos2dx/lua/AppActivity", "(Ljava/lang/String;)V", "AppController", "copyTextToClipboard", str)
    end

    -- clipBoardPara说明见 gf:copyTextToClipboardEx()
    self.clipBoardPara = nil
end

-- 从剪贴板读取文本
function gf:getTextFromClipboard(callback)
    if gf:isWindows() then
        local str = gfGetTextFromClipboard()
        local exec = string.format("%s('%s')", callback, str)
        local func = loadstring(exec)
        if func and 'function' == type(func) then
            pcall(func)
        end
    else
    gf:callPlatformFun("org/cocos2dx/lua/AppActivity", "(Ljava/lang/String;)V", "AppController", "getTextFromClipboard", callback)
    end
end

-- 特殊处理加了标记的名字（名字相同时，服务端会给同名的名字加标记，格式：标记-名字）
function gf:getRealName(name)
    local realname, flagName = gf:getRealNameAndFlag(name)
    if realname then
        return realname
    else
        return name
    end
end

-- 返回去除标记的名字和标记（部分界面帮派名显示为标记内容，用于区分同名）
function gf:getRealNameAndFlag(name)
    local flagName, realname  = string.match(name or "", "(.+)-(.*)")
    if realname then
        return realname, flagName
    else
        return name
    end
end

function gf:getChildName(type)
    if type == 0 then
        return CHS[4100601]
    elseif type == CHILD_TYPE.YUANYING or type == CHILD_TYPE.UPGRADE_IMMORTAL then
        return CHS[4100560]
    elseif type == CHILD_TYPE.XUEYING or type == CHILD_TYPE.UPGRADE_MAGIC then
        return CHS[4100561]
    end
end

-- 根据给定的顶点画线
function gf:drawLine(radius, col, ...)
    return gf:drawLineEx(radius, col, {gl.ONE, gl.ONE_MINUS_SRC_ALPHA}, ...)
end

function gf:drawLineEx(radius, col, blend, ...)
    local v = {...}
    local drawNode = cc.DrawNode:create()
    drawNode:setBlendFunc(blend[1], blend[2])
    drawNode:setAnchorPoint(0.5, 0.5)

    for i = 1, #v - 1 do
        drawNode:drawSegment(v[i], v[i + 1], radius, col)
    end

    return drawNode
end

-- 清除缓存数据
function gf:clearLocalCache()
    -- 先删除对应的版本patch信息
    cc.FileUtils:getInstance():removeDirectory(cc.FileUtils:getInstance():getWritablePath() .. "patch/")

    -- 删除对应代码及资源的路径
    cc.FileUtils:getInstance():removeDirectory(cc.FileUtils:getInstance():getWritablePath() .. "atmu/")

    -- 清除与补丁更新相关的用户数据
    local PLATFORM_CONFIG = require("PlatformConfig")
    cc.UserDefault:getInstance():setStringForKey("local-version", PLATFORM_CONFIG.CUR_VERSION)
    cc.UserDefault:getInstance():setStringForKey("current-version-code", "")
end

-- 将1~10转换为一~十
function gf:getChineseNum(v)
    local cn = {
        CHS[6000055],
        CHS[6000056],
        CHS[6000057],
        CHS[6000058],
        CHS[6000059],
        CHS[6000060],
        CHS[6000061],
        CHS[6000062],
        CHS[6000063],
        CHS[6000064],
    }

    return cn[v]
end

-- 检查字符是否合法
function gf:checkIsGBK(str)
    local str1 = gfGBKToUTF8(gfUTF8ToGBK(str))
    return str1 == str
end

function gf:weightRandom(weigths)
    local sum = 0
    for i = 1, #weigths do
        sum = sum + weigths[i]
    end

    local stepSum = 0
    local v = math.random(1, sum)
    for i = 1, #weigths do
        stepSum = stepSum + weigths[i]
        if  v <= stepSum and weigths[i] > 0 then
            return i
        end
    end
end

--function gf:toByteStr(str)
--    local s = ""
--    for i = 1, #str, 2 do
--        s = s .. string.char(tonumber(string.format("0x%s", string.sub(str, i, i + 1))))
--    end
--    return s
--end

-- 发送相关错误信息，用于一些客户端报错，容错后搜集信息
function gf:sendErrInfo(errType, msg)

    gf:CmdToServer('CMD_CLIENT_ERR_OCCUR', {
        errType  = errType,
        msg = msg
    })
end

function gf:getChannelNameFromUrl(url)
    if string.isNilOrEmpty(url) then return end
    local t = gf:split(url, "/")
    if #t > 0 then
        for i = #t, 1, -1 do
            if not string.isNilOrEmpty(t[i]) then
                return t[i]
            end
        end
    end
end

-- 显示禁用模拟器界面
function gf:showForbidSimulatorDlg(data)
    DlgMgr:openDlgEx("LoginForbidSimulatorDlg", data)
end

-- 检查权限
local GRANTS = {
    ["Camera"] = {
        ["iOS"] = "Camera",
        ["Android"] = "android.permission.CAMERA",
        ["android_tip"] = CHS[2100134],
        ["ios_tip"] = CHS[2100135]
    },
     ["Record"] = {
        ["iOS"] = "Record",
        ["Android"] = "android.permission.RECORD_AUDIO",
        ["ios_tip"] = CHS[2100136],
        ["android_tip"] = CHS[2100137],
     },
    ["GPS"] = {
        ["iOS"] = "GPS",
        ["Android"] = "android.permission.ACCESS_FINE_LOCATION",
        ["android_tip"] = CHS[2100138],
        ["ios_tip"] = CHS[2100139],
    },
    ["Push"] = {
        ["iOS"] = "Push",
        ["android_tip"] = CHS[2100140],
        ["ios_tip"] = CHS[2100141],
    },
    ["STORAGE"] = {
        ["Android"] = "android.permission.WRITE_EXTERNAL_STORAGE",
        ["android_tip"] = CHS[2200155],
    },
}


-- Android底层回调，不建议lua层直接调用
local toBeAndroidGrants
function doAndroidPermissionCallback(str)
    if not toBeAndroidGrants or string.isNilOrEmpty(str) then return end

    local grants = json.decode(str)
    if not grants then return end

    for k, v in pairs(grants) do
        local t = toBeAndroidGrants[k]
        if not t then return end

        if 0 == v then
            for k1, v1 in pairs(t) do
                if 'function' == type(v1.succ) then v1.succ() end
            end
        else
            for k1, v1 in pairs(t) do
                if 'function' == type(v1.fail) then v1.fail() end
            end
        end

		toBeAndroidGrants[k] = nil
    end
end

-- 检查权限
function gf:checkPermission(permission, name, onSucc, onFailed)
    if not gf:gfIsFuncEnabled(FUNCTION_ID.CHECK_PERMISSION) then
        if 'function' == type(onSucc) then onSucc() end
        return true
    end
    local cfg = GRANTS[permission]
    if not cfg then
        if 'function' == type(onSucc) then onSucc() end
        return true
    end -- 没有配置，默认有权限

    if gf:isAndroid() then
        if not cfg["Android"] then
            if 'function' == type(onSucc) then onSucc() end
            return true
        end

        local luaj = require('luaj')
        local className = 'com/gbits/GrantUtil'
        local sig = "(Ljava/lang/String;)I"
        local args = {}
        args[1] = cfg["Android"]

        toBeAndroidGrants = toBeAndroidGrants or {}
        toBeAndroidGrants[cfg["Android"]] = {}
        toBeAndroidGrants[cfg["Android"]][name] = { succ = onSucc, fail = onFailed }

        local ok, v = luaj.callStaticMethod(className, 'checkPermission', args, sig)
        if ok then
            if 0 == v then
                if 'function' == type(onSucc) then onSucc() end
                return true
            end
        end
    elseif gf:isIos() then
        if not cfg["iOS"] then
            if 'function' == type(onSucc) then onSucc() end
            return true
        end

        local luaoc = require('luaoc')
        local ok, v = luaoc.callStaticMethod('GrantUtil', 'checkPermission', {['arg1']=cfg["iOS"]})
        if ok then
            if 2 ~= v then
                if 'function' == type(onSucc) then onSucc() end
                return true
            else
                if 'function' == type(onFailed) then onFailed() end
    end
        end
    end

    return false
end

function gf:uncheckPermission(permission, name)
    if toBeAndroidGrants and toBeAndroidGrants[permission] then
        toBeAndroidGrants[permission][name] = nil
    end
end

-- 跳转页面
function gf:gotoSetting(permission)
    local cfg = GRANTS[permission]
    if not cfg then return end

    if gf:isAndroid() then
        if not gf:gfIsFuncEnabled(FUNCTION_ID.CHECK_PERMISSION) then
            if "Record" == permission then
                local dlg = DlgMgr:openDlg("RemindDlg")
                dlg:setLableString(CHS[3003949])
            end
            return
        end
        gf:confirmEx(cfg.android_tip, CHS[2100142], function()
            local luaj = require('luaj')
            local className = 'com/gbits/GrantUtil'
            local sig = "()V"
            local args = {}
            luaj.callStaticMethod(className, 'gotoSetting', args, sig)
        end, CHS[2100143], function() end)
    elseif gf:isIos() then
        DlgMgr:openDlgEx("RemindDlg", cfg.ios_tip)
    end
end

-- 垂直排列
function gf:doLinearVerticalLayout(layout)
    -- 设为垂直布局获取子控件的布局参数
    layout:setLayoutType(1)

    local layoutSize = layout:getContentSize()
    local container = layout:getChildren()
    local topBoundary = layoutSize.height

    for i = 1, #container do
        local child = container[i]
        if child and child:isVisible() then
            local layoutParameter = child:getLayoutParameter()
            if layoutParameter then
                local childGravity = layoutParameter:getGravity()
                local ap = child:getAnchorPoint()
                local cs = child:getContentSize()
                local finalPosX = ap.x * cs.width
                local finalPosY = topBoundary - ((1.0 - ap.y) * cs.height)
                if childGravity == 3 then
                    finalPosX = layoutSize.width - ((1.0 - ap.x) * cs.width)
                elseif childGravity == 6 then
                    finalPosY = layoutSize.width / 2.0 - cs.width * (0.5 - ap.x)
                end

                local mg = layoutParameter:getMargin()
                finalPosX = finalPosX + mg.left
                finalPosY = finalPosY - mg.top
                child:setPosition(cc.p(finalPosX, finalPosY))
                local _, y = child:getPosition()
                topBoundary = y - child:getAnchorPoint().y * child:getContentSize().height - mg.bottom
            end
        end
    end

    -- 设置为绝对布局才能避免底层修改位置
    layout:setLayoutType(0)
end

-- 横向布局
function gf:doLinearHorizontalLayout(layout)
    -- 设置为横向布局
    layout:setLayoutType(2)

    local layoutSize = layout:getContentSize()
    local container = layout:getChildren()
    local leftBoundary = 0

    for i = 1, #container do
        local child = container[i]
        if child and child:isVisible() then
            local layoutParameter = child:getLayoutParameter()
            if layoutParameter then
                local childGravity = layoutParameter:getGravity()
                local ap = child:getAnchorPoint()
                local cs = child:getContentSize()
                local finalPosX = leftBoundary + (ap.x * cs.width)
                local finalPosY = layoutSize.height - ((1.0 - ap.y) * cs.height)
                if childGravity == 4 then
                    finalPosY = ap.y * cs.height
                elseif childGravity == 5 then
                    finalPosY = layoutSize.height / 2.0 - cs.height * (0.5 - ap.y)
                end

                local mg = layoutParameter:getMargin()
                finalPosX = finalPosX + mg.left
                finalPosY = finalPosY - mg.top
                child:setPosition(cc.p(finalPosX, finalPosY))
                leftBoundary = child:getRightBoundary() + mg.right
            end
        end
    end

    -- 设置为绝对布局才能避免底层修改位置
    layout:setLayoutType(0)
end

function gf:chechCard(text)
    local len = string.len(text)

    if len ~= 18 and len ~= 15 then
        gf:ShowSmallTips(CHS[4300327])
        return false
    end

    -- 保证前面17或14都为数字
    if len == 15 then
        if tonumber(string.sub(text, 1, 14)) == nil then
            gf:ShowSmallTips(CHS[4300327])
            return false
        end
    elseif len == 18 then
        if tonumber(string.sub(text, 1, 17)) == nil then
            gf:ShowSmallTips(CHS[4300327])
            return false
        end
    end

    local area = string.sub(text, 1, 2)

    if tonumber(area) == nil or AREA_CODE[tonumber(area)] == nil  then
        gf:ShowSmallTips(CHS[4300327])
        return false
    else
        if len == 15 then
            local year  = tonumber("19"..string.sub(text, 7, 8))
            local month = tonumber(string.sub(text,  9, 10))
            local day = tonumber(string.sub(text, 11, 12))
            if not year or not month or not day then
                gf:ShowSmallTips(CHS[4300327])
                return false
            else
                if not self:checkCardTime(year, month, day) then
                    gf:ShowSmallTips(CHS[4300327])
                    return false
                end
            end
        elseif len== 18 then
            local year  = tonumber(string.sub(text, 7, 10))
            local month = tonumber(string.sub(text,  11, 12))
            local day = tonumber(string.sub(text, 13, 14))
            if not year or not month or not day then
                gf:ShowSmallTips(CHS[4300327])
                return false
            else
                if self:checkCardTime(year, month, day) == false then
                    gf:ShowSmallTips(CHS[4300327])
                    return false
                end
            end
        end
    end

    -- 15位身份证无效验码，通过日期检测后，当做成功
    if len == 15 then
        return true
    end

    local wi = {7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2, 1}
    local ai = {}
    if len == 18 then
        for i = 1, 17 do
            local oneChar = string.sub(text, i, i)
            table.insert(ai, tonumber(oneChar))
        end
    end

    local Y = {1,0,10,9,8,7,6,5,4,3,2} -- x
    local s = 0
    for j = 1, 17 do
        s = s + ai[j] * wi[j]
    end

    local lastNmnmber = string.sub(text, 18, 18)
    local lastNumValue

    if string.lower(lastNmnmber) ~= "x" and (string.byte(lastNmnmber,1) < 48 or string.byte(lastNmnmber,1) > 57) then
        gf:ShowSmallTips(CHS[4300327])
        return false
    else
        if string.lower(string.sub(text, 18, 18)) == "x" then
            lastNumValue = 10
        else
            lastNumValue = tonumber(string.sub(text, 18, 18))
        end
    end

    local y = s % 11
    if Y[y + 1] ~= lastNumValue then
        gf:ShowSmallTips(CHS[4300327])
        return false
    end

    return true

end

function gf:checkCardTime(year, month, day)
    local febDay  = 28
    local curtimeTabel = gf:getServerDate("*t", gf:getServerTime())
    local curYear = curtimeTabel["year"]

    if year % 100 == 0 and year % 4 == 0 then
        febDay  = 29
    elseif year % 4 == 0 then
        febDay = 29
    end

    if year < 1800  or year > curYear then
        return false
    elseif (curYear== year and month > curtimeTabel["month"]) or month == 0 then
        return false
    else
        if month > 12 or month <= 0 then
            return false
        else
            if month == 2 then
                if day <= 0 or day > febDay then
                    return false
                end
            else
                if day <= 0 or day > MONTH_DAY[month]  then
                    return false
                end
            end

        end
    end

    return true
end

function gf:checkPhoneNum(tel)
    if #tel ~= 11 then
        gf:ShowSmallTips(CHS[2200126])
        return
    end

    if tonumber(string.sub(tel, 1, 1)) ~= 1 then
        gf:ShowSmallTips(CHS[2200126])
        return
    end

    if not tonumber(tel) then
        gf:ShowSmallTips(CHS[2200126])
        return
    end

    return true
end

-- 尝试打开完整包下载url
function gf:openFullPackageLoadUrl()
    local filePath = cc.FileUtils:getInstance():getWritablePath() .. 'patch/full_client_url.lua'
    local urls = {}

    -- 文件不存在
    if not pcall(function ()
        urls = dofile(filePath)
    end) then
        return
    end

    local platformConfig = require("PlatformConfig")
    if urls[platformConfig.FULL_CLIENT_KEY] then
        DeviceMgr:openUrl(urls[platformConfig.FULL_CLIENT_KEY])
    end
end

-- 检查是否存在指定光效
function gf:hasLightEffect(lightEffects, magicKey)
    if lightEffects and #lightEffects > 0 then
        for i = 1, #lightEffects do
            if lightEffects[i] == magicKey then return true end
        end
    end
end

-- 检测输入的时间的年月日是否合法
function gf:checkTimeLegal(year, month, day)
    if year <= 0 or month <= 0 or month > 12 or day <= 0 then
        return false
    end

    if month == 2 then
        if (year % 100 ~= 0 and year % 4 == 0)
           or year % 400 == 0 then
            if day > 29 then
                return false
            end
        elseif day > 28 then
            return false
        end
    elseif month <= 7 then
        if month % 2 == 1 then
            if day > 31 then
                return false
            end
        elseif day > 30 then
            return false
        end
    else
        if month % 2 == 0 then
            if day > 31 then
                return false
            end
        elseif day > 30 then
            return false
        end
    end

    return true
end

-- 处理定位Cookie
function gf:dealWithGpsCookie(p1, p2, p3)
    if p3 == "true" then
        return gfGetMd5(p1 .. "%" .. p2 .. "%" .. p3 .. "%" .. GPS_CONFIG.DEFAULT_PLAT_K)
    else
        return gfGetMd5(p1 .. "%" .. p2 .. "%" .. GPS_CONFIG.DEFAULT_PLAT_K)
    end
end

-- 字符串是否是纯数字
function gf:isOnlyDigital(str)
    local index = 1
    local len = string.len(str)

    while len >= index do
        local byteValue = string.byte(str, index)
        if byteValue >= 48 and byteValue <= 57 then
            index = index + 1
        else
            return false
        end
    end

    return true
end

-- 中文到阿拉伯数字，支持0~9999,0000,0000
function gf:chsToNumber(str)
    -- 中文到数字，如："一" -> 1
    local chs2Num = {
        [CHS[7150058]] = 0,
        [CHS[7150048]] = 1,
        [CHS[7150049]] = 2,
        [CHS[7150050]] = 3,
        [CHS[7150051]] = 4,
        [CHS[7150052]] = 5,
        [CHS[7150053]] = 6,
        [CHS[7150054]] = 7,
        [CHS[7150055]] = 8,
        [CHS[7150056]] = 9,
    }

    -- 中文到数字单位，如："千" -> 1000
    -- "万"、"亿"特殊处理为1是因为有可能出现"十万"、"百万"、"百亿"、"千亿"的读法，这种连续两个单位
    -- 的情况在下面使用 stepUnit变量 处理
    local chs2NumUnit = {
        [CHS[7150131]] = 10,
        [CHS[7150132]] = 100,
        [CHS[7150133]] = 1000,
        [CHS[7150134]] = 1, -- 万
        [CHS[7150135]] = 1, -- 亿
    }

    local result = 0
    local _, textLenth = gf:getTextLength(str)
    local unit = 1
    local stepUnit = 1
    for i = textLenth, 1, -1 do
        local chsNum = string.sub(str, (i - 1) * 3 + 1, i * 3)
        if chs2Num[chsNum] then
            -- 遇到数字直接累加
            result = result + unit * chs2Num[chsNum] * stepUnit
        elseif chs2NumUnit[chsNum] then
            -- 遇到单位调整当前单位
            if chsNum == CHS[7150135] then
                stepUnit = 100000000
            elseif chsNum == CHS[7150134] then
                stepUnit = 10000
        end

            unit = chs2NumUnit[chsNum]

            if unit == 10 and i == 1 then
                -- 十作为第一位时特殊处理，因为不会写"一十一"
                result = result + 10
            end
    else
            -- 字符串不合法
            Log:I(string.format("gf:chsToNumber para invalid %s ", str))
            return result
    end
    end

    return result
end

-- 阿拉伯数字到中文, 支持0~9999,0000,0000
function gf:numberToChs(para)
    if string.isNilOrEmpty(para) then
        Log:I(string.format("gf:numberToChs para invalid %s ", tostringex(para)))
        return
    end

    local numStr = tostring(para)

    local num2Chs = {
        [0] = CHS[7150058],
        [1] = CHS[7150048],
        [2] = CHS[7150049],
        [3] = CHS[7150050],
        [4] = CHS[7150051],
        [5] = CHS[7150052],
        [6] = CHS[7150053],
        [7] = CHS[7150054],
        [8] = CHS[7150055],
        [9] = CHS[7150056],
    }

    for i = 1, #numStr do
        local numi = string.sub(numStr, i, i)
        if not num2Chs[tonumber(numi)] then
            Log:I(string.format("gf:numberToChs para invalid %s ", tostringex(para)))
            return
        end
    end

    -- 万以内的转换使用此函数完成
    local function getOneSection(num)
        local ret = {}
        local weight = {[1] = CHS[7150131], [2] = CHS[7150132], [3] = CHS[7150133]}
        local count = 0
        local zeroFlag = false
        local lastIsZero = num % 10 == 0
        local qianfwIsZero = num < 1000 and num > 0
        while num > 0 do
            local posNum = num % 10
            num = math.floor(num / 10)
            if posNum > 0 then
                if zeroFlag and not lastIsZero then
                    -- 遇到0或者连续的0，并且这些0后面还有非0数字，则插入一个0
                    zeroFlag = false
                    table.insert(ret, 1, num2Chs[0])
                end

                if weight[count] then
                    if posNum == 1 and count == 1 and num == 0 then
                        -- 最前面的 一十 特殊处理为 十
                        table.insert(ret, 1, weight[count])
    else
                        table.insert(ret, 1, num2Chs[posNum] .. weight[count])
                    end
                else
                    table.insert(ret, 1, num2Chs[posNum])
                end
            else
                zeroFlag = true
            end

            count = count + 1
        end

        return table.concat(ret, ""), qianfwIsZero
    end

    local numberValue = tonumber(para)
    if numberValue == 0 then
        return num2Chs[0]
    end

        local ret = ""

    -- 亿，万
    local sectionKey = 100000000
    local sectionWeight = {[1] = CHS[7150135], [2] = CHS[7150134]}

    -- 将数字分成3块:每一块使用 getOneSection 获取转换结果，再对每一块进行连接
    -- 连接时加上"万"、"亿"单位即可，有可能需要额外增加"零"连接，如：10100 -> 一万零一百
    for i = 1, 3 do
        local section = math.floor(numberValue / sectionKey)
        if section > 0 then
            local tempStr, qianfwIsZero = getOneSection(section)
            if qianfwIsZero and tonumber(para) > sectionKey * 10000 then
                -- 千位是0，且存在上一个section，则插入一个"零"
                ret = ret .. num2Chs[0]
        end

            if sectionWeight[i] then
                ret = ret .. tempStr .. sectionWeight[i]
            else
                ret = ret .. tempStr
        end
        end

        numberValue = numberValue % sectionKey
        sectionKey = math.floor(sectionKey / 10000)
    end

        return ret
end

-- 图片剪裁
-- 将指定剪裁框(clipSize)的图片缩放到指定尺寸(scaleSize)
-- 0:相册 1:相机
-- isPick:直接拾取，忽略clipSize
function gf:comDoOpenPhoto(state, funcName, clipSize, scaleSize, quality, isPick)
    if gf:isWindows() then
        local ConfirmEx = require("dlg/ConfirmDlgEx")
        if not ConfirmEx then return end
        local inputDlg = ConfirmEx.create()

        inputDlg:setTipText("请输入文件的绝对路径")
        inputDlg:setCallBack(function(input)
            local func = _G[funcName]
            if func then
                func(input)
            end
            gf:getUILayer():removeChild(inputDlg)
        end, function()
            gf:getUILayer():removeChild(inputDlg)
        end)
        gf:getUILayer():addChild(inputDlg)
        return
    end

    if ImagePicker then
        local isCameraPermmit, isStoragePermmit

        local function doOpenPhoto()
        quality = quality or 50
        if gf:gfIsFuncEnabled(FUNCTION_ID.CLIP_SCALE_IMAGE) then
            local cw, ch, sw, sh = clipSize.width, clipSize.height, scaleSize.width, scaleSize.height
            ImagePicker:getInstance():setBitmapOption(0, quality)
            if 1 == state then
                if not DeviceMgr:isEmulator() then
                    if isPick and gf:gfIsFuncEnabled(FUNCTION_ID.IMAGE_PICK_FIXED) then
                        ImagePicker:getInstance():openCamera(0, 0, funcName)
                    else
                        ImagePicker:getInstance():openCamera(cw, ch, math.min(cw, sw), math.min(ch, sh), funcName)
                    end
                else
                    gf:ShowSmallTips(CHS[2100133])
                end
            else
                if isPick and gf:gfIsFuncEnabled(FUNCTION_ID.IMAGE_PICK_FIXED) then
                    ImagePicker:getInstance():openPhoto(0, 0, funcName)
                else
                    ImagePicker:getInstance():openPhoto(cw, ch, math.min(cw, sw), math.min(ch, sh), funcName)
                end
            end
        end
        end

        gf:checkPermission("Camera", funcName, function()
            gf:checkPermission("STORAGE", funcName, function()
				doOpenPhoto()
			end, function()
				gf:gotoSetting("STORAGE")
			end)
        end, function()
            gf:gotoSetting("Camera")
        end)
    else
        gf:ShowSmallTips(CHS[2100039])
    end
end

-- 获取裁剪框大小
function gf:getPortraitClipRange(bw, bh)
    local w, h
    if gf:isAndroid() then
        local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
        w = frameSize.width - 20
        h = frameSize.height - 20
        local dpi = self:getDpi()
        local statusHeight = math.ceil(50 * dpi / 160)
        local buttonHeight = math.ceil(50 * dpi / 160)
        h = h - statusHeight - buttonHeight
    else
        w, h = self:getIosSize()
    end

    local scale
    if w / h >= bw / bh then
        scale = math.floor(h / bh)
    else
        scale = math.floor(w / bw)
    end

    return bw * scale, bh * scale
end

function gf:getIosSize()
    local frameSize = cc.Director:getInstance():getOpenGLView():getFrameSize()
    local h = frameSize.height / 3
    local minHeight
    if cc.PLATFORM_OS_IPAD == cc.Application:getInstance():getTargetPlatform() then
        minHeight = 768
    else
        minHeight = 320
    end

    if h < minHeight then
        h = frameSize.height  / 2
    end
    if h < minHeight then
        h = frameSize.height
    end
    h = (h / 2 - 32) * 2
    local w = h * (frameSize.width / frameSize.height)
    return w, h
end

function gf:getDpi()
    if not self.dpi and gf:isAndroid() then
        self.dpi = callJavaFun("org/cocos2dx/lib/Cocos2dxHelper", "getDPI", "()I")
        self.dpi = self.dpi or 1
    end

    return self.dpi
end

-- 显示提示及杂项
function gf:showTipAndMisMsg(tip)
    gf:ShowSmallTips(tip)
    ChatMgr:sendMiscMsg(tip)
end

-- 生成部件字符串
function gf:makePartString(backIndex, hairIndex, bodyIndex, trousersIndex, weaponIndex)
    return string.format("%02d%02d%02d%02d%02d%02d%02d%02d%02d%02d", weaponIndex, backIndex, hairIndex,
        bodyIndex, trousersIndex, bodyIndex, bodyIndex, hairIndex, backIndex, weaponIndex)
end

function gf:convertStringToPartIndex(str)
    local len = #str

    assert(10 == len or 8 == len, "part string must be equal to 0 or 10 or 8")

    if 8 == len then
        -- 新增背饰后兼任旧数据
        return 0,
               tonumber(string.sub(str, 1, 2)),
               tonumber(string.sub(str, 3, 4)),
               tonumber(string.sub(str, 5, 6)),
               tonumber(string.sub(str, 7, 8))
    elseif 10 == len then
        return tonumber(string.sub(str, 1, 2)),
               tonumber(string.sub(str, 3, 4)),
               tonumber(string.sub(str, 5, 6)),
               tonumber(string.sub(str, 7, 8)),
               tonumber(string.sub(str, 9, 10))
    else
        return 0, 0, 0, 0, 0
    end
end

-- 生成换色字符串
function gf:makePartColorString(nudeIndex, backIndex, hairIndex, bodyIndex, trousersIndex, weaponIndex)
    return string.format("%02d%02d%02d%02d%02d%02d%02d%02d%02d%02d%02d", nudeIndex, weaponIndex, backIndex, hairIndex, bodyIndex,
        trousersIndex, bodyIndex, bodyIndex, hairIndex, backIndex, weaponIndex)
end

function gf:convertStringToPartColorIndex(str)
    local len = #str

    assert(12 == len or 10 == len or 0 == len, "part string must be equal to 0 or 12")

    if 10 == len then
        -- 新增背饰后兼任旧数据
        return 0,
               tonumber(string.sub(str, 1, 2)),
               tonumber(string.sub(str, 3, 4)),
               tonumber(string.sub(str, 5, 6)),
               tonumber(string.sub(str, 7, 8)),
               tonumber(string.sub(str, 9, 10))
    elseif 12 == len then
        return tonumber(string.sub(str, 1, 2)),
               tonumber(string.sub(str, 3, 4)),
               tonumber(string.sub(str, 5, 6)),
               tonumber(string.sub(str, 7, 8)),
               tonumber(string.sub(str, 9, 10)),
               tonumber(string.sub(str, 11, 12))
    else
        return 0, 0, 0, 0, 0, 0
    end
end

function gf:getElapseTimeStr(elapse)
    local timeStr = ""
    if elapse < 60 then
        timeStr = string.format(CHS[4100774], 1)
    elseif elapse < 60 * 60 then
        timeStr = string.format(CHS[4100774], math.floor(elapse / 60))
    elseif elapse < 60 * 60 * 24 then
        timeStr = string.format(CHS[4100775], math.floor(elapse / (60 * 60)))
    elseif elapse < 60 * 60 * 24 * 365 then
        timeStr = string.format(CHS[4100776], math.floor(elapse / (60 * 60 * 24)))
    else
        timeStr = CHS[2100273]
    end

    return timeStr
end

-- 将lua配置表导出为json
function gf:exportJson(t, path)
    local json = require("json")
    local jstr = json.encode(t)
    local f = io.open(path, "wb")
    f:write(jstr)
    f:close()
end

-- gf:exportCHS("D:/work/ATM/sy_patch_now/client/AsktaoH5/assets/scripts/global")
function gf:exportCHS(path)
    local f
    f = nil
    local str
    local count = 0
    local index = 0
    local t = {}
    for k, v in pairs(CHS) do
        table.insert(t, {k, v})
    end

    table.sort(t, function(l, r)
        if l[1] < r[1] then return true end
        return false
    end)

    for i = 1, #t do
        k = t[i][1]
        v = t[i][2]
        if not f then
            index = index + 1
            f = io.open(string.format("%s/CHS%d.ts", path, index), "wb")
            count = 0
            f:write(string.format("export let CHS%d = {\n", index))
        end
        v = string.gsub(v, "\9", "\\x09")
        v = string.gsub(v, "\29", "\\x1D")
        v = string.gsub(v, "\n", "\\n")
        v = string.gsub(v, "\"", "\\\"")
        str = string.format("    [\"%d\"] : \"%s\",\n", k, v)
        f:write(str)

        count = count + 1
        if count >= 3000 then
            f:write("}\n")
            f:write(string.format("\nexport default CHS%d", index))
            f:close()
            f = nil
        end
    end
    f:write("}\n")
    f:write(string.format("\nexport default CHS%d", index))
    f:close()

    local f = io.open(path .. "/CHS.ts", "wb")
    for i = 1, index do
        f:write(string.format("import CHS%d from \"./CHS%d\"\n", i, i))
    end

    f:write("\nexport let CHS = {}\n\n")
    for i = 1, index do
        f:write(string.format("for (let k in CHS%d)\n{\n", i))
        f:write(string.format("    CHS[k] = CHS%d[k]\n", i))
        f:write("\n}\n")
    end

    f:write("\nexport default CHS")
    f:close()
end

--==============================--
--desc: 通用倒计时 by songcw
--time:2018-12-27 02:50:48
--@endTime: 结束时间
--@cdType: nil为标准倒计时（3 2 1）， "start"为显示开始（3 2 1 开始）, "end" 显示结束（3 2 1 结束）
--@callBack: 倒计时结束后回调
--@para: 额外参数
--@return
--==============================--
function gf:startCountDowm(endTime, cdType, callBack, para)
    local leftTi = endTime - gf:getServerTime()
    if leftTi <= 0 then return end

    local isRightNow = true

    local dlg = DlgMgr:getDlgByName("CountDownDlg")
    if not dlg then
        dlg = DlgMgr:openDlg("CountDownDlg")
    else
        if dlg.cdType and dlg.cdType ~= cdType then
            isRightNow = false
    end
    end

    if isRightNow then
        -- 直接显示倒计时
    dlg:setData(cdType, callBack, para)
    dlg:startCountDown(leftTi)
    else
        -- 原有倒计时结束后再显示新倒计时
        dlg:setNextData(cdType, callBack, para, endTime)
    end
end

function gf:closeCountDown()
    local dlg = DlgMgr:getDlgByName("CountDownDlg")
    if not dlg then return end
    if dlg.numImg then dlg.numImg:stopCountDown() end

    dlg:onCloseButton()
end

-- 将屏幕上一点坐标转化为世界坐标系中的坐标
function gf:unproject( viewProjection, viewport, src, dst)
    assert(viewport.width ~= 0.0 and viewport.height ~= 0)

    -- 计算点在摄像机坐标系中的坐标，利用触摸点的坐标与摄像机近平面坐标的线性相关性
    local screen = cc.vec4(src.x / viewport.width, (viewport.height - src.y) / viewport.height, src.z, 1.0)
    screen.x = screen.x * 2.0 - 1.0
    screen.y = screen.y * 2.0 - 1.0
    screen.z = screen.z * 2.0 - 1.0

    -- 将得到的摄像机坐标系中的坐标经摄像机矩阵的逆矩阵变换得到其世界坐标
    local inversed = cc.mat4.new(viewProjection:getInversed())
    screen = inversed:transformVector(screen, screen)

    -- 齐次坐标规范化
    if screen.w ~= 0.0 then
        screen.x = screen.x / screen.w
        screen.y = screen.y / screen.w
        screen.z = screen.z / screen.w
    end

    -- 保存该点的世界坐标
    dst.x = screen.x
    dst.y = screen.y
    dst.z = screen.z
    return viewport, src, dst
end

-- 计算射线
function gf:calculateRayByLocationInView(ray, location)
    local dir = cc.Director:getInstance()
    local view = dir:getWinSize()  -- 获取窗口大小 用于计算触摸点在摄像机坐标系中位置
    local mat = cc.mat4.new(dir:getMatrix(cc.MATRIX_STACK_TYPE.PROJECTION)) -- 获取投影矩阵栈栈顶元素(即原栈顶元素的拷贝，携带父节点的变换信息)
    local src = cc.vec3(location.x, location.y, -1)
    local nearPoint = {}  -- 近平面点
    view, src, nearPoint = self:unproject(mat, view, src, nearPoint)  -- 计算近平面点在世界坐标系中的坐标
    src = cc.vec3(location.x, location.y, 1)
    local farPoint = {}   -- 远平面点
    view, src, farPoint = self:unproject(mat, view, src, farPoint)  -- 计算远平面点在世界坐标系中的坐标
    local direction = {}  -- 方向矢量
    direction.x = farPoint.x - nearPoint.x  -- 远平面点减去近平面点求方向矢量
    direction.y = farPoint.y - nearPoint.y
    direction.z = farPoint.z - nearPoint.z
    direction   = cc.vec3normalize(direction)  -- 归一化

    ray._origin    = nearPoint  -- 射线起点位置
    ray._direction = direction  -- 射线方向矢量
end

return gf
