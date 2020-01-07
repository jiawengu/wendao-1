-- AnniversaryTreeDlg.lua
-- Created by yangym Mar/16/2017
-- 招福宝树界面


local AnniversaryTreeDlg = Singleton("AnniversaryTreeDlg", Dialog)

local PRODUCE_TYPE = 
{
    exp = "exp",
    tao = "tao",
}

local ACTION_TYPE = 
{
    water = 0, -- 浇水
    worm = 1,  -- 除虫
    state = 2, -- 切换奖励类型
    out = 3,   -- 领取奖励
}

local MAX_REWARD_EXP = 10000000
local MOVE_TIME = 0.15

-- 宝树阶段变化的渐变时间
local FADE_TIME = 1

-- 虫子消失的渐变时间
local WORM_FADE_TIME = 1

function AnniversaryTreeDlg:init()
    -- 绑定一些控件
    self:bindListener("OutButton", self.onOutButton)
    self:bindListener("ExplainButton", self.onExplainButton)
    self:bindListener("VisitButton", self.onVisitButton)
    self:bindListener("CultureButton", self.onCultureButton)
    self:bindListener("SwitchPanel", self.onSwitchPanel)
    
    self:bindListener("WormImage1", self.onWormPanel, "TreePanel")
    self:bindListener("WormImage2", self.onWormPanel, "TreePanel")
    self:bindListener("WormImage3", self.onWormPanel, "TreePanel")
    
    -- 初始化变量
    self.isOpeningDlg = true
    
    self:hookMsg("MSG_FRESH_MY_BAOSHU_INFO")
    
    -- 请求一下相关信息
    gf:CmdToServer("CMD_GET_MY_BAOSHU_INFO")
end

function AnniversaryTreeDlg:initData(data)
    self.data = data
    
    -- 刷新产出栏
    self:refreshProducePanel()
    
    -- 刷新成长栏
    self:refreshGrowPanel()
    
    -- 刷新宝树形象和虫子
    self:refreshTree()
    
    -- 处理左上角结算时间和右下角浇水冷却时间的界面刷新
    self:doSchedule()
end

function AnniversaryTreeDlg:refreshProducePanel()
    if not self.data then
        return
    end
    
    local data = self.data
    
    -- 宝树等级
    self:setLabelText("LevelLabel", string.format(CHS[7002171], data.level), "GrownPanel")
    
    -- 刷新产出类型
    self:refreshSwitchPanel(data.bonus_type)
    
    -- 每次产出
    if data.bonus_type == PRODUCE_TYPE.exp then
        self:setCtrlVisible("ExpImage", true, "BornPanel")
        self:setCtrlVisible("TaoImage", false, "BornPanel")
    elseif data.bonus_type == PRODUCE_TYPE.tao then
        self:setCtrlVisible("ExpImage", false, "BornPanel")
        self:setCtrlVisible("TaoImage", true, "BornPanel")
    end
    
    self:setLabelText("ValueLabel", data.bonus_num, "BornPanel")
    
    -- 累计奖励（经验/道行）
    if data.bonus_type == PRODUCE_TYPE.exp then
        self:setCtrlVisible("StorageExpPanel", true)
        self:setCtrlVisible("StorageTaoPanel", false)
        self:setLabelText("ExpLabel", data.bonus_exp, "StoragePanel")
        if tonumber(data.bonus_exp) >= MAX_REWARD_EXP then
            self:setLabelText("MaxExpLabel", CHS[7003040], "StoragePanel", COLOR3.RED)
            self:setCtrlVisible("MaxExpLabel", true, "StoragePanel")
        else
            self:setCtrlVisible("MaxExpLabel", false, "StoragePanel")
        end
    elseif data.bonus_type == PRODUCE_TYPE.tao then
        self:setCtrlVisible("StorageExpPanel", false)
        self:setCtrlVisible("StorageTaoPanel", true)
        self:setLabelText("TaoLabel", data.bonus_tao .. CHS[7002178], "StoragePanel")
        if data.bonus_tao == CHS[7003039] then
            self:setLabelText("MaxTaoLabel", CHS[7003040], "StoragePanel", COLOR3.RED)
            self:setCtrlVisible("MaxTaoLabel", true, "StoragePanel")
        else
            self:setCtrlVisible("MaxTaoLabel", false, "StoragePanel")
        end
    end
end

function AnniversaryTreeDlg:refreshSwitchPanel(bonus_type)
    -- 刷新产出类型
    if bonus_type == PRODUCE_TYPE.exp then
        self:setCtrlVisible("ExpImage", true, "SwitchPanel")
        self:setCtrlVisible("TaoImage", false, "SwitchPanel")
    elseif bonus_type == PRODUCE_TYPE.tao then
        self:setCtrlVisible("ExpImage", false, "SwitchPanel")
        self:setCtrlVisible("TaoImage", true, "SwitchPanel")
    end
end

