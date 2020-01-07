-- NianyefanRuleDlg.lua
-- Created by huangzz Dec/13/2017
-- 年夜饭说明界面

local NianyefanRuleDlg = Singleton("NianyefanRuleDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function NianyefanRuleDlg:init(data)
    self:bindListener("LuckyRewad_1", self.onLuckyRewad)
    self:bindListener("ActivityRule_1", self.onActivityRule)
    
    self:setCtrlOnlyEnabled("LuckyRewad_2", false)
    self:setCtrlOnlyEnabled("ActivityRule_2", false)
    
    self:onLuckyRewad()
    
    self:setRewardView(data)
end

function NianyefanRuleDlg:setOneReward(cell, reward)
    local imgPath, textureResType = RewardContainer:getRewardPath(reward)
    local img = self:getControl("RewardImage", nil, cell)
    img:loadTexture(imgPath, textureResType)

    local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
    local item = TaskMgr:spliteItemInfo(itemInfoList, reward)

    if item.number and tonumber(item.number) > 1 and item.name ~= CHS[3002145] then
        self:setNumImgForPanel(img, ART_FONT_COLOR.NORMAL_TEXT, item.number, false, LOCATE_POSITION.RIGHT_BOTTOM, 19)
    end

    cell.reward = reward
end

function NianyefanRuleDlg:onShowItemInfo(sender, eventType)
    RewardContainer:imagePanelTouch(sender, eventType)
end

function NianyefanRuleDlg:setRewardView(data)
    for i = 1, #data do
        local panel = self:getControl("RewardPanel", nil, "InfoPanel_" .. i)
        local reward = TaskMgr:getRewardList(data[i].reward)
        self:setOneReward(panel, reward[1][1])
        self:bindTouchEndEventListener(panel, self.onShowItemInfo)
    end
end

function NianyefanRuleDlg:onLuckyRewad(sender, eventType)
    self:setCtrlVisible("RewardPanel", true)
    self:setCtrlVisible("LuckyRewad_2", true)
    
    self:setCtrlVisible("InfoPanel", false)
    self:setCtrlVisible("ActivityRule_2", false)
end

function NianyefanRuleDlg:onActivityRule(sender, eventType)
    self:setCtrlVisible("RewardPanel", false)
    self:setCtrlVisible("LuckyRewad_2", false)

    self:setCtrlVisible("InfoPanel", true)
    self:setCtrlVisible("ActivityRule_2", true)
end

return NianyefanRuleDlg
