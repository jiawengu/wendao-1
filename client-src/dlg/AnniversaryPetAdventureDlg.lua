-- AnniversaryPetAdventureDlg.lua
-- Created by songcw Nove/21/2018
-- 周年庆之秘境探险

local AnniversaryPetAdventureDlg = Singleton("AnniversaryPetAdventureDlg", Dialog)

local WALL_COUNT = 5
local ROCK_LEN          -- 初始化根据对应控件赋值
local FLOAT_TIME = 1
local FLOAT_LEN = 6

local PRODUCE_TYPE =
{
    exp = "exp",
    tao = "tao",
}

local ROCK_STATE = {
    CAN_CLICK   = 0,    -- 格子未被点击过
    HAS_CLICK   = 1,    -- 格子已经点击过（使用过、敲碎过...）
}

local ROCK_TYPE = {
    BLANK   = 0,    -- 墙
    ITEM    = 1,    -- 道具
    MONSTER = 2,    -- 怪物
    BAOXIANG = 6,   -- 宝箱
    TONGDAO = 7,    -- 通道
    NONE = 10,
}

local ITEM_ZHUANKUAI         = 0   -- 砖块
local ITEM_WUQI              = 1   -- 武器
local ITEM_JUANZHOU          = 2   -- 卷轴
local ITEM_SHIWU             = 3   -- 食物
local ITEM_GUAIWU_SH         = 4   -- 伤害类怪物
local ITEM_GUAIWU_WX         = 5   -- 武学类怪物
local ITEM_BAOXIANG          = 6   -- 宝箱
local ITEM_TONGDAO           = 7   -- 通道
local ITEM_JUESHIHAOJIAN     = 8   -- 绝世好剑
local ITEM_XIANDAN           = 9   -- 仙丹
local ITEM_ZHANGQI           = 10  -- 瘴气
local ITEM_XIANLINGZHIQI     = 11   -- 仙灵之气
local ITEM_ZHISHIBAN         = 12  -- 指示板
local ITEM_JITAN             = 13   -- 祭坛

local ITEM_NONE              = 14   --

local ITEM_MAP = {
    [ITEM_JITAN] = ResMgr.ui.cwtx_jt,
    [ITEM_WUQI] = ResMgr.ui.cwtx_weapon,
    [ITEM_JUANZHOU] = ResMgr.ui.cwtx_juanzhou,
    [ITEM_SHIWU] = ResMgr.ui.cwtx_food,
    [ITEM_GUAIWU_SH] = ResMgr.ui.cwtx_channel,
    [ITEM_GUAIWU_WX] = ResMgr.ui.cwtx_channel,
    ["none1"] = ResMgr.ui.cwtx_none1,
    ["none2"] = ResMgr.ui.cwtx_none2,
    [ITEM_TONGDAO] = ResMgr.ui.cwtx_channel,
    ["blank0"] = ResMgr.ui.cwtx_blank0,
    ["blank1"] = ResMgr.ui.cwtx_blank1,
    ["blank2"] = ResMgr.ui.cwtx_blank2,
    ["monster1"] = ResMgr.ui.cwtx_monster1,
    ["monster2"] = ResMgr.ui.cwtx_monster2,
    ["monster3"] = ResMgr.ui.cwtx_monster3,
    ["monster4"] = ResMgr.ui.cwtx_monster4,
    [ITEM_JUESHIHAOJIAN] = ResMgr.ui.cwtx_jshj,
    [ITEM_XIANDAN] = ResMgr.ui.cwtx_xd,
    [ITEM_ZHANGQI] = ResMgr.ui.cwtx_zq,
    [ITEM_XIANLINGZHIQI] = ResMgr.ui.cwtx_xlzq,
    [ITEM_ZHISHIBAN] = ResMgr.ui.cwtx_zsb,
}

local GAME_READY = 0
local GAME_START = 1


local ZSB_RANDOM_TIPS = {
    CHS[4200618],   --"你来啦！",
    CHS[4200619],   --"我真的还想再活五百年！",
    CHS[4200620],   --"深渊正在凝视你！",
    CHS[4200621],   --"真的很神秘！",
    CHS[4200622],   --"这只是一个指示板！",
    CHS[4200623],   --"这里有宝藏！",
    CHS[4200624],   --"你叫我一声我也不敢答应！",
}

