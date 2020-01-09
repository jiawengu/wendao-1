-- SubmitXinDeDlg.lua
-- Created by yangym Sep/21/2016
-- 经验心得与道武心得使用界面

local COLUNM = 5
local SPACE = 1
local MAX_USETIMES_EVERYDAY = 4

local SubmitXinDeDlg = Singleton("SubmitXinDeDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local XINDE_TYPE =
{
    jingyxd = 1,
    daowxd = 2,
}

function SubmitXinDeDlg:init()

    -- 绑定控件
    self:bindListener("RulePanel", self.onCloseRule)
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("NoteButton", self.onNoteButton)

    -- 绑定点击事件
    self:bindTouchEvent()

    -- 复制列表项
    self.targetCell = self:getControl("SingleTargetPanel", Const.UIPanel)
    self.targetCell:retain()
    self.targetCell:removeFromParent()

    -- 复制物品项
    self.itemCell = self:getControl("ItemPanel_1")
    self.itemCell:retain()
    self.itemCell:removeFromParent()

    -- 经验心得/道武心得使用情况的数据
    self.xinDeUseTimes = nil

    -- 描述选中状态的变量
    self.selectXinDe = nil
    self.selectTargetId = nil
    self.selectItemPos = nil

    -- 复选框初始化
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"ExpCheckBox", "TaoCheckBox"}, self.onCheckbox)
    self.radioGroup:selectRadio(1)
    self.selectXinDe = XINDE_TYPE.jingyxd

    -- 更新被选中心得的描述信息
    self:refreshSelectedItem()

    self:hookMsg("MSG_SET_OWNER")
    self:hookMsg("MSG_INVENTORY")
    self:hookMsg("MSG_WULIANGXINJING_XINDE_INFO")
    gf:CmdToServer("CMD_GET_WULIANGXINJING_XINDE_INFO")
end

-- 初始化目标列表
function SubmitXinDeDlg:initTargetList()
    self.list = self:resetListView("TargetListView")

    -- 目标列表的第一项固定为玩家
    local playerItem = self:createItem()

    -- 如果之前没有选目标，默认选中玩家自身
    if not self.selectTargetId or self.selectTargetId == Me:queryBasicInt("id") then
        self.selectTargetId = Me:queryBasicInt("id")
        self:getControl("ChosenEffectImage", nil, playerItem):setVisible(true)
    end

    -- 将当前项的ID作为列表项的TAG
    playerItem:setTag(Me:queryBasicInt("id"))

    self.list:pushBackCustomItem(playerItem)

    -- 目标列表中继续添加玩家的非野生宠物
    local pets = PetMgr:getOrderPets()
    for k, v in pairs(pets) do
        if v:queryInt('rank') ~= Const.PET_RANK_WILD then
            local petItem = self:createItem(v)
            petItem:setTag(v:queryBasicInt("id"))

            --如果切换心得类别之前选中了某个目标，切换心得类别后保留该目标的选中效果
            if self.selectTargetId == v:queryBasicInt("id") then
                self:getControl("ChosenEffectImage", nil, petItem):setVisible(true)
            end

            self.list:pushBackCustomItem(petItem)
        end
    end
end

