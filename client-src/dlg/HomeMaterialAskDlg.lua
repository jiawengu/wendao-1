-- HomeMaterialAskDlg.lua
-- Created by songcw
-- 

local HomeMaterialAskDlg = Singleton("HomeMaterialAskDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 单选框
local CHECKBOX = { "SettingCheckBox",  "GetCheckBox", "RuleBox" }

local MSG_LIMIT = 30 * 2
local ASK_CD_TIME = 2 * 60 * 1000   -- 发布CD时间

-- 单选框对应显示的panel
local CHECKBOX_DISPLAY = {
    SettingCheckBox = "SettingPanel",
    GetCheckBox = "GetPanel",
    RuleBox = "RulePanel",
}

function HomeMaterialAskDlg:init()
    -- 互助谢礼的增加、删除按钮绑定
    local giftPanel = self:getControl("GiftPanel")
    local needPanel = self:getControl("NeedPanel")
    for i = 1, 3 do
        local unitPanel = self:getControl("SingleGiftPanel" .. i)
        self:setCtrlTag("AddButton", i, unitPanel)
        self:setCtrlTag("DeleteButton", i, unitPanel)
        self:bindListener("AddButton", self.onHelpAddButton, unitPanel)
        self:bindListener("DeleteButton", self.onHelpDeleteButton, unitPanel)
        
        self:bindListener("ItemImage", self.onShowItemButton, unitPanel)
        
        self:bindTouchEndEventListener(unitPanel, self.onTips2Button)
        
        local unitItemPanel = self:getControl("ItemPanel" .. i, nil, needPanel)
        unitItemPanel:setTag(i)
        self:bindListener("ItemPanel" .. i, self.onReleaseAddButton, needPanel)
        self:setCtrlTag("DeleteButton", i, unitItemPanel)
        self:bindListener("DeleteButton", self.onReleaseDelButton, unitItemPanel)
        self:bindListener("NoneImage", self.onTipsButton, unitItemPanel)
        self:bindListener("IconImage", self.onShowItemButton, unitItemPanel)
        
        self:setCtrlTag("ChangeButton", i, unitItemPanel)
        self:bindListener("ChangeButton", self.onReleaseAddButton, unitItemPanel)
    end

    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ReleasePanel", self.onTipsButton)
    self:bindListener("DelButton", self.onDelMsgButton, "MessagePanel")
    
    
    self.giftPanel = self:retainCtrl("GiftPanel", "GetPanel")
    self:bindListener("ItemIconPanel", self.onShowItemButton, self.giftPanel)
    self:bindListener("GetButton", self.onGetButton, self.giftPanel)
    
    self:bindListener("GetAllButton", self.onGetAllButton)
    
    self.newNameEdit = self:createEditBox("InputPanel", nil, nil, function(sender, type) 
        if type == "ended" then
            self.newNameEdit:setText("")
			self:setCtrlVisible("TextInfoLabel", true, "MessagePanel")
        elseif type == "began" then
            local msg = self:getLabelText("TextInfoLabel", "MessagePanel")
            self:setCtrlVisible("TextInfoLabel", false, "MessagePanel")
            self.newNameEdit:setText(msg)
        elseif type == "changed" then
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > MSG_LIMIT then
                newName = gf:subString(newName, MSG_LIMIT)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end    

            if gf:getTextLength(newName) == 0 then
                self:setCtrlVisible("DelButton", false, "MessagePanel")
                self:setCtrlVisible("NoneLabel", true, "MessagePanel")
            else
                self:setCtrlVisible("NoneLabel", false, "MessagePanel")
                self:setCtrlVisible("DelButton", true, "MessagePanel")
            end  
            
            self:setLabelText("TextInfoLabel", newName, "MessagePanel")
      --      self.newNameEdit:setText("")
        end
    end)
    self.newNameEdit:setLocalZOrder(1)
    self.newNameEdit:setPlaceholderFont(CHS[3003597], 20)
    self.newNameEdit:setFont(CHS[3003597], 19)
    self.newNameEdit:setFontColor(cc.c3b(76, 32, 0))
    self.newNameEdit:setText("")
    

    -- 初始化单选框
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, CHECKBOX, self.onCheckBox)
    self.radioGroup:setSetlctByName(CHECKBOX[1])

    HomeMgr:queryGetList()
    self:resetListView("ListView")    
    
    self.data = nil
    self.isGetAll = false
    if HomeMgr.resetAskLastTime then
        self.lastTime = nil
        HomeMgr.resetAskLastTime = false
    end

    local data = HomeMgr:getExchangeData()
	if data then
		self:setData(data)
	end

    self:hookMsg("MSG_ME_EXCHANGE_MATERIAL_DATA")
    self:hookMsg("MSG_MATERIAL_MAILBOX_REFRESH")
    self:hookMsg("MSG_FETCH_MATERIAL_MAIL")    
    
