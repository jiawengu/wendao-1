-- PartyManageDlg.lua
-- Created by yangym Sep/8/2016
-- 帮派管理界面

local PartyManageDlg = Singleton("PartyManageDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")
local GAI_TOU_HUAN_MAIN_CARD = CHS[2000095]
local PARTY_LEVEL_UP_DATA =
{
    [1] = {constructNeed = 100000,  moneyNeed = 0      },
    [2] = {constructNeed = 500000,  moneyNeed = 1000000},
    [3] = {constructNeed = 1000000, moneyNeed = 3000000},
}

local PARTY_LEVEL_PRIMARY = 1      -- 初级帮派
local PARTY_LEVEL_MIDDLE  = 2      -- 中级
local PARTY_LEVEL_SENIOR  = 3      -- 高级
local PARTY_LEVEL_TOP     = 4      -- 顶级

function PartyManageDlg:init()
    self.iconPanel = self:getControl("IconPanel")
    self.renamePanel = self:getControl("RenamePanel")
    self.levelUpPanel = self:getControl("LevelUpPanel")

    self:bindListener("ConfirmButton_1", self.onConfirmButton1, self.levelUpPanel)
    self:bindListener("CancelButton_1",  self.onCancelButton1, self.levelUpPanel)
    self:bindListener("AddImage", self.onAddImage, self.iconPanel)
    self:bindListener("ClearButton", self.onClearButton, self.iconPanel)
    self:bindListener("SetlButton", self.onSetlButton, self.iconPanel)
    self:bindListener("ConfirmButton", self.onConfirmButton2, self.iconPanel)
    self:bindListener("ConfirmButton",   self.onConfirmButton, self.renamePanel)
    self:bindListener("CancelButton",    self.onCancelButton, self.renamePanel)
    self:bindListener("ItemPanel", self.onRenameCardIcon, self.renamePanel)
    self:getControl("ItemPanel"):setTouchEnabled(true)

    self.itemImg  = self:getControl("ItemImage",        Const.UIImage, self:getControl("ItemPanel", Const.UIPanel, self.renamePanel))
    self.itemCost = self:getControl("ItemCostNumLabel", Const.UILabel, self:getControl("ItemPanel", Const.UIPanel, self.renamePanel))
    self.itemUse  = self:getControl("ItemUseNumLabel",  Const.UILabel, self:getControl("CostPanel", Const.UIPanel, self.renamePanel))

    self.dayCastConstruLabel = self:getControl("Label_5", Const.UILabel, self:getControl("LabelPanel", Const.UIPanel, self.levelUpPanel))
    self.dayCastMoneyLabel   = self:getControl("Label_6", Const.UILabel, self:getControl("LabelPanel", Const.UIPanel, self.levelUpPanel))
    self.constructLabel = self:getControl("ConstructLabel", Const.UILabel, self:getControl("LabelPanel", Const.UIPanel, self.levelUpPanel))
    self.moneyLabel = self:getControl("MoneyLabel", Const.UILabel, self:getControl("LabelPanel", Const.UIPanel, self.levelUpPanel))

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"LevelupCheckBox", "RenameCheckBox", "IconCheckBox"}, self.onCheckbox)
    self.radioGroup:selectRadio(1)
    self:onLevelupButton()

    local partyName = Me:queryBasic("party/name")
    self.newNameEdit = self:createEditBox("NameInputPanel", nil, nil, function(sender, type)
        if type == "end" then

        elseif type == "changed" then
            local newName = self.newNameEdit:getText()

            if gf:getTextLength(newName) > 12 then
                newName = gf:subString(newName, 12)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end

            -- 若输入内容为空或与原名一样，则将按钮置灰；若不为空，使按钮可用。
            if newName == ""
                or newName == partyName then
                self:setCtrlEnabled("ConfirmButton", false)
            else
                self:setCtrlEnabled("ConfirmButton", true)
            end
        end
    end)
    self.newNameEdit:setPlaceholderFont(CHS[3003794], 23)
    self.newNameEdit:setFont(CHS[3003794], 23)
    self.newNameEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))
    self.newNameEdit:setPlaceHolder(CHS[7000029])

    -- 初始状态，确认按钮置灰
    self:setCtrlEnabled("ConfirmButton", false)
    self:onLevelupButton()

    local addImage = self:getControl("AddImage", Const.UIImage, self.iconPanel)
    addImage:setTouchEnabled(true)

    self:updateLayout(self:getControl("LabelPanel", Const.UIPanel, self.levelUpPanel))

    self:hookMsg("MSG_PARTY_INFO")
    self:hookMsg("MSG_SEND_ICON")
    self:hookMsg("MSG_INVENTORY")
