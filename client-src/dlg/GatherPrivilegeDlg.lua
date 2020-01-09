-- GatherPrivilegeDlg.lua
-- Created by songcw
-- 大R玩家信息收集

local GatherPrivilegeDlg = Singleton("GatherPrivilegeDlg", Dialog)

local NOMRO_LIMIT = 12 * 2
local ADDRESS_LIMIT = 40 * 2

local YEAR_COUNT = 100
local MONTH_COUNT = 12

-- 滚动结束后，自动滚动到目标值时间
local AUTO_SCROLL_TIME = 0.2

local MONTH_DAY_MAP = {
--      1   2   3   4   5   6   7   8   9   10  11  12
        31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31, 
}

-- 默认文字
local PANEL_MAP = {
    ["NamePanel"]           = CHS[4300299],             -- "点击输入真实姓名",
    ["IDPanel"]             = CHS[4300300],             -- "点击输入身份证号",
    ["PhonePanel"]          = CHS[4300301],             -- "点击输入手机号", 
    ["WeChatPanel"]         = CHS[4300302],             -- "点击输入微信号",
    ["BirthdayPanel"]       = {CHS[4000161], CHS[4300152], CHS[5000240],},--CHS[4300303],             -- "点击输入年月日数字，如19910120"
    ["AddressPanel"]        = "",             -- "点击输入联系地址",
}

-- 若没有输入，给予的提示名称
local PANEL_TITLE = {
    ["NamePanel"]           = CHS[4300310],             -- "姓名",
    ["IDPanel"]             = CHS[4300305],             -- "身份证号",
    ["PhonePanel"]          = CHS[4300306]              -- "手机号",
}

-- 必须填写的
local PANEL_ORDER_HAVETO = {
    "NamePanel", "IDPanel", "PhonePanel", 
}

local PANEL_ORDER_ALL = {
    "NamePanel", "IDPanel", "PhonePanel",  "WeChatPanel", "BirthdayPanel", "AddressPanel"   
}

-- 单个数字panel的高度，生日滚轮处用，代码中根据实际高度会再次赋值
local UNIT_NUMBER_HEIGHT = 36


local NAME_LIMIT = 12 * 2
local ID_CARD_LIMIT = 9 * 2
local PHONE_LIMIT = 5 * 2 + 1
local WECAT_LIMIT = 12 * 2

function GatherPrivilegeDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("BirthdayConfirmButton", self.onBirthdayConfirmButton)
    self:bindListener("ConfrimButton", self.onNoticeShowPanel, "NoticeShowPanel")
    self:bindListener("CloseButton2", self.onCloseButton2)
    
    self:bindListener("TextLabel1", self.onShowNoticeButton, "InfoPanel")
    self:setCheck("CheckBox", true)
    
    self:bindFloatPanelListener("BirthdayNumPanel")    
    
    self:initEdit("NamePanel", "NamePanel", NAME_LIMIT, PANEL_MAP["NamePanel"])
    self:initEdit("IDPanel", "IDPanel", ID_CARD_LIMIT, PANEL_MAP["IDPanel"])
    self:bindNumInput("InputPanel", "PhonePanel", nil, "PhonePanel", true)  
    self:initEdit("WeChatPanel", "WeChatPanel", WECAT_LIMIT, PANEL_MAP["WeChatPanel"])
    self:initBirthdayPanel()
    self:initEditAddress("AddressPanel", "AddressPanel", ADDRESS_LIMIT, PANEL_MAP["AddressPanel"])
    
    for panelName, tips in pairs(PANEL_MAP) do
        self:bindListener("DelButton", self.onDelButton, panelName)
        local btn = self:getControl("DelButton", nil, panelName)
        if btn then
            -- 新界面中生日日期没有btn
            self:onDelButton(btn)
        end
    end
end

