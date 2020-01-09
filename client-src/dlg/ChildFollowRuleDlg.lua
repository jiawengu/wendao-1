-- ChildFollowRuleDlg.lua
-- Created by lixh Apr/01/2019
-- 娃娃跟随介绍界面

local ChildFollowRuleDlg = Singleton("ChildFollowRuleDlg", Dialog)

function ChildFollowRuleDlg:init()
    self:bindListener("CheckButton", self.onCheckButton)

    self.kid = HomeChildMgr:getFightKid()

    self:setInfo()
end

function ChildFollowRuleDlg:setInfo()
    local panel = self:getControl("ChildFollowRulePanel")

    if self.kid then
        -- 跟随中
        self:setLabelText("TitleLabel", CHS[7120251])

        -- 头像
        self:getControl("ShapePanel"):setBackGroundImage(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
        local kidCfg = HomeChildMgr:getFamilyCfg(self.kid:queryBasicInt("gender"), self.kid:queryBasicInt("polar"))
        self:setImage("GuardImage", ResMgr:getSmallPortrait(kidCfg.icon), panel)
        self:setImageSize("GuardImage", {width = 64, height = 64}, panel)

        -- 等级
        self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, self.kid:getLevel(),
            false, LOCATE_POSITION.LEFT_TOP, 21, panel)

        -- 名字
        self:setLabelText("NameLabel", self.kid:getName(), panel, COLOR3.GREEN)

        -- 体力
        self:setLabelText("StrengtLabel", string.format(CHS[7100443], self.kid:queryBasicInt("energy")), panel)
    else
        self:setLabelText("TitleLabel", CHS[7120252])

        self:getControl("ShapePanel"):setBackGroundImage(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
        self:setImage("GuardImage", ResMgr.ui.kid_logo_image, panel)
        self:setImageSize("GuardImage", {width = 64, height = 64}, panel)

        self:setLabelText("NameLabel", CHS[7120253], panel, COLOR3.EQUIP_NORMAL)

        self:setLabelText("StrengtLabel", CHS[7120255], panel)
    end

end

function ChildFollowRuleDlg:onCheckButton(sender, eventType)
    if self.kid then
        DlgMgr:openDlgEx("KidInfoDlg", {selectId = self.kid:queryBasic("cid")})
        DlgMgr:closeDlg(self.name)
    else
        local kids = HomeChildMgr:getChildByOrder()
        for i = 1, #kids do
            if kids[i].stage == HomeChildMgr.CHILD_TYPE.KID then
                DlgMgr:openDlgEx("KidInfoDlg", {selectId = kids[i].id})
            end
        end

        DlgMgr:closeDlg(self.name)
    end
end

function ChildFollowRuleDlg:cleanup()
    self.kid = nil
end

return ChildFollowRuleDlg