-- 初始化目标列表的每一项内容
function SubmitXinDeDlg:createItem(pet)  -- 若没有传入pet参数，则生成目标项为玩家
    local cell = self.targetCell:clone()

    if pet then
        -- 头像、名字以及等级
        self:setImage("PortraitImage", ResMgr:getSmallPortrait(pet:queryBasicInt("portrait")), cell)
        self:setItemImageSize("PortraitImage", cell)
        self:setLabelText("NamePatyLabel", pet:getShowName(), cell)
        self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
            pet:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP, 19, cell)

        -- 今日使用次数
        local timesStr = self:getXinDeLeftTimes(self.selectXinDe, pet:queryBasicInt("id")) .. CHS[7000060]
        self:setLabelText("LeftNumLabel_2", timesStr, cell)
    else
        -- 头像、名字以及等级
        self:setImage("PortraitImage", ResMgr:getSmallPortrait(Me:queryBasicInt("org_icon")), cell)
        self:setItemImageSize("PortraitImage", cell)
        self:setLabelText("NamePatyLabel", Me:getShowName(), cell)
        self:setNumImgForPanel("PortraitPanel", ART_FONT_COLOR.NORMAL_TEXT,
            Me:queryBasicInt("level"), false, LOCATE_POSITION.LEFT_TOP, 19, cell)

        -- 今日使用次数
        local timesStr = self:getXinDeLeftTimes(self.selectXinDe, Me:queryBasicInt("id")) .. CHS[7000060]
        self:setLabelText("LeftNumLabel_2", timesStr, cell)
    end

    -- 显示“道行/武学”或者显示“经验进度条”
    if self.selectXinDe == XINDE_TYPE.jingyxd then

        -- 显示经验进度条，进度条内部显示相应数值
        self:getControl("ExpPanel", nil, cell):setVisible(true)
        self:getControl("TaoPanel", nil, cell):setVisible(false)

        local exp = nil
        local exp_to_next_level = nil
        if pet then
            exp, exp_to_next_level = pet:queryInt("exp"), pet:queryInt("exp_to_next_level")
        else
            exp, exp_to_next_level = Me:queryInt("exp"), Me:queryInt("exp_to_next_level")
        end

        self:setProgressBar("ProgressBar_1", exp, exp_to_next_level, cell)
        local realExpPercent = math.floor(100 * exp / exp_to_next_level)
        self:setLabelText("ExpLabel_1", realExpPercent .. "%", cell)
        self:setLabelText("ExpLabel_2", realExpPercent .. "%", cell)

    elseif self.selectXinDe == XINDE_TYPE.daowxd then

        -- 显示道行/武学：若是玩家，则显示“道行”；若是宠物，则显示“武学”。
        self:getControl("ExpPanel", nil, cell):setVisible(false)
        self:getControl("TaoPanel", nil, cell):setVisible(true)

        if pet then
            self:setLabelText("TaoLabel", CHS[3000050] .. ":" ,cell)
            self:setLabelText("TaoValueLabel", pet:queryInt("martial"), cell)
        else
            self:setLabelText("TaoValueLabel",
                gf:getTaoStr(Me:queryBasicInt("tao"), Me:queryBasicInt("tao_ex")), cell)
        end

    end

    -- 设置此列表项的点击响应函数
    local function listener(sender, eventType)
        if eventType == ccui.TouchEventType.ended then

            -- 点击某一列表项后，会将之前选择列表项的选中效果取消，并为当前列表项添加选中效果
            local lastSelectedId = nil
            if self.selectTargetId then
                self:getControl("ChosenEffectImage", nil,
                    self.list:getChildByTag(self.selectTargetId)):setVisible(false)
                lastSelectedId = self.selectTargetId
            end

            self:getControl("ChosenEffectImage", nil, sender):setVisible(true)

            -- 记录当前选中的目标ID
            if pet then
                self.selectTargetId = pet:queryBasicInt("id")
            else
                self.selectTargetId = Me:queryBasicInt("id")
            end

            -- 切换目标时，会取消心得选择并清除心得状态,同时之前选择的目标状态也要重置
            if self.selectItemPos then
                self:getControl("GetImage", nil,
                    self.scrollview:getChildByTag(999):getChildByTag(self.selectItemPos)):setVisible(false)
                self.selectItemPos = nil
            end
            self:refreshSelectedItem()
            self:refreshSelectedTarget(lastSelectedId)
        end
    end

    cell:addTouchEventListener(listener)

    return cell
end

