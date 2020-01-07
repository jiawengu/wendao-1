-- CityFriendVerifyOperateDlg.lua
-- Created by huangzz Mar/05/2018
-- 请求区域好友验证操作界面

local CityFriendVerifyOperateDlg = Singleton("CityFriendVerifyOperateDlg", Dialog)

local panelList = {}      -- 存储已加载的条目
local panleCount = 0      -- 记录当前已加载的条数
local toLoadItemCount = 0 -- 记录还有几条未加载

function CityFriendVerifyOperateDlg:init()
    self:bindListener("NoteButton", self.onNoteButton)
    self:bindListener("RefuseAllButton", self.onRefuseAllButton)
    self:bindListener("RefuseButton", self.onRefuseButton)
    self:bindListener("AgreeButton", self.onAgreeButton)
    self:bindListener("SingleVerifyPanel", self.onSingleVerifyPanel)
    self:blindLongPress("PortraitPanel", self.onLongPortraitPanel, nil, "SingleVerifyPanel")

    self.listView = self:getControl("ListView")
    self.verifyPanel = self:retainCtrl("SingleVerifyPanel")
    self.chooseImg = self:retainCtrl("ChosenEffectImage", self.verifyPanel)

    -- 验证开关
    local isOn = SystemSettingMgr:getSettingStatus()["lbs_verify_be_added"] == 1
    local switchPanel = self:getControl("UseOpenStatePanel")
    self:createSwichButton(switchPanel, isOn, self.onFriendVerifyButton)

    self:initVerifyList(CitySocialMgr:getVerifyMsgList())

    self:hookMsg("MSG_MAILBOX_REFRESH")
end

function CityFriendVerifyOperateDlg:onFriendVerifyButton(isOn)
    SystemSettingMgr:sendSeting("lbs_verify_be_added", isOn and 1 or 0)

    if isOn then
        gf:ShowSmallTips(CHS[5400505])
    else
        gf:ShowSmallTips(CHS[5400504])
    end
end

function CityFriendVerifyOperateDlg:onSingleVerifyPanel(sender)
    local data = sender.data
    if not data then
        return
    end

    local id = data.id

    self.chooseImg:removeFromParent()
    sender:addChild(self.chooseImg)

    --设置验证消息
    -- 根据消息id获取文本信息
    local data = CitySocialMgr:getOneVerifyMessage(id)
    if not data then
        -- 取不到数据，直接删除
        self:updateOneVerify({
            id = id,
            status = SystemMessageMgr.SYSMSG_STATUS.DEL
        })

        gf:ShowSmallTips(CHS[5420328])
        return
    end

    -- 设置数据
    self.curSelectId = id

    -- 敏感词判断
    local text, textFilt = gf:filtText(data.msg, nil, true)
    self:setLabelText("Label", text, "MessagePanel")
end

-- 设置条目头像
function CityFriendVerifyOperateDlg:setPortrait(filePath, id)
    local cell = panelList[id]
    if cell then
        self:setImage("PortraitImage", filePath, cell)
    end
end

-- 长按头像
function CityFriendVerifyOperateDlg:onLongPortraitPanel(sender)
    local data = sender:getParent().data
    if not data or data.gid == Me:queryBasic("gid") then return end

    local dlg = BlogMgr:showButtonList(self, sender, "reportPortrait", self.name)
    dlg:setGid(data.gid)
end

-- 举报头像
function CityFriendVerifyOperateDlg:reportIcon(sender)
    local data = sender:getParent().data
    if data then
        CitySocialMgr:reportIcon(data.gid, data.icon_img, data.dist_name)
    end
end

function CityFriendVerifyOperateDlg:setOneVerifyPanel(data, cell)
    -- 玩家数据
    self:setPortrait(ResMgr:getSmallPortrait(data.icon), data.id)

    if not string.isNilOrEmpty(data.icon_img) then
        BlogMgr:assureFile("setPortrait", self.name, data.icon_img, nil, data.id)
    end

    self:setLabelText("PlayerNameLabel", data.name, cell)

    if not data.age or data.age < 0 then
        self:setLabelText("AgeLabel", CHS[5400495] .. CHS[5400496], cell)
    else
        self:setLabelText("AgeLabel", CHS[5400495] .. data.age, cell)
    end

    local polar = gf:getPloarByIcon(data.icon)
    self:setImagePlist("PolarImage", ResMgr:getSuitPolarImagePath(polar), cell)

    self:setImage("SexImage", ResMgr:getGenderSignByGender(data.sex), cell)

    local panel = self:getControl("PortraitPanel", nil, cell)
    -- self:setNumImgForPanel(panel, ART_FONT_COLOR.NORMAL_TEXT, data.level or 1, false, LOCATE_POSITION.LEFT_TOP, 19, cell)

    if GameMgr:getDistName() ~= data.dist_name then
        gf:addKuafLogo(panel)
    else
        gf:removeKuafLogo(panel)
    end

    self:setLabelText("TextLabel", data.dist_name, cell)

    cell.data = data
end

