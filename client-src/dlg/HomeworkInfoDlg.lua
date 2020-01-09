-- HomeworkInfoDlg.lua
-- Created by songcw June/18/2016
-- 师徒-授业任务活动界面

local HomeworkInfoDlg = Singleton("HomeworkInfoDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function HomeworkInfoDlg:init()
    self:bindListener("HomeworkInfoPanel", self.onCloseButton)
end

function HomeworkInfoDlg:setData(data)
    self:setLabelText("NameLabel", data.name)
    self:setLabelText("TimeLabel2", data.time)
    self:setLabelText("InfoLabel2", data.introduce)
    
    local srewardPanel = self:getControl("StudentRewardPanel")
    self:setReward("StudentRewardPanel", data.studentReward)
    self:setReward("TeacherRewardPanel", data.teacherReward)
end

function HomeworkInfoDlg:setReward(ctrlName, reward)
    local rewardPanel = self:getControl(ctrlName)
    rewardPanel:removeAllChildren(true)
    local rewardContainer  = RewardContainer.new(reward, rewardPanel:getContentSize(), nil, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(0, rewardPanel:getContentSize().height / 2)
    rewardPanel:addChild(rewardContainer)  
end

return HomeworkInfoDlg
