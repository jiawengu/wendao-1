-- EquipmentChangePolarDlg.lua
-- Created by songcw Aug/4/2015
-- 选择相性界面

local EquipmentChangePolarDlg = Singleton("EquipmentChangePolarDlg", Dialog)

function EquipmentChangePolarDlg:init()
    for i = 1,5 do
        local button = self:getControl("PolarButton" .. i)
        button:setTag(i)
        self:bindTouchEndEventListener(button, self.onPolarButton)
    end
    
    self.pos = nil
end

function EquipmentChangePolarDlg:onPolarButton(sender, eventType)
    local tag = sender:getTag()
    DlgMgr:sendMsg("EquipmentRefiningSuitDlg", "setPolar", tag)
    self:onCloseButton()
end

function EquipmentChangePolarDlg:getSelectItemBox()
    local con = Me:queryBasicInt("con")
    local dex = Me:queryBasicInt("dex")
    local wiz = Me:queryBasicInt("wiz")
    local str = Me:queryBasicInt("str")
    local panel
    if con >= math.max(wiz, str, dex) then
        panel = self:getControl("PolarPanel2")        
    elseif dex >= math.max(con, wiz, str) then
        panel = self:getControl("PolarPanel4")
    elseif wiz >= math.max(con, str, dex) then
        panel = self:getControl("PolarPanel1")
    elseif str >= math.max(con, wiz, dex) then
        panel = self:getControl("PolarPanel5")
    else
        panel = self:getControl("PolarPanel3")
    end
    
    local image = self:getControl("PolarImage", nil, panel)
    return self:getBoundingBoxInWorldSpace(image)
end

return EquipmentChangePolarDlg
