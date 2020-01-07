-- NPCRecruitDlg.lua
-- Created by sujl, Apr/7/2017
-- 义士招募/辞退界面

local NPCRecruitDlg = Singleton("NPCRecruitDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")
local NPC_DESC = require(ResMgr:getCfgPath("RecruitNpc"))

-- 一级菜单状态
local ONE_MENU_STATE = {
    NO_SECOND_MENU = 1,     -- 无二级菜单
    SECOND_HIDE = 2,        -- 隐藏二级状态
    SECOND_SHOW = 3,        -- 显示二级菜单
}

local RANK_TITLE = {
    [1] = CHS[2100060],
    [2] = CHS[2100061],
    [3] = CHS[2100062],
    [4] = CHS[2100063],
}

function NPCRecruitDlg:init()
    self:bindListener("SupplyButton", self.onSupplyButton, "RecruitPanel")
    self:bindListener("ContinueSupplyButton", self.onSupplyButton, "RecruitPanel")
    self:bindListener("DismissButton", self.onDismissButton, "RecruitPanel")
    self:bindListener("TipsImage", self.onTipsImage)

    self.bigPanel = self:getControl("BigPanel_1", Const.UIPanel, "CategoryListView")
    self.bigPanel:retain()
    self.bigPanel:removeFromParent()

    self.smallPanel = self:getControl("SmallPanel", Const.UIPanel, "CategoryListView")
    self.smallPanel:retain()
    self.smallPanel:removeFromParent()

    self.randomPanel = self:getControl("BigPanel",  Const.UIPanel, "CategoryListView")
    self.randomPanel:retain()
    self.randomPanel:removeFromParent()

    -- 一级菜单选中光效
    self.bigSelectImage = self:getControl("BChosenEffectImage", Const.UIPanel, self.bigPanel)
    self.bigSelectImage:retain()
    self.bigSelectImage:setVisible(true)
    self.bigSelectImage:removeFromParent()

    -- 二级菜单选中光效
    self.smallSelectImage = self:getControl("SChosenEffectImage", Const.UIPanel, self.smallPanel)
    self.smallSelectImage:retain()
    self.smallSelectImage:setVisible(true)
    self.smallSelectImage:removeFromParent()

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"CheckBox_1", "CheckBox_2"}, self.onCheckBox)
    self.radioGroup:selectRadio(1)

    local hasRecruitNpcs = YiShiMgr:getHasRecruitNpcs()
    self:setCtrlEnabled("CheckBox_2", hasRecruitNpcs and #hasRecruitNpcs > 0)

    self:hookMsg("MSG_YISHI_RECRUIT_RESULT")
    self:hookMsg("MSG_YISHI_DISMISS_RESULT")
end

function NPCRecruitDlg:cleanup()
    self:releaseCloneCtrl("bigPanel")
    self:releaseCloneCtrl("smallPanel")
    self:releaseCloneCtrl("randomPanel")
    self:releaseCloneCtrl("bigSelectImage")
    self:releaseCloneCtrl("smallSelectImage")

    self.curSelectNpc = nil
    self.curDiplayName = nil
    self.dlgType = nil
end

function NPCRecruitDlg:setDlgType(dlgType)
    if 0 == dlgType then
        self.radioGroup:selectRadio(1)
    elseif 1 == dlgType then
        self.radioGroup:selectRadio(2)
    end
end

function NPCRecruitDlg:setType(dlgType)
    if self.dlgType == dlgType then return end
    self.dlgType = dlgType
    self.curSelectNpc = nil
    local isRecruit = "recruit" == dlgType

    -- 标题
    self:setCtrlVisible("TitleLabel_1", isRecruit, "TitlePanel")
    self:setCtrlVisible("TitleLabel_2", isRecruit, "TitlePanel")
    self:setCtrlVisible("TitleLabel_3", not isRecruit, "TitlePanel")
    self:setCtrlVisible("TitleLabel_4", not isRecruit, "TitlePanel")

    -- 按钮
    self:setCtrlVisible("SupplyButton", isRecruit, "RecruitPanel")
    self:setCtrlVisible("ContinueSupplyButton", false, "RecruitPanel")
    self:setCtrlVisible("DismissButton", not isRecruit, "RecruitPanel")
    self:setCtrlVisible("TipsImage", isRecruit)

    -- 面板内容
    self:setCtrlVisible("CostPanel", isRecruit, "RecruitPanel")
    self:setCtrlVisible("AtkPanel", not isRecruit, "RecruitPanel")
    self:setCtrlVisible("SpeedPanel", not isRecruit, "RecruitPanel")
    self:setCtrlVisible("TaoPanel", not isRecruit, "RecruitPanel")
    self:setCtrlVisible("DefencePanel", not isRecruit, "RecruitPanel")
    self:setCtrlVisible("TipsLabel_1", false,  "RecruitPanel")

    if isRecruit then
        self:setMainTypeList({CHS[2000227], CHS[2000228], CHS[2000229], CHS[2000230], CHS[2000231], CHS[2000232]})
    else
        self:setRecruitList(YiShiMgr:getHasRecruitNpcs())
    end

end

function NPCRecruitDlg:setRecruitList(datas)
    local list = self:resetListView("CategoryListView", 5)
    local def
    for i = 1, #datas do
        local itemPanel
        itemPanel = self.smallPanel:clone()
        itemPanel:setName(datas[i].npc_name)
        itemPanel:setTag(100 * i)
        itemPanel.clickFunc = function()
            self:setDismissNpcInfo(datas[i])
            if itemPanel then
                self.curSelectNpc = itemPanel.npc
            end
        end
        itemPanel.npc = datas[i]
        self:setLabelText("Label", datas[i].npc_name, itemPanel)
        self:bindTouchEndEventListener(itemPanel, self.onClickSmallMenu)
        list:pushBackCustomItem(itemPanel)
        if not def then
            def = itemPanel
        elseif self.curSelectNpc and datas[i].npc_name == self.curSelectNpc.npc_name then
            def = itemPanel
        end
    end

    self:onClickSmallMenu(def)
    self:setCtrlEnabled("DismissButton", datas and #datas > 0, "RecruitPanel")

    list:doLayout()
    list:refreshView()
end

function NPCRecruitDlg:setMainTypeList(datas)
    local list = self:resetListView("CategoryListView", 5)
    for i = 1, #datas do
        local itemPanel
        if 1 == i then
            itemPanel = self.randomPanel:clone()
            self:setArrow(ONE_MENU_STATE.NO_SECOND_MENU, itemPanel)
        else
            itemPanel = self.bigPanel:clone()
            self:setArrow(ONE_MENU_STATE.SECOND_HIDE, itemPanel)
        end

        local name, atkType = string.match(datas[i], "([^:]+):?(%d*)")
        itemPanel:setName(name)
        itemPanel:setTag(100 * i)
        itemPanel.atkType = tonumber(atkType)
        self:setLabelText("Label", name, itemPanel)
        self:bindTouchEndEventListener(itemPanel, self.onClickBigMenu)
        list:pushBackCustomItem(itemPanel)

        if 1 == i then self:onClickBigMenu(itemPanel) end
    end

    list:doLayout()
    list:refreshView()
end

function NPCRecruitDlg:setSecondTypeList(sender)
    local list = self:getControl("CategoryListView")
    if not list then return end

    local bigMenu = sender
    if bigMenu.secondType == ONE_MENU_STATE.NO_SECOND_MENU  then
        -- 没有二级菜单
        local npc
        if CHS[2000227] == sender:getName() then
            -- 随机招募
            npc = {
                npc_name = CHS[2000227],
                npc_rank = CHS[2000233],
                icon = ResMgr.ui.quest_mark_plist,
                merit = 10,
            }
            self:setRecruitNpcInfo(npc, YiShiMgr:getMerit())
            self:setCtrlVisible("ContinueSupplyButton", false)
        end

        -- 设置箭头状态
        self:setArrow(ONE_MENU_STATE.NO_SECOND_MENU, bigMenu)
        self.curSelectNpc = npc

    elseif bigMenu.secondType == ONE_MENU_STATE.SECOND_HIDE then
        -- 当前为隐藏二级状态状态

        -- 设置箭头状态
        self:setArrow(ONE_MENU_STATE.SECOND_SHOW, bigMenu)

        -- 增加二级菜单
        local tag = sender:getTag()
        local index = math.floor(tag / 100)
        local showNpcs = YiShiMgr:getCanRecruitNpcs(sender.atkType)
        local def
        for i = 1, #showNpcs do
            local itemPanel = self.smallPanel:clone()
            itemPanel:setName(showNpcs[i].npc_name)
            itemPanel:setTag(tag + i)
            itemPanel.clickFunc = function()
                self:setRecruitNpcInfo(showNpcs[i], YiShiMgr:getMerit())
                if itemPanel then
                    self.curSelectNpc = itemPanel.npc
                end
            end
            itemPanel.npc = showNpcs[i]
            self:setLabelText("Label", showNpcs[i].npc_name, itemPanel)
            list:insertCustomItem(itemPanel, index + i - 1)
            self:bindTouchEndEventListener(itemPanel, self.onClickSmallMenu)
            if not def then
                def = itemPanel
            elseif self.curSelectNpc and showNpcs[i].npc_name == self.curSelectNpc.npc_name then
                def = itemPanel
            end
        end
        self:onClickSmallMenu(def)
        bigMenu.secondMenus = #showNpcs
    elseif bigMenu.secondType == ONE_MENU_STATE.SECOND_SHOW then

        -- 当前为显示二级状态状态

        -- 设置箭头状态
        self:setArrow(ONE_MENU_STATE.SECOND_HIDE, bigMenu)

        -- 删除二级菜单
        local count = bigMenu.secondMenus or 0
        for i = count, 1, -1 do
            list:removeItem(math.floor(bigMenu:getTag() / 100) + i - 1)
        end
    end
end

function NPCRecruitDlg:removeAllSmallPanel(sender)
    local list = self:getControl("CategoryListView")
    if not list then return end
    local items = list:getItems()
    for _, panel in pairs(items) do
        local tag = panel:getTag()
        if tag % 100 ~= 0 and math.floor(tag / 100) * 100 ~= sender:getTag() then
            -- 二级菜单，删除
            list:removeChild(panel)
        else
            -- 一级菜单，有子菜单，设置箭头
            if panel.secondType ~= ONE_MENU_STATE.NO_SECOND_MENU and math.floor(tag / 100) * 100 ~= sender:getTag() then
                self:setArrow(ONE_MENU_STATE.SECOND_HIDE, panel)
            end
        end
    end

    list:requestRefreshView()
end

-- 菜单的箭头设置
function NPCRecruitDlg:setArrow(type, panel)
    self:setCtrlVisible("DownArrowImage", false, panel)
    self:setCtrlVisible("UpArrowImage", false, panel)

    panel.secondType = type

    if type == 1 then
        -- 无二级菜单，不显示
    elseif type == 2 then
        -- 显示向下，（点击展开）
        self:setCtrlVisible("DownArrowImage", true, panel)
    elseif type == 3 then
        -- 显示向上，（点击收缩）
        self:setCtrlVisible("UpArrowImage", true, panel)
    end
end

-- 一级菜单选中光效
function NPCRecruitDlg:addBigMenuSelectEff(sender)
    self.bigSelectImage:removeFromParent()
    sender:addChild(self.bigSelectImage)
end

-- 二级菜单选中光效
function NPCRecruitDlg:addSmallMenuSelectEff(sender)
    if not sender then return end
    self.smallSelectImage:removeFromParent()
    sender:addChild(self.smallSelectImage)
end

-- 设置招募佣兵数据
function NPCRecruitDlg:setRecruitNpcInfo(data, merit)
    if data.npc_icon then
        self:setImage("NPCImage", ResMgr:getSmallPortrait(data.npc_icon))
    elseif data.icon then
        self:setImagePlist("NPCImage", data.icon)
    end
    self:setLabelText("NameLabel", data.npc_name)
    if data.npc_rank then
        self:setLabelText("LevelLabel", type(data.npc_rank) == 'string' and data.npc_rank or RANK_TITLE[data.npc_rank])
    else
        self:setLabelText("LevelLabel", "", data.npc_rank)
    end
    self:setLabelText("IntroduceLabel", NPC_DESC[data.npc_name] or "")

    local costPanel = self:getControl("CostPanel1", nil, "CostPanel")
    if data.merit then
        self:setNumImgForPanel(costPanel, data.merit <= merit and ART_FONT_COLOR.DEFAULT or ART_FONT_COLOR.RED, data.merit, false, LOCATE_POSITION.LEFT_TOP, 19)
        costPanel.value = data.merit
    else
        local value = costPanel.value or 0
        self:setNumImgForPanel(costPanel, value <= merit and ART_FONT_COLOR.DEFAULT or ART_FONT_COLOR.RED, value, false, LOCATE_POSITION.LEFT_TOP, 19)
    end
    self:setNumImgForPanel("OwnPanel", ART_FONT_COLOR.DEFAULT, merit, false, LOCATE_POSITION.LEFT_TOP, 19, "CostPanel")
end

-- 设置解雇佣兵数据
function NPCRecruitDlg:setDismissNpcInfo(data)
    self:setImage("NPCImage", ResMgr:getSmallPortrait(data.npc_icon))
    self:setLabelText("NameLabel", data.npc_name)
    self:setLabelText("LevelLabel", RANK_TITLE[data.npc_rank])
    self:setLabelText("IntroduceLabel", NPC_DESC[data.npc_name] or "")
    self:setLabelText("NumberTextLabel_1", data.atk_count, "AtkPanel")
    self:setLabelText("NumberTextLabel_1", data.tao_count, "TaoPanel")
    self:setLabelText("NumberTextLabel_1", data.spd_count, "SpeedPanel")
    self:setLabelText("NumberTextLabel_1", data.def_count, "DefencePanel")
end

function NPCRecruitDlg:onClickBigMenu(sender)
    --[[
    if self.curDiplayName == sender:getName() then
        return
    end
    ]]

    self.curSelectNpc = nil
    self.curDiplayName = sender:getName()

    self:removeAllSmallPanel(sender)
    self:setSecondTypeList(sender)
    self:addBigMenuSelectEff(sender)

    local isBaXian = CHS[2000234] == sender:getName()
    self:setCtrlVisible("TipsLabel_1", isBaXian,  "RecruitPanel")
    self:setCtrlVisible("SupplyButton", not isBaXian, "RecruitPanel")
    self:setCtrlVisible("ContinueSupplyButton", false)
end

function NPCRecruitDlg:onClickSmallMenu(sender)
    self:addSmallMenuSelectEff(sender)

    if sender and sender.clickFunc and 'function' == type(sender.clickFunc) then
        sender.clickFunc()
    end
end

function NPCRecruitDlg:onCheckBox(sender, eventType)
    local name = sender:getName()
    if name == "CheckBox_1" then
        self:setType("recruit")
    elseif name == "CheckBox_2" then
        self:setType("dismiss")
        self.curDiplayName = nil
    end
end

function NPCRecruitDlg:onSupplyButton(sender, eventType)
    if not self.curSelectNpc then return end
    YiShiMgr:doRecruit(self.curSelectNpc)
    self:removeArmatureMagicFromCtrl("SupplyButton", Const.ARMATURE_MAGIC_TAG, "RecruitPanel")
end

function NPCRecruitDlg:onDismissButton(sender, eventType)
    if not self.curSelectNpc then return end
    YiShiMgr:doDismiss(self.curSelectNpc)
end

function NPCRecruitDlg:onTipsImage(sender, eventType)
    local dlg = DlgMgr:openDlg("InvadeRuleDlg")
    dlg:setDlgType("recruit")
end

function NPCRecruitDlg:MSG_YISHI_RECRUIT_RESULT(data)
    if self.dlgType ~= "recruit" then
        self:setRecruitList(YiShiMgr:getHasRecruitNpcs())
    else
        self:setRecruitNpcInfo(data.npc, YiShiMgr:getMerit())

        self:setCtrlVisible("ContinueSupplyButton", self.curDiplayName == CHS[2000227])
        self:setCtrlVisible("SupplyButton", self.curDiplayName ~= CHS[2000227])
    end

    self:setCtrlEnabled("CheckBox_2", true)
end

function NPCRecruitDlg:MSG_YISHI_DISMISS_RESULT(data)
    if self.dlgType ~= "recruit" then
        local npcs = YiShiMgr:getHasRecruitNpcs()
        if npcs and #npcs > 0 then
            self:setRecruitList(npcs)
            self:setCtrlEnabled("CheckBox_2", true)
        else
            self:setDlgType(0)
            self:setCtrlEnabled("CheckBox_2", false)
        end
    end
end

return NPCRecruitDlg