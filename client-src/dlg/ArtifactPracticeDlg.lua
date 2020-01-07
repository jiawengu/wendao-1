-- ArtifactPracticeDlg.lua
-- Created by songcw/21/2017
-- 居所-法宝修炼

local ArtifactPracticeDlg = Singleton("ArtifactPracticeDlg", Dialog)

function ArtifactPracticeDlg:init(data)
    self:bindListener("TipsButton", self.onTipsButton)
    self:bindListener("BackButton", self.onBackButton)

    self:bindListener("AddButton", self.onArtifactAddButton, "ShowPanel")   -- 左侧界面的 放入法宝按钮
    self:bindListener("AddImage", self.onArtifactAddButton, "ShowPanel")   -- 左侧界面的 +按钮

    self:bindListener("AddButton", self.onNaijiuAddButton, "NaijiuPanel")
    self:bindListener("AddButton", self.onCleanAddButton, "CleanPanel")
    self:bindListener("AddButton", self.onLingqiAddButton, "LingqiPanel")

    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("StartButton", self.onStartButton)

    self:bindListener("ChoseButton_1", self.onPointButton)
    self:bindListener("ChoseButton_2", self.onCoinButton)
    self:bindListener("ArtifactImage", self.showArtifact, "ArtifactPanel")

    self:bindFloatPanelListener("ChosePanel", "AddButton", "LingqiPanel")

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) and data then
        self.furnitureId = data.furnitureId
        self.furnitureX, self.furnitureY = data.pX, data.pY
    end

    self.data = nil
    self.homeData = nil

    -- 设置法宝，没有法宝则初始化界面
    self:setArtifact()

    -- 不在居所时，每 10 分钟刷一次消息
    self:startSchedule(function()
        local curMap = MapMgr:getCurrentMapName()
        if not MapMgr:isInHouse(curMap)
                or HomeMgr:getHouseId() ~= Me:queryBasic("house/id")
                or not string.match(curMap, CHS[2000283]) then
            gf:CmdToServer("CMD_HOUSE_REQUEST_ARTIFACT_INFO")
        end
    end, 10 * 60)

    HomeMgr:requestData(self.name)

    self:hookMsg("MSG_HOUSE_SELECT_ARTIFACT")
    self:hookMsg("MSG_HOUSE_ARTIFACT_VALUE")
    self:hookMsg("MSG_HOUSE_DATA")
    self:hookMsg("MSG_HOUSE_FURNITURE_OPER")
end

function ArtifactPracticeDlg:showArtifact(sender)
    if not self.data then return end
    local rect = self:getBoundingBoxInWorldSpace(sender)
    local selectArtifact = self.selectArtifact
    InventoryMgr:showArtifact(self.data.item, rect, true)
end

-- 设置法宝
function ArtifactPracticeDlg:setArtifact(item)
    -- 没有法宝则初始化界面
    local showPanel = self:getControl("ShowPanel")
    if not item then                                                    -- 名称
        self:setCtrlVisible("BackButton", false, showPanel)                                         -- 取回按钮
        self:setCtrlVisible("AddButton", true, showPanel)                                           -- 放入法宝
        self:setCtrlVisible("AddImage", true, showPanel)                                            -- +号按钮
        self:setCtrlVisible("ArtifactImage", false, showPanel)                                      -- 法宝icon
        self:removeNumImgForPanel("ArtifactImage", LOCATE_POSITION.LEFT_TOP, showPanel)             -- 移除等级
        InventoryMgr:removeArtifactPolarImage(self:getControl("ArtifactImage", nil, showPanel))     -- 移除法宝相性
        self:setCtrlVisible("ExpPanel", false, showPanel)
        return
    end

    self:setCtrlVisible("ExpPanel", true, showPanel)
    -- 放入、取回按钮
    self:setCtrlVisible("BackButton", true, showPanel)
    self:setCtrlVisible("AddButton", false, showPanel) -- 添加法宝

    -- +号 or 法宝icon
    self:setCtrlVisible("AddImage", false, showPanel)
    self:setCtrlVisible("ArtifactImage", true, showPanel)

    -- 法宝icon
    self:setImage("ArtifactImage", InventoryMgr:getIconFileByName(item.name), showPanel)
    self:setItemImageSize("ArtifactImage", showPanel)

    -- 图标左上角等级
    self:setNumImgForPanel("LevelPanel", ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 21, showPanel)

    -- 图标右下角相性标志
    if item.item_polar and item.item_polar >= 1 and item.item_polar <= 5 then
        InventoryMgr:addArtifactPolarImage(self:getControl("ArtifactImage", nil, showPanel), item.item_polar)
    end
