-- AllDrawGiftDlg.lua
-- Created by 
-- 

local AllDrawGiftDlg = Singleton("AllDrawGiftDlg", Dialog)
local RewardContainer = require("ctrl/RewardContainer")

function AllDrawGiftDlg:init()
    self:bindListener("RealButton", self.onRealButton)
    self:bindListener("RealButton", self.onRealButton)
    self:bindListViewListener("ItemListView", self.onSelectItemListView)
    
    -- 克隆panel
    self.singelPanel = self:getControl("ItemPanel")
    self.singelPanel:retain()
    self.singelPanel:removeFromParent()
    
    self:setData()   
end

function AllDrawGiftDlg:cleanup()
    self:releaseCloneCtrl("singelPanel")
end

function AllDrawGiftDlg:setData()
    local data = GiftMgr.chargeDrawGiftDlgData
    local list = self:getControl("ItemListView")
    
    local function setSingelPanel(name, reward, panel)
        if gf:findStrByByte(name, CHS[3000089]) then
            -- 妖石
            self:setImagePlist("IconImage", ResMgr.ui["item_common"], panel)
            self:setItemImageSize("IconImage", panel)
        elseif gf:findStrByByte(name, CHS[3000782]) then              
            self:setImagePlist("IconImage", ResMgr.ui["big_equip"], panel)
        elseif gf:findStrByByte(name, CHS[3002147]) then           
            self:setImagePlist("IconImage", ResMgr.ui["daohang"], panel)
        elseif gf:findStrByByte(name, CHS[6200003]) then  
            self:setImagePlist("IconImage", ResMgr.ui["big_change_card"], panel)   
        elseif gf:findStrByByte(reward, CHS[4200186]) then            
            self:setImage("IconImage", ResMgr:getSmallPortrait(PetMgr:getPetIcon(name)), panel)
            self:setItemImageSize("IconImage", panel)
        else
            local iconPath , isPlist = ResMgr:getIconPathByName(name)
            if isPlist then
                self:setImagePlist("IconImage", iconPath, panel)
            else
                self:setImage("IconImage", iconPath, panel)
                self:setItemImageSize("IconImage", panel)
            end
        end

        self:setLabelText("NameLabel", name, panel)
        
        local btn = self:getControl("RealButton", nil, panel)
        btn.name = name

        local classList = TaskMgr:getRewardList(reward)
        if #classList > 0 and classList[1] and classList[1][1] then btn.reward = classList[1][1] end
        self:bindTouchEndEventListener(btn, self.onRealButton)
    end

    local row = math.floor(data.allCount / 2) + data.allCount % 2
    for i = 1, row do
        local panel = self.singelPanel:clone()
        local panel1 = self:getControl("ItemPanel1", nil, panel)
        local name = data.allReward[i * 2 - 1]        
        setSingelPanel(name, data.allRewardField[i * 2 - 1] , panel1)       
        
        local panel2 = self:getControl("ItemPanel2", nil, panel)
        if data.allReward[i * 2] then
            local name = data.allReward[i * 2]        
            setSingelPanel(name, data.allRewardField[i * 2], panel2) 
        else
            panel2:setVisible(false)
        end
  
        list:pushBackCustomItem(panel)
    end
    
    performWithDelay(self.root, function ()
        list:getInnerContainer():setContentSize(list:getInnerContainer():getContentSize().width, row * self.singelPanel:getContentSize().height)
        list:getInnerContainer():setPositionY(list:getContentSize().height - list:getInnerContainerSize().height)
    end,0)
    
    local panel = self:getControl("InfoPanel")
    self:setLabelText("TitleLabel", CHS[3002261] .. gf:getServerDate("%Y-%m-%d %H:%M", tonumber(data.startTime)) .. CHS[3002262] .. gf:getServerDate("%Y-%m-%d %H:%M", tonumber(data.endTime)), panel)

end

function AllDrawGiftDlg:onRealButton(sender, eventType)
    RewardContainer:imagePanelTouch(sender, eventType)
--[[
    if not sender.name then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(sender.name, rect)
    --]]
end

function AllDrawGiftDlg:onSelectItemListView(sender, eventType)
end

return AllDrawGiftDlg
