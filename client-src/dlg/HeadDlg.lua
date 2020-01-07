-- HeadDlg.lua
-- created by cheny Nov/28/2014
-- 头像对话框

local HeadDlg = Singleton("HeadDlg", Dialog)

-- 大于该数值时，血池、灵池的进度条显示 100%
local EXTRA_MAX = 50000

HeadDlg.actNum  = 0
HeadDlg.headGray = false

local GONG_TONG_Y_MARGIN = 40

function HeadDlg:init()
    self:setFullScreen()
    self:bindListener("PlayerImage", self.onPlayerImage)
    self:bindListener("PetImage", self.onPetImage)
    self:bindListener("PlayerBcakImage", self.onPlayerInfo)
    self:bindListener("PlayerBcakImage2", self.onPlayerInfo)
    self:bindListener("PetLifeBcakImage", self.onPetInfo)
    self:bindListener("PetChangePanel", self.onPetChangePanel)
    self:bindListener("PreventFatigueImage", self.onPreventFatigueImage)
    self:bindListener("ChildFollowPanel", self.onChildFollowPanel)
    self:bindListener("PetFollowPanel", self.onPetFollowPanel)

    self.gongtongPanel = self:getControl("PetChangePanel")
    self.followKidPanel = self:getControl("ChildFollowPanel")
    performWithDelay(self.root, function()
        -- 延迟一帧，在self.root doLayout之后获取坐标
        self.gongtongOrgY = self.gongtongPanel:getPositionY()
    end)

    self.curPlayerLife  = 0
    self.curPlayerMana  = 0
    self.curPetLife     = 0
    self.curPetMana     = 0

    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_UPDATE_IMPROVEMENT")
    self:hookMsg('MSG_UPDATE_PETS')
    self:hookMsg("MSG_ICON_CARTOON")
    self:hookMsg("MSG_SET_SETTING")
    self:hookMsg("MSG_UPDATE_ANTIADDICTION_STATUS")

    self:updatePlayerInfo()
    self:updatePetInfo()

    -- 设置默认图片并更新防沉迷信息
    self:setImage("PreventFatigueImage", ResMgr.ui.prevent_fatigue_0)
    self:updateAntiaddictionInfo()

    -- 元神共通
    self:setCtrlVisible("PetChangePanel", SystemSettingMgr:getSettingStatus("award_supply_pet", 0) >= 1)

    -- 娃娃跟随
    self:updateChildPanelShow()
end

function HeadDlg:updateFightPetWhenHasFightKid(tempPetId)
    self.tempPetId = tempPetId
end

function HeadDlg:updateChildPanelShow()
    if #HomeChildMgr:getKidList(HomeChildMgr.CHILD_TYPE.KID) > 0 then
        if Me:isInCombat() and HomeChildMgr:getFightKid() then
            self:setCtrlVisible("ChildFollowPanel", false)
            self:setCtrlVisible("PetFollowPanel", true)
        else
            self:setCtrlVisible("PetFollowPanel", false)
            self:setCtrlVisible("ChildFollowPanel", true)
        end

    else
        self:setCtrlVisible("ChildFollowPanel", false)
        self:setCtrlVisible("PetFollowPanel", false)
    end

    self:updateGongtongPosition()
end

-- 清除数据
function HeadDlg:cleanup()
	self.numImg = nil
    self.lastTimeText = nil
    self.headGray = false
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
end

