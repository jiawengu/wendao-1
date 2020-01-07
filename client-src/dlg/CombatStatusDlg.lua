-- CombatStatusDlg.lua
-- Created by songcw May/28/2015
-- 战斗状态长按角色。角色状态对话框

local CombatStatusDlg = Singleton("CombatStatusDlg", Dialog)

local OBJ_ME            = 0 --Me 和 参战宠物
local OBJ_FRIEND       = 1 -- 友方
local OBJ_ENEMRY        = 2 -- 敌方

local margin = 6

local STATUS_POISON         = 1     -- 中毒
local STATUS_SLEEP          = 2     -- 昏睡
local STATUS_FORGOTTEN      = 3     -- 遗忘
local STATUS_FROZEN         = 4     -- 冰冻
local STATUS_CONFUSION      = 5     -- 混乱
local STATUS_SPEED_UP       = 13    -- 速度上升
local STATUS_PHY_POWER_UP   = 14    -- 物理伤害上升
local STATUS_DODGE_UP       = 17    -- 躲闪上升
local STATUS_DEF_UP         = 18    -- 防御力上升
local STATUS_RECOVER_LIFE   = 19    -- 气血上升(持续加血)

local STATUS_PASSIVE_ATTACK   = 27  -- 反弹物理攻击(乾坤罩)
local STATUS_DEADLY_KISS      = 28  -- 死亡缠绵特效
local STATUS_LOYALTY          = 29  -- 忠诚度变化(游说之舌)
local STATUS_IMMUNE_PHY_DAMAGE = 30 -- 免疫物理攻击(神龙罩)
local STATUS_IMMUNE_MAG_DAMAGE = 31 -- 免疫魔法攻击(如意圈)
local STATUS_POLAR_CHANGED     = 32 -- 相性改变
local STATUS_FANZHUAN_QIANKUN  = 33 -- 翻转乾坤
local STATUS_MANA_SHIELD       = 34 -- 法力护盾
local STATUS_PASSIVE_MAG_ATTACK= 35 -- 反弹魔法攻击(无色光环)
local STATUS_ADD_LIFE_BY_MANA  = 36 -- 移花接木技能状态
local STATUS_XUWU              = 42  -- 虚无状态
local STATUS_HUANBING_ZHIJI    = 43  -- 缓兵之计
local STATUS_SHUSHOU_JIUQIN    = 44  -- 束手就擒
local STATUS_AITONG_YUJUE      = 45  -- 哀痛欲绝
local STATUS_WENFENG_SANGDAN   = 46  -- 闻风丧胆
local STATUS_YANGJING_XURUI    = 47  -- 养精蓄锐
local STATUS_DIANDAO_QIANKUN   = 48  -- 颠倒乾坤
local STATUS_JINGANGQUAN       = 49  -- 金刚圈
local STATUS_WUJI_BIFAN        = 50  -- 物极必反
local STATUS_TIANYAN           = 51  -- 天眼
local STATUS_CHAOFENG          = 52  -- 嘲讽
local STATUS_QINMI_WUJIAN      = 53  -- 亲密无间
local STATUS_QISHA_YIN          = 54  -- 七杀-阴
local STATUS_QISHA_YANG      = 55  -- 七杀-阳
local STATUS_YANCHUAN_SHENJIAO = 56     -- 言传身教

local STATUS_WEIYA             = 58
local STATUS_DLB_BJ            = 60 -- 地裂波标记

local STATUS_SHOW_OPPONENT_LIFE= 100  -- 火眼金睛

