-- PartyApplyDlg.lua
-- Created by songcw Mar/21/2015
-- 任命界面

local PartyApplyDlg = Singleton("PartyApplyDlg", Dialog)

function PartyApplyDlg:init()    
    local applyPanel = self:getControl("ApplyPanel")
    applyPanel:removeAllChildren()
    
    self.queryMember = nil
    self.heir = nil
    
    self.root:setAnchorPoint(0, 0)
end

function PartyApplyDlg:setQueryAndHeir(queryMember, heir)
    self.queryMember = queryMember
    self.heir = heir
end

function PartyApplyDlg:setJobList()
    local applyPanel = self:getControl("ApplyPanel")
    local viewList = ccui.ListView:create()
    local panelSize = applyPanel:getContentSize()    
    viewList:setContentSize(panelSize)
    local height = 0
    if PartyMgr:isPartyLeader() then
        if self.heir == nil or self.heir == "" then
            -- 帮派没有帮主继承人，第一个显示传位
            local button = ccui.Button:create(ResMgr.ui.button_file, ResMgr.ui.button_file, ResMgr.ui.button_file, ccui.TextureResType.plistType)
            button:setTitleText(CHS[4000154])        
            button:setTag(-1)
            self:bindTouchEndEventListener(button,self.applyJob)
            viewList:pushBackCustomItem(button)

            height = button:getContentSize().height
        else
            if self.heir == self.queryMember.name then
                -- 帮派没有帮主继承人，第一个显示传位
                local button = ccui.Button:create(ResMgr.ui.button_file, ResMgr.ui.button_file, ResMgr.ui.button_file, ccui.TextureResType.plistType)
                button:setTitleText(CHS[4000260])        
                button:setTag(-2)
                self:bindTouchEndEventListener(button,self.applyJob)
                viewList:pushBackCustomItem(button)

                height = button:getContentSize().height
            end
        end
    end
    
    local str = self.queryMember.job    
    local pos = gf:findStrByByte(str, ":")

    while(pos ~= nil) do
        local jobName = string.sub(str, 1, pos - 1)
        local cutPos = gf:findStrByByte(str, ",") or 0
        local enable = string.sub(str, pos + 1, cutPos - 1)        
        str = string.sub(str, cutPos + 1, -1)
        pos = gf:findStrByByte(str, ":")
        if cutPos == 0 then pos = nil end

        if enable ~= "-1" then
            local button = ccui.Button:create(ResMgr.ui.button_file, ResMgr.ui.button_file, ResMgr.ui.button_file, ccui.TextureResType.plistType)
            button:setTitleText(jobName)
            button:setTag(enable)
            self:bindTouchEndEventListener(button,self.applyJob)
            viewList:pushBackCustomItem(button)

            height = height + button:getContentSize().height
        end
    end
    
    applyPanel:addChild(viewList)
end

function PartyApplyDlg:applyJob(sender, eventType)
    local jobId = sender:getTag()
    local jobname = sender:getTitleText()

    if self:applyCondition() == false then return end

    if jobId == -1 then            
        -- 传位
        PartyMgr:demiseMember(self.queryMember.name, self.queryMember.gid)
    elseif jobId == -2 then
        -- 取消传位
        PartyMgr:cancelDemiseMember()
    else
        -- 任命
        local function sendApplyCmd()
            PartyMgr:applyMember(self.queryMember.name, self.queryMember.gid, jobId)
        end

        -- [4000155] = "你确认任命#Y%s#n为#R%s#n？",
        local tips = string.format(CHS[4000155], self.queryMember.name, jobname)
        gf:confirm(tips, sendApplyCmd)  
    end
        
    self:onCloseButton()
end

function PartyApplyDlg:applyCondition()
    if Me:queryBasic("party/job") ~= CHS[4000153] and Me:queryBasic("party/job") ~= CHS[4000157] then
        gf:ShowSmallTips(CHS[4000219])
        return false
    end

    if Me:queryBasic("name") == self.queryMember.name then
        gf:ShowSmallTips(CHS[4000200])
        return false
    end

    local pos = gf:findStrByByte(self.queryMember.job, ":")
    if string.sub(self.queryMember.job, 1, pos - 1) == CHS[4000153] then
        gf:ShowSmallTips(CHS[4000262])
        return false
    end

    return true
end

function PartyApplyDlg:onJobButton_1(sender, eventType)
end



return PartyApplyDlg
