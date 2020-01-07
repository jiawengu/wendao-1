-- KidProgressDlg.lua
-- Created by songcw Feb/02/2019
-- 娃娃喂菜肴进度条

local KidProgressDlg = Singleton("KidProgressDlg", Dialog)

local MAX_TIME = 7

function KidProgressDlg:init()
    self:getControl("ProgressBar"):setPercent(0)


    local dlg = DlgMgr:getDlgByName("KidRearingDlg")
    if dlg then dlg:setVisible(false) end
end

function KidProgressDlg:onUpdate()
    if not self.data then return end
    local leftTime = self.data.endTime - gfGetTickCount()
    leftTime = math.max(leftTime / 1000, 0)
    self:setLabelText("ValueLabel", string.format(CHS[4101323], leftTime))    -- 剩余时间：%d秒
    self:setLabelText("ValueLabel2", string.format(CHS[4101323], leftTime))
end

function KidProgressDlg:setInfo(data)
    data.endTime = gfGetTickCount() + MAX_TIME * 1000
    self.data = data
    local info = HomeChildMgr:getFuyangCfg(data.op_type)
    self:setLabelText("CaseNameLabel", info.name)
    self:setImage("IconImage", info.icon)
    self:onUpdate()

    local function callBack()
        performWithDelay(self.root, function()
            DlgMgr:closeDlg(self.name)
         --   gf:CmdToServer("CMD_CHILD_STOP_RAISE_PROGRESS")
        end)
    end

    if data.result == 1 then

        self:setProgressBarByHourglassToEnd("ProgressBar", data.ti * 1000, 0, 100, callBack)
    else

        self:setProgressBarByHourglassToEnd("ProgressBar", 3 * 1000, 0, 3 / 7 * 100, callBack)
    end
end

function KidProgressDlg:cleanup()
    gf:unfrozenScreen(true)

    local dlg = DlgMgr:getDlgByName("KidRearingDlg")
    if dlg then dlg:setVisible(true) end
end

return KidProgressDlg
