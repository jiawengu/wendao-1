-- LoginChangeDistDlg.lua
-- Created by zhengjh Sep/12/2015
-- 登录区组选择

local UpdateCheck = require("global/UpdateCheck")

local LoginChangeDistDlg = Singleton("LoginChangeDistDlg", Dialog)
local MAX_HAVE_ROLE = 4
local ROLE_CELL_DISTANCE = 4
local COLUNM = 4

local DISTLISTVIEW_HEIGHT           = 434   -- 默认DistListView高度
local DISTLISTVIEW_HASROLE_HEIGHT   = 371   -- 已有角色时的高度

-- 4个及4个以下角色选角尺寸
local SMALL_SIZE = {}

local MID_SIZE = {}
local MID_SCROLL_SIZE = {}

-- 8个以上角色
local BIG_SIZE = {}
local BIG_SCROLL_SIZE = {}

function LoginChangeDistDlg:init(param)
    self:bindListener("RefreshButton", self.onRefreshButton)
    self:setCtrlVisible("RefreshButton", true)

    local distListView = self:getControl("DistListView")
    DISTLISTVIEW_HEIGHT = distListView:getContentSize().height

    -- 初始化尺寸大小
    local smallPanel = self:getControl("CharPanel")
    SMALL_SIZE = smallPanel:getContentSize()

    local midPanel = self:getControl("CharMidSizePanel")
    MID_SIZE = midPanel:getContentSize()
    MID_SCROLL_SIZE = self:getControl("ScrollView", nil, midPanel):getContentSize()
    midPanel:removeFromParent()


    local bigPanel = self:getControl("CharBigSizePanel")
    BIG_SIZE = bigPanel:getContentSize()
    BIG_SCROLL_SIZE = self:getControl("ScrollView", nil, bigPanel):getContentSize()
    bigPanel:removeFromParent()

    self.updateCheck = UpdateCheck.new()

    -- 大区列表单元格
    self.distTypePanel = self:getControl("DistTypePanel")
    self.distTypePanel:retain()
    self.distTypePanel:removeFromParent()

    self.typeSelectImage = self:getControl("TypeChosenEffectImage", Const.UIImage, self.distTypePanel)
    self.typeSelectImage:retain()
    self.typeSelectImage:removeFromParent()

    -- 区列表单元格
    self.oneRowDistPanel = self:getControl("OneRowDistPanel")
    self.oneRowDistPanel:retain()
    self.oneRowDistPanel:removeFromParent()

    self.charPanel = self:getControl("CharPanel")
    self.charPanel:retain()
    self.charPanel:removeFromParent()

    self.charCellPanel = self:getControl("CharPanel_1", nil, self.charPanel)
    self.charCellPanel:retain()
    self.charCellPanel:removeFromParent()

    self.createCharPanel = self:getControl("CreateCharPanel", nil, self.charPanel)
    self.createCharPanel:retain()
    self.createCharPanel:removeFromParent()


    local cell = self:getControl("DistPanel_1", nil, self.oneRowDistPanel)
    self.itemSelectImg = self:getControl("ChosenEffectImage", Const.UIImage, cell)
    self.itemSelectImg:setVisible(true)
    self.itemSelectImg:retain()
    self.itemSelectImg:removeFromParent()


    -- 获取所有列表数据
    self.allGroupList = DistMgr:getNameKeyList()
    self.allGroupList[CHS[3002918]] = DistMgr:getRecommendList()    -- 推荐

    -- 初值化大区列表
    self.gorupList = gf:deepCopy( DistMgr:getGroupList())
    table.insert(self.gorupList, 1, CHS[3002918])

    table.insert(self.gorupList, 1, CHS[2100040])   -- 已有角色

    local allHasRoleDist
    local charOfDist
    allHasRoleDist, charOfDist = DistMgr:getHasRoleDistList(param)
    self.allGroupList[CHS[2100040]] = allHasRoleDist or {}
    self.charOfDist = charOfDist or {}
    self.allDistChar = param

    if self.allGroupList[CHS[2100040]] and not next(self.allGroupList[CHS[2100040]]) then
        self:onRefreshButton(nil, nil, true)
    end

    if allHasRoleDist and #allHasRoleDist > 0 then
        self.typeName = self.gorupList[1]
    else
        self.typeName = self.gorupList[2]
    end

    self:initTypeDistListView(self.gorupList)

    -- 初值化区默认列表
    local list = DistMgr:getRecommendList()
    self:initListView(self.typeName)

    --self:hookMsg("MSG_L_ACCOUNT_CHARS")
    self:hookMsg("MSG_EXISTED_CHAR_LIST")

    DlgMgr:setVisible("UserLoginDlg", false)