function HeadDlg:updatePlayerInfo()
    local curLife = Me:getExtraRecoverLife()
    if Me:isInCombat() then
        curLife = Me:queryInt("life")
    end

    local curMana = Me:getExtraRecoverMana()
    if Me:isInCombat() then
        curMana = Me:queryInt("mana")
    end

    self.curPlayerLife  = curLife
    self.curPlayerMana  = curMana

    self:setProgressBar("PlayerLifeProgressBar", curLife, Me:queryInt("max_life"))
    self:setProgressBar("PlayerManaProgressBar", curMana, Me:queryInt("max_mana"))
    self:setProgressBar("PlayerEXPProgressBar", Me:queryInt("exp"), Me:queryInt("exp_to_next_level"))

    local extraLife = Me:queryInt("extra_life")
    local extraMana = Me:queryInt("extra_mana")
    if extraLife > EXTRA_MAX then extraLife = EXTRA_MAX end
    if extraMana > EXTRA_MAX then extraMana = EXTRA_MAX end
    self:setProgressBar("PlayerExtraLifeProgressBar", extraLife, EXTRA_MAX)
    self:setProgressBar("PlayerExtraManaProgressBar", extraMana, EXTRA_MAX)

    if Me:isRealBody() then
        -- 人物等级
        local level = Me:queryBasicInt("level")
        -- 人物等级使用带描边的数字图片显示
        self:setNumImgForPanel("PlayerPanel", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 21)
        self:setImage("PlayerImage", ResMgr:getSmallPortrait(Me:queryBasicInt("org_icon")))
        self:setProgressBar("PlayerEXPProgressBar", Me:queryInt("exp"), Me:queryInt("exp_to_next_level"))
    else
        -- 元婴、血
        local level = Me:queryBasicInt("upgrade/level")
        -- 人物等级使用带描边的数字图片显示
        self:setNumImgForPanel("PlayerPanel", ART_FONT_COLOR.NORMAL_TEXT, level, false, LOCATE_POSITION.LEFT_TOP, 21)
        self:setImage("PlayerImage", ResMgr:getSmallPortrait(Me:getChildPortrait()))
        self:setProgressBar("PlayerEXPProgressBar", Me:queryInt("upgrade/exp"), Me:queryInt("upgrade/exp_to_next_level"))
    end

    local isInnerAlchemyOpen = InnerAlchemyMgr:isInnerAlchemyOpen(Me:queryInt("upgrade/level"), Me:queryInt("upgrade/type"))
    self:setCtrlVisible("PlayerBcakImage", not isInnerAlchemyOpen)
    self:setCtrlVisible("PlayerBcakImage2", isInnerAlchemyOpen)
    self:setCtrlVisible("CoverImage", not isInnerAlchemyOpen, "PlayerPanel")
    self:setCtrlVisible("CoverImage2", isInnerAlchemyOpen, "PlayerPanel")
    self:setCtrlVisible("PlayerInnerEXPProgressBar", isInnerAlchemyOpen)

    if isInnerAlchemyOpen then
        self:setProgressBar("PlayerInnerEXPProgressBar", InnerAlchemyMgr:getCurrentSpirit(), InnerAlchemyMgr:getCurrentMaxSpirit())
    else
        self:setProgressBar("PlayerInnerEXPProgressBar", 0, 100)
    end

    self:setItemImageSize("PlayerImage")

    self:updatePetInfo()
end

function HeadDlg:updatePetInfo()
    local life, max_life = 0,0
    local mana, max_mana = 0,0
    local exp, exp_to_next_level = 0,0
    local portrait = 0
    local pet = PetMgr:getFightPet()
    local kid = HomeChildMgr:getFightKid()

    if Me:isInCombat() and kid and not FightMgr:hasRecvEndCombatMsg() then
        -- 只在战斗中使用娃娃对象刷新右上角宠物头像信息
        pet = kid
    end

    local petLevel = 0

    if self.headGray then
        return
    end

    if pet ~= nil then
        local curLife = pet:getExtraRecoverLife()
        if Me:isInCombat() then
            curLife = pet:queryInt("life")
        end

        local curMana = pet:getExtraRecoverMana()
        if Me:isInCombat() then
            curMana = pet:queryInt("mana")
        end

        life = curLife
        max_life = pet:queryInt("max_life")
        mana = curMana
        max_mana = pet:queryInt("max_mana")
        exp = pet:queryInt("exp")
        exp_to_next_level = pet:queryInt("exp_to_next_level")
        portrait = pet:queryBasicInt("portrait")
        petLevel = pet:queryBasicInt("level")

        self.curPetLife = life
        self.curPetMana = mana

        -- 宠物等级更新使用带描边的数字图片显示
        self.numImg = self:setNumImgForPanel("PetPanel", ART_FONT_COLOR.NORMAL_TEXT,
                                            petLevel, false, LOCATE_POSITION.LEFT_TOP,21)
        self.numImg:setVisible(true)
    elseif self.numImg then
        -- 如果不存在参战宠物，则宠物等级不显示
        self.numImg:setVisible(false)
    end

    self:setImage("PetImage", ResMgr:getSmallPortrait(portrait))
    self:setItemImageSize("PetImage")
    self:setProgressBar("PetLifeProgressBar", life, max_life)
    self:setProgressBar("PetManaProgressBar", mana, max_mana)
    self:setProgressBar("PetEXPProgressBar", exp, exp_to_next_level)
end