end

-- 改头换面卡的点击事件
function PartyManageDlg:onRenameCardIcon()
    InventoryMgr:showBasicMessageDlg(GAI_TOU_HUAN_MAIN_CARD)
end

function PartyManageDlg:onDlgOpened(list, param)
    if "Icon" == param then
        self.radioGroup:selectRadio(3)
    end
end

function PartyManageDlg:onCheckbox(sender, eventType)
    local name = sender:getName()
    if "LevelupCheckBox" == name then
        self:onLevelupButton()
    elseif "RenameCheckBox" == name then
        self:onRenameButton()
    elseif "IconCheckBox" == name then
        self:onIconButton()
    end
end

function PartyManageDlg:setCost()
    if self.itemImg then
        local iconPath = ResMgr:getItemIconPath("9028")
        self.itemImg:loadTexture(iconPath)
        gf:setItemImageSize(self.itemImg)
    end

    if self.itemCost then
        self.itemCost:setString(tostring(1))
    end

    if self.itemUse then
        local items = InventoryMgr:filterBagItems({name = GAI_TOU_HUAN_MAIN_CARD})
        local count = 0
        if items then
            for i = 1, items.count do
                count = count + tonumber(items[i].amount)
            end
        end

        self.itemUse:setString(tostring(count > 999 and "*" or count))
        self.itemUse:setColor(0 == count and cc.c3b(255, 0, 0) or cc.c3b(86, 41, 2))
    end
end

-- 改帮派名字
function PartyManageDlg:onRenameButton()
--    self:getControl("BackgroundPanel"):setVisible(true)
--    self:getControl("CancelButton"):setVisible(true)
--    self:getControl("ConfirmButton"):setVisible(true)
--
--    self:getControl("LabelPanel"):setVisible(false)
--    self:getControl("ExpProgressBarPanel_1"):setVisible(false)
--    self:getControl("ExpProgressBarPanel_2"):setVisible(false)
--    self:getControl("CancelButton_1"):setVisible(false)
--    self:getControl("ConfirmButton_1"):setVisible(false)
    self.levelUpPanel:setVisible(false)
    self.renamePanel:setVisible(true)
    self.iconPanel:setVisible(false)

    self:setCost()

    -- 初始默认显示帮派名
    self.newNameEdit:setText(Me:queryBasic("party/name"))
end

-- 帮派升级
function PartyManageDlg:onLevelupButton()
--    self:getControl("LabelPanel"):setVisible(true)
--    self:getControl("ExpProgressBarPanel_1"):setVisible(true)
--    self:getControl("ExpProgressBarPanel_2"):setVisible(true)
--    self:getControl("CancelButton_1"):setVisible(true)
--    self:getControl("ConfirmButton_1"):setVisible(true)
--
--    self:getControl("BackgroundPanel"):setVisible(false)
--    self:getControl("CancelButton"):setVisible(false)
--    self:getControl("ConfirmButton"):setVisible(false)
    self.levelUpPanel:setVisible(true)
    self.renamePanel:setVisible(false)
    self.iconPanel:setVisible(false)

    self:setPartyLevelupInfo()
end

-- 帮派图标
function PartyManageDlg:onIconButton()
    self.levelUpPanel:setVisible(false)
    self.renamePanel:setVisible(false)
    self.iconPanel:setVisible(true)

    self:setPartyIcon()
end

