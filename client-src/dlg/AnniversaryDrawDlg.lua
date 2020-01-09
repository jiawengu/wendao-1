-- AnniversaryDrawDlg.lua
-- Created by songcw Mar/15/2017
-- 周年庆 抽奖界面

local BachelorDrawDlg = require('dlg/BachelorDrawDlg')
local AnniversaryDrawDlg = Singleton("AnniversaryDrawDlg", BachelorDrawDlg)


local REWARD_MAX = 8

AnniversaryDrawDlg.BONUS_INFO = {
    [1] = {drawIndex = 1, chs = CHS[3000049], icon = ResMgr.ui.daohang, isPlist = 1, reward = {[1] = CHS[3000049], [2] = CHS[3000049]}},    -- 1倍道行
    [2] = {drawIndex = 7, icon = ResMgr.ui.pet_common, chs = CHS[4300125], isPlist = 1, reward = {[1] = CHS[3001218], [2] = CHS[4200263]}}, -- 随机变异宠物
    [3] = {drawIndex = 3, chs = CHS[3001148], item = {name = CHS[3001148]}},     -- 天神护佑
    [4] = {drawIndex = 4, chs = CHS[7000210], item = {name = CHS[7000210]}},     -- 宠物顿悟丹
    [5] = {drawIndex = 5, chs = CHS[3000176], item = {name = CHS[3000176]}},     -- 召唤令·十二生肖
    [6] = {drawIndex = 6, chs = CHS[6000502], icon = ResMgr.ui.rewaed_beiji, reward = {[1] = CHS[3001218], [2] = CHS[4200262]}},       -- 北极熊
    [7] = {drawIndex = 2, chs = CHS[3001147], item = {name = CHS[3001147]}},     -- 超级仙风散
    [8] = {drawIndex = 8, chs = CHS[4100488], item = {name = CHS[4100488]}},     -- 周年庆礼盒
}

function AnniversaryDrawDlg:getCfgFileName()
    return ResMgr:getDlgCfg("AnniversaryDrawDlg")
end

function AnniversaryDrawDlg:init()
    self:bindListener("DrawButton", self.onDrawButton)
  
    self:resetRewards()

    self.isRotating = false

    self:hookMsg("MSG_ZNQ_LOTTERY_RESULT")
    self:hookMsg("MSG_INVENTORY")

    self:setDrawCount()
    self:updateLayout("WelfarePanel")
    for i = 1, REWARD_MAX do
        local panel = self:getControl("BonusPanel_" .. i)        
        self:bindListener("BonusImage", self.onRewardIconButton, panel)
    end
end


function AnniversaryDrawDlg:setDrawCount()
    local count = InventoryMgr:getAmountByName(CHS[4100489])
    self:setLabelText("NoteLabel_1", string.format(CHS[4100490], count))
    self:updateLayout("SignPanel")
end

function AnniversaryDrawDlg:MSG_ZNQ_LOTTERY_RESULT(data)
    local ret = self.BONUS_INFO[data.result].drawIndex

    self.needCount = ret + 1 - self.startPos + math.random(4,5) * REWARD_MAX
    self.startPos = 1
    self.curPos = 0
    self.delay = 1
    self.updateTime = 1
    self.isRotating = true
    self:resetRewards()
end

-- 1领奖    0抽奖
function AnniversaryDrawDlg:draw(flag)
    AnniversaryMgr:fetchLotteryZNQ2017(flag)
end

function AnniversaryDrawDlg:onDrawButton(sender, eventType)
    if not DistMgr:checkCrossDist() then return end

    if not self:isOutLimitTime("lastTime", 1000 * 10) then
        gf:ShowSmallTips(CHS[4300098])
        return
    end


    if self.isRotating then
        return 
    end
    
    if Me:queryBasicInt("level") < 30 then
        gf:ShowSmallTips(string.format(CHS[4300135], 30))
        return
    end

    self:setLastOperTime("lastTime", gfGetTickCount())
    
    local count = InventoryMgr:getAmountByName(CHS[4100489])
    if count <= 0 then
        gf:ShowSmallTips(CHS[4100491])
        return
    end
     
    AnniversaryMgr:fetchLotteryZNQ2017(0)
end

return AnniversaryDrawDlg
