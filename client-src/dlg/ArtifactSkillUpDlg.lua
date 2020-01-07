-- ArtifactSkillUpDlg.lua
-- Created by yangym Dec/23/2016
-- 法宝特殊技能升级界面
local ArtifactSkillUpDlg = Singleton("ArtifactSkillUpDlg", Dialog)

local ARTIFACT_SPSKILL_LEVELUP_MIN_LEVEL = 70

function ArtifactSkillUpDlg:init()
    self:bindListener("ArtifactImagePanel_2", self.onSelectSecondaryArtifact, "ArtifactPanel_1")
    self:bindListener("ArtifactImagePanel_1", self.onSelectSecondaryArtifact, "ArtifactPanel_2")
    self:bindListener("ArtifactImagePanel_2", self.onSelectSecondaryArtifact, "ArtifactPanel_2")
    self:bindListener("SkillUpButton", self.onSkillUpButton)
    self:bindListener("InfoButton", self.onRuleButton)
    self:bindListener("BindCheckBox", self.onLimitedCheckBox)

    self:setCtrlVisible("NoneArtifactImage", true, "ArtifactImagePanel")
    self:setCtrlVisible("FrameImage", false, "ArtifactImagePanel")

    self.selectArtifact = nil

    -- 当前法宝特殊技能升级需要消耗的法宝数量
    self.submitArtifactNum = 0

    -- 当前已经勾选的法宝
    self.chosenArtifacts = {}

    -- 当前法宝特殊技能升级需要消耗的宝石
    self.costItem = {}

    local artifactPanel1 = self:getControl("ArtifactPanel_1")
    local artifactPanel2 = self:getControl("ArtifactPanel_2")

    if InventoryMgr.UseLimitItemDlgs[self.name] == 1 then
        self:setCheck("BindCheckBox", true)
    elseif InventoryMgr.UseLimitItemDlgs[self.name] == 0 then
        self:setCheck("BindCheckBox", false)
    end

    -- 副法宝状态重置
    self:refreshSecondaryArtifactPanel()

    -- 宝石状态重置
    self:refreshCostItemPanel()

    -- 升级按钮状态重置
    self:refreshLevelUpButton()

    self:hookMsg("MSG_INVENTORY")
end

function ArtifactSkillUpDlg:chosenArfactsIsExist()
    if not next(self.chosenArtifacts) then return false end

    for i = 1, #self.chosenArtifacts do
        if not InventoryMgr:getItemById(self.chosenArtifacts[i].item_unique) then
            return false
        end
    end

    return true
end