-- 初始化心得（经验心得/道武心得）物品列表
function SubmitXinDeDlg:initItemList()

    -- 重新生成列表时，将原本的选中状态清除
    self.selectItemPos = nil

    self.scrollview = self:getControl("ScrollView")
    self.scrollview:removeAllChildren()
    local contentLayer = ccui.Layout:create()

    -- 获取对应心得的物品数据
    local xinDeName = nil
    if self.selectXinDe == XINDE_TYPE.jingyxd then
        xinDeName = CHS[7000044]
    elseif self.selectXinDe == XINDE_TYPE.daowxd then
        xinDeName = CHS[7000045]
    end

    local data = InventoryMgr:getXinDe(xinDeName)

    local count = #data + 1 -- 加1是因为最后一格多了便捷购买
    local cellColne = self.itemCell:clone()
    local line = math.floor(count / COLUNM)
    local left =  count % COLUNM

    if left ~= 0 then
        line = line + 1
    end

    local curColunm = 0
    local totalHeight = line * (cellColne:getContentSize().height + SPACE)

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = COLUNM
        end

        for j = 1, curColunm do
            local tag = j + (i - 1) * COLUNM
            local cell = cellColne:clone()
            cell:setAnchorPoint(0,1)
            local x = (j - 1) * (cellColne:getContentSize().width + SPACE)
            local y = totalHeight - (i - 1) * (cellColne:getContentSize().height + SPACE)
            cell:setPosition(x, y)
            self:setItemCellData(cell, data[tag], tag == count)
            if tag ~= count then
                cell:setTag(data[tag].pos)
            end

            contentLayer:addChild(cell)
        end
    end

    contentLayer:setContentSize(self.scrollview:getContentSize().width, totalHeight)
    self.scrollview:addChild(contentLayer, 1, 999)
    self.scrollview:setInnerContainerSize(contentLayer:getContentSize())

    if totalHeight < self.scrollview:getContentSize().height then
        contentLayer:setPositionY(self.scrollview:getContentSize().height  - totalHeight)
    end
end

