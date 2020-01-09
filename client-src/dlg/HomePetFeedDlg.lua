-- HomePetFeedDlg.lua
-- Created by huangzz July/11/2017
-- 宠物饲养界面

local HomePetFeedDlg = Singleton("HomePetFeedDlg", Dialog)

local DataObject = require("core/DataObject")

local PRODUCE_TYPE =
{
    exp = 0,
    tao = 1,
}

function HomePetFeedDlg:init()
    self:bindListener("GetButton", self.onGetButton)
    self:bindListener("StopButton", self.onStopButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("InfoButton", self.onInfoButton)
    self:bindListener("AddButton", self.onAddFoodButton, "FurniturePanel")
    self:bindListener("CleanButton", self.onCleanPetButton, "PetShapePanel")
    self:bindListener("AddButton", self.onChoosePetButton, "PetShapePanel")
    self:bindListener("SwitchPanel", self.onChangeValueButton)

    self.schedule = nil
    self.feedStatus = 0
    self.feedPetValue = nil
    self.selectPetFeed = nil
    self.petFoodInfo = nil

    self.curBowlId = HomeMgr:getCurChooseBowlId()
    self.furniture = HomeMgr:getFurnitureById(self.curBowlId)
    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) and self.furniture then
        self.furnitureX, self.furnitureY = self.furniture.curX, self.furniture.curY
    end

    self:MSG_HOUSE_PET_FEED_STATUS_INFO(HomeMgr.bowlFeedStatus[self.curBowlId])
    self:MSG_HOUSE_PET_FEED_SELECT_PET(HomeMgr.selectPetFeed[self.curBowlId])
    self:MSG_HOUSE_PET_FEED_VALUE_INFO(HomeMgr.feedPetValue[self.curBowlId])
    self:MSG_HOUSE_PET_FEED_FOOD_INFO(HomeMgr.petFoodInfo[self.curBowlId])

    self:hookMsg("MSG_HOUSE_PET_FEED_VALUE_INFO")
    self:hookMsg("MSG_HOUSE_PET_FEED_FOOD_INFO")
    self:hookMsg("MSG_HOUSE_PET_FEED_SELECT_PET")
    self:hookMsg("MSG_HOUSE_PET_FEED_STATUS_INFO")
end

-- 显示收益相关信息
function HomePetFeedDlg:initValueView(data)
    if data.type == PRODUCE_TYPE.exp then
        self:setCtrlVisible("ExpImage", true, "SwitchPanel")
        self:setCtrlVisible("TaoImage", false, "SwitchPanel")
        self:setCtrlVisible("ExpImage", true, "BornPanel")
        self:setCtrlVisible("TaoImage", false, "BornPanel")
        self:setCtrlVisible("ExpImage", true, "StoragePanel")
        self:setCtrlVisible("TaoImage", false, "StoragePanel")
    elseif data.type == PRODUCE_TYPE.tao then
        self:setCtrlVisible("ExpImage", false, "SwitchPanel")
        self:setCtrlVisible("TaoImage", true, "SwitchPanel")
        self:setCtrlVisible("ExpImage", false, "BornPanel")
        self:setCtrlVisible("TaoImage", true, "BornPanel")
        self:setCtrlVisible("ExpImage", false, "StoragePanel")
        self:setCtrlVisible("TaoImage", true, "StoragePanel")
    end

    if data.bonus_value == 0 then
        -- 置灰领取按钮
        gf:grayImageView(self:getControl("GetButton"))

        self:setCtrlEnabled("GetButton", false)
    else
        gf:resetImageView(self:getControl("GetButton"))
        self:setCtrlEnabled("GetButton", true)
    end

    if self.selectPetFeed and self.selectPetFeed.pet_iid ~= "" then
        -- 效率
        local color = COLOR3.TEXT_DEFAULT
        if data.rate > 0 then
            color = COLOR3.BLUE
        end

        self:setLabelText("ValueLabel", string.format(CHS[5410071], data.efficiency), "BornPanel", color)
    end

    if self.feedStatus == 1 or data.bonus_value > 0 then
        -- 累计收益
        if data.type == 1 then
            self:setLabelText("ValueLabel", data.bonus_value .. CHS[5410102], "StoragePanel")
        else
            self:setLabelText("ValueLabel", data.bonus_value, "StoragePanel")
        end
    else
        self:setLabelText("ValueLabel", CHS[5410097], "StoragePanel")
    end

    if data.bonus_value > 0 then
        -- 按钮显示领取
        self:setLabelText("TextLabel_1", CHS[5410092], "StartButton")
        self:setLabelText("TextLabel_2", CHS[5410092], "StartButton")
    else
        -- 按钮显示开始饲养
        self:setLabelText("TextLabel_1", CHS[5410093], "StartButton")
        self:setLabelText("TextLabel_2", CHS[5410093], "StartButton")
    end
