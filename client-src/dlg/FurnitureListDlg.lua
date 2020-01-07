-- FurnitureListDlg.lua
-- Created by yangym Jun/19/2017
-- 点击家具弹出的悬浮框

local FurnitureListDlg = Singleton("FurnitureListDlg", Dialog)

local MARGIN = 5

function FurnitureListDlg:init()
    self:bindListener("FurnitureButton", self.onFurnitureButton)

    self.button = self:getControl("FurniturePanel")
    self.button:retain()

    self.changeList = {}
    self:hookMsg("MSG_ENTER_ROOM")
end

function FurnitureListDlg:setInfo(type, data, touch, menus)
    if touch then
        self.touchPos = touch:getLocation()
    end

    if type == "furniture" then
        self:setCtrlVisible("SinglePanel", true)
        self:setCtrlVisible("ListPanel", false)
        self.char = data
        self:initShowText(data, menus)
    elseif type == "furnitureList" then
        self:setCtrlVisible("ListPanel", true)
        self:setCtrlVisible("SinglePanel", false)
        self.charList = data
        self:initCharList()
    end
end

-- 添加新的按钮
function FurnitureListDlg:addShowTextList(list)
    local button = self:getControl("FurnitureButton")
    local x, y = button:getPosition()
    local buttonSize = button:getContentSize()
    local singlePanel = self:getControl("SinglePanel", nil)
    local singleSize = singlePanel:getContentSize()
    local totalHeight = singleSize.height
    local cou = #list
    button:setPosition(x, y + (buttonSize.height + 5) * cou)
    for i = 1, cou do
        local cell = button:clone()
        cell:setTitleText(list[i].text)
        cell:setPosition(x, y + (buttonSize.height + 5) * (cou - i))
        cell.flag = list[i].flag
        totalHeight = totalHeight + buttonSize.height + 5
        singlePanel:addChild(cell)
    end

    singlePanel:setContentSize(singleSize.width, totalHeight)
end

function FurnitureListDlg:initShowText(char, menus)
    local furnitureType = char:queryBasic("furniture_type")
    local button = self:getControl("FurnitureButton")
    local name = char:queryBasic("name")
    if furnitureType == CHS[7002320] then
        -- 我要休息
        button:setTitleText(CHS[5410074])
        button.flag = "oneSleep"
        if name == CHS[5420207] or name == CHS[5420208] then
            -- 我们要休息
            self:addShowTextList({
                [1] = {text = CHS[5410152], flag = "weSleep"},
                [2] = {text = CHS[5450478], flag = "weSleepEx"}
            })
        end
    elseif furnitureType == CHS[5410072] then
        if name == CHS[5400111] then
            button:setTitleText(CHS[5400117])
        elseif char:queryBasic("name") == CHS[7190000] then -- 金丝鸟笼
            button:setTitleText(CHS[7190000])
        elseif char:queryBasic("name") == CHS[2500061] then -- 演武木桩
            button:setTitleText(CHS[2500061])
        elseif name == CHS[2100214] then    -- 宠物小屋
            local furnInfo = HomeMgr:getFurnitureInfo(name)
            local showText = furnInfo.touchFloatText
            button:setTitleText(showText)
        elseif name == CHS[4010392] then    -- 天地灵石
            button:setTitleText(menus[1])

            if #menus > 1 then
                local uData = {}
                for i = 2, #menus do
                    table.insert( uData, {text = menus[i], flag = menus[i]} )
                end

                self:addShowTextList(uData)
            end


        else
            button:setTitleText(CHS[5410073])   -- 饲养宠物
        end
    elseif furnitureType == CHS[4100686] then    -- 房屋-功能
        if string.match(name, CHS[4100675]) then
            button:setTitleText(CHS[4100687])
        elseif string.match(name, CHS[2000384]) then
            button:setTitleText(CHS[2000385])
        elseif name == CHS[7100000] or name == CHS[7100001] then
            button:setTitleText(CHS[7100002])
        elseif char:queryBasic("name") == CHS[7190001] then -- 白玉观音像
            button:setTitleText(CHS[7190003])
        elseif char:queryBasic("name") == CHS[7190002] then -- 七宝如意
            button:setTitleText(CHS[7190002])
        elseif char:queryBasic("name") == CHS[4010428] then -- 摇篮
            button:setTitleText(CHS[4010429])
            self:addShowTextList({
                [1] = {text = CHS[4010430], flag = CHS[4010430]},
                [2] = {text = CHS[4010431], flag = CHS[4010431]}
            })
        else
            button:setTitleText(CHS[4100688])
        end

    else
        local furnInfo = HomeMgr:getFurnitureInfo(name)
        local showText = furnInfo.touchFloatText
        button:setTitleText(showText or "")
    end