function AnniversaryTreeDlg:refreshTree()
    if not self.data then
        return
    end
    
    local data = self.data
    
    -- 重置所有状态
    for i = 1, 3 do
        self:setCtrlVisible("TreeImage" .. i, false, "TreePanel")
        self:setCtrlVisible("ParticlePanel" .. i, false, "TreePanel")
        local wormImage = self:getControl("WormImage" .. i)
        if self:getCtrlVisible("WormImage" .. i) == true and data.has_worm ~= 1 then
            -- 如果本身有虫，此时虫被清除，则播放渐变效果
            local fadeOut = cc.FadeOut:create(WORM_FADE_TIME)
            local endAction = cc.CallFunc:create(function()
                wormImage:setVisible(false)
                wormImage:setOpacity(255)
                wormImage:removeAllChildren()
            end)
            wormImage:runAction(cc.Sequence:create(fadeOut, endAction))
        else
            wormImage:setVisible(false)
            wormImage:removeAllChildren()
        end
        
        self:getControl("ParticlePanel" .. i):removeAllChildren()
    end
    
    -- 宝树
    if data.stage then
        local treeImage = self:getControl("TreeImage" .. data.stage, nil, "TreePanel")
        local particlePanel = self:getControl("ParticlePanel" .. data.stage, nil, "TreePanel")
        treeImage:setVisible(true)
        particlePanel:setVisible(true)
        
        -- 树表的星星光效
        for i = 1, data.stage do
            local quad = cc.ParticleSystemQuad:create(ResMgr:getParticleFilePath("Particle01128"))
            -- Sun/Fire/rain/Snow/Smoke/Flower/Galaxy/Metor/Spiral
            quad:setAnchorPoint(0.5, 0.5)
            local width = particlePanel:getContentSize().width
            local height = particlePanel:getContentSize().height
            quad:setPosition(width / 2, height / 2)
            quad:setPosVar(cc.vertex2F(width / 2, height / 2))
            quad:setLocalZOrder(7)
            particlePanel:addChild(quad)
        end
        
        if self.treeCenterEffect then
            self.treeCenterEffect:removeFromParent()
            self.treeCenterEffect = nil
        end
        
        if data.stage == 3 then
            -- 如果是第三阶段的树，还要额外添加一个树心光效，此光效在重置状态时需移除
            local effect =  gf:createLoopMagic(ResMgr.magic.zhaofu_tree_shuxin)
            effect:setAnchorPoint(0.5, 0.5)
            effect:setPosition(treeImage:getContentSize().width / 2 + 15, treeImage:getContentSize().height / 2 - 30)
            effect:setLocalZOrder(5)
            treeImage:addChild(effect)
            self.treeCenterEffect = effect
        end
    end
    
    -- 虫子
    if data.has_worm == 1 then
        -- 虫子本身是一个光效
        self:setCtrlVisible("WormImage" .. data.stage, true, "TreePanel")
        local wormPanel = self:getControl("WormImage" .. data.stage)
        local effect =  gf:createLoopMagic(ResMgr.magic.zhaofu_tree_worm)
        effect:setAnchorPoint(0.5, 0.5)
        effect:setPosition(wormPanel:getContentSize().width / 2, wormPanel:getContentSize().height / 2)
        effect:setLocalZOrder(10)
        wormPanel:addChild(effect)
    end
end

function AnniversaryTreeDlg:doSchedule()
    if not self.data then
        return
    end
    
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
    
    self.askCount = 0
    local time = gf:getServerTime()
    local nextComputeTime = self.data.next_compute_time
    local leftTime = nextComputeTime - time
    local waterLeftTime = self.data.next_water_time - time
    local promptPanel = self:getControl("PromptPanel")
    local function func()
        local time = gf:getServerTime()
        
        -- 左上角结算时间
        local curHour = gf:getServerDate("*t", time)["hour"]
        if curHour >= 0 and curHour <= 7 then
            self:setCtrlVisible("SleepPanel", true, "PromptPanel")
            self:setCtrlVisible("ActivePanel", false, "PromptPanel")
        else
            self:setCtrlVisible("SleepPanel", false, "PromptPanel")
            self:setCtrlVisible("ActivePanel", true, "PromptPanel")
            if leftTime < 0 then
                -- 倒计时结束后延迟1s重新向服务器索要数据，最多索要三次，同时索要间隔控制在1秒
                performWithDelay(self.root, function()
                    if self.askCount < 3 then
                        local nowTime = gf:getServerTime()
                        if not self.lastCmdTime or (nowTime - self.lastCmdTime >= 1) then
                            gf:CmdToServer("CMD_GET_MY_BAOSHU_INFO")
                            self.lastCmdTime = nowTime
                            self.askCount = self.askCount + 1
                        end
                    end
                end, 1)
            else
                self:setLabelText("ActiveLabel2", self:getShowLeftTime(leftTime) .. CHS[7002176], "PromptPanel")    
            end
            
            leftTime = leftTime - 1
        end
        
        -- 右下角浇水冷却时间
        waterLeftTime = waterLeftTime - 1
        if waterLeftTime <= 0 then
            self:setCtrlVisible("TimeLabel", false)
        else
            self:setCtrlVisible("TimeLabel", true)
            self:setLabelText("TimeLabel", self:getShowLeftTime(waterLeftTime))
        end
    end
    
    func()
    self.scheduleId = gf:Schedule(function()
        func()
    end, 1)