end

function HomePetFeedDlg:onDlgOpened(list)
    self.bowlName = list[1]

    self:MSG_HOUSE_PET_FEED_FOOD_INFO(HomeMgr.petFoodInfo[self.curBowlId])
end

-- 显示食粮相关信息
function HomePetFeedDlg:initFoodView(data)
    data.name = self.bowlName

    local percent = data.num / data.max_num
    self:setLabelText("FeedNumLabel", data.num .. "/" .. data.max_num, "BowlPanel")
    local foodIcon, bowlImage = HomeMgr:getFoodImageInfo(data.name, percent)
    if foodIcon then
        -- 显示食粮
        self:setImage("FeedImage", foodIcon, "BowlPanel")
        self:setCtrlVisible("FeedImage", true, "BowlPanel")
    else
        self:setCtrlVisible("FeedImage", false, "BowlPanel")
    end

    if bowlImage then
        -- 显示食盆
        self:setImage("BowlImage", bowlImage, "BowlPanel")
    end

    if data.name then
        -- 食盆名称
        self:setLabelText("NameLabel", data.name, "FurniturePanel")
    end

    -- 倒计时
    self:setLeftTime(self.leftTime)
    local fur = HomeMgr:getFurnitureById(data.bowl_id)
    local bowlIId = data.bowl_iid
    local function refreshTime()
        if self.feedStatus == 0 then
            return
        end

        self.leftTime = self.leftTime - 1
        if self.leftTime >= 0 then
            self:setLeftTime(self.leftTime)
        end

        if self.leftTime == 0 then
            if fur then
                HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "feed_info")
            else
                gf:CmdToServer("CMD_HOUSE_REQUEST_PET_FEED_INFO", {furniture_iid = bowlIId})
            end
        end
    end

    if not self.schedule then
        self.schedule = schedule(self.root, refreshTime, 1)
    end
end

function HomePetFeedDlg:setLeftTime(time)
    local m = math.floor(time / 60)
    local s = time % 60
    local totalM = math.floor((time + self.remainTime) / 60)

    if totalM == 0 then
        self:setLabelText("HoldTimeNumLabel", string.format(CHS[5410103], s), "TimePanel")
    else
        self:setLabelText("HoldTimeNumLabel", string.format(CHS[5410090], totalM, s), "TimePanel")
    end

    if m == 0 then
        self:setLabelText("NextTimeLabel", string.format(CHS[5410089], string.format(CHS[5410103], s)), "TimePanel")
    else
        self:setLabelText("NextTimeLabel", string.format(CHS[5410089], string.format(CHS[5410090], m, s)), "TimePanel")
    end
end

function HomePetFeedDlg:getPetIcon(data)
    if data.fasion_id and data.fasion_id ~= 0 and data.fasion_visible ~= 0 then return data.fasion_id end

    if data.dye_icon and data.dye_icon ~= 0 then return data.dye_icon end

    -- data.pet_icon 为 服务器下发已有数据
    return data.pet_icon
end

-- 显示宠物相关信息
function HomePetFeedDlg:initPetView(data)
    if data.pet_iid ~= "" then
        -- 已选择宠物
        self:setCtrlVisible("AddButton", false, "PetShapePanel")
        self:setCtrlVisible("CleanButton", true, "PetShapePanel")
        self:setCtrlVisible("PetIconPanel", true)

        local icon = self:getPetIcon(data)
        self:setPortrait("PetIconPanel", icon, 0, self.root, true, nil, nil, cc.p(0, -36))

        if self.feedPetValue and self.feedPetValue.efficiency then
            local color = COLOR3.TEXT_DEFAULT
            if self.feedPetValue.rate > 0 then
                color = COLOR3.BLUE
            end

            self:setLabelText("ValueLabel", string.format(CHS[5410071], self.feedPetValue.efficiency), "BornPanel", color)
        end

        -- 标识
        self:setCtrlVisible("PetLogoPanel", true)
        PetMgr:setPetLogo(self, self.showPet)

        -- 设置类型：野生、宝宝
        self:setCtrlVisible("SuffixImage", true)
        self:setImage("SuffixImage", ResMgr:getPetRankImagePath(self.showPet))
    else
        self:setCtrlVisible("AddButton", true, "PetShapePanel")
        self:setCtrlVisible("CleanButton", false, "PetShapePanel")
        self:getControl("PetIconPanel"):removeAllChildren()
        self:setCtrlVisible("PetIconPanel", false)
        self:setCtrlVisible("SuffixImage", false)
        self:setCtrlVisible("PetLogoPanel", false)
        self:setLabelText("ValueLabel", CHS[5410098], "BornPanel")
    end

    self:setLabelText("NameLabel", data.pet_name ~= "" and string.format(CHS[5410096], data.pet_name) or CHS[2100111], "PetShapePanel")