end

function HomeMaterialAskDlg:setData(data)
    self:setHelpHonorariumData(data)
    self:setReleaseData(data)
    
    self:setCtrlVisible("ReleasePanel", data.is_publish == 1)
    self:setCtrlVisible("CancelButton", data.is_publish == 1)
    self:setCtrlVisible("ConfirmButton", data.is_publish ~= 1)
    
    if not self.data or (self.data and self.data.is_publish == 0 and data.is_publish == 1) then    
        self:setLabelText("TextInfoLabel", data.msg, "MessagePanel")        
        if gf:getTextLength(data.msg) == 0 then
            self:setCtrlVisible("DelButton", false, "MessagePanel")
            self:setCtrlVisible("NoneLabel", true, "MessagePanel")
        else
            self:setCtrlVisible("NoneLabel", false, "MessagePanel")
            self:setCtrlVisible("DelButton", data.is_publish ~= 1, "MessagePanel")
        end      
    end
    
    --[[
    if not self.data and data.has_material_unfetch == 1 and self.radioGroup:getSelectedRadioName() ~= "GetCheckBox" then
        RedDotMgr:insertOneRedDot("HomeMaterialAskDlg", "GetCheckBox")
    end
    --]]
    
    if self.data and self.data.is_publish == 0 and data.is_publish == 1 then
        self.lastTime = gfGetTickCount() 
    end
    
    self.data = data
end

-- 设置控件的tag
function HomeMaterialAskDlg:setCtrlTag(ctrlName, tag, root)
    local ctl = self:getControl(ctrlName, nil, root)
    if ctl then
        ctl:setTag(tag)
    end
end

-- 设置主要的panel可见性
function HomeMaterialAskDlg:setMainPanelVisible(panelName)
    for _, name in pairs(CHECKBOX_DISPLAY) do
        self:setCtrlVisible(name, name == panelName)
    end
end

-- Check点击事件
function HomeMaterialAskDlg:onCheckBox(sender, eventType)
    self.isGetAll = false
    local displayName = CHECKBOX_DISPLAY[sender:getName()]
    self:setMainPanelVisible(displayName)
    RedDotMgr:removeOneRedDot("HomeMaterialAskDlg", sender:getName())
end

function HomeMaterialAskDlg:setReleaseData(data)
    local panel = self:getControl("NeedPanel")
    if not data then data = {} end
    for i = 1, 3 do
        local unitPanel = self:getControl("ItemPanel" .. i)
        self:setUnitRelease(data.needData[i + 10], data.is_publish == 1, unitPanel)
    end
end

function HomeMaterialAskDlg:setHelpHonorariumData(data)
    local panel = self:getControl("GiftPanel")

    for i = 1, 3 do
        local unitPanel = self:getControl("SingleGiftPanel" .. i)
        self:setUnitHonorarium(data.giftData[i + 20], data.is_publish == 1, unitPanel)
    end
end

-- 设置单个谢礼 
-- data == nil表示没有设置谢礼
-- isDone 表示是否操作完成 （发送至服务器）
function HomeMaterialAskDlg:setUnitHonorarium(data, isDone, panel)
    local isNotPick = not data or not next(data)            -- 为true表示没有选择谢礼
    self:setCtrlVisible("ItemImage", not isNotPick, panel)
    self:setCtrlVisible("NameLabel", not isNotPick, panel)
    self:setCtrlVisible("NumLabel", not isNotPick, panel)
    self:setCtrlVisible("NoneLabel", isNotPick, panel)
    self:setCtrlVisible("AddButton", isNotPick, panel)
    self:setCtrlVisible("DeleteButton", not isNotPick, panel)

    -- 如果选好谢礼，设置相关信息
    if data and next(data) then
        self:setImage("ItemImage", ResMgr:getIconPathByName(data.name), panel)
        self:setLabelText("NameLabel", data.name, panel)
        self:setLabelText("NumLabel", "× " .. data.num, panel)
    end

    -- 设置按钮状态 如果设置好了，已经发送服务器了，需要隐藏按钮
    if isDone then
        self:setCtrlVisible("AddButton", false, panel)
        self:setCtrlVisible("DeleteButton", false, panel)
    end
    
    panel.data = data
