-- UserRenameDlg.lua
-- Created by cheny Dec/05/2014
-- 角色改名

local UserRenameDlg = Singleton("UserRenameDlg", Dialog)
local OPER_TYPE = {
    CHANGE_NAME = 1,
    CHANGE_SEX = 2,
    CHANGE_PARTY_NAME = 3,
}

local GAI_TOU_HUAN_MAIN_CARD = CHS[2000095]

local RadioGroup = require("ctrl/RadioGroup")

function UserRenameDlg:init()
    self.itemImg = self:getControl("ItemImage", Const.UIImage, "ItemPanel")
    self.itemCost = self:getControl("ItemCostNumLabel", Const.UILabel, "ItemPanel")
    self.itemUse = self:getControl("ItemUseNumLabel", Const.UILabel)
    self:bindListener("ItemPanel", self.onRenameCardIcon, self.renamePanel)
    self:getControl("ItemPanel"):setTouchEnabled(true)

--    self:bindListener("RenameButton", self.onRenameButton)
--    self:bindListener("ChangeSexButton", self.onChangeSexButton)
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("ExpendButton", self.onExpendButton)
    self:bindListener("PartyExpendButton", self.onExpendPartyButton)

    self:bindFloatPanelListener("SelectNamePanel", "ExpendButton")

    self.historyNamePanel = self:toCloneCtrl("HistoryNamePanel")
    self:bindTouchEndEventListener(self.historyNamePanel, self.onSelectHistoryName)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"RenameCheckBox", "ChangeSexCheckBox", "PartyRenameCheckBox"}, self.onCheckbox)
    self.radioGroup:selectRadio(1)
    self:onRenameButton()

    local partyName = Me:queryBasic("party/name")
    local myName = Me:getShowName()
    self.newNameEdit = self:createEditBox("NameInputPanel", nil, nil, function(sender, type)
        if type == "end" then

        elseif type == "changed" then
            if not self.newNameEdit then return end
            local newName = self.newNameEdit:getText()
            if gf:getTextLength(newName) > 12 then
                newName = gf:subString(newName, 12)
                self.newNameEdit:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end

            -- 若输入内容为空或与原名一样，则将按钮置灰；若不为空，使按钮可用。
            if newName == ""
               or (self.operType == OPER_TYPE.CHANGE_NAME and myName == newName)
               or (self.operType == OPER_TYPE.CHANGE_PARTY_NAME and partyName == newName) then
                self:setCtrlEnabled("ConfirmButton", false)
            else
                self:setCtrlEnabled("ConfirmButton", true)
            end
        end
    end)
    self.newNameEdit:setPlaceholderFont(CHS[3003794], 23)
    self.newNameEdit:setFont(CHS[3003794], 23)
    self.newNameEdit:setPlaceHolder(CHS[3003795])
    self.newNameEdit:setPlaceholderFontColor(cc.c3b(102, 102, 102))

    self:onRenameButton()

    self:hookMsg("MSG_INVENTORY")

    self:setHistoryNamePanel()

    self:hookMsg('MSG_FORMER_NAME')
    self:hookMsg('MSG_PARTY_FORMER_NAME')

    if not Me:isBindName() then
        -- 请求实名认证信息
        gf:CmdToServer('CMD_REQUEST_FUZZY_IDENTITY', {force_request = 0})
        self.isNotFuzzyIdentity = false
    else
        self.isNotFuzzyIdentity = true
    end

    self:hookMsg("MSG_FUZZY_IDENTITY")
end

-- 改头换面卡的点击事件
function UserRenameDlg:onRenameCardIcon()
    InventoryMgr:showBasicMessageDlg(GAI_TOU_HUAN_MAIN_CARD)
end

function UserRenameDlg:cleanup()
    self.newNameEdit = nil
    self.isQuestHistoryName = false
    self:releaseCloneCtrl("historyNamePanel")
    self.historyNames = nil
    self.isQuestPartyNames = nil
end

function UserRenameDlg:setCost()
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

    self:getControl("CostPanel"):requestDoLayout()
end

function UserRenameDlg:onCheckbox(sender, eventType)
    local name = sender:getName()
    self:setCtrlVisible("SelectNamePanel", false)
    if "RenameCheckBox" == name then
        self:onRenameButton()
    elseif "ChangeSexCheckBox" == name then
        self:onChangeSexButton()
    elseif "PartyRenameCheckBox" == name then
        self:onPartyRenameButton()
    end
end

