-- LinkDlg.lua
-- Created by zhengjh Apr/9/2015
-- 常用语和名片链接

local LinkDlg = Singleton("LinkDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

local Config_Data =
{
    ItemCheckBox = "ItemScrollPanel",
    PetCheckBox = "PetScrollPanel",
    GuardCheckBox = "GuardScrollPanel",
    TaskCheckBox = "TaskScrollPanel",
    SkillCheckBox = "SkillScrollPanel",
    TitleCheckBox = "TitleScrollPanel",
}


local CONST_DATA =
{
    columnSpace = 5 ,
    lineSapce = 10 ,
}


function LinkDlg:init()
    self:bindListener("KeyBoardButton", self.onKeyBoardButton)
    self:bindListener("ExpressionButton", self.onExpressionButton)
    self:bindListener("SpaceButton", self.onSpaceButton)
    self:bindListener("DelButton", self.onDelButton)
    self:bindListener("SendButton", self.onSendButton)
    self.root:setAnchorPoint(0,0)
    self.root:setPosition(0,0)
    self:bindListener("Panel_10", self.onEdit)

    self.itemCell = self:getControl("SingleItemPanel_1", Const.UIPanel)
    self.itemCell:retain()
    self.itemCell:removeFromParent()

    self.petCell = self:getControl("SinglePetPanel_1", Const.UIPanel)
    self.petCell:retain()
    self.petCell:removeFromParent()

    self.guardCell = self:getControl("SingleGuardPanel_1", Const.UIPanel)
    self.guardCell:retain()
    self.guardCell:removeFromParent()

    self.taskCell = self:getControl("SingleTaskPanel_1", Const.UIPanel)
    self.taskCell:retain()
    self.taskCell:removeFromParent()

    self.skillCell = self:getControl("SingleSkillPanel_1", Const.UIPanel)
    self.skillCell:retain()
    self.skillCell:removeFromParent()

    self.titleCell = self:getControl("SingleTitlePanel_1", Const.UIPanel)
    self.titleCell:retain()
    self.titleCell:removeFromParent()

    self.panelListTable = {}
    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"ItemCheckBox", "PetCheckBox", "GuardCheckBox", "TaskCheckBox", "SkillCheckBox", "TitleCheckBox"}, self.onCheckBox)

    -- 默认选中第一个
    self:setTabListInfo("ItemCheckBox")
    self.radioGroup:selectRadio(1)

    -- 设置常用语
    self:setDailyWord()
end

function LinkDlg:onKeyBoardButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    self:callBack("swichWordInput")
end

function LinkDlg:onExpressionButton(sender, eventType)
    DlgMgr:closeDlg(self.name)
    self:callBack("onExpressionButton")
end

function LinkDlg:onSpaceButton(sender, eventType)
    self:callBack("addSpace")
end

function LinkDlg:onDelButton(sender, eventType)
    self:callBack("deleteWord")
end

function LinkDlg:onSendButton(sender, eventType)
    self:callBack("sendMessage")
end

-- 回调对象
function LinkDlg:setCallObj(obj)
    self.obj = nil
    self.obj = obj
end

-- 调用回调方法
function LinkDlg:callBack(funcName, ...)
    local func = self.obj[funcName]
    if self.obj and func then
        func(self.obj, ...)
    end
end


function LinkDlg:onEdit(sender, eventType)
    DlgMgr:openDlg("CommonLangEditDlg")
end

function LinkDlg:setDailyWord()
    self.dailyWord = ChatMgr:getDailyWord()
    for i = 1, 9 do
        local panel = self:getControl(string.format("Panel_%d",i), Const.UIPanel)
        panel:setTag(i)
        local label = self:getControl("Label", Const.UILabel, panel)
        label:setString(self.dailyWord[i])
        self:bindListener(string.format("Panel_%d",i), self.onDailyWord)
    end
end

function LinkDlg:onDailyWord(sender, eventType)
    local tag = sender:getTag()
    self:callBack("addExpression", self.dailyWord[tag])
end

function LinkDlg:onCheckBox(sender, type)
    local name = sender:getName()
    for k,v in pairs(self.panelListTable) do
        if v then
            v:setVisible(false)
        end
    end

    if self.panelListTable[name] then
        self.panelListTable[name]:setVisible(true)
    else
        self:setTabListInfo(name)
    end
end

