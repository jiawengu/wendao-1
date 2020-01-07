-- BarrageTalkMgr.lua
-- created by songcw Feb/17/2017
-- 弹幕管理器

BarrageTalkMgr = Singleton()

-----------------------------------------------------
-- 弹幕当前有两种
-- 1.观战中心的弹幕，分实时弹幕和录像弹幕
----- 实时弹幕通过消息 MSG_LOOKON_CHANNEL_MESSAGE
-- 2.婚礼弹幕
----- 通过频道-CHANNEL-WEDDING
-- update by songcw 2018、3、29
--------------------------------


local MOVE_SPEED = 11

local pastY = {}

local m_barrageData = {}

local m_isReceive = true    -- 是否接收

local m_recorded_channel_interval = 30000          -- 每页弹幕间隔时间。默认为30秒。由服务器修改

local m_requested = {} -- 已经请求过的页码

function BarrageTalkMgr:getBarrageLayer()
    local layer = gf:getUILayer():getChildByName("BarrageLayer")
    return layer
end

function BarrageTalkMgr:removeBarrageLayer()
    local layer = gf:getUILayer():getChildByName("BarrageLayer")
    if layer then
        layer:removeFromParent()
        m_requested = {}   
    end
end

function BarrageTalkMgr:removeAllBarrages()
    local layer = gf:getUILayer():getChildByName("BarrageLayer")
    if layer then
        layer:removeAllChildren()
    end
end

function BarrageTalkMgr:creatBarrageLayer()
    local layer = gf:getUILayer():getChildByName("BarrageLayer")
    if layer then
        layer:removeFromParent()
        m_requested = {}  
    end

    local panel = ccui.Layout:create()    
    panel:setName("BarrageLayer")
    panel:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    panel:setPosition(0,0)    
    gf:getUILayer():addChild(panel)
    panel:setLocalZOrder(Const.LOADING_DLG_ZORDER - 1)
end

-- 获取弹幕 posY
function BarrageTalkMgr:getPosY()
    local function getHasDistenceY(curTime)
        local y = math.random(120, Const.WINSIZE.height / Const.UI_SCALE - 80)
        
        local isSame = false
        gf:PrintMap(pastY)
        for lastTime, lastY in pairs(pastY) do
            if curTime - lastTime > 3 * 1000 then
                pastY[lastTime] = nil
                gf:PrintMap(pastY)
            else
                if math.abs(y - lastY) < 30 then
                    isSame = true
                end  
            end
        end
        
        return y, isSame
    end

    local curTime = gfGetTickCount()
    local y, isSame = getHasDistenceY(curTime)
    if isSame then
        -- 如果有重叠的，再走两次，两次后再重叠就重叠，怕弹幕太多递归死循环
        y, isSame = getHasDistenceY(curTime)    
        if isSame then
            y, isSame = getHasDistenceY(curTime)
        end 
    end
    
    pastY[curTime] = y
    return y
end

function BarrageTalkMgr:isOpen()
    return m_isReceive
end

-- 增加弹幕
function BarrageTalkMgr:addBarrage(data)
    if not m_isReceive then return end
    
    BarrageTalkMgr:creatBarrage(data)
end

-- 发送弹幕至屏幕
function BarrageTalkMgr:creatBarrage(data)
    if not m_isReceive then return end

    local layer = gf:getUILayer():getChildByName("BarrageLayer")
    if not layer then        
        return        
    end
    
    local msg = data.msg
    
    -- 敏感字
    local retStr, haveBadStr = gf:filtText(msg, data.gid)
    if haveBadStr then
        return
    end
    
    -- 去除闪烁
    msg = string.gsub(msg, "#b", "")
    
    if data.sender == Me:queryBasic("name") then
        msg = "#R[" .. data.sender .. "]#n：" .. msg
    else
        msg = "[" .. data.sender .. "]：" .. msg
    end

    local panel = ccui.Layout:create()    
    local y = BarrageTalkMgr:getPosY()    
    panel:setPosition(Const.WINSIZE.width / Const.UI_SCALE, y)
    layer:addChild(panel)
    
    local textCtrl = CGAColorTextList:create()
    textCtrl:setDefaultColor(COLOR3.WHITE.r, COLOR3.WHITE.g, COLOR3.WHITE.b)
    --textCtrl:setDefaultColor(153, 109, 56)
    textCtrl:setFontSize(30)
    textCtrl:setString(gf:filterPlayerColorText(msg))
    textCtrl:updateNow()
    -- 垂直方向居中显示
    local textW, textH = textCtrl:getRealSize()
    panel:setContentSize(textW + 10, textH + 2)
    
    textCtrl:setPosition(5, textH + 1)  

    panel:addChild(tolua.cast(textCtrl, "cc.LayerColor"))
     
    local speed = MOVE_SPEED + math.random(0, 15) / 10
    
    local size = panel:getContentSize()
    local moveAct = cc.MoveBy:create(speed, cc.p(-(Const.WINSIZE.width / Const.UI_SCALE + 30 + textW), 0))
    panel:runAction(moveAct)    