end

function AnniversaryTreeDlg:refreshGrowPanel()
    if not self.data then
        return
    end
    
    local data = self.data
    
    -- 成长
    local expStr = string.format(CHS[7002174], data.cur_exp, data.level_up_exp)
    local expPercent = math.floor(data.cur_exp / data.level_up_exp * 100)
    if data.level == Const.ZF_TREE_MAX_LEVEL then
        self:setLabelText("ExpLabel1", CHS[7002177], "GrownPanel", COLOR3.RED)
        self:setLabelText("ExpLabel2", CHS[7002177], "GrownPanel", COLOR3.BLACK)
    else
        self:setLabelText("ExpLabel1", expStr, "GrownPanel", COLOR3.WHITE)
        self:setLabelText("ExpLabel2", expStr, "GrownPanel", COLOR3.BLACK)
    end
    
    local expProgressBar = self:getControl("ExpProgressBar")
    expProgressBar:setPercent(expPercent)
    
    -- 健康
    local healthStr = string.format(CHS[7002174], data.health, 100)
    local healthPercent = data.health

    self:setLabelText("HealthyLabel1", healthStr, "GrownPanel")
    self:setLabelText("HealthyLabel2", healthStr, "GrownPanel")
    
    local healthProgressBar = self:getControl("HealthyProgressBar")
    AnniversaryMgr:setProBar(healthProgressBar, healthPercent)
end

function AnniversaryTreeDlg:getShowLeftTime(leftTime)
    local leftTimeStr
    if leftTime <= 59 then
        leftTimeStr = string.format(CHS[3002134], leftTime)
    else
        local minute = math.floor(leftTime / 60)
        local second = leftTime - minute * 60
        leftTimeStr = string.format(CHS[3002678], minute, second)   
    end
    
    return leftTimeStr
end

function AnniversaryTreeDlg:onSwitchPanel()
    -- 告知服务器产出类型发生改变
    gf:CmdToServer("CMD_DO_ACTION_ON_BAOSHU", {type = ACTION_TYPE.state})
end

function AnniversaryTreeDlg:onOutButton()
    if Me:isInCombat() or Me:isLookOn() then
        gf:ShowSmallTips(CHS[7002179])
        return
    end
    
    gf:CmdToServer("CMD_DO_ACTION_ON_BAOSHU", {type = ACTION_TYPE.out})
end

function AnniversaryTreeDlg:onExplainButton()
    DlgMgr:openDlg("TreasureTreeRuleDlg")
end

function AnniversaryTreeDlg:onVisitButton()
    DlgMgr:openDlg("AnniversaryFriendTreeDlg")
end

function AnniversaryTreeDlg:onCultureButton()
    gf:CmdToServer("CMD_DO_ACTION_ON_BAOSHU", {type = ACTION_TYPE.water})
end

function AnniversaryTreeDlg:onWormPanel()
    gf:confirm(CHS[7002175], function()
        gf:CmdToServer("CMD_DO_ACTION_ON_BAOSHU", {type = ACTION_TYPE.worm})
    end)
end

function AnniversaryTreeDlg:MSG_FRESH_MY_BAOSHU_INFO(data)
    -- 打开对话框时，如果健康度小于80，给出提示
    if self.isOpeningDlg then
        if data and data.health < 80 then
            gf:ShowSmallTips(CHS[7003033])
        end
        
        self.isOpeningDlg = false
    end

    -- 播放浇水
    if data.type == "water" then
        AnniversaryMgr:createWaterArmatureAction(ResMgr.ArmatureMagic.zf_tree_water.name, "Animation1", self:getControl("WaterPanel" .. data.stage))
    end
    
    if self.data and self.data.stage then
        if self.data.stage ~= data.stage and data.stage > 1 then
            -- 树的阶段提升了,播放树的渐变动画
            local treeBefore = self:getControl("TreeImage" .. self.data.stage)
            local treeAfter = self:getControl("TreeImage" .. data.stage)
            local endAction = cc.CallFunc:create(function()
                self:initData(data)
            end)
            
            AnniversaryMgr:playTreeStageUp(treeBefore, treeAfter, FADE_TIME, endAction)
            return
        end
    end
    
    self:initData(data)
end

function AnniversaryTreeDlg:cleanup()
    self.data = nil
    self.treeCenterEffect = nil
    self.isOpeningDlg = true
    
    if self.scheduleId then
        gf:Unschedule(self.scheduleId)
        self.scheduleId = nil
    end
end

return AnniversaryTreeDlg