end

-- 右侧居所相关信息
function ArtifactPracticeDlg:setHomeData(data)
    -- 炼器台空间
    self:setLabelText("AttribLabel", HomeMgr:getLevelStr(data.space_num), "RoomPanel")

    -- 舒适度
    self:setLabelText("AttribLabel", string.format("%d/%d", data.home_comfort, data.max_comfort), "ComfortPanel")

    -- 清洁度
    self:setLabelText("AttribLabel", string.format("%d/%d", data.cleanliness, data.max_cleanliness), "CleanPanel")

    -- 耐久度
    self:setLabelText("AttribLabel", string.format("%d/%d", data.durability, data.max_durability), "NaijiuPanel")

    -- 灵气
    self:setLabelText("AttribLabel", string.format("%d/%d", data.nimbus, data.max_nimbus), "LingqiPanel")

    -- 效率
    local color = COLOR3.TEXT_DEFAULT
    if data.rate > 0 then
        color = COLOR3.BLUE
    end

    self:setLabelText("AttribLabel", string.format(CHS[4100677], data.daofa_em), "EffectPanel", color)

    -- 持续时间
    if data.keep_ti == 0 then
        self:setLabelText("AttribLabel", CHS[4200424], "TimePanel")
    elseif data.keep_ti < 60 then
        self:setLabelText("AttribLabel", string.format(CHS[4200423], data.keep_ti), "TimePanel")
    else
        local min = math.floor(data.keep_ti / 60)
        local s = data.keep_ti % 60
        if s == 0 then
            self:setLabelText("AttribLabel", string.format(CHS[4300223], min), "TimePanel")
        else
            self:setLabelText("AttribLabel", string.format(CHS[4100678], min, s), "TimePanel")
        end
    end

    self:setCtrlVisible("StopButton", data.cur_status == 1)
    self:setCtrlVisible("StartButton", data.cur_status == 0)

    if self.data then
        local parentPanel = self:getControl("ArtifactPanel")
        local icon = 0
        if data.name == CHS[4100675] then  -- 炼器台
            icon = ResMgr.magic.lianqi_magic
        else
            icon = ResMgr.magic.shanggu_lianqi_magic
        end

        if data.cur_status == 1 then
            local magic = parentPanel:getChildByTag(icon)
            if not magic then
                magic = gf:createLoopMagic(icon, nil, {blendMode = "add"})
                magic:setTag(icon)
                parentPanel:addChild(magic)
            end
        else
            local magic = parentPanel:getChildByTag(icon)
            if magic then magic:removeFromParent() end
        end
    end

    self.homeData = data
end

function ArtifactPracticeDlg:onTipsButton(sender, eventType)
    DlgMgr:openDlg("ArtifactPracticeRuleDlg")
end

-- 取回法宝
function ArtifactPracticeDlg:onBackButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end

    if not self.data then return end
    HomeMgr:cmdHouseUseFurniture(self.data.furniture_pos, "artifact_practice", "take_artifact", "")
end

-- 添加法宝按钮
function ArtifactPracticeDlg:onArtifactAddButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if not self.data then return end
    local artifacts = InventoryMgr:getItemByType(ITEM_TYPE.ARTIFACT)
    if #artifacts == 0 then
        gf:ShowSmallTips(CHS[4100679])
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end

    HomeMgr:cmdHouseUseFurniture(self.data.furniture_pos, "artifact_practice", "select_artifact", "")
end

function ArtifactPracticeDlg:onNaijiuAddButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if not self.data then return end
    local fur = HomeMgr:getFurnitureById(self.data.furniture_pos)
    if fur then
        local nowDur, maxDur = HomeMgr:getDurInfo(fur)
        local cosrCash = HomeMgr:getFixCost(nowDur, maxDur)
        HomeMgr:repairItem(fur, cosrCash)
    end
end

function ArtifactPracticeDlg:onCleanAddButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if not self.homeData then return end
    if self.homeData.cleanliness == self.homeData.max_cleanliness then
        -- 当前清洁度已满，无需清洁了。
        gf:ShowSmallTips(CHS[7002347])
        return
    end

    HomeMgr:requestData("HomeCleanDlg")
