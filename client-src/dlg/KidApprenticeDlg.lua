-- KidApprenticeDlg.lua
-- Created by lixh Apr/01/2019
-- 娃娃拜师界面

local KidApprenticeDlg = Singleton("KidApprenticeDlg", Dialog)

-- 门派信息配置
local FAMILY_INFO_CFG = HomeChildMgr:getFamilyCfg()

function KidApprenticeDlg:init()
    self.itemPanel = self:retainCtrl("OneTeacherPanel")
    self.listView = self:getControl("ListView")
    self.listView:addScrollViewEventListener(function(sender, eventType) self:updateArrowVisible() end)

    local effectPanel = self:getControl("MainPanel")
    gf:createArmatureMagic(ResMgr.ArmatureMagic.sjb_arrow_right, effectPanel, Const.ARMATURE_MAGIC_TAG)
    self.leftImage = effectPanel:getChildByTag(Const.ARMATURE_MAGIC_TAG)
    self.leftImage:setPosition(10, 230)
    self.leftImage:setLocalZOrder(30)
    gf:createArmatureMagic(ResMgr.ArmatureMagic.sjb_arrow_left, effectPanel, Const.ARMATURE_MAGIC_TAG + 1)
    self.rightImage = effectPanel:getChildByTag(Const.ARMATURE_MAGIC_TAG + 1)
    self.rightImage:setPosition(792, 230)
    self.rightImage:setLocalZOrder(30)
end

function KidApprenticeDlg:setData(childInfo)
    self.childId = childInfo.id
    self.childGender = childInfo.gender

    self.listView:removeAllChildren()

    local startIndex = self.childGender == 1 and 1 or 6
    for i = startIndex, startIndex + 4 do
        local familyInfo = FAMILY_INFO_CFG[i]
        local itemPanel = self.itemPanel:clone()
        self:setSingelItemInfo(itemPanel, familyInfo)
        self.listView:pushBackCustomItem(itemPanel)
    end

    self.listView:refreshView()
    self:updateArrowVisible()
end

function KidApprenticeDlg:updateArrowVisible()
    self.leftImage:setVisible(true)
    self.rightImage:setVisible(true)

    local percent = self:getCurScrollPercent("ListView")
    if percent <= 0 then
        self.rightImage:setVisible(false)
    end

    if percent >= 100 then
        self.leftImage:setVisible(false)
    end
end

function KidApprenticeDlg:setSingelItemInfo(panel, info)
    -- 头像
    local bonesPath, texturePath = ResMgr:getBonesCharFilePath(info.icon)
    local bExist = cc.FileUtils:getInstance():isFileExist(bonesPath)
    if bExist then
        self:creatCharDragonBones(info.icon, self:getControl("NPCIconPanel", nil, panel))
    end

    -- 系别
    local familyPanel = self:getControl("PolarPanel", nil, panel)
    self:setLabelText("NameLabel", info.familyChs, familyPanel)

    -- 道具icon
    local itemPanel = self:getControl("IconInfoPanel", nil, panel)
    self:setImage("IconImage", ResMgr:getIconPathByName(info.itemName), itemPanel)

    -- 道具名称
    self:setLabelText("NameLabel", info.itemName, itemPanel)

    -- 抓取按钮
    self:getControl("ChosenButton", nil, panel).family = info.family
    self:bindListener("ChosenButton", self.onChosenButton, panel)
end

function KidApprenticeDlg:creatCharDragonBones(icon, panel)
    local magic = panel:getChildByName("KidPortrait")

    if magic then
        if magic:getTag() == icon then
            return
        else
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
            magic:removeFromParent()
        end
    end

    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local magic = tolua.cast(dbMagic, "cc.Node")
    magic:setPosition(panel:getContentSize().width * 0.5, 0)
    magic:setName("KidPortrait")
    magic:setTag(icon)
    panel:addChild(magic)

    return magic
end

function KidApprenticeDlg:cleanup()
    self.childId = nil

    -- 释放骨骼动画相关资源
    if self.listView then
        local items = self.listView:getItems()
        for i = 1, #items do
            local panel = self:getControl("NPCIconPanel", nil, items[i])
            if panel then
                local magic = panel:getChildByName("KidPortrait")
                if magic then
                    DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
                end
            end
        end

        self.listView = nil
    end
end

-- 请求拜师
function KidApprenticeDlg:onChosenButton(sender, eventType)
    gf:CmdToServer("CMD_CHILD_JOIN_FAMILY", {id = self.childId, type = sender.family})
end

return KidApprenticeDlg