end

function HomeMaterialAskDlg:updateHonorarium(ctlName, item, count)
    local panel = self:getControl(ctlName)
    local data 
    if item then
        data = {name = item.name, count = count}
    end
    self:setUnitHonorarium(data, data.is_publish == 1, panel)
end

function HomeMaterialAskDlg:updateRelease(ctlName, item, count)
    local panel = self:getControl(ctlName)
    local data 
    if item then
        data = {name = item.name, count = count}
    end
    self:setUnitRelease(data, data.is_publish == 1, panel)
end

-- 设置单个发布求助
function HomeMaterialAskDlg:setUnitRelease(data, isDone, panel)
    local isNotPick = not data or not next(data)            -- 为true表示没有选择发布信息
    self:setCtrlVisible("ButtonPanel", not isNotPick, panel)
    self:setCtrlVisible("NameLabel", not isNotPick, panel)
    self:setCtrlVisible("HaveNumLabel", not isNotPick, panel)
    self:setCtrlVisible("DeleteButton", false, panel)
    self:setCtrlVisible("NeedNumPanel", false, panel)
    self:setCtrlVisible("AddImage", false, panel)
    self:setCtrlVisible("DeleteButton", false, panel)
    self:setCtrlVisible("IconImage", false, panel)
    self:setCtrlVisible("NoneLabel", isNotPick, panel)
    self:setCtrlVisible("NoneLabel2", false, panel)
    self:setCtrlVisible("NoneImage", false, panel)
    
    self:setCtrlVisible("AskImage", false, panel)
    self:setCtrlVisible("FinishImage", false, panel)
    self:setCtrlVisible("ChangeButton", false, panel)
    self:setCtrlVisible("NumLabel2", true, panel)
    self:setLabelText("NumLabel2", "", panel)
    
    panel.data = data

    -- 如果选好发布内容，设置相关信息
    if data and next(data) then
        self:setImage("IconImage", ResMgr:getIconPathByName(data.name), panel)
        self:getControl("IconImage", nil, panel):getParent().data = data
        self:setLabelText("NameLabel", data.name, panel)  
        self:setCtrlVisible("IconImage", true, panel)
        if isDone then
            self:setCtrlVisible("FinishImage", data.get_num >= data.req_num, panel)
            self:setCtrlVisible("AskImage", data.get_num < data.req_num, panel)            
            self:setLabelText("NumLabel2", string.format(CHS[4100766], data.get_num, data.req_num), panel)
            self:setLabelText("NumLabel", string.format("%d/%d", data.get_num, data.req_num), panel)
        else
            self:setCtrlVisible("ChangeButton", true, panel)
            self:setLabelText("NumLabel", string.format("%d/%d", data.get_num, data.req_num), panel)
            
            self:setCtrlVisible("NeedNumPanel", true, panel)
            self:setCtrlVisible("DeleteButton", true, panel)
        end
    else
        self:getControl("IconImage", nil, panel):getParent().data = nil

        if isDone then
            self:setCtrlVisible("IconImage", true, panel)
            self:setCtrlVisible("NoneLabel2", true, panel)
            self:setCtrlVisible("NoneLabel", false, panel)
            self:setCtrlVisible("NoneImage", true, panel)
        else
            self:setCtrlVisible("AddImage", true, panel)
        end

    end

end

function HomeMaterialAskDlg:onReleaseDelButton(sender, eventType)
    HomeMgr:removeNeed(sender:getTag())
end



function HomeMaterialAskDlg:onReleaseAddButton(sender, eventType)
    if sender.data then return end
    local data = HomeMgr:getExchangeData()
    if data.is_publish == 1 then return end
    local dlg = DlgMgr:openDlg("HomeChooseItemDlg")
    dlg:setData(1, sender:getTag())
end

