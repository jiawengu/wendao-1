-- GatherBankDlg.lua
-- Created by lixh Jul/13/2018
-- 银行卡信息提交界面

local GatherBankDlg = Singleton("GatherBankDlg", Dialog)

local BANK_NAME = require(ResMgr:getCfgPath("BankCfg.lua"))
local CITY_CFG = require(ResMgr:getCfgPath("CityCfg.lua"))

local NUM_LENTH_LIMIT = {
    ["PhonePanel"] = 11,
    ["BankCardPanel"] = 19,
}

local EDIT_BOX_CFG = {
    ["NamePanel"]          = {TEXT_LENTH_LIMIT = 24, EDIT_BOX_NAME = "NameEditBox"},
    ["IDPanel"]            = {TEXT_LENTH_LIMIT = 18, EDIT_BOX_NAME = "IdEditBox"},
    ["WeChatPanel"]        = {TEXT_LENTH_LIMIT = 24, EDIT_BOX_NAME = "WeChatEditBox"},
    ["InputBankNamePanel"] = {TEXT_LENTH_LIMIT = 16, EDIT_BOX_NAME = "AddressEditBox"},
}

local UNIT_NUMBER_HEIGHT = 44

function GatherBankDlg:init()
    -- 选择列表当做悬浮框处理
    self:bindFloatPanelListener("SelectBankPanel")

    -- 姓名,id,微信号,银行开户行名称2,采用输入法输入
    self.nameEditBox    = self:initEditBox("NamePanel")
    self.idEditBox      = self:initEditBox("IDPanel")
    self.wechatEditBox  = self:initEditBox("WeChatPanel")

    self:bindTextField("InputBankNamePanel")

    self:bindListener("DelButton", self.onEditBoxDelButton, "NamePanel")
    self:bindListener("DelButton", self.onEditBoxDelButton, "IDPanel")
    self:bindListener("DelButton", self.onEditBoxDelButton, "WeChatPanel")

    -- 手机号,银行卡号，采用小数字键盘输入
    self:bindNumInput("InputPanel", "PhonePanel", self.numberLimitCallBack, "PhonePanel", true)
    self:bindNumInput("InputPanel", "BankCardPanel", self.numberLimitCallBack, "BankCardPanel", true)
    self:bindListener("DelButton", self.onNumDelButton, "PhonePanel")
    self:bindListener("DelButton", self.onNumDelButton, "BankCardPanel")

    -- 银行开户行名称1，开户行所在地址1，开户行所在地址2，支持ListView滑动选择
    self:bindListener("InputPanel", self.onTableChoose, "BankNamePanel")
    self:bindListener("InputPanel", self.onTableChoose, "BankAddressPanel_1")
    self:bindListener("InputPanel", self.onTableChoose, "BankAddressPanel_2")

    self:bindListViewListener("ListView", self.onSelectListView)
    self.unitItem = self:retainCtrl("UnitNumPanel", "SelectBankPanel")
    UNIT_NUMBER_HEIGHT = self.unitItem:getContentSize().height
    self:bindListViewListenr()

    -- 银行开户行名称1，开户行所在地址1，开户行所在地址2
    self:bindListener("ConfirmButton", self.onChooseConfirmButton, "SelectBankPanel")

    -- 提交所有信息
    self:bindListener("ConfirmButton", self.onConfirmButton, "InfoPanel")
end

-- 设置邮件信息
function GatherBankDlg:setMailInfo(data)
    if not data then return end
    self.mailId = data.id
    self.mailType = tonumber(data.type)

    local ts = data.date
    local tsArray = os.time{year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6),
        day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}
    self.mailEndTime = tsArray
    self:setLabelText("NoteLabel", gf:getServerDate(CHS[5420175], tsArray))
end

-- 初始化EditBox输入
function GatherBankDlg:bindTextField(root)
    self:bindEditFieldForSafe(root, EDIT_BOX_CFG[root].TEXT_LENTH_LIMIT,
        nil, cc.VERTICAL_TEXT_ALIGNMENT_TOP, function(dlg, sender, eventType)
            if ccui.TextFiledEventType.insert_text == eventType or ccui.TextFiledEventType.delete_backward == eventType then
                if root == "InputBankNamePanel" then
                    -- 输入开户行名称2，还应该清除开户行名称1
                    self:setLabelText("YearLabel", "", self:getControl("InputPanel", nil, "BankNamePanel"))
                end
            end
        end
    )