function GatherPrivilegeDlg:initListView(list, defCount, minValue, defValu)

    for i = 1, defCount + 4 do
        local uPanel = self.numPanel:clone()
        uPanel:setContentSize(list:getContentSize().width, UNIT_NUMBER_HEIGHT)
        if i <= 2 then
            self:setLabelText("NumberLabel", "", uPanel)
        elseif i >= defCount + 3 then            
            self:setLabelText("NumberLabel", "", uPanel)
        else
            self:setLabelText("NumberLabel", minValue + i - 2 - 1, uPanel)
        end
        list:pushBackCustomItem(uPanel)
    end
    
    list.minValue = minValue
    list.maxValue = minValue + defCount - 1 
    self:updateList(list)   
    list:refreshView()
    if defValu then
  --      performWithDelay(list:getParent(), function ()
            self:setListByValue(list, defValu)
  --      end, 0)
    end
end

-- 初始化生日的panel
function GatherPrivilegeDlg:initBirthdayPanel()
    local panel = self:getControl("BirthdayPanel")
    local strTab = PANEL_MAP["BirthdayPanel"]
    self:setLabelText("YearLabel", strTab[1], nil, COLOR3.GRAY)
    self:setLabelText("MonthLabel", strTab[2], nil, COLOR3.GRAY)
    self:setLabelText("DayLabel", strTab[3], nil, COLOR3.GRAY)
    
    for i = 1, 3 do
        self:bindListener("InputPanel" .. i, self.onBirthDay, panel)
    end
    
    
    local year = gf:getServerDate("*t", gf:getServerTime())["year"]
    local month = gf:getServerDate("*t", gf:getServerTime())["month"]
    local day = gf:getServerDate("*t", gf:getServerTime())["day"]
    local minYear = year - 100 + 1
    
    self.numPanel = self:retainCtrl("UnitNumPanel")
    UNIT_NUMBER_HEIGHT = self.numPanel:getContentSize().height



    local yList = self:resetListView("YearListView")
    self:initListView(yList, YEAR_COUNT, minYear, year - 30)
    local mList = self:resetListView("MonthListView")
    self:initListView(mList, 12, 1, month)
    local dList = self:resetListView("DayListView")
    self:initListView(dList, 31, 1, day) 
end


-- 获取当前ListView滚动百分比
function GatherPrivilegeDlg:onBirthdayConfirmButton()
    local yList = self:getControl("YearListView")
    local mList = self:getControl("MonthListView")
    local dList = self:getControl("DayListView")

    if yList.scrolling or mList.scrolling or dList.scrolling then
        -- 如果有还在滚动，则return
        gf:ShowSmallTips(CHS[4300328])  -- 当前有数字处于未选中状态，请稍后再试。
        return
    end
    
    
    local year = self:getListView(yList)
    local month = self:getListView(mList)
    local day = self:getListView(dList)
    
    self:setLabelText("YearLabel", year, nil, COLOR3.TEXT_DEFAULT)
    self:setLabelText("MonthLabel", month, nil, COLOR3.TEXT_DEFAULT)
    self:setLabelText("DayLabel", day, nil, COLOR3.TEXT_DEFAULT)
    
    self:setCtrlVisible("BirthdayNumPanel", false)
end

function GatherPrivilegeDlg:setListByValue(listView, value)
    local ret = value - listView.minValue
    local retHeight = ret * UNIT_NUMBER_HEIGHT
    local height = listView:getInnerContainer():getContentSize().height
    local percent = retHeight / (height - listView:getContentSize().height)   
    
    listView:getInnerContainer():setPositionY(listView:getContentSize().height - height + retHeight) 
end


function GatherPrivilegeDlg:setDestPercent(listView, lastPercent, lastY)
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
    
    if lastY == curPosY then
        listView.scrolling = false 
        return 
    end
    
    --[[
    if lastPercent and math.abs(lastPercent - percent) <= 0.0001  then
        listView.scrolling = false 
        return 
    end
    --]]
    
    listView:scrollToPercentVertical(percent * 100, AUTO_SCROLL_TIME, false)
end


function GatherPrivilegeDlg:getListView(listView)
    if listView.scrolling then return end
    local height = listView:getInnerContainer():getContentSize().height
    local curPosX = listView:getInnerContainer():getPositionY()    
    local disHeight = (curPosX + (height - listView:getContentSize().height))
    
    disHeight = disHeight + 5 -- 加上5像素误差
    local value = listView.minValue + math.floor(disHeight / UNIT_NUMBER_HEIGHT)
    return value
