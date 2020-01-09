-- InnElevateDlg.lua
-- Created by lixh Api/20/2018
-- 客栈提升界面

local InnElevateDlg = Singleton("InnElevateDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local TYPE_CHECKBOS = {
    "WaitCheckBox",
    "DinnerCheckBox",
    "RoomCheckBox",
}

local DISPLAY_PANEL = {
    DinnerCheckBox    = "DinnerPanel",
    RoomCheckBox      = "RoomPanel",
    WaitCheckBox      = "WaitPanel",
}

-- 客栈家具类型
local INN_FURNITURE_TYPE = InnMgr:getInnFurnitureType()

-- 桌子,房门,椅子配置
local TABLE_CFG = InnMgr:getInnTabelCfg()
local ROOM_CFG = InnMgr:getInnRoomCfg()
local DESK_IMAGE_PATH = InnMgr:getInnDeskImagePath()

-- 候客区椅子颜色
local WAIT_GUEST_COLOR_CFG = {OPEN = cc.c3b(255, 255, 255), CLOSE = {cc.c3b(204, 204, 204)}}

-- 客栈乞丐类型
local INN_BEGGAR_TYPE = InnMgr:getInnBeggarType()

-- 家具升级特效标记
local FUR_UP_MAGIC_TAG = 999

function InnElevateDlg:init()
    self:bindListener("InfoButton", self.onDinnerInfoButton, "DinnerPanel")
    self:bindFloatPanelListener("DinnerRulePanel")
    self:bindListener("InfoButton", self.onRoomInfoButton, "RoomPanel")
    self:bindFloatPanelListener("RoomRulePanel")
    self:bindListener("InfoButton", self.onWaitInfoButton, "WaitPanel")
    self:bindFloatPanelListener("WaitRulePanel")

    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("UpdateButton", self.onUpdateButton)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, TYPE_CHECKBOS, self.onCheckBox)
    self.radioGroup:selectRadio(1)

    self:setDlgInfo()

    InnMgr:hideOrShowInnMainDlg(false)
end

-- 设置桌子，门，候客区3个小界面内容
function InnElevateDlg:setDlgInfo()
    self:refreshBasicInfo()
    self:setFurnitureInfo()
    self:setWaitGuestInfo()
end

-- 设置桌子,房门信息
function InnElevateDlg:setFurnitureInfo()
    self.baseData = InnMgr:getBaseData()
    if not self.baseData then return end

    local tabelInfo = self.baseData.tableInfo
    local roomInfo = self.baseData.roomInfo
    for i = 1, 6 do
        local tablePanel = self:getControl("ItemPanel" .. i, nil, "DinnerPanel")
        tablePanel.id = i
        tablePanel:setVisible(true)
        if tabelInfo and tabelInfo[i] then
            self:setSingleItemInfo(INN_FURNITURE_TYPE.TABLE, tablePanel, tabelInfo[i].level)
        else
            -- 未拥有
            if i == self.baseData.tableCount + 1 then
                self:setSingleItemInfo(INN_FURNITURE_TYPE.TABLE, tablePanel, 0, true)
            else
                tablePanel:setVisible(false)
            end
        end

        local roomPanel = self:getControl("ItemPanel" .. i, nil, "RoomPanel")
        roomPanel.id = i
        roomPanel:setVisible(true)
        if roomInfo and roomInfo[i] then
            self:setSingleItemInfo(INN_FURNITURE_TYPE.ROOM, roomPanel, roomInfo[i].level)
        else
            -- 未拥有
            if i == self.baseData.roomCount + 1 then
                self:setSingleItemInfo(INN_FURNITURE_TYPE.ROOM, roomPanel, 0, true)
            else
                roomPanel:setVisible(false)
            end
        end
    end
end

