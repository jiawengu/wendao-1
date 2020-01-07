-- ScratchRewardInfoDlg.lua
-- Created by by huangzz Dec/09/2016
-- 寒假刮刮乐玩法说明界面

local VariationPetList = require (ResMgr:getCfgPath("VariationPetList.lua"))
local ScratchRewardInfoDlg = Singleton("ScratchRewardInfoDlg", Dialog)
local REDBAG_TAG = 6695

local pRText,image
function ScratchRewardInfoDlg:init()
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001757]].icon), self:getControl("PortraitPanel1", nil, "PrizePanel2")) -- 鼠
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001757]].icon), self:getControl("PortraitPanel2", nil, "PrizePanel2"))
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001757]].icon), self:getControl("PortraitPanel3", nil, "PrizePanel2"))
    
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001757]].icon), self:getControl("PortraitPanel1", nil, "PrizePanel3"))
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001757]].icon), self:getControl("PortraitPanel2", nil, "PrizePanel3"))
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001762]].icon), self:getControl("PortraitPanel3", nil, "PrizePanel3")) -- 牛
    
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001757]].icon), self:getControl("PortraitPanel1", nil, "PrizePanel4"))
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001762]].icon), self:getControl("PortraitPanel2", nil, "PrizePanel4"))
    self:setImage("PortraitImage", ResMgr:getSmallPortrait(VariationPetList[CHS[3001767]].icon), self:getControl("PortraitPanel3", nil, "PrizePanel4")) -- 虎
end


return ScratchRewardInfoDlg
