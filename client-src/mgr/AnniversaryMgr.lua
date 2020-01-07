-- AnniversaryMgr.lua
-- created by songcw Mar/15/2017
-- 周年庆管理器

AnniversaryMgr = Singleton()

-- 灵猫不同饱食度信息
local LINGMAO_FOOD_INFO = {
    [1] = {num = 0,  status = CHS[5400460], color = cc.c3b(178, 45, 45), icon = ResMgr.ui.lingmao_food_0 },
    [2] = {num = 20, status = CHS[5400461], color = cc.c3b(217, 116, 36), icon = ResMgr.ui.lingmao_food_20},
    [3] = {num = 40, status = CHS[5400462], color = cc.c3b(242, 200, 73), icon = ResMgr.ui.lingmao_food_40},
    [4] = {num = 60, status = CHS[5400463], color = cc.c3b(166, 204, 51), icon = ResMgr.ui.lingmao_food_60},
    [5] = {num = 80, status = CHS[5400464], color = cc.c3b(80, 229, 130), icon = ResMgr.ui.lingmao_food_80},
}

-- 灵猫不同心情度信息
local LINGMAO_MOOD_INFO = {
    [1] = {num = 0,  status = CHS[5400455], color = cc.c3b(178, 45, 45), icon = ResMgr.ui.lingmao_mood_0 },
    [2] = {num = 20, status = CHS[5400456], color = cc.c3b(217, 116, 36), icon = ResMgr.ui.lingmao_mood_20},
    [3] = {num = 40, status = CHS[5400457], color = cc.c3b(242, 200, 73), icon = ResMgr.ui.lingmao_mood_40},
    [4] = {num = 60, status = CHS[5400458], color = cc.c3b(166, 204, 51), icon = ResMgr.ui.lingmao_mood_60},
    [5] = {num = 80, status = CHS[5400459], color = cc.c3b(80, 229, 130), icon = ResMgr.ui.lingmao_mood_80},
}

-- 灵猫不同阶段形象
local LINGMAO_SHAPE_STAGE = {
    [1] = {level = 0, icon = ResMgr.DragonBones.anniversary_lingmao_type1},
    [2] = {level = 4, icon = ResMgr.DragonBones.anniversary_lingmao_type2},
    [3] = {level = 8, icon = ResMgr.DragonBones.anniversary_lingmao_type3},
}

local CAT_MAX_LEVEL = 12  -- 灵猫的最大等级

-- 抽奖、领奖   2017周年庆      0 表示请求抽奖，1 表示请求领奖。
function AnniversaryMgr:fetchLotteryZNQ2017(flag)
    gf:CmdToServer("CMD_FETCH_LOTTERY_ZNQ_2017", {flag = flag})
end

-- 领取周年庆礼包，index 为礼包序号
function AnniversaryMgr:fetchZNQLoginGift(index)
    gf:CmdToServer("CMD_ZNQ_FETCH_LOGIN_GIFT_2019", {index = index})
end

-- 打开周年庆登录礼包界面
function AnniversaryMgr:znqOpenLoginGift()
    gf:CmdToServer("CMD_ZNQ_OPEN_LOGIN_GIFT_2019")
end

-- 五行商店兑换
function AnniversaryMgr:wuxingShopExchange(name, count)
    gf:CmdToServer("CMD_WUXING_SHOP_EXCHANGE", {name = name, count = count})
end

-- 五行商店刷新
function AnniversaryMgr:wuxingShopRefresh()
    gf:CmdToServer("CMD_WUXING_SHOP_REFRSH")
end

-- 播放浇水骨骼动画（招福宝树相关）
function AnniversaryMgr:createWaterArmatureAction(icon, actionName, panel, callback)
    local magic = ArmatureMgr:createArmature(icon)

    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)

            if callback and "function" == type(callback) then callback() end
        end
    end
    
    panel:setVisible(true)
    magic:setAnchorPoint(0.5, 0.5)
    local size = panel:getContentSize()
    magic:setPosition(size.width / 2, size.height / 2)
    panel:addChild(magic)
    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play(actionName)
end

