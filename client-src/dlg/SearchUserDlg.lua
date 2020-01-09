-- SearchUserDlg.lua
-- Created by sujl, Sept/23/2016
-- 追踪界面

local SearchUserDlg = Singleton("SearchUserDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")
local RecordType = {
    ["be_pk_record"] = 1,
    ["pk_record"] = 2,
    ["search_pk"] = 3,
}

local COUNT_PER_PAGE = 10

function SearchUserDlg:init()
    self:bindListener("SearchButton", self.onSearchButton)
    self:bindListener("DelAllButton", self.onCleanButton)
    self:bindListener("PKButton", self.onPKButton)
    self:bindListViewListener("MemberListView", self.onSelectMemberListView)

    self:setCtrlVisible("DelAllButton", false)
  --  self:visibleSearch(true)
    self:disableMemberListView(true)
    
    self.charInfo = {}

    self.itemCell = self:getControl("OneRowMemberPanel", nil, "MemberListView")
    self.itemCell:retain()
    self.itemCell:removeFromParent()

    -- 光效
    self.selectEff = self:getControl("ChosenEffectImage", nil, self.itemCell):clone()
    self.selectEff:setVisible(true)
    self.selectEff:retain()

    self.viewStart = 1
    self:bindListViewByPageLoad("MemberListView", "TouchPanel", function(dlg, percent)
        if percent > 100 then
            local index = self.radioGroup:getSelectedRadioIndex()
            local dType
            for k, v in pairs(RecordType) do
                if index == v then
                    dType = k
                    break
                end
            end
            self:appendList(PKDataMgr:getDataByType(dType, self.viewStart, COUNT_PER_PAGE))
        end
    end)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"KillMeCheckBox", "MyKilledCheckBox", "SearchCheckBox"}, self.onRadioSelect)
    self.radioGroup:selectRadio(1)
    
    self:bindEditField("InputPanel", 12, "", "SearchPanel")
    self:setCtrlVisible("DefaultLabel", false)
    
    self:hookMsg("MSG_PK_RECORD")
    self:hookMsg("MSG_RECORD_INFO")
    self:hookMsg("MSG_PK_FINGER")
    self:hookMsg("MSG_FIND_CHAR_MENU_FAIL")
    
    self:hookMsg("MSG_CHAR_INFO_EX")
    self:hookMsg("MSG_OFFLINE_CHAR_INFO")
end

function SearchUserDlg:cleanup()
    PKDataMgr:clearData()
    self:releaseCloneCtrl("selectEff")
    self:releaseCloneCtrl("itemCell")    
end

function SearchUserDlg:bindEditField(textFieldName, lenLimit, clenButtonName, root)
    self.newEdit = self:createEditBox(textFieldName, root, nil, function(sender, type) 
        if type == "end" then
        elseif type == "changed" then
            local newEditString = self.newEdit:getText()
            if gf:getTextLength(newEditString) > lenLimit then
                newEditString = gf:subString(newEditString, lenLimit)
                self.newEdit:setText(newEditString)
                gf:ShowSmallTips(CHS[4000224])
            end
            
            self:setCtrlVisible("DelAllButton", newEditString ~= "")
        end
    end)

    self.newEdit:setPlaceHolder(CHS[7001016])
    self.newEdit:setPlaceholderFontColor(COLOR3.GRAY)
    self.newEdit:setPlaceholderFont(CHS[3003597], 21)
    self.newEdit:setFont(CHS[3003597], 21)
    self.newEdit:setFontColor(COLOR3.WHITE)
    self.newEdit:setText("")
end

function SearchUserDlg:disableMemberListView(value)
    self:setCtrlVisible("SearchEmptyPanel", value, "MemberListPanel")
    self:setCtrlVisible("MemberListView", not value, "MemberListPanel")
end

function SearchUserDlg:visibleSearch(value)
    self:setCtrlVisible("SearchButton", value, "SearchPanel")
    self:setCtrlVisible("CleanButton", not value, "SearchPanel")
end

