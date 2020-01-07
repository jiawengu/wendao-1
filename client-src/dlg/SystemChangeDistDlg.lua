-- SystemChangeDistDlg.lua
-- Created by zhengjh Sep/09/2015
-- 区组界面

local SystemChangeDistDlg = Singleton("SystemChangeDistDlg", Dialog)

local MAX_HAVE_ROLE = 4
local ROLE_CELL_DISTANCE = 4

function SystemChangeDistDlg:init()
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
    local recommedList = DistMgr:getGameRecommonedList()
    self.allGroupList[CHS[3003677]] = recommedList

    -- 初值化大区列表
    self.gorupList = gf:deepCopy( DistMgr:getGroupList())
    table.insert(self.gorupList, 1, CHS[3003677])
    self:initTypeDistListView(self.gorupList)

    -- 初值化区默认列表
    --local list = recommedList
    self.typeName = CHS[3003677]
    self:initListView(self.typeName)

    self:hookMsg("MSG_L_ACCOUNT_CHARS")
    self:hookMsg("MSG_EXISTED_CHAR_LIST")
end



function SystemChangeDistDlg:initTypeDistListView(list)
    local listview = self:resetListView("DistTypeListView", 3)
    for i = 1, #list do
        local cell = self:createTypeDistCell(list[i])
        listview:pushBackCustomItem(cell)

        -- 默认选择第一个
        if i == 1 then
            self:addTypeSelectImage(cell)
        end
    end
end

function SystemChangeDistDlg:addTypeSelectImage(cell)
    self.typeSelectImage:removeFromParent()
    cell:addChild(self.typeSelectImage)
end

function SystemChangeDistDlg:createTypeDistCell(name)
    local cell = self.distTypePanel:clone()
    self:setLabelText("Label", name, cell)

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:addTypeSelectImage(cell)
            self.typeName = name
            self:initListView(self.typeName)
        end
    end

    cell:addTouchEventListener(listener)

    return cell
end

