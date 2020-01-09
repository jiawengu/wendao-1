-- UseBarDlg.lua
-- Created by zhengjh Feb/29/2016
-- 采集进度条界面

local UseBarDlg = Singleton("UseBarDlg", Dialog)

function UseBarDlg:init()
    self:getControl("ProgressBar"):setPercent(0)
    if GameMgr:isInPartyWar() then
		-- WDSY-28581 	帮战中不冻屏
        Me:setCanMove(false)

        DlgMgr:closeDlg("CharPortraitDlg")
        DlgMgr:closeDlg("NpcDlg")
        DlgMgr:closeDlg("UserListDlg")
    else
        gf:frozenScreen(0, 0)
    end
    self.times = 1
end

function UseBarDlg:cleanup()
    EventDispatcher:dispatchEvent("GATHER_FINISHED")

    if GameMgr:isInPartyWar() then
        Me:setCanMove(true)
    end
    gf:unfrozenScreen(true)
end

function UseBarDlg:setInfo(data)
    data.word = string.gsub(data.word, "…", "")  -- 现在不需要"…"
    self:setLabelText("LabelNote_0", data.word)
    self:setLabelText("LabelNote_1", data.word)
    if type(data.icon) == 'string' then
        self:setImage("ManaImage", data.icon)
    else
        -- number
        self:setImage("ManaImage", ResMgr:getGatherIcon(data.icon))
    end

    self:setBarInfo(data)

    -- 春节幸运红包界面需调整位置
    if data.gather_style == "spring_day" then
        local mainPanel = self:getControl("MainPanel")
        mainPanel:setPosition(cc.p(510, 343))
        mainPanel:setAnchorPoint(cc.p(0, 1))
        mainPanel:requestDoLayout()
    end

end

function UseBarDlg:setBarInfo(data)
    local function callBack()
        performWithDelay(self.root, function()
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_FINISH_GATHER, 1)
            DlgMgr:closeDlg(self.name)
        end, 0.1)
    end


	-- 小于3秒就不从当前时间开始，直接强制走3秒采集过程，不然误差存在时，表现不好
    if data.end_time - data.start_time <= 3 then
        local ti = data.end_time - data.start_time
        self:setProgressBarByHourglass("ProgressBar", ti * 1000, 0, callBack, nil, false)
        self:createPointAcyion()
        return
    end

    local ti = data.end_time - gf:getServerTime()
    if ti <= 0 then
        self:onCloseButton()
        return
    end
    local start = math.max(gf:getServerTime() - data.start_time, 0)/ (data.end_time - data.start_time) * 100
    self:setProgressBarByHourglassToEnd("ProgressBar", ti * 1000, start, 100, callBack)

    self:createPointAcyion()
end

function UseBarDlg:createPointAcyion()
    local function setPointAction()
        if self.times % 4 == 1 then
            self:setCtrlVisible("LabelNote_2", true)
            self:setCtrlVisible("LabelNote_5", true)
            self:setCtrlVisible("LabelNote_3", false)
            self:setCtrlVisible("LabelNote_6", false)
            self:setCtrlVisible("LabelNote_4", false)
            self:setCtrlVisible("LabelNote_7", false)
        elseif self.times % 4 == 2 then
            self:setCtrlVisible("LabelNote_2", true)
            self:setCtrlVisible("LabelNote_5", true)
            self:setCtrlVisible("LabelNote_3", true)
            self:setCtrlVisible("LabelNote_6", true)
            self:setCtrlVisible("LabelNote_4", false)
            self:setCtrlVisible("LabelNote_7", false)
        elseif self.times % 4 == 3 then
            self:setCtrlVisible("LabelNote_2", true)
            self:setCtrlVisible("LabelNote_5", true)
            self:setCtrlVisible("LabelNote_3", true)
            self:setCtrlVisible("LabelNote_6", true)
            self:setCtrlVisible("LabelNote_4", true)
            self:setCtrlVisible("LabelNote_7", true)
        elseif self.times % 4 == 0 then
            self:setCtrlVisible("LabelNote_2", false)
            self:setCtrlVisible("LabelNote_5", false)
            self:setCtrlVisible("LabelNote_3", false)
            self:setCtrlVisible("LabelNote_6", false)
            self:setCtrlVisible("LabelNote_4", false)
            self:setCtrlVisible("LabelNote_7", false)
        end

        self.times = self.times + 1
    end

    schedule(self.root, setPointAction, 0.3)
end


return UseBarDlg
