-- NPCSupplyDlg.lua
-- Created by sujl, Apr/7/2017
-- 属性强化界面

local NPCSupplyDlg = Singleton("NPCSupplyDlg", Dialog)
local NPC_DESC = require(ResMgr:getCfgPath("RecruitNpc"))

local NPC_COST = 50
local ME_COST = 100

function NPCSupplyDlg:init()
    self:bindPressForIntervalCallback("AddButton", 0.1, self.onAtkAddButton, "times", "AtkPanel")
    self:bindPressForIntervalCallback("ReduceButton", 0.1, self.onAtkReduceButton, "times", "AtkPanel")
    self:bindPressForIntervalCallback("AddButton", 0.1, self.onSpeedAddButton, "times", "SpeedPanel")
    self:bindPressForIntervalCallback("ReduceButton", 0.1, self.onSpeedReduceButton, "times", "SpeedPanel")
    self:bindPressForIntervalCallback("AddButton", 0.1, self.onTaoAddButton, "times", "TaoPanel")
    self:bindPressForIntervalCallback("ReduceButton", 0.1, self.onTaoReduceButton, "times", "TaoPanel")
    self:bindPressForIntervalCallback("AddButton", 0.1, self.onDefenceAddButton, "times", "DefencePanel")
    self:bindPressForIntervalCallback("ReduceButton", 0.1, self.onDefenceReduceButton, "times", "DefencePanel")
    self:bindListener("SupplyButton", self.onSupplyButton)
    self:bindListener("UpgradeButton", self.onUpgradeButton)
    self:bindListener("TipsImage", self.onTipsImage)

    self:setCtrlEnabled("FullSupplyButton", false)

    self.bigPanel = self:getControl("BigPanel_1", Const.UIPanel, "CategoryListView")
    self.bigPanel:retain()
    self.bigPanel:removeFromParent()

    -- 选中光效
    self.bigSelectImage = self:retainCtrl("BChosenEffectImage", self.bigPanel)
    self.bigSelectImage:setVisible(true)
    self.bigSelectImage:removeFromParent()

    self:setRecruitList(YiShiMgr:getImproveNpcs())

    self:hookMsg('MSG_YISHI_IMPROVE_RESULT')
    self:hookMsg('MSG_YISHI_IMPROVE_PREVIEW')
end

function NPCSupplyDlg:cleanup()
    self.curNpc = nil
    self:releaseCloneCtrl("bigPanel")
end

function NPCSupplyDlg:getImproveCount(npc)
    if not npc then return 0 end

    return npc.atk_count + npc.spd_count + npc.tao_count + npc.def_count
end

function NPCSupplyDlg:getCost()
    if not self.curNpc then return 0 end
    local addPoint = self:getAddPoint('AtkPanel') + self:getAddPoint('SpeedPanel') + self:getAddPoint('TaoPanel') + self:getAddPoint('DefencePanel')
    if self.curNpc.npc_id and  0 ~= self.curNpc.npc_id then
        return addPoint * NPC_COST
    else
        return addPoint * ME_COST
    end
end

function NPCSupplyDlg:setRecruitList(datas)
    local list = self:resetListView("CategoryListView", 5)
    local itemPanel
    for i = 1, #datas do
        itemPanel = self.bigPanel:clone()
        itemPanel:setName(datas[i].npc_name)
        itemPanel.npc = datas[i]
        self:setLabelText("Label", string.format("%s:(%d)", datas[i].npc_name, self:getImproveCount(datas[i])), itemPanel)
        self:bindTouchEndEventListener(itemPanel, self.onClickItem)
        list:pushBackCustomItem(itemPanel)

        if self.curNpc and self.curNpc.npc_id == datas[i].npc_id then
            self:onClickItem(itemPanel)
        end
    end

    -- 自身属性
    local myData = YiShiMgr:getMyImproveData()
    if myData then
        itemPanel = self.bigPanel:clone()
        itemPanel:setName(CHS[2000235])
        itemPanel.npc = myData
        self:setLabelText("Label", string.format("%s:(%d)", CHS[2000235], self:getImproveCount(myData)), itemPanel)
        self:bindTouchEndEventListener(itemPanel, self.onClickItem)
        list:pushBackCustomItem(itemPanel)

        if not self.curNpc or not self.curNpc.npc_id or 0 == self.curNpc.npc_id then
            self:onClickItem(itemPanel)
        end
    end

    list:doLayout()
    list:refreshView()
end

function NPCSupplyDlg:setNumberValue(name, value, attribName)
    local panel = self:getControl(name, Const.UIPanel, "SupplyPanel")
    local panel1 = self:getControl("NumberValueImage", Const.UIPanel, panel)
    local curValue = self.curNpc[attribName]
    local color = value > curValue and COLOR3.GREEN or COLOR3.WHITE
    self:setLabelText("NumberLabel", value, panel1, color)
    self:setLabelText("NumberLabel_1", value, panel1)
    if attribName then
        self:checkButtonState(name, attribName)
    end
end