end

-- 发送弹幕至服务器
function BarrageTalkMgr:sendBarrageMessage(combatId, interval_tick, msg)    
    self.lastTime = self.lastTime or 0
    if gf:getTickCount() - self.lastTime <= 3000 then
        gf:ShowSmallTips(CHS[4100456]) 
        return 
    end

    gf:CmdToServer("CMD_LOOKON_CHANNEL_MESSAGE", {combat_id = combatId, interval_tick = interval_tick, msg = msg})
    self.lastTime = gf:getTickCount()
    return true
end

-- 请求录像弹幕 按时间
function BarrageTalkMgr:queryBarrageDataByTime(combatId, interval_tick)    

    local page = BarrageTalkMgr:getPageForTime(interval_tick) 

    BarrageTalkMgr:queryBarrageDataByPage(combatId, page)  
end

-- 请求录像弹幕 按页
function BarrageTalkMgr:queryBarrageDataByPage(combatId, page)    
    if m_requested[page] then return end
    gf:CmdToServer("CMD_LOOKON_COMBAT_CHANNEL_DATA", {combat_id = combatId, page = page})
    m_requested[page] = 1
end

function BarrageTalkMgr:getPageForTime(time)
    local page = math.ceil(time / m_recorded_channel_interval)
    return page
end

function BarrageTalkMgr:MSG_LOOKON_COMBAT_CHANNEL_DATA(data)    
    local combatId = WatchRecordMgr:getCurReocrdCombatId()
    if not combatId or combatId ~= data.combat_id then
        m_barrageData[data.combat_id] = nil
        m_requested = {}
        return 
    end
    if not m_barrageData[combatId] or data.page == 1 then
        m_barrageData[combatId] = {}
        m_requested = {}  
    end
    m_barrageData[combatId][data.page] = {}
    
    -- 排序
    table.sort(data.barrage, function(l, r)
        if l.interval_tick < r.interval_tick then return true end
        if l.interval_tick > r.interval_tick then return false end
        return false
    end)
    
    
    for i = 1, data.count do
        local unitBarrage = data.barrage[i]
        
        table.insert(m_barrageData[combatId][data.page], unitBarrage)
    end    
    --BarrageTalkMgr:queryBarrageDataByPage(data.combat_id, data.page + 1) 
end

function BarrageTalkMgr:getBarrageData(combatId, curTime)
    local page = BarrageTalkMgr:getPageForTime(curTime)
    
    if m_barrageData[combatId] and m_barrageData[combatId][page] then
        return m_barrageData[combatId][page]   
    end
end

-- 实时弹幕，收到直接播放
function BarrageTalkMgr:MSG_LOOKON_CHANNEL_MESSAGE(data)
    BarrageTalkMgr:creatBarrage(data)   
end

function BarrageTalkMgr:MSG_SET_SETTING(data) 
    if data.setting and data.setting.refuse_lookon_msg then
        m_isReceive = data.setting.refuse_lookon_msg == 0
        DlgMgr:sendMsg("WatchCentreBattleInterfaceDlg", "barrageBtnState")
    end
end

function BarrageTalkMgr:MSG_BROADCAST_COMBAT_DATA(data) 
    m_recorded_channel_interval = data.recorded_channel_interval
end

-- 发送弹幕至服务器
function BarrageTalkMgr:sendBarrageMsgForWedding()    

end


function BarrageTalkMgr:MSG_OPEN_WEDDING_CHANNEL(data) 

    BarrageTalkMgr:creatBarrageLayer()
    BarrageTalkMgr:MSG_SET_SETTING({setting = {refuse_lookon_msg = 0}}) 

    local dlg = DlgMgr:openDlgEx("WeddingBarrageDlg", data)

    -- 如果此时在战斗中，需要隐藏界面
    if Me:isInCombat() then
        dlg:setVisible(false)
    end
end

function BarrageTalkMgr:MSG_CLOSE_WEDDING_CHANNEL(data) 


    local dlg = DlgMgr:getDlgByName("WeddingBarrageDlg")
    if dlg then
        -- 关界面时，需求为，如果正在输入中，输入完成后关闭
        if dlg:getInputState() == "began" then
            dlg:setInputDownCloseDlg(true)
        else
            DlgMgr:closeDlg("WeddingBarrageDlg")
        end
    end
end

MessageMgr:hook("MSG_OPEN_WEDDING_CHANNEL", BarrageTalkMgr, "BarrageTalkMgr")
MessageMgr:hook("MSG_CLOSE_WEDDING_CHANNEL", BarrageTalkMgr, "BarrageTalkMgr")

MessageMgr:hook("MSG_SET_SETTING", BarrageTalkMgr, "BarrageTalkMgr")
MessageMgr:hook("MSG_BROADCAST_COMBAT_DATA", BarrageTalkMgr, "BarrageTalkMgr")

MessageMgr:regist("MSG_LOOKON_CHANNEL_MESSAGE", BarrageTalkMgr)
MessageMgr:regist("MSG_LOOKON_COMBAT_CHANNEL_DATA", BarrageTalkMgr)