-- HomePlantDlg.lua
-- Created by huangzz Aug/11/2017
-- 种植操作界面

local HomePlantDlg = Singleton("HomePlantDlg", Dialog)

local UPLEVEL_NEED_EXP = {
    [1] = 1200,
    [2] = 3600,
    [3] = 10800,
    [4] = 32400,
    [5] = 0,
}

function HomePlantDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("BuyButton_0", self.onInfoButton)
    self:blindLongPressWithCtrl(self:getControl("ImagePanel_1"), self.onLongPressSeed, self.onSelectSeed, true)

    self.isMoveSeed = false
    self.selectTag = nil
    self.seedImage = nil

    -- 设置适配
    self:setFullScreen()

    local panel = self:getControl("ListBKImageanel")
    local infoPanel = self:getControl("InfoPanel_1")
    local psize = panel:getContentSize()
    panel:setContentSize(cc.size(self:getWinSize().width / Const.UI_SCALE - infoPanel:getContentSize().width, psize.height))

    self.seedPanel = self:retainCtrl("ImagePanel_1")
	self.selectImage = self:retainCtrl("ChoseImage", self.seedPanel)
	self.scrollView = self:getControl("ListScrollView")
    self.seedsInfo = self:getAllSeedsInfo()
    self:initScrollViewPanel(self.seedsInfo, self.seedPanel, self.initOneSeedPanel, self.scrollView, #self.seedsInfo, 7, 10, 25, 19, ccui.ScrollViewDir.horizontal)
    self:setNotSelectView()

    DlgMgr:closeDlg("HomePuttingDlg")
    DlgMgr:closeDlg("HomeFishingDlg")

    -- 先获取当前被隐藏的界面，避免关闭时被再次显示出来
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })

    self:setCtrlVisible("InfoPanel_2", false)
    self:setCtrlVisible("InfoPanel_1", true)

    self:hookMsg("MSG_STORE")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_HOUSE_FARM_DATA")

    -- 创建拖动的种子
    local image = ccui.ImageView:create()
    image:setPosition(0, 0)
    image:setVisible(false)
    image:setLocalZOrder(10)
    self.root:addChild(image)

    local function clickCropLand(sender, event)
        local pos = sender:getLocation()
        if event:getEventCode() == cc.EventCode.ENDED and self.isMoveSeed then
            -- 放开拖动的种子后判断该位置是否有农田，是则播种种子
            local croplands = HomeMgr.croplands
            for _, v in ipairs(croplands) do
                if v.isDigUp then
                    local pos = v:convertTouchToNodeSpace(sender)
                    local rect = {["height"] = 60,["width"] = 120,["x"] = 36,["y"] = 22}
                    if cc.rectContainsPoint(rect, pos) then
                        self:toPlant(v.farmIndex)
                        break
                    end
                end
            end

            self.seedImage:setVisible(false)
            self.isMoveSeed = false
            performWithDelay(self.scrollView , function()
                self.scrollView:setDirection(ccui.ScrollViewDir.horizontal)
            end, 0)
        end

        return true
    end

    gf:bindTouchListener(image, clickCropLand, cc.Handler.EVENT_TOUCH_ENDED, true)

    self.seedImage = image
end

function HomePlantDlg:getAllSeedsInfo()
    local info = HomeMgr:getAllSeedsInfo()
    for i = 1, #info do
        info[i].num = HomeMgr:getAllItemCountByName(info[i].name)
    end

    table.sort(info, function(l, r)
        if l.num > 0 and r.num <= 0 then return true end
        if l.num <= 0 and r.num > 0 then return false end
        if l.level < r.level then return true end
        if l.level > r.level then return false end
        if l.harvest_exp < r.harvest_exp then return true end
        if l.harvest_exp > r.harvest_exp then return false end

        return l.icon < r.icon
     end)

     return info
end

function HomePlantDlg:onUpdate()
    if not self.seedImage or not self.isMoveSeed then
        return
    end

    local pos = GameMgr.curTouchPos
    if pos then
        local pos = self.root:convertToNodeSpace(pos)
        self.seedImage:setPosition(pos.x, pos.y)
    end
end

-- 显示拖动的种子
function HomePlantDlg:showMoveSeed(icon)
    if not self.seedImage then
        return
    end

    self.seedImage:setVisible(true)
    self.seedImage:loadTexture(ResMgr:getItemIconPath(icon))
    local pos = GameMgr.curTouchPos
    if pos then
        self.seedImage:setPosition(pos.x / Const.UI_SCALE, pos.y / Const.UI_SCALE)
    end

    self.scrollView:setDirection(ccui.ScrollViewDir.none)
end

-- 未选择种子时的界面显示
function HomePlantDlg:setNotSelectView()
    local level = Me:getPlantLevel()
    self:setLabelText("LevelLabel", level .. CHS[7002280], "InfoPanel_1")
    if UPLEVEL_NEED_EXP[level] == 0 then
        self:setLabelText("ExpLabel", CHS[7002015], "InfoPanel_1")
    else
        self:setLabelText("ExpLabel", Me:queryInt("plant_exp") .. "/" .. UPLEVEL_NEED_EXP[level], "InfoPanel_1")
    end

    local ownCount, maxCount = HomeMgr:getCropCount()
    self:setLabelText("TimesLabel", ownCount .. "/" .. maxCount, "InfoPanel_1")
