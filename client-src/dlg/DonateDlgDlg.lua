-- DonateDlgDlg.lua
-- Created by zhengjh Feb/27/2016
-- 捐助界面

local DonateDlgDlg = Singleton("DonateDlgDlg", Dialog)
local CLICK_ADD_MONEY = 100

DonateDlgDlg.lastTime = 0
DonateDlgDlg.totalMoney = 1700
local RESET_TIME = 25 * 1000
local MONEY_MAX = 2000
local MONEY_MIN = 1500
local MONEY_DEFAULT = 1700

function DonateDlgDlg:init()
    self:bindListener("ReduceButton", self.onReduceButton)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("DonateButton", self.onDonateButton)
    
    self:bindPressForIntervalCallback('ReduceButton', 0.1, self.onSubOrAddNum, 'times')
    self:bindPressForIntervalCallback('AddButton', 0.1, self.onSubOrAddNum, 'times')
    
    -- 初值默认的捐款
    local nowTime = gfGetTickCount()
    if self:isOutLimitTime("lastTime", RESET_TIME) then
        self.totalMoney = MONEY_DEFAULT
    end
    
    -- 捐助金额提示
    self:setLabelText("Label_21", string.format(CHS[4200000], MONEY_MIN, MONEY_MAX))

    self:setNumber()

    self:hookMsg("MSG_UPDATE_TEAM_LIST")
end

function DonateDlgDlg:cleanup()
    self:setLastOperTime("lastTime", gfGetTickCount())
end

function DonateDlgDlg:onSubOrAddNum(ctrlName, times)
    if ctrlName == "AddButton" then
        self:onAddButton()
    elseif ctrlName == "ReduceButton" then
        self:onReduceButton()
    end
end

function DonateDlgDlg:onReduceButton(sender, eventType)
    if self.totalMoney <= MONEY_MIN then
        return
    end
    
    self.totalMoney = self.totalMoney - CLICK_ADD_MONEY
    self:setNumber()
end

function DonateDlgDlg:onAddButton(sender, eventType)
    if self.totalMoney >= MONEY_MAX then
        return
    end
    
    self.totalMoney = self.totalMoney + CLICK_ADD_MONEY
    self:setNumber()
end

function DonateDlgDlg:setNumber()
    self:setLabelText("NumberLabel_1", self.totalMoney)
    self:setLabelText("NumberLabel_2", self.totalMoney)
end

function DonateDlgDlg:onDonateButton(sender, eventType)
    local data = {}
    data.money = self.totalMoney or 0
    gf:CmdToServer("CMD_SHIMEN_TASK_DONATE", data)
    DlgMgr:closeDlg(self.name)
end

function DonateDlgDlg:MSG_UPDATE_TEAM_LIST(data)
    if data.count > 0 then
        self:onCloseButton()
    end
end

return DonateDlgDlg
