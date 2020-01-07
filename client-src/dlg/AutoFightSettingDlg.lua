-- AutoFightSettingDlg.lua
-- Created by zhengjh   Apr/24/2015
-- 自动战斗设置

local DEFENCE_NO = 9167
local PHYATTACT_NO = 9166
local LIFE_NO   = 9169
local MANA_NO   = 9170
local PHYSIC_CONFIG =
{
    [DEFENCE_NO] = CHS[3002291],
    [PHYATTACT_NO] = CHS[3002292],
    [LIFE_NO] = CHS[3002293],
    [MANA_NO] = CHS[3002294],
}

local AutoFightSettingDlg = Singleton("AutoFightSettingDlg", Dialog)

function AutoFightSettingDlg:init()
    -- self:bindListener("AutoFightSettingButton", self.onAutoFightSettingButton)
    self:bindListener("PetSkillButton", self.onPetSkillButton)
    self:bindListener("PlayerSkillButton", self.onPlayerSkillButton)
    self:bindListener("CancelButton", self.onCancelButton)

    self:setSecondSkillVisible(false)

    self:hookMsg("MSG_GENERAL_NOTIFY")
    self:hookMsg("MSG_AUTO_FIGHT_SKILL")

    -- 刷新宠物菜单类型
    self:refreshMenu()

    if not AutoFightMgr:getMeActionTag() and not AutoFightMgr:isOpenZuheSkill("Me") then

        AutoFightMgr:setDefaultAction("Me")
    end

    if not AutoFightMgr:getPetActionTag() and not AutoFightMgr:isOpenZuheSkill("Pet") then
        AutoFightMgr:setDefaultAction("Pet")
    end

    self.isInit = false
    performWithDelay(self.root, function()
        -- 初始化界面时，可能宠物对象未创建完成，导致宠物技能不显示，故延迟刷新
        self.isInit = true
        self:refreshAllData()
    end, 0)

    self:setFullScreen()
end

function AutoFightSettingDlg:cleanup()
    DlgMgr:closeDlg("AutoFightDlg")
end

function AutoFightSettingDlg:refreshAllData(meSkillNo, petSkillNo)
    meSkillNo = meSkillNo or AutoFightMgr:getMeActionTag()
    self:initSelceltedPanel(meSkillNo, "me")

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet and FightMgr:getObjectById(pet:getId()) then
        petSkillNo = petSkillNo or AutoFightMgr:getPetActionTag()
        self:initSelceltedPanel(petSkillNo, "pet")
    end

    self:refreshMenu()
end

function AutoFightSettingDlg:refreshMenu()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    local button = self:getControl("PetSkillButton", Const.UIButton)
    if pet and FightMgr:getObjectById(pet:getId()) then
        button:setTouchEnabled(true)
        self:setCtrlVisible("SkillImage", true, "PetSkillButton")
    else
        button:setTouchEnabled(false)
        self:getControl("PetSkillButton", Const.UIPanel):setVisible(true)
        self:setCtrlVisible("SkillImage", false, "PetSkillButton")
    end

    -- 底图类型：娃娃、宠物
    if HomeChildMgr:getFightKid() and FightMgr:getObjectById(HomeChildMgr:getFightKid():getId()) then
        self:setImage("TextImage", ResMgr.ui.auto_fight_kid_text, "PetSkillButton")
    elseif PetMgr:getFightPet() and FightMgr:getObjectById(PetMgr:getFightPet():getId()) then
        self:setImagePlist("TextImage", ResMgr.ui.auto_fight_pet_text, "PetSkillButton")
    end
end

function AutoFightSettingDlg:onCancelButton()
    Me:setBasic('auto_fight', 0)
    AutoFightMgr:autoFightSiwchStatus(0)
    DlgMgr:closeDlg(self.name)

    local dlg = DlgMgr:openDlg('FightPlayerMenuDlg')
    if dlg then
        dlg:updateFastSkillButton()
    end

    if Me:queryBasicInt('c_enable_input') == 1 then
        FightMgr:showSelectImg(true)
        dlg:showOnlyAutoFightButton(false)
    else
        dlg:showOnlyAutoFightButton(true)
    end