end

function LoginChangeDistDlg:selectCharBydist(distName)
    local groupName = DistMgr:getBigGroupNameByDist(distName)
    local listCtrl = self:getControl("DistTypeListView")
    local items = listCtrl:getItems()
    for i, panel in pairs(items) do
        if panel.name == groupName then
            self:onClickGroup(panel, ccui.TouchEventType.ended)
            performWithDelay(panel, function ()
                local listview = self:getControl("DistListView", Const.UIListView, self.root)
                local items = listview:getItems()
                for i, rowPanel in pairs(items) do
                    local left = self:getControl("DistPanel_1", nil, rowPanel)
                    local right = self:getControl("DistPanel_2", nil, rowPanel)
                    if left.name == distName then
                        self:onClickDist(left, ccui.TouchEventType.ended)
                    end
                    if right.name == distName then
                        self:onClickDist(right, ccui.TouchEventType.ended)
                    end
                end
            end,0)
        end
    end
end

function LoginChangeDistDlg:initTypeDistListView(list)
    local listview = self:resetListView("DistTypeListView", 5)
    for i = 1, #list do
        local cell = self:createTypeDistCell(list[i])
        listview:pushBackCustomItem(cell)

        -- 默认选择第一个
        if cell.name == self.typeName then
            self:addTypeSelectImage(cell)
        end
    end
end

function LoginChangeDistDlg:addTypeSelectImage(cell)
    self.typeSelectImage:removeFromParent()
    cell:addChild(self.typeSelectImage)
end