function AnniversaryPetAdventureDlg:init()
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("SwitchPanel", self.onSwitchPanel)
    self:bindListener("DownButton", self.onDownButton)
    self:bindListener("LogButton", self.onLogButton)
    self:bindListener("RuleButton", self.onRuleButton)

    self:setCtrlVisible("IntroducePanel", true)
    self:setCtrlVisible("RewardImage", false)

   -- self:bindFloatPanelListener("RulePanel")
    self:bindListener("RulePanel", self.setRuleUnvisible)

    self.rockPanel = self:retainCtrl("RockPanel")

    local rewardImage = self:getControl("RewardImage")
    rewardImage.x = 3
    rewardImage.y = 3
    self:bindListener("RewardImage", self.onRockPanel)
    self:bindTouchEndEventListener(self.rockPanel, self.onRockPanel)
    ROCK_LEN = self.rockPanel:getContentSize().width

    self.refreshTi = 0
    self.lastTime = 0
    self.rockLastTime = 0
    self.isRefresh = nil

    self:initWall()

    if self.data then
        self:MSG_2019ZNQ_CWTX_DATA(self.data)
    end

    gf:CmdToServer("CMD_2019ZNQ_CWTX_DATA")
    self:hookMsg("MSG_2019ZNQ_CWTX_DATA")
    self:hookMsg("MSG_2019ZNQ_CWTX_CLICK")
end

function AnniversaryPetAdventureDlg:getFloatAction()
    local act1 = cc.MoveBy:create(FLOAT_TIME * 0.5, cc.p(0, FLOAT_LEN * 0.5))
    local act2 = cc.MoveBy:create(FLOAT_TIME, cc.p(0, -FLOAT_LEN))
    local act3 = cc.MoveBy:create(FLOAT_TIME * 0.5, cc.p(0, FLOAT_LEN * 0.5))

    local seqAct = cc.Sequence:create(act1, act2, act3)
    local act = cc.RepeatForever:create(seqAct)

    return act
end

function AnniversaryPetAdventureDlg:getRockStateBykey(data)
    if data.cell_type == ITEM_ZHUANKUAI then
        if data.click_status == ROCK_STATE.HAS_CLICK then
            if data.extra_data == 0 then
                return
            else
                local res = data.extra_data == 1 and ITEM_MAP["none1"] or ITEM_MAP["none2"]
                return ROCK_TYPE.NONE, res
            end
        else
            local key = "blank" .. data.extra_data
            local res = ITEM_MAP[key]
            return ROCK_TYPE.BLANK, res
        end
    elseif data.cell_type >= ITEM_WUQI and data.cell_type <= ITEM_SHIWU then
        if data.click_status == ROCK_STATE.HAS_CLICK then
            return
        else
            return ROCK_TYPE.ITEM, ITEM_MAP[data.cell_type]
        end
    elseif data.cell_type >= ITEM_GUAIWU_SH and data.cell_type <= ITEM_GUAIWU_WX then
        if data.click_status == ROCK_STATE.HAS_CLICK then
            return
        else
            local key = "monster" .. math.floor( data.extra_data / 1000 )
            local res = ITEM_MAP[key]
            return ROCK_TYPE.MONSTER, res
        end
    elseif data.cell_type == ITEM_TONGDAO then
        return ITEM_TONGDAO, ITEM_MAP[data.cell_type]
    elseif data.cell_type == ITEM_BAOXIANG then
        return ITEM_BAOXIANG
    elseif data.cell_type >= ITEM_JUESHIHAOJIAN then
        return data.cell_type
    end
end


function AnniversaryPetAdventureDlg:onUpdate()
    if not self.data then return end
    if self.data.state == GAME_READY then return end

    self.refreshTi = self.refreshTi + 1
    if self.refreshTi % 10 == 1 then
        self:setFullTiMan(self.data)
    end
end

