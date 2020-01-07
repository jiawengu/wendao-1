-- JuBaoUserViewGuardDlg.lua
-- Created by songcw Dec/23/2016
-- 聚宝斋守护信息界面

local JuBaoUserViewGuardDlg = Singleton("JuBaoUserViewGuardDlg", Dialog)
local DataObject = require("core/DataObject")

function JuBaoUserViewGuardDlg:init()
    self:bindListener("BuyButton", self.onBuyButton)
    self:bindListener("BuyButton", self.onBuyButton, "DesignatedSellPanel")
    self:bindListener("NoteButton", self.onNoteButton, "DesignatedSellPanel")
    
    -- 初始化克隆
    self:initRetainPanels()
    
    -- 获取gid
    self.goods_gid = DlgMgr:sendMsg("JuBaoUserViewTabDlg", "getGid")
    
    -- 从管理器中取数据设置
    self:setDataFormMgr()  
    
    -- 价格信息
    TradingMgr:setPriceInfo(self)
    
    self:hookMsg("MSG_TRADING_SNAPSHOT")
end

-- 初始化克隆
function JuBaoUserViewGuardDlg:initRetainPanels()
    -- 克隆
    self.oneRowPanel = self:toCloneCtrl("OneRowPanel")

    self.chosenImage = self:toCloneCtrl("ChosenImage", self.oneRowPanel)
end

-- 清理资源
function JuBaoUserViewGuardDlg:cleanup()
    self:releaseCloneCtrl("oneRowPanel")
    self:releaseCloneCtrl("chosenImage")
end

-- 设置数据
function JuBaoUserViewGuardDlg:setDataFormMgr()
    -- 设置数据
    if not self.goods_gid then return end

    local guardData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_GUARD)        
    if guardData then
        local retGuard = {}
        for i, petData in pairs(guardData) do
            local objcet = DataObject.new()
            objcet:absorbBasicFields(petData)
            table.insert(retGuard, objcet)                
        end
        self:setGuardsList(retGuard)
    else
        TradingMgr:tradingSnapshot(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_GUARD)
    end
end

-- 设置守护列表
function JuBaoUserViewGuardDlg:setGuardsList(guards)
    local listView = self:resetListView("GuardListView")
    if not next(guards) then return end
    
    local count = #guards
    local rowCount = math.ceil(count / 2)
    for i = 1, rowCount do
        local parentPanel = self.oneRowPanel:clone()
        local leftPanel = self:getControl("GuardInfoPanel_1", nil, parentPanel)
        self:setUnitGuardCell(guards[i * 2 - 1], leftPanel)
        local rightPanel = self:getControl("GuardInfoPanel_2", nil, parentPanel)
        self:setUnitGuardCell(guards[i * 2], rightPanel)
        listView:pushBackCustomItem(parentPanel)           
    end
    
    -- 默认选择第一个
    local item = listView:getItem(0)
    if item then
        local leftPanel = self:getControl("GuardInfoPanel_1", nil, item)
        self:onSelectGuard(leftPanel)
    end
end

