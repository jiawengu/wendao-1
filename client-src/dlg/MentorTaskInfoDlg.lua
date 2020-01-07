-- MentorTaskInfoDlg.lua
-- Created by huangzz Dec/19/2018
-- 师徒任务悬浮框

local MentorTaskInfoDlg = Singleton("MentorTaskInfoDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function MentorTaskInfoDlg:init()
    self:bindListener("MentorTaskInfoPanel", self.onCloseButton)
end

function MentorTaskInfoDlg:setData(data)
    self:setLabelText("NameLabel", data.name)
    self:setLabelText("TimeLabel2", data.time)
    self:setLabelText("LevelLabel2", data.level)
    self:setLabelText("RanksLabel2", data.team)
    self:setLabelText("InfoLabel2", data.introduce)
    
    local srewardPanel = self:getControl("StudentRewardPanel")
    self:setReward("StudentRewardPanel", data.studentReward)
    self:setReward("TeacherRewardPanel", data.teacherReward)
end

function MentorTaskInfoDlg:setReward(ctrlName, reward)
    local rewardPanel = self:getControl(ctrlName)
    rewardPanel:removeAllChildren(true)
    local rewardContainer  = RewardContainer.new(reward, rewardPanel:getContentSize(), nil, nil, true)
    rewardContainer:setAnchorPoint(0, 0.5)
    rewardContainer:setPosition(0, rewardPanel:getContentSize().height / 2)
    rewardPanel:addChild(rewardContainer)  
end

return MentorTaskInfoDlg