function AnniversaryPetAdventureDlg:setRockPanel(data, panel)
    panel.cell_type = data.cell_type
    panel.data = data

    local type, res = self:getRockStateBykey(data)

    self:setImagePlist("OtherImage", ResMgr.ui.touming, panel)
    self:setCtrlVisible("OtherImage", true, panel)
    if not type then
        self:setCtrlVisible("RockImage", false, panel)
        self:setCtrlVisible("ItemPanel", false, panel)
        self:setCtrlVisible("MonsterPanel", false, panel)
        return
    end

    if type == ROCK_TYPE.BAOXIANG then
        local ctl = self:setCtrlVisible("RewardImage", data.click_status == ROCK_STATE.CAN_CLICK)
        ctl.data = data
        self:setCtrlVisible("RockImage", false, panel)
        self:setCtrlVisible("ItemPanel", false, panel)
        self:setCtrlVisible("MonsterPanel", false, panel)

        if data.click_status == ROCK_STATE.CAN_CLICK then
            local ctl = self:getControl("BKImage", nil, "OperatePanel")

            if ctl:getChildByTag(999) then
                return
            end

           gf:createArmatureMagic(ResMgr.ArmatureMagic.cwtx_no_open_box, ctl, 999)
        end

        return
    end

    self:setCtrlVisible("RockImage", type == ROCK_TYPE.BLANK, panel)
    self:setCtrlVisible("ItemPanel", type == ROCK_TYPE.ITEM, panel)
    self:setCtrlVisible("MonsterPanel", type == ROCK_TYPE.MONSTER, panel)

    if type == ROCK_TYPE.CAN_CLICK then
    elseif type == ROCK_TYPE.BLANK then
        self:setImage("RockImage", res, panel)
    elseif type == ROCK_TYPE.ITEM then
        local itemImage = self:setImage("ItemImage", res, panel)
        local act = self:getFloatAction()

        if not itemImage.isActiong then
            itemImage:runAction(act)
            itemImage.isActiong = true
        end
    elseif type == ROCK_TYPE.MONSTER then
        local itemImage = self:setImage("MonsterImage", res, panel)
        local act = self:getFloatAction()
        if not itemImage.isActiong then
            itemImage:runAction(act)
            itemImage.isActiong = true
        end
        self:setLabelText("NumLabel", data.extra_data % 1000, panel)        -- 1000以内才是数值

        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, data.extra_data % 1000, false, LOCATE_POSITION.MID, 19, panel)

        if data.cell_type == ITEM_GUAIWU_SH then
            self:setImage("TypeImage", ResMgr.ui.cwtx_monster_sh, panel)
        elseif data.cell_type == ITEM_GUAIWU_WX then
            self:setImage("TypeImage", ResMgr.ui.cwtx_monster_wu, panel)
        end

    elseif type == ROCK_TYPE.TONGDAO then
        self:setImage("OtherImage", res, panel)
    elseif type == ROCK_TYPE.NONE then
        self:setImage("OtherImage", res, panel)
    else
        if ITEM_MAP[data.cell_type] then
            if data.click_status == ROCK_STATE.CAN_CLICK then
                self:setCtrlVisible("ItemPanel", true, panel)
                local itemImage = self:setImage("ItemImage", ITEM_MAP[data.cell_type], panel)
                if data.cell_type == ITEM_XIANDAN then
                    local act = self:getFloatAction()
                    if not itemImage.isActiong then
                        itemImage:runAction(act)
                        itemImage.isActiong = true
                    end
                elseif data.cell_type == ITEM_ZHISHIBAN or data.cell_type == ITEM_JUESHIHAOJIAN or data.cell_type == ITEM_JITAN then
                    --
                    if itemImage.isActiong then
                        itemImage:stopAllActions()
                        itemImage.isActiong = false
                        itemImage:setPosition(0,0)
                    end
                end
            else
                self:setImagePlist("OtherImage", ResMgr.ui.touming, panel)
            end
        end
    end
end

function AnniversaryPetAdventureDlg:initWall()
    local wallPanel = self:getControl("WallPanel")

    -- 5 * 5 的格子
    for i = 1, WALL_COUNT do
        for j = 1, WALL_COUNT do
            local panel = self.rockPanel:clone()
            panel.x = j
            panel.y = i
            panel:setTag(i * 10 + j)
            panel:setPosition(0 + (i - 1) * ROCK_LEN, wallPanel:getContentSize().height - j * ROCK_LEN)
            self:setRockPanel({cell_type = ITEM_ZHUANKUAI, click_status = ROCK_STATE.CAN_CLICK, extra_data = 0 }, panel)
            wallPanel:addChild(panel)
        end
    end
end