end

-- 显示停止/开始状态信息
function HomePetFeedDlg:initStatusView(data)
    local status = data.status

    if data.is_my == 0 then
        -- 非己方家具
        self:setCtrlVisible("RewardPanel", false)
        self:setCtrlVisible("ButtonPanel", false)
        self:setCtrlVisible("NoticePanel", true)
        self:setCtrlEnabled("AddButton", false, "PetShapePanel")
        self:setCtrlEnabled("CleanButton", false, "PetShapePanel")
    else
        self:setCtrlVisible("RewardPanel", true)
        self:setCtrlVisible("ButtonPanel", true)
        self:setCtrlVisible("NoticePanel", false)
        self:setCtrlEnabled("AddButton", true, "PetShapePanel")
        self:setCtrlEnabled("CleanButton", true, "PetShapePanel")
    end

    if status == 0 then
        self:setCtrlVisible("GetButton", false)
        self:setCtrlVisible("StopButton", false)
        self:setCtrlVisible("StartButton", true)
        if data.is_my == 1 then
            self:setCtrlVisible("HoldTimeNumLabel", true, "TimePanel")
            self:setCtrlVisible("NextTimeLabel", true, "TimePanel")
            self:setCtrlVisible("HoldTimeTextLabel", true, "TimePanel")
        else
            self:setCtrlVisible("NextTimeLabel", false, "TimePanel")
            self:setCtrlVisible("HoldTimeNumLabel", false, "TimePanel")
            self:setCtrlVisible("HoldTimeTextLabel", false, "TimePanel")
        end
        if self.feedPetValue then
            if self.feedPetValue.bonus_value > 0 then
                self:setLabelText("TextLabel_1", CHS[5410092], "StartButton")
                self:setLabelText("TextLabel_2", CHS[5410092], "StartButton")

                if self.feedPetValue.type == 1 then
                    self:setLabelText("ValueLabel", self.feedPetValue.bonus_value .. CHS[5410102], "StoragePanel")
                else
                    self:setLabelText("ValueLabel", self.feedPetValue.bonus_value, "StoragePanel")
                end
            else
                self:setLabelText("TextLabel_1", CHS[5410093], "StartButton")
                self:setLabelText("TextLabel_2", CHS[5410093], "StartButton")
                self:setLabelText("ValueLabel", CHS[5410097], "StoragePanel")
            end
        else
            self:setLabelText("ValueLabel", CHS[5410097], "StoragePanel")
        end
    elseif status == 1 then
        self:setCtrlVisible("GetButton", true)
        self:setCtrlVisible("StopButton", true)
        self:setCtrlVisible("StartButton", false)

        if data.is_my == 1 then
            self:setCtrlVisible("HoldTimeNumLabel", true, "TimePanel")
            self:setCtrlVisible("NextTimeLabel", true, "TimePanel")
            self:setCtrlVisible("HoldTimeTextLabel", true, "TimePanel")
        else
            self:setCtrlVisible("NextTimeLabel", false, "TimePanel")
            self:setCtrlVisible("HoldTimeNumLabel", false, "TimePanel")
            self:setCtrlVisible("HoldTimeTextLabel", false, "TimePanel")
        end

        if self.feedPetValue then
            if self.feedPetValue.type == 1 then
                self:setLabelText("ValueLabel", self.feedPetValue.bonus_value .. CHS[5410102], "StoragePanel")
            else
                self:setLabelText("ValueLabel", self.feedPetValue.bonus_value, "StoragePanel")
            end
        end
    end
end

function HomePetFeedDlg:setSelectPet(petId)
    HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "select_pet", tostring(petId))
end


function HomePetFeedDlg:onInfoButton(sender, eventType)
    DlgMgr:openDlg("HomePetFeedRuleDlg")
end