end

-- 初始化EditBox输入
function GatherBankDlg:initEditBox(root)
    local editBox = self:createEditBox("InputPanel", root, nil, function(self, type, sender) 
        if type == "changed" then
            local newText = sender:getText()
            local textLength = gf:getTextLength(newText)
            local textLenthLimit = EDIT_BOX_CFG[root].TEXT_LENTH_LIMIT
            if textLength > textLenthLimit then
                newText = gf:subString(newText, textLenthLimit)
                sender:setText(newText)
                gf:ShowSmallTips(CHS[5400041])
            end

            self:setCtrlVisible("DelButton", textLength ~= 0, root)
            self:setCtrlVisible("DefaultLabel", textLength == 0, root)
        end
    end)

    editBox:setName(EDIT_BOX_CFG[root].EDIT_BOX_NAME)
    editBox:setLocalZOrder(1)
    editBox:setPlaceholderFont(CHS[3003597], 20)
    editBox:setFont(CHS[3003597], 20)
    editBox:setFontColor(cc.c3b(86, 41, 2))
    editBox:setText("")
    return editBox
end

-- EditBox，清空按钮
function GatherBankDlg:onEditBoxDelButton(sender, eventType)
    local parent = sender:getParent()
    local inputPanel = parent:getChildByName("InputPanel")
    local editBoxName = EDIT_BOX_CFG[parent:getName()].EDIT_BOX_NAME
    if not editBoxName or not inputPanel then return end
    local editBox = inputPanel:getChildByName(editBoxName)
    if not editBox then return end

    editBox:setText("")
    self:setCtrlVisible("DelButton", false, parent)
    self:setCtrlVisible("DefaultLabel", true, parent)
end

-- 数字键盘，打开界面后回调
function GatherBankDlg:doWhenOpenNumInput(ctrlName, root)
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(self:getLabelText("NumLabel", root))
    end
end

-- 数字键盘，输入回调
function GatherBankDlg:insertNumber(num, key)
    local lenth = gf:getTextLength(num)
    if lenth > NUM_LENTH_LIMIT[key] then
        local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
        if dlg then
            dlg:setInputValue(self:getLabelText("NumLabel", key))
        end

        gf:ShowSmallTips(CHS[5400041])
        return
    end 

    self:setCtrlVisible("DefaultLabel", lenth == 0, key)
    self:setCtrlVisible("DelButton", lenth ~= 0, key)
    self:setLabelText("NumLabel", num, key)
end

-- 数字键盘，清空按钮
function GatherBankDlg:onNumDelButton(sender, eventType)
    local parent = sender:getParent()
    self:setLabelText("NumLabel", "", parent)
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue("")
    end

    self:setCtrlVisible("DelButton", false, parent)
    self:setCtrlVisible("DefaultLabel", true, parent)
end

-- 打开选择列表
function GatherBankDlg:onTableChoose(sender, eventType)
    local cfg = BANK_NAME
    local parentName = sender:getParent():getName()
    if parentName == "BankAddressPanel_1" then
        cfg = self:getCityList()
    elseif parentName == "BankAddressPanel_2" then
        cfg = self:getCityList(self:getLabelText("YearLabel", "BankAddressPanel_1"))
    end

    -- 配置不存在
    if not cfg then return end

    self:setChooseTable(cfg)
    self:setCtrlVisible("SelectBankPanel", true)
    self.chooseTableRoot = parentName
end

-- 设置选择列表内容，首尾放两个空白的item
function GatherBankDlg:setChooseTable(list)
    local listView = self:resetListView("NameListView")
    listView:pushBackCustomItem(self.unitItem:clone())
    listView:pushBackCustomItem(self.unitItem:clone())
    for i = 1, #list do
        local item = self.unitItem:clone()
        self:setLabelText("NumberLabel", list[i], item)
        listView:pushBackCustomItem(item)
    end

    listView:pushBackCustomItem(self.unitItem:clone())