function HomeMaterialAskDlg:onShowItemButton(sender, eventType)
    local panel = sender:getParent()
    local rect = self:getBoundingBoxInWorldSpace(sender)
  --  InventoryMgr:showBasicMessageDlg(panel.data.name, rect)
    
    local dlg = DlgMgr:openDlg("ItemInfoDlg")
    local info = gf:deepCopy(InventoryMgr:getItemInfoByName(panel.data.name) or {})
    if not info then
        return
    end

    info.name = panel.data.name
    if info.item_class == ITEM_CLASS.FISH then
        info.item_type = ITEM_TYPE.FISH
    end

    dlg:setInfoFormCard(info)
    dlg:setFloatingFramePos(rect)
end

function HomeMaterialAskDlg:onHelpDeleteButton(sender, eventType)
    HomeMgr:removeGift(sender:getTag())
end

function HomeMaterialAskDlg:onHelpAddButton(sender, eventType)
    local dlg = DlgMgr:openDlg("HomeChooseItemDlg")
    dlg:setData(2, sender:getTag())
end


function HomeMaterialAskDlg:onDelMsgButton(sender, eventType)
    self:setLabelText("TextInfoLabel", "", "MessagePanel")
    self.newNameEdit:setText("")
    self:setCtrlVisible("DelButton", false, "MessagePanel")
    self:setCtrlVisible("NoneLabel", true, "MessagePanel")     
end

function HomeMaterialAskDlg:onTips2Button(sender, eventType)
    local data = HomeMgr:getExchangeData()
    if not data then return end
    if data.is_publish == 1 then
        self:onTipsButton()
    end
end

function HomeMaterialAskDlg:onTipsButton(sender, eventType)
    gf:ShowSmallTips(CHS[4100767])
end

function HomeMaterialAskDlg:onConfirmButton(sender, eventType)
    local data = HomeMgr:getExchangeData()
    if data.isNoSet then
        gf:ShowSmallTips(CHS[4100768])  -- 当前并未设置任何求助材料，无法发布。
        return
    end     

    if self.lastTime and gfGetTickCount() - self.lastTime <= ASK_CD_TIME then
        local min = math.min(2, math.ceil((ASK_CD_TIME - (gfGetTickCount() - self.lastTime)) / (60 * 1000)))
        min = math.max(1, min)
        gf:ShowSmallTips(string.format(CHS[4100769], min))   -- 请勿频繁发送求助信息，请#R%d#n分钟后再尝试。
        return
    end

    local msg = self:getLabelText("TextInfoLabel", "MessagePanel")
    local nameText, haveBadName = gf:filtText(msg, nil, true)
    if haveBadName then
        gf:confirm(CHS[4100770], function ()
            self:setLabelText("TextInfoLabel", nameText, "MessagePanel")
        end, nil, nil, nil, nil, nil, true)
        return
    end
    
    if data.giftCount == 0 then
        gf:confirm(CHS[4100771], function ()
            if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                gf:ShowSmallTips(CHS[5410117])
                return
            end
            
            gf:confirm(CHS[4100772], function ()
                if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                    gf:ShowSmallTips(CHS[5410117])
                    return
                end
                

                HomeMgr:publishExchange(self:getLabelText("TextInfoLabel", "MessagePanel"))
            end)
        end)
    else
        gf:confirm(CHS[4100772], function ()
            if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                gf:ShowSmallTips(CHS[5410117])
                return
            end
            
            HomeMgr:publishExchange(self:getLabelText("TextInfoLabel", "MessagePanel"))
        end)
    end
end

function HomeMaterialAskDlg:onCancelButton(sender, eventType)
    gf:confirm(CHS[4100773], function ()
        if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
            gf:ShowSmallTips(CHS[5410117])
            return
        end
        
        HomeMgr:unPublishExchange()
    end)
end

