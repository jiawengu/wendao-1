-- SubmitGodBookDlg.lua
-- Created by Chang_back Jun/10/2015
-- 天书提交界面

local SubmitGodBookDlg = Singleton("SubmitGodBookDlg", Dialog)

local MAX_SCROLL_HIGHT = 355

local GOD_BOOK = {
    [CHS[5000032]] = "moyin",
    [CHS[5000033]] = "kuangbao",
    [CHS[5000035]] = "potian",
    [CHS[5000030]] = "xiangmozhan",
    [CHS[5000031]] = "xiuluoshu",
    [CHS[5000036]] = "fanji",
    [CHS[5000037]] = "yunti",
    [CHS[5000038]] = "xianfeng",
    [CHS[5000039]] = "jinzhong",
    [CHS[5000034]] = "nuji",
    [CHS[3000138]] = "jinglei",
    [CHS[3000139]] = "qingmu",
    [CHS[3000140]] = "hanbing",
    [CHS[3000141]] = "lieyan",
    [CHS[3000142]] = "suishi",
}

local GODBOOK_SKILLS_B = {
    'xiangmozhan',
    'xiuluoshu',
    'moyin',
    'kuangbao',
    'nuji',
    'potian',
    'fanji',
    'yunti',
    'xianfeng',
    'jinzhong',
    "jinglei",
    "qingmu",
    "hanbing",
    "lieyan",
    "suishi",
}

local GODBOOK_SKILL_NUM = #GODBOOK_SKILLS_B

local BAG_HEIGHT = 455
local BAG_WIDTH = 307


function SubmitGodBookDlg:init()
    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("CancelButton", self.onCancelButton)
    self:bindListener("ReplenishButton", self.onReplenishButton)

    self.scrollView = self:getControl("GodBookScrollView", Const.UIScrollView)
    self.tmpItem = self:getControl("SingleGodBookPanel_1", Const.UIPanel)
    self.tmpItem:retain()
    self.tmpItem:removeFromParent()

    self:setCtrlVisible("NonePanel", false)

    local rowPanel = self:getControl("OneRowGodBookPanel", Const.UIPanel)
    rowPanel:removeFromParent()

    self.selectGodBook = nil
    self.selectItem = nil
    self.isAddGodBook = nil
    self.petId = nil
    self.petNo = nil

    self:hookMsg("MSG_INVENTORY")
end

function SubmitGodBookDlg:setPetId(id)
    self.petId = id
    if PetMgr:getPetById(id) then
        self.petNo = PetMgr:getPetById(id):queryBasicInt("no")
    end

end

function SubmitGodBookDlg:cleanup()
    self:releaseCloneCtrl("tmpItem")
    DlgMgr:closeDlg('AddPetBookDlg')
end

function SubmitGodBookDlg:showInventory(itemTips, data, callback)

end

function SubmitGodBookDlg:addGodBook()
    if not self.petNo then return end


    local pet = PetMgr:getPetByNo(self.petNo)
    if not pet then return end
    local pos = self.selectGodBook.pos

    if not pet then
        return
    end
    local godBookCount = pet:queryBasicInt('god_book_skill_count')
    local dlg = DlgMgr:getDlgByName("PetSkillDlg")
    if not dlg then return end
    local skillNo = dlg.curSkillNo
    local power = 0
    for i = 1, godBookCount do
        -- 获取当前天书技能的各个属性
        local nameKey = 'god_book_skill_name_' .. i
        local name = pet:queryBasic(nameKey)
        local skillAttr = SkillMgr:getskillAttribByName(name)
        if skillNo == skillAttr.skill_no then
            local levelKey = 'god_book_skill_level_' .. i
            local powerKey = 'god_book_skill_power_' .. i
            local level = pet:queryBasic(levelKey)
            local bookPower = pet:queryBasicInt(powerKey)
            power = bookPower
        end
    end
    if power + self.selectGodBook.nimbus > 30000 then
        gf:ShowSmallTips(CHS[4200043])
        return
    end

    local petNo = pet:queryBasicInt("no")
    local item = InventoryMgr:getItemByPos(pos)
    local str, day = gf:converToLimitedTimeDay(pet:queryInt("gift"))
    local curSkillName = DlgMgr:getDlgByName("PetSkillDlg").curSkillName
    InventoryMgr:feedPet(petNo, pos, curSkillName)