-- 设置帮派图标
function PartyManageDlg:setPartyIcon()
    local partyIcon = PartyMgr:getPartyIcon()
    local reviewIcon = PartyMgr:getPartyReviewIcon()
    local itemPanel = self:getControl("ItemPanel", Const.UIPanel, self.iconPanel)

    if string.isNilOrEmpty(partyIcon) and string.isNilOrEmpty(reviewIcon) then
        -- 没有帮派图标
        self:setCtrlVisible("AddImage", true, itemPanel)
        self:setCtrlVisible("ItemImage", false, itemPanel)
        self:setCtrlVisible("StateLabel", true, itemPanel)
        self:setLabelText("StateLabel", CHS[2000200], itemPanel)
        self:setCtrlVisible("StateBKImage", true, itemPanel)

        self:setCtrlVisible("SetlButton", true, self.iconPanel)
        self:setCtrlVisible("ClearButton", false, self.iconPanel)
        self:setCtrlVisible("ConfirmButton", false, self.iconPanel)
    else
        -- 有帮派图标，检查状态
        self:setCtrlVisible("AddImage", false, itemPanel)
        self:setCtrlVisible("ItemImage", true, itemPanel)

        self:setCtrlVisible("SetlButton", false, self.iconPanel)

        local iconPath
        local isCustomIcon
        if not string.isNilOrEmpty(reviewIcon) and '(undefined)' ~= reviewIcon then
            -- 待审核
            if PartyMgr:getPartyMemberByJob(CHS[3003250]) ~= Me:getName() then
                -- 非帮主，使用默认图标
                iconPath = ResMgr.ui.default_review_icon
            else
                -- 帮主，使用审核图标
                iconPath = ResMgr:getCustomPartyIconPath(reviewIcon)
                isCustomIcon = true
                if not gf:isFileExist(iconPath) then
                    CharMgr:requestPartyIcon(reviewIcon)
                    iconPath = nil
                end
            end

            self:setCtrlVisible("StateLabel", true, itemPanel)
            self:setLabelText("StateLabel", CHS[2000201], itemPanel)
            self:setCtrlVisible("StateBKImage", true, itemPanel)

            self:setCtrlVisible("ClearButton", true, self.iconPanel)
            self:setCtrlVisible("ConfirmButton", true, self.iconPanel)
        else
            iconPath = ResMgr:getPartyIconPath(partyIcon)
            if not gf:isFileExist(iconPath) then
                iconPath = ResMgr:getCustomPartyIconPath(partyIcon)
                isCustomIcon = true
            end

            if not gf:isFileExist(iconPath) then
                CharMgr:requestPartyIcon(partyIcon)
                iconPath = nil
            end

            self:setCtrlVisible("StateLabel", false, itemPanel)
            self:setCtrlVisible("StateBKImage", false, itemPanel)
            self:setCtrlVisible("ClearButton", true, self.iconPanel)
            self:setCtrlVisible("ConfirmButton", true, self.iconPanel)
        end

        if iconPath then
            self:setImage("ItemImage", iconPath, itemPanel)
            if isCustomIcon then
                local img = self:getControl("ItemImage", Const.UIImage, itemPanel)
                if img then
                    img:ignoreContentAdaptWithSize(true)
                end
            else
                self:setImageSize("ItemImage", cc.size(64, 64), itemPanel)
            end
            self:setCtrlVisible("ItemImage", true, itemPanel)
        else
            self:setCtrlVisible("ItemImage", false, itemPanel)
        end
    end
end

function PartyManageDlg:setPartyLevelupInfo()

    -- 帮派日耗金钱与日耗建设度
    local dayCastMoney = gf:getMoneyDesc(PartyMgr:getDayCastMoney(), true)
    local dayCastConstru = gf:getMoneyDesc(PartyMgr:getDayCastConstru(), true)
    self.dayCastMoneyLabel:setString(dayCastMoney)
    self.dayCastConstruLabel:setString(dayCastConstru)

    -- 帮派建设进度以及帮派资金进度（升级）
    local partyInfo = PartyMgr:getPartyInfo()
    local partyMoney = partyInfo.money
    local partyConstruct = partyInfo.construct

    if partyInfo.partyLevel == PARTY_LEVEL_TOP then  -- 顶级帮派不再显示进度条，取而代之显示现有建设度和资金
        self:getControl("ExpProgressBarPanel_1"):setVisible(false)
        self:getControl("ExpProgressBarPanel_2"):setVisible(false)
        self.moneyLabel:setVisible(true)
        self.constructLabel:setVisible(true)

        local partyMoneyStr = gf:getMoneyDesc(partyMoney, true)
        local partyConstructStr = gf:getMoneyDesc(partyConstruct,true)
        self.moneyLabel:setString(partyMoneyStr)
        self.constructLabel:setString(partyConstructStr)
    else                                             -- 非顶级帮派显示进度条
        self:getControl("ExpProgressBarPanel_1"):setVisible(true)
        self:getControl("ExpProgressBarPanel_2"):setVisible(true)
        self.moneyLabel:setVisible(false)
        self.constructLabel:setVisible(false)

        local moneyNeedToLevelup = PARTY_LEVEL_UP_DATA[partyInfo.partyLevel].moneyNeed
        local constructNeedToLevelup = PARTY_LEVEL_UP_DATA[partyInfo.partyLevel].constructNeed

        -- 帮派建设进度条（包括进度条内数值显示）
        self:setProgressBar("ExpProgressBar", partyConstruct, constructNeedToLevelup, "ExpProgressBarPanel_1")

        local construProgress = tostring(partyConstruct) .. " / " .. tostring(constructNeedToLevelup)
        self:getControl("ExpvalueLabel", nil, "ExpProgressBarPanel_1"):setString(construProgress)
        self:getControl("ExpvalueLabel2", nil, "ExpProgressBarPanel_1"):setString(construProgress)

        -- 帮派资金进度条（包括进度条内数值显示）
        if moneyNeedToLevelup == 0 then  -- 初级帮派，资金进度条永远为满，并在进度条上只显示现有资金
            self:setProgressBar("ExpProgressBar", 100, 100, "ExpProgressBarPanel_2")
            self:getControl("ExpvalueLabel", nil, "ExpProgressBarPanel_2"):setString(tostring(partyMoney))
            self:getControl("ExpvalueLabel2", nil, "ExpProgressBarPanel_2"):setString(tostring(partyMoney))
        else
            self:setProgressBar("ExpProgressBar", partyMoney, moneyNeedToLevelup, "ExpProgressBarPanel_2")
            local moneyProgress = tostring(partyMoney) .. " / " .. tostring(moneyNeedToLevelup)
            self:getControl("ExpvalueLabel", nil, "ExpProgressBarPanel_2"):setString(moneyProgress)
            self:getControl("ExpvalueLabel2", nil, "ExpProgressBarPanel_2"):setString(moneyProgress)
        end
    end