-- 宝树阶段变化的渐变动画
function AnniversaryMgr:playTreeStageUp(treeBefore, treeAfter, time, endAction)
    treeBefore:setVisible(true)
    treeAfter:setVisible(true)
    treeBefore:setOpacity(255)
    treeAfter:setOpacity(0)
    
    local fadeOut = cc.FadeOut:create(time)
    treeBefore:runAction(fadeOut)
    
    local fadeIn = cc.FadeIn:create(time)
    treeAfter:runAction(cc.Sequence:create(fadeIn, endAction))
end

-- 设置招福宝树健康值进度条颜色
function AnniversaryMgr:setProBar(bar, percent)
    bar:setPercent(percent)
    
    if percent < 20 then
        bar:setColor(cc.c3b(255, 74, 38))
    elseif percent >= 20 and percent < 80 then
        bar:setColor(cc.c3b(255, 255, 76))
    elseif percent >= 80 then
        bar:setColor(cc.c3b(85, 242, 124))
    end
end

function AnniversaryMgr:cleanData(isMsgLoginDone)
    if not isMsgLoginDone then
        self.znqLoginGift = nil
        self.znqWXShopGift = nil
    end
end

-- 打开周年庆抽奖界面
function AnniversaryMgr:MSG_OPEN_LOTTERY_ZNQ_2017(data)
    DlgMgr:openDlg("AnniversaryDrawDlg")
end

-- 周年庆登录礼包数据
function AnniversaryMgr:MSG_ZNQ_LOGIN_GIFT(data)
    self.znqLoginGift = data
end

function AnniversaryMgr:MSG_ZNQ_LOGIN_GIFT_2018(data)
    self:MSG_ZNQ_LOGIN_GIFT(data)
end

function AnniversaryMgr:MSG_ZNQ_LOGIN_GIFT_2019(data)
    self:MSG_ZNQ_LOGIN_GIFT(data)
end

-- 刷新五行商店
function AnniversaryMgr:MSG_WUXING_SHOP_REFRSH(data)
    self.znqWXShopGift = data
end

function AnniversaryMgr:MSG_CAN_FETCH_FESTIVAL_GIFT(data)
    -- 换线不处理
    if DistMgr:getIsSwichServer() then return end
    
    if data.activeName == CHS[4100497] and data.count > 0 then
        RedDotMgr:insertOneRedDot("SystemFunctionDlg", "AnniversaryButton")
        RedDotMgr:insertOneRedDot("AnniversaryTabDlg", "ZNLBCheckBox")
    end
end

-- 请求自己的灵猫数据
function AnniversaryMgr:requestMyLingMaoInfo()
    gf:CmdToServer("CMD_ZNQ_2018_REQ_LINGMAO_INFO", {})
end

-- oper  forget_skill:遗忘技能，dunwu_skill:顿悟技能，scratch:挠痒，feed:喂食
-- para  遗忘的技能名称（oper=forget_skill 时生效）
function AnniversaryMgr:requestOperateLingMao(oper, para)
    gf:CmdToServer("CMD_ZNQ_2018_OPER_LINGMAO", {oper = oper, para = para or ""})
end

-- 请求好友灵猫数据
-- gids(gid以"|"分隔，一次最多6个, 空表示只打开界面)
function AnniversaryMgr:requestFriendsLingMaoInfo(gids)
    gf:CmdToServer("CMD_ZNQ_2018_REQ_LINGMAO_FRIENDS", {gids = gids})
end

-- 获取灵猫心情状态
function AnniversaryMgr:getCatMoodStatus(num)
    local cou =  #LINGMAO_MOOD_INFO
    for i = 1, cou do
        if i == cou then
            return LINGMAO_MOOD_INFO[i]
        end

        if num < LINGMAO_MOOD_INFO[i + 1].num then
            return LINGMAO_MOOD_INFO[i]
        end 
    end
end

-- 获取灵猫饱食度状态
function AnniversaryMgr:getCatFoodStatus(num)
    local cou =  #LINGMAO_FOOD_INFO
    for i = 1, cou do
        if i == cou then
            return LINGMAO_FOOD_INFO[i]
        end

        if num < LINGMAO_FOOD_INFO[i + 1].num then
            return LINGMAO_FOOD_INFO[i]
        end
    end