local STATUS_TAB = {
    [STATUS_POISON] =          CHS[3002334],
    [STATUS_SLEEP] =           CHS[3002335],
    [STATUS_FORGOTTEN] =       CHS[3002336],
    [STATUS_FROZEN] =          CHS[3002337],
    [STATUS_CONFUSION] =       CHS[3002338],
    [STATUS_SPEED_UP] =        CHS[3002339],
    [STATUS_PHY_POWER_UP] =    CHS[3002340],
    [STATUS_DODGE_UP] =        CHS[3002341],
    [STATUS_DEF_UP] =          CHS[3002342],
    [STATUS_RECOVER_LIFE] =    CHS[3002343],
    [STATUS_PASSIVE_ATTACK] =  CHS[3002344],
    [STATUS_DEADLY_KISS] =     CHS[3002345],
    [STATUS_LOYALTY] =         CHS[3002346],
    [STATUS_IMMUNE_PHY_DAMAGE] = CHS[3002347],
    [STATUS_IMMUNE_MAG_DAMAGE] =  CHS[3002348],
    [STATUS_POLAR_CHANGED]     =  CHS[3002349], -- 法攻免疫
    [STATUS_FANZHUAN_QIANKUN] =   CHS[3002349], -- 改变相性
    [STATUS_PASSIVE_MAG_ATTACK] = CHS[3002350], -- 法术反弹
    [STATUS_MANA_SHIELD] =        CHS[3002351], -- 法力抵伤
    [STATUS_ADD_LIFE_BY_MANA] =   CHS[3002352], -- 增加气血上限
    [STATUS_XUWU]              =  CHS[7000251],  -- 虚无状态
    [STATUS_HUANBING_ZHIJI]    =  CHS[7000241],  -- 缓兵之计
    [STATUS_SHUSHOU_JIUQIN]    =  CHS[7000242],  -- 束手就擒
    [STATUS_AITONG_YUJUE]      =  CHS[7000244],  -- 哀痛欲绝
    [STATUS_WENFENG_SANGDAN]   =  CHS[7000243],  -- 闻风丧胆
    [STATUS_YANGJING_XURUI]    =  CHS[7000245],  -- 养精蓄锐
    [STATUS_DIANDAO_QIANKUN]   =  CHS[7000307],  -- 颠倒乾坤
    [STATUS_JINGANGQUAN]       =  CHS[7000308],  -- 金刚圈
    [STATUS_CHAOFENG]          =  CHS[7000309],  -- 嘲讽
    [STATUS_SHOW_OPPONENT_LIFE]=  CHS[7002089],  -- 火眼金睛
    [STATUS_QISHA_YIN]        =  CHS[4100964],
    [STATUS_QISHA_YANG]        =  CHS[4100965],
    [STATUS_YANCHUAN_SHENJIAO] = CHS[4101059],
    [STATUS_WEIYA]              = CHS[4010163],
    [STATUS_DLB_BJ]            = CHS[4200551], -- "被阳天君标记为攻击目标",

}

-- 界面显示的属性
local DISPLAY_ATTRIB = {
    {title = CHS[4300287], titleLabel = "LifeLabel", valueLabel = "LifeValueLabel"},
    {title = CHS[4300288], titleLabel = "ManaLabel", valueLabel = "ManaValueLabel"},
    {title = CHS[4300289], titleLabel = "NuQiLabel", valueLabel = "NuQiValueLabel"},
    {title = CHS[4300290], titleLabel = "ZhenfaLabel", valueLabel = "ZhenfaValueLabel"},
}

function CombatStatusDlg:init()

    for i = 1, #DISPLAY_ATTRIB do
        self:setLabelText(DISPLAY_ATTRIB[i].titleLabel, "")
    end

    self:bindListener("SendNotifyButton", self.onSendNotifyButton)

    self.root:setVisible(false)
    -- 克隆
    local statusPanel = self:getControl("OneStatusPanel_1", Const.UIPanel)
    self.statusPanel = statusPanel:clone()
    self.statusPanel:retain()

    self.valuePanelSize = self.valuePanelSize or self:getControl("ValuePanel"):getContentSize()
    self.lifePanelSize = self:getControl("LifePanel"):getContentSize()
    self.rootSize = self.rootSize or self.root:getContentSize()

    self.listSize = self:getControl("StatueListListView"):getContentSize()

    self:setImagePlist("PhaseImage", ResMgr.ui.touming)
    self:hookMsg("MSG_COMBAT_STATUS_INFO")
end

