-- QiShaDlg.lua
-- Created by songcw Dec/2017/13
-- 七杀界面

local QiShaDlg = Singleton("QiShaDlg", Dialog)


local ITEM_MAP = {
 --   "黑熊血精", "魔猪血精", "鬼猿血精", "蝎后血精"
    CHS[4100951], CHS[4100952], CHS[4100953], CHS[4100954], 
}

-- 已经放入的物品
QiShaDlg.readyItems = {}

function QiShaDlg:init()
    self:bindListener("StartButton", self.onStartButton)
    self:setCtrlEnabled("StartButton", false)
    for i = 1, 4 do
        local panel = self:getControl("Panel_" .. i)
        panel:setTag(i)
        self:bindTouchEndEventListener(panel, self.onChoseCheckBox)
        self:bindListener("ChosePanel_2_1", self.onShowButton, panel)        
    end
    
    for i = 1, 3 do
        local panel = self:getControl("ChosePanel_" .. i)
        self:setLabelText("Label_324", CHS[4100956], panel)
    end

    self.readyItems = {[1] = "", [2] = "", [3] = ""}
    
    self:initUI()
end

function QiShaDlg:onShowButton(sender, eventType)
    local tag = sender:getParent():getTag()
    local rect = self:getBoundingBoxInWorldSpace(sender)
    InventoryMgr:showBasicMessageDlg(ITEM_MAP[tag], rect)
end

function QiShaDlg:initUI()
    -- 左侧
    for i = 1, 4 do
        local panel = self:getControl("Panel_" .. i)
        self:setImage("GuardImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(ITEM_MAP[i])), panel)
        self:setCtrlVisible("GuardImage", true, panel)

        self:setLabelText("NameLabel", ITEM_MAP[i], panel)

        local amount = InventoryMgr:getAmountByName(ITEM_MAP[i])
        local color = (amount > 0) and COLOR3.TEXT_DEFAULT or COLOR3.RED 
        self:setLabelText("NumLabel_2", amount, panel, color)
        
        self:setCtrlEnabled("ChoseCheckBox", amount > 0, panel)
        
        if amount <= 0 then
            local bkImage = self:getControl("BackImage", nil, panel)
            gf:grayImageView(bkImage)
            
            local itemImage = self:getControl("GuardImage", nil, panel)
            gf:grayImageView(itemImage)          
        end
        
        -- 再次设置 ChoseCheckBox 不可用，是因为策划希望点击panel响应事件
        self:setCtrlOnlyEnabled("ChoseCheckBox", false, panel)
        self:setCheck("ChoseCheckBox", false, panel)
    end
end

function QiShaDlg:updateSelectItems()
    local isLight = true
    for i = 1, 3 do
        local panel = self:getControl("ChosePanel_" .. i)
        --self:setCtrlVisible("GuardImage", self.readyItems[i] ~= "", panel)
        if self.readyItems[i] ~= "" then
            self:setImage("GuardImage", ResMgr:getItemIconPath(InventoryMgr:getIconByName(self.readyItems[i])), panel)
            self:setLabelText("Label_324", self.readyItems[i], panel)
        else
            isLight = false
            self:setLabelText("Label_324", CHS[4100956], panel)
            self:setImage("GuardImage", ResMgr.ui.xuejing_jianying, panel)
        end
    end

    self:setCtrlEnabled("StartButton", isLight)
end

function QiShaDlg:removeItem(itemName)
    for i = 1, 3 do            
        if self.readyItems[i] == itemName then
            self.readyItems[i] = ""
            return true
        end
    end

    return false
end

function QiShaDlg:addItem(itemName)
    -- 个数不够    
    local amount = InventoryMgr:getAmountByName(itemName)
    if amount <= 0 then
        gf:ShowSmallTips(string.format(CHS[4100957], itemName))
        return
    end    

    local isAdd = false
    for i = 1, 3 do            
        if self.readyItems[i] == "" and not isAdd then
            self.readyItems[i] = itemName
            isAdd = true
        end
    end

    if not isAdd then             
        gf:ShowSmallTips(CHS[4100958])
        return 
    end

    return true
end

function QiShaDlg:onChoseCheckBox(sender, eventType)
    local selectName = ITEM_MAP[sender:getTag()]
    if self:isCheck("ChoseCheckBox", sender) then
        -- 删除
        self:removeItem(selectName)
        
        self:setCheck("ChoseCheckBox", false, sender)
    else
        -- 增加
        if self:addItem(selectName) then
            self:setCheck("ChoseCheckBox", true, sender)
        end
    end
    
    self:updateSelectItems()
end

function QiShaDlg:onTodo()

    if TaskMgr:isExistTaskByName(CHS[4100959]) then
        gf:ShowSmallTips(CHS[4100960])
        return
    end

    -- 安全锁判断
    if self:checkSafeLockRelease("onTodo") then
        return
    end

    local items_pos = ""
    for i = 1, 3 do            
        if self.readyItems[i] ~= ""  then
            local item = InventoryMgr:getItemByName(self.readyItems[i])
            if not item[1] then
                gf:ShowSmallTips(string.format(CHS[4100961], self.readyItems[i]))
                return
            else
                if items_pos == "" then
                    items_pos = items_pos .. item[1].pos
                else
                    items_pos = items_pos .. "|" .. item[1].pos
                end
            end
        else
            -- 异常情况，不管
            return 
        end
    end

    gf:CmdToServer("CMD_SUBMIT_XUEJING_ITEM", {items_pos = items_pos})
    self:onCloseButton()
end

function QiShaDlg:onStartButton(sender, eventType)
    gf:confirm(CHS[4100962], function()
        self:onTodo()
    end)
end

return QiShaDlg
