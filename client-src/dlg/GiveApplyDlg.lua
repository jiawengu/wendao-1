-- GiveApplyDlg.lua
-- Created by song Aug/10/2016
-- 赠送申请、同意界面

local GiveApplyDlg = Singleton("GiveApplyDlg", Dialog)


local IS_SEND     = 1       -- 我是送的人
local IS_RECEIVED = 2       -- 我是收到的人

local HOURGLASS = 30000        -- 沙漏时间30s   单位毫秒

function GiveApplyDlg:init()
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("AgreeButton", self.onAgreeButton)
    
    self.notSendFail = false
    
    self:hookMsg("MSG_COMPLETE_GIVING")
    
    self:hookMsg("MSG_OPEN_GIVING_WINDOW")
    
end

function GiveApplyDlg:cleanup()
    -- 需要向服务器发送消息
    if not self.notSendFail then
        GiveMgr:cancelGiving()
    end
end

function GiveApplyDlg:setData(data)
    local giveType = 1
    local charInfo = nil
    if data.giver.name == Me:queryBasic("name") then
        giveType = 1
        charInfo = data.receive
    else
        giveType = 2
        charInfo = data.giver
    end


    local icon = ResMgr:getSmallPortrait(charInfo["icon"])
    self:setImage("ShapeImage", icon)
    self:setItemImageSize("ShapeImage")
    
    self:setNumImgForPanel("ShapeImage", ART_FONT_COLOR.NORMAL_TEXT, charInfo.level, false, LOCATE_POSITION.LEFT_TOP, 21)

    
    self:setLabelText("NameLabel", gf:getRealName(charInfo.name))
    
    self:setCtrlDisplay(giveType)
    
    -- 沙漏
    self:setHourglass()
end

function GiveApplyDlg:onUpdate()
    self:setTimeHour()
end

function GiveApplyDlg:setCtrlDisplay(giveType)
    if giveType == IS_SEND then
        self:setLabelText("Label_65", CHS[4100304])
    elseif giveType == IS_RECEIVED then
        self:setLabelText("Label_65", CHS[4100305])
    end
    
    self:setCtrlVisible("CancelButton", giveType == IS_SEND)
    self:setCtrlVisible("RefuseButton", giveType ~= IS_SEND)
    self:setCtrlVisible("AgreeButton", giveType ~= IS_SEND)
end

-- 设置倒计时进度条
function GiveApplyDlg:setHourglass(time)
    time = time or HOURGLASS
    -- 进度条倒计时
    local function hourglassCallBack(parameters)
        performWithDelay(self.root, function()
            
            self:onCloseButton()
        end, 0.1)
    end
    self:setProgressBarByHourglass("ProgressBar", time, 100, hourglassCallBack, nil, true)
end

-- 设置秒数
function GiveApplyDlg:setTimeHour()
    local barCtrl = self:getControl("ProgressBar")
    local time = barCtrl:getPercent() * 30 * 0.01
    local timeHour = math.ceil(time)
    self:setLabelText("LeftTimeLabel", timeHour .. CHS[3002392])
end

function GiveApplyDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function GiveApplyDlg:onRefuseButton(sender, eventType)
    self:onCloseButton()
end

function GiveApplyDlg:onAgreeButton(sender, eventType)
    GiveMgr:openGiving()
    self.notSendFail = true
    self:onCloseButton()
end

function GiveApplyDlg:MSG_COMPLETE_GIVING(data)
    self.notSendFail = true
    self:onCloseButton()
end

function GiveApplyDlg:MSG_OPEN_GIVING_WINDOW(data)
    self.notSendFail = true
    self:onCloseButton()
end

return GiveApplyDlg