-- 设置法宝基本信息
function ArtifactSkillUpDlg:setArtifactInfo(artifact)
    if not artifact or artifact.item_type ~= ITEM_TYPE.ARTIFACT then
        return
    end

    self:setCtrlVisible("NoneArtifactImage", false, "ArtifactImagePanel")
    self:setCtrlVisible("FrameImage", true, "ArtifactImagePanel")

    local lastArtifact = self.selectArtifact
    self.selectArtifact = artifact

    -- 法宝图标
    self:setImage("ArtifactImage", InventoryMgr:getIconFileByName(artifact.name), "ArtifactImagePanel")
    self:setItemImageSize("ArtifactImage", "ArtifactImagePanel")
    self:setCtrlVisible("ArtifactImage", true, "ArtifactImagePanel")

    -- 图标左上角等级
    self:setNumImgForPanel("ArtifactImagePanel", ART_FONT_COLOR.NORMAL_TEXT,
        artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21)

    -- 图标右下角相性标志
    local img = self:getControl("ArtifactImage", nil, "ArtifactImagePanel")
    InventoryMgr:removeArtifactPolarImage(img)
    if artifact.item_polar then
        InventoryMgr:addArtifactPolarImage(img, artifact.item_polar)
    end

    -- 图标左下角限制交易/限时标记
    if InventoryMgr:isTimeLimitedItem(artifact) then
        InventoryMgr:removeLogoBinding(img)
        InventoryMgr:addLogoTimeLimit(img)
    elseif InventoryMgr:isLimitedItem(artifact) then
        InventoryMgr:removeLogoTimeLimit(img)
        InventoryMgr:addLogoBinding(img)
    else
        InventoryMgr:removeLogoTimeLimit(img)
        InventoryMgr:removeLogoBinding(img)
    end

    -- 点击弹出法宝名片
    local function func(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            local selectArtifact = self.selectArtifact
            InventoryMgr:showArtifact(selectArtifact, rect, true)
        end
    end

    local artifactImage = self:getControl("ArtifactImage", nil, "ArtifactImagePanel")
    artifactImage:addTouchEventListener(func)

    -- 法宝名称
    self:setLabelText("ArtifactNameLabel", artifact.name)

    -- 升级预览部分（有特殊技能/无特殊技能）
    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)

    if artifactSpSkillName then
        local artifactSpSkillLevel = artifact.extra_skill_level
        -- 升级前
        self:setLabelText("SkillNameLabel", artifactSpSkillName, "OldArtifactSkillPanel", COLOR3.TEXT_DEFAULT)
        self:setLabelText("SkillNLabel", string.format(CHS[2000131], artifactSpSkillLevel), "OldArtifactSkillPanel")

        -- 升级后
        self:setLabelText("SkillNameLabel", artifactSpSkillName, "NewArtifactSkillPanel", COLOR3.GREEN)
        self:setLabelText("SkillNLabel", string.format(CHS[2000131], artifactSpSkillLevel + 1) .. CHS[7002014], "NewArtifactSkillPanel", COLOR3.GREEN)

        if artifactSpSkillLevel >= Const.ARTIFACT_MAX_LEVEL then
            self:setLabelText("SkillNameLabel", CHS[7002015], "NewArtifactSkillPanel", COLOR3.GREEN)
            self:setLabelText("SkillNLabel", "", "NewArtifactSkillPanel")
        end
    else
        -- 升级前
        self:setLabelText("SkillNameLabel", CHS[7000329], "OldArtifactSkillPanel", COLOR3.GRAY)
        self:setLabelText("SkillNLabel", "", "OldArtifactSkillPanel")

        -- 升级后
        self:setLabelText("SkillNameLabel", CHS[7002002], "NewArtifactSkillPanel", COLOR3.GRAY)
        self:setLabelText("SkillNLabel", "", "NewArtifactSkillPanel")
    end

    -- 副法宝状态重置
    if lastArtifact and lastArtifact == self.selectArtifact and self:chosenArfactsIsExist() then
        self:refreshSecondaryArtifactPanel(self.chosenArtifacts)
    else
        self:refreshSecondaryArtifactPanel()
    end

    -- 宝石状态重置
    self:refreshCostItemPanel()

    -- 升级按钮状态重置
    self:refreshLevelUpButton()
end