-- 设置单个宠物列表
function JuBaoUserViewGuardDlg:setUnitGuardCell(guard, panel)
    if not guard then 
        panel:setVisible(false)
        return
    end

    -- 头像
    self:setImage("GoodsImage", ResMgr:getSmallPortrait(guard:queryBasicInt("icon")), panel)
    self:setItemImageSize("GoodsImage", panel)

    -- 相性
    -- 设置宠物相性
    local polar = gf:getPolar(guard:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("PolarImage", polarPath, panel)

    -- 名字
    self:setLabelText("NameLabel", guard:queryBasic("name"), panel)

    -- 根据rank设置边框颜色
    local rankImg = self:getGuardColorByRank(guard:queryInt("rank"))
    local coverImgCtrl = self:getControl("QualityImage", nil, panel)
    self:setCtrlVisible("QualityImage", true, panel)
    coverImgCtrl:loadTexture(rankImg, ccui.TextureResType.plistType)
    panel.guard = guard

    -- 事件监听
    self:bindTouchEndEventListener(panel, self.onSelectGuard)
end

-- 增加点击宠物的选中光效
function JuBaoUserViewGuardDlg:addSelectPetEff(sender)
    self.chosenImage:removeFromParent()
    sender:addChild(self.chosenImage)
end

-- 点击某个宠物
function JuBaoUserViewGuardDlg:onSelectGuard(sender, eventType)
    self.guard = sender.guard
    self:addSelectPetEff(sender)

    self:setGuardInfo(self.guard)
end

-- 设置宠物
function JuBaoUserViewGuardDlg:setGuardInfo(guard)
    self:setShapeInfo(guard)
    
    self:setAttribInfo(guard)
end

function JuBaoUserViewGuardDlg:setAttribInfo(guard)
    local infoPanel = self:getControl("InfoPanel")
    -- 头像
    self:setImage("GuardImage", ResMgr:getSmallPortrait(guard:queryBasicInt("icon")), infoPanel)
    self:setItemImageSize("GuardImage", infoPanel)
    
    local polar = gf:getPolar(guard:queryBasicInt("polar"))
    local polarPath = ResMgr:getPolarImagePath(polar)
    self:setImagePlist("Image", polarPath, infoPanel)

    -- 品质边框    
    self:setImagePlist("QualityImage", self:getGuardColorByRank(guard:queryInt("rank")), infoPanel)
    
    -- 品质
    self:setLabelText("QualityLabel_3", self:getGuardQualityChsByRank(guard:queryInt("rank")), infoPanel)    

    -- 名字
    self:setLabelText("NameLabel", guard:queryBasic("name"), infoPanel)
    
    -- 亲密
    self:setLabelText("IntimacyLabel_3", guard:queryInt("intimacy"), infoPanel)
    
    -- 培养
    local growInfo = guard:queryBasic("grow_attrib")
    if growInfo and growInfo.degree_32 ~= 0 then
        local degree = growInfo.degree_32 / 1000000
        self:setLabelText("DevelopLabel_3", string.format(CHS[3002761], growInfo.rebuild_level, degree), infoPanel)
    else
        self:setLabelText("DevelopLabel_3", growInfo.rebuild_level .. CHS[3002791], infoPanel)
    end
    
    -- 气血
    self:setLabelText("LifeLabel_3", guard:queryInt("max_life"), infoPanel)
    
    -- 物伤
    self:setLabelText("PhyPowerLabel_3", guard:queryInt("phy_power"), infoPanel)
    
    -- 法伤
    self:setLabelText("MagPowerLabel_3", guard:queryInt("mag_power"), infoPanel)
    
    -- 速度
    self:setLabelText("SpeedLabel_3", guard:queryInt("speed"), infoPanel)
    if guard:queryInt("speed") == 0 then
        -- 旧数据没有速度，所以为0时，隐藏
        self:setLabelText("SpeedLabel_1", "", infoPanel)
        self:setLabelText("SpeedLabel_2", "", infoPanel)
        self:setLabelText("SpeedLabel_3", "", infoPanel)    
    end
    
    -- 防御
    self:setLabelText("DefLabel_3", guard:queryInt("def"), infoPanel)
end

-- 形象
function JuBaoUserViewGuardDlg:setShapeInfo(guard)
    local shapePanel = self:getControl("ShapePanel")

    -- 名称
    self:setLabelText("NameLabel_1", guard:queryBasic("name"), shapePanel)
    self:setLabelText("NameLabel_2", guard:queryBasic("name"), shapePanel)    

    -- 形象
    self:setPortrait("UserPanel", guard:queryInt("icon"), 0, nil, true, nil, nil, cc.p(0, -60))

    -- 品质
    self:setImage("QualityImage", self:getGuardQualityByRank(guard:queryInt("rank")), shapePanel)

    -- 等级
    self:setLabelText("LevelLabel", guard:queryInt("level") .. CHS[3002760], shapePanel)  

    local polarPath = ResMgr:getPolarImagePath(guard:queryInt("polar"))
    self:setImagePlist("PolarImage", polarPath, shapePanel)
end

-- 根据等级获取守护的颜色
function JuBaoUserViewGuardDlg:getGuardColorByRank(rank)
    if rank == GUARD_RANK.TONGZI then
        return ResMgr.ui.guard_rank1
    elseif rank == GUARD_RANK.ZHANGLAO then
        return ResMgr.ui.guard_rank2
    elseif rank == GUARD_RANK.SHENLING then
        return ResMgr.ui.guard_rank3
    end

    return nil
end

-- 根据等级获取守护的品质
function JuBaoUserViewGuardDlg:getGuardQualityByRank(rank)
    if rank == GUARD_RANK.TONGZI then
        return ResMgr.ui.guard_attr_rank1
    elseif rank == GUARD_RANK.ZHANGLAO then
        return ResMgr.ui.guard_attr_rank2
    elseif rank == GUARD_RANK.SHENLING then
        return ResMgr.ui.guard_attr_rank3
    end

    return nil
end

-- 根据等级获取守护的品质
function JuBaoUserViewGuardDlg:getGuardQualityChsByRank(rank)
    if rank == GUARD_RANK.TONGZI then
        return CHS[4100946]
    elseif rank == GUARD_RANK.ZHANGLAO then
        return CHS[4100947]
    elseif rank == GUARD_RANK.SHENLING then
        return CHS[4100948]
    end

    return nil
end

function JuBaoUserViewGuardDlg:onNoteButton(sender, eventType)    
    gf:showTipInfo(CHS[4100945], sender)
end

-- 点击购买
function JuBaoUserViewGuardDlg:onBuyButton(sender, eventType)
    if not self.goods_gid then return end
    TradingMgr:tryBuyItem(self.goods_gid, self.name)
end

function JuBaoUserViewGuardDlg:onCloseButton(sender, eventType)
    TradingMgr:cleanAutoLoginInfo()
    DlgMgr:closeDlg(self.name)
end

-- 收到数据
function JuBaoUserViewGuardDlg:MSG_TRADING_SNAPSHOT(data)
    if data.snapshot_type == TRAD_SNAPSHOT.SNAPSHOT_GUARD and data.goods_gid == self.goods_gid and self.goods_gid then
        local guardData = TradingMgr:getTradGoodsData(self.goods_gid, TRAD_SNAPSHOT.SNAPSHOT_GUARD)        
        if guardData then
            local retGuard = {}
            for i, petData in pairs(guardData) do
                local objcet = DataObject.new()
                objcet:absorbBasicFields(petData)
                table.insert(retGuard, objcet)                
            end
            self:setGuardsList(retGuard)
        end
    end
end

return JuBaoUserViewGuardDlg
