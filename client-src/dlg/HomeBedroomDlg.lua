-- HomeBedroomDlg.lua
-- Created by yangym Jun/20/2017
-- 卧室界面
local HomeBedroomDlg = Singleton("HomeBedroomDlg", Dialog)

local RadioGroup = require("ctrl/RadioGroup")

local MIN_CLEAN = 20

local userDefault
local userDefaultKey

function HomeBedroomDlg:init(data)
    self:bindListener("SleepButton", self.onSleepButton)
    self:bindListener("BigSleepButton", self.onBigSleepButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("AddButton", self.onAddDurButton, "BedroomInfoPanel")
    self:bindListener("AddCleanButton", self.onAddCleanButton, "BedroomInfoPanel")

    userDefault = cc.UserDefault:getInstance()
    userDefaultKey = "HomeBedroomDlgSleepType" .. gf:getShowId(Me:queryBasic("gid"))
    local value = userDefault:getIntegerForKey(userDefaultKey)
    if value == 0 then
        value = 1
    end

    -- 复选框初始化
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"SleepType1CheckBox", "SleepType2CheckBox"}, self.onCheckBox)
    self.radioGroup:selectRadio(value)

    self:hookMsg("MSG_HOUSE_FURNITURE_OPER")
    self:hookMsg("MSG_HOUSE_DATA")
    self:hookMsg("MSG_BEDROOM_FURNITURE_APPLY_DATA")

    HomeMgr:requestData()
    HomeMgr:requestBedRoom()

    self.curId = data[1]
    self.rawX = data[2]
    self.rawY = data[3]
    self.bedroomSleepCount = data[4] or 1

    self:setBedInfo()
end

function HomeBedroomDlg:setBedInfo()
    local data = {
        bedRoomType = HomeMgr:getBedroomType(),
        sleepTimes = math.max(0, HomeMgr:getMaxSleepTimes() -  HomeMgr:getBedroomSleepTimes()),
        nowComfort = HomeMgr:getComfort(),
        maxComfort = HomeMgr:getMaxComfort(),
        nowClean = HomeMgr:getClean(),
        maxClean = HomeMgr:getMaxClean(),
    }

    local furn = HomeMgr:getFurnitureById(self.curId)
    if not furn then
        return
    end

    -- 卧室空间
    self:setLabelText("SpaceTypeLabel", self:getBedroomTypeStr(data))

    -- 居所舒适度
    self:setLabelText("ComfortNumLabel", data.nowComfort)
    self:setLabelText("ComfortLimitNumLabel", "/" .. data.maxComfort)

    -- 居所耐久度
    local nowDur, maxDur = self:getDurInfo(furn)
    if nowDur < Const.SLEEP_COST_DUR then
        self:setLabelText("DurableNumLabel", nowDur, "BedroomInfoPanel", COLOR3.RED)
    else
        self:setLabelText("DurableNumLabel", nowDur, "BedroomInfoPanel", COLOR3.TEXT_DEFAULT)
    end

    self:setLabelText("DurableLimitNumLabel", "/" .. maxDur, "BedroomInfoPanel")

    -- 消耗的耐久度
    local sleepCostDur =  Const.SLEEP_COST_DUR * self.bedroomSleepCount
    self:setLabelText("CostNumLabel", string.format(CHS[5420218], sleepCostDur))

    -- 居所清洁度
    if data.nowClean <= MIN_CLEAN then
        self:setLabelText("CleanNumLabel", data.nowClean, "BedroomInfoPanel", COLOR3.RED)
    else
        self:setLabelText("CleanNumLabel", data.nowClean, "BedroomInfoPanel", COLOR3.TEXT_DEFAULT)
    end

    self:setLabelText("CleanLimitNumLabel", "/" .. data.maxClean, "BedroomInfoPanel")

    -- 气血储备
    local lifeStoreStr = gf:getMoneyDesc(self:getLifeStore(data), true)
    self:setLabelText("NumLabel", lifeStoreStr, "SleepTypePanel_1")

    -- 法力储备
    local manaStoreStr = gf:getMoneyDesc(self:getManaStore(data), true)
    self:setLabelText("NumLabel", manaStoreStr, "SleepTypePanel_2")


    -- 左边内容

    -- 名称
    local name = furn:queryBasic("name")
    self:setLabelText("NameLabel", name, "BedPanel")

    if self.bedroomSleepCount == 2 then
        self:setLabelText("SleepTextLabel", CHS[5410155], "BedPanel")
    else
        self:setLabelText("SleepTextLabel", CHS[5410156], "BedPanel")
    end

    -- 休息次数
    self:setLabelText("SleepNumLabel", data.sleepTimes)
    self:setLabelText("LimitSleepNumLabel", string.format(CHS[7002357], HomeMgr:getMaxSleepTimes()))

    -- 床的形象
    local bedImage = self:getControl("BedImage")
    bedImage:loadTexture(self:getBedRes(name))
    bedImage:setScale(0.85, 0.85)
end

function HomeBedroomDlg:onCheckBox(sender, idx)
    if userDefault then
        userDefault:setIntegerForKey(userDefaultKey, idx)
    end
end

-- 休息按钮
function HomeBedroomDlg:onSleepButton()
    local furn = HomeMgr:getFurnitureById(self.curId)
    if not furn then
        -- 家具已消失
        gf:ShowSmallTips(CHS[4200431])
        self:onCloseButton()
        return
    end

    local x, y = gf:convertToMapSpace(furn.curX, furn.curY)
    if x ~= self.rawX or y ~= self.rawY then
        -- 家具位置移动
        gf:ShowSmallTips(CHS[2000391])
        self:onCloseButton()
        return
    end

    local sleepType
    local type = self.radioGroup:getSelectedRadioIndex()
    if type == 1 then
        sleepType = "life"
    elseif type == 2 then
        sleepType = "mana"
    end

    -- self.bedroomSleepCount 1 一个人休息，2 双人休息
    -- 服务端  0 一个人休息，2 双人休息
    HomeMgr:cmdHouseUseFurniture(self.curId, "rest", sleepType, tostring(self.bedroomSleepCount - 1))
