-- QuanmPK2InfoDlg.lua
-- Created by lixh Jul/16/2018
-- 全民PK赛第2版 比赛信息界面

local QuanmPK2InfoDlg = Singleton("QuanmPK2InfoDlg", Dialog)

function QuanmPK2InfoDlg:init()
    self:setFullScreen()
    self:bindListener("ShidaoButton", self.onShidaoButton)
    self:bindListener("CloseButton", self.onCloseButton)

    QuanminPK2Mgr:requestQmpkInfo()
end

function QuanmPK2InfoDlg:onUpdate()
    if not self.data then return end

    -- 15秒请求新数据
    local curTime = gfGetTickCount()
    if not self:getLastOperTime("lastTime") then self:setLastOperTime("lastTime", curTime) end
    if self:isOutLimitTime("lastTime", 15 * 1000) then
        self:setLastOperTime("lastTime", curTime)
        QuanminPK2Mgr:requestQmpkInfo()
    end
end

function QuanmPK2InfoDlg:refreshInfo()
    self.data = QuanminPK2Mgr:getFubenData()
    if not self.data then return end

    self:setCtrlVisible("JiFenPanel", false)
    self:setCtrlVisible("TaoTaiPanel", false)
    if string.match(self.data.status, "score") then
        self:setCtrlVisible("JiFenPanel", true)
        self:setJiFenPanel()
    elseif string.match(self.data.status, "kickout") then
        self:setCtrlVisible("TaoTaiPanel", true)
        self:setTaotaiPanel("kickout")
    elseif string.match(self.data.status, "final") then
        if self.data.cobId <= 3 then
            self:setCtrlVisible("TaoTaiPanel", true)
            self:setTaotaiPanel("kickout")
        else
            self:setCtrlVisible("TaoTaiPanel", true)
            self:setTaotaiPanel("final")
        end
    end
end

-- 设置积分赛内容
function QuanmPK2InfoDlg:setJiFenPanel()
    local text = self.data.cobFlag
    local win, winMax, score, order = string.match(text, "(.+),(.+),(.+),(.+)")
    if not win or not winMax or not score or not order then return end
    local root = self:getControl("ShrinkPanel", Const.UIPanel, "JiFenPanel")
    self:setLabelText("WinTimesLabel", string.format(CHS[7100306], win), root)
    self:setLabelText("WinMaxLabel", string.format(CHS[7100307], winMax), root)
    self:setLabelText("ScoreLabel", string.format(CHS[7100308], score), root)
    if tonumber(order) <= 0 then
        -- 排名小于等于0时，显示为"无"
        self:setLabelText("CurrentOrderLabel", string.format(CHS[7100309], CHS[7120141]), root)
    else
        self:setLabelText("CurrentOrderLabel", string.format(CHS[7100309], order), root)
    end

    self:setCtrlVisible("TitleImage_3", false, "JiFenPanel")
    self:setCtrlVisible("TitleImage_4", false, "JiFenPanel")

    self:setLeftTime(self:getControl("JiFenPanel"))
end

-- 设置淘汰赛内容
function QuanmPK2InfoDlg:setTaotaiPanel(type)
    self:setCtrlVisible("TaoTai", false, "TaoTaiPanel")
    self:setCtrlVisible("JueSai", false, "TaoTaiPanel")
    local allFightNum = 3
    local root = self:getControl("TaoTai", Const.UIPanel, "TaoTaiPanel")
    if type  == "final" then
        root = self:getControl("JueSai", Const.UIPanel, "TaoTaiPanel")
        allFightNum = 5
    end

    root:setVisible(true)
    self:setLabelText("MyTeamLabel", self.data.myName, root)
    self:setLabelText("OppTeamLabel", self.data.otherName, root)

    for i = 1, allFightNum do
        if i <= self.data.cobNum then
            local result = tonumber(string.sub(self.data.cobFlag, i, i))
            self:setWarResult(i, result, root)
        else
            self:setWarResult(i, nil, root)
        end
    end

    self:setLeftTime(self:getControl("TaoTaiPanel"))