-- 检测是否需要置灰或者恢复宠物头像
function HeadDlg:checkGrayPetHeadImgInCombat()
    local pet = PetMgr:getFightPet()
    local kid = HomeChildMgr:getFightKid()
    local petHeadImg = self:getControl("PetImage", Const.UIImage)

    if not pet and not kid then
        gf:resetImageView(petHeadImg)
        self.headGray = false
        return false
    end

    local fightObj
    if pet then
        fightObj = FightMgr:getObjectById(pet:queryBasicInt("id"))
    else
        fightObj = FightMgr:getObjectById(kid:queryBasicInt("id"))
    end

    if Me:isInCombat() then
        if not fightObj or fightObj:queryInt("life") == 0 then
            -- 如果战斗对象中没有自己的宠物或娃娃，不用通知更新
            gf:grayImageView(petHeadImg)
            self:updatePetInfo()
            self.headGray = true
            return true
        else
            gf:resetImageView(petHeadImg)
            self.headGray = false
            return false
        end
    else
        gf:resetImageView(petHeadImg)
        self.headGray = false
        return false
    end
end

-- 恢复置灰图标并更新宠物
function HeadDlg:resetPetHeadImgAndUpdate()
    local petHeadImg = self:getControl("PetImage", Const.UIImage)
    gf:resetImageView(petHeadImg)
    self.headGray = false
    self:updatePetInfo()
end

-- 置灰宠物图标
function HeadDlg:grayPetHeadImgWithoutUpdate()
    local petHeadImg = self:getControl("PetImage", Const.UIImage)
    gf:grayImageView(petHeadImg)
    self:updatePetInfo()
    self.headGray = true
end

function HeadDlg:onPlayerInfo()
    DlgMgr:openDlgEx("HeadPlayerRuleDlg", {curPlayerLife = self.curPlayerLife, curPlayerMana = self.curPlayerMana,
        node = self:getControl("PlayerPanel")})
end

function HeadDlg:onPetChangePanel()
    DlgMgr:openDlg("PetChangeRuleDlg")
end


function HeadDlg:onPetFollowPanel()
    DlgMgr:openDlgEx("PetFollowRuleDlg", self.tempPetId)
end


function HeadDlg:onChildFollowPanel()
    DlgMgr:openDlg("ChildFollowRuleDlg")
end

function HeadDlg:onPetInfo()
    local pet = PetMgr:getFightPet()
    local kid = HomeChildMgr:getFightKid()
    local dlgName = "HeadPetRuleDlg"
    if Me:isInCombat() and kid then
        pet = HomeChildMgr:getFightKid()
        dlgName = "HeadChildRuleDlg"
    end

    if not pet then return end

    DlgMgr:openDlgEx(dlgName, {curPetLife = self.curPetLife, curPetMana = self.curPetMana,
        node = self:getControl("PetPanel")})
end

function HeadDlg:onPlayerImage(sender)
    local ctrl = sender:getParent()
    local magic = ctrl:getChildByName(ResMgr.magic.headDlg_magic)
    if magic then
        magic:removeFromParent()
        local dlg = DlgMgr:openDlg("UserDlg")
        dlg:showCbjyMagic()

        DlgMgr:closeDlg("HeadTipsDlg")
        return
    end

    local last = DlgMgr:getLastDlgByTabDlg('UserTabDlg') or 'UserDlg'
    DlgMgr:openDlg(last)
end

function HeadDlg:onPetImage()
    local kid = HomeChildMgr:getFightKid()
    if Me:isInCombat() and kid then
        DlgMgr:openDlgEx("KidInfoDlg", {selectId = kid:queryBasic("cid")})
    else
        DlgMgr:openTabDlg("PetTabDlg")
    end
end

function HeadDlg:MSG_UPDATE(data)
    self:updatePlayerInfo()
end

function HeadDlg:MSG_UPDATE_IMPROVEMENT(data)
    self:updatePlayerInfo()
end

function HeadDlg:MSG_UPDATE_PETS()
    self:updatePetInfo()
end

-- 元神共通标记
function HeadDlg:MSG_SET_SETTING(data)
    if data.setting and data.setting.award_supply_pet then
        self:setCtrlVisible("PetChangePanel", data.setting.award_supply_pet >= 1)
        self:updateGongtongPosition()
    end
end