end

function ArtifactPracticeDlg:onLingqiAddButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    self:setCtrlVisible("ChosePanel", true)
end

function ArtifactPracticeDlg:onStopButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end

    if not self.data then return end
    HomeMgr:cmdHouseUseFurniture(self.data.furniture_pos, "artifact_practice", "stop", "")
end

function ArtifactPracticeDlg:onStartButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.furnitureId)
        -- 目标家具已消失
        if not furn then
            gf:ShowSmallTips(CHS[5410041])
            ChatMgr:sendMiscMsg(CHS[5410041])
            self:onCloseButton()
            return
        end

        -- 对应家具位置已发生改变
        if self.furnitureX ~= furn.curX or self.furnitureY ~= furn.curY then
            gf:ShowSmallTips(CHS[4200418])
            ChatMgr:sendMiscMsg(CHS[4200418])
            self:onCloseButton()
            return
        end
    end

    if not self.data then return end
    HomeMgr:cmdHouseUseFurniture(self.data.furniture_pos, "artifact_practice", "start", "")
end


function ArtifactPracticeDlg:onPointButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if not self.homeData then return end
    if self.homeData.nimbus == self.homeData.max_nimbus then
        gf:ShowSmallTips(CHS[4100680])
        return
    end

    local dlg = DlgMgr:openDlgEx("ArtifactAddDlg", { furnitureId = self.furnitureId, pX = self.furnitureX, pY = self.furnitureY })
    dlg:setData(self.homeData, self.data.furniture_pos)
    self:setCtrlVisible("ChosePanel", false)
end

function ArtifactPracticeDlg:onCoinButton(sender, eventType)
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000283]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000283]))
        return
    end

    if not self.homeData then return end
    if self.homeData.nimbus > self.homeData.max_nimbus - 200 then
        gf:ShowSmallTips(CHS[4100680])
        return
    end

    local dlg = DlgMgr:openDlgEx("ArtifactBuyDlg", { furnitureId = self.furnitureId, pX = self.furnitureX, pY = self.furnitureY })
    dlg:setData(self.homeData, self.data.furniture_pos)
    self:setCtrlVisible("ChosePanel", false)
end

function ArtifactPracticeDlg:MSG_HOUSE_SELECT_ARTIFACT(data)
    if self.data and self.data.furniture_pos ~= data.furniture_pos then
        return
    end
    self.data = data
    self:setArtifact(data.item)

    local showPanel = self:getControl("ShowPanel")
    -- 家具名称
    self:setLabelText("NameLabel", data.name, showPanel)
    self:setCtrlVisible("BKImage_1", data.name == CHS[4100675], showPanel) -- 炼器台
    self:setCtrlVisible("BKImage_2", data.name == CHS[4100676], showPanel) -- 上古炼器台
end

function ArtifactPracticeDlg:MSG_HOUSE_FURNITURE_OPER(data)
    if self.data.furniture_pos == data.furniture_pos then
        -- 耐久度
        self:setLabelText("AttribLabel", string.format("%d/%d", data.durability, self.homeData.max_durability), "NaijiuPanel")
    end
end


function ArtifactPracticeDlg:MSG_HOUSE_DATA(data)
    -- 舒适度
    local comf = HomeMgr:getComfort()
    local max_comf = HomeMgr:getMaxComfort()
    self:setLabelText("AttribLabel", string.format("%d/%d", comf, max_comf), "ComfortPanel")

    -- 清洁度
    self:setLabelText("AttribLabel", string.format("%d/%d", HomeMgr:getClean(), HomeMgr:getMaxClean()), "CleanPanel")
end

function ArtifactPracticeDlg:MSG_HOUSE_ARTIFACT_VALUE(data)
    if self.data and self.data.furniture_pos ~= data.furniture_pos then
        return
    end

    self.homeData = data
    self:setLabelText("ExpLabel", string.format(CHS[4200436], data.all_bonus_exp))
    self:setHomeData(data)
end

function ArtifactPracticeDlg:cleanup(data)
    -- 关闭该界面时，同时关闭各个子界面
    DlgMgr:closeDlg("ArtifactBuyDlg")
    DlgMgr:closeDlg("ArtifactAddDlg")
    DlgMgr:closeDlg("ArtifactPracticeRuleDlg")
    DlgMgr:closeDlg("SubmitEquipDlg")
end


return ArtifactPracticeDlg