function SearchUserDlg:initList(datas)
    self.curDatas = datas;
    self:disableMemberListView(not datas or #datas <= 0)
    FriendMgr:unrequestCharMenuInfo(self.name)

    local listView = self:getControl("MemberListView")
    listView:removeAllChildren()

    local count = datas and #datas or 0
    for i = 1, count do
        listView:pushBackCustomItem(self:createCell(datas[i], i))
    end

    self.viewStart = self.viewStart + count
end

function SearchUserDlg:appendList(datas)
    if not datas or #datas <= 0 then return end

    local listView = self:getControl("MemberListView")

    if not self.viewStart then
        self.viewStart = 1
    end

    for i = 1, #datas do
        listView:pushBackCustomItem(self:createCell(datas[i], self.viewStart + i - 1))

        -- 将数据追加到 curDatas 上
        if not self.curDatas then
            self.curDatas = {}
        end

        table.insert(self.curDatas, datas[i])
    end

    local innerContainer = listView:getInnerContainerSize()
    innerContainer.height = #datas * self.itemCell:getContentSize().height
    listView:setInnerContainerSize(innerContainer)

    self.viewStart = self.viewStart + #datas
    listView:requestRefreshView()
end

-- 增加选中光效
function SearchUserDlg:addSelectEffect(sender)
    self.selectEff:removeFromParent()
    sender:addChild(self.selectEff)
    self.curSelect = sender:getTag()
end

function SearchUserDlg:createCell(data, index)
    local cell = self.itemCell:clone()

    cell:setTag(index)

    -- 头像
    local iconPath = ResMgr:getSmallPortrait(data.icon)
    self:setImage("GuardImage", iconPath, cell)
    self:setItemImageSize("GuardImage", cell)
    if not data.server_name or "" == data.server_name then
        local imgCtrl = self:getControl("GuardImage", Const.UIImage, cell)
        gf:grayImageView(imgCtrl)
    else
        local imgCtrl = self:getControl("GuardImage", Const.UIImage, cell)
        gf:resetImageView(imgCtrl)
    end

    -- 等级
    self:setNumImgForPanel("GuardImage", ART_FONT_COLOR.NORMAL_TEXT, data.level, false, LOCATE_POSITION.LEFT_TOP, 21, cell)

    -- 名字
    self:setLabelText("NameLabel", gf:getRealName(data.name), cell)

    -- 线路
    if not data.server_name or "" == data.server_name then
        self:setLabelText("LinelLabel", CHS[2000155], cell)
    else
        local distName, serverId = DistMgr:getServerShowName(data.server_name)
        if nil == distName then
            distName = GameMgr:getServerName()
        end

        if "" ~= serverId then
            self:setLabelText("LinelLabel", string.format(CHS[7000119], serverId), cell)
        else
            self:setLabelText("LinelLabel", distName, cell)
        end
    end

    if 0 == index % 2 then
        self:setCtrlVisible("BackImage_1", true, cell)
        self:setCtrlVisible("BackImage_2", false, cell)
    else
        self:setCtrlVisible("BackImage_1", false, cell)
        self:setCtrlVisible("BackImage_2", true, cell)
    end

    if 1 == index then
        self:addSelectEffect(cell)
    end

    self:bindListener("CommunicationButton", function(sender, eventType)
        if Me:getName() == data["name"] then
            gf:ShowSmallTips(CHS[4100148])
            return
        end
        
        local info = self.charInfo[data["gid"]]
        if info then
            FriendMgr:communicat(info.name, info.gid, info.icon, info.level)
        else
            FriendMgr:requestCharMenuInfo(data["gid"], nil, "SearchUserDlg", 1)
            self.communicatGid = data["gid"]
        end
    end, cell)

    self:bindListener("NoteButton", function(sender, eventType)
        local rect = self:getBoundingBoxInWorldSpace(self:getControl("NoteButton", nil, cell))
        FriendMgr:requestCharMenuInfo(data.gid, function()
            local dlg = DlgMgr:openDlg("CharMenuContentDlg")
            if dlg then
                dlg:setting(data.gid)
                dlg:setFloatingFramePos(rect)
            end
        end)
    end, cell)

    return cell
end

function SearchUserDlg:MSG_CHAR_INFO_EX(data)
    if data.msg_type ~= "SearchUserDlg" or self.communicatGid ~= data.gid then
        return
    end
    
    self.charInfo[data.gid] = data
    self.communicatGid = nil
    FriendMgr:communicat(data.name, data.gid, data.icon, data.level)
end

function SearchUserDlg:MSG_OFFLINE_CHAR_INFO(data)
    self:MSG_CHAR_INFO_EX(data)
end

function SearchUserDlg:refreshCurData(datas)
    if not self.curDatas or #self.curDatas < 0 then return end

    local listView = self:getControl("MemberListView")
    local items = listView:getItems()
    for i = 1, #items do
        local item = items[i]
        local index = item:getTag()
        local data = self.curDatas[index]
        if data and datas.list and datas.list[data.gid] then
            local gsName = datas.list[data.gid]

            local imgCtrl = self:getControl("GuardImage", Const.UIImage, item)
            if not gsName or "" == gsName then
                gf:grayImageView(imgCtrl)
                self:setLabelText("LinelLabel", CHS[2000155], item)
            else
                gf:resetImageView(imgCtrl)
                local distName, serverId = DistMgr:getServerShowName(gsName)

                if nil == distName then
                    distName = GameMgr:getServerName()
                end

                if "" ~= serverId then
                    self:setLabelText("LinelLabel", string.format(CHS[7000119], serverId), item)
                else
                    self:setLabelText("LinelLabel", distName, item)
                end
            end
        end
    end
end

function SearchUserDlg:onRadioSelect(sender, eventType)
    local name = sender:getName()
    self.curDatas = nil
    self.curSelect = 0
    self.viewStart = 1
    if "KillMeCheckBox" == name then
        self:onKillMeCheck()
    elseif "MyKilledCheckBox" == name then
        self:onMyKilledCheck()
    elseif "SearchCheckBox" == name then
        self:onSearchCheck()
    end
end

function SearchUserDlg:onKillMeCheck()
    self.recordType = RecordType.be_pk_record
    local list = PKDataMgr:getDataByType("be_pk_record", 1, COUNT_PER_PAGE)
    if not list or #list <= 0 then
        PKDataMgr:requestPkInfo("be_pk_record", para1, para2)
        self:initList()
    else
        self:initList(list)
    end
end

function SearchUserDlg:onMyKilledCheck()
    self.recordType = RecordType.pk_record
    local list = PKDataMgr:getDataByType("pk_record", 1, COUNT_PER_PAGE)
    if not list or #list <= 0 then
        PKDataMgr:requestPkInfo("pk_record", para1, para2)
        self:initList()
    else
        self:initList(list)
    end
end

function SearchUserDlg:onSearchCheck()
    self.recordType = RecordType.search_pk
    local list = PKDataMgr:getDataByType("search_pk", 1, COUNT_PER_PAGE)
    if list then
        self:initList(list)
    end
end

function SearchUserDlg:onSearchButton(sender, eventType)
    if not self.newEdit then
        return
    end
    
    local text = self.newEdit:getText()
    if not text or #text <= 0 then
        gf:ShowSmallTips(CHS[2000156])
        return
    end

    local para1, para2
    if nil ~= tonumber(text, 16) then
        if gf:getShowId(Me:queryBasic("gid")) == text then
            gf:ShowSmallTips(CHS[3002645])
            return
        end

        -- 根据id查找
        para1 = text
        para2 = 2
    else
        if Me:queryBasic("name") == text then
            gf:ShowSmallTips(CHS[3002645])
            return
        end

        -- 根据名字查找
        para1 = text
        para2 = 1
    end

    PKDataMgr:clearDataByType("search_pk")
    self.radioGroup:selectRadio(3)
    self:disableMemberListView(false)    -- 先禁用无数据
    PKDataMgr:requestPkInfo("search_pk", para1, para2)

 --   self:visibleSearch(false)
end

function SearchUserDlg:onCleanButton(sender, eventType)
    self.newEdit:setText("")
    self:setCtrlVisible("DelAllButton", false)
end

function SearchUserDlg:onPKButton(sender, eventType)
    if not self.curDatas then
        gf:ShowSmallTips(CHS[2000157])
        return
    end

    local idx = self.curSelect
    if not idx or idx <= 0 then
        gf:ShowSmallTips(CHS[2000157])
        return
    end

    local value = self.curDatas[idx]

    if not value or not value.server_name or "" == value.server_name then
        gf:ShowSmallTips(CHS[2000158])
        return
    end

    gf:CmdToServer("CMD_GOTO_PK", { gid = value.gid })
    DlgMgr:closeDlg(self.name)
end

function SearchUserDlg:onSelectMemberListView(sender, eventType)
    local idx = self:getListViewSelectedItemTag(sender)

    -- 选中效果
    local panel = self:getListViewSelectedItem(sender)
    self:addSelectEffect(panel)
end

function SearchUserDlg:MSG_PK_RECORD(data)
    if not data.type or RecordType[data.type] ~= self.recordType then return end
    local idx = RecordType[data.type]
    if self.radioGroup:getSelectedRadioIndex() ~= idx then return end

    local listView = self:getControl("MemberListView")
    local datas = listView:getItems()
    if not self.curDatas or #self.curDatas <= 0 then
        self:initList(PKDataMgr:getDataByType(data.type, self.viewStart, COUNT_PER_PAGE))
    end
end

function SearchUserDlg:MSG_RECORD_INFO(data)
    self:refreshCurData(data)
end

function SearchUserDlg:MSG_PK_FINGER(data)
    data.type = 'search_pk'
    self:MSG_PK_RECORD(data)
end

function SearchUserDlg:MSG_FIND_CHAR_MENU_FAIL(data)
    gf:ShowSmallTips(CHS[3003112])
end

return SearchUserDlg
