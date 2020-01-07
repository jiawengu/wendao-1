-- PartyActiveDlg.lua
-- Created by songcw May/9/2015
-- 帮派活动界面（新）

local PartyActiveDlg = Singleton("PartyActiveDlg", Dialog)

function PartyActiveDlg:init()
    -- 标题
    self:setLabelText("TitleLabel_1", Me:queryBasic("party/name"))
    self:setLabelText("TitleLabel_2", Me:queryBasic("party/name"))

    -- 克隆
    local activePanel = self:getControl("ActivePanel_1", Const.UIPanel)
    self:setCtrlVisible("ChosenEffectImage", false, activePanel)
    self:setCtrlVisible("SetButton", false, activePanel)
    self:setCtrlVisible("NotePanel", false, activePanel)
    self.activePanel = activePanel:clone()
    self.activePanel:retain()

    self:setInfomartion()
    self:hookMsg("MSG_PARTY_INFO")
    self:hookMsg("MSG_PARTY_ZHIDUOXING_INFO")

    -- 请求帮派守卫信息
    PartyMgr:queryPartyZdxInfo()
    PartyMgr:queryPartyQdlxOrPyjs()
    PartyMgr:queryPartHangba()
    PartyMgr:queryPartyShouwei()
    PartyMgr:queryPartyJS(0)

    if not PartyMgr:getPartyInfo() then
        PartyMgr:queryPartyInfo()
    end
end

function PartyActiveDlg:cleanup()
    self:releaseCloneCtrl("activePanel")
end

function PartyActiveDlg:setInfomartion()
    local partyActiveView = self:resetListView("ListView", 5)
    local partyActives = PartyMgr:getPartyActiveInfo()
    for i = 1, #partyActives do
        local panel = self.activePanel:clone()
        panel:setTag(i)
        self:getControl("NoteButton", nil, panel):setTag(i)
        self:bindListener("NoteButton", self.onNoteButton, panel)
        self:bindTouchEndEventListener(panel, self.chooseActive)
        self:setSingleActive(partyActives[i], panel)
        partyActiveView:pushBackCustomItem(panel)
    end

 --   self:chooseActive()
end

function PartyActiveDlg:setButtonDoubleText(content, btnName, root)
    local btn = self:getControl(btnName, nil, root)
    if not btn then return end

    self:setLabelText("Label1", content, btn)
    self:setLabelText("Label2", content, btn)
end

function PartyActiveDlg:setButtonVisibleFalse(panel)
    self:setCtrlVisible("GoButton", false, panel)
    self:setCtrlVisible("OpenImmediatelyButton", false, panel)
    self:setCtrlVisible("OpenTimePanel", false, panel)
    self:setCtrlVisible("ClockImage", true, panel)
    self:setCtrlVisible("SetButton", false, panel)
    self:setCtrlVisible("NotePanel", false, panel)
end

-- 按钮初始化，根据活动名称
function PartyActiveDlg:btnInitByActiveName(activeInfo, panel)
    if activeInfo.name == CHS[5450002] then
        if Me:queryBasic("party/job") == CHS[3003203] or Me:queryBasic("party/job") == CHS[3003204] then
            self:setCtrlVisible("SetButton", true, panel)
        else
            self:setCtrlVisible("GoButton", true, panel)
        end
    elseif activeInfo.name == CHS[5400231] then  --    [5400231] = "培育巨兽",
        -- 强盗来袭或培育巨兽
        if PartyMgr.pyjsIsOpen then
            self:setActiviesOpen(NOTIFY.NOTIFY_QUERY_PARTY_SHOUWEI, panel)
        else
            if Me:queryBasic("party/job") == CHS[3003203] or Me:queryBasic("party/job") == CHS[3003204] then
                self:setCtrlVisible("GoButton", false, panel)
                self:setCtrlVisible("OpenImmediatelyButton", true, panel)
            else
                self:setCtrlVisible("GoButton", false, panel)
                self:setCtrlVisible("OpenTimePanel", true, panel)
                self:setLabelText("OpenTimeLabel", CHS[3003206], panel)
                self:setCtrlVisible("OpenImmediatelyButton", false, panel)
            end
        end     
    elseif activeInfo.name == CHS[4100784] then -- 挑战巨兽
        if PartyMgr.openStateTZJS then
            self:setActiviesOpen(CHS[4100784], panel)
        else
            if Me:queryBasic("party/job") == CHS[3003203] or Me:queryBasic("party/job") == CHS[3003204] then
                self:setCtrlVisible("GoButton", false, panel)
                self:setCtrlVisible("OpenImmediatelyButton", true, panel)
            else
                self:setCtrlVisible("GoButton", false, panel)
                self:setCtrlVisible("OpenTimePanel", true, panel)
                self:setLabelText("OpenTimeLabel", CHS[3003206], panel)
                self:setCtrlVisible("OpenImmediatelyButton", false, panel)
            end
        end   
    elseif activeInfo.name == CHS[3003208] then
        self:setCtrlVisible("NotePanel", true, panel)
    else
        self:setCtrlVisible("GoButton", true, panel)
    end
