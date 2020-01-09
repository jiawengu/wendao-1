-- PartyPokeBubbleDlg.lua
-- Created by huangzz, Sep/05/2017
-- 培育巨兽益智训练（戳泡泡）

local ChildrenDayDlg = require('dlg/ChildrenDayDlg')
local PartyPokeBubbleDlg = Singleton("PartyPokeBubbleDlg", ChildrenDayDlg)

function PartyPokeBubbleDlg:getCfgFileName()
    return ResMgr:getDlgCfg("ChildrenDayDlg")
end

function PartyPokeBubbleDlg:init()
    self:setFullScreen()
    
    self:bindListener("PauseButton", self.onPauseButton)
    self:bindListener("CloseImage", self.onResultPanel, "ResultPanel_1")
    self:bindListener("CloseImage", self.onResultPanel, "ResultPanel_2")
    self:bindListener("CloseImage", self.onResultPanel, "ResultPanel_3")
    self:bindListener("RestartPanel", self.onReStartPanel, "ResultPanel_3")
    self:bindListener("CloseImage2", self.onResultPanel, "ResultPanel_3")

    self:setCtrlVisible("GameResultPanel", true)

    -- 获取屏幕尺寸
    local winSize = cc.Director:getInstance():getWinSize()
    self.rootHeight = winSize.height / Const.UI_SCALE
    self.rootWidth = winSize.width / Const.UI_SCALE
    
    -- 加载背景图
    local dlgBack = ccui.ImageView:create(ResMgr.loadingPic.qipao)
    dlgBack:setPosition(self.rootWidth / 2, self.rootHeight / 2)
    dlgBack:setAnchorPoint(0.5, 0.5)
    dlgBack:setTouchEnabled(true)
    self.blank:addChild(dlgBack)
    local order = self.root:getOrderOfArrival()
    self.root:setOrderOfArrival(dlgBack:getOrderOfArrival())
    dlgBack:setOrderOfArrival(order)
    
    self:setCtrlFullClient("BubblePanel")
    self:setCtrlFullClient("BlackPanel", "StarPanel")
    self:setCtrlFullClient("BlackPanel", "ResultPanel_1")
    self:setCtrlFullClient("BlackPanel", "ResultPanel_2")
    self:setCtrlFullClient("BlackPanel", "ResultPanel_3")

    self.root:requestDoLayout()
    
    self.running = false
    self.numImg = nil

    self.bubblePanel = self:getControl("BubblePanel")
    self.root:scheduleUpdateWithPriorityLua(function(deltaTime) if self.running then self:updateBubble(deltaTime) end end, 0)
    
    -- 注册事件
    self:hookMsg("MSG_PARTY_YZXL_POKE")
    self:hookMsg("MSG_PARTY_YZXL_QUIT")
    self:hookMsg("MSG_PARTY_YZXL_REMOVE")
    self:hookMsg("MSG_PARTY_YZXL_START")
    self:hookMsg("MSG_PARTY_YZXL_END")
end

function PartyPokeBubbleDlg:initData(param)
    self:setCtrlVisible("ResultPanel_1", false, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_2", false, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_3", false, "GameResultPanel")
    self:setCtrlVisible("StarPanel", false)
    
    -- 创建气泡
    self.bubbles = {}
    local datas = param.bubbles
    for i = 1, #datas do
        self.bubbles[datas[i].gid] = self:createBubble(datas[i].gid, datas[i].type)
    end

    -- 倒计时
    local readyId
    local readyTime = param.ready_time - 1
    self:createCountDown(readyTime)
    self:startCountDown(readyTime, function()
        -- 开始计时
        self:showGameTime(true, param.game_time)
        self.running = true
    end)
    local numPanel = self:getControl("NumPanel", nil, "TimePanel")
    self:setNumImgForPanel(numPanel, ART_FONT_COLOR.DEFAULT, param.game_time, false, LOCATE_POSITION.LEFT_TOP, 23)

    -- 初始化分数
    self:setBubbleNum("BluePanel", 0, ART_FONT_COLOR.DEFAULT)
    self:setBubbleNum("PurplePanel", 0, ART_FONT_COLOR.DEFAULT)
    self:setBubbleNum("GoldenPanel", 0, ART_FONT_COLOR.DEFAULT)
    local totalNumLabel = self:getControl("TotalNumLabel", Const.UIAtlasLabel)
    totalNumLabel:setString(tostring(0))

    self.lastClickTime = 0
    self.speedScale = 1
    self.costTime = 0
end

-- 移除泡泡
function PartyPokeBubbleDlg:removeBubble(bubble)
    bubble.speed = nil
    gf:CmdToServer("CMD_PARTY_YZXL_REMOVE", { gid = bubble.gid })
end