-- 初值化好友列表
function CityFriendVerifyOperateDlg:initVerifyList(verifyList)
    local listView = self.listView
    if #verifyList == 0 then
        self:updateUI()
        return
    end

    listView:removeAllItems()
    listView:setInnerContainerSize(cc.size(0, 0))
    self:stopSchedule()

    local curNum = 1
    local oneLoadNum = 5
    local cou = #verifyList
    local function func()
        for i = curNum, curNum + oneLoadNum - 1 do
            if i > cou then
                self:stopSchedule()
                return
            end

            repeat
                local id = verifyList[i].id
                if panelList[id] then
            	     break
            	end

                local data = CitySocialMgr:getOneVerifyMessage(id)
            	if not data then
            	    break
            	end

                local cell = self.verifyPanel:clone()

                panelList[id] = cell
                panleCount = panleCount + 1
                toLoadItemCount = toLoadItemCount - 1

                self:setOneVerifyPanel(verifyList[i], cell)

                if panleCount == 1 then
                    -- 默认选中第一条
                    self:onSingleVerifyPanel(cell)
                end

                listView:pushBackCustomItem(cell)
            until true
        end

        curNum = curNum + oneLoadNum
    end

    toLoadItemCount = cou
    panelList = {}
    panleCount = 0
    self.friendSch = self:startSchedule(func, 0.06)

    func()
    oneLoadNum = 1

    self:updateUI()
end

function CityFriendVerifyOperateDlg:stopSchedule()
    if self.friendSch then
        Dialog.stopSchedule(self, self.friendSch)
        self.friendSch = nil
    end
end

function CityFriendVerifyOperateDlg:removeOneVerify(id)
    local item = panelList[id]
    if not item then
        return
    end

    local list = self.listView
    local index = list:getIndex(item)
    list:removeItem(index)
    panelList[id] = nil
    panleCount = panleCount - 1

    self:updateUI()

    if self.curSelectId ~= id then
        return
    end

    -- 自动选中下一个
    local item = list:getItem(index)
    if not item then
        -- 没有下一个，自动选上一个
        item = list:getItem(index - 1)
    end

    if item then
        self:onSingleVerifyPanel(item)
    end
end

-- 更新一条验证信息
function CityFriendVerifyOperateDlg:updateOneVerify(data)
    local id = data.id
    if data.status == SystemMessageMgr.SYSMSG_STATUS.DEL then
        self:removeOneVerify(id)
        return
    end

    local cell = panelList[id]
    local isNewOne = false
    if not cell then
        isNewOne = true
    end

    local function func()
        local data = CitySocialMgr:getOneVerifyMessage(id)
        if not data then
            return
        end

        local cell = panelList[id]
        if not cell then
            cell =  self.verifyPanel:clone()
            panleCount = panleCount + 1
            panelList[id] = cell
            self.listView:pushBackCustomItem(cell)
        end

        self:setOneVerifyPanel(data, cell)

        if panleCount == 1 then
            -- 默认选中第一条
            self:onSingleVerifyPanel(cell)
            self:updateUI()
        end

        toLoadItemCount = toLoadItemCount - 1
    end

    toLoadItemCount = toLoadItemCount + 1
    if isNewOne then
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.06 * toLoadItemCount),  cc.CallFunc:create(func)))
    else
        func()
    end
end

-- 更新UI界面
function CityFriendVerifyOperateDlg:updateUI()
    if 0 == panleCount then
        -- 如果没有验证消息
        self:setCtrlEnabled("RefuseAllButton", false)
        self:setCtrlEnabled("AgreeButton", false)
        self:setCtrlEnabled("RefuseButton", false)

        self:setCtrlVisible("NoticePanel_0", true)
        self.listView:setVisible(false)

        self:setLabelText("Label", "", "MessagePanel")
    else
        self:setCtrlEnabled("RefuseAllButton", true)
        self:setCtrlEnabled("AgreeButton", true)
        self:setCtrlEnabled("RefuseButton", true)

        self:setCtrlVisible("NoticePanel_0", false)
        self.listView:setVisible(true)
    end
end

function CityFriendVerifyOperateDlg:onNoteButton(sender, eventType)
    local data = sender:getParent().data
    if data and data.gid ~= Me:queryBasic("gid") then
        local char = {}
        char.gid = data.gid
        char.name = data.name
        char.level = data.level
        char.icon = data.icon
        char.dist_name = data.dist_name
        local rect = self:getBoundingBoxInWorldSpace(sender)
        FriendMgr:openCharMenu(char, CHAR_MUNE_TYPE.CITY, rect)
    end
end

function CityFriendVerifyOperateDlg:onRefuseAllButton(sender, eventType)
    gf:confirm(CHS[6200041], function ()
        self:stopSchedule()
        SystemMessageMgr:deleteAllCityFriendCheck()
    end, nil)
end

function CityFriendVerifyOperateDlg:onRefuseButton(sender, eventType)
    if nil == self.curSelectId then return end

    CitySocialMgr:operFriendVerify(self.curSelectId, 0)
end

function CityFriendVerifyOperateDlg:onAgreeButton(sender, eventType)
    if nil == self.curSelectId then return end

    CitySocialMgr:operFriendVerify(self.curSelectId, 1)
end

function CityFriendVerifyOperateDlg:cleanup()
    self:stopSchedule()


    panelList = {}
    panleCount = 0
    toLoadItemCount = 0
end

function CityFriendVerifyOperateDlg:MSG_MAILBOX_REFRESH(data)
    if nil == data or data.count <= 0 then return end

    local count = data.count
    for i = 1, count do
        if data[i].type == SystemMessageMgr.SYSMSG_TYPE.TYPE_MAIL_FRIEND then
            self:updateOneVerify(data[i])
        end
    end
end

return CityFriendVerifyOperateDlg