end

-- 获取城市列表
-- 有省份参数，返回市列表 ， 否则返回省列表
function GatherBankDlg:getCityList(province)
    if province then
        local provinceCfg = CITY_CFG[province]
        if not provinceCfg then return end
        return provinceCfg.city
    end

    local list = {}
    for k, v in pairs(CITY_CFG) do
        table.insert(list, v)
    end

    table.sort(list, function(l, r)
        return l.order < r.order
    end)

    local ret = {}
    for i = 1, #list do
        table.insert(ret, list[i].name)
    end

    return ret
end

-- 开户行名称，开户行地址1，开户行地址2，确认
function GatherBankDlg:onChooseConfirmButton(sender, eventType)
    self:setCtrlVisible("SelectBankPanel", false)

    local listView = self:getControl("NameListView")
    local listViewHeight = listView:getContentSize().height
    local innerContainer = listView:getInnerContainer()
    local height = innerContainer:getContentSize().height
    local positionY = innerContainer:getPositionY()
    local posY = positionY + height - listViewHeight
    local index = posY / self.unitItem:getContentSize().height + 0.0001
    index = math.floor(index) + 1 + 2
    local item = listView:getItems()[index]
    if not item then return end

    local text = self:getLabelText("NumberLabel", item)
    if string.isNilOrEmpty(text) then return end

    self:setLabelText("YearLabel", text, self.chooseTableRoot)
    self:setCtrlVisible("DefaultLabel", false, self.chooseTableRoot)
    if self.chooseTableRoot == "BankNamePanel" then
        -- 开户行名称选中，还应清空自行填写的开户行名称2
        self:getControl("InputPanel", nil, "InputBankNamePanel"):getChildByName("TextField"):setText("")
        self:setCtrlVisible("DefaultLabel", true, "InputBankNamePanel")
    elseif self.chooseTableRoot == "BankAddressPanel_1" then
        -- 开户行地址1选中，还应清空开户行地址2
        self:setLabelText("YearLabel", "", "BankAddressPanel_2")
    end
end

-- 提交所有信息
function GatherBankDlg:onConfirmButton(sender, eventType)
    local name = self:getControl("InputPanel", nil, "NamePanel"):getChildByName("NameEditBox"):getText()
    local id = self:getControl("InputPanel", nil, "IDPanel"):getChildByName("IdEditBox"):getText()
    local phoneNum = self:getLabelText("NumLabel", "PhonePanel")
    local weChat = self:getControl("InputPanel", nil, "WeChatPanel"):getChildByName("WeChatEditBox"):getText()
    local bankCardNum = self:getLabelText("NumLabel", "BankCardPanel")
    local bankName1 = self:getLabelText("YearLabel", self:getControl("InputPanel", nil, "BankNamePanel"))
    local bankName2 = self:getControl("InputPanel", nil, "InputBankNamePanel"):getChildByName("TextField"):getStringValue()
    local bandAddress1 = self:getLabelText("YearLabel", self:getControl("InputPanel", nil, "BankAddressPanel_1"))
    local bandAddress2 = self:getLabelText("YearLabel", self:getControl("InputPanel", nil, "BankAddressPanel_2"))
    
    local blankTips = self:getEmptyStrTips(name, id, phoneNum, bankCardNum, bankName1, bankName2, bandAddress1, bandAddress2)
    if blankTips ~= "" then
        -- 有未填写信息
        gf:ShowSmallTips(blankTips .. CHS[7100279])
        return
    end

    if not gf:chechCard(id) then
        -- 身份证号不合法
        return
    end

    if string.len(phoneNum) ~= 11 then
        -- 手机号不合法
        gf:ShowSmallTips(CHS[4300330])
        return
    end 
    
    if tonumber(string.sub(phoneNum, 1, 1)) ~= 1 then
        -- 手机号不合法
        gf:ShowSmallTips(CHS[4300330])
        return
    end

    local bankNumLength = string.len(bankCardNum)
    if bankNumLength > 19 or bankNumLength < 16 then
        -- 银行卡号不合法
        gf:ShowSmallTips(CHS[7120145])
        return
    end

    if self.mailEndTime and tonumber(self.mailEndTime) < gf:getServerTime() then
        -- 提交时间已过
        gf:ShowSmallTips(string.format(CHS[4300092], self.mailEndTime))
        return
    end

    gf:confirm(CHS[4300309], function ()
        gf:CmdToServer('CMD_MAILBOX_GATHER', {
            ["mail_type"] = self.mailType,
            ["mail_id"] = self.mailId,
            ["mail_oper"] = 1,
            ["name"] = name,
            ["id"] = id,
            ["tel"] = phoneNum,
            ["we_chat"] = weChat,
            ["bank_id"] = bankCardNum,
            ["bank_name"] = (bankName1 == "" and bankName2 or bankName1),
            ["bank_city"] = bandAddress1 .. bandAddress2
        })
        DlgMgr:closeDlg(self.name)
    end)