function SystemChangeDistDlg:initListView(typeName, selectTag)
    local data = self.allGroupList[typeName]
    local listview = self:resetListView("DistListView", 8)
    local row = math.ceil(#data / 2)
    for i = 1, row do
        listview:pushBackCustomItem(self:createDistPanel(data, i, selectTag))
        if selectTag and math.ceil(selectTag / 2) == i then
            listview:pushBackCustomItem(self:createCharListPanel(data, selectTag))
        end
    end
end

function SystemChangeDistDlg:createDistPanel(data, row, selectTag)
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

        cell:setTag(tag)

        -- 选中效果
        if tag == selectTag then
            self:addItemSelcelImage(cell)
        end

        -- 是否新区
        if data[tag].isNew then
            self:setCtrlVisible("SuggestImage", true, cell)
        else
            self:setCtrlVisible("SuggestImage", false, cell)
        end

        -- 状态
        local stateImage = self:getControl("StateImage", nil, cell)
        stateImage:loadTexture(DistMgr:getServerStateImage(data[tag].state))


        local roleInfo =  DistMgr:getHaveRoleInfo(data[tag].name)

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
            self:setLabelText("NameLabel", roleInfo.roleName, cell)
        else
            -- 角色数量
            self:setCtrlVisible("CharNumLabel", false, cell)
            self:setCtrlVisible("NameLabel", false, cell)
            self:setCtrlVisible("HeadPanel", false, cell)
            self:setCtrlVisible("PersionImage", false, cell)
        end

        local function listener(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if  data[tag].state == 1 then -- 维护中
                    gf:ShowSmallTips(CHS[3003678])
                    return
                end

                self.selectDistName = data[tag].name
                self.selectTag = tag

                if DistMgr:isNeedConnectAAA(data[tag].name) then
                    DistMgr:connetAAA(data[tag].name)
                end

                performWithDelay(cell, function() self:initListView(self.typeName, (row-1)*2 + i)  end, 0)
            end
        end

        cell:addTouchEventListener(listener)
    end

    return distpanel
end

function SystemChangeDistDlg:createCharListPanel(data, tag)
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

function SystemChangeDistDlg:setCharListInfo(charPanel, distName)
    local charListPanel = self:getControl("CharListPanel", nil, charPanel)

    if charListPanel then
        charListPanel:removeAllChildren()
    else
        return
    end
    local roleList = DistMgr:getDistRoleInfo(distName)
    local posX = 6
    if roleList then
        for i = 1, #roleList do
            local cell = self.charCellPanel:clone()
            self:setCharCellData(cell, roleList[i])
            cell:setPositionX(posX)
            posX = posX + self.charCellPanel:getContentSize().width + ROLE_CELL_DISTANCE
            charListPanel:addChild(cell)
        end
    end

    local left = 0
    if roleList then
        left = MAX_HAVE_ROLE - #roleList
    else
        left = MAX_HAVE_ROLE
    end

    if left > 0 then
        local cell = self:createAddCharCell()
        cell:setPositionX(posX)
        charListPanel:addChild(cell)
    end
end

function SystemChangeDistDlg:setCharCellData(cell, data)
    -- 头像
    local imgPath = ResMgr:getSmallPortrait(data.icon)
    local headImage = self:getControl("HeadImage_1", Const.UIImage, cell)
    headImage:loadTexture(imgPath)
    self:setItemImageSize("HeadImage_1", cell)

    self:setLabelText("NameLabel_1", gf:getRealName(data.name), cell)

    -- 等级
    local iconPanel = self:getControl("HeadPanel_1", nil, cell)

    if data.name == Me:queryBasic("name") then
        data.level = Me:queryBasic("level")
    end

    if  data.level ~= 0 then
        self:setNumImgForPanel(iconPanel, ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21)
    end

    if data.deletime > 0 then
        self:setCtrlVisible("DelImage", true, cell)
    else
        self:setCtrlVisible("DelImage", false, cell)
    end

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if data.name == Me:queryBasic("name") then
                gf:ShowSmallTips(CHS[3003679])
            elseif Me:isInCombat() then
                gf:ShowSmallTips(CHS[3003680])
            else
                Client:setLoginChar(data.name)
                gf:CmdToServer("CMD_LOGOUT", {reason = LOGOUT_CODE.LGT_SELECT_CHAR_1})
                CommThread:stop()
                Client:tryLogin()
            end
        end
    end

    cell:addTouchEventListener(listener)
end

function SystemChangeDistDlg:createAddCharCell()
    local cell = self.createCharPanel:clone()
    local addPanel = self:getControl("HeadPanel_1", nil, cell)

    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if Me:isInCombat() then
                gf:ShowSmallTips(CHS[3003680])
            else
                local distInfo = DistMgr:getDistRoleInfo(self.selectDistName)
                if distInfo then
                    -- 打开创建角色
                    Client:setLoginChar(CHS[3003681])
                    gf:CmdToServer("CMD_LOGOUT", {reason = LOGOUT_CODE.LGT_SELECT_CHAR_2})
                    CommThread:stop()
                    Client:tryLogin()

                    -- 清除区组列表缓存
                    distInfo = nil
                end
            end
        end
    end

    cell:addTouchEventListener(listener)

    return cell
end

function SystemChangeDistDlg:refreshRoleInfo()
    local listView = self:getControl("DistListView")
    self:setCharListInfo(listView:getChildByTag(999), self.selectDistName)
end

function SystemChangeDistDlg:refreshDistRoleNum()
    local listView = self:getControl("DistListView")
    local row = math.ceil(self.selectTag / 2)

    local panel = listView:getChildByTag(row)
    local item = panel:getChildByTag(self.selectTag)
    local roleInfo =  DistMgr:getHaveRoleInfo(self.selectDistName)
    if roleInfo then
        -- 角色数量
        self:setLabelText("CharNumLabel", "["..roleInfo.roleNum.."]", item)
    end
end

function SystemChangeDistDlg:addItemSelcelImage(item)
    self.itemSelectImg:removeFromParent()
    item:addChild(self.itemSelectImg)
end

function SystemChangeDistDlg:MSG_L_ACCOUNT_CHARS(data)
    self:refreshRoleInfo()
    self:refreshDistRoleNum()
end

function SystemChangeDistDlg:cleanup()
    self:releaseCloneCtrl("oneRowDistPanel")
    self:releaseCloneCtrl("typeSelectImage")
    self:releaseCloneCtrl("distTypePanel")
    self:releaseCloneCtrl("itemSelectImg")
    self:releaseCloneCtrl("charPanel")
    self:releaseCloneCtrl("charCellPanel")
    self:releaseCloneCtrl("createCharPanel")
    self.gorupList = {}
end

return SystemChangeDistDlg