function LinkDlg:setTabListInfo(name)
    self.panelListTable[name] = self:getControl(Config_Data[name])
    self.panelListTable[name]:setVisible(true)
    self.panelListTable[name]:removeAllChildren()

    local columnNumber = 2
    local clonePanel = nil
    local dataTable = {}
    local func = nil

    if name == "ItemCheckBox" then
        columnNumber = 3
        clonePanel = self.itemCell
        func = self.setItemCellInfo
        dataTable = self:getItemList()
    elseif name == "PetCheckBox" then
        columnNumber = 2
        clonePanel = self.petCell
        func = self.setPetCellInfo
        dataTable = self:getPetList()
    elseif name  == "GuardCheckBox" then
        columnNumber = 2
        clonePanel = self.guardCell
        func = self.setGuardInfo
        dataTable = self:getGuardList()
    elseif name == "TaskCheckBox" then
        columnNumber = 5
        clonePanel = self.taskCell
        func = self.setTaskInfo
        dataTable = self:getTaskList()
    elseif name == "SkillCheckBox" then
        columnNumber = 3
        clonePanel = self.skillCell
        func = self.setSkillInfo
        dataTable = self:getSkillList()
     elseif name == "TitleCheckBox" then
        columnNumber = 5
        clonePanel = self.titleCell
        func = self.setTitleInfo
        dataTable = self:getTitleList()
    end

    if dataTable == nil then return end
    self:initScrolview(name,columnNumber,clonePanel,dataTable,func)
end

function LinkDlg:initScrolview(name, columnNum , clonePanel, dataTable, func)
    local scrollview = ccui.ScrollView:create()
    scrollview:setContentSize(self.panelListTable[name]:getContentSize())
    scrollview:setDirection(ccui.ScrollViewDir.horizontal)
    scrollview:setTouchEnabled(true)
    self.panelListTable[name]:addChild(scrollview)

    local container = ccui.Layout:create()
    container:setPosition(0,0)
    local number = #dataTable
    local line = math.floor(number / columnNum) + 1
    local left = number % columnNum
    local innerSizeWidth = 0

    if left == 0 then
        innerSizeWidth = (line - 1) * (clonePanel:getContentSize().width + CONST_DATA.columnSpace)
    else
        innerSizeWidth = line * (clonePanel:getContentSize().width + CONST_DATA.columnSpace)
    end

    if innerSizeWidth < scrollview:getContentSize().width then
        innerSizeWidth = scrollview:getContentSize().width
    end

    for i = 1 , line do
        local cloumnNumber = 0
        if i == line then
            cloumnNumber = left
        else
            cloumnNumber = columnNum
        end

        for j = 1 , cloumnNumber do
            local tag = (i - 1)* columnNum + j
            local cell = clonePanel:clone()
            cell:setTag(tag)
            cell:setAnchorPoint(0,1)
            local pox = (clonePanel:getContentSize().width + CONST_DATA.columnSpace) * (i - 1)
            local poy = scrollview:getContentSize().height - (clonePanel:getContentSize().height + CONST_DATA.lineSapce) * (j - 1)
            cell:setPosition(pox, poy)
            container:addChild(cell)
            func(self, cell, dataTable[tag])

            -- 给默认第一个选中图
            if tag == 1 then
                self:addSelcetImage(cell, name)
            end
        end
    end

    scrollview:addChild(container)
    container:setContentSize(innerSizeWidth, clonePanel:getContentSize().height)
    scrollview:setInnerContainerSize(container:getContentSize())
end

function LinkDlg:addSelcetImage(cell, name)
    if self[name] == nil then
        self[name] = {}
    end

    if self[name].selectImage == nil then
        self[name].selectImage = ccui.ImageView:create(ResMgr.ui.grid_select, ccui.TextureResType.plistType)
        self[name].selectImage:setAnchorPoint(0, 0)
        local imgContentSize = self[name].selectImage:getContentSize()
        local gridContentSize = cell:getContentSize()
        self[name].selectImage:setScale(gridContentSize.width / imgContentSize.width, gridContentSize.height / imgContentSize.height)
        self[name].selectImage:retain()
    else
        -- self[name].selectImage:retain()
        self[name].selectImage:removeFromParent()
    end

    cell:addChild(self[name].selectImage)
end
function LinkDlg:setItemCellInfo(cell, data)
    local function touch(sender, eventType)
         if ccui.TouchEventType.ended == eventType then
            self:addSelcetImage(cell, "ItemCheckBox")
            local item = InventoryMgr:getItemByPos(data["pos"])
            local str = string.format("{\t%s=%s=%s}", item["name"], CHS[3000015], item["item_unique"])
            local showInfo = string.format("{\t%s\t}", item["name"])
            self:callBack("addCardInfo", str,showInfo)
         end
    end

    cell:addTouchEventListener(touch)

    -- 道具图片
    local image = self:getControl("ItemImage", Const.UIImage, cell)
    image:loadTexture(data["imgFile"])
    dlg:setItemImageSize("ItemImage", cell)
