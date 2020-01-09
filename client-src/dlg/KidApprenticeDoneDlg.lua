-- KidApprenticeDoneDlg.lua
-- Created by lixh Apr/01/2019
-- 娃娃拜师成功界面

local KidApprenticeDoneDlg = Singleton("KidApprenticeDoneDlg", Dialog)

function KidApprenticeDoneDlg:init()
    self:setFullScreen()
    self:setCtrlFullClientEx("BKPanel_1")
    self:bindListener("CheckButton", self.onCheckButton)
end

function KidApprenticeDoneDlg:setData(data)
    self.childId = data.childId

    local icon = HomeChildMgr:getFamilyCfg(data.gender, data.family).icon
    local bonesPath, texturePath = ResMgr:getBonesCharFilePath(icon)
    local bExist = cc.FileUtils:getInstance():isFileExist(bonesPath)
    if bExist then
        self:creatCharDragonBones(icon, self:getControl("NPCIconPanel", nil, "MainPanel"))
    end
end

function KidApprenticeDoneDlg:creatCharDragonBones(icon, panel)
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
    magic:setPosition(panel:getContentSize().width * 0.5, 20)
    magic:setName("KidPortrait")
    magic:setTag(icon)
    magic:setScaleX(0.9)
    magic:setScaleY(0.9)
    panel:addChild(magic)

    return magic
end

function KidApprenticeDoneDlg:cleanup()
    self.childId = nil

    -- 释放骨骼动画相关资源
    local panel = self:getControl("NPCIconPanel", nil, "MainPanel")
    if panel then
        local magic = panel:getChildByName("KidPortrait")
        if magic then
            DragonBonesMgr:removeCharDragonBonesResoure(magic:getTag(), string.format("%05d", magic:getTag()))
        end
    end
end

function KidApprenticeDoneDlg:onCheckButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    DlgMgr:openDlgEx("KidInfoDlg", {selectId = self.childId})
end

return KidApprenticeDoneDlg
