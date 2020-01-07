-- ChoseDressDlg.lua
-- Created by huangzz May/20/2019
-- 时装选择界面

local ChoseDressDlg = Singleton("ChoseDressDlg", Dialog)

-- local FASHIONS = {
--     {name = CHS[4100670], icon = 21001,},  -- 千秋梦
--     {name = CHS[4100671], icon = 21002,},  -- 汉宫秋
--     {name = CHS[4100669], icon = 21003,},  -- 龙吟水
--     {name = CHS[4100672], icon = 21004,},  -- 凤鸣空
--     {name = CHS[7120024], icon = 51526,},  -- 峥岚衣
--     {name = CHS[7120025], icon = 51525,},  -- 水光衫
--     {name = CHS[5410226], icon = 21007,},  -- 狐灵逸
--     {name = CHS[5410227], icon = 21008,},  -- 狐灵娇
--     {name = CHS[5430028], icon = 21005,},  -- 晓色红妆
--     {name = CHS[5430029], icon = 21006,},  -- 云暮风华
--     {name = CHS[5410264], icon = 21013,},  -- 日耀辰辉
--     {name = CHS[5410265], icon = 21014,},  -- 星垂月涌
--     {name = CHS[5410266], icon = 21015,},  -- 星火昭
--     {name = CHS[5410267], icon = 21016,},  -- 点红烛
--     {name = CHS[5400332], icon = 21009,},  -- 如意年
--     {name = CHS[5400333], icon = 21010,},  -- 吉祥天
--     {name = CHS[5430030], icon = 21017,},  -- 剑魄琴心
--     {name = CHS[5430031], icon = 21018,},  -- 引天长歌
--     {name = CHS[5430032], icon = 21019,},  -- 踏雪寻梅
--     {name = CHS[5430033], icon = 21020,},  -- 紫岚故梦
-- }

function ChoseDressDlg:init()
    self:bindListener("UseButton", self.onUseButton)
    self:bindListener("TurnRightButton", self.onTurnRightButton)
    self:bindListener("TurnLeftButton", self.onTurnLeftButton)
    self:bindListener("DressPanel", self.onCheckBox)

    self.dressPanel = self:retainCtrl("DressPanel")

    self.listView = self:getControl("ListView")

    self:setCheck("ChoseCheckBox", false, self.dressPanel)
end

function ChoseDressDlg:setData(data)
    table.sort(data, function(l, r)
        return l.index < r.index
    end)

    self:initList(data)

    self.msgType = data.type
end

-- 刷新列表
function ChoseDressDlg:initList(data)
    self.lastSelectCell = nil
    self.listView:removeAllItems()
    for i = 1, #data do
        local cell = self.dressPanel:clone()
        self:setItemInfo(data[i], cell)
        self.listView:pushBackCustomItem(cell)
    end

    self:refreshPortrait(true)

    self:setLabelText("ItemLabel", "", "ShapePanel")
end

function ChoseDressDlg:setItemInfo(data, cell)
    self:setImage("ItemImage", ResMgr:getIconPathByName(data.name), cell)

    self:setLabelText("ItemLabel", data.name .. CHS[5410268], cell)

    local goldText = gf:getArtFontMoneyDesc(data.price)
    self:setNumImgForPanel("PricePanel", ART_FONT_COLOR.DEFAULT, goldText, false, LOCATE_POSITION.LEFT_TOP, 17, cell)
    cell.data = data
end

function ChoseDressDlg:onCheckBox(sender, eventType)
    local isCheck = self:isCheck("ChoseCheckBox", sender)
    if self.lastSelectCell then
        self:setCheck("ChoseCheckBox", false, self.lastSelectCell)
    end

    if isCheck then
        self.lastSelectCell = nil

        self:refreshPortrait(true)

        self:setLabelText("ItemLabel", "", "ShapePanel")
    else
        self.lastSelectCell = sender
    
        self:setCheck("ChoseCheckBox", true, sender)
    
        self:refreshPortrait(true)
    
        self:setLabelText("ItemLabel", sender.data.name .. CHS[5410268], "ShapePanel")
    end
end

function ChoseDressDlg:refreshPortrait(resetDir)
    local icon, gender, partIndex, partColorIndex
    gender = Me:queryBasicInt("gender")
    if not self.lastSelectCell then
        icon = gf:getIconByGenderAndPolar(gender, Me:queryBasicInt("polar"))
    else
        icon = self.lastSelectCell.data.icon
        partIndex = nil
        partColorIndex = nil
    end

    if resetDir then self.dir = 5 end

    local panel = self:getControl("PlanPanel", nil, "PlanShapePanel")
    local argList = {
        panelName = "UserPanel",
        icon = icon,
        weapon = 0,
        root = panel,
        action = nil,
        clickCb = nil,
        offPos = nil,
        orgIcon = gf:getIconByGenderAndPolar(gender, Me:queryBasicInt("polar")),
        syncLoad = nil,
        dir = self.dir,
        pTag = nil,
        extend = nil,
        partIndex = Me:getDlgPartIndex(true),
        partColorIndex = Me:getDlgPartColorIndex(true),
    }

    self:setPortraitByArgList(argList)

    self.icon = icon

    self:displayPlayActions("UserPanel", panel, -36)
end
 
function ChoseDressDlg:onUseButton(sender, eventType)
    if not self.lastSelectCell then
        gf:ShowSmallTips(CHS[5430028])
        return
    end

    -- 处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

        -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    gf:CmdToServer("CMD_CHOOSE_FASION", {type = self.msgType, index = self.lastSelectCell.data.index})
end

function ChoseDressDlg:onTurnRightButton(sender, eventType)
    self.dir = self.dir - 2
    if self.dir < 0 then
        self.dir = 7
    end

    self:refreshPortrait()
end

function ChoseDressDlg:onTurnLeftButton(sender, eventType)
    self.dir = self.dir + 2
    if self.dir > 7 then
        self.dir = 1
    end

    self:refreshPortrait()
end

return ChoseDressDlg