function SubmitXinDeDlg:setItemCellData(cell, item, isAddItem)

    -- 根据当前选择的心得类型来决定类似于心得类型名称、物品图标这样的属性
    local itemIconPath = nil
    local itemName = nil
    if self.selectXinDe == XINDE_TYPE.jingyxd then
        itemName = CHS[7000044]
    elseif self.selectXinDe == XINDE_TYPE.daowxd then
        itemName = CHS[7000045]
    end

    itemIconPath = InventoryMgr:getIconFileByName(itemName)

    -- 是否为最后一项：若是最后一项，图标置灰并显示加号
    if isAddItem then
        self:setCtrlVisible("AddImage", true, cell)
        self:setCtrlVisible("GetImage", false, cell)
        self:setImage("ItemImage", itemIconPath, cell)
        self:setItemImageSize("ItemImage", cell)
        local image = self:getControl("ItemImage", nil ,cell)
        gf:grayImageView(image)
    else
        self:setCtrlVisible("AddImage", false, cell)
        self:setCtrlVisible("GetImage", false, cell)
        self:setImage("ItemImage", InventoryMgr:getIconFileByName(item.name), cell)
        self:setItemImageSize("ItemImage", cell)

        -- 为物品项左上角添加“等级”
        if item.level then
            self:setNumImgForPanel("Panel", ART_FONT_COLOR.NORMAL_TEXT,
                item.level, false, LOCATE_POSITION.LEFT_TOP, 19, cell)
        end

        -- 为物品项右下角添加“堆叠个数”
        if item.amount and item.amount > 1 then
            self:setNumImgForPanel("Panel", ART_FONT_COLOR.NORMAL_TEXT,
                item.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, cell)
        end


    end

    local function touch(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if isAddItem then
                -- 若点击的是最后一项“便捷购买”图标，则弹出集市界面
                local textCtrl = CGAColorTextList:create()
                local resources = InventoryMgr:getItemInfoByName(itemName).rescourse
                local resourceStr
                for i = 1, #resources do
                    if string.match(resources[i], CHS[3000792]) then
                        resourceStr = resources[i]
                    end
                end

                if resourceStr then
                    -- 参数中需要附加心得等级（由玩家等级决定）
                    resourceStr = string.sub(resourceStr, 1, string.len(resourceStr) - 2)
                    resourceStr = resourceStr .. ":" .. MarketMgr:getXindeLVByLevel(nil, itemName) .. "#@"

                    textCtrl:setString(resourceStr)
                DlgMgr:openDlgWithParam(textCtrl:getCsParam())
                end
            else
                -- 若当前点击的是已被选中的目标，则取消选中；否则选中当前目标。
                if not self.selectItemPos then
                    self:getControl("GetImage", nil, sender):setVisible(true)
                    self.selectItemPos = item.pos
                elseif self.selectItemPos == item.pos then
                    self:getControl("GetImage", nil, sender):setVisible(false)
                    self.selectItemPos = nil
                else
                    self:getControl("GetImage", nil, sender):setVisible(true)
                    self:getControl("GetImage", nil,
                        self.scrollview:getChildByTag(999):getChildByTag(self.selectItemPos)):setVisible(false)
                    self.selectItemPos = item.pos
                end

                -- 更新选中目标状态以及心得状态栏
                self:refreshSelectedItem()
                self:refreshSelectedTarget()
            end
        end
    end

    cell:addTouchEventListener(touch)
end

-- 更新当前选中的目标项状态，主要包括经验条
function SubmitXinDeDlg:refreshSelectedTarget(lastSelectedId)

    -- 更新目标项状态的预览效果，主要包括经验条
    if self.selectXinDe == XINDE_TYPE.jingyxd then
        local exp = nil
        local exp_to_next_level = nil
        local expAdd = nil
        local realExpPercent = nil
        local addExpPercent = nil

        -- 重置之前选中项的进度条
        if lastSelectedId then

            -- 获取当前经验、升级所需经验
            if lastSelectedId == Me:queryBasicInt("id") then
                exp, exp_to_next_level = Me:queryInt("exp"), Me:queryInt("exp_to_next_level")
            else
                local pet = PetMgr:getPetById(lastSelectedId)
                if not pet then return end
                exp, exp_to_next_level = pet:queryInt("exp"), pet:queryInt("exp_to_next_level")
            end

            realExpPercent = math.floor(100 * exp / exp_to_next_level)

            -- 进度条预览部分不再显示
            self:getControl("ProgressBar_2", nil, self.list:getChildByTag(lastSelectedId)):setVisible(false)

            -- 进度条内不再显示预览数值
            self:setLabelText("ExpLabel_1", realExpPercent .. "%", self.list:getChildByTag(lastSelectedId))
            self:setLabelText("ExpLabel_2", realExpPercent .. "%", self.list:getChildByTag(lastSelectedId))
        end


        -- 更新当前选中项的进度条
        if self.selectTargetId == Me:queryBasicInt("id") then
            exp, exp_to_next_level = Me:queryInt("exp"), Me:queryInt("exp_to_next_level")
        else
            local pet = PetMgr:getPetById(self.selectTargetId)
            if not pet then return end
            exp, exp_to_next_level = pet:queryInt("exp"), pet:queryInt("exp_to_next_level")
        end

        realExpPercent = math.floor(100 * exp / exp_to_next_level)
        local selectedTargetPanel = self.list:getChildByTag(self.selectTargetId)

        -- 显示正常进度条
        self:setProgressBar("ProgressBar_1", exp, exp_to_next_level, selectedTargetPanel)

        if self.selectItemPos then

            -- 获取心得增加的经验
            local item = InventoryMgr:getItemByPos(self.selectItemPos)
            if not item then return end
            expAdd = item.exp or 0
            expAdd = self:getExpBalance(expAdd)
            addExpPercent = math.floor(100 * expAdd / exp_to_next_level)

            -- 显示预览进度条
            self:setProgressBar("ProgressBar_2", exp + expAdd, exp_to_next_level, selectedTargetPanel)
            self:getControl("ProgressBar_2", nil, selectedTargetPanel):setVisible(true)
            self:getControl("ProgressBar_2", nil, selectedTargetPanel):setLocalZOrder(1)

            -- 进度条内部显示预览数值信息
            self:setLabelText("ExpLabel_1", realExpPercent .. "% + " .. addExpPercent .. "%", selectedTargetPanel)
            self:setLabelText("ExpLabel_2", realExpPercent .. "% + " .. addExpPercent .. "%", selectedTargetPanel)
        else

            -- 不显示预览进度条
            self:getControl("ProgressBar_2", nil, selectedTargetPanel):setVisible(false)

            -- 进度条内部不显示预览值
            self:setLabelText("ExpLabel_1", realExpPercent .. "%", selectedTargetPanel)
            self:setLabelText("ExpLabel_2", realExpPercent .. "%", selectedTargetPanel)
        end
    end
end

-- 更新选中的心得状态栏信息
function SubmitXinDeDlg:refreshSelectedItem()
    local previewPanel = self:getControl("PreviewPanel")

    if not self.selectItemPos then
        previewPanel:setVisible(false)
    else
        self:getControl("PreviewPanel"):setVisible(true)

        -- 设置状态栏图标
        local item = InventoryMgr:getItemByPos(self.selectItemPos)
        if not item then return end
        self:setImage("GuardImage", InventoryMgr:getIconFileByName(item.name), previewPanel)
        self:setItemImageSize("GuardImage", previewPanel)

        -- 为图标左上角添加“等级”
        if item.level then
            self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT,
                item.level, false, LOCATE_POSITION.LEFT_TOP, 19, "PreviewPanel")
        end

        -- 为图标右下角添加“堆叠个数”
        if item.amount and item.amount > 1 then
            self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT,
                item.amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "PreviewPanel")
        elseif item.amount and item.amount == 1 then
            self:setNumImgForPanel("ShapePanel", ART_FONT_COLOR.NORMAL_TEXT,
                nil, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, "PreviewPanel")
        end

        -- 设置名称
        self:setLabelText("NameLabel", string.format(CHS[3002762] .. item.name, item.level or 0), previewPanel)

        -- 设置使用数量
        self:setLabelText("ApplyNumLabel", string.format(CHS[7000050], 1), previewPanel)

        -- 设置经验/道行/武学
        if self.selectXinDe == XINDE_TYPE.jingyxd and self.selectTargetId == Me:queryBasicInt("id") then
            -- 人物经验
            self:setLabelText("TypeLabel", CHS[3003157] .. CHS[7000078], previewPanel)
            self:setLabelText("ValueLabel_1", "", previewPanel)
            self:setLabelText("ValueLabel_2", item.exp, previewPanel, COLOR3.GREEN)

        elseif self.selectXinDe == XINDE_TYPE.jingyxd and self.selectTargetId ~= Me:queryBasicInt("id") then
            -- 宠物经验
            self:setLabelText("TypeLabel", CHS[3003157] .. CHS[7000078], previewPanel)
            self:setLabelText("ValueLabel_1", "", previewPanel)
            self:setLabelText("ValueLabel_2", item.exp, previewPanel, COLOR3.GREEN)

        elseif self.selectXinDe == XINDE_TYPE.daowxd and self.selectTargetId == Me:queryBasicInt("id") then
            -- 人物道行
            self:setLabelText("TypeLabel", CHS[3003158] .. CHS[7000078], previewPanel)
            self:setLabelText("ValueLabel_1", "", previewPanel)
            self:setLabelText("ValueLabel_2", gf:getTaoStr(item.tao or 0, 0), previewPanel, COLOR3.GREEN)

        elseif self.selectXinDe == XINDE_TYPE.daowxd and self.selectTargetId ~= Me:queryBasicInt("id") then
            -- 宠物武学
            self:setLabelText("TypeLabel", CHS[3000050] .. CHS[7000078], previewPanel)
            self:setLabelText("ValueLabel_1", "", previewPanel)
            self:setLabelText("ValueLabel_2", item.martial, previewPanel, COLOR3.GREEN)
        end
    end
    self:updateLayout("PreviewPanel")