end

-- 设置时间
function QuanmPK2InfoDlg:setLeftTime(root)
    local panel = self:getControl("LeftTimePanel", nil, root)
    panel:stopAllActions()

    if not self.data then return end
    local curTime = gf:getServerTime()
    local waitTime = 0
    self:setCtrlVisible("TitleImage_4", true, "JiFenPanel")
    if curTime >= self.data.enterTime and curTime < self.data.startTime then
        -- 入场准备阶段,需要倒计时
        waitTime = self.data.startTime - curTime - 1
        self:setCtrlVisible("TitleImage_3", true, "JiFenPanel")
        self:setCtrlVisible("TitleImage_4", false, "JiFenPanel")
    elseif curTime >= self.data.startTime and curTime < self.data.pairTime then
        -- time7 到time8
        waitTime = self.data.pairTime - curTime - 1
    elseif curTime < self.data.restTime then
        waitTime = self.data.restTime - curTime - 1
    end

    -- 默认隐藏倒计时
    self:setCtrlVisible("LeftTimePanel", false, root)

    if self.data.hasConfirmCob == 1 then
        -- 有未确认结果的比赛，先不显示倒计时
        return
    end

    if waitTime > 0 then
        -- 需要倒计时
        self:showTimeInfo(waitTime, panel)
        self:setCtrlVisible("LeftTimePanel", true, root)

        local function func()
            if waitTime <= 0 then
                panel:stopAllActions()
                self:setCtrlVisible("LeftTimePanel", false, root)

                -- 倒计时结束刷新界面
                QuanminPK2Mgr:requestQmpkInfo()
            else
                self:setCtrlVisible("LeftTimePanel", true, root)
                waitTime = waitTime - 1
                self:showTimeInfo(waitTime, panel)
            end
        end

        schedule(panel, func, 1)
    end
end

function QuanmPK2InfoDlg:showTimeInfo(waitTime, panel)
    local h = math.floor(waitTime) / 3600
    local m = math.floor((waitTime % 3600) / 60)
    local s = waitTime % 60
    self:setLabelText("LeftTimeLabel_1", string.format("%02d:%02d:%02d", h, m, s) , panel)
    self:setLabelText("LeftTimeLabel_2", string.format("%02d:%02d:%02d", h, m, s) , panel)
end

function QuanmPK2InfoDlg:setWarResult(key, result, panel)
    local myPanel = self:getControl("MyResultPanel", nil, panel)
    local oppPanel = self:getControl("OppResultPanel", nil, panel)

    self:setCtrlVisible("Image_" .. key, true, myPanel)
    self:setCtrlVisible("Image_" .. key, true, oppPanel)

    if result then
        if result == 1 then
            self:setImagePlist("Image_" .. key, ResMgr.ui.party_war_win, myPanel)
            self:setImagePlist("Image_" .. key, ResMgr.ui.party_war_lose, oppPanel)
        else
            self:setImagePlist("Image_" .. key, ResMgr.ui.party_war_lose, myPanel)
            self:setImagePlist("Image_" .. key, ResMgr.ui.party_war_win, oppPanel) 
        end
    else
        self:setImagePlist("Image_" .. key, ResMgr.ui.touming, myPanel)
        self:setImagePlist("Image_" .. key, ResMgr.ui.touming, oppPanel) 
    end
end

function QuanmPK2InfoDlg:onShidaoButton(sender, eventType)
    self:setCtrlVisible("MainPanel", true)
    self:setCtrlVisible("ShidaoButton", false)
end

function QuanmPK2InfoDlg:onCloseButton(sender, eventType)
    self:setCtrlVisible("MainPanel", false)
    self:setCtrlVisible("ShidaoButton", true)
end

function QuanmPK2InfoDlg:cleanup()
    self.data = nil
end

return QuanmPK2InfoDlg
