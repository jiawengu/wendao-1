-- KidsCreateDlg.lua
-- Created by huangzz Feb/21/2019
-- 夫妻之礼操作界面

local KidsCreateDlg = Singleton("KidsCreateDlg", Dialog)

local ITEM_INFO = {
    {name = CHS[5450482], icon = 02088, purchase_cost = 399999, purchase_type = "cash"},
    {name = CHS[5450483], icon = 02089, purchase_cost = 99, purchase_type = "coin"}
}

function KidsCreateDlg:init(data)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("InfoButton", self.onInfoButton)

    self:bindListener("RulePanel", self.onRulePanel)

    self:bindFloatPanelListener(self:getControl("RulePanel"))

    self.curId = data[1]
    self.rawX = data[2]
    self.rawY = data[3]

    self.selectTag = nil

    for i = 1, #ITEM_INFO do
        local panel = self:getControl("ChosePanel_" .. i)
        panel:setTag(i)
        if ITEM_INFO[i].purchase_type == "coin" then
            local str, color = gf:getArtFontMoneyDesc(ITEM_INFO[i].purchase_cost)
            self:setNumImgForPanel("ValuePanel", color, str, false, LOCATE_POSITION.MID, 19, panel)
        else
            local str, color = gf:getArtFontMoneyDesc(ITEM_INFO[i].purchase_cost)
            self:setNumImgForPanel("ValuePanel", color, str, false, LOCATE_POSITION.MID, 19, panel)
        end

        self:setImage("ItemImage", ResMgr:getItemIconPath(ITEM_INFO[i].icon), panel)

        self:bindTouchEndEventListener(panel, self.onItemPanel)
    end

    self:setBedInfo()
end

function KidsCreateDlg:setBedInfo()
    local furn = HomeMgr:getFurnitureById(self.curId)
    if not furn then
        return
    end

    -- 名称
    local name = furn:queryBasic("name")
    self:setLabelText("NameLabel", name, "BedPanel")

    -- 床的形象
    local bedImage = self:getControl("BedImage")
    bedImage:loadTexture(self:getBedRes(name))
    bedImage:setScale(0.85, 0.85)
end

-- 获取当前选中床的形象资源
function KidsCreateDlg:getBedRes(name)
    local icon = HomeMgr:getFurnitureIcon(name)
    return ResMgr:getFurniturePath(icon)
end

function KidsCreateDlg:onItemPanel(sender, eventType)
    local tag = sender:getTag()
    self:setCtrlVisible("ChosenBKImage", false, "ChosePanel_1")
    self:setCtrlVisible("ChosenBKImage", false, "ChosePanel_2")

    if tag == self.selectTag then
        self.selectTag = nil
        self:setLabelText("ChoosenLabel", CHS[5450481] .. CHS[7100146])
        return
    end

    self:setCtrlVisible("ChosenBKImage", true, sender)
    self.selectTag = sender:getTag()

    self:setLabelText("ChoosenLabel", CHS[5450481] .. ITEM_INFO[self.selectTag].name)
end

function KidsCreateDlg:onStartButton(sender, eventType)
    local furn = HomeMgr:getFurnitureById(self.curId)
    if not furn then
        -- 家具已消失
        gf:ShowSmallTips(CHS[4200431])
        self:onCloseButton()
        return
    end

    local x, y = gf:convertToMapSpace(furn.curX, furn.curY)
    if x ~= self.rawX or y ~= self.rawY then
        -- 家具位置移动
        gf:ShowSmallTips(CHS[2000391])
        self:onCloseButton()
        return
    end

    if self.selectTag and ITEM_INFO[self.selectTag] then
        -- 安全锁判断
        if self:checkSafeLockRelease("onStartButton") then
            return
        end

        HomeMgr:cmdHouseUseFurniture(self.curId, "sex_love", ITEM_INFO[self.selectTag].purchase_type)
    else
        HomeMgr:cmdHouseUseFurniture(self.curId, "sex_love")
    end
end

function KidsCreateDlg:onInfoButton(sender, eventType)
    self:setCtrlVisible("RulePanel", true)
end

function KidsCreateDlg:onRulePanel(sender, eventType)
    self:setCtrlVisible("RulePanel", false)
end


return KidsCreateDlg