end

-- 修改帮派名称
function PartyManageDlg:onConfirmButton(sender, eventType)

    -- 判断ME是否是帮主
    if not PartyMgr:isPartyLeader() then
        gf:ShowSmallTips(CHS[7000030])
        return
    end

    -- 是否处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 是否有可使用的改头换面卡
    local items = InventoryMgr:filterBagItems({name = GAI_TOU_HUAN_MAIN_CARD})
    if not items or #items <= 0 then
        gf:askUserWhetherBuyItem(GAI_TOU_HUAN_MAIN_CARD)
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onConfirmButton", sender, eventType) then
        return
    end

    -- 命名是否符合规范
    local name = self.newNameEdit:getText()
    if not PartyMgr:partyRenameCheck(name) then
        return
    end

    -- 向服务器发送重命名帮派请求
    gf:CmdToServer("CMD_PARTY_RENAME", {name = name, type = 0})
end

-- 帮派升级
function PartyManageDlg:onConfirmButton1(sender, eventType)
    gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_LEVEL_UP_PARTY)
end

function PartyManageDlg:onCancelButton1(sender, eventType)
    self:close()
end

function PartyManageDlg:onCancelButton(sender, eventType)
    self:close()
end

-- 添加帮派图标
function PartyManageDlg:onAddImage(sender, eventType)
    DlgMgr:openDlg("PartyManageIconDlg")
end

-- 清除
function PartyManageDlg:onClearButton(sender, eventType)
    if CHS[4000153] ~= PartyMgr:getPartyJob() then
        gf:ShowSmallTips(CHS[2000202])
        return
    end

    local partyIcon = PartyMgr:getPartyIcon()
    if string.isNilOrEmpty(partyIcon) then
        gf:ShowSmallTips(CHS[2000209])
        return
    end

    local reivewIcon = PartyMgr:getPartyReviewIcon()
    if not string.isNilOrEmpty(reivewIcon) then
        gf:ShowSmallTips(CHS[2000210])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onClearButton", sender, eventType) then return end

    gf:confirm(CHS[2000211], function()
        PartyMgr:clearPartyIcon()
    end)
end

-- 修改
function PartyManageDlg:onConfirmButton2(sender, eventType)
    DlgMgr:openDlg("PartyManageIconDlg")
end

function PartyManageDlg:onSetlButton(sender, eventType)
    DlgMgr:openDlg("PartyManageIconDlg")
end

function PartyManageDlg:MSG_PARTY_INFO(data)
    self:setPartyIcon()
end

function PartyManageDlg:MSG_SEND_ICON(data)
    self:setPartyIcon()
end

function PartyManageDlg:MSG_INVENTORY()
    self:setCost()
end

return PartyManageDlg
