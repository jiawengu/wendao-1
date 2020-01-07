-- GMNPCListDlg.lua
-- Created by songcw July/11/2016
-- GM查询NPC列表

local GMNPCListDlg = Singleton("GMNPCListDlg", Dialog)

function GMNPCListDlg:init()
    self.unitPanel = self:getControl("OneNPCPanel")
    self.unitPanel:removeFromParent()
    self.unitPanel:retain()
    
    self.selectImage = self:getControl("ChosenEffectImage", nil, self.unitPanel)
    self.selectImage:removeFromParent()
    self.selectImage:retain()
    self.selectImage:setVisible(true)
    
    -- 事件监听
    self:bindTouchEndEventListener(self.unitPanel, self.onChosenPanel)
end

function GMNPCListDlg:onChosenPanel(sender)
    if not self.selectImage then return end
    self.selectImage:removeFromParent()
    sender:addChild(self.selectImage)
end

function GMNPCListDlg:cleanup()
    self:releaseCloneCtrl("unitPanel")
    self:releaseCloneCtrl("selectImage")
end

function GMNPCListDlg:setData(data)
    local list = self:resetListView("ListView")
    for i = 1, data.count do
        local panel = self.unitPanel:clone()
        self:setLabelText("NameLabel", data.npc[i], panel)
        list:pushBackCustomItem(panel)
    end
end


return GMNPCListDlg