end

-- 获取当前等级的灵猫形象
function AnniversaryMgr:getCatCurShapeIcon(level)
    local cou =  #LINGMAO_SHAPE_STAGE
    for i = 1, cou do
        if i == cou then
            return LINGMAO_SHAPE_STAGE[i].icon, i
        end

        if level < LINGMAO_SHAPE_STAGE[i + 1].level then
            return LINGMAO_SHAPE_STAGE[i].icon, i
        end
    end
end

-- 尝试打开灵猫界面
function AnniversaryMgr:tryOpenLingMaoDlg()
    local task = TaskMgr:getTaskByName(CHS[5400448])
    if not task then
        gf:ShowSmallTips(CHS[5400518])
    elseif string.match(task.task_prompt, CHS[5400517]) then
        gf:confirm(CHS[5400516], function() 
            AutoWalkMgr:beginAutoWalk(gf:findDest(CHS[5400520]))
            DlgMgr:closeTabDlg("AnniversaryTabDlg")
        end)
    else
        self.needLingmaoTips = true
        AnniversaryMgr:requestMyLingMaoInfo()
    end
end

function AnniversaryMgr:setLingMaoDataView(dlg, data, root)
    -- 等级
    local panel = dlg:getControl("LevelPanel", nil, root)
    if not data.level then
        dlg:setTwoLabelText("", panel, 1)
        data.exp = 0
        data.max_exp = 0
    else
        dlg:setTwoLabelText(data.level .. CHS[7002280], panel, 1)
    end
    
    local bar = dlg:getControl("ProgressBar", nil, panel)
    bar:setColor(cc.c3b(85, 242, 124))
    if data.level == CAT_MAX_LEVEL then
        bar:setPercent(100)
        dlg:setTwoLabelText(CHS[7002177], panel, 3)
    else
        bar:setPercent((data.exp / data.max_exp) * 100)
        dlg:setTwoLabelText(data.exp .. "/" .. data.max_exp, panel, 3)
    end
    
    local function func(num, panel, statusInfo)
        dlg:setTwoLabelText(statusInfo.status, panel, 1)
        dlg:setTwoLabelText(num .. "/100", panel, 3)
        dlg:setImage("Image", statusInfo.icon, panel)
        local bar = dlg:getControl("ProgressBar", nil, panel)
        bar:setPercent(num)
        bar:setColor(statusInfo.color)
    end

    -- 饱食度
    local food = data.food or 0
    local panel = dlg:getControl("FoodPanel", nil, root)
    local foodStatus = AnniversaryMgr:getCatFoodStatus(food)
    func(food, panel, foodStatus)

    -- 心情
    local mood = data.mood or 0
    local panel = dlg:getControl("MoodPanel", nil, root)
    local moodStatus = AnniversaryMgr:getCatMoodStatus(mood)
    func(mood, panel, moodStatus)
end

function AnniversaryMgr:MSG_ZNQ_2018_MY_LINGMAO_INFO(data)
    local dlg = DlgMgr:getDlgByName("AnniversaryLingMaoDlg")
    if not dlg and data.openType == 1 then
        DlgMgr:openDlgEx("AnniversaryLingMaoDlg", data)
    else
        self.needLingmaoTips = false
    end
end

MessageMgr:regist("MSG_ZNQ_2018_MY_LINGMAO_INFO", AnniversaryMgr)
MessageMgr:regist("MSG_ZNQ_LOGIN_GIFT_2018", AnniversaryMgr)
MessageMgr:regist("MSG_CAN_FETCH_FESTIVAL_GIFT", AnniversaryMgr)
MessageMgr:regist("MSG_OPEN_LOTTERY_ZNQ_2017", AnniversaryMgr)
MessageMgr:regist("MSG_ZNQ_LOGIN_GIFT", AnniversaryMgr)
MessageMgr:regist("MSG_ZNQ_LOGIN_GIFT_2019", AnniversaryMgr)
MessageMgr:regist("MSG_WUXING_SHOP_REFRSH", AnniversaryMgr)