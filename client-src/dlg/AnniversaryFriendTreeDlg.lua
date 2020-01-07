-- AnniversaryFriendTreeDlg.lua
-- Created by yangym Mar/16/2017
-- 好友的招福宝树界面


local AnniversaryFriendTreeDlg = Singleton("AnniversaryFriendTreeDlg", Dialog)

local ONLINE = 1

local FRIEND_MIN_LEVEL = 30

function AnniversaryFriendTreeDlg:init()
    self:bindListener("CultureButton", self.onCultureButton)
    
    self.friendPanel = self:getControl("SingleFriendPanel")
    self.friendPanel:retain()
    self.friendPanel:removeFromParent()
    
    self.gid = nil
    self.waterData = {}
    
    self:initTreePanel()
    
    self:hookMsg("MSG_FRIEND_NOTIFICATION")
    self:hookMsg("MSG_GET_FRIEND_BAOSHU_INFO")
    self:hookMsg("MSG_GET_WATER_LIST")
    self:hookMsg("MSG_FRIEND_UPDATE_PARTIAL")
    
    -- 请求一下自己浇过水的所有好友数据
    gf:CmdToServer("CMD_GET_WATER_LIST")
end

function AnniversaryFriendTreeDlg:initTreePanel()
    self:setCtrlVisible("TreeImage1", false, "TreePanel")
    self:setCtrlVisible("TreeImage2", false, "TreePanel")
    self:setCtrlVisible("TreeImage3", false, "TreePanel")
end

-- 初始化好友列表
function AnniversaryFriendTreeDlg:initFriendList()
    local listView = self:getControl("FriendListView")
    listView:removeAllChildren()
    local friends = FriendMgr:getFriends()
    local friends = self:filterFriend(friends)
    self:sortFriends(friends)
    
    if not friends or #friends == 0 then
        -- 没有好友
        self:setCtrlVisible("FriendTreePanel", false)
        self:setCtrlVisible("NoticePanel", true)
        self:setCtrlVisible("InfoImage", true, "NoticePanel")
        self:setCtrlVisible("InfoBackImage1", false, "NoticePanel")
        self:setCtrlVisible("InfoBackImage2", true, "NoticePanel")
        self:setCtrlVisible("InfoBackImage3", false, "NoticePanel")
        self:setCtrlVisible("InfoBackImage4", true, "NoticePanel")
    end
    
    for i = 1, #friends do
        local cell = self.friendPanel:clone()
        self:setFriendData(cell, friends[i])
        listView:pushBackCustomItem(cell)
        
        if i == 1 then -- 默认选中第一个
            if ONLINE == friends[i].isOnline then
                gf:CmdToServer("CMD_GET_FRIEND_BAOSHU_INFO", {gid = friends[i].gid})
            else
                self.gid = friends[i].gid
                self.friend = friends[i]
                self:addSelectImage(cell)
                self:setCtrlVisible("FriendTreePanel", false)
                self:setCtrlVisible("NoticePanel", true)
                self:setCtrlVisible("InfoImage", true, "NoticePanel")
                self:setCtrlVisible("InfoBackImage1", true, "NoticePanel")
                self:setCtrlVisible("InfoBackImage2", true, "NoticePanel")
                self:setCtrlVisible("InfoBackImage3", false, "NoticePanel")
                self:setCtrlVisible("InfoBackImage4", false, "NoticePanel")
            end
        end
    end
end

-- 过滤好友
function AnniversaryFriendTreeDlg:filterFriend(friends)
    local filteredFriends = {}
    for i = 1, #friends do
        local friend = friends[i]
        if friend and friend.lev and friend.lev >= FRIEND_MIN_LEVEL then
            table.insert(filteredFriends, friend)
        end
    end
    
    return filteredFriends
end