end

function AutoFightSettingDlg:onPlayerSkillPanel(sender, eventType)
    local dlg = DlgMgr:openDlg("AutoFightDlg")
    if dlg then
        dlg:initSkill("me")
        dlg:setCallBcak(self, self.initSelceltedPanel)
    end
end

function AutoFightSettingDlg:onPetSkillPanel()
    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    local objType = "pet"
    if HomeChildMgr:getFightKid() then
        objType = "kid"
    end

    if not pet then
        -- 无参战宠物，直接返回即可
        return
    end

    local dlg = DlgMgr:openDlg("AutoFightDlg")
    if dlg then
        dlg:initSkill(objType)
        dlg:setCallBcak(self, self.initSelceltedPanel)
    end
end

function AutoFightSettingDlg:setSecondSkillVisible(isVisible)
    self:setCtrlVisible("ChildPanel", false, "PlayerSkillButton")
    self:setCtrlVisible("ChildPanel", false, "PetSkillButton")

    self:removeNumImgForPanel("SkillImage", LOCATE_POSITION.RIGHT_BOTTOM, "PlayerSkillButton")
end

function AutoFightSettingDlg:initSelceltedPanel(skillNo, name)
    if nil == skillNo then return end

	-- 如果为TABLE 格式，S设置组合技能时回调，不做处理，等服务器下发组合技能消息刷新
    if "table" == type(skillNo) then return end
    local image, path

    local function OneSecondLaterFunc(sender, eventType, type)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        if not PHYSIC_CONFIG[skillNo] then
            if name == "me" then
                SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), Me:getId(), false, rect, type)
            elseif name == "pet" then
                local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
                if pet then
                    SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), pet:getId(), true, rect, type)
                end
            end
        else
            local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
            dlg:setSKillByName(PHYSIC_CONFIG[skillNo] , rect)
        end
    end

    if name == "me" then
        image = self:getControl("SkillImage", Const.UIImage, "PlayerSkillButton")
        local mySkill = SkillMgr:getSkill(Me:getId(), skillNo)

        -- 重置法宝特殊技能图标状态
        SkillMgr:removeArtifactSpSkillImage(image)
        if mySkill then
            if mySkill.skill_mana_cost > Me:queryInt("mana") then
                self:blindLongPress("PlayerSkillButton",
                    function(dlg, sender, eventType)
                        OneSecondLaterFunc(sender, eventType, 2)
                    end, self.onPlayerSkillPanel)
            else
                self:blindLongPress("PlayerSkillButton",
                    function(dlg, sender, eventType)
                        OneSecondLaterFunc(sender, eventType, nil)
                    end, self.onPlayerSkillPanel)
            end

            -- 法宝特殊技能标识
            if SkillMgr:isArtifactSpSkill(mySkill.skill_name) then
                self:addArtifactSpSkillImage(image)
            end
        else
            self:blindLongPress("PlayerSkillButton",
                function(dlg, sender, eventType)
                    OneSecondLaterFunc(sender, eventType, nil)
                end, self.onPlayerSkillPanel)
        end
        -- self:blindLongPress("PlayerSkillButton", OneSecondLaterFunc, self.onPlayerSkillPanel)
        self.playerSkillNo = skillNo
    elseif name == "pet" then
        self:getControl("PetSkillButton", Const.UIPanel):setVisible(true)
        image = self:getControl("SkillImage", Const.UIImage, "PetSkillButton")

        -- 重置顿悟技能/法宝特殊技能图标状态
        SkillMgr:removeDunWuSkillImage(image)
        SkillMgr:removeArtifactSpSkillImage(image)

        self:setCtrlVisible("SkillImage", true, "PetSkillButton")

        local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
        local mySkill = SkillMgr:getSkill(pet:getId(), skillNo)
        if pet and mySkill then
            if mySkill.skill_mana_cost > pet:queryInt("mana")
                 or not SkillMgr:isPetDunWuSkillCanUse(pet:getId(), mySkill) then
                -- 普通技能缺少魔法，或者顿悟技能缺少怒气/魔法/灵气
                self:blindLongPress("PetSkillButton",
                    function(dlg, sender, eventType)
                        OneSecondLaterFunc(sender, eventType, 2)
                    end, self.onPetSkillPanel)
            else
                self:blindLongPress("PetSkillButton",
                    function(dlg, sender, eventType)
                        OneSecondLaterFunc(sender, eventType, nil)
                    end, self.onPetSkillPanel)
            end

            -- 顿悟技能标识
            if SkillMgr:isPetDunWuSkill(pet:getId(), mySkill.skill_name) then
                self:addDunWuSkillImage(image)
            end

            -- 法宝特殊技能标识
            if SkillMgr:isArtifactSpSkill(mySkill.skill_name) then
                self:addArtifactSpSkillImage(image)
            end
        else
            self:blindLongPress("PetSkillButton",
                function(dlg, sender, eventType)
                    OneSecondLaterFunc(sender, eventType, nil)
                end, self.onPetSkillPanel)
        end
        -- self:blindLongPress("PetSkillButton", OneSecondLaterFunc, self.onPetSkillPanel)
        self.petSkillNo = skillNo
    end

    -- 找不到对象，可能已经关闭了
    if not image then return end

    if PHYSIC_CONFIG[skillNo] then
        path = ResMgr:getSkillIconPath(skillNo)
    else
        path = SkillMgr:getSkillIconPath(skillNo)
    end

    if nil ~= path then
        image:loadTexture(path)
        self:setItemImageSize("SkillImage", "PetSkillButton")
    end

    self:refreshManaImage()
