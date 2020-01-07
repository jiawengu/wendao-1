-- PetExploreRewardDlg.lua
-- Created by lixh Jan/19/2019 
-- 宠物探索小队奖励界面

local PetExploreRewardDlg = Singleton("PetExploreRewardDlg", Dialog)

-- 探索技能配置
local EXPLORE_SKILL_CFG = PetExploreTeamMgr:getExploreSkillCfg()

function PetExploreRewardDlg:init()
    self:bindListener("ClosePanel", self.onCloseButton)
end

function PetExploreRewardDlg:setData(data)
    -- 结果类型
    local starPanel = self:getControl("StarPanel")
    if data.result == 2 then
        self:setCtrlVisible("StarImage1", true, starPanel)
        self:setCtrlVisible("BKImage1", true, starPanel)
    elseif data.result == 1 then
        self:setCtrlVisible("StarImage2", true, starPanel)
        self:setCtrlVisible("BKImage2", true, starPanel)
    elseif data.result == 0 then
        self:setCtrlVisible("StarImage3", true, starPanel)
        self:setCtrlVisible("BKImage3", true, starPanel)
    end

    -- 宠物奖励
    for i = 1, 3 do
        local panel = self:getControl("PetGetPanel" .. i)
        local info = data.bonus_list[i]
        if info then
            self:setLabelText("Label1", string.format(CHS[7190598], info.pet_name), panel)
            self:setLabelText("NumLabel", info.desc, panel)
            if info.bonus_type == "intimacy" then
                self:setLabelText("Label2", CHS[7190600], panel)
            else
                self:setLabelText("Label2", CHS[7190599], panel)
            end
        else
            self:setLabelText("Label1", "", panel)
            self:setLabelText("NumLabel", "", panel)
            self:setLabelText("Label2", "", panel)
        end
    end

    -- 道具奖励
    local itemRootName = "IconPanel1"
    if string.isNilOrEmpty(data.bonus_type) then
        self:setCtrlVisible(itemRootName, false)
        itemRootName = "IconPanel3"
        self:setCtrlVisible(itemRootName, true)
    end

    local itemCfg = EXPLORE_SKILL_CFG[data.item_id]
    if itemCfg then
        self:setImage("IconImage", itemCfg.materailPath, itemRootName)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, data.item_desc,
            nil, LOCATE_POSITION.RIGHT_BOTTOM, 19, itemRootName)

        self:getControl(itemRootName).item_id = data.item_id
        self:bindListener(itemRootName, self.onMaterialPanel)
    end

    -- 大成功特殊奖励
    if not string.isNilOrEmpty(data.bonus_type) then
        local iconPath, isPlist = ResMgr:getIconPathByName(data.bonus_desc)
        if iconPath then
            -- 道具,宠物
            if isPlist then
                self:setImagePlist("IconImage", iconPath, "IconPanel2")
            else
                self:setImage("IconImage", iconPath, "IconPanel2")
            end
        else
            self:setCtrlVisible("IconPanel2", false)
        end

        self:createBigSuccEffect()

        local panel = self:getControl("IconPanel2")
        panel.item_type = data.bonus_type
        panel.item_name = data.bonus_desc
        self:bindListener("IconPanel2", self.onBigRewardPanel)
    else
        self:setCtrlVisible("IconPanel2", false)
    end
end

-- 点击大成功奖励框
function PetExploreRewardDlg:onBigRewardPanel(sender, eventType)
    local item_type = sender.item_type
    local item_name = sender.item_name
    if string.isNilOrEmpty(item_type) or string.isNilOrEmpty(item_name) then
        return
    end

    local rect = self:getBoundingBoxInWorldSpace(sender)
    if item_type == 'pet' or string.match(item_name, CHS[7100346]) then
        -- 宠物，或者首饰
        local dlg = DlgMgr:openDlg("BonusInfo2Dlg")
        local iconPath, isPlist = ResMgr:getIconPathByName(item_name)
        local rewardInfo = {
            imagePath = ResMgr:getIconPathByName(item_name),
            resType = isPlist and ccui.TextureResType.plistType or ccui.TextureResType.localType,
            basicInfo = {item_name}
        }
        dlg:setRewardInfo(rewardInfo)
        dlg.root:setAnchorPoint(0, 0)
        dlg:setFloatingFramePos(rect)
    else
        -- 道具
        local item = {name = item_name}
        item["isGuard"] = InventoryMgr:getIsGuard(item.name)
        local dlg = DlgMgr:openDlg("ItemInfoDlg")
        dlg:setInfoFormCard(item)
        dlg:setFloatingFramePos(rect)
    end
end

-- 点击材料框
function PetExploreRewardDlg:onMaterialPanel(sender, eventType)
    local skill_index = sender.item_id

    local dlg = DlgMgr:openDlg("BonusInfoDlg")
    local rect = self:getBoundingBoxInWorldSpace(sender)
    dlg:setRewardInfo({
        imagePath = EXPLORE_SKILL_CFG[skill_index].materailPath,
        resType = ccui.TextureResType.localType,
        basicInfo = {
            [1] = EXPLORE_SKILL_CFG[skill_index].materialName
        },

        desc = EXPLORE_SKILL_CFG[skill_index].materailDes
    })
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function PetExploreRewardDlg:createBigSuccEffect()
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.pet_explore_reward.name)
    local sz = self.root:getContentSize()
    local pos = cc.p(sz.width / 2, sz.height / 2)
    magic:setPosition(pos)
    self.root:addChild(magic, 10)
    magic:getAnimation():play("Top", -1, 1)
end

return PetExploreRewardDlg
