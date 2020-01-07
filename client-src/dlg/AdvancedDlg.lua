-- AdvancedDlg.lua
-- Created by zhengjh 23/Jul/2015
-- 守护历练界面

local AdvancedDlg = Singleton("AdvancedDlg", Dialog)

function AdvancedDlg:init()
    self:setCtrlFullClient("BlackImage", "BKPanel_1")
    self:getControl("BlackImage"):setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)
    self.root:setContentSize(Const.WINSIZE.width / Const.UI_SCALE, Const.WINSIZE.height / Const.UI_SCALE)

    self:bindListener("ConfrimButton", self.onConfrimButton)
    self:bindListener("ConfrimPanel", self.onConfrimButton)
    DlgMgr:closeDlg("GuardAdvanceDlg")
   -- DlgMgr:closeDlg("GuardAttribDlg")
end

function AdvancedDlg:setLabelTextAndShadow(name, content, shadowName, root)
    self:setLabelText(name, content, root)
    self:setLabelText(shadowName, content, root)
end

function AdvancedDlg:setData(data)
    local guardId = data.guard_id
    local guard = GuardMgr:getGuard(guardId)

    -- 相性
    local polar = gf:getPolar(guard:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, "OldShapePanel")
    self:setImagePlist("PolarImage", polarPath, "NewShapePanel")
    -- 头像
    local imgPath = ResMgr:getSmallPortrait(guard:queryBasicInt("icon"))
    self:setImage("GuardImage", imgPath, "OldShapePanel")
    self:setImage("GuardImage", imgPath, "NewShapePanel")
    self:setItemImageSize("GuardImage", "OldShapePanel")
    self:setItemImageSize("GuardImage", "NewShapePanel")

    -- 品阶颜色
    local rankImg = self:getGuardColorByRank(data.raw_rank)
    self:setImagePlist("CoverImage", rankImg, "OldShapePanel")
    local rankImg2 = self:getGuardColorByRank(guard:queryBasicInt("rank"))
    self:setImagePlist("CoverImage", rankImg2, "NewShapePanel")

    -- 气血
    local lifePanel = self:getControl("LifeEffectPanel")
    self:setLabelTextAndShadow("LifeEffectLabel_1", data.raw_life, "LifeEffectLabel_0", lifePanel)
    self:setLabelTextAndShadow("LifeEffectLabel_3", guard:queryBasicInt("life"), "LifeEffectLabel_2", lifePanel)

    -- 物伤
    local PhyPanel = self:getControl("PhyEffectPanel")
    self:setLabelTextAndShadow("PhyEffectLabel_1", data.raw_phy_power, "PhyEffectLabel_0", PhyPanel)
    self:setLabelTextAndShadow("PhyEffectLabel_3", guard:queryBasicInt("phy_power"), "PhyEffectLabel_2", PhyPanel)

    -- 法伤
    local MagPanel = self:getControl("MagEffectPanel")
    self:setLabelTextAndShadow("MagEffectLabel_1", data.raw_mag_power, "MagEffectLabel_0", MagPanel)
    self:setLabelTextAndShadow("MagEffectLabel_3", guard:queryBasicInt("mag_power"), "MagEffectLabel_2", MagPanel)

    -- 速度
    local SpeedPanel = self:getControl("SpeedEffectPanel")
    self:setLabelTextAndShadow("SpeedEffectLabel_1", data.speed, "SpeedEffectLabel_0", SpeedPanel)
    self:setLabelTextAndShadow("SpeedEffectLabel_3", guard:queryBasicInt("speed"), "SpeedEffectLabel_2", SpeedPanel)

    -- 防御
    local DefPanel = self:getControl("DefEffectPanel")
    self:setLabelTextAndShadow("DefEffectLabel_1", data.def, "DefEffectLabel_0", DefPanel)
    self:setLabelTextAndShadow("DefEffectLabel_3", guard:queryBasicInt("def"), "DefEffectLabel_2", DefPanel)
end

-- 根据等级获取守护的颜色
function AdvancedDlg:getGuardColorByRank(rank)
    if rank == GUARD_RANK.TONGZI then
        return ResMgr.ui.guard_rank1
    elseif rank == GUARD_RANK.ZHANGLAO then
        return ResMgr.ui.guard_rank2
    elseif rank == GUARD_RANK.SHENLING then
        return ResMgr.ui.guard_rank3
    end

    return nil
end

function AdvancedDlg:onConfrimButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

return AdvancedDlg