-- 更新共通按钮位置
function HeadDlg:updateGongtongPosition()
    if not self.gongtongOrgY then return end

    if self.followKidPanel:isVisible() or self:getCtrlVisible("PetFollowPanel") then
        if self.gongtongPanel:isVisible() then
            self.gongtongPanel:setPositionY(self.gongtongOrgY - GONG_TONG_Y_MARGIN)
        end
    else
        if self.gongtongPanel:isVisible() then
            self.gongtongPanel:setPositionY(self.gongtongOrgY)
        end
    end
end

-- 获得宠物动画
function HeadDlg:MSG_ICON_CARTOON(data)
    if data.type ~= 2 then return end
    -- 添加宠物则进行动画

    local image = cc.Sprite:create(ResMgr:getSmallPortrait(tonumber(data.param)))
    if not image then
        return
    end

    local size = self:getControl("PetImage"):getContentSize()
    local pos = self:getBoundingBoxInWorldSpace(self:getControl("PetImage"))
    pos.x = pos.x + size.width * 0.5
    pos.y = pos.y + size.height * 0.5

    image:setAnchorPoint(0.5,0.5)
    image:setPosition((Const.WINSIZE.width * 0.5 + image:getContentSize().width * 0.5) / Const.UI_SCALE, (pos.y - 2 * image:getContentSize().height) )
    gf:setItemImageSize(image, true)
    gf:getUILayer():addChild(image)
    self.actNum = self.actNum + 1
    -- 动作效果
    local disAct = cc.CallFunc:create(function()
        self.actNum = self.actNum - 1
        if self.actNum == 0 then
            gf:getUILayer():removeChild(image)
        end
    end)

    local moveRight = cc.EaseSineIn:create(cc.MoveTo:create(0.7, cc.p(pos.x, pos.y)))
    local scale = cc.Spawn:create(cc.FadeOut:create(1.5), cc.ScaleBy:create(1, 0.7))
    local itemAct = cc.Spawn:create(moveRight,scale)
    image:runAction(cc.Sequence:create(cc.DelayTime:create(self.actNum * 0.4), cc.DelayTime:create(0.2), itemAct, disAct))

end

-- uiLayer 移除所有子节点时需要清理一些数据
function HeadDlg:doWhenUiLayerRemoveAllChild()
    self.actNum = 0
end

-- 点击防沉迷图片时打开防沉迷说明界面
function HeadDlg:onPreventFatigueImage()
    DlgMgr:openDlg("PreventFatigueRuleDlg")
end

-- 是否有防沉迷信息需要显示
function HeadDlg:haveAntiaddictionInfoToShow()
    local needShow = false
    local adultStatus = Me:getAdultStatus()
    if Me:isAntiAddictionStartup() then
        -- 开启了防沉迷
        if adultStatus == 2 or adultStatus == 0 then
            -- 未认证或者未成年
            needShow = true
        end
    end

    return needShow
end

-- 更新防沉迷相关信息
function HeadDlg:updateAntiaddictionInfo()
    if not self:haveAntiaddictionInfoToShow() then
        -- 没有防沉迷信息需要显示
        self:setCtrlVisible("PreventFatiguePanel", false)
        DlgMgr:closeDlg("PreventFatigueRuleDlg")
        if self.scheduleId then
            gf:Unschedule(self.scheduleId)
            self.scheduleId = nil
        end
        return
    end

    self:setShowAntiaddictionInfo(true)
    self:updateAntiadditionTime()

    if not self.scheduleId then
        self.scheduleId = gf:Schedule(function()
            self:updateAntiadditionTime()
        end, 2)
    end
end