end

function SubmitXinDeDlg:setUseItemPos(pos)
    self.selectItemPos = pos
end

-- 打开对话框后默认选中玩家所点击使用的那本经验心得/道武心得
function SubmitXinDeDlg:setUseItem()
    local pos = self.selectItemPos
    if not pos then
        return
    end

    local item = InventoryMgr:getItemByPos(pos)
    if not item then
        return
    end

    local name = item.name
    if name == CHS[7000044] then
        self.radioGroup:selectRadio(1)
    elseif name == CHS[7000045] then
        self.radioGroup:selectRadio(2)
    end

    self:getControl("GetImage", nil,
        self.scrollview:getChildByTag(999):getChildByTag(pos)):setVisible(true)

    self.selectItemPos = pos

    self:refreshSelectedItem()

    self:refreshSelectedTarget()
end

-- 经验的等级差削减
function SubmitXinDeDlg:getExpBalance(expAdd)
    -- 削减后的经验
    if not self.selectTargetId or not self.selectItemPos then
        return expAdd
    end

    local level
    local item = InventoryMgr:getItemByPos(self.selectItemPos)
    if not item then return expAdd end
    if self.selectTargetId == Me:queryBasicInt("id") then
        level = Me:queryBasicInt("level")
    else
        local pet = PetMgr:getPetById(self.selectTargetId)
        if pet then
            level = pet:queryInt("level")
        else
            level  = 0
        end
    end

    expAdd = math.floor(expAdd * Formula:getExpBalance(level - item.level) + 0.5)
    return expAdd
