-- PartyActiveNoteDlg.lua
-- Created by songcw May/9/2015
-- 帮派活动信息界面

local PartyActiveNoteDlg = Singleton("PartyActiveNoteDlg", Dialog)

function PartyActiveNoteDlg:init()
--[[ 
local introPanel = self:getControl("IntrducePanel")
self:setCtrlVisible("ContentLabel", false, introPanel)
local conditionPanel = self:getControl("LimitPanel")
self:setCtrlVisible("ContentLabel", false, conditionPanel)
--]]
    self.index = nil
end

function PartyActiveNoteDlg:setActiveInfo(index)
    local activeInfo = PartyMgr:getPartyActiveInfo()
    local dlgSize = self.root:getContentSize()

    local introPanel = self:getControl("IntrducePanel")

    self:setLabelText("NameLabel", activeInfo[index].name)

    self:setLabelText("DescLabel", activeInfo[index].time)

    local activeInfoPanel = self:getControl("IntrducePanel")
    -- self:setLabelText("ContentLabel", activeInfo[index].introduce, activeInfoPanel)
    local introduceHeightC = self:setContentText("IntrducePanel", activeInfo[index].introduce)

    local limitInfoPanel = self:getControl("LimitPanel")
    -- self:setLabelText("ContentLabel", activeInfo[index].limit, limitInfoPanel)
    local limitHeightC = self:setContentText("LimitPanel", activeInfo[index].limit)

    local size = self.root:getContentSize()
    self.root:setContentSize(size.width, size.height + limitHeightC + introduceHeightC)

    local bkImage = self:getControl("BKImage")
    size = bkImage:getContentSize()
    bkImage:setContentSize(size.width, size.height + limitHeightC + introduceHeightC)
    
    self.index = index
    --[[
    local introCut = self:setContentText("IntrducePanel", activeInfo[index].introduce)
    local ContentCut = self:setContentText("LimitPanel", activeInfo[index].limit)

    local rootSize = self.root:getContentSize()
    self.root:setContentSize(rootSize.width, rootSize.height - introCut - ContentCut)

    self:updateLayout("IntrducePanel")
    self:updateLayout("LimitPanel")
    ]]
    self.root:requestDoLayout()
    

end


function PartyActiveNoteDlg:setContentText(ctrlName, descript)
    local panel = self:getControl(ctrlName)
    local initSize = panel:getContentSize()
    local label = self:getControl("ContentLabel", nil, panel)
    local color = label:getColor()    
    local font = label:getFontSize()
    local textSize = label:getContentSize()
    local textCtrl = CGAColorTextList:create()

    textCtrl:setFontSize(font)
    textCtrl:setDefaultColor(color.r, color.g, color.b)
    textCtrl:setString(descript)
    textCtrl:setContentSize(textSize.width, 0)
    textCtrl:updateNow()

    local textW, textH = textCtrl:getRealSize()

    textCtrl:setPosition(0, textSize.height)
    label:addChild(tolua.cast(textCtrl, "cc.LayerColor"))

    local heightC = textH - textSize.height
    if heightC > 0 then
        panel:setContentSize(initSize.width, textH)
    end

    return math.max(heightC, 0) 
end

return PartyActiveNoteDlg