function LoginChangeDistDlg:onClickGroup(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
        self:addTypeSelectImage(sender)
        if self.typeName ~= sender.name then
            self.selectTag = nil
        end
        self.typeName = sender.name
        if self.updateCheck then self.updateCheck:cleanup() end

        self:initListView(self.typeName)
    end
end

function LoginChangeDistDlg:createTypeDistCell(name)
    local cell = self.distTypePanel:clone()
    self:setLabelText("Label", name, cell)
    cell.name = name
    --[[
    local function listener(sender, eventType)
    if eventType == ccui.TouchEventType.ended then
    	self:addTypeSelectImage(cell)
    	self.typeName = name

		if self.updateCheck then self.updateCheck:cleanup() end

		      self:initListView(self.typeName)
		end
    end

    cell:addTouchEventListener(listener)
    --]]
    self:bindTouchEndEventListener(cell, self.onClickGroup)
    return cell
end

function LoginChangeDistDlg:initListView(typeName, selectTag)
    local data = self.allGroupList[typeName]

    local listview = self:getControl("DistListView", Const.UIListView, self.root)
    listview:removeAllChildren()
    local row = math.ceil(#data / 2)
    for i = 1, row do
        listview:pushBackCustomItem(self:createDistPanel(data, i, selectTag))
        if selectTag and math.ceil(selectTag / 2) == i then
            listview:pushBackCustomItem(self:createCharListPanel(data, selectTag))
        end
    end

    listview:setAnchorPoint(cc.p(0, 1))
    if CHS[2100040] ~= typeName then
        self:setCtrlVisible("RefreshButton", false)
        self:setCtrlVisible("CoverImage_2", false)
        local cs = listview:getContentSize()
        if cs.height ~= DISTLISTVIEW_HEIGHT then
            listview:setContentSize(cs.width, DISTLISTVIEW_HEIGHT)
        end
    else
        self:setCtrlVisible("RefreshButton", true)
        self:setCtrlVisible("CoverImage_2", true)
        local cs = listview:getContentSize()
        if cs.height ~= DISTLISTVIEW_HASROLE_HEIGHT then
            listview:setContentSize(cs.width, DISTLISTVIEW_HASROLE_HEIGHT)
        end
    end
    listview:doLayout()
end

function LoginChangeDistDlg:setSelectDistName(distName)
    self.selectDistName = distName
end

function LoginChangeDistDlg:onClickDist(sender, eventType)
    local data = sender.data
    local tag = sender.tag
    local row = sender.row
    local i = sender.i
    Client:setLoginChar("")
    if eventType == ccui.TouchEventType.ended then
        if not LeitingSdkMgr:isLogined() then
            -- 还未登录，需要先登录
            LeitingSdkMgr:login()
            return
        end

        local userDefault = cc.UserDefault:getInstance()
        local noUpdate = userDefault:getIntegerForKey("noupdate", 0)
        local distName = data[tag].name

        local function doConnect()
            if self.selectDistName and self.selectDistName ~= data[tag].name then
                CommThread:stopAAA()
                CommThread:stop()
            end

            self.selectDistName = data[tag].name
            self.selectTag = tag

            if distName ~= Client:getWantLoginDistName() or (not Client:getReconnectShowPara(distName) and not Client._isConnectingGS) then
                Client:setReplaceData(1) -- 设置成服务器判断，同mac地址顶号
                DistMgr:connetAAA(data[tag].name)
            end

            performWithDelay(sender, function()
                self:initListView(self.typeName, (row-1)*2 + i)
            end, 0)

            if self.updateCheck then self.updateCheck:cleanup() end
        end

        if self.curShowDist == distName and Client:getReconnectShowPara(distName) then
            return
        end

        self.curShowDist = nil
        if 0 == noUpdate and self.updateCheck then
            sender:stopAllActions()
            if not DlgMgr:getDlgByName("CreateCharDlg") then
                DlgMgr:openDlg("WaitDlg")
            end
            self.updateCheck:doCheck(distName, function(succ)
                if succ then
                    doConnect()
                else
                    -- 刷新状态
                    local distName = data[tag].name
                    local dist = DistMgr:getDistInfoByName(distName)
                    local stateImage = self:getControl("StateImage", nil, sender)
                    stateImage:loadTexture(DistMgr:getServerStateImage(dist.state))
                end

                DlgMgr:closeDlg("WaitDlg")
            end)
        else
            doConnect()
        end
    end
end

function LoginChangeDistDlg:createDistPanel(data, row, selectTag)
    local distpanel = self.oneRowDistPanel:clone()
    distpanel:setTag(row)
    for i = 1, 2 do
        local tag = (row-1)*2 + i
        local cell = self:getControl("DistPanel_"..i, nil, distpanel)
        if  not data[tag] then
            cell:setVisible(false)
            break
        else
            self:setLabelText("DistNameLabel", data[tag].name, cell)
        end

        cell.name = data[tag].name
        cell:setTag(tag)

        -- 选中效果
        if tag == selectTag then
            self:addItemSelcelImage(cell)
        end

        if data[tag].orderTimeTip and "" ~= data[tag].orderTimeTip then
            self:setCtrlVisible("SuggestImage_2", true, cell)
            self:setCtrlVisible("SuggestImage_1", false, cell)
            self:setCtrlVisible("SuggestImage_3", false, cell)
            self:setCtrlVisible("OrderTimeLabel", true, cell)
            self:setLabelText("OrderTimeLabel", data[tag].orderTimeTip, cell)
        elseif data[tag].show_flag_type == 2019 then
            -- 2019 标识
            self:setCtrlVisible("SuggestImage_3", true, cell)
            self:setCtrlVisible("SuggestImage_1", false, cell)
            self:setCtrlVisible("SuggestImage_2", false, cell)
            self:setCtrlVisible("OrderTimeLabel", false, cell)
        else
            -- 是否新区
            if data[tag].isNew then
                self:setCtrlVisible("SuggestImage_1", true, cell)
            else
                self:setCtrlVisible("SuggestImage_1", false, cell)
            end

            self:setCtrlVisible("SuggestImage_2", false, cell)
            self:setCtrlVisible("SuggestImage_3", false, cell)
            self:setCtrlVisible("OrderTimeLabel", false, cell)
        end

        -- 状态
        local stateImage = self:getControl("StateImage", nil, cell)
        stateImage:loadTexture(DistMgr:getServerStateImage(data[tag].state))


        local roleInfo =  DistMgr:getHaveRoleInfo(data[tag].name) or self.charOfDist[data[tag].name]

        if roleInfo then
            -- 角色数量
            self:setLabelText("CharNumLabel", "["..roleInfo.roleNum.."]", cell)

            -- 头像
            local imgPath = ResMgr:getSmallPortrait(roleInfo.icon)
            local headImage = self:getControl("HeadImage", Const.UIImage, cell)
            headImage:loadTexture(imgPath)
            self:setItemImageSize("HeadImage", cell)

            -- 等级
            local iconPanel = self:getControl("HeadPanel", nil, cell)
            if  data.level ~= 0 then
                self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, roleInfo.level, false, LOCATE_POSITION.LEFT_TOP, 21)
            end

            -- 名字
            self:setLabelText("NameLabel", gf:getRealName(roleInfo.roleName or roleInfo.name), cell)
        else
            -- 角色数量
            self:setCtrlVisible("CharNumLabel", false, cell)
            self:setCtrlVisible("NameLabel", false, cell)
            self:setCtrlVisible("HeadPanel", false, cell)
            self:setCtrlVisible("PersionImage", false, cell)
        end

        cell.data = data
        cell.tag = tag
        cell.row = row
        cell.i = i
        self:bindTouchEndEventListener(cell, self.onClickDist)
    end

    return distpanel
end

function LoginChangeDistDlg:createCharListPanel(data, tag)
    local charPanel = self.charPanel:clone()
    if tag % 2 ~= 0 then
        self:setCtrlVisible("PointImage_1", true, charPanel)
        self:setCtrlVisible("PointImage_2", false, charPanel)
    else
        self:setCtrlVisible("PointImage_1", false, charPanel)
        self:setCtrlVisible("PointImage_2", true, charPanel)
    end

    self:setCharListInfo(charPanel, data[tag].name)
    charPanel:setTag(999)

    return charPanel
end

function LoginChangeDistDlg:getCharPanelPos(index, size)
    local i = index % 4
    if i == 0 then i = 4 end

    local x = 4 + (self.charCellPanel:getContentSize().width + 4) * (i - 1)

    local row = math.ceil(index / 4)

    local y = size.height - (self.charCellPanel:getContentSize().height + 4) * (row)

    return x, y
end

function LoginChangeDistDlg:setCharListInfo(charPanel, distName)
    local roleList = Client:getCharListInfo()
    local scroll = self:getControl("CharScrollView", nil, charPanel)
    scroll:removeAllChildren()
    local container = ccui.Layout:create()
    container:setTouchEnabled(true)
    local sum = 0
    if roleList then
        if roleList.count <= 4 then
            container:setContentSize(scroll:getContentSize())
            scroll:setInnerContainerSize(container:getContentSize())
        elseif roleList.count <= 8 then
            charPanel:setContentSize(MID_SIZE)
            self:getControl("BKImage", nil, charPanel):setContentSize(MID_SCROLL_SIZE.width, MID_SCROLL_SIZE.height + 4)
            scroll:setContentSize(MID_SCROLL_SIZE)

            container:setContentSize(scroll:getContentSize())
            scroll:setInnerContainerSize(container:getContentSize())
        else
            charPanel:setContentSize(BIG_SIZE)
            self:getControl("BKImage", nil, charPanel):setContentSize(BIG_SCROLL_SIZE.width, BIG_SCROLL_SIZE.height + 4)
            scroll:setContentSize(BIG_SCROLL_SIZE)

            local row = math.ceil(roleList.count / 4)
            local height = (self.charCellPanel:getContentSize().height + 4) * row + 4
            if height < scroll:getContentSize().height then height = scroll:getContentSize().height end
            container:setContentSize(scroll:getContentSize().width, height)
            scroll:setInnerContainerSize(container:getContentSize())
        end

        for i = 1, roleList.count do
            local cell = self.charCellPanel:clone()
            self:setCharCellData(cell, roleList[i])
            local x, y = self:getCharPanelPos(i, container:getContentSize())
            cell:setPosition(x,y)
            container:addChild(cell)
            sum = i
        end
    else
        container:setContentSize(scroll:getContentSize())
        scroll:setInnerContainerSize(container:getContentSize())
    end

    if sum < 4 then
        -- 增加创建角色
        local createPanel = self:createAddCharCell()
        local x, y = self:getCharPanelPos(sum + 1, container:getContentSize())
        createPanel:setPosition(x,y)
        container:addChild(createPanel)
    end

    scroll:setAnchorPoint(0.5, 0.5)
    container:setPosition(0,0)
    scroll:addChild(container)
end

function LoginChangeDistDlg:tradingOperate(sender)
    local data = sender.data
    if data.trading_state == TRADING_STATE.FROZEN then
        gf:ShowSmallTips(CHS[4100419])
        return
    elseif data.trading_state == TRADING_STATE.CLOSED then
        gf:ShowSmallTips(CHS[4100420])
        return
    elseif data.trading_state == TRADING_STATE.PAYMENT then
        gf:ShowSmallTips(CHS[4100420])
        return
    else
        -- 弹出 UserSellDlg界面
        TradingMgr:tradingSnapshot(data.trading_goods_gid, TRAD_SNAPSHOT.SNAPSHOT)
    end
end

local function toReconnectLoginGame(charName)
    Client:setLoginChar(charName)
    Client:setIsNeedEnterGame(true)
    Client:setReplaceData(0) -- 可以顶号

    MessageMgr:clearMsg()
    DlgMgr:openDlg("WaitDlg")
    local data = DistMgr:splitSwichServerInfo({ msg = Client:getReconnectShowPara(Client:getWantLoginDistName()) })
    Client:MSG_L_AGENT_RESULT(data, true)
end

function LoginChangeDistDlg:setCharCellData(cell, data)
    -- 头像
    local imgPath = ResMgr:getSmallPortrait(data.icon)
    local headImage = self:getControl("HeadImage_1", Const.UIImage, cell)
    headImage:loadTexture(imgPath)
    self:setItemImageSize("HeadImage_1", cell)

    self:setLabelText("NameLabel_1", gf:getRealName(data.name), cell)

    local stateImgPath

    if data.char_online_state == CHAR_ONLINE_STATE.CHAR_LIST_T_CROSSSERVER then    -- 跨服
        stateImgPath = ResMgr.ui.login_change_dist_cross_server
    elseif data.char_online_state == CHAR_ONLINE_STATE.CHAR_LIST_T_TRUSTEESHIP then -- 托管
        stateImgPath = ResMgr.ui.login_change_dist_trusteeship
    elseif data.trading_state > 0 then  -- 公示、寄售、过期
        stateImgPath = TradingMgr:getTradingStateImagePathForChangeDist(data.trading_state)
    end
    if not stateImgPath and data.char_online_state == CHAR_ONLINE_STATE.CHAR_LIST_T_ONLINE then  -- 在线
        stateImgPath = ResMgr.ui.login_change_dist_online
    end

    local stateImage = self:getControl("SellStateBKImage", Const.UIImage, cell)
    if stateImgPath and stateImage then
        stateImage:loadTexture(stateImgPath)
        stateImage:setVisible(true)
    end

    -- 时间
    if data.trading_state == TRADING_STATE.SHOW or data.trading_state == TRADING_STATE.SALE or data.trading_state == TRADING_STATE.PAYMENT then
        local panel = self:getControl("SellStatePanel", nil, cell)
        if panel then
            panel:setVisible(true)
            self:setLabelText("LeftTimeValueLabel", TradingMgr:getLeftTime(data.trading_left_time, data.trading_state), panel)
        end
    end

    -- 正常状态、公示不显示展开信息按钮
    if data.trading_state >= TRADING_STATE.SALE then

        self:setCtrlVisible("ShrinkButton", true, cell)
        self:bindListener("ShrinkButton", function ()
            local dlg = DlgMgr:openDlg("LoginJubzSaleInfoDlg")
            dlg:setData(data, cell)
        end, cell)
    end


    -- 等级
    local iconPanel = self:getControl("HeadPanel_1", nil, cell)
    if  data.level ~= 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    if data.left_time_to_delete > 0 then
        self:setCtrlVisible("DelImage", true, cell)
    else
        self:setCtrlVisible("DelImage", false, cell)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if data.name == Me:queryBasic("name") then
                gf:ShowSmallTips(CHS[3002920])
            else

                local function toLoginGame()
                    Client:setLoginChar(data.name)
                    Client:setIsNeedEnterGame(true)
                    Client:setReplaceData(0) -- 可以顶号
                    --       DistMgr:connetAAA(self.selectDistName)
                    Client:loginGame()
                end

                local loginListInfo = Client:getCharListInfo()
                if not loginListInfo then
                    self:refreshRoleInfo()
                    return
                end

                local onLineChar
                for i = 1, loginListInfo.count do
                    if loginListInfo[i].char_online_state > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE then
                        onLineChar = loginListInfo[i]
                    end
                end

                if loginListInfo and loginListInfo.account_online > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE then
                    -- 账号在线
                    if onLineChar then
                        -- 在线、托管中
                        local stateStr = CHS[4100543]
                        if onLineChar.char_online_state > 1 then stateStr = CHS[4100399] end
                        gf:confirm(string.format(CHS[4100542], onLineChar.name, stateStr, onLineChar.name), function ()
                            local msg = Client:getReconnectShowPara(Client:getWantLoginDistName())
                            if msg then
                                -- 存在显示角色重连数据
                                toReconnectLoginGame()
                            else
                                toLoginGame()
                            end
                        end)
                        return
                    else
                        -- 创角
                        gf:confirm(string.format(CHS[4100541]), function ()
                            toLoginGame()
                        end)
                        return
                    end
                end

                toLoginGame()

            end
        end
    end

    cell:addTouchEventListener(listener)
end

function LoginChangeDistDlg:createAddCharCell()
    local cell = self.createCharPanel:clone()
    local addPanel = self:getControl("HeadPanel_1", nil, cell)

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then

            local function creatChar()
                -- 打开创建角色
                Client:setLoginChar(CHS[3002921])
                Client:setReplaceData(0) -- 可以顶号
                Client:loginGame()

                -- 清除区组列表缓存
                local distInfo = DistMgr:getDistRoleInfo(self.selectDistName)
                if distInfo then
                    distInfo = nil
                end
            end

            local function toLoginGame(charName)
                Client:setLoginChar(charName)
                Client:setIsNeedEnterGame(true)
                Client:setReplaceData(0) -- 可以顶号
                --       DistMgr:connetAAA(self.selectDistName)
                Client:loginGame()
            end

            local loginListInfo = Client:getCharListInfo()
            local onLineChar
            if loginListInfo then
                for i = 1, loginListInfo.count do
                    if loginListInfo[i].char_online_state > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE then
                        onLineChar = loginListInfo[i]
                    end
                end
            end

            if loginListInfo and loginListInfo.account_online > CHAR_ONLINE_STATE.CHAR_LIST_T_NONE then
                if loginListInfo.count == 0 then
                    -- 创角
                    gf:confirm(string.format(CHS[4100541]), function ()
                        creatChar()
                    end)
                    return
                end

                -- 账号在线
                if onLineChar then
                    -- 在线、托管中
                    local stateStr = CHS[4100543]
                    if onLineChar.char_online_state > 1 then stateStr = CHS[4100399] end
                    gf:confirm(string.format(CHS[4100542], onLineChar.name, stateStr, onLineChar.name), function ()
                        local msg = Client:getReconnectShowPara(Client:getWantLoginDistName())
                        if msg then
                            -- 存在显示角色重连数据
                            toReconnectLoginGame()
                        else
                            toLoginGame()
                        end
                    end)
                    return
                else
                    -- 创角
                    gf:confirm(string.format(CHS[4100541]), function ()
                        creatChar()
                    end)
                    return
                end
            end

            creatChar()

        end
    end

    cell:addTouchEventListener(listener)

    return cell
end

function LoginChangeDistDlg:refreshRoleInfo()
    local listView = self:getControl("DistListView")
    local item = listView:getChildByTag(999)
    if not item then return false end
    self:setCharListInfo(item, self.selectDistName)
    item:retain()
    local index = listView:getIndex(item)
    listView:removeItem(index)
    listView:insertCustomItem(item, index)
    item:release()

    -- 如果超出屏幕，则滚动
    local children = listView:getChildren()
    local count = #children - index - 1

    local panel = listView:getChildren()[1]
    local height = (panel:getContentSize().height) * count
    local inner = listView:getInnerContainer()
    if inner:getContentSize().height - height >= listView:getContentSize().height then
        inner:setPositionY(-height)
    end

    return true
end

function LoginChangeDistDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    item:addChild(self.itemSelectImg)
end

function LoginChangeDistDlg:refreshDistRoleNum()
    if not self.selectTag then return end
    local listView = self:getControl("DistListView")
    local row = math.ceil(self.selectTag / 2)
    local panel = listView:getChildByTag(row)
    if not panel then return end
    local item = panel:getChildByTag(self.selectTag)
    local roleInfo =  DistMgr:getHaveRoleInfo(self.selectDistName)

    if roleInfo then
        local roleList = Client:getCharListInfo()
        for i = 1, roleList.count do
            local role = roleList[i]
            if gf:getRealName(role.name) == roleInfo.roleName then
                roleInfo.icon = role.icon
                roleInfo.level = role.level
            end
        end

        -- 角色数量
        self:setLabelText("CharNumLabel", "["..roleInfo.roleNum.."]", item)
        if not roleInfo.roleName then
            self:setCtrlVisible("NameLabel", false, item)
            self:setCtrlVisible("HeadPanel", false, item)
            self:setCtrlVisible("PersionImage", false, item)

            if roleInfo.roleNum == 0 then
                self:setLabelText("CharNumLabel", "", item)
            end
        else
            local imgPath = ResMgr:getSmallPortrait(roleInfo.icon)
            local headImage = self:getControl("HeadImage", Const.UIImage, item)
            headImage:loadTexture(imgPath)
            self:setItemImageSize("HeadImage", item)

            -- 等级
            local iconPanel = self:getControl("HeadPanel", nil, item)
            if  roleInfo.level ~= 0 then
                self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, roleInfo.level, false, LOCATE_POSITION.LEFT_TOP, 21)
            end
        end
    else
        self:setCtrlVisible("CharNumLabel", false, item)
        self:setCtrlVisible("NameLabel", false, item)
        self:setCtrlVisible("HeadPanel", false, item)
        self:setCtrlVisible("PersionImage", false, item)
    end