function AnniversaryPetAdventureDlg:setInfoPanel(data)
    local panel = self:getControl("InfoPanel")

    if not data then
        data = {temp_damage = 0, temp_tao = 0, level = 0, exp = 0, upgrade_need_exp = 0, damage = 0, tao = 0, act_power = 0, max_act_power = 0, full_power_time = 0}
    end
    -- 资源暂时不抽取，应该后续资源来了，这里不是显示文字
    -- 等级
    self:setLabelText("LevelLabel", string.format(CHS[5410293], data.level), panel)  -- "等级：%d"

    -- 经验
    self:setLabelText("ExpLabel", string.format(CHS[4101276], data.exp, data.upgrade_need_exp), panel)    -- "经验：%d/%d"

    -- 伤害
    self:setLabelText("AttackLabel", string.format(CHS[4101277], data.damage), panel)       -- "伤害：%d"
    if data.temp_damage == 0 then
        self:setLabelText("AttackLabel_1", "", panel)       -- "伤害：%d"
    elseif data.temp_damage > 0 then
        self:setLabelText("AttackLabel_1", "+" .. data.temp_damage, panel, COLOR3.GREEN)       -- "伤害：%d"
    else
        self:setLabelText("AttackLabel_1", "-" .. math.abs( data.temp_damage ), panel, COLOR3.RED)       -- "伤害：%d"
    end

    -- 武学
    self:setLabelText("TaoLabel", string.format( CHS[4100441], data.tao), panel) -- "武学：%d"

    if data.temp_tao == 0 then
        self:setLabelText("TaoLabel_0", "", panel)       -- "伤害：%d"
    elseif data.temp_tao > 0 then
        self:setLabelText("TaoLabel_0", "+" .. data.temp_tao, panel, COLOR3.GREEN)       -- "伤害：%d"
    else
        self:setLabelText("TaoLabel_0", "-" .. math.abs( data.temp_tao ), panel, COLOR3.RED)       -- "伤害：%d"
    end

    -- 探险值
    self:setLabelText("SpiritLabel", string.format( CHS[4101278], data.act_power, data.max_act_power), panel)

    self:setFullTiMan(data)
end


function AnniversaryPetAdventureDlg:setFullTiMan(data)

    -- 体满
    local h, m, s
    local str
    if data.full_power_time == 0 then
        h = 0
        m = 0
        s = 0
    else
        local leftTi = math.max(0, data.full_power_time - gf:getServerTime())
        h = math.floor( leftTi / 3600 )
        m = math.floor( (leftTi % 3600) / 60 )
        s = math.floor( leftTi % 60 )
    end
    str = string.format( "%02d:%02d:%02d", h,m,s)


    local curH = tonumber(os.date("%H", gf:getServerTime()))
    if curH < 8 then
        self:setLabelText("TimeLabel", string.format( CHS[4101280]), panel)   -- 体满：%s   0-8点不恢复
    else
        self:setLabelText("TimeLabel", string.format( CHS[4101279], str), panel) -- 体满：%s

        if data.next_refresh_time and not self.isRefresh and data.next_refresh_time - gf:getServerTime() <= 0 and data.act_power < data.max_act_power then
            self.isRefresh = gfGetTickCount()
            gf:CmdToServer("CMD_2019ZNQ_CWTX_DATA")
        end
    end
end

function AnniversaryPetAdventureDlg:setMapInfo(data)
    local panel = self:getControl("MapInfoPanel")

    if not data then
        data = {layer = 0, remain_layer_times = 0, remain_bonus_times = 0, baoxiang_layer = 0}
    end

    -- 第x层
    self:setLabelText("MapLabel", string.format( CHS[4010257], data.layer), panel)

    -- 今日还允许探索：N层
    self:setLabelText("AllowMapLabel", string.format( CHS[4010258], data.remain_layer_times), panel)

    -- 宝箱所在
    self:setLabelText("RewardLabel", string.format( CHS[4010259], data.baoxiang_layer), panel)

    -- 今日还可开启：n个
    self:setLabelText("AllowRewardLabel", string.format(CHS[4010260], data.remain_bonus_times), panel)

    -- 刷新奖励类型
    self:refreshSwitchPanel(data.bonus_type)
end


function AnniversaryPetAdventureDlg:onSwitchPanel(sender, eventType)
    if not self.data then return end
    if self.data.state == GAME_READY then
        gf:ShowSmallTips(CHS[4010261])
        return
    end

    if gfGetTickCount() - self.lastTime <= 1000 then
        gf:ShowSmallTips(CHS[4010262])
        return
    end

    self.lastTime = gfGetTickCount()

    local bType = self.data.bonus_type == "tao" and "exp" or "tao"
    gf:CmdToServer("CMD_2019ZNQ_CWTX_BONUS_TYPE", {bonus_type = bType})