-- 设置单个桌子，房门信息
function InnElevateDlg:setSingleItemInfo(type, panel, level, showBuyButton)
    local cfg = type == INN_FURNITURE_TYPE.TABLE and TABLE_CFG[level] or ROOM_CFG[level]
    if not cfg then return end

    local tabelName = cfg.name
    self:setLabelText("NameLabel1", tabelName, panel)
    self:setLabelText("NameLabel2", tabelName, panel)
    
    local imagePath = cfg.imagePath
    local image = self:getControl("IconImage", Const.UIImage, panel)
    image:loadTexture(imagePath)
    image:setOpacity(255)

    -- 等级
    self:setLabelText("LevelLabel", "Lv." .. level, panel)
    self:setCtrlVisible("LevelLabel", true, panel)

    self:setCtrlVisible("MoneyPanel", true, panel)
    self:setCtrlVisible("BestImage", false, panel)
    self:setCtrlVisible("UpdateButton", false, panel)

    if level == 0 then
        -- 未拥有
        image:setOpacity(180)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.DEFAULT, cfg.buyPrice, false, LOCATE_POSITION.CENTER, 19, panel)

        self:setCtrlVisible("LevelLabel", false, panel)
    elseif level == 5 then
        -- 满级
        self:setCtrlVisible("MoneyPanel", false, panel)
        self:setCtrlVisible("BestImage", true, panel)
    else
        -- 可升级
        self:setCtrlVisible("UpdateButton", true, panel)
        self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.DEFAULT, cfg.upPrice, false, LOCATE_POSITION.CENTER, 19, panel)
        local updateButton = self:getControl("UpdateButton", nil, panel)
        self:setLabelText("Label_1", string.format(CHS[7150073], cfg.upAddDeluxe), updateButton)
        self:setLabelText("Label_2", string.format(CHS[7150073], cfg.upAddDeluxe), updateButton)
    end

    -- 购买按钮
    if showBuyButton then
        self:setCtrlVisible("BuyButton", true, panel)
    else
        self:setCtrlVisible("BuyButton", false, panel)
    end

    -- 升级与购买走相同逻辑
    if type == INN_FURNITURE_TYPE.TABLE then
        self:bindListener("BuyButton", self.onBuyTableButton, panel)
        self:bindListener("UpdateButton", self.onUpgradeTableButton, panel)
    else
        self:bindListener("BuyButton", self.onBuyRoomButton, panel)
        self:bindListener("UpdateButton", self.onUpgradeRoomButton, panel)
    end
end

-- 检车家具数据变化是否需要播放特效
function InnElevateDlg:checkMagic(orgData, newData)
    if not orgData or not newData then return end

    local orgTableInfo = orgData.tableInfo
    local newTableInfo = newData.tableInfo
    if not orgTableInfo or not newTableInfo then return end
    for i = 1, 6 do
        if not orgTableInfo[i] and newTableInfo[i] then
            -- 新购买桌子
            self:playUpgradeMagic(INN_FURNITURE_TYPE.TABLE, i, false)
        elseif orgTableInfo[i] and newTableInfo[i] and orgTableInfo[i].level < newTableInfo[i].level then
            -- 桌子升级
            self:playUpgradeMagic(INN_FURNITURE_TYPE.TABLE, i, true)
        end
    end

    local orgRoomInfo = orgData.roomInfo
    local newRoomInfo = newData.roomInfo
    for i = 1, 6 do
        if not orgRoomInfo[i] and newRoomInfo[i] then
            -- 新购买房间
            self:playUpgradeMagic(INN_FURNITURE_TYPE.ROOM, i, false)
        elseif orgRoomInfo[i] and newRoomInfo[i] and orgRoomInfo[i].level < newRoomInfo[i].level then
            -- 房间升级
            self:playUpgradeMagic(INN_FURNITURE_TYPE.ROOM, i, true)

            -- 延迟0.1秒保证房间数据刷新完，刷新地图客人头顶气泡
            performWithDelay(self.root, function()
                InnMgr:refreshRoomGuestBubber(i)
            end, 0.1)
        end
    end
end

-- 播放家具升级，购买特效
function InnElevateDlg:playUpgradeMagic(type, index, isLevelUp)
    local panel
    if type == INN_FURNITURE_TYPE.TABLE then
        panel = self:getControl("ItemPanel" .. index, nil, "DinnerPanel")
    else
        panel = self:getControl("ItemPanel" .. index, nil, "RoomPanel")
    end

    local action = "Bottom02"
    if isLevelUp then action = "Bottom01" end
    local sz = panel:getContentSize()
    local magic = panel:getChildByTag(FUR_UP_MAGIC_TAG)
    if magic then
        magic:removeFromParent()
        magic = nil
    end

    gf:createArmatureMagic({name = ResMgr.ArmatureMagic.inn_fur_update.name, action = action},
        panel, FUR_UP_MAGIC_TAG, -sz.width / 4, 0)