end


function GatherPrivilegeDlg:checkBirthValidity()
    local yList = self:getControl("YearListView")
    local mList = self:getControl("MonthListView")
    local dList = self:getControl("DayListView")
    
    if yList.scrolling or mList.scrolling or dList.scrolling then
        -- 如果有还在滚动，则return
        return
    end
    
    local year = self:getListView(yList)
    local month = self:getListView(mList)
    local day = self:getListView(dList)
    
    local dayMax = MONTH_DAY_MAP[month]
    if month == 2 and year % 4 == 0 then
        -- 如果是2月闰年，29天
        dayMax = 29
    end
    
    if dList.maxValue ~= dayMax then
        local dList = self:resetListView("DayListView")
        local def = day > dayMax and 1 or day
        if day > dayMax then
            gf:ShowSmallTips(CHS[4300329])
        end
        
        self:initListView(dList, dayMax, 1, def) 
    end
end


-- 获取当前ListView滚动百分比
function GatherPrivilegeDlg:getCurScrollPercent(listView)
    local height = listView:getInnerContainer():getContentSize().height
    local curPosX = listView:getInnerContainer():getPositionY()    
    local disHeight = (curPosX + (height - listView:getContentSize().height))
    local percent = disHeight / (height - listView:getContentSize().height)    
    return percent, curPosX
end

-- 更新右侧信息
function GatherPrivilegeDlg:updateList(list)
    local lastPercent, lastY
    local  function scrollListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrolling then
            local delay = cc.DelayTime:create(0.1)
            local func = cc.CallFunc:create(function()
                local percent = self:getCurScrollPercent(sender)
                if percent <= 0 or percent >= 100 then return end

                self:setDestPercent(sender, lastPercent, lastY)
                lastPercent, lastY = self:getCurScrollPercent(sender)                
            end)
            
            local func2 = cc.CallFunc:create(function()
                 -- 如果是年、月的listView，滚动结束后们需要重置日的滚轮
                sender.scrolling = false
                
                self:checkBirthValidity()            
            end)

            sender:stopAllActions()
            sender.scrolling = true
            sender:runAction(cc.Sequence:create(delay, func, cc.DelayTime:create(AUTO_SCROLL_TIME), func2))
        end
    end

    list:addScrollViewEventListener(scrollListener)    
end

function GatherPrivilegeDlg:onBirthDay(sender, eventType)
    self:setCtrlVisible("BirthdayNumPanel", true)   
end

-- 重写的原因是，希望再次点能继续输入，增加了 dlg:setInputValue(self[key .. "value"] or "")  
function GatherPrivilegeDlg:bindNumInput(ctrlName, root, limitCallBack, key, isString)
    local panel = self:getControl(ctrlName, nil, root)
    local function openNumIuputDlg()
        if limitCallBack and "function" == type(limitCallBack) then
            if limitCallBack(self) then
                return
            end
        end

        local rect = self:getBoundingBoxInWorldSpace(panel)
        local dlg = DlgMgr:openDlg("SmallNumInputDlg")
        dlg:setObj(self)
        dlg:setKey(key)
        dlg:setIsString(true == isString and true or false)
        dlg:updatePosition(rect)
        dlg:setInputValue(self[key .. "value"] or "")        
        if self.doWhenOpenNumInput then
            self:doWhenOpenNumInput(ctrlName, root)
        end
    end

    self:bindListener(ctrlName, openNumIuputDlg, root)
end

-- 数字键盘插入数字
function GatherPrivilegeDlg:insertNumber(num, key)

    if gf:getTextLength(num) > PHONE_LIMIT then
        num = gf:subString(num, PHONE_LIMIT)
        gf:ShowSmallTips(CHS[5400041])
    end    

    self[key .. "value"] = num
    self:setLabelText("NumLabel", num, key, COLOR3.ORANGE)

    -- 更新键盘数据
    local dlg = DlgMgr.dlgs["SmallNumInputDlg"]
    if dlg then
        dlg:setInputValue(num)
    end
    
    local panel = self:getControl(key)
    self:setCtrlVisible("DelButton", num ~= "", panel)
    
    if num == "" then
        self:setLabelText("NumLabel", PANEL_MAP[key], key, COLOR3.GRAY)
    end
