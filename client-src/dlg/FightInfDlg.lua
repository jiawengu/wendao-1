-- FightInfDlg.lua
-- Created by chenyq Dec/2/2014
-- 战斗信息对话框

local NumImg = require('ctrl/NumImg')
local FightInfDlg = Singleton("FightInfDlg", Dialog)

local DEFAULT_TIME_MAX = 25

function FightInfDlg:init()
    self:setFullScreen()

    -- 将倒计时图片、等待图片添加到 TimePanel 中
    local timePanel = self:getControl('TimePanel')
    if timePanel then
        local sz = timePanel:getContentSize()
        self.numImg = NumImg.new('bfight_num', DEFAULT_TIME_MAX, false, -5)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.numImg:setVisible(false)
        self.numImg:setScale(0.5, 0.5)
        timePanel:addChild(self.numImg)
        self.waitImg = self:getControl("WaitImage", Const.UIImage)
        self.numImg:setPosition(sz.width / 2, sz.height / 2)
        self.waitImg:setVisible(false)
    end

    if BattleSimulatorMgr:isRunning() and not BattleSimulatorMgr:getCurCombatData().hasWaitTime then
        -- 如果存在战斗模拟器，并且有不需要显示
        self:setCtrlVisible("TimePanel", false)
    end

    self:setCtrlVisible("GzPanel", false)

    local battleArrayInfo = FightMgr:getBattleArrayInfo()
    if battleArrayInfo then
        self:MSG_BATTLE_ARRAY_INFO(battleArrayInfo)
    else
        self:setCtrlVisible("ZhenfPanel1", false)
        self:setCtrlVisible("ZhenfPanel2", false)
    end

    self:hookMsg("MSG_BATTLE_ARRAY_INFO")
end

-- 开始计时
function FightInfDlg:startCountDown(time)
    if not self.numImg then
        return
    end

    if BattleSimulatorMgr:isRunning() and not BattleSimulatorMgr:getCurCombatData().hasWaitTime then
        -- 如果存在战斗模拟器，并且有不需要显示
        return
    end

    self.numImg:setNum(time, false)
    self.numImg:setVisible(true)
    self.waitImg:setVisible(false)
    self:setCtrlVisible("TimePanel", true)

    self.numImg:startCountDown(function()
        -- 时间到
        self:setCtrlVisible("TimePanel", false)
    end)
end

-- 设置是否显示等待提示
function FightInfDlg:showPleaseWait(show)
    if show then
        self.numImg:stopCountDown()
        self.numImg:setVisible(false)
        self.waitImg:setVisible(true)
        self:setCtrlVisible("TimePanel", true)

        FightMgr:hideOperateDlgs()
    else
        self.waitImg:setVisible(false)
        self:setCtrlVisible("TimePanel", false)
    end
end

-- 返回剩余倒计时
function FightInfDlg:getLeftTime()
    if self.numImg then
        return self.numImg.num
    else
        return 0
    end
end

-- 设置显示观战
function FightInfDlg:showLookInfo()
    self:setCtrlVisible("TimePanel", false)
    self:setCtrlVisible("BackImage", true)
end

-- 设置观战人数
function FightInfDlg:setLookOnNum(data)
    if data.num and data.num > 0 then
        self:setCtrlVisible("GzPanel", true)
        self:setLabelText("ValueLabel", CHS[5400593] .. data.num, "GzPanel")
    else
        self:setCtrlVisible("GzPanel", false)
    end
end

function FightInfDlg:isPlayFight()
    if not self.numImg:isVisible() and not self.waitImg:isVisible() then
        return true
    end

    return false
end

function FightInfDlg:setPolarImage(panel, polar, isRestrain)
    local img
    if polar == 0 then
        img = self:getControl("Image", Const.UIImage, panel)
        img:loadTexture(ResMgr.ui.zhenfa_non_polar, ccui.TextureResType.localType)
        img:setScale(1)
    else
        local path = ResMgr:getSuitPolarImagePath(polar)
        img = self:getControl("Image", Const.UIImage, panel)
        img:loadTexture(path, ccui.TextureResType.plistType)
        img:setScale(0.6)
    end

    if isRestrain then
        gf:grayImageView(img)
    else
        gf:resetImageView(img)
    end
end

function FightInfDlg:MSG_BATTLE_ARRAY_INFO(data)
    if data.opponent_polar == 0 and data.friend_polar == 0 then
        self:setCtrlVisible("ZhenfPanel1", false)
        self:setCtrlVisible("ZhenfPanel2", false)
    else
        self:setCtrlVisible("ZhenfPanel1", true)
        self:setCtrlVisible("ZhenfPanel2", true)
        self:setPolarImage("ZhenfPanel1", data.opponent_polar, data.type == 1)
        self:setPolarImage("ZhenfPanel2", data.friend_polar, data.type == -1)
    end
end

return FightInfDlg