-- 排序好友
function AnniversaryFriendTreeDlg:sortFriends(friends)
    local function sortFunc(l, r)
        if l.isOnline > r.isOnline then return false end
        if l.isOnline < r.isOnline then return true end

        if l.isVip > r.isVip then return true end
        if l.isVip < r.isVip then return false end

        if l.friendShip > r.friendShip then
            return true
        else
            return false
        end
    end

    table.sort(friends, sortFunc)
end

-- 选中效果
function AnniversaryFriendTreeDlg:addSelectImage(cell)
    local listView = self:getControl("FriendListView")
    local items = listView:getChildren()
    
    for k, v in pairs(items) do
        self:setCtrlVisible("BChosenEffectImage", false, v)
        self:setCtrlVisible("BackImage", true, v)
    end

    self:setCtrlVisible("BChosenEffectImage", true, cell)
    self:setCtrlVisible("BackImage", false, cell)
end

-- 设置好友基本信息
function AnniversaryFriendTreeDlg:setFriendData(cell, friend)
    -- 更新一下保存的self.friend
    if self.friend and self.friend.gid and self.friend.gid == friend.gid then
        self.friend = friend
    end
    
    -- 设置图标
    local iconPath = ResMgr:getSmallPortrait(friend.icon)
    self:setImage("PortraitImage", iconPath, cell)
    self:setItemImageSize("PortraitImage", cell)
    if ONLINE ~= friend.isOnline then
        local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
        gf:grayImageView(imgCtrl)
    else
        local imgCtrl = self:getControl("PortraitImage", Const.UIImage, cell)
        gf:resetImageView(imgCtrl)
    end

    -- 名字
    self:setLabelText("NamePatyLabel", gf:getRealName(friend.name), cell, COLOR3.BROWN)

    -- 友好度
    self:setLabelText("FriendlyDegreeLabel", CHS[4100139] .. friend.friendShip, cell)
    
    -- 是否浇过水
    if self.waterData[friend.gid] then
        self:setCtrlVisible("WateringImage1", false, cell)
        self:setCtrlVisible("WateringImage2", true, cell)
    else
        self:setCtrlVisible("WateringImage1", true, cell)
        self:setCtrlVisible("WateringImage2", false, cell)
    end
    
    local function touch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if ONLINE == friend.isOnline then
                gf:CmdToServer("CMD_GET_FRIEND_BAOSHU_INFO", {gid = friend.gid})
            else
                self.gid = friend.gid
                self.friend = friend
                self:addSelectImage(sender)
                self:setCtrlVisible("FriendTreePanel", false)
                self:setCtrlVisible("NoticePanel", true)
                self:setCtrlVisible("InfoImage", true, "NoticePanel")
                self:setCtrlVisible("InfoBackImage1", true, "NoticePanel")
                self:setCtrlVisible("InfoBackImage2", true, "NoticePanel")
                self:setCtrlVisible("InfoBackImage3", false, "NoticePanel")
                self:setCtrlVisible("InfoBackImage4", false, "NoticePanel")
            end
        end
    end
    cell:requestDoLayout()
    cell:setName(friend.gid)
    cell:addTouchEventListener(touch)
end

function AnniversaryFriendTreeDlg:refreshFriendPanel(friend)
    -- 刷新一下好友的一般数据
    if not friend then return end
    local listView = self:getControl("FriendListView")
    local item = listView:getChildByName(friend.gid)
    if not item then return end
    self:setFriendData(item, friend)
end

-- 浇水按钮响应
function AnniversaryFriendTreeDlg:onCultureButton()
    if self.gid then
        if self.friend and ONLINE ~= self.friend.isOnline then
            self:setCtrlVisible("FriendTreePanel", false)
            self:setCtrlVisible("NoticePanel", true)
            self:setCtrlVisible("InfoImage", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage1", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage2", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage3", false, "NoticePanel")
            self:setCtrlVisible("InfoBackImage4", false, "NoticePanel")
            gf:ShowSmallTips(CHS[7003034])
            return
        end
        
        gf:CmdToServer("CMD_WATER_FRIEND", {gid = self.gid})
    end
end

-- 好友上线离线，更新好友列表
function AnniversaryFriendTreeDlg:MSG_FRIEND_NOTIFICATION(data)
    local name =  data.char
    local newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByName(name))
    self:refreshFriendPanel(newFriendInfo)
