-- SubmitChildDlg.lua
-- Created by songcw June/29/2015
-- 宠物提交界面

local SubmitChildDlg = Singleton("SubmitChildDlg", Dialog)

function SubmitChildDlg:getCfgFileName()
    return ResMgr:getDlgCfg("SubmitPetDlg")
end

function SubmitChildDlg:init(data)
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("CancelButton", self.onCancelButton)
  --  self:bindListViewListener("PetListView", self.onSelectPetListView)

    self:initCtrl()

    -- 克隆单个Panel
    self.petPanel = self:retainCtrl("SinglePetPanel")
    self:bindTouchEndEventListener(self.petPanel, self.onSelectChildPanel)

    -- 克隆选中效果
    self.selectEff = self:retainCtrl("ChosenEffectImage", self.petPanel)

    self:setChildList(data)

    self:hookMsg("MSG_ENTER_GAME")
end

-- 由于读取的时提交宠物的json，需要修改一些label上文字
function SubmitChildDlg:initCtrl()
    -- 标题
    self:setLabelText("Label_1", CHS[4101452], "TitlePanel")
    self:setLabelText("Label_2", CHS[4101452], "TitlePanel")

    -- 培养阶段
    self:setLabelText("LevelLabel", CHS[4101453], "LevelPanel")

    -- 成长金库
    self:setLabelText("IntimacyLabel", CHS[4101454], "IntimacyPanel")

    -- 成长度
    self:setLabelText("MartialLabel", CHS[4101455], "MartialPanel")

    -- 血量
    self:setLabelText("TypeLabel", CHS[4101478], "LifeEffectPanel")

    -- 法力
    self:setLabelText("TypeLabel", CHS[4101479], "ManaEffectPanel")

    -- 速度
    self:setLabelText("TypeLabel", CHS[4101480], "SpeedEffectPanel")

    -- 物攻
    self:setLabelText("TypeLabel", CHS[4101481], "PhypowerEffectPanel")

    -- 法攻
    self:setLabelText("TypeLabel", CHS[4101482], "MagpwerEffectPanel")
end

function SubmitChildDlg:setChildList(data)
    local listView = self:resetListView("PetListView", 5, ccui.ListViewGravity.centerHorizontal)
    for i = 1, data.count do
        local child = data.childInfo[i]

        local singelPanel = self.petPanel:clone()
        singelPanel:setTag(i)
        self:setChildPanel(child, singelPanel)
        listView:pushBackCustomItem(singelPanel)

        if i == 1 then
            self:onSelectChildPanel(singelPanel)
        end
    end
end

function SubmitChildDlg:setChildPanel(child, panel)
    panel.data = child
    -- 头像
   -- local portrait = pet:queryBasicInt("portrait")
    self:setImage("GuardImage", ResMgr:getSmallPortrait(child.icon), panel)
    self:setItemImageSize("GuardImage", panel)

    -- 亲密
    self:setLabelText("LevelLabel", string.format( CHS[7000187], child.intimacy), panel)

    -- 名字
    self:setLabelText("NameLabel", child.name, panel)

    -- 跟随   功能尚未制作
    self:setCtrlVisible("StatusImage_0", child.isFollow == 1, panel)
    self:setCtrlVisible("StatusImage", false, panel) -- 参战
end


function SubmitChildDlg:addSelectEffect(sender)
    self.selectEff:removeFromParent()
    sender:addChild(self.selectEff)
end

function SubmitChildDlg:onSelectChildPanel(sender, eventType)
    -- 选中效果
    self:addSelectEffect(sender)

    local data = sender.data
    self:setChildAttrib(data)
end

function SubmitChildDlg:setChildAttrib(data)
    local panel = self:getControl("PetInfoPanel")

    self.selectData = data

    -- 头像
    self:setImage("PetIconImage", ResMgr:getSmallPortrait(data.icon), panel)
    self:setItemImageSize("PetIconImage", panel)

    -- 亲密
    local qinmiPanel = self:getControl("PetItemPanel", nil, panel)
    self:setLabelText("LevelLabel", string.format( CHS[7000187], data.intimacy), qinmiPanel)

    -- 名字
    self:setLabelText("NameLabel", data.name, panel)

    -- 培养阶段
    local pyPanel = self:getControl("LevelPanel", nil, panel)
    self:setLabelText("LevelValueLabel", HomeChildMgr:getStageChild(data), pyPanel)

    -- 血量
    self:setLabelText("LifeValueLabel", data.life, panel)
    -- 法力
    self:setLabelText("ManaValueLabel", data.mana, panel)
    -- 速度
    self:setLabelText("SpeedValueLabel", data.speed, panel)
    -- 物理
    self:setLabelText("PhyValueLabel", data.phy_power, panel)
    -- 法攻
    self:setLabelText("MagValueLabel", data.mag_power, panel)
    -- 成长金库
    self:setLabelText("IntimacyValueLabel", data.money, panel)

    if data.stage == HomeChildMgr.CHILD_TYPE.KID then
        -- 成长
        self:setLabelText("MartialValueLabel", "", panel)
        self:setCtrlVisible("MartialLabel", false, "MartialPanel")
    else
        -- 成长
        self:setLabelText("MartialValueLabel", data.mature, panel)
        self:setCtrlVisible("MartialLabel", true, "MartialPanel")
    end

end

function SubmitChildDlg:onSubmitButton(sender, eventType)
    gf:CmdToServer("CMD_CHILD_SELECT", {child_id = self.selectData.id})
end

function SubmitChildDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function SubmitChildDlg:MSG_ENTER_GAME(data)
    self:onCloseButton()
end

return SubmitChildDlg