end

function FurnitureListDlg:initCharList()
    if not self.charList then
        return
    end

    local mainPanel = self:getControl("ListPanel")
    mainPanel:removeAllChildren()
    local charList = self.charList
    local buttonNum = #charList
    local buttonHeight = self.button:getContentSize().height
    local totalHeight = buttonNum * (buttonHeight + MARGIN) + 2 * MARGIN
    local originY = self.button:getPositionY()
    mainPanel:setContentSize(mainPanel:getContentSize().width, totalHeight)
    for i = 1, #charList do
        local button = self.button:clone()
        local name = charList[i]:queryBasic("name")
        local icon = HomeMgr:getFurnitureIcon(name)
        self:setImage("IconImage", ResMgr:getItemIconPath(icon), button)
        self:setLabelText("NameLabel", name, button)
        button:setPosition(button:getPositionX(), originY + (i - 1) * (buttonHeight + MARGIN))
        button:setTag(i)
        local function touch(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:close()
                local tag = sender:getTag()
                local char = charList[tag]
                if HomeMgr:isCanClickFurniture(char) and self.touchPos then
                    char:onClickFurniture(self.touchPos)
                end
            end
        end

        button:addTouchEventListener(touch)
        mainPanel:addChild(button)
    end
end

function FurnitureListDlg:onFurnitureButton(sender)
    if not self.char then
        return
    end
    local char = self.char
    local id = char:getId()
    local furn = HomeMgr:getFurnitureById(id)
    if not furn then
        gf:ShowSmallTips(CHS[4200431])
        ChatMgr:sendMiscMsg(CHS[4200431])
        self:onCloseButton()
        return
    elseif furn.curX ~= char.curX or furn.curY ~= char.curY then
        gf:ShowSmallTips(CHS[4200418])
        ChatMgr:sendMiscMsg(CHS[4200418])
        self:onCloseButton()
        return
    end

    if sender.flag == "weSleep" then
        HomeMgr:setBedroomSleepInfo(2, 1)
    elseif sender.flag == "oneSleep" then
        HomeMgr:setBedroomSleepInfo(1, 1)
    elseif sender.flag == "weSleepEx" then
        HomeMgr:setBedroomSleepInfo(2, 2)
    elseif sender:getTitleText() == CHS[4010393] then
        HomeMgr:setLSClickType(CHS[4010393])
    elseif sender:getTitleText() == CHS[4010427] then
        HomeMgr:setLSClickType(CHS[4010427])
    elseif sender:getTitleText() == CHS[4010430] then
        HomeMgr:setLSClickType(CHS[4010430])
    end

    -- 点击“我要休息”、“饲养宠物”后，走向家具（床），然后打开界面
    -- 详见AutoWalkMgr:doAutoWalkEnd()
    char:startAutoWalk()

    self:close()
end

function FurnitureListDlg:cleanup()
    self:releaseCloneCtrl("button")
end

function FurnitureListDlg:MSG_ENTER_ROOM(data)
    self:onCloseButton()
end

return FurnitureListDlg