end

function PartyActiveDlg:setSingleActive(activeInfo, panel)
    local image = self:getControl("ActiveImage", nil, panel)

    image:loadTexture(activeInfo.icon, activeInfo.iconResType)
    gf:setItemImageSize(image)
    self:setLabelText("ActiveNameLabel", activeInfo.name, panel)
    self:setLabelText("ActiveLevelLabel", activeInfo.level .. CHS[3003209], panel)

    self:setLabelText("ConditionLabel", activeInfo.time, panel)
    self:setLabelText("ContentLabel", activeInfo.reward, panel)

    self:btnInitByActiveName(activeInfo, panel)
    
    local setButton = self:getControl("SetButton", nil, panel)
    local noteButton = self:getControl("NoteButton", nil, panel)
    local gotoButton = self:getControl("GoButton", nil, panel)
    local openButton = self:getControl("OpenImmediatelyButton", nil, panel)

    setButton:setTag(panel:getTag())
    noteButton:setTag(panel:getTag())
    gotoButton:setTag(panel:getTag())
    openButton:setTag(panel:getTag())

    self:bindTouchEndEventListener(setButton, self.onSetButton)
    self:bindTouchEndEventListener(noteButton, self.onNoteButton)
    self:bindTouchEndEventListener(gotoButton, self.onGotoButton)
    self:bindTouchEndEventListener(openButton, self.onOpenButton)

    -- 不同活动特殊处理
    if activeInfo.name == CHS[5450002] then
        -- 将按钮隐藏
        self:setButtonVisibleFalse(panel)

        -- 设置前往按钮label显示状态
        if Me:queryBasic("party/job") == CHS[3003203] or Me:queryBasic("party/job") == CHS[3003204] then
            self:setCtrlVisible("SetButton", true, panel)
            if PartyMgr:getZdxOpenToday() == 2 then
                -- 正在开启
                self:setCtrlVisible("GoButton", true, panel)
                self:setCtrlVisible("SetButton", false, panel)
            elseif PartyMgr:getZdxOpenToday() == 1 then
                -- 今天已经开启
                self:setCtrlVisible("OpenTimePanel", true, panel)
                self:setCtrlVisible("ClockImage", false, panel)
                self:setLabelText("OpenTimeLabel", CHS[3003210], panel)
            else
                -- 今天尚未开启
                self:setCtrlVisible("OpenImmediatelyButton", true, panel)
            end
        else
            if PartyMgr:getPartyZdxOpenLine() == 0 then
                -- 未设置路线显示等待开启和闹钟
                self:setCtrlVisible("OpenTimePanel", true, panel)
                self:setLabelText("OpenTimeLabel", CHS[3003206], panel)
            else
                if PartyMgr:getZdxOpenToday() == 2 then
                    -- 正在开启
                    self:setCtrlVisible("GoButton", true, panel)
                elseif PartyMgr:getZdxOpenType() == 1 then
                    -- 自动开启状态
                    local time = "12:45"
                    local hour, min = PartyMgr:getZdxAutoStartTime()
                    if hour and min then
                        if min >= 50 then
                            hour = (hour + 1) % 24
                        end
                        
                        min = (min + 10) % 60
                        
                        time = string.format("%02d:%02d", hour, min)
                    end
                    
                    self:setCtrlVisible("OpenTimePanel", true, panel)
                    self:setLabelText("OpenTimeLabel", time, panel)
                elseif PartyMgr:getZdxOpenType() == 0 then
                    -- 非自动开启
                    if PartyMgr:getZdxOpenToday() == 0 then
                        -- 今天没有开启过
                        self:setCtrlVisible("OpenTimePanel", true, panel)
                        self:setLabelText("OpenTimeLabel", CHS[3003206], panel)
                    else
                        self:setCtrlVisible("OpenTimePanel", true, panel)
                        self:setLabelText("OpenTimeLabel", CHS[3003210], panel)
                    end
                end
            end
        end
    end