end

function SubmitGodBookDlg:intSubmitInfo(isShowAll)
    if not self.petNo then return end
    local pet = PetMgr:getPetByNo(self.petNo)
    if not pet then return end
    local godBookCount = pet:queryBasicInt('god_book_skill_count')

    local godBookSkills = {}
    for i = 1, #GODBOOK_SKILLS_B do
        godBookSkills[i] = GODBOOK_SKILLS_B[i]
    end

    local bagItem = InventoryMgr:getItemByTypeWithMerge(ITEM_TYPE.GODBOOK)

    self.isAddGodBook = isShowAll
    if not isShowAll then
        -- 查找已学习技能
        for i = 1, godBookCount do
            -- 获取天书技能的各个属性
            local nameKey = 'god_book_skill_name_' .. i
            local name = pet:queryBasic(nameKey)
            for j = 1, #godBookSkills do
                -- 若为为学习的技能天书则移除天书
                for k, v in pairs(bagItem) do
                    if v.name == name then
                        table.remove(bagItem,k)
                    end
                end
            end
        end
    else
        -- 补充灵气，显示元宝补充按钮
        self:setCtrlVisible("ReplenishButton", true)
    end
    self.tmpItem:removeFromParent()

    -- 初始化scrollview列表
    local contentSize = self.scrollView:getContentSize()
    local size = self.tmpItem:getContentSize()
    size.height = size.height * math.ceil(#bagItem / 2)

    if size.height < contentSize.height then
        size = contentSize
    end

    self.scrollView:setInnerContainerSize(size)

    for k, v in pairs(bagItem) do
        local godbookItem = self.tmpItem:clone()
        local iconPath = ResMgr:getItemIconPath(v.icon)
        local iconImage = self:getControl("GuardImage", Const.UIImage, godbookItem)

        if iconPath then
            iconImage:loadTexture(iconPath)
            self:setItemImageSize("GuardImage", godbookItem)
        end

        -- 刷新道具数量
        self:refreshItemNum(v.amount, godbookItem)

        if InventoryMgr:isTimeLimitedItem(v) then
            InventoryMgr:addLogoTimeLimit(iconImage)
        elseif InventoryMgr:isLimitedItem(v) then
            InventoryMgr:addLogoBinding(iconImage)
        end

        local nameLabel = self:getControl("NameLabel", Const.UILabel, godbookItem)

        if nameLabel then
            nameLabel:setString(v.name)
        end

        local nimbusLabel = self:getControl("NimbusLabel", Const.UILabel, godbookItem)
        nimbusLabel:setString(CHS[3003661] .. v.nimbus)

        if v.nimbus == 0 then
            nimbusLabel:setColor(COLOR3.RED)
        end
        local contentSize = godbookItem:getContentSize()
        local x, y = godbookItem:getPosition()
        godbookItem:setPosition(x + ((k + 1) % 2) * contentSize.width, size.height - (math.floor((k + 1) / 2) * contentSize.height))
        self.scrollView:addChild(godbookItem)

        -- 绑定长按事件
        self:blindLongPressWithCtrl(godbookItem, function(dlg, sender, eventType)
            -- 显示名片
            if InventoryMgr:getItemByPos(v.pos) then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            InventoryMgr:showBasicMessageByItem(v, rect)
            end
        end, function(dlg, sender, eventType)
            local children = self.scrollView:getChildren()

            for _, v in pairs(children) do
                self:setCtrlVisible("ChosenEffectImage", false, v)
            end

            self:setCtrlVisible("ChosenEffectImage", true, sender)
            self.selectGodBook = v
            self.selectItem = sender
            self:refreshSelectedGodBookDesc()
        end, true)

    end

    self:setCtrlVisible("NonePanel", not next(bagItem))
    self:refreshSelectedGodBookDesc()
    self.scrollView:jumpToTop()
end

-- 刷新道具数量
function SubmitGodBookDlg:refreshItemNum(amount, godbookItem)
    local numImg = self:setNumImgForPanel("NumPanel", ART_FONT_COLOR.NORMAL_TEXT, amount, false, LOCATE_POSITION.RIGHT_BOTTOM, 19, godbookItem)
    numImg:setVisible(true)
    if amount <= 1 then
        numImg:setVisible(false)
    end
end

function SubmitGodBookDlg:refreshSelectedGodBookDesc()
    local skillDesc
    if self.selectGodBook then
        skillDesc = SkillMgr:getSkillDesc(self.selectGodBook.name)
    end

    if skillDesc and skillDesc.pet_desc then
        self:setColorText(skillDesc.pet_desc, "DescrPanel", "DescPanel", nil, nil, nil, 19)
    else
        self:setColorText("", "DescrPanel", "DescPanel", nil, nil, nil, 19)
    end

    local listView = self:getControl("DescrListView", Const.UIListView, "DescPanel")
    listView:requestRefreshView()
end

-- 获取当前滚动的百分比
-- 获取当前ListView滚动百分比
function SubmitGodBookDlg:getCurScrollPercent()
    local height = self.scrollView:getInnerContainer():getSize().height - BAG_HEIGHT
    local curPosY = self.scrollView:getInnerContainer():getPositionY()
    return curPosY / height * (-100)
end

function SubmitGodBookDlg:learnGodSkill()
    local pet = DlgMgr:sendMsg('PetListChildDlg', 'getCurrentPet')

    if not pet then
        return
    end

    local petNo = pet:queryBasicInt("no")
    InventoryMgr:feedPet(petNo, self.selectGodBook.pos, '')
    SkillMgr.selectGodbookSkillName = self.selectGodBook.name
end

function SubmitGodBookDlg:onSubmitButton(sender, eventType)
    if not self.isAddGodBook then
        -- 学习天书
        if Me:isInCombat() then
            gf:ShowSmallTips(CHS[3003663])
            return
        end

        if not self.selectGodBook then
            gf:ShowSmallTips(CHS[3000063])
            return
        end

        self:learnGodSkill()
        self:onCloseButton()
    else
        -- 补充灵气
        if not self.selectGodBook then
            gf:ShowSmallTips(CHS[3000063])
            return
        end
        self:addGodBook()
    end
end

-- 元宝补充按钮
function SubmitGodBookDlg:onReplenishButton(sender, eventType)
    if not self.petNo then return end


    local pet = PetMgr:getPetByNo(self.petNo)
    if not pet then return end
    local dlg = DlgMgr:openDlg("AddPetBookDlg")
    dlg:setData(pet)
end

function SubmitGodBookDlg:onCancelButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
end

-- 这个界面中只需要监听选中的物品的信息是否变化，非选中物品的信息更新无需处理
function SubmitGodBookDlg:MSG_INVENTORY(data)
    if not self.selectGodBook then
        return
    end

    local bagItem = InventoryMgr:getItemByTypeWithMerge(ITEM_TYPE.GODBOOK)

    for i = 1, data.count do
        if self.selectGodBook.pos == data[i].pos then
            if not data[i].name then
                -- 物品用完了，重新刷一下
                self.scrollView:removeAllChildren()
                self.selectGodBook = nil
                self.selectItem = nil
                self:refreshSelectedGodBookDesc()
                self:intSubmitInfo(self.isAddGodBook)
                return
            elseif self.selectItem then
                -- 刷新物品数量
                for j = 1, #bagItem do
                    if bagItem[j] and InventoryMgr:isSameItemToMerge(bagItem[j], data[i]) then
                        self:refreshItemNum(bagItem[j].amount, self.selectItem)
                        break
                    end
                end

                return
            end
        end
    end
end

return SubmitGodBookDlg