end

function HomeBedroomDlg:onInfoButton()
    DlgMgr:openDlg("HomeBedroomRuleDlg")
end

-- 修理按钮
function HomeBedroomDlg:onBigSleepButton()
    local furn = HomeMgr:getFurnitureById(self.curId)
    if not furn then
        -- 家具已消失
        gf:ShowSmallTips(CHS[4200431])
        self:onCloseButton()
        return
    end


    local x, y = gf:convertToMapSpace(furn.curX, furn.curY)
    if x ~= self.rawX or y ~= self.rawY then
        -- 家具位置移动
        gf:ShowSmallTips(CHS[2000391])
        self:onCloseButton()
        return
    end

    local sleepType
    local type = self.radioGroup:getSelectedRadioIndex()
    if type == 1 then
        sleepType = "life"
    elseif type == 2 then
        sleepType = "mana"
    end

    -- self.bedroomSleepCount 1 一个人休息，2 双人休息
    -- 服务端  0 一个人休息，2 双人休息，3 一个人酣睡，4 双人酣睡
    HomeMgr:cmdHouseUseFurniture(self.curId, "rest", sleepType, tostring(self.bedroomSleepCount + 1))
end

function HomeBedroomDlg:cleanup()
    DlgMgr:closeDlg("HomeBedroomRuleDlg")

    userDefault = nil
end

-- 获取卧室空间
function HomeBedroomDlg:getBedroomTypeStr(data)
    local type = data.bedRoomType
    if type == BEDROOM_TYPE.SMALL then
        return CHS[7002343]
    elseif type == BEDROOM_TYPE.MIDDLE then
        return CHS[7002344]
    elseif type == BEDROOM_TYPE.BIG then
        return CHS[7002345]
    end
end

function HomeBedroomDlg:getDurInfo(item)
    local dur = item:queryBasicInt("durability")
    local maxDur = HomeMgr:getMaxDur(item:queryBasic("name"))
    return dur, maxDur
end

-- 获取当前可增加的气血储备（舒适度不超过居所类型对应的最大舒适度）
function HomeBedroomDlg:getLifeStore(data)
    local comfort = math.min(data.nowComfort, HomeMgr:getMaxComfort())
    return math.ceil(Const.SLEEP_COST_DUR * 50000 * 3 / (1 - (comfort / 1000) * 0.3 - (self.bedroomSleepCount - 1) * 0.1))
end

-- 获取当前可增加的法力储备（舒适度不超过居所类型对应的最大舒适度）
function HomeBedroomDlg:getManaStore(data)
    local comfort = math.min(data.nowComfort, HomeMgr:getMaxComfort())
    return math.ceil(Const.SLEEP_COST_DUR * 50000 / (1 - (comfort / 1000) * 0.3 - (self.bedroomSleepCount - 1) * 0.1))
end

-- 获取当前选中床的形象资源
function HomeBedroomDlg:getBedRes(name)
    local icon = HomeMgr:getFurnitureIcon(name)
    return ResMgr:getFurniturePath(icon)
end

-- 获取恢复耐久所消耗的金钱
function HomeBedroomDlg:getCostMoney(item)
    local nowDur, maxDur = self:getDurInfo(item)
    return HomeMgr:getFixCost(nowDur, maxDur)
end

function HomeBedroomDlg:onAddDurButton(sender, eventType)
    local furn = HomeMgr:getFurnitureById(self.curId)
    if not furn then
        -- 家具已消失
        gf:ShowSmallTips(CHS[4200431])
        self:onCloseButton()
        return
    end

    local furniture_pos = self.curId

    -- 这件家具的耐久度已达上限，无需进行修理。
    local dur, maxDur =self:getDurInfo(furn)
    if dur >= maxDur then
        gf:ShowSmallTips(CHS[7002350])
        return
    end

    local costMoney = self:getCostMoney(furn)
    if costMoney then
        local name = furn.name or furn:queryBasic("name")
        local moneyStr = gf:getMoneyDesc(costMoney)
        local tip = string.format(CHS[7002351], moneyStr, name)
        gf:confirm(tip, function()
            if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
                gf:ShowSmallTips(CHS[5410117])
                return
            end

            gf:CmdToServer("CMD_HOUSE_REPAIR_FURNITURE", {furniture_pos = furniture_pos, cost = costMoney})
        end)
    end
end

function HomeBedroomDlg:onAddCleanButton(sender, eventType)
    if HomeMgr:getClean() == HomeMgr:getMaxClean() then
        -- 当前清洁度已满，无需清洁了。
        gf:ShowSmallTips(CHS[7002347])
        return
    end

    HomeMgr:requestData("HomeCleanDlg")
    --DlgMgr:openDlg("HomeCleanDlg")
end

function HomeBedroomDlg:MSG_HOUSE_DATA()
    self:setBedInfo()
end

function HomeBedroomDlg:MSG_BEDROOM_FURNITURE_APPLY_DATA()
    self:setBedInfo()
end

function HomeBedroomDlg:MSG_HOUSE_FURNITURE_OPER(data)
    if not (data.action == "repair" or data.action == "update") then
        return
    end

    self:setBedInfo()
end

return HomeBedroomDlg