end

function SubmitXinDeDlg:onExpButton(sender, eventType)

    -- 保存当前选择的心得状态
    self.selectXinDe = XINDE_TYPE.jingyxd

    -- 更新目标列表
    self:initTargetList()

    -- 更新物品列表
    self:initItemList()

    -- 重置心得状态显示栏
    self:refreshSelectedItem()
end

function SubmitXinDeDlg:onTaoButton(sender, eventType)

    -- 保存当前选择的心得状态
    self.selectXinDe = XINDE_TYPE.daowxd

    -- 更新目标列表
    self:initTargetList()

    -- 更新物品列表
    self:initItemList()

    -- 重置心得状态显示栏
    self:refreshSelectedItem()
end

function SubmitXinDeDlg:onSubmitButton(sender, eventType)

    -- 玩家处于禁闭状态
    if Me:isInJail() then
        gf:ShowSmallTips(CHS[6000214])
        return
    end

    -- 玩家正在战斗中
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3002430])
        return
    end

    -- 当前未选中使用目标
    if not self.selectTargetId then
        gf:ShowSmallTips(CHS[7000051])
        return
    end

    -- 未选择要使用的心得
    if not self.selectItemPos then
        gf:ShowSmallTips(CHS[7000052])
        return
    end

    local item = InventoryMgr:getItemByPos(self.selectItemPos)
    local xindeLevel = item and item.level or 0
    local meLevel = Me:queryBasicInt("level")
    local pet = PetMgr:getPetById(self.selectTargetId)
    local petLevel = nil
    local petNameStr = nil
    if self.selectTargetId ~= Me:queryBasicInt("id") then
        if not pet then return end
        petLevel = pet:queryBasicInt("level")
        petNameStr = string.format(CHS[7000054], pet:getShowName())
    end

    if self.selectXinDe == XINDE_TYPE.jingyxd then  -- 如果当前选中经验心得
        if self.selectTargetId == Me:queryBasicInt("id") then

            -- 玩家达到最高等级上限
            if meLevel == Const.PLAYER_MAX_LEVEL then
                gf:ShowSmallTips(string.format(CHS[7000055], CHS[7000053]))
                return
            end

            -- 玩家锁定了经验
            if Me:queryBasicInt("lock_exp") ~= 0 then
                gf:ShowSmallTips(string.format(CHS[7000056], CHS[7000053]))
                return
            end

            -- 玩家等级小于经验心得等级
            if meLevel < xindeLevel then
                gf:ShowSmallTips(string.format(CHS[7000057], CHS[7000053], CHS[7000044]))
                return
            end

            -- 玩家等级超过经验心得等级9级
            if meLevel > xindeLevel + 9 then
                gf:ShowSmallTips(string.format(CHS[7000058], CHS[7000053], CHS[7000044], CHS[7000053]))
                return
            end

            -- 玩家当天已经使用了4本经验心得
            if self:getXinDeLeftTimes(XINDE_TYPE.jingyxd, self.selectTargetId) <= 0 then
                gf:ShowSmallTips(string.format(CHS[7000059], CHS[7000053], CHS[7000044]))
                return
            end
        else
            -- 宠物达到最高等级上限
            if petLevel == Const.PLAYER_MAX_LEVEL then
                gf:ShowSmallTips(string.format(CHS[7000055], petNameStr))
                return
            end

            -- 宠物锁定了经验
            if pet:queryBasicInt("lock_exp") ~= 0 then
                gf:ShowSmallTips(string.format(CHS[7000056], petNameStr))
                return
            end

            -- 宠物等级小于经验心得等级
            if petLevel < xindeLevel then
                gf:ShowSmallTips(string.format(CHS[7000057], petNameStr, CHS[7000044]))
                return
            end

            -- 宠物等级超过经验心得等级9级
            if petLevel > xindeLevel + 9 then
                gf:ShowSmallTips(string.format(CHS[7000058], petNameStr, CHS[7000044], petNameStr))
                return
            end

            -- 宠物当天已经使用了4本经验心得
            if self:getXinDeLeftTimes(XINDE_TYPE.jingyxd, self.selectTargetId) <= 0 then
                gf:ShowSmallTips(string.format(CHS[7000059], petNameStr, CHS[7000044]))
                return
            end
        end
    elseif self.selectXinDe == XINDE_TYPE.daowxd then  -- 如果当前选中道武心得
        if self.selectTargetId == Me:queryBasicInt("id") then

            -- 玩家等级小于道武心得等级
            if meLevel < xindeLevel then
                gf:ShowSmallTips(string.format(CHS[7000057], CHS[7000053], CHS[7000045]))
                return
            end

            local maxLimitLevel = xindeLevel + 9
            if Const.PLAYER_MAX_LEVEL - xindeLevel == 10 then
                maxLimitLevel = xindeLevel + 10
            end

            -- 玩家等级超过道武心得等级9级
            if meLevel > maxLimitLevel then
                gf:ShowSmallTips(string.format(CHS[7000058], CHS[7000053], CHS[7000045], CHS[7000053]))
                return
            end

            -- 玩家当天已经使用了4本道武心得
            if self:getXinDeLeftTimes(XINDE_TYPE.daowxd, self.selectTargetId) <= 0 then
                gf:ShowSmallTips(string.format(CHS[7000059], CHS[7000053], CHS[7000045]))
                return
            end
        else
            -- 宠物等级小于道武心得等级
            if petLevel < xindeLevel then
                gf:ShowSmallTips(string.format(CHS[7000057], petNameStr, CHS[7000045]))
                return
            end

            local maxLimitLevel = xindeLevel + 9
            if Const.PLAYER_MAX_LEVEL - xindeLevel == 10 then
                maxLimitLevel = xindeLevel + 10
            end

            -- 宠物等级超过道武心得等级9级
            if petLevel > maxLimitLevel then
                gf:ShowSmallTips(string.format(CHS[7000058], petNameStr, CHS[7000045], petNameStr))
                return
            end

            -- 宠物当天已经使用了4本道武心得
            if self:getXinDeLeftTimes(XINDE_TYPE.daowxd, self.selectTargetId) <= 0 then
                gf:ShowSmallTips(string.format(CHS[7000059], petNameStr, CHS[7000045]))
                return
            end
        end
    end

    -- 通过判断，使用经验心得/道武心得
    if self.selectTargetId == Me:queryBasicInt("id") then
        gf:CmdToServer('CMD_APPLY', {pos = self.selectItemPos, amount = 1})
    else
        local pet = PetMgr:getPetById(self.selectTargetId)
        if not pet then return end
        local no = pet:queryBasicInt("no")
        gf:CmdToServer("CMD_FEED_PET", { no = no, pos = self.selectItemPos, para = ""})
    end

    self.selectItemPos = nil
    self:refreshSelectedItem()

    -- 重新请求心得使用次数数据
    gf:CmdToServer("CMD_GET_WULIANGXINJING_XINDE_INFO")