function CombatStatusDlg:cleanup()
    self:releaseCloneCtrl("statusPanel")
end

function CombatStatusDlg:queryInfo(obj, rect)
    if obj == nil then
        self:onCloseButton()
        return
    end
    self.obj = obj
    self.clickRect = rect
    gf:CmdToServer("CMD_GENERAL_NOTIFY", {
        type = NOTIFY.NOTICE_COMBAT_STATUS_INFO,
        para1 = tostring(obj:getId()),
        para2 = tostring(0),
    })
end

function CombatStatusDlg:setAttrib(obj)
    self:setLabelText("NameLabel", obj:getShowName())
end

function CombatStatusDlg:setManaHide()
    self:setLabelText("ManaLabel", "")
    self:setLabelText("ManaValueLabel", "")


    local valuePanel = self:getControl("ValuePanel")
    valuePanel:setContentSize(self.valuePanelSize.width, self.valuePanelSize.height * 0.5)

    self.root:setContentSize(self.rootSize.width, self.rootSize.height - self.valuePanelSize.height * 0.5)
end

function CombatStatusDlg:setAngerHide()
    self:setLabelText("NuQiLabel", "")
    self:setLabelText("NuQiValueLabel", "")


    local valuePanel = self:getControl("ValuePanel")
    valuePanel:setContentSize(self.valuePanelSize.width, self.valuePanelSize.height * 0.5)

    self.root:setContentSize(self.rootSize.width, self.rootSize.height - self.valuePanelSize.height * 0.5)
end

function CombatStatusDlg:setAngerShow(anger)
    self:setLabelText("NuQiValueLabel", anger .. "/100")
end

-- 隐藏震动面板
function CombatStatusDlg:setNotifyHide()
    self:setCtrlVisible("SendNotifyPanel", false)
    local rootSize = self.root:getContentSize()
    -- + 10的原因是，如果没有震动，怕list和root太近，不美观
    self.root:setContentSize(self.rootSize.width, rootSize.height - self:getControl("SendNotifyPanel"):getContentSize().height + 10)
end

-- 若气血值大于10亿，修改显示格式
function CombatStatusDlg:getLifeDesc(life)
    local lifeNum = tonumber(life)
    if lifeNum >= 1000000000 then
        local y = math.floor(lifeNum / 100000000)
        local w = math.floor((lifeNum - y * 100000000)/10000)

        local lifeStr = ""
        lifeStr = lifeStr .. tostring(y) .. CHS[7000075]
        if w ~= 0 then
            lifeStr = lifeStr .. tostring(w) .. CHS[7000076]
        end

        return lifeStr
    end
    return life
end

function CombatStatusDlg:setBasicAttrib(key, value, titleKey, color)
    self:setLabelText(DISPLAY_ATTRIB[titleKey].titleLabel, DISPLAY_ATTRIB[key].title)

    self:setLabelText(DISPLAY_ATTRIB[titleKey].valueLabel, value, nil, color)
end

function CombatStatusDlg:getPolarImagePath(polar)
    if polar == CHS[3004297] or polar == 1 then
        return ResMgr.ui.combatStatusDlg_polar_metal
    elseif polar == CHS[3004298] or polar == 2 then
        return ResMgr.ui.combatStatusDlg_polar_wood
    elseif polar == CHS[3004299] or polar == 3 then
        return ResMgr.ui.combatStatusDlg_polar_water
    elseif polar == CHS[3004300] or polar == 4 then
        return ResMgr.ui.combatStatusDlg_polar_fire
    elseif polar == CHS[3004301] or polar == 5 then
        return ResMgr.ui.combatStatusDlg_polar_earth
    end
end