end

function HomePlantDlg:initOneSeedPanel(cell, data)
    -- 名字
    self:setLabelText("NameLabel", data.name, cell)

    -- 图片
    local imgPath = ResMgr:getItemIconPath(data.icon)
    self:setImage("FurnitureImage", imgPath, cell)

    -- 等级
    self:setLabelText("LevelLabel", data.level, cell)

    local num = HomeMgr:getAllItemCountByName(data.name)
    self:setLabelText("NumLabel", num, cell)
end

-- 刷新种子数量
function HomePlantDlg:refreshSeedNum()
    local cell
    local layout = self.scrollView:getChildByTag(#self.seedsInfo * 99)
    for tag, seed in pairs(self.seedsInfo) do
        cell = layout:getChildByTag(tag)
        if cell then
            local num = HomeMgr:getAllItemCountByName(seed.name)
            self:setLabelText("NumLabel", num, cell)
        end
    end
end

-- 种植
function HomePlantDlg:toPlant(tag)
    if not self.seedsInfo or not self.selectTag then
        gf:ShowSmallTips(CHS[5400154])
        return
    end

    local name = self.seedsInfo[self.selectTag].name
    local seed = InventoryMgr:getItemByName(name)
    if next(seed) then
        HomeMgr:requestFarmAction(1 ,tag, seed[1].pos)
    else
        local seed = StoreMgr:getFurnitureByName(name)
        if next(seed) then
            HomeMgr:requestFarmAction(1 ,tag, seed[1].pos)
        else
            gf:ShowSmallTips(CHS[5400151])
        end
    end
end

function HomePlantDlg:onSelectSeed(sender, eventType)
    local tag = sender:getTag()
    local seedInfo = self.seedsInfo[tag]
    if seedInfo and self.selectTag ~= tag then
        -- 选中种子
        self.selectTag = tag
        self:setCtrlVisible("InfoPanel_2", true)
        self:setCtrlVisible("InfoPanel_1", false)

        self.selectImage:removeFromParent()
        sender:addChild(self.selectImage)

        self:setInfoPanel(seedInfo)
    else
        -- 取消选中种子
        self.selectTag = nil
        self.selectImage:removeFromParent()
        self:setCtrlVisible("InfoPanel_2", false)
        self:setCtrlVisible("InfoPanel_1", true)
    end
end

function HomePlantDlg:onLongPressSeed(sender, eventType)
    local tag = sender:getTag()
    local seedInfo = self.seedsInfo[tag]
    if seedInfo then
        self.selectTag = tag
        self.selectImage:removeFromParent()
        sender:addChild(self.selectImage)

        self.isMoveSeed = true
        self:showMoveSeed(seedInfo.icon)

        self:setCtrlVisible("InfoPanel_2", true)
        self:setCtrlVisible("InfoPanel_1", false)
        self:setInfoPanel(seedInfo)
    end
end

function HomePlantDlg:setInfoPanel(seedInfo)
    local level = Me:getPlantLevel()
    local color = COLOR3.TEXT_DEFAULT
    if level < seedInfo.level then
        color = COLOR3.RED
    end

    self:setLabelText("TitleLabel", seedInfo.name, "InfoPanel_2")
    self:setLabelText("LevelLabel", seedInfo.level .. CHS[7002280], "InfoPanel_2", color)
    self:setLabelText("ExpLabel", seedInfo.harvest_exp, "InfoPanel_2")
    self:setLabelText("ValueLabel", seedInfo.harvest_value, "InfoPanel_2")
    self:setLabelText("HarNameLabel", seedInfo.harvest_name, "InfoPanel_2")
    self:setLabelText("TimeLabel", seedInfo.harvest_time .. CHS[3004169], "InfoPanel_2")
end

function HomePlantDlg:onBuyButton(sender, eventType)
    if not self.selectTag or not self.seedsInfo[self.selectTag] then
        return
    end

    if self.seedsInfo[self.selectTag].level > Me:getPlantLevel() then
        gf:ShowSmallTips(CHS[5400158])
        return
    end

    DlgMgr:openDlgEx("SeedBuyDlg", self.seedsInfo[self.selectTag].name)
end

function HomePlantDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("HomePlantRuleDlg")
end

-- 更新种子数量
function HomePlantDlg:MSG_STORE(data)
    self:refreshSeedNum()
end

function HomePlantDlg:MSG_INVENTORY(data)
    self:refreshSeedNum()
end

function HomePlantDlg:cleanup()
    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    self.allInvisbleDlgs = nil

    -- 关闭该界面时，同时关闭对应子界面
    DlgMgr:closeDlg("SeedBuyDlg")
    DlgMgr:closeDlg("HomePlantRuleDlg")
end

-- 更新种植经验、等级
function HomePlantDlg:MSG_UPDATE()
    self:setNotSelectView()
end

function HomePlantDlg:MSG_HOUSE_FARM_DATA()
    self:setNotSelectView()
end


return HomePlantDlg