function HomeMaterialAskDlg:onGetButton(sender, eventType)
    local panel = sender:getParent()
    if panel.data then
        if gf:getServerTime() - panel.data.create_time > 86400 * 7 then
            gf:ShowSmallTips(CHS[4100778])
            local list = self:getControl("ListView")
            list:removeChild(panel)
            list:requestRefreshView()
            self:setCtrlVisible("NoticePanel", #list:getItems() == 0)
            self:setCtrlEnabled("GetAllButton", #list:getItems() ~= 0)
            return
        end
    
        HomeMgr:getGiftBymail(panel.data.id)
    end
end

function HomeMaterialAskDlg:onGetAllButton(sender, eventType)
--[[

    local items = list:getItems()
    for _, panel in pairs(items) do
        if panel.data then
            HomeMgr:getGiftBymail(panel.data.id)
        end
    end
    --]]
    
    local list = self:getControl("ListView")
    local items = list:getItems()
    if items and items[1] then
        HomeMgr:getGiftBymail(items[1].data.id)
        self.isGetAll = true
    else
        self.isGetAll = false
    end
end

function HomeMaterialAskDlg:onSelectListView(sender, eventType)
end

function HomeMaterialAskDlg:MSG_ME_EXCHANGE_MATERIAL_DATA(data)
    self:setData(data)
end

function HomeMaterialAskDlg:setUnitGetPanel(data, panel)
    -- icon 
    local playerPanel = self:getControl("PlayerIconPanel", nil, panel)
    self:setImage("IconImage", ResMgr:getSmallPortrait(data.sender_icon), playerPanel)
    
    -- level
    self:setNumImgForPanel(playerPanel, ART_FONT_COLOR.NORMAL_TEXT, data.sender_level, false, LOCATE_POSITION.LEFT_TOP, 21)

    -- name
    self:setLabelText("PlayerNameLabel", data.sender, panel)

    local leftTime = gf:getServerTime() - data.create_time
    local timeStr = ""
    if leftTime < 60 then 
        timeStr = string.format(CHS[4100774], 1)
    elseif leftTime < 60 * 60 then
        timeStr = string.format(CHS[4100774], math.floor(leftTime / 60))
    elseif leftTime < 60 * 60 * 24 then
        timeStr = string.format(CHS[4100775], math.floor(leftTime / (60 * 60)))
    else
        timeStr = string.format(CHS[4100776], math.floor(leftTime / (60 * 60 * 24)))
    end

    -- 时间
    self:setLabelText("TimeLabel", timeStr, panel)

    -- 物品名称
    local classList = TaskMgr:getRewardList(data.attachment)
    local itemInfoList = gf:splitBydelims(classList[1][1][2], {"%", "$", "#r"})
    local tempData = TaskMgr:spliteItemInfo(itemInfoList)
    self:setLabelText("ItemNameLabel", tempData.name, panel)
    
    -- 物品icon
    local playerPanel = self:getControl("ItemIconPanel", nil, panel)
    self:setImage("IconImage", ResMgr:getIconPathByName(tempData.name), playerPanel)

    -- 数量
    self:setLabelText("NumTimeLabel", string.format(CHS[4100777], tempData.number), panel)    

    panel.data = data
    panel.data.name = tempData.name
end

function HomeMaterialAskDlg:MSG_MATERIAL_MAILBOX_REFRESH(data)
    local list = self:getControl("ListView")    
    self:setCtrlVisible("NoticePanel", data.count == 0)
    
    self:setCtrlEnabled("GetAllButton", data.count ~= 0)

    table.sort(data.info, function(l, r)
        if l.create_time < r.create_time then return true end
        if l.create_time > r.create_time then return false end
    end)
    
    for i = 1, data.count do
        local panel = self.giftPanel:clone()
        self:setUnitGetPanel(data.info[i], panel)
        list:pushBackCustomItem(panel)
    end
    
    if self.radioGroup:getSelectedRadioName() ~= "GetCheckBox" and data.count > 0 then
        RedDotMgr:insertOneRedDot("HomeMaterialAskDlg", "GetCheckBox")
    end
end

function HomeMaterialAskDlg:MSG_FETCH_MATERIAL_MAIL(data)
    local list = self:getControl("ListView")
    local items = list:getItems()
    for _, panel in pairs(items) do
        self:onGetButton(panel)
        if panel.data and panel.data.id == data.id then
            list:removeChild(panel)
        end
    end    
    list:requestRefreshView()
    self:setCtrlVisible("NoticePanel", #list:getItems() == 0)
    self:setCtrlEnabled("GetAllButton", #list:getItems() ~= 0)
    
    if self.isGetAll then
        local items = list:getItems()
        if items and items[1] then
            HomeMgr:getGiftBymail(items[1].data.id)
        else
            self.isGetAll = false
        end
    end
end

function HomeMaterialAskDlg:cleanup(data)
    -- 关闭该界面时，同时关闭各个子界面
    DlgMgr:closeDlg("HomeChooseItemDlg")
end

return HomeMaterialAskDlg