function CombatStatusDlg:MSG_COMBAT_STATUS_INFO(data)
    if data.objId ~= self.obj:getId() then
        self:onCloseButton()
        return
    end

    -- 显示属性的个数（气血法力...）
    local displayCount = 0

    -- 重置状态
    self.root:setContentSize(self.rootSize)
    self:getControl("ValuePanel"):setContentSize(self.valuePanelSize)
    self:getControl("LifePanel"):setContentSize(self.lifePanelSize)
    Log:D("1. >>>>>> root size width : " .. self.rootSize.width .. ", height : " .. self.rootSize.height)

    local realName = self.obj:getShowName()
    if Me:isLookOn() then
        self:setLabelText("OthorNameLabel", realName)
        self:setLabelText("NameLabel", "")

        displayCount = displayCount + 1
        self:setBasicAttrib(displayCount, CHS[4200191], displayCount)
        self:setNotifyHide()

    elseif self.obj:getType() == "FightPet" or self.obj:getType() == "FightFriend" then

        -- 气血
        displayCount = displayCount + 1
        self:setBasicAttrib(1, self.obj:query("life") .. "/" .. self.obj:query("max_life"), displayCount)

        if self.obj:isGuard() or self.obj:isNpc() or self.obj:isMonster() then
        else
            -- 法力
            displayCount = displayCount + 1
            self:setBasicAttrib(2, self.obj:query("mana") .. "/" .. self.obj:query("max_mana"), displayCount)
        end

        -- 如果是自己，进行特殊处理（断线重连[顶号/切后台]时，自己的最大血/最大蓝以Me:queryInt()为准，
        -- 战斗对象obj不一定是正确的数值， 详见WDSY-20295）
        if Me:getId() == self.obj:getId() then
            self:setBasicAttrib(1, self.obj:query("life") .. "/" .. Me:queryInt("max_life"), displayCount)
            self:setBasicAttrib(2, self.obj:query("mana") .. "/" .. Me:queryInt("max_mana"), displayCount)
        end

        -- 对宠物作同样特殊处理
        if self.obj:getType() == "FightPet" then
            local pet = PetMgr:getPetById(self.obj:getId())
            if pet then
                self:setBasicAttrib(1, self.obj:query("life") .. "/" .. pet:queryInt("max_life"), displayCount)
                self:setBasicAttrib(2, self.obj:query("mana") .. "/" .. pet:queryInt("max_mana"), displayCount)
            end
        end

        -- 怒气
        if self.obj:getType() == "FightPet" then
            if self.obj:queryBasic("pet_anger") ~= "" then
                displayCount = displayCount + 1
                self:setBasicAttrib(3, self.obj:queryInt("pet_anger") .. "/100", displayCount)
            end
        end

        -- 相性
        local polar = gf:getPolar(data.polar)
        local polarPath = self:getPolarImagePath(polar)
        self:setImage("PhaseImage", polarPath)

        self:setLabelText("NameLabel", realName)
        if nil ~= data.level then
            self:setLabelText("NameLabel", realName .. "(" .. data.level .. CHS[3002353])
        end
        self:setLabelText("OthorNameLabel", "")



        if not self.obj:isPlayer() or data.objId == Me:getId() then
            self:setNotifyHide()
        end
    elseif self.obj:getType() == "FightOpponent" then
        self:setLabelText("OthorNameLabel", realName)
        self:setLabelText("NameLabel", "")
        displayCount = displayCount + 1
        if not self.obj.showLife then
            if data.isCanUseHYJJ == 0 then
              --  self:setLabelText("LifeValueLabel", CHS[4300078])   -- 气血无法查看
                self:setBasicAttrib(1, CHS[4300078], displayCount)
            else
              --  self:setLabelText("LifeValueLabel", CHS[4300079], nil, COLOR3.GREEN)    -- 需使用火眼金睛查看
                self:setBasicAttrib(1, CHS[4300079], displayCount, COLOR3.GREEN)
            end
        else
            self:setBasicAttrib(1, self:getLifeDesc(self.obj:query("life")) .. "/" .. self:getLifeDesc(self.obj:query("max_life")), displayCount)
        end

        self:setNotifyHide()
    end

    if FightMgr.glossObjsInfo[self.obj:getId()] then
        if FightMgr.glossObjsInfo[self.obj:getId()].name then
            self:setLabelText("NameLabel", gf:getRealName(FightMgr.glossObjsInfo[self.obj:getId()].name))
        end

		if nil ~= data.level then
		    if FightMgr.glossObjsInfo[self.obj:getId()].name then
                self:setLabelText("NameLabel", gf:getRealName(FightMgr.glossObjsInfo[self.obj:getId()].name) .. "(" .. data.level .. CHS[3002353])
            end
        end

        if FightMgr.glossObjsInfo[self.obj:getId()].life and FightMgr.glossObjsInfo[self.obj:getId()].max_life then
            displayCount = math.max(displayCount, 1)
            self:setBasicAttrib(1, FightMgr.glossObjsInfo[self.obj:getId()].life .. "/" .. FightMgr.glossObjsInfo[self.obj:getId()].max_life, displayCount)
        end

        if FightMgr.glossObjsInfo[self.obj:getId()].mana and FightMgr.glossObjsInfo[self.obj:getId()].max_mana then
            displayCount = math.max(displayCount, 2)
            self:setBasicAttrib(2, FightMgr.glossObjsInfo[self.obj:getId()].mana .. "/" .. FightMgr.glossObjsInfo[self.obj:getId()].max_mana, displayCount)
        end
    end
    local statusTab = {}


    -- 火眼金睛特殊处理：火眼金睛没有状态字段，仅有动态字段status_show_opponent_life记录持续回合数
    if data.status_show_opponent_life then
        local statusType = STATUS_SHOW_OPPONENT_LIFE
        local keepRoundStr
        local keep = data.status_show_opponent_life
        if keep > 20 then
            keepRoundStr = string.format(CHS[3002357], CHS[3002358])
        else
            keepRoundStr = string.format(CHS[3002359], keep)
        end

        local str
        if Me:isLookOn() then
            -- 观战不显示火眼金睛回合数
            str = STATUS_TAB[statusType]
        else
            str = STATUS_TAB[statusType] .. keepRoundStr
    end
        table.insert(statusTab, {statusType = statusType, str = str})
    end

    if data.zhenfaPolar ~= 0 then
        displayCount = displayCount + 1
        local zhenfa = string.format(CHS[4300285], gf:getPolar(data.zhenfaPolar))
        self:setBasicAttrib(4, zhenfa, displayCount)
    end

    -- 基本属性自适应 （气血、法力等）
    local missCount = 4 - displayCount
    self:setCtrlContentSize("ValuePanel", nil, self.valuePanelSize.height - missCount * (25 + 10))   -- 25:单位高度，10间隔
    local rootSize = self.root:getContentSize()
    self.root:setContentSize(rootSize.width, rootSize.height - missCount * (25 + 10))   -- 25:单位高度，10间隔


    if DlgMgr:sendMsg("FightInfDlg", "isPlayFight") then
        statusTab = self:addStatus(statusTab, STATUS_FORGOTTEN, data)
        statusTab = self:addStatus(statusTab, STATUS_PHY_POWER_UP, data)
        statusTab = self:addStatus(statusTab, STATUS_POISON, data)
        statusTab = self:addStatus(statusTab, STATUS_RECOVER_LIFE, data)
        statusTab = self:addStatus(statusTab, STATUS_FROZEN, data)
        statusTab = self:addStatus(statusTab, STATUS_DEF_UP, data)
        statusTab = self:addStatus(statusTab, STATUS_SLEEP, data)
        statusTab = self:addStatus(statusTab, STATUS_SPEED_UP, data)
        statusTab = self:addStatus(statusTab, STATUS_CONFUSION, data)
        statusTab = self:addStatus(statusTab, STATUS_DODGE_UP, data)
        statusTab = self:addStatus(statusTab, STATUS_POLAR_CHANGED, data)
        statusTab = self:addStatus(statusTab, STATUS_FANZHUAN_QIANKUN, data)
        statusTab = self:addStatus(statusTab, STATUS_DEADLY_KISS, data)
        statusTab = self:addStatus(statusTab, STATUS_LOYALTY, data)
        statusTab = self:addStatus(statusTab, STATUS_PASSIVE_ATTACK, data)
        statusTab = self:addStatus(statusTab, STATUS_IMMUNE_PHY_DAMAGE, data)
        statusTab = self:addStatus(statusTab, STATUS_IMMUNE_MAG_DAMAGE, data)
        statusTab = self:addStatus(statusTab, STATUS_MANA_SHIELD, data)
        statusTab = self:addStatus(statusTab, STATUS_ADD_LIFE_BY_MANA, data)
        statusTab = self:addStatus(statusTab, STATUS_PASSIVE_MAG_ATTACK, data)
        statusTab = self:addStatus(statusTab, STATUS_XUWU, data)
        statusTab = self:addStatus(statusTab, STATUS_HUANBING_ZHIJI, data)
        statusTab = self:addStatus(statusTab, STATUS_SHUSHOU_JIUQIN, data)
        statusTab = self:addStatus(statusTab, STATUS_AITONG_YUJUE, data)
        statusTab = self:addStatus(statusTab, STATUS_WENFENG_SANGDAN, data)
        statusTab = self:addStatus(statusTab, STATUS_YANGJING_XURUI, data)
        statusTab = self:addStatus(statusTab, STATUS_DIANDAO_QIANKUN, data)
        statusTab = self:addStatus(statusTab, STATUS_JINGANGQUAN, data)
        statusTab = self:addStatus(statusTab, STATUS_CHAOFENG, data)
        statusTab = self:addStatus(statusTab, STATUS_QISHA_YIN, data)
        statusTab = self:addStatus(statusTab, STATUS_QISHA_YANG, data)
        statusTab = self:addStatus(statusTab, STATUS_YANCHUAN_SHENJIAO, data)
        statusTab = self:addStatus(statusTab, STATUS_WEIYA, data)
        statusTab = self:addStatus(statusTab, STATUS_DLB_BJ, data)


    else
        statusTab = self:addStatusBefore(statusTab, STATUS_FORGOTTEN, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_PHY_POWER_UP, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_POISON, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_RECOVER_LIFE, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_FROZEN, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_DEF_UP, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_SLEEP, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_SPEED_UP, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_CONFUSION, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_DODGE_UP, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_POLAR_CHANGED, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_FANZHUAN_QIANKUN, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_DEADLY_KISS, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_LOYALTY, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_PASSIVE_ATTACK, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_IMMUNE_PHY_DAMAGE, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_IMMUNE_MAG_DAMAGE, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_MANA_SHIELD, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_ADD_LIFE_BY_MANA, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_PASSIVE_MAG_ATTACK, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_XUWU, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_HUANBING_ZHIJI, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_SHUSHOU_JIUQIN, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_AITONG_YUJUE, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_WENFENG_SANGDAN, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_YANGJING_XURUI, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_DIANDAO_QIANKUN, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_JINGANGQUAN, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_CHAOFENG, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_QISHA_YIN, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_QISHA_YANG, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_YANCHUAN_SHENJIAO, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_WEIYA, data)
        statusTab = self:addStatusBefore(statusTab, STATUS_DLB_BJ, data)

    end

    self:displayStatus(statusTab)