function NPCSupplyDlg:getNumberValue(name)
    local panel = self:getControl(name, Const.UIPanel, "SupplyPanel")
    local panel1 = self:getControl("NumberValueImage", Const.UIPanel, panel)
    return self:getLabelText("NumberLabel", panel1)
end

function NPCSupplyDlg:setAddPoint(panel, value)
    if value > 0 then
        self:setLabelText("AddLabel", string.format("+%d", value), self:getControl(panel, Const.UIPanel, "SupplyPanel"))
    else
        self:setLabelText("AddLabel", string.format("%d", value), self:getControl(panel, Const.UIPanel, "SupplyPanel"))
    end
end

function NPCSupplyDlg:getAddPoint(panel)
    return tonumber(self:getLabelText("AddLabel", self:getControl(panel, Const.UIPanel, "SupplyPanel"))) or 0
end

function NPCSupplyDlg:setNpcInfo(npc, cost, left, isSetValue)
    self.curNpc = npc
    if isSetValue then
        self.left_count = self.curNpc.left_count
    end

    -- 头像
    self:setImage("NPCImage", ResMgr:getSmallPortrait(npc.npc_icon or Me:queryBasicInt("org_icon")), "SupplyPanel")

    -- 名字
    self:setLabelText("NameLabel", npc.npc_name or Me:getName(), "SupplyPanel")

    -- 阶位
    self:setCtrlVisible("LevelLabel", nil ~= npc.type, "SupplyPanel")
    self:setLabelText("LevelLabel", YiShiMgr:getNpcTypeName(npc.type), "SupplyPanel")

    -- 伤害
    if isSetValue then
        self:setAddPoint("AtkPanel", 0)
    end
    self:setNumberValue("AtkPanel", npc.atk_count, 'atk_count')

    -- 速度
    if isSetValue then
        self:setAddPoint("SpeedPanel", 0)
    end
    self:setNumberValue("SpeedPanel", npc.spd_count, 'spd_count')

    -- 道行
    if isSetValue then
        self:setAddPoint("TaoPanel", 0)
    end
    self:setNumberValue("TaoPanel", npc.tao_count, 'tao_count')

    -- 防御
    if isSetValue then
        self:setAddPoint("DefencePanel", 0)
    end
    self:setNumberValue("DefencePanel", npc.def_count, 'def_count')

    -- 剩余强化次数
    self:setLabelText("TimeLabel_1_1", npc.left_count, "SupplyPanel")
    self.left_count = npc.left_count

    -- 消耗军功
    self:setNumImgForPanel("CostPanel1", ART_FONT_COLOR.DEFAULT, cost, false, LOCATE_POSITION.LEFT_TOP, 19, self:getControl("CostPanel", Const.UIPanel, "SupplyPanel"))

    -- 可用军功
    self:setNumImgForPanel("OwnPanel", ART_FONT_COLOR.DEFAULT, left, false, LOCATE_POSITION.LEFT_TOP, 19, self:getControl("CostPanel", Const.UIPanel, "SupplyPanel"))

    -- 当前拥有腰牌数量
    local itemAmount = InventoryMgr:getAmountByName(CHS[2100074]) or 0

    -- 消耗腰牌
    self:setNumImgForPanel("CostPanel1", (npc.amount or 0) > itemAmount and ART_FONT_COLOR.RED or ART_FONT_COLOR.DEFAULT, npc.amount, false, LOCATE_POSITION.LEFT_TOP, 19, self:getControl("CostPanel_1", Const.UIPanel, "SupplyPanel"))

    -- 可用腰牌
    self:setNumImgForPanel("OwnPanel", ART_FONT_COLOR.DEFAULT, itemAmount, false, LOCATE_POSITION.LEFT_TOP, 19, self:getControl("CostPanel_1", Const.UIPanel, "SupplyPanel"))

    -- 简介
    local npc_name = npc.npc_name
    self:setLabelText("IntroduceLabel_0", NPC_DESC[npc_name] or CHS[2200025], self:getControl("IntroducePanle", Const.UIPanel, "SupplyPanel"))

    self:setCtrlVisible("SupplyButton", npc.left_count > 0)
    self:setCtrlVisible("CostPanel", npc.left_count > 0)
    self:setCtrlVisible("UpgradeButton", npc.left_count <= 0 and (npc.amount or 0) > 0)
    self:setCtrlVisible("CostPanel_1", npc.left_count <= 0 and (npc.amount or 0) > 0)
    self:setCtrlVisible("FullSupplyButton", npc.left_count <= 0 and (npc.amount or 0) <= 0)
end

function NPCSupplyDlg:addSelectImage(sender)
    self.bigSelectImage:removeFromParent()
    sender:addChild(self.bigSelectImage)
end

