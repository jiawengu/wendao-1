-- HomeManagerDlg.lua
-- Created by sujl, Sept/6/2017
-- 管家界面

local HomeManagerDlg = Singleton("HomeManagerDlg", Dialog)

local MANAGERS = HomeMgr:getHomeManagersConfig()

function HomeManagerDlg:init()
    self.managerPanel1 = self:getControl("ManagerPanel1")
    self:bindListener("BuyButton", self.onBuyButton1, self.managerPanel1)
    self:bindListener("UseButton", self.onUseButton1, self.managerPanel1)

    self.managerPanel2 = self:getControl("ManagerPanel2")
    self:bindListener("BuyButton", self.onBuyButton2, self.managerPanel2)
    self:bindListener("UseButton", self.onUseButton2, self.managerPanel2)

    self:initManagers()

    self:hookMsg("MSG_HOUSE_ALL_GUANJIA_INFO")
end

-- 初始化管家
function HomeManagerDlg:initManagers()
    local panel, manager
    local gjData = HomeMgr:getGjData() or {}
    local index = 1
    for i = 1, #MANAGERS do
        manager = MANAGERS[i]
        if manager.type ~= gjData.cur_select_gj_type then
            panel = self:getControl(string.format("ManagerPanel%d", index))
            local icon = manager.icon
            local modelPanel = self:getControl("ShapePanel", nil, panel)
            self:setPortrait("ShapePanel", icon, 0, panel, true, nil, function()
                if 51513 ~= icon and 51514 ~= icon then 
                    gf:ShowSmallTips(CHS[5420239])
                    return 
                end
                
                local char = modelPanel:getChildByTag(Dialog.TAG_PORTRAIT)
                char:playActionOnce(nil, Const.SA_BOW)
            end)
            if gjData.gjs[manager.type] and not string.isNilOrEmpty(gjData.gjs[manager.type].gj_name) then
                self:setLabelText("NameLabel", gjData.gjs[manager.type].gj_name, panel)
            else
                self:setLabelText("NameLabel", manager.name, panel)
            end
            self:setColorText(manager.desc, "IntroducePanel", panel, nil, nil, nil, 17)
            self:setCtrlVisible("UseButton", manager.price <= 0 or nil ~= gjData.gjs[manager.type], panel)
            self:setCtrlVisible("BuyButton", manager.price > 0 and not gjData.gjs[manager.type], panel)
            -- self:setColorText(manager.price, "CostPanel", self:getControl("BuyButton", nil, panel), nil, nil, COLOR3.WHITE, 25)
            self:setLabelText("CostLabel_1", manager.price, self:getControl("BuyButton", nil, panel))
            self:setLabelText("CostLabel_2", manager.price, self:getControl("BuyButton", nil, panel))
            self:setCtrlVisible("CostImage_Silver", 2 == manager.coin_type, self:getControl("BuyButton", nil, panel))
            self:setCtrlVisible("CostImage_Gold", 1 == manager.coin_type, self:getControl("BuyButton", nil, panel))
            panel.gj_type = manager.type
            index = index + 1
        end
    end
end

-- 购买管家
function HomeManagerDlg:buyManager(index)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000281])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("buyManager", index) then
        return
    end

    local manager = MANAGERS[index]
    -- 金钱通用处理
    local silver = Me:queryBasicInt("silver_coin")
    local gold = Me:queryBasicInt("gold_coin") -- 可能为负
    local totalPrice = manager.price
    if 1 == manager.coin_type and gold < totalPrice then
        gf:askUserWhetherBuyCoin("gold_coin")
    elseif 2 == manager.coin_type and silver < totalPrice and silver + gold < totalPrice then
        gf:askUserWhetherBuyCoin()
    else
        local panel = self:getControl(string.format("ManagerPanel%d", index))
        gf:CmdToServer("CMD_HOUSE_BUY_GUANJIA", { gj_type = panel.gj_type })
    end
end

-- 选择管家
function HomeManagerDlg:selectManager(index)
    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[2000281])
        return
    end

    local panel = self:getControl(string.format("ManagerPanel%d", index))
    gf:CmdToServer("CMD_HOUSE_SELECT_GUANJIA", {gj_type = panel.gj_type})
end

-- 购买按钮
function HomeManagerDlg:onBuyButton1(sender, eventType)
    self:buyManager(1)
end

-- 购买按钮
function HomeManagerDlg:onBuyButton2(sender, eventType)
    self:buyManager(2)
end

-- 选择按钮
function HomeManagerDlg:onUseButton1(sender, eventType)
    self:selectManager(1)
end

-- 选择按钮
function HomeManagerDlg:onUseButton2(sender, eventType)
    self:selectManager(2)
end

function HomeManagerDlg:MSG_HOUSE_ALL_GUANJIA_INFO(data)
    self:initManagers()
end

return HomeManagerDlg