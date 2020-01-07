-- AchievementRewardDlg.lua
-- Created by songcw Sep/12/2017
-- 成就界面-奖励

local AchievementRewardDlg = Singleton("AchievementRewardDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")
local RadioGroup = require("ctrl/RadioGroup")

function AchievementRewardDlg:init()
    self:bindListener("ReceiveButton", self.onReceiveButton)

    self.clothesPanel = self:getControl("ClothesPanel")
    self.titleRewardPanel = self:getControl("TitleRewardPanel")
    self.clothesPanel:setVisible(false)
    self.titleRewardPanel:setVisible(false)

    self:hookMsg("MSG_ACHIEVE_OVERVIEW")
end

function AchievementRewardDlg:setData(data)
    if data.bonus_desc == "" then
        self:setLabelText("RewardLabel", CHS[4100849])
        self.clothesPanel:setVisible(false)
        self.titleRewardPanel:setVisible(true)
    else
        local classList = TaskMgr:getRewardList(data.bonus_desc)
        local count = #classList[1]
        if count == 8 then
             self:setCustomInfo(classList)
        else
            self.clothesPanel:setVisible(false)
            self.titleRewardPanel:setVisible(true)

            local imgPath,textureResType = RewardContainer:getRewardPath(classList[1][1])
            if textureResType == 1 then
                self:setImagePlist("RewardImage", imgPath)
            else
                self:setImage("RewardImage", imgPath)
            end

            local content = RewardContainer:getRewardInfo(classList[1][1])
            if content then
                self:setLabelText("RewardLabel", content.basicInfo[1] .. ": " .. content.basicInfo[2])
            else
                self:setLabelText("RewardLabel", "")
            end
        end
    end

    local total = math.min(data.total, data.bonus_point)
    self:setProgressBar("ProgressBar", total, data.bonus_point)

    self:setLabelText("ValueLabel", string.format("%d/%d", total, data.bonus_point))
    self:setLabelText("ValueLabel_1", string.format("%d/%d", total, data.bonus_point))

    self:setCtrlEnabled("ReceiveButton", data.can_bonus == 1)
end

function AchievementRewardDlg:onReceiveButton(sender, eventType)

    AchievementMgr:getBonus()
end

function AchievementRewardDlg:MSG_ACHIEVE_OVERVIEW(data)

    self:setData(data)
end

function AchievementRewardDlg:setCustomInfo(classList)
    self.titleRewardPanel:setVisible(false)
    self.clothesPanel:setVisible(true)

    -- 成就8000点，奖励8件时装
    local function refreshCustomInfo()
        local startIndex = 5
        if self.isFemale then
            startIndex = 1
        end

        -- 头发
        local imgPath, _ = RewardContainer:getRewardPath(classList[1][startIndex])
        self:setImage("ItemImage", imgPath, "HairPanel")
        gf:setItemImageSize(self:getControl("ItemImage", nil, "HairPanel"))
        local content = RewardContainer:getRewardInfo(classList[1][startIndex])
        self:setLabelText("HairNameLabel", content.basicInfo[1])

        -- 衣服
        local imgPath, _ = RewardContainer:getRewardPath(classList[1][startIndex + 1])
        self:setImage("ItemImage", imgPath, "BodyPanel")
        gf:setItemImageSize(self:getControl("ItemImage", nil, "BodyPanel"))
        local content = RewardContainer:getRewardInfo(classList[1][startIndex + 1])
        self:setLabelText("BodyNameLabel", content.basicInfo[1])

        -- 裤子
        local imgPath, _ = RewardContainer:getRewardPath(classList[1][startIndex + 2])
        self:setImage("ItemImage", imgPath, "TrousersPanel")
        gf:setItemImageSize(self:getControl("ItemImage", nil, "TrousersPanel"))
        local content = RewardContainer:getRewardInfo(classList[1][startIndex + 2])
        self:setLabelText("TrousersNameLabel", content.basicInfo[1])

        -- 武器
        local imgPath, _ = RewardContainer:getRewardPath(classList[1][startIndex + 3])
        self:setImage("ItemImage", imgPath, "WeaponPanel")
        gf:setItemImageSize(self:getControl("ItemImage", nil, "WeaponPanel"))
        local content = RewardContainer:getRewardInfo(classList[1][startIndex + 3])
        self:setLabelText("WeaponNameLabel", content.basicInfo[1])
    end

    self.isFemale = Me:queryBasicInt("gender") == GENDER_TYPE.FEMALE
    self:createSwichButton(self:getControl("SexPanel"), self.isFemale, function(dlg, isOn)
        self.isFemale = isOn
        refreshCustomInfo()
    end)

    refreshCustomInfo()