-- 更新副法宝显示
function ArtifactSkillUpDlg:refreshSecondaryArtifactPanel(chosenArtifacts)
    local artifact = self.selectArtifact
    if not artifact then
        return
    end

    local skillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if not skillName then
        -- 如果法宝没有特殊技能，则副法宝选择区域按照特殊技能为1级显示
        self:setCtrlVisible("ArtifactPanel_1", true, "CostPanel")
        self:setCtrlVisible("ArtifactPanel_2", false, "CostPanel")
        self:setArtifactImage(nil, self:getControl("ArtifactImagePanel_2", nil, "ArtifactPanel_1"))
        return
    end

    if artifact.extra_skill_level < 10 then
        -- 10级以下的法宝特技升级消耗一个副法宝
        self.submitArtifactNum = 1
        self:setCtrlVisible("ArtifactPanel_1", true, "CostPanel")
        self:setCtrlVisible("ArtifactPanel_2", false, "CostPanel")

        local rootName = "ArtifactPanel_1"
        if chosenArtifacts and #chosenArtifacts == 1 then
            -- 选择了一个法宝
            self.chosenArtifacts = chosenArtifacts
            self:setArtifactImage(chosenArtifacts[1], self:getControl("ArtifactImagePanel_2", nil, rootName))
        else
            -- 没有选择法宝
            self.chosenArtifacts = {}
            self:setArtifactImage(nil, self:getControl("ArtifactImagePanel_2", nil, rootName))
        end
    else
        -- 10级及以上的法宝特技升级消耗两个副法宝
        self.submitArtifactNum = 2
        self:setCtrlVisible("ArtifactPanel_1", false, "CostPanel")
        self:setCtrlVisible("ArtifactPanel_2", true, "CostPanel")

        local rootName = "ArtifactPanel_2"
        if chosenArtifacts and #chosenArtifacts == 2 then
            -- 选择了两个法宝
            self.chosenArtifacts = chosenArtifacts
            self:setArtifactImage(chosenArtifacts[1], self:getControl("ArtifactImagePanel_1", nil, rootName))
            self:setArtifactImage(chosenArtifacts[2], self:getControl("ArtifactImagePanel_2", nil, rootName))
        else
            -- 没有选择法宝
            self.chosenArtifacts = {}
            self:setArtifactImage(nil, self:getControl("ArtifactImagePanel_1", nil, rootName))
            self:setArtifactImage(nil, self:getControl("ArtifactImagePanel_2", nil, rootName))
        end
    end
end

-- 副法宝图标设置的功能函数
function ArtifactSkillUpDlg:setArtifactImage(artifact, root)
    if artifact then
        self:setCtrlVisible("ArtifactPanel", true, root)
        self:setCtrlVisible("NoneImage", false, root)

        -- 法宝图标
        self:setImage("ArtifactImage", InventoryMgr:getIconFileByName(artifact.name), root)
        self:setItemImageSize("ArtifactImage", root)

        -- 图标左上角等级
        self:setNumImgForPanel("ArtifactPanel", ART_FONT_COLOR.NORMAL_TEXT,
            artifact.level, false, LOCATE_POSITION.LEFT_TOP, 21, root)

        -- 图标右下角相性标志
        local img = self:getControl("ArtifactImage", nil, root)
        InventoryMgr:removeArtifactPolarImage(img)
        if artifact.item_polar then
            InventoryMgr:addArtifactPolarImage(img, artifact.item_polar)
        end

        -- 限制交易标志
        if artifact and InventoryMgr:isLimitedItem(artifact) then
            InventoryMgr:addLogoBinding(img)
        else
            InventoryMgr:removeLogoBinding(img)
        end
    else
        self:setCtrlVisible("ArtifactPanel", false, root)
        self:setCtrlVisible("NoneImage", true, root)
    end
end