end


function AnniversaryPetAdventureDlg:onStartButton(sender, eventType)

    -- 等级
    if Me:queryBasicInt("level") < 30 then
        gf:ShowSmallTips(CHS[4010263])
        return
    end

    gf:confirmEx(CHS[4101308], CHS[6000583], function ()
        gf:CmdToServer("CMD_2019ZNQ_CWTX_START")
        gf:CmdToServer("CMD_2019ZNQ_CWTX_BONUS_TYPE", {bonus_type = "tao"})
    end, CHS[5410084], function ()
        gf:CmdToServer("CMD_2019ZNQ_CWTX_START")
        gf:CmdToServer("CMD_2019ZNQ_CWTX_BONUS_TYPE", {bonus_type = "exp"})
    end, nil, nil, nil, nil, nil, "AnniversaryPetAdventureDlgStartGame")
end

-- 点击状况
function AnniversaryPetAdventureDlg:onRockPanel(sender, eventType)

    if not self.data then return end

    if sender.data.click_status ~= ROCK_STATE.CAN_CLICK then return end

    if gfGetTickCount() - self.rockLastTime < 400 then
        return
    end

    self.rockLastTime = gfGetTickCount()

    local type = self:getRockStateBykey(sender.data)
    if type == ROCK_TYPE.MONSTER then
        local typeStr = CHS[4010264] -- "探索伤害"
        local contentStr = CHS[4010265] -- "由于#R餐风#n的%s#R高于#n该探险者，无需消耗探险值不费吹灰之力就可轻松将其赶走，是否确认？"
        local num = 0
        local isNotConfirm = false

        local monsterPow = sender.data.extra_data % 1000

        local damage = self.data.damage + self.data.temp_damage
        local tao = self.data.tao + self.data.temp_tao

        if sender.data.cell_type == ITEM_GUAIWU_SH then
            if damage > monsterPow then
                isNotConfirm = true
            elseif damage == monsterPow then
                contentStr = CHS[4010266] --"由于#R餐风#n的%s#R等于#n该探险者，需要消耗#R%d#n点探险值将其赶走，是否确认？"
                num = 1
            elseif damage < monsterPow then
                contentStr =  CHS[4010267] --"由于#R餐风#n的%s#R小于#n该探险者，需要消耗#R%d#n点探险值将其赶走，是否确认？"
                num = 1 + monsterPow - damage
            end

        elseif sender.data.cell_type == ITEM_GUAIWU_WX then

            typeStr = CHS[4010268]--"探索武学"
            if tao > monsterPow then
                isNotConfirm = true
            elseif tao == monsterPow then
                contentStr = CHS[4010266]--"由于#R餐风#n的%s#R等于#n该探险者，需要消耗#R%d#n点探险值将其赶走，是否确认？"
                num = 1
            elseif tao < monsterPow then
                contentStr = CHS[4010267] --"由于#R餐风#n的%s#R小于#n该探险者，需要消耗#R%d#n点探险值将其赶走，是否确认？"
                num = 1 + monsterPow - tao
            end
        end

        if isNotConfirm then
            gf:CmdToServer("CMD_2019ZNQ_CWTX_CLICK", {layer = self.data.layer, x = sender.x, y = sender.y})
        else
            if num >= 5 then
                contentStr = contentStr .. "\n" .. CHS[4101309]
            end

            gf:confirm(string.format( contentStr, typeStr, num), function ()
                gf:CmdToServer("CMD_2019ZNQ_CWTX_CLICK", {layer = self.data.layer, x = sender.x, y = sender.y})
            end)
        end
        return
    elseif type == ROCK_TYPE.BAOXIANG and sender.data.click_status == ROCK_STATE.CAN_CLICK then
            -- 战斗
        if GameMgr.inCombat then
            -- 战斗中不可进行此操作。
            gf:ShowSmallTips(CHS[4000223])
            return
        end

        self:setCtrlVisible("RewardImage", false)

        local icon = ResMgr.ArmatureMagic.cwtx_open_box.name
        local act = ResMgr.ArmatureMagic.cwtx_open_box.action
        local ctl = self:getControl("BKImage", nil, "OperatePanel")

        if ctl:getChildByName(act) then
            return
        end

        performWithDelay(self.root, function ()
            gf:CmdToServer("CMD_2019ZNQ_CWTX_CLICK", {layer = self.data.layer, x = sender.x, y = sender.y})
        end, 0.5)


        gf:createArmatureOnceMagic(icon, act, ctl, function ( )

            local magic = ctl:getChildByTag(999)
            if magic then magic:removeFromParent() end
        end)
        return
    elseif sender.data.cell_type == ITEM_ZHISHIBAN and sender.data.click_status == ROCK_STATE.CAN_CLICK then
        -- 指示版
        local randStr = ZSB_RANDOM_TIPS[sender.data.extra_data % 7 + 1]
        local str = string.format(CHS[4200625], randStr)    -- 发现了一块神秘的指示板，上面书写着“%s”，是否向下挖掘，看看里面有些什么？
        gf:confirmEx(str, CHS[4200626], function ()
            gf:CmdToServer("CMD_2019ZNQ_CWTX_CLICK", {layer = self.data.layer, x = sender.x, y = sender.y})
        end, CHS[4200627])
        return
    elseif sender.data.cell_type == ITEM_JUESHIHAOJIAN and sender.data.click_status == ROCK_STATE.CAN_CLICK then
        gf:confirmEx(CHS[4200628], CHS[4200629], function ()
            gf:CmdToServer("CMD_2019ZNQ_CWTX_CLICK", {layer = self.data.layer, x = sender.x, y = sender.y})
        end, CHS[4200627])
        return
    elseif sender.data.cell_type == ITEM_XIANDAN and sender.data.click_status == ROCK_STATE.CAN_CLICK then
        gf:confirmEx(CHS[4200630], CHS[4200631], function ()
            gf:CmdToServer("CMD_2019ZNQ_CWTX_CLICK", {layer = self.data.layer, x = sender.x, y = sender.y})
        end, CHS[4200627])
        return
    elseif sender.data.cell_type == ITEM_TONGDAO then
        local ctl = self:getControl("BKImage", nil, "OperatePanel")
        local magic = ctl:getChildByTag(999)
        if magic then
            return
        end
    elseif sender.data.cell_type == ITEM_JITAN then
        -- 1 武学转伤害
        local str = ""
        if self.data.damage == self.data.tao then
            if sender.data.extra_data == 0 then
                str = CHS[4101314]--"发现一座远古祭坛，是否献祭#R5#n点探险值，将你的#R5#n点伤害变为武学？"
            elseif sender.data.extra_data == 1 then
                str = CHS[4101315]--"发现一座远古祭坛，是否献祭#R5#n点探险值，将你的#R5#n点武学变为伤害？"
            end
        elseif self.data.damage > self.data.tao then
            str = CHS[4101314] -- "发现一座远古祭坛，是否献祭#R5#n点探险值，将你的#R5#n点伤害变为武学？"
        else
            str = CHS[4101315]--"发现一座远古祭坛，是否献祭#R5#n点探险值，将你的#R5#n点武学变为伤害？"
        end

        gf:confirmEx(str, CHS[4101316], function ()
            gf:CmdToServer("CMD_2019ZNQ_CWTX_CLICK", {layer = self.data.layer, x = sender.x, y = sender.y})
        end, CHS[4200627])
        return
    end

    gf:CmdToServer("CMD_2019ZNQ_CWTX_CLICK", {layer = self.data.layer, x = sender.x, y = sender.y})
