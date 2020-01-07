-- WulxjApplyDlg.lua
-- Created by yangym Sep/21/2016
-- 无量心经使用界面
local WulxjApplyDlg = Singleton("WulxjApplyDlg", Dialog)

-- 无量心经可生成经验心得或者道武心得
local XINDE_TYPE =
{
    jingyxd = 1,
    daowxd = 2,
}

function WulxjApplyDlg:init()

    -- 绑定控件
    self:bindListener("JingyxdPanel", self.onJingyxdPanel)
    self:bindListener("DaowxdPanel", self.onDaowxdPanel)
    self:bindListener("SelectButton", self.onSelectButton)
    
    -- 初始化界面
    self:getControl("ChosenEffectImage", nil, "JingyxdPanel"):setVisible(false)
    self:getControl("ChosenEffectImage", nil, "DaowxdPanel"):setVisible(false)
    self:getControl("EmptyPanel"):setVisible(true)
    
    -- 无量心经可使用次数
    self.leftTimes = nil
    self.useItemPos = nil
    
    self:setBasicInfo()
    
    self:hookMsg("MSG_WULIANGXINJING_INFO")
    gf:CmdToServer("CMD_GET_WULIANGXINJING_INFO")
end

function WulxjApplyDlg:setBasicInfo()

   --  设置图标
   self:setImage("GuardImage", InventoryMgr:getIconFileByName(CHS[7000044]), "JingyxdPanel")
    self:setItemImageSize("GuardImage", "JingyxdPanel")
   self:setImage("GuardImage", InventoryMgr:getIconFileByName(CHS[7000045]), "DaowxdPanel")
    self:setItemImageSize("GuardImage", "JingyxdPanel")
   
   --  设置还可使用的无量心经数量
   local jingyxdNum = self:getLeftTimes(XINDE_TYPE.jingyxd)
   local daowxdNum = self:getLeftTimes(XINDE_TYPE.daowxd)
   self:setLabelText("LeftNumLabel", CHS[7000046] .. jingyxdNum .. InventoryMgr:getUnit(CHS[7000044]), "JingyxdPanel")
   self:setLabelText("LeftNumLabel", CHS[7000046] .. daowxdNum .. InventoryMgr:getUnit(CHS[7000045]), "DaowxdPanel")
end

-- 获得经验心得/道武心得任务的无量心经剩余使用数量
function WulxjApplyDlg:getLeftTimes(xindeType)
    if self.leftTimes then
        if xindeType == XINDE_TYPE.jingyxd then
            return self.leftTimes.jyxd_times
        elseif xindeType == XINDE_TYPE.daowxd then
            return self.leftTimes.dwxd_times
        end
    else
        return 0
    end
end

function WulxjApplyDlg:setUseItemPos(pos)
    self.useItemPos = pos
end

function WulxjApplyDlg:onJingyxdPanel(sender, eventType)

    self:getControl("EmptyPanel"):setVisible(false)
    
    -- 设置选中效果
    self:getControl("ChosenEffectImage", nil, "JingyxdPanel"):setVisible(true)
    self:getControl("ChosenEffectImage", nil, "DaowxdPanel"):setVisible(false)
    
    -- 设置标题
    self:setLabelText("TitleLabel", CHS[7000044], "XindePanel", COLOR3.RED)
    
    -- 设置对应心得的具体描述
    local str = string.format(CHS[7000047], math.min(Const.JY_XINDE_MAX_LEVEL, Me:queryInt("level") - 10))
    self:setLabelText("NoteLabel", str, "XindePanel")
    
    -- 记录当前选择的状态
    self.selectXd = XINDE_TYPE.jingyxd
end

function WulxjApplyDlg:onDaowxdPanel(sender, eventType)

    self:getControl("EmptyPanel"):setVisible(false)
    
    -- 设置选中效果
    self:getControl("ChosenEffectImage", nil, "JingyxdPanel"):setVisible(false)
    self:getControl("ChosenEffectImage", nil, "DaowxdPanel"):setVisible(true)

    -- 设置标题
    self:setLabelText("TitleLabel", CHS[7000045], "XindePanel", COLOR3.RED)

    -- 设置对应心得的具体描述
    local str = string.format(CHS[7000048], Me:queryInt("level") - 10)
    self:setLabelText("NoteLabel", str, "XindePanel")
    
    -- 记录当前选择的状态
    self.selectXd = XINDE_TYPE.daowxd
end

function WulxjApplyDlg:onSelectButton(sender, eventType)

    -- 玩家等级低于使用无量心经所需要的等级
    if Me:queryInt("level") < InventoryMgr:getItemInfoByName(CHS[7000043]).use_level then
        gf:ShowSmallTips(InventoryMgr:getItemInfoByName(CHS[7000043]).level_tip)
        return
    end
    
    -- 玩家处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end
    
    -- 是否选择了心得类型
    if not self.selectXd then
        gf:ShowSmallTips(CHS[7000049])
        return
    end
    
    -- 判断当前选择的心得是否已经叠加使用了两本无量心经
    if self:getLeftTimes(self.selectXd) <= 0 then
        if self.selectXd == XINDE_TYPE.jingyxd then
            gf:ShowSmallTips(string.format(CHS[7000061], CHS[7000044]))
        elseif self.selectXd == XINDE_TYPE.daowxd then
            gf:ShowSmallTips(string.format(CHS[7000061], CHS[7000045]))
        end
        return
    end
    
    -- 使用无量心经
    local pos = nil
    if self.useItemPos and InventoryMgr:getItemByPos(self.useItemPos) and
            InventoryMgr:getItemByPos(self.useItemPos).name == CHS[7000043] then
        pos = self.useItemPos
    else
        -- 按照使用优先级选择背包中的无量心经
        local item = InventoryMgr:getPriorityUseInventoryByName(CHS[7000043], true)
        if item then
            pos = item.pos
        else
            -- 如果找不到可使用的无量心经则给出提示
            gf:ShowSmallTips(CHS[7000093])
            return
        end
    end
    
    local xinde_name = nil
    if self.selectXd == XINDE_TYPE.jingyxd then
        xinde_name = CHS[7000044]
    elseif self.selectXd == XINDE_TYPE.daowxd then
        xinde_name = CHS[7000045]
    end
    
    if xinde_name == CHS[7000044] and Me:getLevel() > 110 then
        gf:confirm(CHS[7003056], function()
            gf:CmdToServer("CMD_APPLY_EX", {pos = pos, amount = 1, str = xinde_name})
        end)
        return    
    end
    
    gf:CmdToServer("CMD_APPLY_EX", {pos = pos, amount = 1, str = xinde_name})
end

function WulxjApplyDlg:MSG_WULIANGXINJING_INFO(data)
    self.leftTimes = data
    self:setBasicInfo()
end

function WulxjApplyDlg:cleanup()
    self.selectXd = nil
    self.leftTimes = nil
    self.useItemPos = nil
end

return WulxjApplyDlg