function NPCSupplyDlg:addValue(name, v, initValue, attribName)
    if not self.curNpc then return end

    local value = tonumber(self:getAddPoint(name)) or 0
    local curValue = value
    value = math.max(0, math.min(value + v, value + self.left_count))
    local newValue = value
    self:setAddPoint(name, value)

    value = tonumber(self:getNumberValue(name)) or 0
    value = math.max(initValue, math.min(value + v, value + self.left_count))
    self:setNumberValue(name, value, attribName)

    if curValue ~= newValue then
        self.left_count = math.max(0, self.left_count - v)
        self:setLabelText("TimeLabel_1_1", self.left_count, "SupplyPanel")
    end

    local cost = self:getCost()
    self:setNumImgForPanel("CostPanel1", cost > YiShiMgr:getMerit() and ART_FONT_COLOR.RED or ART_FONT_COLOR.DEFAULT, cost, false, LOCATE_POSITION.LEFT_TOP, 19, self:getControl("CostPanel", Const.UIPanel, "SupplyPanel"))

    --[[
    gf:CmdToServer('CMD_YISHI_IMPROVE', {
        id = self.curNpc.id  or 0,
        type = 0,   -- 预览
        atk_count = self:getAddPoint('AtkPanel'),
        spd_count = self:getAddPoint('SpeedPanel'),
        tao_count = self:getAddPoint('TaoPanel'),
        def_count = self:getAddPoint('DefencePanel'),
    })
    ]]

    self:checkButtonState("AtkPanel", "atk_count")
    self:checkButtonState("SpeedPanel","spd_count")
    self:checkButtonState("TaoPanel", "tao_count")
    self:checkButtonState("DefencePanel", "def_count")
end

function NPCSupplyDlg:checkButtonState(name, attrName)
    local value = tonumber(self:getNumberValue(name)) or 0
    local panel = self:getControl(name, nil, "SupplyPanel")
    self:setCtrlEnabled("ReduceButton", value > (self.curNpc[attrName] or 0), panel)
    self:setCtrlEnabled("AddButton", self.left_count > 0, panel)
end

function NPCSupplyDlg:onClickItem(sender)
    self:addSelectImage(sender)

    local npc = sender.npc
    if not npc then return end
    self:setNpcInfo(npc, 0, YiShiMgr:getMerit(), true)
end

function NPCSupplyDlg:onAtkAddButton(ctrlName, times)
    self:addValue("AtkPanel", 1, self.curNpc.atk_count, 'atk_count')
end

function NPCSupplyDlg:onAtkReduceButton(ctrlName, times)
    self:addValue("AtkPanel", -1, self.curNpc.atk_count, 'atk_count')
end

function NPCSupplyDlg:onSpeedAddButton(ctrlName, times)
    self:addValue("SpeedPanel", 1, self.curNpc.spd_count, 'spd_count')
end

function NPCSupplyDlg:onSpeedReduceButton(ctrlName, times)
    self:addValue("SpeedPanel", -1, self.curNpc.spd_count, 'spd_count')
end

function NPCSupplyDlg:onTaoAddButton(ctrlName, times)
    self:addValue("TaoPanel", 1, self.curNpc.tao_count, 'tao_count')
end

function NPCSupplyDlg:onTaoReduceButton(ctrlName, times)
    self:addValue("TaoPanel", -1, self.curNpc.tao_count, 'tao_count')
end

function NPCSupplyDlg:onDefenceAddButton(ctrlName, times)
    self:addValue("DefencePanel", 1, self.curNpc.def_count, 'def_count')
end

function NPCSupplyDlg:onDefenceReduceButton(ctrlName, times)
    self:addValue("DefencePanel", -1, self.curNpc.def_count, 'def_count')
end

function NPCSupplyDlg:onSupplyButton(sender, eventType)
    if not self.curNpc then return end

    gf:CmdToServer('CMD_YISHI_IMPROVE', {
        id = self.curNpc.npc_id or 0,
        type = 1,   -- 强化
        atk_count = self:getAddPoint('AtkPanel'),
        spd_count = self:getAddPoint('SpeedPanel'),
        tao_count = self:getAddPoint('TaoPanel'),
        def_count = self:getAddPoint('DefencePanel'),
    })
end

function NPCSupplyDlg:onUpgradeButton(sender, eventType)
    if not self.curNpc then return end

    local npc_id = self.curNpc.npc_id
    local atk_count = self:getAddPoint('AtkPanel')
    local spd_count = self:getAddPoint('SpeedPanel')
    local tao_count = self:getAddPoint('TaoPanel')
    local def_count = self:getAddPoint('DefencePanel')
    gf:confirm(string.format(CHS[2000236], self.curNpc.amount, self.curNpc.npc_name), function()
        gf:CmdToServer('CMD_YISHI_IMPROVE', {
            id = npc_id or 0,
            type = 2,   -- 晋升
            atk_count = atk_count,
            spd_count = spd_count,
            tao_count = tao_count,
            def_count = def_count,
        })
    end)
end

function NPCSupplyDlg:onTipsImage(sender, eventType)
    local dlg = DlgMgr:openDlg("InvadeRuleDlg")
    dlg:setDlgType("supply")
end

function NPCSupplyDlg:MSG_YISHI_IMPROVE_RESULT(data)
    self:setRecruitList(YiShiMgr:getImproveNpcs())
end

function NPCSupplyDlg:MSG_YISHI_IMPROVE_PREVIEW(data)
    self:setNpcInfo(data.npc, data.cost_merit, data.left_merit)
end

return NPCSupplyDlg