-- 移除宠物
function HomePetFeedDlg:onCleanPetButton(sender, eventType)
    if not self:canOper() then
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.curBowlId)
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

    if not self.feedPetValue then
        return
    end

    -- 若当前家具不属于玩家自己（不可使用夫妻另一半的宠物食盆），则弹出如下提示
    if self.isMy == 0 then
        gf:ShowSmallTips(CHS[5410083])
        return
    end

    -- 若角色处于战斗中，则给予如下弹出提示
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5000079])
        return
    end

    -- 若当前正在饲养过程中，则给予如下弹出提示
    if self.feedStatus == 1 then
        gf:ShowSmallTips(CHS[5410045])
        return
    end

    -- 该宠物当前尚有累积经验/武学未被领取，无法移除。
    local valueType = self.feedPetValue.type
    if self.feedPetValue.bonus_value > 0 then
        gf:ShowSmallTips(string.format(CHS[5410046], valueType == 0 and CHS[5410084] or CHS[5410085]))
        return
    end

    HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "remove_pet")
end

function HomePetFeedDlg:canOper()
    if not MapMgr:isInHouse(MapMgr:getCurrentMapName()) or HomeMgr:getHouseId() ~= Me:queryBasic("house/id") then
        gf:ShowSmallTips(CHS[5410115])
        return
    end

    if not string.match(MapMgr:getCurrentMapName(), CHS[2000282]) then
        gf:ShowSmallTips(string.format(CHS[5410116], CHS[2000282]))
        return
    end

    return true
end

-- 选择宠物
function HomePetFeedDlg:onChoosePetButton(sender, eventType)
    if not self:canOper() then
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.curBowlId)
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

    -- 若当前家具不属于玩家自己（不可使用夫妻另一半的宠物食盆），则弹出如下提示
    if self.isMy == 0 then
        gf:ShowSmallTips(CHS[5410083])
        return
    end

    HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "select_pet")
end


-- 补充食粮
function HomePetFeedDlg:onAddFoodButton(sender, eventType)
    if not self:canOper() then
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.curBowlId)
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

    if not self.feedPetValue and not self.petFoodInfo then
        return
    end

    HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "pre_add_food")
end

-- 开始饲养宠物
function HomePetFeedDlg:onStartButton(sender, eventType)
    if not self:canOper() then
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.curBowlId)
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

    if not self.feedPetValue and not self.petFoodInfo then
        return
    end

    if self.feedStatus == 0 and self.feedPetValue.bonus_value > 0 then
        -- 未开始饲养宠物，且有收益未领取
        self:onGetButton(sender, eventType)
        return
    end

    local pet = self.myPet
    local valueType = self.feedPetValue.type

    -- 若当前家具不属于玩家自己（不可使用夫妻另一半的宠物食盆），则弹出如下提示
    if self.isMy == 0 then
        gf:ShowSmallTips(CHS[5410083])
        return
    end

    -- 若当前尚未选择饲养的宠物，则予以如下弹出提示
    if self.selectPetFeed.pet_iid == "" then
        gf:ShowSmallTips(CHS[5410051])
        return
    end

    -- 若当前尚选择饲养的宠物未携带，则予以如下弹出提示
    if not pet then
        gf:ShowSmallTips(CHS[5410095])
        return
    end

    -- 若当前所选择的宠物为野生宠物，则予以如下弹出提示
    if pet:queryInt('rank') == Const.PET_RANK_WILD then
        gf:ShowSmallTips(CHS[5410052])
        return
    end

    -- 若当前所选择的宠物为限时宠物，则予以如下弹出提示
    if PetMgr:isTimeLimitedPet(pet) then
        gf:ShowSmallTips(CHS[5410053])
        return
    end

    -- 若当前选择的宠物等级<50级，则予以如下弹出提示
    local petLevel = pet:queryInt('level')
    if petLevel < 50 then
        gf:ShowSmallTips(CHS[5410055])
        return
    end

    -- 若当前选择的是经验收益类型，但当前宠物尚未飞升且已达到已达115级满经验-1，则予以如下弹出提示
    local petExp = pet:queryBasicInt("exp")
    local petMaxExp = PetMgr:getPetMaxExpForLevel(petLevel)
    if valueType == 0 and petLevel == 115 and not PetMgr:isFlyPet(pet) and petExp >= petMaxExp - 1 then
        gf:ShowSmallTips(CHS[5420320])
        return
    end

    -- 若当前选择的是经验收益类型，但当前宠物等级≥人物等级+15级且满经验-1，则予以如下弹出提示
    local meLevel = Me:queryInt("level")
    if valueType == 0 and (petLevel - meLevel == 15 and petExp >= petMaxExp - 1 or petLevel - meLevel > 15) then
        gf:ShowSmallTips(CHS[5410056])
        return
    end

    -- 若当前选择的是经验收益类型，但当前宠物已锁定经验，则予以如下弹出提示
    if valueType == 0 and pet:queryBasicInt("lock_exp") == 1 then
        gf:ShowSmallTips(CHS[5410058])
        return
    end

    -- 若当前选择的是经验收益类型，但当前宠物达等级上限（飞升前、后等级上限不同，详见[升级经验数值详细设计(design)]的等级限制）
    if valueType == 0 and (petLevel == Const.PLAYER_MAX_LEVEL and petExp >= petMaxExp - 1 or petLevel > Const.PLAYER_MAX_LEVEL) then
        gf:ShowSmallTips(CHS[5410056])
        return
    end

    -- 若当前剩余食粮<10分钟所需消耗食粮，则予以如下弹出提示
    if self.petFoodInfo.num == 0 then
        gf:ShowSmallTips(CHS[5410060])
        return
    end

    HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "oper", "1")