end

function LinkDlg:getItemList()
    local dataTable = {}
    local equip = InventoryMgr:getEquipments() -- 武器数据
    local Jewelry = InventoryMgr:getJewelrys() -- 首饰数据
    local bag1 = InventoryMgr:getBag1Items() -- 包裹数据
    local bag2 = InventoryMgr:getBag2Items() -- 行囊数据

    for i = 1, equip["count"] do
        if equip[i]["imgFile"] then
            table.insert(dataTable, equip[i])
        end
    end

    for i = 1, Jewelry["count"] do
        if Jewelry[i]["imgFile"] then
            table.insert(dataTable, Jewelry[i])
        end
    end

    for i = 1, bag1["count"] do
        if bag1[i]["imgFile"] then
            table.insert(dataTable, bag1[i])
        end
    end

    for i = 1, bag2["count"] do
        if bag2[i]["imgFile"] then
            table.insert(dataTable, bag2[i])
        end
    end

    return dataTable
end

function LinkDlg:setPetCellInfo(cell, pet)
    -- 宠物头像
    local path = ResMgr:getSmallPortrait(pet:queryBasicInt("portrait"))
    local image = self:getControl("PortraitImage", Const.UIImage, cell)
    image:loadTexture(path)
    self:setItemImageSize("PortraitImage", cell)

    -- 名称
    local namePanel = self:getControl("NameLabel", Const.UILabel, cell)
    local name = gf:getPetName(pet["basic"])
    namePanel:setString(name)

    -- 等级
    local levelLabel = self:getControl("LevelLabel", Const.UILabel, cell)
    levelLabel:setString(CHS[2000015] .. pet:queryBasic("level"))

    local function touch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            self:addSelcetImage(cell, "PetCheckBox")

            local sendInfo = string.format("{\t%s=%s=%s}", pet:queryBasic("raw_name"), CHS[6000079],  pet:getId())
            local showInfo = string.format("{\t%s\t}", pet:queryBasic("raw_name"))
            self:callBack("addCardInfo", sendInfo, showInfo)
        end
    end

    cell:addTouchEventListener(touch)
end

function LinkDlg:getPetList()
    local function sort(left, right)
        if left:queryInt("intimacy") > right:queryInt("intimacy") then return true
        elseif left:queryInt("intimacy") < right:queryInt("intimacy") then return false
        end

        if left:queryInt("level") > right:queryInt("level") then return true
        elseif left:queryInt("level") < right:queryInt("level") then return false
        end

        if left:queryInt("shape") > right:queryInt("shape") then return true
        elseif left:queryInt("shape") < right:queryInt("shape") then return false
        end

        if left:getName() < right:getName() then return true
        else return false
        end
    end

    local petList = {}
    for k,v in pairs(PetMgr.pets) do
        table.insert(petList, v)
    end

    table.sort(petList, sort)

    return petList
end

function LinkDlg:getGuardList()
    local guardsList = {}
    local fightArr = {}
    if nil == GuardMgr.objs then return  end

    local function sortFunc(l, r)
        -- 排序逻辑
        if l.combat_guard > r.combat_guard then return true
        elseif l.combat_guard < r.combat_guard then return false
        end

        if l.rank > r.rank then return true
        elseif l.rank < r.rank then return false
        end

        if l.polar < r.polar then return true
        else return false
        end
    end

    for k, v in pairs(GuardMgr.objs) do
        table.insert(fightArr, {id = v:queryBasicInt("id"), combat_guard = v:queryBasicInt("combat_guard"),
            rank = v:queryBasicInt("rank"), polar = v:queryBasic("polar")})
    end

    table.sort(fightArr, sortFunc)

    for i = 1, #fightArr do
        table.insert(guardsList, GuardMgr:getGuard(fightArr[i].id))
    end

    return guardsList
end