end

function GatherBankDlg:getEmptyStrTips(name, id, phoneNum, bankCardNum, bankName1, bankName2, bandAddress1, bandAddress2)
    local tips = ""
    if name == "" then tips = self:getConcatStr(tips, CHS[7100273]) end
    if id == "" then tips = self:getConcatStr(tips, CHS[7100274]) end
    if phoneNum == "" then tips = self:getConcatStr(tips, CHS[7100275]) end
    if bankCardNum == "" then tips = self:getConcatStr(tips, CHS[7100276]) end
    if bankName1 == "" and bankName2 == "" then tips = self:getConcatStr(tips, CHS[7100277]) end
    if bandAddress1 == "" or (bandAddress1 ~= "" and bandAddress2 == "" 
        and bandAddress1 ~= CHS[7100280] and bandAddress1 ~= CHS[7100281] and bandAddress1 ~= CHS[7100282]
        and bandAddress1 ~= CHS[7180003]) then
        -- 开户行地址1为空, 或开户行地址1非空，且不是北京、天津、上海、重庆，开户行地址2为空，则要提示2不能为空
        tips = self:getConcatStr(tips, CHS[7100278])
    end

    return tips
end

function GatherBankDlg:getConcatStr(str, addStr)
    if addStr == "" then return str end
    if str == "" then
        return addStr
    else
        return str .. "、" .. addStr
    end
end

function GatherBankDlg:onSelectListView(sender, eventType)
end

-- 滑动选择银行名称、城市名称
function GatherBankDlg:bindListViewListenr()
    local listView = self:getControl("NameListView")
    local lastPercent
    local  function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local delay = cc.DelayTime:create(0.1)
            local func = cc.CallFunc:create(function()
                local percent = self:getCurScrollPercent(sender)
                if percent <= 0 or percent >= 100 then return end

                self:setDestPercent(sender, lastPercent, lastY)
                lastPercent, lastY = self:getCurScrollPercent(sender)
            end)

            sender:stopAllActions()
            sender:runAction(cc.Sequence:create(delay, func))
        end
    end

    listView:addScrollViewEventListener(scrollListener)    
end

-- 获取当前ListView滚动百分比
function GatherBankDlg:getCurScrollPercent(listView)
    local height = listView:getInnerContainer():getContentSize().height
    local curPosY = listView:getInnerContainer():getPositionY()    
    local disHeight = (curPosY + (height - listView:getContentSize().height))
    local percent = disHeight / (height - listView:getContentSize().height)    
    return percent, curPosY
end

function GatherBankDlg:setDestPercent(listView, lastPercent, lastY)
    local height = listView:getInnerContainer():getContentSize().height
    local curPosY = listView:getInnerContainer():getPositionY()    
    local disHeight = (curPosY + (height - listView:getContentSize().height))
    if disHeight <= 0 or disHeight >= (height - listView:getContentSize().height) then return end

    local floatHeight = disHeight % UNIT_NUMBER_HEIGHT
    if floatHeight > UNIT_NUMBER_HEIGHT * 0.5 then
        disHeight = disHeight - floatHeight + UNIT_NUMBER_HEIGHT
    else
        disHeight = disHeight - floatHeight
    end

    local percent = disHeight / (height - listView:getContentSize().height)    
    listView:scrollToPercentVertical(percent * 100, 0.2, false)
end

return GatherBankDlg