end

-- 停止饲养宠物
function HomePetFeedDlg:onStopButton(sender, eventType)
    if not self:canOper() then
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.curBowlId)
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

    HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "oper", "0")
end


-- 切换武学/经验
function HomePetFeedDlg:onChangeValueButton(sender, eventType)
    if not self:canOper() then
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.curBowlId)
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

    if not self.feedPetValue then
        return
    end

    --判断玩家距离上一次成功切换时间间隔是否少于1秒，若是则予以如下弹出提示
    local time = gf:getServerTime()
    if self.lastChangeTime and self.lastChangeTime - time == 0 then
        gf:ShowSmallTips(CHS[5410075])
        return
    end

    -- 否则判断当前家具是否属于玩家自己（不可使用夫妻另一半的宠物食盆），若否则弹出如下提示
    if self.isMy == 0 then
        gf:ShowSmallTips(CHS[5410083])
        return
    end

    -- 否则判断当前是否处于饲养过程中，若是则弹出如下提示
    if self.feedStatus == 1 then
        gf:ShowSmallTips(CHS[5410047])
        return
    end

    -- 否则判断当前是否有未领取的累积数值奖励，若有则弹出如下提示
    if self.feedPetValue.bonus_value > 0 then
        gf:ShowSmallTips(CHS[5410048])
        return
    end

    if self.feedPetValue.type == 1 then
        HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "switch_bonus_type", "0")
    else
        HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "switch_bonus_type", "1")
    end

    self.lastChangeTime = time
end

-- 领取收益
function HomePetFeedDlg:onGetButton(sender, eventType)
    if not self:canOper() then
        return
    end

    if MapMgr:isInHouse(MapMgr:getCurrentMapName()) then
        local furn = HomeMgr:getFurnitureById(self.curBowlId)
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

    -- 若角色处于战斗中，则给予如下弹出提示
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[5000079])
        return
    end

    HomeMgr:cmdHouseUseFurniture(self.curBowlId, "feed_pet", "get_bonus")
end

-- 饲养收益
function HomePetFeedDlg:MSG_HOUSE_PET_FEED_VALUE_INFO(data)
    if not data or data.bowl_id ~= self.curBowlId then
        return
    end

    self.feedPetValue = data
    self:initValueView(data)
end

-- 更换宠物
function HomePetFeedDlg:MSG_HOUSE_PET_FEED_SELECT_PET(data)
    if not data or data.bowl_id ~= self.curBowlId then
        return
    end

    self.selectPetFeed = data

    self.myPet = PetMgr:getPetByIId(data.pet_iid)

    if not self.showPet then
        self.showPet = DataObject.new()
    end

    self.showPet:absorbBasicFields(data)

    self:initPetView(data)
end

-- 培养食粮
function HomePetFeedDlg:MSG_HOUSE_PET_FEED_FOOD_INFO(data)
    if not data or data.bowl_id ~= self.curBowlId then
        return
    end

    self.petFoodInfo = data
    self.leftTime = data.next_bonus_time
    if data.remain_time > 0 then
        self.remainTime = data.remain_time * 60
    else
        self.remainTime = 0
    end

    self:initFoodView(data)
end

-- 设置开始/停止饲养宠物
function HomePetFeedDlg:MSG_HOUSE_PET_FEED_STATUS_INFO(data)
    if not data or data.bowl_id ~= self.curBowlId then
        return
    end

    self.feedStatus = data.status
    self.isMy = data.is_my

    self:initStatusView(data)
end

-- 清理
function HomePetFeedDlg:cleanup()
    self.myPet = nil
    self.feedStatus = 0
    self.isMy = 0
    self.feedPetValue = nil
    self.selectPetFeed = nil
    self.petFoodInfo = nil

    -- 关闭该界面时，同时关闭各个子界面
    DlgMgr:closeDlg("HomePetFeedRuleDlg")
    DlgMgr:closeDlg("SubmitPetDlg")
    DlgMgr:closeDlg("HomeBuyFeedDlg")
end

return HomePetFeedDlg
