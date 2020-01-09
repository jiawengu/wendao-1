-- JiebVoteDlg.lua
-- Created by yangym Apr/7/2017
-- 结拜投票界面

local JiebVoteDlg = Singleton("JiebVoteDlg", Dialog)

local PORTRAIT_NUM = 5

function JiebVoteDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    
    -- 初始化显示状态
    for i = 1, PORTRAIT_NUM do
        local fingerImage = self:getControl("PortraitPanel_" .. i)
        fingerImage:setColor(COLOR3.WHITE)
    end
    
    -- 创建分享按钮
    self:createShareButton(self:getControl("ShareButton"), SHARE_FLAG.JIEBAI)
    
    -- 初始显示确认结拜按钮
    self:setCtrlVisible("ConfirmPanel", true)
    self:setCtrlVisible("SharePanel", false)
end

-- 根据结拜人数初始化头像位置
function JiebVoteDlg:initPortraitPos(num)
    if self.initPortraitPosFinished then
        return
    end

    -- 根据人数隐藏“空头像”
    for i = 1, PORTRAIT_NUM do
        if i <= num then
            self:setCtrlVisible("PortraitPanel_" .. i, true)
        else
            self:setCtrlVisible("PortraitPanel_" .. i, false)
        end
    end

    -- 将显示状态的头像整体居中

    -- 计算需要移动的距离
    local portraitPanelWidth = self:getControl("PortraitPanel_1"):getContentSize().width
    local firstPanelPosX = self:getControl("PortraitPanel_1"):getPositionX()
    local lastPanelPosX = self:getControl("PortraitPanel_" .. num):getPositionX()
    local mainPanel = self:getControl("PortraitPanel")
    local offset = mainPanel:getContentSize().width / 2 - ((firstPanelPosX + lastPanelPosX + portraitPanelWidth) / 2)

    -- 移动显示状态的头像
    for i = 1, num  do
        local portraitPanel = self:getControl("PortraitPanel_" .. i)
        portraitPanel:setPositionX(portraitPanel:getPositionX() + offset)
    end

    self.initPortraitPosFinished = true
end

function JiebVoteDlg:setInfo(data, isShowRelation)
    -- isShowRelation代表界面是否用于显示结拜成功后的结拜关系
    if not data then
        return
    end
    
    self:initPortraitPos(#data)
    
    self.isShowRelation = isShowRelation
    
    --  处理一下数据，获取各角色称谓
    local data = JiebaiMgr:insertChengWeiByData(data)
    local meInfo
    
    -- 设置每个角色信息
    for i = 1, PORTRAIT_NUM do
        local info = data[i]
        if info then
            if info.gid == Me:queryBasic("gid") then
                meInfo = info
            end
            
            local name = gf:getRealName(info.name)
            local iconPath = ResMgr:getCirclePortraitPathByIcon(info.icon)
            self:setImage("PortraitImage", iconPath, "PortraitPanel_" .. i)
            self:setLabelText("NameLabel", name, "PortraitPanel_" .. i)
            self:setLabelText("TitleLabel", info.chengWei, "PortraitPanel_" .. i)
            
            -- 确认手印状态
            if info.has_confirm == 1 or isShowRelation then
                local fingerImage = self:getControl("FingerPrintImage", nil, "PortraitPanel_" .. i)
                fingerImage:setColor(COLOR3.RED)
                
                if info.gid == Me:queryBasic("gid") then
                   local confirmButton = self:getControl("ConfirmButton", nil, "ConfirmPanel")
                   confirmButton:setColor(COLOR3.RED)
                   confirmButton:setTouchEnabled(false)
                end
                
                self:setCtrlVisible("StatusLabel", false, "PortraitPanel_" .. i)
            else
                self:setCtrlVisible("StatusLabel", true, "PortraitPanel_" .. i)
            end
        else
            -- self:setLabelText("NameLabel", CHS[7002236], "PortraitPanel_" .. i)
            self:setCtrlVisible("FingerPrintImage", false, "PortraitPanel_" .. i)
        end
    end
    
    -- 设置自己的相关信息
    if meInfo then
        local meIconPath = ResMgr:getBigPortrait(meInfo.icon)
        self:setImage("UserImage", meIconPath, "SelfPortraitPanel")
        self:setLabelText("TitleLabel", data.appellation, "SelfTitlePanel")
        self:setLabelText("NameLabel", gf:getRealName(meInfo.name), "SelfTitlePanel")
    end
    
    -- 当前界面显示结拜成功后的结拜关系，确认按钮替换为分享按钮
    if isShowRelation then
        self:setCtrlVisible("ConfirmPanel", false)
        self:setCtrlVisible("SharePanel", true)
    end
end

function JiebVoteDlg:onConfirmButton()
    gf:CmdToServer("CMD_CONFIRM_JIEBAI")
end

-- 关闭按钮响应
function JiebVoteDlg:onCloseButton()
    if self.isShowRelation then
        self:close()
        return
    end
    
    gf:confirm(CHS[7002238], function()
        gf:CmdToServer("CMD_CANCEL_BROTHER")
    end)
end

function JiebVoteDlg:cleanup()
    self.initPortraitPosFinished = nil
end


return JiebVoteDlg