end

function GatherPrivilegeDlg:initEditAddress(key, panelName, limit, defStr, isTop)
    self[key] = self:createEditBox("InputPanel", panelName, nil, function(sender, type) 
        if type == "ended" then
            self[key]:setText("")
            self:setCtrlVisible("NumLabel", true, panelName)
        elseif type == "began" then
            local msg = self:getLabelText("NumLabel", panelName)
            self[key]:setText(msg)
            self:setCtrlVisible("NumLabel", false, panelName)
        elseif type == "changed" then
            local newName = self[key]:getText()
            if gf:getTextLength(newName) > limit then
                newName = gf:subString(newName, limit)
                self[key]:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end    

            self[key .. "value"] = newName
            if gf:getTextLength(newName) ~= 0 then                
                self:setCtrlVisible("DelButton", true, panelName)
                self:setLabelText("NumLabel", newName, panelName, COLOR3.TEXT_DEFAULT)
                self:setCtrlVisible("DefaultLabel", false, panelName)
            else                
                self:setLabelText("NumLabel", "", panelName, COLOR3.GRAY)
                self:setCtrlVisible("DelButton", false, panelName)
                self:setCtrlVisible("DefaultLabel", true, panelName)
            end  
        end
    end, isTop)
  --  self:setLabelText("NumLabel", PANEL_MAP[key], panelName, COLOR3.GRAY)
    self[key]:setLocalZOrder(1)
    self[key]:setPlaceholderFont(CHS[3003794], 19)
    self[key]:setPlaceHolder("")
    self[key]:setPlaceholderFontColor(COLOR3.GRAY)
    self[key]:setFont(CHS[3003597], 19)
    self[key]:setFontColor(cc.c3b(76, 32, 0))  
end

function GatherPrivilegeDlg:initEdit(key, panelName, limit, defStr, isTop)
    self[key] = self:createEditBox("InputPanel", panelName, nil, function(sender, type) 
        if type == "ended" then
        elseif type == "began" then
        elseif type == "changed" then
            local newName = self[key]:getText()
            if gf:getTextLength(newName) > limit then
                newName = gf:subString(newName, limit)
                self[key]:setText(newName)
                gf:ShowSmallTips(CHS[5400041])
            end    

            self[key .. "value"] = newName
            if gf:getTextLength(newName) ~= 0 then                
                self:setCtrlVisible("DelButton", true, panelName)
            else                
                self:setCtrlVisible("DelButton", false, panelName)
            end  

        end
    end, isTop)
    self[key]:setLocalZOrder(1)
    self[key]:setPlaceholderFont(CHS[3003794], 19)
    self[key]:setPlaceHolder(defStr)
    self[key]:setPlaceholderFontColor(COLOR3.GRAY)
    self[key]:setFont(CHS[3003597], 19)
    self[key]:setFontColor(cc.c3b(76, 32, 0))  
end

function GatherPrivilegeDlg:createEditBox(name, root, returnType,func, top)
    local function editBoxListner(envent, sender)
        if func ~= nil then
            func(self, envent, sender)
        end
    end

    local backSprite = cc.Scale9Sprite:createWithSpriteFrameName('Frame0011.png')
    backSprite:setOpacity(0)
    local panel = self:getControl(name, nil , root)
    local editBox = cc.EditBox:create(panel:getContentSize(), backSprite)
    editBox:registerScriptEditBoxHandler(editBoxListner)
    editBox:setReturnType(returnType or cc.KEYBOARD_RETURNTYPE_DEFAULT)
    editBox:setAnchorPoint(0, 0.5)
    
    if top then
        editBox:setPosition(0, panel:getContentSize().height / 2 + 19 * 0.5 + 4)
    else
        editBox:setPosition(0, panel:getContentSize().height / 2)
    end
    editBox:setName("EditBox")
    panel:addChild(editBox)

    return editBox
end

function GatherPrivilegeDlg:onShowNoticeButton()
    self:setCtrlVisible("NoticeShowPanel", true)
    self:setCtrlVisible("InfoPanel", false)
end