end

function PartyActiveDlg:chooseActive(sender, eventType)
    local activeView = self:getControl("ListView")
    local panels = activeView:getItems()
    for i, panel in pairs(panels) do
        self:setCtrlVisible("ChosenEffectImage", false, panel)
    end

    sender = sender or activeView:getItem(0)
    self:setCtrlVisible("ChosenEffectImage", true, sender)

    local dlg = DlgMgr:openDlg("PartyActiveNoteDlg")
    dlg:setActiveInfo(sender:getTag())
end

function PartyActiveDlg:onOpenButton(sender, eventType)
    local index = sender:getTag()
    if index == 4 then
        if PartyMgr:getPartyZdxOpenLine() == 0 then
            gf:ShowSmallTips(CHS[3003211])
            return
        end

        -- PartyMgr.pyjsIsOpen 也可能表示巨兽活动
        if PartyMgr.pyjsIsOpen == 1 then
            -- 强盗来袭或培育巨兽开启
            gf:ShowSmallTips(string.format(CHS[3003212], CHS[5400231]))
            
            return
        end

        if PartyMgr:getZdxOpenToday() == 2 then
            gf:ShowSmallTips(CHS[3003214])
            return
        end
        
        gf:confirm(CHS[5420114], function ()
            if PartyMgr:getPartyZdxOpenLine() == 0 then
                gf:ShowSmallTips(CHS[3003211])
                return
            end

            if PartyMgr.pyjsIsOpen == 1 then
                -- -- 强盗来袭或培育巨兽开启
                gf:ShowSmallTips(string.format(CHS[3003212], CHS[5400231]))
                
                return
            end

            if PartyMgr:getZdxOpenToday() == 2 then
                gf:ShowSmallTips(CHS[3003214])
                return
            end
            
            PartyMgr:setZdxOpenType(3, PartyMgr:getPartyZdxOpenLine())
        end)
    elseif 5 == index then
        PartyMgr:requestStartPYJS()
    elseif 6 == index then        
        PartyMgr:openPartyJS()
    end
end

function PartyActiveDlg:onSetButton(sender, eventType)
    local index = sender:getTag()
    if index == 4 then

        if PartyMgr:partyZdxOpenCondition() then
            local dlg = DlgMgr:openDlg("PartyQqlModifyDlg")
        end

    elseif 5 == index then
        -- 强盗来袭或培育巨兽
        PartyMgr:requestPYJSInfo(1)
    elseif 6 == index then
        PartyMgr:queryPartyJS(1)
    elseif 7 == index then
        DlgMgr:openDlg("PartyWarInstructionDlg")
    end
end

function PartyActiveDlg:onGotoButton(sender, eventType)
    local index = sender:getTag()
    local actives = PartyMgr:getPartyActiveInfo()
    local tasks = TaskMgr.tasks

    if index == 1 then
        -- 帮派任务
        local haveTask = false
        local taskName = ""
        for i,v in pairs(actives[index].task) do
            if TaskMgr:isExistTaskByName(v) then
                haveTask = true
                taskName = v
            end
        end
        if haveTask then
            AutoWalkMgr:beginAutoWalk(gf:findDest(tasks[taskName].task_prompt))
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest("#P" .. actives[index].npc .. CHS[3003215] .. "#P"))
        end
    elseif index == 2 then
        -- 帮派日常
        if TaskMgr:isExistTaskByName(actives[index].name) ~= false then
            AutoWalkMgr:beginAutoWalk(gf:findDest(tasks[actives[index].name].task_prompt))
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest("#P" .. actives[index].npc .. CHS[3003216] .. "#P"))
        end
    elseif index == 3 then
        -- 强帮之道
        if TaskMgr:isExistTaskByName(CHS[6400046]) then
            AutoWalkMgr:beginAutoWalk(gf:findDest(tasks[CHS[6400046]].task_prompt))
        else
            AutoWalkMgr:beginAutoWalk(gf:findDest("#P" .. actives[index].npc .. CHS[6400045] .. "#P"))
        end
           
    elseif index == 4 then
        -- 帮派圈圈乐前往
        -- PartyMgr:setZdxOpenType(6, 0)
        PartyMgr:setZdxGotoMap()
    elseif index == 5 then
        -- 强盗来袭或培育巨兽
        PartyMgr:requestPYJSInfo(1)
    elseif index == 6 then
        PartyMgr:queryPartyJS(1)
    elseif index == 7 then
        --gf:sendGeneralNotifyCmd(NOTIFY.NOTIFT_JOIN_PARTY_WAR)
        AutoWalkMgr:beginAutoWalk(gf:findDest("#P" .. CHS[3003217] .. CHS[3003218] .. "#P"))
    else
        PartyMgr:flyToParty()
    end
    self:onCloseButton()