end

function CombatStatusDlg:getKeepRound(field)
    local keep = field or 0
    if keep > 20 then
        return string.format(CHS[3002357], CHS[3002358])
    else
        return string.format(CHS[3002359], keep)
    end
end

function CombatStatusDlg:getKeepRoundSpecial(field, value)
    if field == "status_weiya_count" then
        return string.format(CHS[4010162], value)
    end

    return ""
end

function CombatStatusDlg:getKeepRoundAdd(field, add)
    local keep = field or 0
    local add_value = add or 0
    if keep > 20 then
        return string.format(CHS[6000577], add_value, CHS[3002358])
    else
        return string.format(CHS[6000578], add_value, keep)
    end
end

function CombatStatusDlg:getKeepRoundAddForDef(field, add1, add2)
    local keep = field or 0
    local add_value1 = add1 or 0
    local add_value2 = add2 or 0
    if keep > 20 then
        return string.format(CHS[4300342], add_value1, add_value2, CHS[3002358])
    else
        return string.format(CHS[4300343], add_value1, add_value2, keep)
    end
end

function CombatStatusDlg:getKeepRoundAdd2(field, add1, add2)
    local keep = field or 0
    local add_value1 = add1 or 0
    local add_value2 = add2 or 0
    if keep > 20 then
        return string.format(CHS[6000579], add_value1, add_value2, CHS[3002358])
    else
        return string.format(CHS[6000580], add_value1, add_value2, keep)
    end
