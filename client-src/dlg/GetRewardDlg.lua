-- GetRewardDlg.lua
-- Created by songcw Oct/09/2015
-- 通天塔突破修练奖励界面

local GetRewardDlg = Singleton("GetRewardDlg", Dialog)

function GetRewardDlg:init()
    self:bindListener("NextLevelButton", self.onNextLevelButton)
    self:bindListener("FlyButton", self.onFlyButton)
    self:bindListener("EnterButton", self.onEnterButton)
end

function GetRewardDlg:setBonus(data)
    -- 当前没有经验和道行奖励图片资源，所以不做处理
    local expImage = self:getControl("ExpImage")
    if data.bonusType == "exp" then
        expImage:loadTexture(ResMgr.ui["small_exp"], ccui.TextureResType.plistType)
        self:setLabelText("ExpLabel", data.bonusValue)
    else
        -- "tao"
        expImage:loadTexture(ResMgr.ui["small_daohang"], ccui.TextureResType.plistType)
        self:setLabelText("ExpLabel", gf:getTaoStr(data.bonusValue, data.bonusTaoPoint))
    end
end

-- 切换修炼奖励界面按钮状态
function GetRewardDlg:switchFightBtnStatues(type)
    if type == 1 then
        -- 显示飞升，挑战下层按钮
        self:setCtrlVisible("FlyButton", true)
        self:setCtrlEnabled("FlyButton", true)

        self:setCtrlVisible("NextLevelButton", true)
        self:setCtrlEnabled("NextLevelButton", true)

        self:setCtrlVisible("EnterButton", false)
        self:setCtrlEnabled("EnterButton", false)
    elseif type == 2 then
        -- 显示进塔修炼按钮
        self:setCtrlVisible("FlyButton", false)
        self:setCtrlEnabled("FlyButton", false)

        self:setCtrlVisible("NextLevelButton", false)
        self:setCtrlEnabled("NextLevelButton", false)

        self:setCtrlVisible("EnterButton", true)
        self:setCtrlEnabled("EnterButton", true)
    end
end

function GetRewardDlg:onEnterButton(sender, eventType)
    AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[2200070]))
    self:onCloseButton()
end

function GetRewardDlg:onNextLevelButton(sender, eventType)
    DlgMgr:sendMsg("MissionDlg", "onChallengeButton")
    self:onCloseButton()
end

function GetRewardDlg:onFlyButton(sender, eventType)
    DlgMgr:sendMsg("MissionDlg", "onFlyButton")
    self:onCloseButton()
end

return GetRewardDlg