end

-- 刷新合服区组信息
-- fromDist被合服到toDist
function LoginChangeDistDlg:checkHideMergeTip(dist)
    if not self.hasShowMergeTip then
        self.hasShowMergeTip = {}
    end

    if not self.hasShowMergeTip[dist] then
        self.hasShowMergeTip[dist] = true
        return
    end

    return self.hasShowMergeTip[dist]
end

function LoginChangeDistDlg:MSG_EXISTED_CHAR_LIST(data)
    local roleInfo =  DistMgr:getHaveRoleInfo(self.selectDistName)
    local isMiss = true
    local level = 0
    local nextRole
    if roleInfo then
        for i = 1, data.count do
            if data[i].name == roleInfo.roleName then
                isMiss = false
            else
                if data[i].level >= level then
                    level = data[i].level
                    nextRole = data[i]
                end
            end
        end

        -- 先更新为无名的
        if isMiss then
            roleInfo.roleName = nil
            roleInfo.name = nil
            roleInfo.roleNum = data.count
            DistMgr:refreshUserDefalut(roleInfo)
        end
    end


    if self:refreshRoleInfo(data) then
        self.curShowDist = self.selectDistName
    end

    self:refreshDistRoleNum()

    -- 尝试修复平台数据
    if self.allDistChar then
        for i = 1, #self.allDistChar do
            local cd = self.allDistChar[i]
            if cd and cd["dist"] == self.selectDistName then
                local miss = true
                for i = 1, data.count do
                    if cd["name"] == data[i].name then
                        miss = false
                        break
                    end
                end
                if miss then
                    LeitingSdkMgr:deleteCharReport({
                        gameZone = cd["dist"],
                        sid = cd["account"],
                        gid = cd["gid"],
                        beDeleted = 1
                    })
                    table.remove(self.allDistChar, i)
                    local charInfo = self.charOfDist[self.selectDistName]
                    if charInfo and charInfo.name == cd["name"] then
                        self.charOfDist[self.selectDistName] = nil
                    end
                end
                break
            end
        end
    end


    -- 上次登入的角色被删除了
    if roleInfo and isMiss then
        if nextRole then
            roleInfo.roleName = nextRole.name
            roleInfo.icon = nextRole.portrait
            roleInfo.level = nextRole.level
            roleInfo.name = self.selectDistName
            DistMgr:refreshUserDefalut(roleInfo)
        else
            DistMgr.haveRoleDist[self.selectDistName] = nil
            DistMgr:refreshUserDefalut({index = roleInfo.index})
        end
    end