end

function PartyActiveDlg:onNoteButton(sender, eventType)
    if 7 == sender:getTag() then
        DlgMgr:openDlg("PartyWarInstructionDlg")
        self:onCloseButton()
    end
end

function PartyActiveDlg:onSelectListView(sender, eventType)
end

function PartyActiveDlg:MSG_PARTY_INFO(date)
    local partyActiveView = self:getControl("ListView")
    local actives = partyActiveView:getItems()
    if #actives == 0 then return end
    local partyActives = PartyMgr:getPartyActiveInfo()
    for i = 1, #actives do
        local panel = actives[i]

        self:setSingleActive(partyActives[i], panel)
    end
end

function PartyActiveDlg:MSG_PARTY_ZHIDUOXING_INFO()
    self:MSG_PARTY_INFO()
end


function PartyActiveDlg:setActiviesOpen(activeType, panelCtrl)
    local function setOpen(panel, setType)    
        setType = setType or 1
        if setType == 0 then
            -- 今天尚未开启
            if Me:queryBasic("party/job") == CHS[3003203] or Me:queryBasic("party/job") == CHS[3003204] then
                self:setCtrlVisible("GoButton", false, panel)
                self:setCtrlVisible("OpenImmediatelyButton", true, panel)
            else
                self:setCtrlVisible("GoButton", false, panel)
                self:setCtrlVisible("OpenTimePanel", true, panel)
                self:setLabelText("OpenTimeLabel", CHS[3003206], panel)
                self:setCtrlVisible("OpenImmediatelyButton", false, panel)
            end

        elseif setType == 1 then
            self:setCtrlVisible("GoButton", true, panel)
            self:setCtrlVisible("OpenImmediatelyButton", false, panel)
            self:setCtrlVisible("OpenTimePanel", false, panel)
        elseif setType == 2 then
            self:setCtrlVisible("GoButton", false, panel)
            self:setCtrlVisible("OpenTimePanel", true, panel)
            self:setLabelText("OpenTimeLabel", CHS[3003210], panel)
            self:setCtrlVisible("OpenImmediatelyButton", false, panel)
        end
    end

    local partyActives = PartyMgr:getPartyActiveInfo()
    local partyActiveView = self:getControl("ListView")
    if NOTIFY.NOTIFY_QUERY_PARTY_SHOUWEI == activeType then
        -- 强盗来袭或培育巨兽
        local tag = nil
        for i = 1, #partyActives do
            if partyActives[i].name == CHS[3003205]
                or partyActives[i].name == CHS[5400231] then
                tag = i
            end
        end

        if not tag then return end
        local panel = panelCtrl or partyActiveView:getChildByTag(tag)
        if not panel then return end
        setOpen(panel, PartyMgr.pyjsIsOpen)
    elseif NOTIFY.NOTIFY_QUERY_PARTY_HANGBARUQIN == activeType then
        local tag = nil
        for i = 1, #partyActives do
            if partyActives[i].name == CHS[3003207] then
                tag = i
            end
        end

        if not tag then return end
        local panel = panelCtrl or partyActiveView:getChildByTag(tag)
        if not panel then return end
        setOpen(panel, PartyMgr.hangbaOpen)
    elseif CHS[4100784] == activeType then
        local tag = nil
        for i = 1, #partyActives do
            if partyActives[i].name == CHS[4100784] then
                tag = i
            end
        end

        if not tag then return end
        local panel = panelCtrl or partyActiveView:getChildByTag(tag)
        if not panel then return end
        setOpen(panel, PartyMgr.openStateTZJS)
    end
end

return PartyActiveDlg