end

function AnniversaryPetAdventureDlg:playMagic(cell, icon, cb)
    local size = self.rockPanel:getContentSize()
    local magic = gf:createCallbackMagic(icon, function(node)
        node:removeFromParent(true)
        if cb then cb() end
    end)

    local panel = cell:getParent():getParent():getParent()
    local x, y = cell:getPosition()
    local pos = cell:getParent():convertToWorldSpace(cc.p(x, y))
    pos = panel:convertToNodeSpace(pos)
    magic:setPosition(pos.x + size.width / 2, pos.y + size.height / 2)
    magic:setLocalZOrder(20)
    panel:addChild(magic)
end

function AnniversaryPetAdventureDlg:refreshSwitchPanel(bonus_type)
    -- 刷新产出类型
    if bonus_type == PRODUCE_TYPE.exp then
        self:setCtrlVisible("ExpImage", true, "SwitchPanel")
        self:setCtrlVisible("TaoImage", false, "SwitchPanel")
    elseif bonus_type == PRODUCE_TYPE.tao then
        self:setCtrlVisible("ExpImage", false, "SwitchPanel")
        self:setCtrlVisible("TaoImage", true, "SwitchPanel")
    end
end

function AnniversaryPetAdventureDlg:onDownButton(sender, eventType)
    if not self.data then return end
    if self.data.state == GAME_READY then
        gf:ShowSmallTips(CHS[4010261])
        return
    end

    gf:CmdToServer("CMD_2019ZNQ_CWTX_BACK", {layer = self.data.layer})