-- 更新宝石消耗显示
function ArtifactSkillUpDlg:refreshCostItemPanel()
    local artifact = self.selectArtifact

    local costItem = EquipmentMgr:getArtifactSpSkillLevelUpCost(artifact)
    local costItemName = costItem.name
    local costItemNum = costItem.num
    self.costItem = costItem

    self:setImage("CostImage", InventoryMgr:getIconFileByName(costItemName), "CostImagePanel")
    self:setItemImageSize("CostImage", "CostImagePanel")
    self:setLabelText("CostItemLabel", costItemName, "CostImagePanel")
    self:setLabelText("CostNumLabel", "/" .. costItemNum, "CostImagePanel")

    local isUseLimited = false
    if self:isCheck("BindCheckBox")then
        isUseLimited = true
    else
        isUseLimited = false
    end

    local amount = InventoryMgr:getAmountByNameIsForeverBind(costItemName, isUseLimited)
    if amount < costItemNum then
        self:setLabelText("HaveNumLabel", amount, "CostImagePanel", COLOR3.RED)
    elseif amount <= 999 then
        self:setLabelText("HaveNumLabel", amount, "CostImagePanel", COLOR3.GREEN)
    else
        self:setLabelText("HaveNumLabel", "*", "CostImagePanel", COLOR3.GREEN)
    end

    -- 点击弹出道具悬浮框
    local costImagePanel = self:getControl("CostImage", nil, "CostImagePanel")
    local function listener(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            local name = self.costItem.name
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showBasicMessageDlg(name, rect)
        end
    end
    costImagePanel:addTouchEventListener(listener)
end

-- 更新升级按钮显示
function ArtifactSkillUpDlg:refreshLevelUpButton()
    local artifact = self.selectArtifact
    if not artifact then
        -- 没有选中任何法宝
        self:setCtrlVisible("SkillUpButton", true)
        self:setCtrlVisible("MarkPanel", false)
        self:setCtrlEnabled("SkillUpButton", false)
        return
    end

    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(artifact.extra_skill)
    if not artifactSpSkillName then
        -- 法宝无特殊技能
        self:setCtrlVisible("SkillUpButton", true)
        self:setCtrlVisible("MarkPanel", false)
        self:setCtrlEnabled("SkillUpButton", false)
    else
        -- 法宝有特殊技能
        local artifactSpSkillLevel = artifact.extra_skill_level
        if artifactSpSkillLevel >= artifact.level then
            -- 法宝特殊技能等级大于等于法宝等级
            self:setCtrlVisible("SkillUpButton", false)
            self:setCtrlVisible("MarkPanel", true)
        else
            self:setCtrlVisible("SkillUpButton", true)
            self:setCtrlVisible("MarkPanel", false)
            self:setCtrlEnabled("SkillUpButton", true)
        end
    end
end

-- 弹出副法宝选择界面
function ArtifactSkillUpDlg:onSelectSecondaryArtifact(sender, eventType)
    local mainArtifact = self.selectArtifact
    if not mainArtifact then
        gf:ShowSmallTips(CHS[7002011])
        return
    end

    -- 法宝是否拥有特殊技能
    local artifactSpSkillName = SkillMgr:getArtifactSpSkillName(mainArtifact.extra_skill)
    if not artifactSpSkillName then
        gf:ShowSmallTips(CHS[7002013])
        return
    end

    local artifacts = InventoryMgr:getBagAllArtifacts()
    local count = 0
    for i = 1, #artifacts do
        if artifacts[i].name == self.selectArtifact.name
            and not InventoryMgr:isTimeLimitedItem(artifacts[i])
            and artifacts[i].pos ~= mainArtifact.pos then
            count = count + 1
        end
    end

    if self.submitArtifactNum > 0 and count < self.submitArtifactNum then
        gf:ShowSmallTips(string.format(CHS[7002003], self.submitArtifactNum))
        return
    end

    -- 打开副法宝选择界面
    local dlg = DlgMgr:openDlg("ArtifactSubmitDlg")
    dlg:setMainArtifact(self.selectArtifact)
    dlg:setSubmitType("skillup")
    dlg:setSubmitNum(self.submitArtifactNum)
end


function ArtifactSkillUpDlg:onSkillUpButton()
    if not DistMgr:checkCrossDist() then return end

    local artifact = self.selectArtifact

    if not artifact then
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    -- 玩家等级不够
    if Me:getLevel() < ARTIFACT_SPSKILL_LEVELUP_MIN_LEVEL then
        gf:ShowSmallTips(string.format(CHS[3004067], ARTIFACT_SPSKILL_LEVELUP_MIN_LEVEL))
        return
    end

    -- 限时法宝
    if InventoryMgr:isTimeLimitedItem(artifact) then
        gf:ShowSmallTips(CHS[7002004])
        return
    end

    -- 法宝无特殊技能
    if not SkillMgr:getArtifactSpSkillName(artifact.extra_skill) then
        gf:ShowSmallTips(CHS[7002005])
        return
    end

    local isUseLimited = false
    if self:isCheck("BindCheckBox")then
        isUseLimited = true
    else
        isUseLimited = false
    end

    -- 材料不足
    local costItem = EquipmentMgr:getArtifactSpSkillLevelUpCost(artifact)
    local amount = InventoryMgr:getAmountByNameIsForeverBind(costItem.name, isUseLimited)
    if amount < costItem.num then
        gf:ShowSmallTips(string.format(CHS[7002007], costItem.name))
        return
    end

    -- 法宝不足
    if not self.chosenArtifacts or #self.chosenArtifacts < self.submitArtifactNum then
        gf:ShowSmallTips(string.format(CHS[7002008], self.submitArtifactNum))
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onSkillUpButton") then
        return
    end

    self:skillLevelUp()
end

function ArtifactSkillUpDlg:skillLevelUp()
    local artifact = self.selectArtifact
    if not artifact then
        return
    end

    local costItemName = self.costItem.name
    local costItemNum = self.costItem.num

    if not costItemName or not costItemNum then
        return
    end

    local isUseLimited = false
    if self:isCheck("BindCheckBox")then
        isUseLimited = true
    else
        isUseLimited = false
    end

    -- 限制交易时间提示
    local str, day = gf:converToLimitedTimeDay(artifact.gift)
    local count = 0
    if InventoryMgr:isLimitedItemForever(self.chosenArtifacts[1]) then
        count = count + 10
    end

    if InventoryMgr:isLimitedItemForever(self.chosenArtifacts[2]) then
        count = count + 10
    end

    local data = {}
    data.pos = artifact.pos
    data.type = Const.UPGRADE_ARTIFACT_EXTRA_SKILL

    if self.submitArtifactNum == 2 then
        -- 消耗两个法宝+一个道具
        local item = InventoryMgr:getPriorityUseInventoryByName(costItemName, isUseLimited)
        if InventoryMgr:isLimitedItemForever(item) then
            count = count + 10
        end

        data.para = self.chosenArtifacts[1].pos .. "|" .. self.chosenArtifacts[2].pos .. "|" .. item.pos
        if day <= Const.LIMIT_TIPS_DAY and count > 0 then
            gf:confirm(string.format(CHS[7002012], count), function()
                gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
            end)
            return
        end

        gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
    else
        -- 消耗两个道具+一个法宝

        local itemArray = InventoryMgr:getItemArrayByCostOrder(costItemName, isUseLimited)
        if not itemArray[1] then
            return
        end

        -- 第一个道具
        local firstItem = itemArray[1]
        if InventoryMgr:isLimitedItemForever(firstItem) then
            count = count + 10
        end

        -- 第二个道具
        local secondItem
        if itemArray[1].amount == 1 then
            -- 消耗的第二个道具不与第一个道具堆叠在一起
            secondItem = itemArray[2]
        else
            -- 消耗的第二个道具与第一个道具堆叠在一起
            secondItem = itemArray[1]
        end

        if not secondItem then
            return
        end

        if InventoryMgr:isLimitedItemForever(secondItem) then
            count = count + 10
        end

        data.para = self.chosenArtifacts[1].pos .. "|" .. firstItem.pos .. "|" .. secondItem.pos
        if day <= Const.LIMIT_TIPS_DAY and count > 0 then
            gf:confirm(string.format(CHS[7002012], count), function()
                gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
            end)
            return
        end

        gf:CmdToServer("CMD_UPGRADE_EQUIP", data)
    end
end

function ArtifactSkillUpDlg:onLimitedCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        InventoryMgr:setLimitItemDlgs(self.name, 1)
        gf:ShowSmallTips(CHS[6000525])
    else
        InventoryMgr:setLimitItemDlgs(self.name, 0)
    end

    self:refreshCostItemPanel()
end

function ArtifactSkillUpDlg:onRuleButton()

    local data = {one = CHS[4200590], isScrollToDef = true}
    DlgMgr:openDlgEx("ArtifactRuleNewDlg", data)
end

function ArtifactSkillUpDlg:cleanup()
    self.selectArtifact = nil

    self.submitArtifactNum = 0

    self.chosenArtifacts = {}
end

return ArtifactSkillUpDlg