end

-- 不用SkillMgr:addArtifactSpSkillImage(ctr)原因是，它默认都在右边
-- 组合技能加上后，需求在左边
function AutoFightSettingDlg:addArtifactSpSkillImage(ctr)
    local sp = ctr:getChildByName("artifactSpSkillLogo")
    if sp then return end

    local path = ResMgr.ui.artifact_special_skill_mark
    local sp = ccui.ImageView:create()
    sp:loadTexture(path, ccui.TextureResType.plistType)
    gf:setSkillFlagImageSize(sp)

    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(spSize.width * 0.5, size.height - spSize.height * 0.5)
    sp:setName("artifactSpSkillLogo")
    ctr:addChild(sp)
end

-- 同上
function AutoFightSettingDlg:addDunWuSkillImage(ctr)
    local sp = ctr:getChildByName("dunWuLogo")
    if sp then return end

    local path = ResMgr.ui.dunWu_skill_mark
    local sp = ccui.ImageView:create()
    sp:loadTexture(path, ccui.TextureResType.plistType)
    gf:setSkillFlagImageSize(sp)

    local size = ctr:getContentSize()
    local spSize = sp:getContentSize()
    sp:setPosition(spSize.width * 0.5, size.height - spSize.height * 0.5)
    sp:setName("dunWuLogo")
    ctr:addChild(sp)
end