end

function CombatStatusDlg:checkStatus(statusType, data)
    local keepRoundStr = ""
    local curRound = FightMgr:getCurRound()
    if statusType == STATUS_PHY_POWER_UP then
        -- 攻
        keepRoundStr = self:getKeepRoundAdd2(data.status_phy_power, data.status_phy_power_add, data.status_mag_power_add)
    elseif statusType == STATUS_RECOVER_LIFE then
        -- 心
        keepRoundStr = self:getKeepRoundAdd(data.status_recover_life, data.status_recover_life_add)
    elseif statusType == STATUS_DEF_UP then
        -- 防
        keepRoundStr = self:getKeepRoundAddForDef(data.status_def, data.status_def_add, data.status_all_resist_except_add)
    elseif statusType == STATUS_SPEED_UP then
        -- 速
        keepRoundStr = self:getKeepRoundAdd(data.status_speed, data.status_speed_add)
    elseif statusType == STATUS_DODGE_UP then
        -- 闪
        keepRoundStr = self:getKeepRound(data.status_dodge)
    elseif statusType == STATUS_POLAR_CHANGED then
        --
        keepRoundStr = self:getKeepRound(data.status_polar_changed)
    elseif statusType == STATUS_FANZHUAN_QIANKUN then
        -- 翻转乾坤
        keepRoundStr = self:getKeepRound(data.status_fanzhuan_qiankun)
    elseif statusType == STATUS_PASSIVE_ATTACK then
        -- 乾坤罩
        keepRoundStr = self:getKeepRound(data.status_passive_attack)
    elseif statusType == STATUS_IMMUNE_PHY_DAMAGE then
        -- 神龙罩
        keepRoundStr = self:getKeepRound(data.status_immune_phy_damage)
    elseif statusType == STATUS_IMMUNE_MAG_DAMAGE then
        -- 如意圈
        keepRoundStr = self:getKeepRound(data.status_immune_mag_damage)
    elseif statusType == STATUS_MANA_SHIELD then
        -- 法力护盾
        keepRoundStr = self:getKeepRound(data.status_mana_shield)
    elseif statusType == STATUS_ADD_LIFE_BY_MANA then
        -- 移花接木
        keepRoundStr = self:getKeepRoundAdd(data.status_add_life_by_mana, data.status_add_life_by_mana_add)
    elseif statusType == STATUS_PASSIVE_MAG_ATTACK then
        -- 五色光华
        keepRoundStr = self:getKeepRound(data.status_passive_mag_attack)
    elseif statusType == STATUS_XUWU then
        -- 虚无状态
        keepRoundStr = self:getKeepRound(data.status_xuwu)
    elseif statusType == STATUS_DIANDAO_QIANKUN then
        -- 颠倒乾坤
        keepRoundStr = self:getKeepRound(data.status_diandao_qiankun)
    elseif statusType == STATUS_JINGANGQUAN then
        -- 金刚圈
        keepRoundStr = self:getKeepRound(data.status_jingangquan)
    elseif statusType == STATUS_CHAOFENG then
        -- 嘲讽
        keepRoundStr = self:getKeepRound(data.status_chaofeng)
    elseif statusType == STATUS_QISHA_YIN then
        keepRoundStr = self:getKeepRound(data.status_qisha_yin)
    elseif statusType == STATUS_QISHA_YANG then
        keepRoundStr = self:getKeepRound(data.status_qisha_yang)
    elseif statusType == STATUS_YANCHUAN_SHENJIAO then
        keepRoundStr = self:getKeepRound(data.status_yanchuan_shenjiao)
    elseif statusType == STATUS_WEIYA then
        keepRoundStr = self:getKeepRoundSpecial("status_weiya_count", data.status_weiya_count)
    end

    return keepRoundStr
