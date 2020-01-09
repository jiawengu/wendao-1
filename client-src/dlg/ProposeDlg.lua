-- ProposeDlg.lua
-- Created by zhengjh Jun/06/2016
-- 求婚界面

local ProposeDlg = Singleton("ProposeDlg", Dialog)
local TIME = 60

function ProposeDlg:init()
    self:bindListener("AgreeButton", self.onAgreeButton)
    self:bindListener("RefuseButton", self.onRefuseButton)

    -- 设置倒计时进度条
    self:setHourglass()

    -- 秒数更新
    schedule(self.root, function()
        self:setTimeHour()
    end, 0)

    self:hookMsg("MSG_CLOSE_TIQIN_DLG")
end

function ProposeDlg:setInfo(data)

    local maleName = ""
    local femaleName = ""
    for i = 1, data.count do
        if data[i].gender == GENDER_TYPE.MALE then
            self:setPlayerInfo("MalePanel", data[i].org_icon, data[i].suit_icon, data[i].weapon_icon, data[i].org_icon)
            maleName = data[i].name
            -- 仙魔光效
            if data[i]["upgrade/type"] then
                self:addUpgradeMagicToCtrl("MalePanel", data[i]["upgrade/type"], nil, true)
            end
        else
            self:setPlayerInfo("FemalePanel", data[i].org_icon, data[i].suit_icon, data[i].weapon_icon, data[i].org_icon)
            femaleName = data[i].name
            -- 仙魔光效
            if data[i]["upgrade/type"] then
                self:addUpgradeMagicToCtrl("FemalePanel", data[i]["upgrade/type"], nil, true)
            end
        end
    end

	local gender = Me:queryInt("gender")
	local wordStr = ""
	if GENDER_TYPE.MALE == gender then
        wordStr = string.format(CHS[6000279], femaleName)
        self:setCtrlVisible("RefuseButton", false)
        self:setCtrlVisible("AgreeButton", false)
	else
        wordStr = string.format(CHS[6000278], maleName)
	end

	local wordPanel = self:getControl("WordPanel")
    local lableText = CGAColorTextList:create(true)
    lableText:setFontSize(19)
    lableText:setString(wordStr)
    lableText:setContentSize(wordPanel:getContentSize().width, 0)
    lableText:updateNow()
    lableText:setDefaultColor(COLOR3.LIGHT_BROWN.r, COLOR3.LIGHT_BROWN.g, COLOR3.LIGHT_BROWN.b)
    local labelW, labelH = lableText:getRealSize()
    local layerColor = tolua.cast(lableText, "cc.LayerColor")
    wordPanel:addChild(layerColor)
    local pos = cc.p((wordPanel:getContentSize().width - labelW) * 0.5, (wordPanel:getContentSize().height - labelH) * 0.5 + labelH)
    layerColor:setPosition(pos)
end

function ProposeDlg:setPlayerInfo(panelName, icon, suitIcon, weaponIcon, originIcon)
    -- 有套装显示套装icon
    if suitIcon and suitIcon ~= 0 then
        self:setPortrait(panelName, suitIcon, weaponIcon, self.root, true, nil, nil, nil, originIcon)
    else
        self:setPortrait(panelName, icon, weaponIcon, self.root, true)
    end
end

-- 设置倒计时进度条
function ProposeDlg:setHourglass(time)
    time = time or TIME
    -- 进度条倒计时
    local function hourglassCallBack(parameters)
        performWithDelay(self.root, function()
           self:onRefuseButton()
        end, 0.1)
    end
    self:setProgressBarByHourglass("ProgressBar", time * 1000, 100, hourglassCallBack, nil, true)
end

-- 设置秒数
function ProposeDlg:setTimeHour()
    local barCtrl = self:getControl("ProgressBar")
    local time = barCtrl:getPercent() * TIME * 0.01
    local timeHour = math.ceil(time)
    self:setLabelText("LeftTimeLabel", timeHour .. CHS[3002392])
end

function ProposeDlg:onAgreeButton(sender, eventType)
    MarryMgr:sendProposeReslutToServer(MarryMgr.agree)
    DlgMgr:closeDlg(self.name)
end

function ProposeDlg:onRefuseButton(sender, eventType)
    MarryMgr:sendProposeReslutToServer(MarryMgr.refuse)
    DlgMgr:closeDlg(self.name)
end

function ProposeDlg:MSG_CLOSE_TIQIN_DLG()
    DlgMgr:closeDlg(self.name)
end

return ProposeDlg