end

-- 设置候客区升级特效
function InnElevateDlg:setWaitUpMagic(orgData, newData)
    if not orgData or not newData then return end
    if orgData.guestCountMax and newData.guestCountMax and orgData.guestCountMax / 5 <  newData.guestCountMax / 5 then
        -- 候客区升级
        local ctrl = self:getControl("NumLabel", nil, "WaitPanel")
        gf:createArmatureOnceMagic(ResMgr.ArmatureMagic.inn_wait_around.name,
            ResMgr.ArmatureMagic.inn_wait_around.action, ctrl)
    end
end

-- 刷新候客区信息
function InnElevateDlg:setWaitGuestInfo()
    self.waitData = InnMgr:getWaitData()
    if not self.waitData then return end

    self:setLabelText("NumLabel", string.format(CHS[7190203], self.waitData.guestCountMax), "WaitPanel")

    local openIndex = self.waitData.guestCountMax / 5
    for i = 1, 8 do
        local panel = self:getControl("ItemPanel" .. i, nil, "WaitPanel")
        panel:setVisible(false)
        if i <= openIndex + 1 then
            -- 最多显示已开启的，+1 个panel
            panel:setVisible(true)
            self:setCtrlVisible("TitlePanel", true, panel)
            self:setCtrlVisible("BuyButton", false, panel)
            self:setCtrlVisible("BKColorPanel", true, panel)
            local parentPanel = self:getControl("IconPanel", nil, panel)

            for j = 1, 5 do
                self:setImage("IconImage" .. j, DESK_IMAGE_PATH, parentPanel)
                local image = self:getControl("IconImage" .. j, nil, parentPanel)
                if i <= openIndex then
                    image:setOpacity(255)
                else
                    image:setOpacity(102)
                end
            end

            if i <= openIndex then
                -- 已开启
                self:setCtrlVisible("TitlePanel", false, panel)
                self:setCtrlVisible("BKColorPanel", false, panel)
            elseif i == openIndex + 1 then
                -- 可购买
                self:setCtrlVisible("BuyButton", true, panel)
                self:setNumImgForPanel("CurValuePanel", ART_FONT_COLOR.DEFAULT,
                    InnMgr:getInnUpgradeCost(), false, LOCATE_POSITION.CENTER, 19, panel)
                self:bindListener("BuyButton", self.onBuyDeskButton, panel)
            end
        end
    end 
end

-- 刷新基本信息
function InnElevateDlg:refreshBasicInfo()
    self.baseData = InnMgr:getBaseData()
    if not self.baseData then return end

    self:refreshCoinNum(self.baseData.tongCoin)
    self:refreshDeluxe(self.baseData.deluxe)
    self:refreshUnitTongCoin(self.baseData.unitTongCoin)
    self:refreshLevelAndExp(self.baseData.level, self.baseData.exp, self.baseData.expToNext)
    self:refreshGuestSpeed()
end

-- 刷新候客速度信息
function InnElevateDlg:refreshGuestSpeed(minute, second, color)
    local root = self:getControl("UnitTimePanel", nil, "ResourceInfoPanel")
    if not self.waitData then
        self.waitData = InnMgr:getWaitData()
    end

    if not minute or not second or not color then
        color = COLOR3.WHITE
        local beggerEventType = InnMgr:getInnBeggarEventType()
        if beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_BE then
            -- 乞丐报恩
            color = COLOR3.GREEN
        elseif beggerEventType == INN_BEGGAR_TYPE.INN_BEGGAR_NS then
            -- 乞丐闹事
            color = COLOR3.RED
        end

        minute = math.floor(self.waitData.waitTime / 60)
        second = math.floor(self.waitData.waitTime % 60)
    end

    self:setLabelText("NumLabel", string.format(CHS[7190188], minute, second), root, color)
end