-- 改名字
function UserRenameDlg:onRenameButton()
    self:getControl("BackgroundPanel"):setVisible(true)
    self:getControl("ChangeSexPanel"):setVisible(false)
    self:getControl("PromptLabel"):setVisible(true)
    self:getControl("PromptLabel3"):setVisible(false)

    self:setCtrlVisible("ExpendButton", true)
    self:setCtrlVisible("PartyExpendButton", false)
    self:setCtrlEnabled("ConfirmButton", false)

    if Me:queryBasicInt("free_rename") == 1 then
        self:getControl("FreeLabel"):setVisible(true)
        self:getControl("CostPanel"):setVisible(false)
    else
        self:getControl("FreeLabel"):setVisible(false)
        self:getControl("CostPanel"):setVisible(true)
        self:setCost()
    end

    if self.newNameEdit then
        self.newNameEdit:setPlaceHolder(CHS[3003795])

        -- 初始默认显示角色名
        self.newNameEdit:setText(Me:getShowName())
    end

    self.operType = OPER_TYPE.CHANGE_NAME
end

-- 改帮派名字
function UserRenameDlg:onPartyRenameButton()
    self:getControl("BackgroundPanel"):setVisible(true)
    self:getControl("ChangeSexPanel"):setVisible(false)
    self:getControl("PromptLabel"):setVisible(false)
    self:getControl("PromptLabel3"):setVisible(true)

    self:getControl("FreeLabel"):setVisible(false)
    self:getControl("CostPanel"):setVisible(true)
    self:setCost()

    self:setCtrlVisible("ExpendButton", false)
    self:setCtrlVisible("PartyExpendButton", true)
    self:setCtrlEnabled("ConfirmButton", false)

    if self.newNameEdit then
        self.newNameEdit:setPlaceHolder(CHS[7000029])

        -- 初始默认显示帮派名
        self.newNameEdit:setText(Me:queryBasic("party/name"))
    end

    self.operType = OPER_TYPE.CHANGE_PARTY_NAME
end

function UserRenameDlg:onChangeSexButton()
    self:getControl("BackgroundPanel"):setVisible(false)
    self:getControl("ChangeSexPanel"):setVisible(true)
    self:getControl("CostPanel"):setVisible(true)

    self:setCtrlVisible("ExpendButton", false)
    self:setCtrlVisible("PartyExpendButton", false)
    self:setCtrlEnabled("ConfirmButton", true)

    local iconPath

    -- 设置当前头像
    self:setImage("HeadImage", ResMgr:getSmallPortrait(Me:queryBasicInt("org_icon")), "HeadPanel1")
    self:setItemImageSize("HeadImage", "HeadPanel1")
    -- 设置对应性别头像
    local gender = GENDER_TYPE.MALE == Me:queryBasicInt("gender") and GENDER_TYPE.FEMALE or GENDER_TYPE.MALE
    self:setImage("HeadImage", ResMgr:getUserSmallPortrait(Me:queryBasicInt("polar"), gender), "HeadPanel2")

    self:setCost()
    self.operType = OPER_TYPE.CHANGE_SEX
end

-- 进行改名操作
function UserRenameDlg:doChangeName()
    local name = self.newNameEdit:getText()

    if gf:getTextLength(name) > 12 or gf:getTextLength(name) == 0 then
        return
    end

    if not gf:checkRename(name) then
        gf:ShowSmallTips(CHS[3003798])
        return
    end

    if not gf:checkIsGBK(name) then
        gf:ShowSmallTips(CHS[7150018])
        return
    end

    local name, fitStr = gf:filtText(name)
    if fitStr then
        return
    end

    if Me:queryBasicInt("free_rename") <= 0 then
        local items = InventoryMgr:filterBagItems({name = GAI_TOU_HUAN_MAIN_CARD})
        if not items or #items <= 0 then
            gf:askUserWhetherBuyItem(GAI_TOU_HUAN_MAIN_CARD)
            return
        end
    end

    local name, fitStr = gf:filtText(name)
    if fitStr then
        return
    end

    gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.CHAR_RENAME, para1 = name, para2=''})

    -- 记录重命名名字，防止mdb角色信息还没更新登录不进去问题
    Client:setRenameStr(name)
end

-- 进行改帮派名操作
function UserRenameDlg:doChangePartyName()

    -- 判断ME是否是帮主
    if not PartyMgr:isPartyLeader() then
        gf:ShowSmallTips(CHS[7000030])
        return
    end

    -- 处于禁闭状态
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
    if self:checkSafeLockRelease("doChangePartyName") then
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

function UserRenameDlg:_doChangeSex()
    -- 安全锁判断
    if self:checkSafeLockRelease("_doChangeSex") then
        return
    end

    gf:confirm(CHS[4300055], function ()
        local items = InventoryMgr:filterBagItems({name = GAI_TOU_HUAN_MAIN_CARD})
        if not items or #items <= 0 then
            gf:askUserWhetherBuyItem(GAI_TOU_HUAN_MAIN_CARD)
            return
        end


        gf:CmdToServer('CMD_GENERAL_NOTIFY', {type = NOTIFY.NOTIFY_CHAR_CHANGE_SEX})
        self:close()
    end)
