-- AchievementCompleteDlg.lua
-- Created by songcw Sep/12/2017
-- 成就界面-奖励

local AchievementCompleteDlg = Singleton("AchievementCompleteDlg", Dialog)

function AchievementCompleteDlg:init()
    self:setFullScreen()

    self:bindListener("MainPanel", self.onOpenAchieveButton)

    self.data = nil

    -- 5秒后关闭
    performWithDelay(self.root, function ()
    	self:onCloseButton()
    end, 5)

    self:createArmatureAction(ResMgr.ArmatureMagic.chengjiu.name, ResMgr.ArmatureMagic.chengjiu.action)

    self.blank:setLocalZOrder(Const.ZORDER_ACHIEVEMENT)
end


function AchievementCompleteDlg:createArmatureAction(icon, actionName, callback)
    local magic = ArmatureMgr:createArmature(icon)

    local function func(sender, etype, id)
        if self.curMagic ~= magic then return end
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
            self.curMagic = nil
            if callback and "function" == type(callback) then callback() end
        end
    end

    local panel = self:getControl("MainPanel")
    magic:setAnchorPoint(0.5, 0.5)
    local size = panel:getContentSize()
    magic:setPosition(size.width / 2, size.height * 0.5)
    panel:addChild(magic)

    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(actionName)

    self.curMagic = magic
    self.curMagic.quickFinish = function()
        magic:stopAllActions()
        magic:removeFromParent(true)
        self.curMagic = nil
    end
end

function AchievementCompleteDlg:onOpenAchieveButton(sender)
    AchievementMgr:stopAutoComp()

    DlgMgr:sendMsg("GameFunctionDlg", "onAchievementButton")
end

function AchievementCompleteDlg:setData(data)
    self.data = data
    self:setImage("GuardImage", AchievementMgr:getIconById(data.achieve_id))

    local achieve = AchievementMgr:getAchieveInfoById(data.achieve_id)

    self:setLabelText("PetNumberLabel", data.achieve_name)

    self:setLabelText("AchieveLabel", achieve.point)

    AchievementMgr:removeAchieveCompByName(data.achieve_name)

    if achieve.achieve_desc and achieve.achieve_desc ~= "" then
        self:setLabelText("DescLabel", string.format(achieve.achieve_desc, achieve.progress))
    end
end

function AchievementCompleteDlg:cleanup()
    AchievementMgr:openNextAchieve()
end

return AchievementCompleteDlg