end

function LoginChangeDistDlg:onCloseButton()
    CommThread:stop() -- 断开gs
    DlgMgr:closeDlg(self.name)
end

function LoginChangeDistDlg:cleanup()
    self:releaseCloneCtrl("distTypePanel")
    self:releaseCloneCtrl("typeSelectImage")
    self:releaseCloneCtrl("oneRowDistPanel")
    self:releaseCloneCtrl("charPanel")
    self:releaseCloneCtrl("charCellPanel")
    self:releaseCloneCtrl("createCharPanel")
    self:releaseCloneCtrl("itemSelectImg")
    self:releaseCloneCtrl("charList")

    self.gorupList = {}
    self.selectTag = nil
    self.refreshCallback = nil
    self.allDistChar = nil
    self.hasShowMergeTip = nil

    DlgMgr:setVisible("UserLoginDlg", true)

    if self.updateCheck then
        self.updateCheck:dispose()
        self.updateCheck = nil
    end

    DlgMgr:closeDlg("LoginJubzSaleInfoDlg")
    self.curShowDist = nil
    Client:clearReconnectShowPara()
end

function LoginChangeDistDlg:onRefreshButton(sender, eventType, forceQuery)
    if self.isQuery and not forceQuery then
        gf:ShowSmallTips(CHS[2100041])  -- 5秒内只能刷新一次，请稍后再试。
        return
    end

    if not forceQuery then
        self.isQuery = true
    end
    self.refreshCallback = function(s)
        if not s then
            return
        end
        local json = require("json")
        local t
        local s, t = pcall(function() return s and json.decode(s) or {} end)
        if not s then
            if not forceQuery then  -- 初始化时的强制执行就不再弹提示，避免弹多次
                gf:ShowSmallTips(CHS[2100144])
            end
            return
        end
        local allHasRoleDist
        local charOfDist
        allHasRoleDist, charOfDist = DistMgr:getHasRoleDistList(t.data)
        self.allGroupList[CHS[2100040]] = allHasRoleDist or {}
        self.charOfDist = charOfDist or {}
        if self.typeName == CHS[2100040] then
            if self.updateCheck then
                self.updateCheck:cleanup()
            end
            self:initListView(self.typeName)
        end
    end

    LeitingSdkMgr:queryAllChars({
        sid = Client:getAccount(),
    }, function(s)

        if self.refreshCallback and 'function' == type(self.refreshCallback) then
            self.refreshCallback(s)
        end
    end, 5)

    -- 5s查询一次
    performWithDelay(self.root, function()
        self.isQuery = nil
    end, 5)
end

return LoginChangeDistDlg