end

-- 进行改性别操作
function UserRenameDlg:doChangeSex()
    local equips = InventoryMgr:getEquipAttrByArray({EQUIP.HELMET, EQUIP.ARMOR})
    if 2 ~= #equips then
        gf:confirm(CHS[2000096], function()
            self:_doChangeSex()
        end, function() end)
    else
        self:_doChangeSex()
    end
end

function UserRenameDlg:onConfirmButton(sender, eventType)
    if not self.operType then return end

    if self.operType ~= OPER_TYPE.CHANGE_PARTY_NAME then  -- 战斗或观战中可以修改帮派名称，不能修改角色名和性别
        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3003796])
            return
        elseif Me:isLookOn() then
            gf:ShowSmallTips(CHS[3003797])
            return
        end
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if not DistMgr:checkCrossDist() then return end

    self.isQuestHistoryName = false
    if OPER_TYPE.CHANGE_NAME == self.operType then
        self:doChangeName()
    elseif OPER_TYPE.CHANGE_SEX == self.operType then
        self:doChangeSex()
    elseif OPER_TYPE.CHANGE_PARTY_NAME == self.operType then
        self:doChangePartyName()
    end
end

function UserRenameDlg:onCancelButton(sender, eventType)
    self:close()
end

function UserRenameDlg:onExpendPartyButton(sender, eventType)

    if not PartyMgr:isPartyLeader() then
        -- 我不是帮主
        gf:ShowSmallTips(CHS[4200398])
        return
    end

    self.isQuestPartyNames = true
    gf:CmdToServer("CMD_PARTY_FORMER_NAME", {})
end

function UserRenameDlg:onExpendButton(sender, eventType)

    if LeitingSdkMgr:isLeiting() then
        -- 官方需要验证实名
    if not self.isNotFuzzyIdentity then
        -- 请求验证的消息还没有回来
        gf:ShowSmallTips(CHS[4200371])
        return
    end

    if not Me:isBindName() then
        gf:ShowSmallTips(CHS[4100632])
        return
    end
    end

    if not self.historyNames then
        gf:CmdToServer("CMD_FORMER_NAME", {})
        self.isQuestHistoryName = true
        return
    else
        if self.historyNames.is_ok == 1 and self.historyNames.count == 0 then
            gf:ShowSmallTips(CHS[4100633])
            return
        elseif self.historyNames.is_ok == 0 then
            gf:CmdToServer("CMD_FORMER_NAME", {})
            self.isQuestHistoryName = true
            return
        end
    end

    --
    local displayPael = self:getControl("SelectNamePanel")
    displayPael:setVisible(not displayPael:isVisible())

    self:setHistoryNamePanel(self.historyNames)
end

function UserRenameDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlgEx("UserRenameRuleDlg", self.operType)
end

function UserRenameDlg:MSG_INVENTORY(data)
    self:setCost()
end

function UserRenameDlg:MSG_PARTY_FORMER_NAME(data)
    if self.isQuestPartyNames and self.radioGroup:getSelectedRadioIndex() == 3 then
        if data.count == 0 then
            gf:ShowSmallTips(CHS[4200386])
        else
            local displayPael = self:getControl("SelectNamePanel")
            displayPael:setVisible(true)
            self:setHistoryNamePanel(data)
        end
    end

    self.isQuestPartyNames = false
end

function UserRenameDlg:MSG_FORMER_NAME(data)
    if data.is_ok == 1 and self.isQuestHistoryName then
        self.historyNames = data
        self:onExpendButton()
        self.isQuestHistoryName = false
    end
end

function UserRenameDlg:addEffSelectName()

end

function UserRenameDlg:onSelectHistoryName(sender, eventType)
    -- 初始默认显示帮派名
    self.newNameEdit:setText(self:getLabelText("NameLabel", sender))

    self:setCtrlEnabled("ConfirmButton", true)
    self:setCtrlVisible("SelectNamePanel", false)
end

function UserRenameDlg:setHistoryNamePanel(data)
    local listCtl = self:resetListView("ListView", 10)

    if not data then return end
    for i = 1, data.count do
        local panel = self.historyNamePanel:clone()
        self:setLabelText("NameLabel", data[i], panel)
        listCtl:pushBackCustomItem(panel)
    end
end

function UserRenameDlg:MSG_FUZZY_IDENTITY(data)
    self.isNotFuzzyIdentity = true
end

return UserRenameDlg