end

function AnniversaryPetAdventureDlg:onLogButton(sender, eventType)

    DlgMgr:openDlg("AdventureLogDlg")
end

function AnniversaryPetAdventureDlg:setRuleUnvisible()
    DlgMgr:openDlg("AdventureRuleDlg")

end

function AnniversaryPetAdventureDlg:onRuleButton(sender, eventType)

     DlgMgr:openDlg("AdventureRuleDlg")

end

function AnniversaryPetAdventureDlg:cleanup()
    gf:CmdToServer("CMD_2019ZNQ_CWTX_QUIT")
end

function AnniversaryPetAdventureDlg:refreshRock(data)
    local wallPanel = self:getControl("WallPanel")

    -- 5 * 5 的格子
    for i = 1, WALL_COUNT do
        for j = 1, WALL_COUNT do
            local idx = (j - 1) * 5 + i
            local tag = i * 10 + j
            local panel = wallPanel:getChildByTag(i * 10 + j)
            panel:setVisible(true)
            self:setRockPanel(data.cells[idx], panel)
        end
    end
end


function AnniversaryPetAdventureDlg:MSG_2019ZNQ_CWTX_CLICK(data)
    if data.bef_data.cell_type == ITEM_TONGDAO then return end
    local tag = data.y * 10 + data.x
    local wallPanel = self:getControl("WallPanel")
    local panel = wallPanel:getChildByTag(tag)

    -- 砖块炸碎效果
    if data.bef_data.cell_type == ITEM_ZHUANKUAI and data.bef_data.click_status == ROCK_STATE.CAN_CLICK then
        self:playMagic(panel, ResMgr.magic.xunbao_broken_nomal_rock)
    end

    -- 怪物消失
    if (data.bef_data.cell_type == ITEM_GUAIWU_SH or data.bef_data.cell_type == ITEM_GUAIWU_WX) and data.bef_data.click_status == ROCK_STATE.CAN_CLICK then
        local magic = gf:createSelfRemoveMagic(ResMgr.magic.duanwujie2019KillMonstrt, {blendMode = "normal", frameInterval = 100})
        magic:setPosition(-panel:getContentSize().width * 0.5 , panel:getContentSize().height * 1.5 )
        panel:addChild(magic)
    end

    if (data.atf_data.cell_type == ITEM_ZHANGQI or data.atf_data.cell_type == ITEM_XIANLINGZHIQI) then
        local name = data.atf_data.cell_type == ITEM_ZHANGQI and ResMgr.magic.cwtx_zq or ResMgr.magic.cwtx_xlzq
        local magic = gf:createSelfRemoveMagic(name, {blendMode = "normal", frameInterval = 100})
        magic:setPosition(-panel:getContentSize().width - 10 , panel:getContentSize().height * 2 + 10)
        panel:addChild(magic)
    end
end

function AnniversaryPetAdventureDlg:MSG_2019ZNQ_CWTX_DATA(data)
    self:setCtrlVisible("RewardImage", false)
        local ctl = self:getControl("BKImage", nil, "OperatePanel")
        local magic = ctl:getChildByTag(999)
        if magic then
            magic:removeFromParent()
        end

    self.data = data
    self.isRefresh = nil
    if data.state == GAME_READY then
        self:setInfoPanel()
     --   self:refreshRock()
        self:setCtrlVisible("IntroducePanel", true)
        self:setCtrlVisible("WallPanel", false)
        self:setMapInfo()
    else
        self:setCtrlVisible("WallPanel", true)
        self:setInfoPanel(data)
        self:setMapInfo(data)
        self:refreshRock(data)
        self:setCtrlVisible("IntroducePanel", false)
    end
end


return AnniversaryPetAdventureDlg