-- 点击泡泡
function PartyPokeBubbleDlg:onClickBubble(bubble)
    if not self:checkClickTime() or not bubble:isVisible() then return end

    local gid = bubble.gid
    gf:CmdToServer('CMD_PARTY_YZXL_POKE', { gid = gid })


    -- 气泡破碎效果
    self:playBubbleBreak(gid)

    self.lastClickTime = gf:getTickCount()
end

-- 暂停按钮
function PartyPokeBubbleDlg:onPauseButton(sender, eventType)
    gf:CmdToServer('CMD_PARTY_YZXL_QUIT', { type = "request" })
end

function PartyPokeBubbleDlg:onReStartPanel(sender, eventType)
    gf:CmdToServer('CMD_PARTY_YZXL_REPLAY', {})
end

-- 继续游戏
function PartyPokeBubbleDlg:onResultPanel(sender, eventType)
    self:onCloseButton()
    
    local task = TaskMgr:getTaskByShowName(CHS[5400241])
    if task then
        gf:doActionByColorText(task.task_prompt, task)
    end
end

function PartyPokeBubbleDlg:MSG_PARTY_YZXL_QUIT(data)
    self.running = data.type ~= "request"
    self:showGameTime(data.type ~= "request", data.left_time)

    if "request" == data.type then
        gf:confirmEx(CHS[5400237], CHS[2100082], function()
            -- 退出
            gf:CmdToServer('CMD_PARTY_YZXL_QUIT', { type = "confirm" })
        end, CHS[2100083], function()
            -- 继续
            gf:CmdToServer('CMD_PARTY_YZXL_QUIT', { type = "cancel" })
        end)
    end
end

function PartyPokeBubbleDlg:clearData()
    if self.bubbles then
        for _, bubble in pairs(self.bubbles) do
            bubble:removeFromParent()
        end
        
        self.bubbles = {}
    end
    
    if self.numImg then
        self.numImg:removeFromParent()
        self.numImg = nil
    end
    
    self.running = false
end

function PartyPokeBubbleDlg:MSG_PARTY_YZXL_START(data)
    self:clearData(data)
    
    self:initData(data)
end

function PartyPokeBubbleDlg:setBonus(data)
    self:setCtrlVisible("ResultPanel_1", false, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_2", false, "GameResultPanel")
    self:setCtrlVisible("ResultPanel_3", true, "GameResultPanel")

    local resultPanel = self:getControl("ResultPanel_3", nil, "GameResultPanel")

    -- 当前分数
    local numPanel = self:getControl("NumPanel", nil, resultPanel)
    self:setNumImgForPanel(numPanel, "bfight_num", data.blue_score + data.gold_score + data.purple_score, false, LOCATE_POSITION.MID, 25)

    -- 蓝
    self:setLabelText("NumLabel_1", data.blue_score, self:getControl("BluePanel", nil, resultPanel))
   
    -- 紫
    self:setLabelText("NumLabel_1", data.purple_score, self:getControl("PurplePanel", nil, resultPanel))
    
    -- 金
    self:setLabelText("NumLabel_1", data.gold_score, self:getControl("GoldenPanel", nil, resultPanel))
    
    if data.result == 1 then
        self:setCtrlVisible("ResultImage1", true, resultPanel)
        self:setCtrlVisible("ResultImage2", false, resultPanel)
        self:setCtrlVisible("CloseImage", true, resultPanel)
        self:setCtrlVisible("RestartPanel", false, resultPanel)
        self:setCtrlVisible("CloseImage2", false, resultPanel)
    else
        self:setCtrlVisible("ResultImage1", false, resultPanel)
        self:setCtrlVisible("ResultImage2", true, resultPanel)
        self:setCtrlVisible("CloseImage", false, resultPanel)
        self:setCtrlVisible("RestartPanel", true, resultPanel)
        self:setCtrlVisible("CloseImage2", true, resultPanel)
    end
end

function PartyPokeBubbleDlg:MSG_PARTY_YZXL_END(data)
    self.running = false
    self:showGameTime(false)

    if -1 == data.result then
        self:onCloseButton()
        return
    end

    self:setBonus(data)

    local numPanel = self:getControl("NumPanel", nil, "TimePanel")
    self:setNumImgForPanel(numPanel, ART_FONT_COLOR.DEFAULT, 0, false, LOCATE_POSITION.LEFT_TOP, 23)
end

function PartyPokeBubbleDlg:MSG_PARTY_YZXL_POKE(data)
    self:MSG_CHILD_DAY_2017_POKE(data)
end

function PartyPokeBubbleDlg:MSG_PARTY_YZXL_REMOVE(data)
    self:MSG_CHILD_DAY_2017_REMOVE(data)
end

return PartyPokeBubbleDlg