-- 刷新喜来通宝数量
function InnElevateDlg:refreshCoinNum(tongCoin)
    local str = gf:getArtFontMoneyDesc(tongCoin or 0)
    local root = self:getControl("MoneyPanel", nil, "ResourceInfoPanel")
    self:setLabelText("NumLabel", str, root)
end

-- 刷新客栈豪华度
function InnElevateDlg:refreshDeluxe(deluxe)
    local str = gf:getArtFontMoneyDesc(deluxe or 0)
    self:setLabelText("NumLabel", str, "DeluxePanel")
end

-- 刷新单个客人消费通宝数量
function InnElevateDlg:refreshUnitTongCoin(tCoin)
    local str = gf:getArtFontMoneyDesc(tCoin or 0)
    self:setLabelText("NumLabel", string.format(CHS[7190195], str), "UnitIncomePanel")
end

-- 刷新客栈等级与经验
function InnElevateDlg:refreshLevelAndExp(level, exp, expToNext)
    local root = self:getControl("LevelPanel", nil, "ResourceInfoPanel")
    root.level = level
    root.exp = exp
    root.expToNext = expToNext 

    if expToNext == 0 then
        -- 满级
        self:setCtrlVisible("MaxNumLabel", true, root)
        self:setCtrlVisible("NumLabel", false, root)
        self:setCtrlVisible("ProgressPanel", false, root)
        self:setLabelText("MaxNumLabel", string.format(CHS[7190184], level), root)
    else
        self:setCtrlVisible("MaxNumLabel", false, root)
        self:setCtrlVisible("NumLabel", true, root)
        self:setCtrlVisible("ProgressPanel", true, root)
        self:setLabelText("NumLabel", string.format(CHS[7190184], level), root)
        self:setProgressBar("ProgressBar", exp, expToNext, root)
    end

    -- 刷新悬浮框内容
    self:setLabelText("Label1", string.format(CHS[7190185], level), "LevelRulePanel")
    if expToNext == 0 then
        -- 满级
        self:setLabelText("Label2", CHS[7120077], "LevelRulePanel")
    else
        self:setLabelText("Label2", string.format(CHS[7190186], exp, expToNext), "LevelRulePanel")
    end
end

function InnElevateDlg:onCheckBox(sender, eventType)
    for _, panelName in pairs(DISPLAY_PANEL) do
        self:setCtrlVisible(panelName, false)
    end

    self:setCtrlVisible(DISPLAY_PANEL[sender:getName()], true)
end

function InnElevateDlg:onDinnerInfoButton(sender, eventType)
    self:setCtrlVisible("DinnerRulePanel", true, "DinnerPanel")
end

function InnElevateDlg:onRoomInfoButton(sender, eventType)
    self:setCtrlVisible("RoomRulePanel", true, "RoomPanel")
end

function InnElevateDlg:onWaitInfoButton(sender, eventType)
    self:setCtrlVisible("WaitRulePanel", true, "WaitPanel")
end

function InnElevateDlg:onBuyTableButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local parent = sender:getParent()
    if parent.id and self.baseData then
        -- 服务器要求购买id，为当前数量+1
        gf:CmdToServer("CMD_INN_UPGRADE_TABLE", {id = self.baseData.tableCount + 1})
    end
end

function InnElevateDlg:onBuyRoomButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local parent = sender:getParent()
    if parent.id then
        -- 服务器要求购买id，为当前数量+1
        gf:CmdToServer("CMD_INN_UPGRADE_ROOM", {id = self.baseData.roomCount + 1})
    end
end

function InnElevateDlg:onUpgradeTableButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local parent = sender:getParent()
    if parent.id then
        gf:CmdToServer("CMD_INN_UPGRADE_TABLE", {id = parent.id})
    end
end

function InnElevateDlg:onUpgradeRoomButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    local parent = sender:getParent()
    if parent.id then
        gf:CmdToServer("CMD_INN_UPGRADE_ROOM", {id = parent.id})
    end
end

function InnElevateDlg:onBuyDeskButton(sender, eventType)
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    gf:CmdToServer("CMD_INN_UPGRADE_WAITING")
end

function InnElevateDlg:onCloseButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    InnMgr:hideOrShowInnMainDlg(true)
end

return InnElevateDlg
