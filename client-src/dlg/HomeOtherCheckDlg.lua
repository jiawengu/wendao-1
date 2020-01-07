-- HomeOtherCheckDlg.lua
-- Created by huangzz Sep/11/2017
-- 居所入口其它提醒界面

local HomeOtherCheckDlg = Singleton("HomeOtherCheckDlg", Dialog)

local BED_INFO = {
    [1] = {leveType = CHS[7002343]},
    [2] = {leveType = CHS[7002344]},
    [3] = {leveType = CHS[7002345]},
}

local HOME_HETANG_ICON = {
    [1] = ResMgr.ui.xiaoshe_hetang,
    [2] = ResMgr.ui.yazhu_hetang,
    [3] = ResMgr.ui.haozhai_hetang,
}

local NEED_CLEAN_MAX_CLEAN = 20

function HomeOtherCheckDlg:init()
    self:bindListener("CheckButton", self.onCheckButton, "InfoPanel2")
    self:bindListener("CheckButton", self.onCheckButton, "InfoPanel1")
    
    self.infoPanel = self:retainCtrl("InfoPanel2")
    self.otherPanel = self:retainCtrl("OtherPanel")
    
    self:setCtrlVisible("NonePanel", false, self.infoPanel)
    
    gf:CmdToServer("CMD_HOUSE_OTHER_FURNITURE_DATA", {})
    self:hookMsg("MSG_HOUSE_OTHER_FURNITURE_DATA")
end

function HomeOtherCheckDlg:onCheckButton(sender, eventType)
    if sender.destStr then
        AutoWalkMgr:beginAutoWalk(gf:findDest(sender.destStr))
        DlgMgr:closeDlg("HomeOtherCheckDlg")
    end
end

function HomeOtherCheckDlg:setBedView(num, maxNum, icon, bedroomType, cell)
    self:setImage("GuardImage", ResMgr:getItemIconPath(icon), cell)

    local titlePanel = self:getControl("TitlePanel", nil, cell)
    self:setLabelText("NameLabel", BED_INFO[bedroomType].leveType .. CHS[2000252], titlePanel)
    
    self:setImage("EffectImage", ResMgr.ui.small_hint_bed, titlePanel)
    
    local contentPanel = self:getControl("ContentPanel", nil, cell)
    self:setLabelText("NumLabel", num .. "/" .. maxNum, contentPanel)
    self:setLabelText("NameLabel", CHS[5420202], contentPanel)
    self:setImage("EffectImage", ResMgr.ui.small_hint_sleep, contentPanel)
    
    local button = self:getControl("CheckButton", nil, cell)
    button.destStr = CHS[5420210]
end

function HomeOtherCheckDlg:setFishView(num, maxNum, homeType,cell)
    self:setImage("GuardImage", HOME_HETANG_ICON[homeType], cell)

    local titlePanel = self:getControl("TitlePanel", nil, cell)
    local homeTypeName = HomeMgr:getHomeTypeCHS(homeType)
    self:setLabelText("NameLabel", homeTypeName .. CHS[5410118], titlePanel)
    self:setImage("EffectImage", ResMgr.ui.small_hint_pond, titlePanel)

    local contentPanel = self:getControl("ContentPanel", nil, cell)
    self:setLabelText("NumLabel", num .. "/" .. maxNum, contentPanel)
    self:setLabelText("NameLabel", CHS[5420203], contentPanel)
    self:setImage("EffectImage", ResMgr.ui.small_hint_fish, contentPanel)
    
    local button = self:getControl("CheckButton", nil, cell)
    button.destStr = CHS[5420211]
end

function HomeOtherCheckDlg:setZCSView(num, maxNum, cell)
    local info = HomeMgr:getFurnitureInfo(CHS[5400111])
    self:setImage("GuardImage", ResMgr:getItemIconPath(info.icon), cell)
    
    local titlePanel = self:getControl("TitlePanel", nil, cell)
    self:setLabelText("NameLabel", CHS[5400111], titlePanel)
    self:setImage("EffectImage", ResMgr.ui.small_hint_tree, titlePanel)

    local contentPanel = self:getControl("ContentPanel", nil, cell)
    self:setLabelText("NumLabel", num .. "/" .. maxNum, contentPanel)
    self:setLabelText("NameLabel", CHS[5420204], contentPanel)
    self:setImage("EffectImage", ResMgr.ui.small_hint_zcnf, contentPanel)
    
    local button = self:getControl("CheckButton", nil, cell)
    button.destStr = CHS[5420212]
end

function HomeOtherCheckDlg:setCleanView(num, maxNum, cell)
    self:setImage("GuardImage", ResMgr.ui.home_broom, cell)
    
    local titlePanel = self:getControl("TitlePanel", nil, cell)
    self:setLabelText("NameLabel", CHS[5420209], titlePanel)
    self:setImage("EffectImage", ResMgr.ui.small_hint_home, titlePanel)

    local contentPanel = self:getControl("ContentPanel", nil, cell)
    self:setLabelText("NumLabel", num .. "/" .. maxNum, contentPanel)
    self:setLabelText("NameLabel", CHS[5420205], contentPanel)
    self:setImage("EffectImage", ResMgr.ui.small_hint_broom, contentPanel)
    
    local button = self:getControl("CheckButton", nil, cell)
    button.destStr = CHS[5420210]
end

function HomeOtherCheckDlg:setListView(data)
    local listView = self:resetListView("MainListView", 5)
    
    self.itemCou = 0
    if data.bed_icon > 0 and data.max_rest_count > data.cur_rest_count then
        local cell = self:getItem(listView)
        self:setBedView(data.cur_rest_count, data.max_rest_count, data.bed_icon, data.bedroom_type, cell)
    end
    
    if data.max_fish_count > data.cur_fish_count then
        local cell = self:getItem(listView)
        self:setFishView(data.cur_fish_count, data.max_fish_count, data.home_type, cell)
    end
    
    if data.max_nafu_count > data.cur_nafu_count then
        local cell = self:getItem(listView)
        self:setZCSView(data.cur_nafu_count, data.max_nafu_count, cell)
    end

    if data.cur_cleanliness <= NEED_CLEAN_MAX_CLEAN then
        local cell = self:getItem(listView)
        self:setCleanView(data.cur_cleanliness, data.max_cleanliness, cell)
    end
    
    if self.itemCou == 0 then
        listView:pushBackCustomItem(self.otherPanel)
    end
    
    self:setCtrlVisible("ShapePanel", self.itemCou ~= 0, self.otherPanel)
    self:setCtrlVisible("TitlePanel", self.itemCou ~= 0, self.otherPanel)
    self:setCtrlVisible("ContentPanel", self.itemCou ~= 0, self.otherPanel)
    self:setCtrlVisible("BKImage", self.itemCou ~= 0, self.otherPanel)
    -- self:setCtrlVisible("CheckButton", self.itemCou ~= 0, self.otherPanel)
    self:setCtrlVisible("NonePanel", self.itemCou == 0, self.otherPanel)
end

function HomeOtherCheckDlg:getItem(listView, cou)
    local cell
    if self.itemCou == 0 then
        cell = self.otherPanel
    else
        cell = self.infoPanel:clone()
    end
    
    listView:pushBackCustomItem(cell)
    self.itemCou = self.itemCou + 1
    return cell
end

function HomeOtherCheckDlg:MSG_HOUSE_OTHER_FURNITURE_DATA(data)
    self:setListView(data)
end

return HomeOtherCheckDlg