function LinkDlg:setGuardInfo(cell, guard)
    -- 头像
    local image = self:getControl("PortraitImage", Const.UIImage, cell)
    local imgPath = ResMgr:getSmallPortrait(guard:queryBasicInt("icon"))
    image:loadTexture(imgPath)
    self:setItemImageSize("PortraitImage", cell)

    -- 名称
    local nameLabel = self:getControl("NameLabel", Const.UILabel, cell)
    nameLabel:setString(guard:queryBasic("name"))

    -- 等级
    local levelLabel = self:getControl("LevelLabel", Const.UILabel, cell)
    levelLabel:setString(CHS[2000015] .. guard:queryBasic("level"))

    local function touch(sender, eventType)
         if ccui.TouchEventType.ended == eventType then
            self:addSelcetImage(cell, "GuardCheckBox")

            local sendInfo = string.format("{\t%s=%s=%s}", guard:queryBasic("raw_name"), CHS[6000162],  guard:queryBasicInt('id'))
            local showInfo = string.format("{\t%s\t}", guard:queryBasic("raw_name"))
            self:callBack("addCardInfo", sendInfo, showInfo)
         end
    end

    cell:addTouchEventListener(touch)
end

function LinkDlg:getTaskList()
    local taskList = {}
    for k, v in pairs(TaskMgr.tasks) do
        table.insert(taskList,  v)
    end

    return taskList
end

function LinkDlg:setTaskInfo(cell, task)
    -- 名称
    local nameLabel = self:getControl("NameLabel", Const.UILabel, cell)
    nameLabel:setString(task["show_name"])

    local function touch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            self:addSelcetImage(cell, "TaskCheckBox")

            local sendInfo = string.format("{\t%s=%s=%s}", task["task_type"], CHS[6000163],  task["task_type"])
            local showInfo = string.format("{\t%s\t}", task["show_name"])
            self:callBack("addCardInfo", sendInfo, showInfo)
        end
    end

    cell:addTouchEventListener(touch)
end

function LinkDlg:getSkillList()
    local skillList = {}
    local id = Me:getId()
    local phySkill = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_J)
    if phySkill then
        table.insert(skillList, phySkill[1])
    end

    local bSkill = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_B)
    if bSkill then
        for k,v in pairs(bSkill) do
            table.insert(skillList, v)
        end
    end

    local cSKill = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_C)
    if cSKill then
        for k,v in pairs(cSKill) do
            table.insert(skillList, v)
        end
    end

    local dSkill = SkillMgr:getSkillNoAndLadder(id, SKILL.SUBCLASS_D)
    if dSkill then
        for k,v in pairs(dSkill) do
            table.insert(skillList, v)
        end
    end

    return skillList
end

function LinkDlg:setSkillInfo(cell, skill)
    -- 技能图片
    local image = self:getControl("ItemImage", Const.UIImage, cell)
    local path = SkillMgr:getSkillIconPath(skill.no)
    image:loadTexture(path)
    self:setItemImageSize("ItemImage", cell)

    local function touch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            self:addSelcetImage(cell, "SkillCheckBox")
            local sendInfo = string.format("{\t%s=%s=%s}", SkillMgr:getSkillName(skill.no), CHS[6000164],  skill.no)
            local showInfo = string.format("{\t%s\t}", SkillMgr:getSkillName(skill.no))
            self:callBack("addCardInfo", sendInfo, showInfo)
        end
    end

    cell:addTouchEventListener(touch)
end


function LinkDlg:getTitleList()
    local titleList = {}
    local titleNum = Me:queryBasicInt("title_num")
    for i = 1, titleNum do
        local title  = {}
        title["title"] = Me:queryBasic(string.format("title%d", i))
        title["type"] = Me:queryBasic(string.format("type%d", i))
        if title["title"] ~= "" and title["type"] ~= "" then
            table.insert(titleList, title)
        end
   end

    return titleList
end

function LinkDlg:setTitleInfo(cell, title)
    -- 名称
    local nameLabel = self:getControl("NameLabel", Const.UILabel, cell)
    nameLabel:setString(CharMgr:getChengweiShowName(title["title"]))

    local function touch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            self:addSelcetImage(cell, "TitleCheckBox")

            local sendInfo = string.format("{\t%s=%s=%s}", title["title"], CHS[6000165],  title["type"])
            local showInfo = string.format("{\t%s\t}", title["title"])
            self:callBack("addCardInfo", sendInfo, showInfo)
        end
    end

    cell:addTouchEventListener(touch)
end

function LinkDlg:cleanup()
    self:releaseCloneCtrl("itemCell")
    self:releaseCloneCtrl("petCell")
    self:releaseCloneCtrl("guardCell")
    self:releaseCloneCtrl("taskCell")
    self:releaseCloneCtrl("skillCell")
    self:releaseCloneCtrl("titleCell")

    for k,v in pairs(Config_Data) do
        if self[k] and self[k].selectImage then
            self[k].selectImage:removeFromParent()
            self[k].selectImage = nil
        end
    end
end

return LinkDlg
