-- ChildFlyDoneDlg.lua
-- Created by lixh, Apr/12/2019
-- 娃娃飞升成功界面

local ChildFlyDoneDlg = Singleton("ChildFlyDoneDlg", Dialog)

function ChildFlyDoneDlg:init(data)
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel_1")

    self:bindListener("ConfrimPanel", self.onConfirmButton)
    self:bindListener("ConfrimButton", self.onConfirmButton)
end

function ChildFlyDoneDlg:setData(data)
    local kid = HomeChildMgr:getKidByCid(data.id)
    if not kid then
        return
    end

    local afterData = data.after
    local beforeData = data.before

    -- 头像
    local icon = kid:queryBasicInt("portrait")
    local bonesPath, texturePath = ResMgr:getBonesCharFilePath(icon)
    local bExist = cc.FileUtils:getInstance():isFileExist(bonesPath)
    if bExist then
        self:creatCharDragonBones(icon, self:getControl("NPCIconPanel", nil, "MainPanel"))
    end

    -- 名称
    self:setLabelText("NameLabel1", kid:getShowName(), "MainPanel")

    -- 飞升前
    local totalBefore = beforeData.life_shape + beforeData.mana_shape
        + beforeData.speed_shape + beforeData.phy_shape + beforeData.mag_shape
    self:setLabelText("TotalGrowValueLabel1", totalBefore)
    self:setLabelText("LifeGrowValueLabel1", beforeData.life_shape)
    self:setLabelText("ManaGrowValueLabel1", beforeData.mana_shape)
    self:setLabelText("SpeedGrowValueLabel1", beforeData.speed_shape)
    self:setLabelText("PhyGrowValueLabel1", beforeData.phy_shape)
    self:setLabelText("MagGrowValueLabel1", beforeData.mag_shape)

    -- 飞升后
    local totalAfter = afterData.life_shape + afterData.mana_shape
        + afterData.speed_shape + afterData.phy_shape + afterData.mag_shape
    self:setLabelText("TotalGrowValueLabel2", totalAfter)
    self:setLabelText("LifeGrowValueLabel2", afterData.life_shape)
    self:setLabelText("ManaGrowValueLabel2", afterData.mana_shape)
    self:setLabelText("SpeedGrowValueLabel2", afterData.speed_shape)
    self:setLabelText("PhyGrowValueLabel2", afterData.phy_shape)
    self:setLabelText("MagGrowValueLabel2", afterData.mag_shape)
end

function ChildFlyDoneDlg:creatCharDragonBones(icon, panel)
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
    magic:setPosition(panel:getContentSize().width * 0.5, 30)
    magic:setName("KidPortrait")
    magic:setTag(icon)
    magic:setScaleX(0.9)
    magic:setScaleY(0.9)
    panel:addChild(magic)

    return magic
end

function ChildFlyDoneDlg:cleanup()
    -- 释放骨骼动画相关资源
    local panel = self:getControl("NPCIconPanel", nil, "MainPanel")
    if panel then
        local magic = panel:getChildByName("KidPortrait")
        if magic then
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        end
    end
end

function ChildFlyDoneDlg:onConfirmButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

return ChildFlyDoneDlg