function AutoFightSettingDlg:refreshManaImage()

    local function OneSecondLaterFunc(sender, eventType, type, skillNo, id, isPet)
        local rect = self:getBoundingBoxInWorldSpace(sender)
        if not PHYSIC_CONFIG[skillNo] then
            SkillMgr:showSkillDescDlg(SkillMgr:getSkillName(skillNo), id,  isPet, rect, type)
        else
            local dlg = DlgMgr:openDlg("SkillFloatingFrameDlg")
            dlg:setSKillByName(PHYSIC_CONFIG[skillNo] , rect)
        end
    end

    if self.playerSkillNo and not PHYSIC_CONFIG[self.playerSkillNo] then -- 刷新人物技能是否缺蓝图标
        local skillInfo = SkillMgr:getSkill(Me:getId(), self.playerSkillNo)
        if skillInfo and
                ((skillInfo.skill_mana_cost or 0 ) > Me:queryInt("mana") or
                -- 一般技能无法使用（缺蓝）
                not SkillMgr:isArtifactSpSkillCanUse(skillInfo.skill_name) or
                -- 法宝特殊技能无法使用（缺少法宝灵气）
                (SkillMgr:isQinMiWuJianCopySkill(skillInfo.skill_name, Me:getId()) and not SkillMgr:isArtifactSpSkillCanUse(CHS[3001947]))) then
                -- 亲密无间复制的宠物技能无法使用（缺少法宝灵气）
            self:setCtrlVisible("NoManaImage", true, "PlayerSkillButton")
            self:blindLongPress("PlayerSkillButton",
                function(dlg, sender, eventType)
                    OneSecondLaterFunc(sender, eventType, 2, self.playerSkillNo, Me:getId(), false)
                end, self.onPlayerSkillPanel)
        else
            self:setCtrlVisible("NoManaImage", false, "PlayerSkillButton")
            self:blindLongPress("PlayerSkillButton",
                function(dlg, sender, eventType)
                    OneSecondLaterFunc(sender, eventType, nil, self.playerSkillNo, Me:getId(), false)
                end, self.onPlayerSkillPanel)
        end
    else
        self:setCtrlVisible("NoManaImage", false, "PlayerSkillButton")
        self:blindLongPress("PlayerSkillButton",
            function(dlg, sender, eventType)
                OneSecondLaterFunc(sender, eventType, nil, self.playerSkillNo, Me:getId(), false)
            end, self.onPlayerSkillPanel)
    end

    local pet = HomeChildMgr:getFightKid() or PetMgr:getFightPet()
    if pet and FightMgr:getObjectById(pet:getId()) and self.petSkillNo and not PHYSIC_CONFIG[self.petSkillNo] then
        local skillInfo = SkillMgr:getSkill(pet:getId(), self.petSkillNo)
        if skillInfo and ((skillInfo.skill_mana_cost or 0 ) > pet:queryInt("mana")
                           or not SkillMgr:isPetDunWuSkillCanUse(pet:getId(), skillInfo)
                           or not SkillMgr:isArtifactSpSkillCanUse(skillInfo.skill_name)) then
            -- 普通技能缺少魔法，或者顿悟技能缺少怒气/魔法/灵气，法宝特殊技能缺少灵气
            self:setCtrlVisible("NoManaImage", true, "PetSkillButton")
            self:blindLongPress("PetSkillButton",
                function(dlg, sender, eventType)
                    OneSecondLaterFunc(sender, eventType, 2, self.petSkillNo, pet:getId(), true)
                end, self.onPetSkillPanel)
        else
            self:setCtrlVisible("NoManaImage", false, "PetSkillButton")
            self:blindLongPress("PetSkillButton",
                function(dlg, sender, eventType)
                    OneSecondLaterFunc(sender, eventType, nil, self.petSkillNo, pet:getId(), true)
                end, self.onPetSkillPanel)
        end
    else
        self:setCtrlVisible("NoManaImage", false, "PetSkillButton")
        self:blindLongPress("PetSkillButton",
            function(dlg, sender, eventType)
                OneSecondLaterFunc(sender, eventType, nil, self.petSkillNo, pet:getId(), true)
            end, self.onPetSkillPanel)
    end
end

