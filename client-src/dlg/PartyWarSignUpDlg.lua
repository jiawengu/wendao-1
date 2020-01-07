-- PartyWarSignUpDlg.lua
-- Created by liuhb Apr/7/2015
-- 帮战报名

local PartyWarSignUpDlg = Singleton("PartyWarSignUpDlg", Dialog)

local BID_SHIWAN = 100000
local BID_YIBAIWAN = 1000000
local PER_PAGE_COUNT                 = 12

function PartyWarSignUpDlg:init()
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("SignUpButton", self.onSignUpButton)
    self:bindListener("BidButton_1", self.onBidButton_1)
    self:bindListener("BidButton_2", self.onBidButton_2)
    self:bindListener("RefreshButton", self.onRefreshButton)

    -- 初始化控件
    self:initControl()


    self:bindFloatPanelListener("NoteInfoPanel")

    self.start = 1
 
    -- 填充数据
    self:bindListViewByPageLoad("PartyListView", "TouchListPanel", function(dlg, percent)
        if percent > 100 then
            -- 下拉获取下一页
                local partyList = PartyWarMgr:getSignUpList(self.start, PER_PAGE_COUNT)
                if not partyList then return end
                self:pushData(partyList)          
        end
    end)

    self:hookMsg("MSG_PARTY_WAR_BID_INFO")
end

-- 重载关闭函数
function PartyWarSignUpDlg:close(now)
    Dialog.close(self, now)
    self:releaseCloneCtrl("simplePanel")
end

-- 初始化界面控件
function PartyWarSignUpDlg:initControl()
    self.simplePanel = self:getControl("OneRowPratyInfoPanel")
    self.simplePanel:retain()
end

function PartyWarSignUpDlg:getColorLimit()
    -- 获取数据
    local signInfo = PartyWarMgr:getSignUpList()

    -- 填充列表数据
    local count = signInfo.count   
    local greenLimit = 0
    if count > 24 then
        greenLimit = 24
    end    
    
    return greenLimit
end

function PartyWarSignUpDlg:pushData(partyList)

    local innerContainer = self.list:getInnerContainerSize()
    innerContainer.height = innerContainer.height + #partyList * self.simplePanel:getContentSize().height
    self.list:setInnerContainerSize(innerContainer)

    for i = 1, #partyList do
        -- 复制出新的控件        
        local newRow = self.simplePanel:clone()
        local defColor = COLOR3.TEXT_DEFAULT
        if (#self.list:getItems() + 1) <= self:getColorLimit() then defColor = COLOR3.GREEN end
        self:setLabelText("RankValueLabel", (#self.list:getItems() + 1), newRow, defColor)
        self:setLabelText("NameValueLabel", partyList[i].partyName, newRow, defColor)
        self:setLabelText("MoneyNameValueLabel", partyList[i].cash, newRow, defColor)
        self:setCtrlVisible("BackImage_2", (#self.list:getItems() + 1) % 2 == 0, newRow)
        self.list:pushBackCustomItem(newRow)
    end
    
    self.list:requestRefreshView()
    self.start = self.start + #partyList

end

-- 设置数据
function PartyWarSignUpDlg:setSignUpInfo()
    -- 初始化列表控件
    self.list, self.size = self:resetListView("PartyListView") 
    self.list:setInnerContainerSize(cc.p(0, 0))
    
    -- 设置分页列表
    self.start = 1
    local signInfoList = PartyWarMgr:getSignUpList(self.start, PER_PAGE_COUNT)
    self:pushData(signInfoList)    
    
    -- 设置其他信息
    local signInfo = PartyWarMgr:getSignUpList()
    -- 填充列表数据
    local count = signInfo.count    
    local myParty = {}    
    for i = 1, count do        
        if Me:queryBasic("party") == signInfo.signList[i].partyName then
            table.insert(myParty, signInfo.signList[i])
            myParty[1].rank = i
        end
    end

    -- 填充截止时间
    self:setLabelText("TimeLabel", gf:getServerDate("%Y-%m-%d %H:%M", tonumber(signInfo.forbidTime)))    

    -- 填充帮战状态
    if count == 0 then
        self:setLabelText("StateNoteLabel", CHS[4000411])
    elseif count >= 1 and count <= 8 then
        self:setLabelText("StateNoteLabel", CHS[5000112])
    elseif count >= 9 and count <= 16 then
        self:setLabelText("StateNoteLabel", CHS[5000113])
    elseif count >= 17 and count <= 24 then
        self:setLabelText("StateNoteLabel", CHS[5000114])
    else
        self:setLabelText("StateNoteLabel", CHS[5000115])
    end
    
    -- 我的帮派信息
    if myParty[1] then
        local panel = self:getControl("OwnPanel")
        self:setLabelText("RankValueLabel", myParty[1].rank, panel)
        self:setLabelText("NameValueLabel", myParty[1].partyName, panel)
        self:setLabelText("MoneyNameValueLabel", myParty[1].cash, panel)
    end
    
    self:updateLayout("SignUpTimePanel")
    self:updateLayout("NotePanel")
end

function PartyWarSignUpDlg:onNoteButton(sender, eventType)
    self:setCtrlVisible("NoteInfoPanel", true)
    --gf:showTipInfo(CHS[5000116], sender)
end

function PartyWarSignUpDlg:onSignUpButton(sender, eventType)
    PartyWarMgr:signUpOper()
end

function PartyWarSignUpDlg:onBidButton_1(sender, eventType)
    PartyWarMgr:assignCashOper(BID_SHIWAN)
end

function PartyWarSignUpDlg:onBidButton_2(sender, eventType)
    PartyWarMgr:assignCashOper(BID_YIBAIWAN)
end

function PartyWarSignUpDlg:onRefreshButton(sender, eventType)
    PartyWarMgr:refreshSignUpList()
end
 
function PartyWarSignUpDlg:MSG_PARTY_WAR_BID_INFO(data)
    self:setSignUpInfo()
end

return PartyWarSignUpDlg