end

function CombatStatusDlg:addStatusBefore(statusTab, statusType, data)
    local meObj = FightMgr:getObjectById(self.obj:getId())
    if meObj.status:isSet(tonumber(statusType) + 1) then
        local desc
        local keepRoundStr = ""

        if not Me:isLookOn() and (self.obj:getType() == "FightFriend" or self.obj:getType() == "FightPet") then
            keepRoundStr = self:checkStatus(statusType, data)

            -- 加攻击状态特殊显示
            if statusType == STATUS_PHY_POWER_UP then
                desc = CHS[6000581] .. keepRoundStr
            else
                desc = STATUS_TAB[statusType] .. keepRoundStr
            end
        else
            desc = STATUS_TAB[statusType] .. keepRoundStr

        end

        table.insert(statusTab, {statusType = statusType, str = desc })
    end
    return statusTab
end

function CombatStatusDlg:addStatus(statusTab, statusType, data)
    local meObj = FightMgr:getObjectById(self.obj:getId())
    if meObj:isSetStatus(tonumber(statusType)) then
        local desc
        local keepRoundStr = ""

        if not Me:isLookOn() and (self.obj:getType() == "FightFriend" or self.obj:getType() == "FightPet") then
            keepRoundStr = self:checkStatus(statusType, data)

            -- 加攻击状态特殊显示
            if statusType == STATUS_PHY_POWER_UP then
                desc = CHS[6000581] .. keepRoundStr
            else
                desc = STATUS_TAB[statusType] .. keepRoundStr
            end
        else
            if statusType == STATUS_DEF_UP then
                -- 水的防御，还要加上抗障碍说明
                desc = STATUS_TAB[statusType] .. CHS[4300344] .. keepRoundStr
            else
                desc = STATUS_TAB[statusType] .. keepRoundStr
            end
        end

        table.insert(statusTab, {statusType = statusType, str = desc})
    end
    return statusTab