-- 更新防沉迷剩余时间信息
function HeadDlg:updateAntiadditionTime()
    local leftTime, showZeroTips = Me:getAntiaddictionLeftTime()
    if leftTime < 0 then
        return
    end

    local h = math.floor(leftTime / 3600)

    leftTime = leftTime % 3600
    local m = math.ceil(leftTime / 60)
    if m >= 60 then
        m = m - 60
        h = h + 1
    end

    leftTime = leftTime % 60
    local timeText = string.format("%02d:%02d", h, m)
    if self.lastTimeText == timeText then
        -- 没有变化，直接返回
        return
    end

    local numImg = self:setNumImgForPanel("TimePanel", "swhite_num", timeText, false, LOCATE_POSITION.MID, 25, nil, 0)
    if numImg then
        numImg:setCascadeColorEnabled(true)
    end

    if Me.antiaddictionData["second_enable"] == 1 then
        -- 第二套监管
        local totalTime = Me:getAntiaddictionLimitTime()
        local midH = math.floor(totalTime / 3600 / 2)
        local midM = math.floor((totalTime / 2 % 3600) / 60)
        if h > midH or (h == midH and m >= midM) then
            self:setImage("PreventFatigueImage", ResMgr.ui.prevent_fatigue_0)
            if numImg then
                numImg:setColor(cc.c3b(0xfb, 0xe3, 0x34))
            end
        elseif m > 5 then
            --  02:00 ~ 00:00 期间
            self:setImage("PreventFatigueImage", ResMgr.ui.prevent_fatigue_3)
            if numImg then
                numImg:setColor(cc.c3b(0xff, 0xa5, 0x26))
            end
        else
            -- 设置相应的图片
            self:setImage("PreventFatigueImage", ResMgr.ui.prevent_fatigue_5)
            if numImg then
                numImg:setColor(cc.c3b(0xf2, 0x35, 0x24))
            end
        end
    else
        if timeText > "02:00" then
            self:setImage("PreventFatigueImage", ResMgr.ui.prevent_fatigue_0)
            if numImg then
                numImg:setColor(cc.c3b(0xfb, 0xe3, 0x34))
            end
        elseif timeText <= "02:00" and timeText > "00:00" then
            --  02:00 ~ 00:00 期间
            self:setImage("PreventFatigueImage", ResMgr.ui.prevent_fatigue_3)
            if numImg then
                numImg:setColor(cc.c3b(0xff, 0xa5, 0x26))
            end
        elseif timeText == "00:00" then
            -- 设置相应的图片
            self:setImage("PreventFatigueImage", ResMgr.ui.prevent_fatigue_5)
            if numImg then
                numImg:setColor(cc.c3b(0xf2, 0x35, 0x24))
            end
        end
    end

    self.lastTimeText = timeText

    local adultStatus = Me:getAdultStatus()
    if adultStatus ~= 2 then
        -- 非未认证，直接返回即可
        return
    end

    -- 战斗中不用给提示
    if Me:isInCombat() then
        return
    end

    -- 未认证，看是否需要给予相应的提示
    if Me.antiaddictionData["second_enable"] == 1 then
        -- 第二套监管
        local totalTime = Me:getAntiaddictionLimitTime()
        local midH = math.floor(totalTime / 3600 / 2)
        local midM = math.floor((totalTime / 2 % 3600) / 60)
        if midH == h and midM == m and (leftTime == 0 or leftTime > 55) then
            if LeitingSdkMgr:isLeiting() then
                if Me.antiaddictionData["is_guest"] == 1 then
                    gf:confirm(string.format(CHS[5420332], totalTime / 3600), nil, nil, false, nil, nil, nil, true)
                else
                    gf:confirm(string.format(CHS[5420333], totalTime / 3600), function()
                        DlgMgr:openDlgWithParam("SystemAccManageDlg=AuthenticateRealName")
                    end)
                end
            else
                gf:confirm(string.format(CHS[5420334], totalTime / 3600), nil, nil, false, nil, nil, nil, true)
            end
        end
    else
        if timeText == "02:00" and (leftTime == 0 or leftTime > 55) then
            if LeitingSdkMgr:isLeiting() then
                gf:confirm(CHS[3010008], function()
                    DlgMgr:openDlgWithParam("SystemAccManageDlg=AuthenticateRealName")
                end)
            else
                gf:confirm(CHS[3010009], nil, nil, false, nil, nil, nil, true)
            end
        elseif timeText == "00:00" and showZeroTips then
            if LeitingSdkMgr:isLeiting() then
                gf:confirm(CHS[3010010], function()
                    DlgMgr:openDlgWithParam("SystemAccManageDlg=AuthenticateRealName")
                end)
            else
                gf:confirm(CHS[3010011], nil, nil, false, nil, nil, nil, true)
            end
        end
    end
end

-- 设置是否显示防沉迷信息
-- 如果无防沉迷信息或者在战斗中，则即使 show 为 true 也不显示
function HeadDlg:setShowAntiaddictionInfo(show)
    show = show and self:haveAntiaddictionInfoToShow() and not Me:isInCombat()
    if show then
        self:setCtrlVisible("PreventFatiguePanel", true)
    else
        self:setCtrlVisible("PreventFatiguePanel", false)
        DlgMgr:closeDlg("PreventFatigueRuleDlg")
    end
end

-- 防沉迷数据更新了
function HeadDlg:MSG_UPDATE_ANTIADDICTION_STATUS(data)
    self:updateAntiaddictionInfo()
end

return HeadDlg