end

-- ---------------- 性别切换按钮事件，参考 CustomDressDlg
function AchievementRewardDlg:createSwichButton(statePanel, isOn, func, key)
    -- 创建滑动开关
    local actionTime = 0.2
    local bkImage1 = self:getControl("ManImage", nil, statePanel)
    local bkImage2 = self:getControl("WomanImage", nil, statePanel)
    local image = self:getControl("ChoseButton", nil, statePanel)
    local psize = statePanel:getContentSize()
    local iSize = image:getContentSize()
    local px1 = iSize.width / 2
    local px2 = psize.width - px1
    local isAtionEnd = true
    image:setTouchEnabled(false)

    local function switchColor(isOn)
        if isOn then
            bkImage1:setColor(cc.c3b(51, 51, 51))
            bkImage1:setOpacity(33)
            bkImage2:setColor(cc.c3b(255, 255, 255))
            bkImage2:setOpacity(255)
        else
            bkImage1:setColor(cc.c3b(255, 255, 255))
            bkImage1:setOpacity(255)
            bkImage2:setColor(cc.c3b(51, 51, 51))
            bkImage2:setOpacity(33)
        end
    end

    local function swichButtonAction(self, sender, eventType, data, noCallBack)
        local action
        if isAtionEnd then
            if statePanel.isOn then
                local moveto = cc.MoveTo:create(actionTime, cc.p(px1, image:getPositionY()))
                isAtionEnd = false
                local fuc = cc.CallFunc:create(function ()
                    local delayFunc  = cc.CallFunc:create(function ()
                        switchColor(statePanel.isOn)
                        isAtionEnd = true
                        if not noCallBack then
                            func(self, statePanel.isOn, key)
                        end
                    end)

                    local sq = cc.Sequence:create(delayFunc)

                    bkImage2:runAction(sq)
                end)

                action = cc.Sequence:create(moveto, fuc)
                image:runAction(action)

                statePanel.isOn = not statePanel.isOn
            else
                local moveto = cc.MoveTo:create(actionTime, cc.p(px2, image:getPositionY()))
                isAtionEnd = false
                local fuc = cc.CallFunc:create(function ()
                    local delayFunc  = cc.CallFunc:create(function ()
                        switchColor(statePanel.isOn)
                        isAtionEnd= true
                        if not noCallBack then
                            func(self, statePanel.isOn, key)
                        end
                    end)

                    local sq = cc.Sequence:create(delayFunc)
                    bkImage1:runAction(sq)
                end)

                action = cc.Sequence:create(moveto, fuc)
                image:runAction(action)
                statePanel.isOn = not statePanel.isOn
            end

        end
    end

    self:bindTouchEndEventListener(statePanel, swichButtonAction)
    local function onNodeEvent(event)
        if "cleanup" == event then
            if not isAtionEnd and func then
                func(self, statePanel.isOn, key)
            end
        end
    end

    statePanel:registerScriptHandler(onNodeEvent)

    statePanel.touchAction = swichButtonAction

    -- 外部强行停止ACTION时，保证isAtionEnd不会因此而无法重置
    image.resetActionEndFlag = function()
        isAtionEnd = true
    end

    switchColor(statePanel.isOn)
end

function AchievementRewardDlg:switchButton(statePanel, isOn)
    self.isFemale = isOn
    if statePanel.isOn == isOn then return end

    statePanel.isOn = isOn
    local bkImage1 = self:getControl("ManImage", nil, statePanel)
    local bkImage2 = self:getControl("WomanImage", nil, statePanel)
    local image = self:getControl("ChoseButton", nil, statePanel)
    local psize = statePanel:getContentSize()
    local iSize = image:getContentSize()
    local px1 = iSize.width / 2
    local px2 = psize.width - px1

    if isOn then
        bkImage1:setColor(cc.c3b(51, 51, 51))
        bkImage1:setOpacity(33)
        bkImage2:setColor(cc.c3b(255, 255, 255))
        bkImage2:setOpacity(255)
        image:setPositionX(px2)
    else
        bkImage1:setColor(cc.c3b(255, 255, 255))
        bkImage1:setOpacity(255)
        bkImage2:setColor(cc.c3b(51, 51, 51))
        bkImage2:setOpacity(33)
        image:setPositionX(px1)
    end
end
-- ---------------- 性别切换按钮事件，参考 CustomDressDlg

return AchievementRewardDlg