end

function CombatStatusDlg:displayStatus(statusTab)
    local file = ResMgr:getBuffIconPath()
    cc.SpriteFrameCache:getInstance():addSpriteFrames(file .. ".plist")
    local list = self:resetListView("StatueListListView", margin)
    local listSize = self.listSize
    local size = self.statusPanel:getContentSize()
    local count = #statusTab
    for i = 1, count do
        local panel = self.statusPanel:clone()
        local statusImage = self:getControl("StatusImage", Const.UIImage, panel)
        statusImage:loadTexture(ResMgr:getFightStatus(statusTab[i].statusType), ccui.TextureResType.plistType)
        self:setLabelText("DesLabel", statusTab[i].str, panel)
        list:pushBackCustomItem(panel)
    end

    if count < 3 then
        list:setContentSize(listSize.width, (size.height + margin) * count)
        local rootSize = self.root:getContentSize()
        local size = self:getCtrlContentSize("ValuePanel")
        self.root:setContentSize(rootSize.width, rootSize.height - (self.listSize.height - list:getContentSize().height))
    end
    self.root:setVisible(true)

    if self.clickRect then
        if not FightCommanderCmdMgr:checkCanShowCommanderDlg(self.obj) then
            -- 长按打开状态悬浮框时，若不需要显示战斗指挥界面，则当前界面位置跟随clickRect
            self:setFloatingFramePos(self.clickRect)
        end
    end
end

function CombatStatusDlg:onSendNotifyButton()
    VibrateMgr:sendVibrate("combat", self.obj:getId())
end

function CombatStatusDlg:onCloseButton()
    DlgMgr:closeDlg(self.name)
    DlgMgr:closeDlg("FightCommanderSetDlg")
end

return CombatStatusDlg