end

-- 获取当前目标剩余的可使用心得的数量
function SubmitXinDeDlg:getXinDeLeftTimes(xindeType, userId)
    if not self.xinDeUseTimes then
        return MAX_USETIMES_EVERYDAY
    end

    for i = 1, #self.xinDeUseTimes do
        if userId == self.xinDeUseTimes[i].id then
            if xindeType == XINDE_TYPE.jingyxd then
                return MAX_USETIMES_EVERYDAY - self.xinDeUseTimes[i].jyxd_times
            elseif xindeType == XINDE_TYPE.daowxd then
                return MAX_USETIMES_EVERYDAY - self.xinDeUseTimes[i].dwxd_times
            end
        end
    end

    return MAX_USETIMES_EVERYDAY
end

function SubmitXinDeDlg:onCheckbox(sender, eventType)  --选项卡响应
    local name = sender:getName()
    if "ExpCheckBox" == name then
        self:onExpButton()
    elseif "TaoCheckBox" == name then
        self:onTaoButton()
    end
end

function SubmitXinDeDlg:onNoteButton(sender, eventType)  -- 打开规则界面的按钮
    local panel = self:getControl("RulePanel")
    panel:setVisible(true)
end

function SubmitXinDeDlg:bindTouchEvent()  -- 用于处理规则界面的点击响应
    local panel = self:getControl("RulePanel")
    local layout = ccui.Layout:create()
    layout:setContentSize(self.root:getContentSize())
    layout:setPosition(self.root:getPosition())
    layout:setAnchorPoint(self.root:getAnchorPoint())
    panel:setVisible(false)

    local  function touch(touch, event)
        local rect = self:getBoundingBoxInWorldSpace(panel)
        local toPos = touch:getLocation()
        local classRect = self:getBoundingBoxInWorldSpace(panel)

        if not cc.rectContainsPoint(rect, toPos) and not cc.rectContainsPoint(classRect, toPos) and  panel:isVisible() then
            panel:setVisible(false)
            return true
        end
    end
    self.root:addChild(layout, 10, 1)

    gf:bindTouchListener(layout, touch)
end

function SubmitXinDeDlg:onCloseRule(sender, eventType)
    local rulePanel = self:getControl("RulePanel")
    rulePanel:setVisible(false)
end

function SubmitXinDeDlg:cleanup()
    self.selectXinDe = nil
    self.selectTargetId = nil
    self.selectItemPos = nil
    self.xinDeUseTimes = nil

    self:releaseCloneCtrl("targetCell")
    self:releaseCloneCtrl("itemCell")
end

function SubmitXinDeDlg:MSG_WULIANGXINJING_XINDE_INFO(data)
    self.xinDeUseTimes = data
    self:initTargetList()

    -- 初始化目标列表完成，之后默认选中玩家所点击使用的心得
    self:setUseItem()
end

function SubmitXinDeDlg:MSG_INVENTORY(data)
    -- 更新物品列表
    self:initItemList()
end

function SubmitXinDeDlg:MSG_SET_OWNER(data)
    -- 更新目标列表
    self:initTargetList()
end

return SubmitXinDeDlg