function GatherPrivilegeDlg:onCloseButton2(sender, eventType)
    self:setCtrlVisible("NoticeShowPanel", false)
    self:setCtrlVisible("InfoPanel", true)
end

function GatherPrivilegeDlg:onNoticeShowPanel(sender, eventType)
    self:setCtrlVisible("NoticeShowPanel", false)
    self:setCtrlVisible("InfoPanel", true)
    
    self:setCheck("CheckBox", true)
end

function GatherPrivilegeDlg:onDelButton(sender, eventType)
    local panel = sender:getParent()
    local inputPanel = panel:getChildByName("InputPanel")
    local ctrl = inputPanel:getChildByName("EditBox")
    if ctrl then ctrl:setText("") end
    
    local ctrl = self:getControl("NumLabel", nil, panel)
    if ctrl then
        self:setLabelText("NumLabel", PANEL_MAP[panel:getName()], panel, COLOR3.GRAY)
    end    
    
    if panel:getName() == "AddressPanel" then    
        self:setCtrlVisible("DefaultLabel", true, panel)
    end
    
    self[panel:getName() .. "value"] = ""
    sender:setVisible(false) 
end

function GatherPrivilegeDlg:onConfirmButton(sender, eventType)
    local tips = ""
    for _, key in pairs(PANEL_ORDER_HAVETO) do
        if self[key .. "value"] == "" then
            if tips == "" then
                tips = PANEL_TITLE[key]
            else
                tips = tips .. "、" .. PANEL_TITLE[key]
            end
        end
    end
    
    -- xx未填写判断          
    if tips ~= "" then
        gf:ShowSmallTips(tips .. CHS[4300307])    -- XX 未填写，请补充完整后再提交认证申请。
        return
    end
    
    if not gf:chechCard(self["IDPanel" .. "value"]) then
        return
    end    
    
    if string.len(self["PhonePanel" .. "value"]) ~= 11 then
        gf:ShowSmallTips(CHS[4300330])
        return
    end 
    
    if tonumber(string.sub(self["PhonePanel" .. "value"], 1, 1)) ~= 1 then
        gf:ShowSmallTips(CHS[4300330])
        return
    end
    
    -- 提交截止时间由服务器判断 WDSY-27247
    

    -- 没有同意
    if not self:isCheck("CheckBox") then
        gf:ShowSmallTips(CHS[4300308])  -- "请先阅读并同意#R雷霆游戏特权服务公约#n。",
        return
    end
    
    local birthday
    local year = tonumber(self:getLabelText("YearLabel"))
    local month = tonumber(self:getLabelText("MonthLabel"))
    local day = tonumber(self:getLabelText("DayLabel"))
    if year and month and day then
        birthday = string.format("%d%02d%02d", year, month, day)

    end
    
    
    -- 确认框  -- "请确认所有信息填写正确后再提交，继续提交吗？",
    gf:confirm(CHS[4300309], function ()
        local data = {}
        data.mail_id = self.id
        data.mail_oper = 1
        data.name = self["NamePanel" .. "value"] or ""
        data.idcard = self["IDPanel" .. "value"] or ""
        data.phone = self["PhonePanel" .. "value"] or ""
        data.wechat = self["WeChatPanel" .. "value"] or ""
        data.address = self["AddressPanel" .. "value"] or ""
        data.birth = birthday or ""
        gf:CmdToServer("CMD_MAILBOX_GATHER_PRIVILEGE", data)
    end)
    
end

function GatherPrivilegeDlg:setMailInfo(info)
    local id = info.id
    local ts = info.date
    local data = os.time{year = string.sub(ts, 1, 4), month = string.sub(ts, 5, 6), day = string.sub(ts, 7, 8), hour = string.sub(ts, 9, 10), min = string.sub(ts, 11, 12), sec = string.sub(ts, 13, 14)}
    local mailType = tonumber(info.type)
    self.id = id
    self.endTime = data
    self.mailType = mailType
    local timeStr = gf:getServerDate("%Y-%m-%d %H:%M:%S", data)
    self:setLabelText("NoteLabel", gf:getServerDate(CHS[5420175], self.endTime))
end

return GatherPrivilegeDlg