end

function AnniversaryFriendTreeDlg:MSG_FRIEND_UPDATE_PARTIAL(data)
    local name =  data.char
    local newFriendInfo = FriendMgr:convertToUserData(FriendMgr:getFriendByGid(data.gid))
    self:refreshFriendPanel(newFriendInfo)
end

-- 刷新宝树界面
function AnniversaryFriendTreeDlg:refreshTreeInfo(data)
    -- 左上角说明显示
    local promptPanel = self:getControl("PromptPanel")
    promptPanel:stopAllActions()
    schedule(promptPanel, function()
        local time = gf:getServerTime()
        local curHour = gf:getServerDate("*t", time)["hour"]
        if curHour >= 0 and curHour <= 7 then
            self:setCtrlVisible("SleepPanel", true, "PromptPanel")
            self:setCtrlVisible("ActivePanel", false, "PromptPanel")
        else
            self:setCtrlVisible("SleepPanel", false, "PromptPanel")
            self:setCtrlVisible("ActivePanel", true, "PromptPanel")
        end
    end, 1)
    
    -- 如果是浇水成功，则播放浇水动画
    if data.type == "water" then
        AnniversaryMgr:createWaterArmatureAction(ResMgr.ArmatureMagic.zf_tree_water.name, "Animation1", self:getControl("WaterPanel" .. data.stage))
    end
    
    -- 等级
    self:setLabelText("LevelLabel", string.format(CHS[7002171], data.level), "GrownPanel")

    -- 成长
    local expStr = string.format(CHS[7002174], data.cur_exp, data.level_up_exp)
    local expPercent = data.cur_exp / data.level_up_exp * 100
    if data.level == Const.ZF_TREE_MAX_LEVEL then
        self:setLabelText("ExpLabel1", CHS[7002177], "GrownPanel", COLOR3.RED)
        self:setLabelText("ExpLabel2", CHS[7002177], "GrownPanel", COLOR3.BLACK)
    else
        self:setLabelText("ExpLabel1", expStr, "GrownPanel", COLOR3.WHITE)
        self:setLabelText("ExpLabel2", expStr, "GrownPanel", COLOR3.BLACK)
    end
    
    local expBar = self:getControl("ExpProgressBar")
    expBar:setPercent(expPercent)

    -- 健康
    local healthStr = string.format(CHS[7002174], data.health, 100)
    local healthPercent = data.health

    self:setLabelText("HealthyLabel1", healthStr, "GrownPanel")
    self:setLabelText("HealthyLabel2", healthStr, "GrownPanel")
    local healthBar = self:getControl("HealthyProgressBar")
    AnniversaryMgr:setProBar(healthBar, healthPercent)
    
    -- 宝树形象
    -- 重置所有状态
    for i = 1, 3 do
        self:setCtrlVisible("TreeImage" .. i, false, "TreePanel")
        self:setCtrlVisible("ParticlePanel" .. i, false, "TreePanel")
        self:setCtrlVisible("WormImage" .. i, false, "TreePanel")
        
        -- 移除一下附加在ParticlePanel上的光效
        self:getControl("ParticlePanel" .. i):removeAllChildren()
    end
        
    -- 宝树
    if data.stage then
        local treeImage = self:getControl("TreeImage" .. data.stage, nil, "TreePanel")
        local particlePanel = self:getControl("ParticlePanel" .. data.stage, nil, "TreePanel")
        treeImage:setVisible(true)
        particlePanel:setVisible(true)
        
        -- 树表的星星光效：不同树的星星数量不同，星星光效限制在各自的区域 ParticlePanel内
        for i = 1, data.stage do
            local quad = cc.ParticleSystemQuad:create(ResMgr:getParticleFilePath("Particle01128"))
            -- Sun/Fire/rain/Snow/Smoke/Flower/Galaxy/Metor/Spiral
            quad:setAnchorPoint(0.5, 0.5)
            local width = particlePanel:getContentSize().width
            local height = particlePanel:getContentSize().height
            quad:setPosition(width / 2, height / 2)
            quad:setPosVar(cc.vertex2F(width / 2, height / 2))
            quad:setLocalZOrder(7)
            particlePanel:addChild(quad)
        end
        
        -- 移除原本的树心光效
        if self.treeCenterEffect then
            self.treeCenterEffect:removeFromParent()
            self.treeCenterEffect = nil
        end
        
        if data.stage == 3 then
            -- 如果是第三阶段的树，还要额外添加一个树心光效，此光效在重置状态时需移除
            local effect =  gf:createLoopMagic(ResMgr.magic.zhaofu_tree_shuxin)
            effect:setAnchorPoint(0.5, 0.5)
            effect:setPosition(treeImage:getContentSize().width / 2 + 15, treeImage:getContentSize().height / 2 - 30)
            effect:setLocalZOrder(5)
            treeImage:addChild(effect)
            self.treeCenterEffect = effect
        end
    end
    
    -- 返回的宝树消息中，如果浇水成功的信息，则更新一下好友列表的浇水情况
    if data.type == "water" then
        self.waterData[data.gid] = true
        for k, v in pairs(self:getControl("FriendListView"):getChildren()) do
            if v:getName() == data.gid then
                self:setCtrlVisible("WateringImage1", false, v)
                self:setCtrlVisible("WateringImage2", true, v)
            end
        end
    end
