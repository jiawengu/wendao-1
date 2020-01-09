-- PartyWelfareDlg.lua
-- Created by songcw Mar/9/2015
-- 帮派福利界面

local PartyWelfareDlg = Singleton("PartyWelfareDlg", Dialog)

-- 俸禄福利      活力条件值
local CONDITION_ACTIVE_SALARY     = 2000

-- 功臣奖励     活力条件值
local CONDITION_ACTIVE_CONTRIBUTOR     = 6750

function PartyWelfareDlg:init()
    local salaryPanel = self:getControl("SalaryPanel")
    self:bindListener("QueryButton", self.onSalaryButton, salaryPanel)
    self:bindListener("SalaryPanel", self.onClickCell)
    
    local contributorsPanel = self:getControl("ContributorsPanel")
    self:bindListener("QueryButton", self.onContributorButton, contributorsPanel)
    self:bindListener("ContributorsPanel", self.onClickCell)
    
    local shopPanel = self:getControl("ShopPanel")
    self:bindListener("QueryButton", self.onShopButton, shopPanel)
    self:bindListener("ShopPanel", self.onClickCell)
    
    self:setCtrlVisible("Slider", false)
    
    local skillPanel = self:getControl("SkillPanel")
    self:bindListener("QueryButton", self.onViewButton, skillPanel)
    self:bindListener("SkillPanel", self.onClickCell)
    
    local redBagPanel = self:getControl("RedBagPanel")
    self:bindListener("QueryButton", self.onRedBagButton, redBagPanel)
    self:bindListener("RedBagPanel", self.onClickCell)
    
    --self:bindListViewListener("ListView", self.onClickCell)
    self:bindListener("TouchClosePanel", self.onTouchClosePanel)
    self:setCtrlVisible("TouchClosePanel", false)
    
    
    -- 设置标题
    if Me:queryBasic("party/name") ~= "" then 
        self:setLabelText("TitleLabel1", Me:queryBasic("party/name"))
        self:setLabelText("TitleLabel2", Me:queryBasic("party/name"))
    end
    
    gf:CmdToServer("CMD_PARTY_GET_BONUS", {type = 3}) -- 查询帮派俸禄
    gf:CmdToServer("CMD_PARTY_GET_BONUS", {type = 4}) -- 刷新功臣奖励
    self:hookMsg("MSG_GENERAL_NOTIFY")

end


function PartyWelfareDlg:onClickCell(sender, enventType) 
    local tag = sender:getTag() 
    self:setAllInfoPanelVisible(false)
    
    if tag == 2 then
        DlgMgr:openDlg("GongcDlg")
    else
        self:setCtrlVisible("InfoPanel"..tag, true)
    end
    
    self:setCtrlVisible("TouchClosePanel", true)
end

function PartyWelfareDlg:setAllInfoPanelVisible(isVisble)
    for i = 1, 5 do
        self:setCtrlVisible("InfoPanel"..i, isVisble)
    end
    
    self:setCtrlVisible("TouchClosePanel", isVisble)
    DlgMgr:closeDlg("GongcDlg")
end

function PartyWelfareDlg:onTouchClosePanel()
    self:setAllInfoPanelVisible(false)
end

function PartyWelfareDlg:onSalaryButton(sender, eventType)
    PartyMgr:getPartySalary()
end

function PartyWelfareDlg:onContributorButton(sender, eventType)
    PartyMgr:getPartyContributor()
end

function PartyWelfareDlg:onViewButton(sender, eventType)
    DlgMgr:openDlg("PartySkillDlg")

  --[[  local tabDlg = DlgMgr.dlgs["PartyInfoTabDlg"]
    
    performWithDelay(sender, function ()
        if tabDlg then
            tabDlg.group:setSetlctByName("SkillCheckBox")
        else
            DlgMgr:openDlg("PartySkillDlg")
            DlgMgr.dlgs["PartyInfoTabDlg"].group:setSetlctByName("SkillCheckBox")
        end	
    end,0)]]
    
end

function PartyWelfareDlg:onShopButton(sender, eventType)
    PartyMgr:refreshPartyShop(0)
end

function PartyWelfareDlg:onRedBagButton(sender, eventType)
    local count = PartyMgr:getPartyPopulation()
    if count and count < PartyMgr:getLastRedBagNum() then
        gf:ShowSmallTips(string.format(CHS[6000475], 20))
        return
    end
    DlgMgr:openDlg("PartyRedBagDlg")
end

function PartyWelfareDlg:refreshSalary(salary)
    local salaryPanel = self:getControl("SalaryPanel")
    local getBtn = self:getControl("QueryButton", Const.UIButton, salaryPanel)
    
    if string.match(salary, "-(%d+)") then
        local text, fontColor = gf:getArtFontMoneyDesc(tonumber(0))
        self:setNumImgForPanel("SalaryNumberPanel", fontColor, text, false, LOCATE_POSITION.MID, 21)   
        gf:grayImageView(getBtn)    
        self:setCtrlVisible("Label_1", false, getBtn)
        self:setCtrlVisible("Label_2", false, getBtn)
        self:setCtrlVisible("Label_3", true, getBtn)
        self:setCtrlVisible("Label_4", true, getBtn)
        getBtn:setTouchEnabled(false)
    else
        local text, fontColor = gf:getArtFontMoneyDesc(tonumber(salary))
        self:setNumImgForPanel("SalaryNumberPanel", fontColor, text, false, LOCATE_POSITION.MID, 21)     
        gf:resetImageView(getBtn)
        self:setCtrlVisible("Label_1", true, getBtn)
        self:setCtrlVisible("Label_2", true, getBtn)
        self:setCtrlVisible("Label_3", false, getBtn)
        self:setCtrlVisible("Label_4", false, getBtn)
        getBtn:setTouchEnabled(true)
    end
end

function PartyWelfareDlg:refreshContribution(contribution)
    local contributorsPanel = self:getControl("ContributorsPanel")
    local getBtn = self:getControl("QueryButton", Const.UIButton, contributorsPanel)

    if contribution ~= "-1" then
        gf:resetImageView(getBtn)
        self:setCtrlVisible("Label_1", true, getBtn)
        self:setCtrlVisible("Label_2", true, getBtn)
        self:setCtrlVisible("Label_3", false, getBtn)
        self:setCtrlVisible("Label_4", false, getBtn)
        getBtn:setTouchEnabled(true)
    else
        gf:grayImageView(getBtn)    
        self:setCtrlVisible("Label_1", false, getBtn)
        self:setCtrlVisible("Label_2", false, getBtn)
        self:setCtrlVisible("Label_3", true, getBtn)
        self:setCtrlVisible("Label_4", true, getBtn)
       getBtn:setTouchEnabled(false)
    end

end

function PartyWelfareDlg:MSG_GENERAL_NOTIFY(data)
    local notify = data.notify
    if NOTIFY.NOTIFY_QUERY_PARTY_SALARY == notify then  -- 刷新俸禄
        self:refreshSalary(data.para)
    elseif NOTIFY.NOTIFY_QUERY_PARTY_CONTRIBUTOR == notify then  -- 刷新功臣
        self:refreshContribution(data.para)
    end
end

return PartyWelfareDlg