function AutoFightSettingDlg:MSG_GENERAL_NOTIFY(data)
    if NOTIFY.NOTIFY_AUTO_FIGHT_SKILL == data.notify  then
        local paraList = gf:split(data.para, "_")
        if paraList[1] ~= "-1" then -- 人物操作动作
            local actionTag = DEFENCE_NO
            if tonumber(paraList[1]) == 0 then
                actionTag = DEFENCE_NO
            elseif tonumber(paraList[1]) == 2 then
                actionTag = PHYATTACT_NO
            else
                actionTag = tonumber(paraList[1])
            end

            AutoFightMgr:setLastMeAction(actionTag)
        else
            AutoFightMgr:setMeDefaultAction()
        end

        if paraList[2] ~= "-1" then -- 宠物操作动作
            local actionTag = DEFENCE_NO
            if tonumber(paraList[2]) == 0 then
                actionTag = DEFENCE_NO
            elseif tonumber(paraList[2]) == 2 then
                actionTag = PHYATTACT_NO
            else
                actionTag = tonumber(paraList[2])
            end

            AutoFightMgr:setLastPetAction(actionTag)
        else
            AutoFightMgr:setPetDefualtAction()
        end

        if paraList[1] ~= "-1" or  paraList[2] ~= "-1" then
            self:refreshAllData()
        end
    end
end

function AutoFightSettingDlg:MSG_AUTO_FIGHT_SKILL(data)
    -- 由于初始化时有  -- 初始化界面时，可能宠物对象未创建完成，导致宠物技能不显示，故延迟刷新
    -- 所以若收到消息时，还没有刷新，强制刷新
    if not self.isInit then
        self.root:stopAllActions()
    end

    -- 可见度设置
    self:setCtrlVisible("ChildPanel", data.user_is_multi == 1, "PlayerSkillButton")
    self:setCtrlVisible("ChildPanel", data.pet_is_multi == 1, "PetSkillButton")

    -- 如果角色时组合技能，设置组合技能
    local no
    local panel = self:getControl("ChildPanel", nil, "PlayerSkillButton")
    if data.user_is_multi == 1 then
        no = AutoFightMgr:getSkillNoByData({para = data.user_para, action = data.user_action})

        -- 下一个
        local nextNo = AutoFightMgr:getSkillNoByData({para = data.user_next_para, action = data.user_next_action})
        local path
        if PHYSIC_CONFIG[nextNo] then
            path = ResMgr:getSkillIconPath(nextNo)
        else
            path = SkillMgr:getSkillIconPath(nextNo)
        end

        if not path or path == "" then
            self:setCtrlVisible("SkillImage", false, panel)
        else
            self:setCtrlVisible("SkillImage", true, panel)
            self:setImage("SkillImage", path, panel)
        end

        -- 次数
        self:setNumImgForPanel("SkillImage", ART_FONT_COLOR.NORMAL_TEXT, data.user_round, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "PlayerSkillButton")
    else
        self:removeNumImgForPanel("SkillImage", LOCATE_POSITION.RIGHT_BOTTOM, "PlayerSkillButton")
    end

    -- 如果宠物是组合技能，设置组合技能相关
    local petNo
    local panel = self:getControl("ChildPanel", nil, "PetSkillButton")
    if data.pet_is_multi == 1 then
        petNo = AutoFightMgr:getSkillNoByData({para = data.pet_para, action = data.pet_action})

        -- 下一个
        local nextNo = AutoFightMgr:getSkillNoByData({para = data.pet_next_para, action = data.pet_next_action})
        local path
        if PHYSIC_CONFIG[nextNo] then
            path = ResMgr:getSkillIconPath(nextNo)
        else
            path = SkillMgr:getSkillIconPath(nextNo)
        end
        local panel = self:getControl("ChildPanel", nil, "PetSkillButton")
        if not path or path == "" then
            self:setCtrlVisible("SkillImage", false, panel)
        else
            self:setCtrlVisible("SkillImage", true, panel)
            self:setImage("SkillImage", path, panel)
        end

        -- 次数
        self:setNumImgForPanel("SkillImage", ART_FONT_COLOR.NORMAL_TEXT, data.pet_round, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "PetSkillButton")
    else
        self:removeNumImgForPanel("SkillImage", LOCATE_POSITION.RIGHT_BOTTOM, "PetSkillButton")
    end

    self:refreshAllData(no, petNo)
end

return AutoFightSettingDlg