end

-- 接收到好友的宝树数据
function AnniversaryFriendTreeDlg:MSG_GET_FRIEND_BAOSHU_INFO(data)
    if not data then
        return
    end
    
    if not data.gid then
        return
    end
    
    -- 等待服务器返回数据后，选中该好友
    for k, v in pairs(self:getControl("FriendListView"):getChildren()) do
        if v:getName() == data.gid then
            self:addSelectImage(v)
        end
    end
    
    -- 保存选中好友的相关信息
    self.gid = data.gid
    for k, v in pairs(FriendMgr:getFriends()) do
        if v.gid == self.gid then
            self.friend = v
        end
    end
    
    if data.error_type == 2 then
        self:setCtrlVisible("FriendTreePanel", true)
        self:setCtrlVisible("NoticePanel", false)
        self:refreshTreeInfo(data)
    else
        self:setCtrlVisible("FriendTreePanel", false)
        self:setCtrlVisible("NoticePanel", true)
        if data.error_type == 1 then
            self:setCtrlVisible("InfoImage", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage1", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage2", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage3", false, "NoticePanel")
            self:setCtrlVisible("InfoBackImage4", false, "NoticePanel")
        elseif data.error_type == 0 then
            self:setCtrlVisible("InfoImage", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage1", false, "NoticePanel")
            self:setCtrlVisible("InfoBackImage2", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage3", true, "NoticePanel")
            self:setCtrlVisible("InfoBackImage4", false, "NoticePanel")
        end
    end
end

-- 好友的浇水数据
function AnniversaryFriendTreeDlg:MSG_GET_WATER_LIST(data)
    local waterData = {}
    for i = 1, #data do
        waterData[data[i]] = true
    end
    
    self.waterData = waterData
    
    -- 重新生成一下列表
    self:initFriendList()
end

function AnniversaryFriendTreeDlg:cleanup()
    self.gid = nil
    self.treeCenterEffect = nil
    self.waterData = {}
    self:releaseCloneCtrl("friendPanel")
end

return AnniversaryFriendTreeDlg