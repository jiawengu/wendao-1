-- RewardContainer.lua
-- Created by zhengjh Mar/11/2015
-- 显示奖励

local CONFIG_DATA =
{
    [CHS[6000041]] = "", -- 金元宝
    [CHS[6000042]] = "", -- 银元宝
    [CHS[6000078]] = "", -- 物品
    [CHS[6000079]] = "", -- 宠物
}

local CONST_DATA =
{
    CellHeight = 44,
    CellWidth = 246,
    LineSpace = 5,
    ColunmSpace = 7,
    Colunm = 2, -- 小图标用的列数（上下滑）
    Space = 10, -- 悬浮框 图片和文字的间隔
    WordWidth = 200, -- 最大文本宽度
    Line = 1, -- 大图标用的行数（左右滑）
    BigCellHeight = 74,
    BigCellWidth = 74,
}

-- #rNum 该格式表示数量的类型表
local DISPLAY_AMOUNT_TYPE = {
    [CHS[6000078]] = 1,             -- 物品
    [CHS[6200002]] = 1,             -- 变身卡
    [CHS[3001096]] = 1,             -- 超级黑水晶
    [CHS[3001114]] = 1,             -- 天书
    [CHS[3002169]] = 1,             -- 未鉴定
    [CHS[3002170]] = 1,             -- 装备
    [CHS[3002234]] = 1,             -- 首饰
    [CHS[4300255]] = 1,             -- 充值好礼
    [CHS[5420176]] = 1,             -- 家具
    [CHS[4100655]] = 1,             -- 时装
    [CHS[5420251]] = 1,             -- 聊天头像框
    [CHS[5420252]] = 1,             -- 聊天底框
    [CHS[2200077]] = 1,             -- 跟随小精灵
    [CHS[2200073]] = 1,             -- 特殊角色特效

    [CHS[5400438]] = 1,             -- 空间头像
    [CHS[5400439]] = 1,             -- 空间装饰
    [CHS[5450185]] = 1,             -- 首饰精华
    [CHS[5400801]] = 1,             -- 灵尘
    [CHS[4200798]] = 1,             -- 娃娃修炼道具

}

local MARGIN = 10
local SKILL_NUM = {
    [0] = "",
    [1] = CHS[3002140],
    [2] = CHS[3002141],
    [3] = CHS[3002142],
}

local REWAR_DESC =
{
    [CHS[3002143]] = CHS[3002144],
    [CHS[3002145]] = CHS[3002146],
    [CHS[3002147]] = CHS[3002148], -- 道行
    [CHS[3002149]] = CHS[3002150], -- 武学
    [CHS[5400594]] = CHS[5400595], -- 道武
    [CHS[3002151]] = CHS[3002152], -- 潜能
    [CHS[3002153]] = CHS[3002154],
    [CHS[3002155]] = CHS[3002156],
    [CHS[3002157]] = CHS[3002158],
    [CHS[3002159]] = CHS[3002160],
    [CHS[3002161]] = CHS[3002162],
    [CHS[3002163]] = CHS[3002164],
    [CHS[6000260]] = CHS[6000261],
    [CHS[4300075]] = CHS[4300077],
    [CHS[7000282]] = CHS[7000283],
    [CHS[7000284]] = CHS[7000285],
    [CHS[4200315]] = CHS[4200317],
    [CHS[4200316]] = CHS[4200318],
    [CHS[5450185]] = CHS[5450184],
    [CHS[5400801]] = CHS[5400802],  -- 灵尘
    [CHS[7100257]] = CHS[7100258],
    [CHS[5420304]] = CHS[5420306],
    [CHS[7190229]] = CHS[7190230],
    [CHS[7190534]] = CHS[7190535],
    [CHS[7190523]] = CHS[7190593],
    [CHS[7190524]] = CHS[7190594],
    [CHS[7190525]] = CHS[7190595],
    [CHS[7190526]] = CHS[7190596],
    [CHS[7190527]] = CHS[7190597],

    [CHS[4101247]] = CHS[4101253], -- 上月道行  道行是中洲世界修行者寻仙问道最本质的追求，该奖励仅增加上月道行。
    [CHS[4101248]] = CHS[4101254],
    [CHS[4101249]] = CHS[4101255],

    [CHS[4101250]] = CHS[4101256],
    [CHS[4101251]] = CHS[4101257],
    [CHS[4101252]] = CHS[4101258],
    [CHS[4200712]] = CHS[4200713],  -- 娃娃亲密度    -- 亲密度是抚养者与娃娃亲密程度的证明。
}

local ARTIFACT_SPSKILL =
{
    "diandao_qiankun",  -- 颠倒乾坤
    "jingangquan",      -- 金刚圈
    "wuji_bifan",       -- 物极必反
    "tianyan",          -- 天眼
    "chaofeng",         -- 嘲讽
    "qinmi_wujian",     -- 亲密无间
}


local ITEMNAME_UI_ICONPATH =
{
        [CHS[5420179]] = ResMgr.ui.shiwu1,
        [CHS[5420189]] = ResMgr.ui.shiwu2,
        [CHS[5420180]] = ResMgr.ui.shiwu3,
        [CHS[5420190]] = ResMgr.ui.shiwu4,
        [CHS[5420181]] = ResMgr.ui.shiwu5,
        [CHS[5420182]] = ResMgr.ui.shiwu6,
        [CHS[5420191]] = ResMgr.ui.shiwu7,
        [CHS[5420183]] = ResMgr.ui.shiwu8,
        [CHS[5420192]] = ResMgr.ui.shiwu9,
        [CHS[5420184]] = ResMgr.ui.shiwu10,
        [CHS[5420193]] = ResMgr.ui.shiwu11,
        [CHS[5420185]] = ResMgr.ui.huafei,
        [CHS[5420186]] = ResMgr.ui.shiwu12,
        [CHS[5420196]] = ResMgr.ui.shiwu13,
        [CHS[5420288]] = ResMgr.ui.huafei100,
        [CHS[5420289]] = ResMgr.ui.shiwu14,
        [CHS[5420290]] = ResMgr.ui.shiwu15,
        [CHS[5420291]] = ResMgr.ui.shiwu16,
        [CHS[5420292]] = ResMgr.ui.shiwu17,
        [CHS[5420293]] = ResMgr.ui.shiwu18,
        [CHS[5420294]] = ResMgr.ui.shiwu19,
        [CHS[5420295]] = ResMgr.ui.shiwu20,
        [CHS[8000014]] = ResMgr.ui.shiwu21,
        [CHS[8000015]] = ResMgr.ui.shiwu22,
        [CHS[8000016]] = ResMgr.ui.shiwu23,
        [CHS[8000017]] = ResMgr.ui.shiwu24,
        [CHS[8000018]] = ResMgr.ui.shiwu25,
}

local RewardContainer = class("RewardContainer", function()
    return ccui.Layout:create()
end)

RewardContainer.parentScale = 1

-- str 奖励字符串
-- contentSize 面板大小
-- defaultColor 需要改变面板的默认，要设置这个值
-- obj 需要的回调的对象
--  isBigIcon 表示是否用大图标排版（默认小图标），左右滑动
---- isBigIcon现在主要给大图用， 小图标基本两列 ，上下滑动
-- notAddScrollView 为True时，不增加scoreview
function RewardContainer:ctor(str, contentSize, defaultColor, obj, isBigIcon, margin, notAddScrollView, parentScale)
    local classList = TaskMgr:getRewardList(str)
    self:setContentSize(contentSize)
    self.defaultColor = defaultColor or COLOR3.TEXT_DEFAULT
    self.obj = obj
    self.imgCtrls = {}   -- 保存图片控件，由于置灰处理

    self.parentScale = parentScale or 1   -- 父节点的缩放数值

    local contentLayer = ccui.Layout:create()
    local totalHight = 0
    local width = 0
    if isBigIcon then -- 大图标没有标题
        if #classList > 0 then
            local cell = self:createOneBigIconContent(classList[1], margin)
            totalHight = totalHight + cell:getContentSize().height + CONST_DATA.ColunmSpace
            width = cell:getContentSize().width
            contentLayer:addChild(cell)
        end

        if totalHight > CONST_DATA.ColunmSpace then
            totalHight = totalHight - CONST_DATA.ColunmSpace
        end

        contentLayer:setContentSize(width, totalHight)

        if width < contentSize.width then
            -- WDSY-34014 修改
            contentSize.width = width
            self:setContentSize(contentSize)
        end
    else
        for i = #classList,  1, -1 do
            local cell
            if classList[i]["isClass"] then
                cell = self:createOneTitle(classList[i]["class"])
            else
                cell = self:createOneContent(classList[i], margin)
                width = cell:getContentSize().width
            end
            cell:setPosition(0, totalHight)
            cell:setAnchorPoint(0, 0)
            totalHight = totalHight + cell:getContentSize().height + CONST_DATA.ColunmSpace
            contentLayer:addChild(cell)
        end

        if totalHight > CONST_DATA.ColunmSpace then
            totalHight = totalHight - CONST_DATA.ColunmSpace
        end

        contentLayer:setContentSize(contentSize.width, totalHight)
    end

    if notAddScrollView then
        self:addChild(contentLayer)
    else
        local scroview = ccui.ScrollView:create()
        scroview:setContentSize(contentSize)
        scroview:addChild(contentLayer)
        scroview:setInnerContainerSize(contentLayer:getContentSize())
        scroview:setTouchEnabled(true)
        self:addChild(scroview)

        if isBigIcon then
            scroview:setDirection(ccui.ScrollViewDir.horizontal)
        else
            scroview:setDirection(ccui.ScrollViewDir.vertical)
            if totalHight <= scroview:getContentSize().height then
                contentLayer:setPositionY(scroview:getContentSize().height  - totalHight)
            else
                self:callBack("addMagicIcon")
            end

            local  function scrollListener(sender , eventType)
                if eventType == ccui.ScrollviewEventType.scrolling then
                    local  y = scroview:getInnerContainer():getPositionY()
                    if y < 0 then
                        self:callBack("addMagicIcon")
                    else
                        self:callBack("removeMagicIcon")
                    end
                end
            end

            scroview:addEventListener(scrollListener)
        end
    end
end

function RewardContainer:createOneTitle(title)
    -- 奖励文本描述
    local lableText = CGAColorTextList:create()
    local width = self:getContentSize().width
    lableText:setFontSize(19)
    lableText:setContentSize(width - MARGIN, 30)
    lableText:setString(title)
    lableText:setDefaultColor(self.defaultColor.r, self.defaultColor.g, self.defaultColor.b)

    lableText:updateNow()

    -- 一行的高度大概 25
    local _, height = lableText:getRealSize()
    lableText:setPosition(MARGIN, height + 5)
    local colorTextLayout = tolua.cast(lableText, "cc.LayerColor")

    local layout = ccui.Layout:create()
    layout:addChild(colorTextLayout)
    layout:setContentSize(width, height + 5)
    return layout
end

function RewardContainer:createOneContent(rewardList, margin)
    local layout = ccui.Layout:create()
    local line = math.floor(#rewardList / CONST_DATA.Colunm)
    local left = #rewardList % CONST_DATA.Colunm

    if left ~= 0 then
        line = line + 1
    end

    margin = margin or CONST_DATA.ColunmSpace

    local curColunm = 0
    local totalHeight = line * (CONST_DATA.CellHeight + CONST_DATA.LineSpace) - CONST_DATA.LineSpace
    local totalWidth = 0

    if line == 1  and left ~= 0 then
        totalWidth = left * (CONST_DATA.CellWidth + margin)

    else
        totalWidth = CONST_DATA.Colunm * (CONST_DATA.CellWidth + margin)
    end

    for i = 1, line do
        if i == line and left ~= 0 then
            curColunm = left
        else
            curColunm = CONST_DATA.Colunm
        end

        for j = 1, curColunm do
            local cell = ccui.Layout:create()
            cell:setContentSize(CONST_DATA.CellWidth,CONST_DATA.CellHeight)
            cell:setTouchEnabled(true)
            cell:setAnchorPoint(0, 1)
            --imageLayout:setBackGroundImage(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
            local x = (j - 1) * (CONST_DATA.CellWidth + margin)
            local y = totalHeight - (i - 1) * (CONST_DATA.CellHeight + CONST_DATA.LineSpace)
            cell:setPosition(x, y)
            self:setCellData(cell, rewardList[(i - 1)* CONST_DATA.Colunm + j])
            layout:addChild(cell, 0, i)
        end
    end

    layout:setContentSize(totalWidth, totalHeight)

    return layout
end

function RewardContainer:createOneBigIconContent(rewardList, margin)
    local layout = ccui.Layout:create()
    local colunm = math.floor(#rewardList / CONST_DATA.Line)
    local left = #rewardList % CONST_DATA.Line

    if left ~= 0 then
        colunm = colunm + 1
    end

    margin = margin or CONST_DATA.ColunmSpace

    local curLine= 0
    local totalHeight = CONST_DATA.Line * (CONST_DATA.BigCellHeight + CONST_DATA.LineSpace) - CONST_DATA.LineSpace
    local totalWidth = colunm * (CONST_DATA.BigCellWidth + margin)  - margin


    for i = 1, colunm do
        if i == colunm and left ~= 0 then
            curLine = left
        else
            curLine = CONST_DATA.Line
        end

        for j = 1, curLine do
            local cell = ccui.Layout:create()
            cell:setContentSize(CONST_DATA.BigCellWidth,CONST_DATA.BigCellHeight)
            cell:setTouchEnabled(true)
            cell:setAnchorPoint(0, 1)
            cell:setBackGroundImage(ResMgr.ui.bag_item_bg_img, ccui.TextureResType.plistType)
            local x = (i - 1) * (CONST_DATA.BigCellWidth + margin )
            local y = totalHeight - (j - 1) * (CONST_DATA.BigCellHeight + CONST_DATA.LineSpace)
            cell:setPosition(x, y)
            self:setBigCellData(cell, rewardList[(i - 1)* CONST_DATA.Line + j])
            layout:addChild(cell, 0, i)
        end
    end

    layout:setContentSize(totalWidth, totalHeight)

    return layout
end

function RewardContainer:imagePanelTouch(sender, eventType)
    local reward = sender.reward
    if not reward then return end
    if ccui.TouchEventType.ended == eventType then
        local rect = self:getBoundingBoxInWorldSpace(sender)
        rect.height = rect.height * self.parentScale
        rect.width = rect.width * self.parentScale
        if reward[1] == CHS[6000078] or reward[1] == CHS[3000059] then       -- 道具

            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local item = TaskMgr:spliteItemInfo(itemInfoList)
            if string.match(item["name"], ".+=(F)") then  -- 不是具体的道具
                self:showCommonReward(sender, reward)
            else
                local dlg = DlgMgr:openDlg("ItemInfoDlg")

                -- WDSY-13676中删除
                if item.name == CHS[5410026] then item.name = CHS[6400035] end

                -- WDSY-18128 中改名
                if item.name == CHS[5410028] then item.name = CHS[6400034] end
                if item.name == CHS[5410029] then item.name = CHS[6400035] end

                -- WDSY-23067 中改名
                if item.name == CHS[5400202] then item.name = CHS[5400196] end

                -- WDSY-27344 中改名
                if item.name == CHS[4100230] then item.name = CHS[5440003] end
                if item.name == CHS[4100234] then item.name = CHS[5440004] end

                item["isGuard"] = InventoryMgr:getIsGuard(item.name)
                dlg:setInfoFormCard(item)
                dlg:setFloatingFramePos(rect)
            end
        elseif reward[1] == CHS[7000144] then -- 法宝
            if string.match(reward[2], ".+=(F)") then  -- 不是具体的法宝
                self:showCommonReward(sender, reward)
            else
                if string.match(reward[2], "$id=") then
                    -- 由于奖励格式没有其他信息，所以只显示简单的奖励悬浮框
                    self:showCommonReward(cell, reward)
                else
                    local artifact = self:buildArtifact(reward[2])
                    InventoryMgr:showArtifact(artifact ,rect, true)
                end
            end
        elseif reward[1] == CHS[6200002] then -- 变身卡
            self:showChangeCard(sender, reward)
        elseif reward[1] == CHS[3002169] then  -- 未鉴定
            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local itemInfo = TaskMgr:spliteItemInfo(itemInfoList)

            if string.match(itemInfoList[1], ".+=(T)") then
                local item = {}
                item.item_type = ITEM_TYPE.EQUIPMENT
                item.unidentified = 1
                item.name = itemInfo["name"] or ""
                item.level = itemInfo["level"] or 0
                item.req_level = itemInfo["level"] or 0
                item.limted = itemInfo.limted
                item.unidentified = 1
                item.color = CHS[3004104]

                local ItemInfo = InventoryMgr:getItemInfoByName(item.name)
                if ItemInfo and ItemInfo.req_level then
                    item.req_level = ItemInfo.req_level
                end

                -- InventoryMgr:showBasicMessageDlg(item, rect)
                local dlg = DlgMgr:openDlg("ItemInfoDlg")
                dlg:setInfoFormCard(item)
                dlg:setFloatingFramePos(rect)
            else
                -- 不需要弹出悬浮框
                self:showCommonReward(sender, reward)
            end
        elseif reward[1] == CHS[3002174] then   -- 超级黑水晶
            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local item = self:buildItemForHSJ(itemInfoList)

            local dlg = DlgMgr:openDlg("ItemInfoDlg")
            dlg:setInfoFormCard(item)
            dlg:setFloatingFramePos(rect)
        elseif reward[1] == CHS[4100655] then   -- 时装
            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local item = TaskMgr:spliteItemInfo(itemInfoList, reward)

            InventoryMgr:showFashioEquip(item, rect, true)
        elseif reward[1] == CHS[5420176] then   -- 家具
            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local item = TaskMgr:spliteItemInfo(itemInfoList, reward)
            local furn = HomeMgr:getFurnitureInfo(item.name)
            if string.match(item["name"], ".+=(F)") or not furn then  -- 不是具体的家具
                self:showCommonReward(sender, reward)
            else
                item.item_type = ITEM_TYPE.FURNITURE
                InventoryMgr:showItemByItemData(item, rect)
            end
        elseif TaskMgr:isAboutMajorR(reward[1]) then   -- 聊天头像框、聊天底框、特殊角色特效、空间头像、空间装饰
            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local item = TaskMgr:spliteItemInfo(itemInfoList, reward)

            local dlg = DlgMgr:openDlg("ItemInfoDlg")
            dlg:setInfoFormCard(item)
            dlg:setFloatingFramePos(rect)
        else
            -- 不需要弹出悬浮框
            self:showCommonReward(sender, reward)
        end
    end
end

function RewardContainer:setBigCellData(cell, reward)
    local function imagePanelTouch(sender, eventType)
        self:imagePanelTouch(sender, eventType)
    end

    cell:addTouchEventListener(imagePanelTouch)
    cell.reward = reward

    -- 奖励图片
    local imgPath,textureResType = self:getRewardPath(reward)
    local iconImg = ccui.ImageView:create(imgPath, textureResType)
    iconImg:setPosition(cell:getContentSize().width / 2, cell:getContentSize().height / 2)
    iconImg:setAnchorPoint(0.5, 0.5)
    gf:setItemImageSize(iconImg)
    cell:addChild(iconImg)

    if self.imgCtrls then
        table.insert(self.imgCtrls, iconImg)
    end

    local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
    local item = TaskMgr:spliteItemInfo(itemInfoList, reward)


    if DISPLAY_AMOUNT_TYPE[reward[1]] and item.number and tonumber(item.number) > 1 and item.name ~= CHS[3002145] then
        Dialog.setNumImgForPanel(nil, cell, ART_FONT_COLOR.NORMAL_TEXT, item.number, false, LOCATE_POSITION.RIGHT_BOTTOM, 19)
    end

    if reward[1] == CHS[7000144] then
        item = self:buildArtifact(reward[2])
    end

    if reward[1] == CHS[3002169] then
        InventoryMgr:addLogoUnidentified(iconImg)
    end

    -- 加上限时或者限制交易图标
    if item and item["time_limited"] then
        InventoryMgr:addLogoTimeLimit(iconImg)
    elseif item and item["limted"] then
        InventoryMgr:addLogoBinding(iconImg)
    end

    -- 法宝
    if reward[1] == CHS[7000144] then
        -- 法宝相性
        if item["item_polar"] then
            InventoryMgr:addArtifactPolarImage(iconImg, item["item_polar"])
        end
    end

    if item["level"] and tonumber(item["level"]) > 0 then
        Dialog.setNumImgForPanel(nil, iconImg, ART_FONT_COLOR.NORMAL_TEXT, item.level, false, LOCATE_POSITION.LEFT_TOP, 19)
    end
end

-- 显示变身卡名片
function RewardContainer:showChangeCard(cell, reward)
    reward[2] = string.gsub(reward[2],"$%d+","")
    local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
    local item = TaskMgr:spliteChangeCardInfo(itemInfoList)
    if string.match(item["name"], ".+=(F)") then  -- 不是具体变身卡
        self:showCommonReward(cell, reward)
    else
        local dlg = DlgMgr:openDlg("ChangeCardInfoDlg")
        item.icon = PetMgr:getPetIcon(item.name)
        dlg:setInfoFromItem(item, true)
        local rect = self:getBoundingBoxInWorldSpace(cell)
        dlg:setFloatingFramePos(rect)
    end
end


-- 构建一个黑水晶
function RewardContainer:buildItemForHSJ(itemInfoList)
    local item = {}
    item.name = itemInfoList[1]
    item.level = tonumber(string.sub(itemInfoList[2], 2, -1))
    item.req_level = item.level
    item.upgrade_type = tonumber(string.sub(itemInfoList[3], 2, -1))
    item.extra = {}

    local field = string.sub(itemInfoList[4], 2, -1)
    local value
    if itemInfoList[5] == "$max" then
        value = EquipmentMgr:getAttribMaxValueByField(item, field)
    elseif itemInfoList[5] == "$min" then
        value = EquipmentMgr:getAttribMinValueByField(item, field)
    elseif itemInfoList[5] == "$std" then
        value = EquipmentMgr:getAttribStdValueByField(item, field)
    else
        -- 具体数值 itemInfoList[5] == "$10000" 格式
        value = tonumber(string.sub(itemInfoList[5], 2, -1))
        local max = EquipmentMgr:getAttribMaxValueByField(item, field)
        if value > max then value = max end

        local min = EquipmentMgr:getAttribMinValueByField(item, field)
        if value < min then value = min end
    end

    -- 限时/限制交易字段配置
    for i = 1, #itemInfoList do
        if string.match(itemInfoList[i], "%%bind") then
            item["limted"] = true
            if string.match(itemInfoList[i], "%%bind=(.*)") then
                item["gift"] = - tonumber(string.match(itemInfoList[i], "%%bind=(.*)")) - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
            else
                item["gift"] = 2
            end
        elseif string.match(itemInfoList[i], "%%deadline") then
            item["time_limited"] = true --为限时物品
            item["deadline"] = gf:convertStrToTime(string.match(itemInfoList[i], "%%deadline=(.*)"))
            item["isTimeLimitedReward"] = true

            -- 限时必为永久限制交易
            item["gift"] = 2
            item["limted"] = true
        end
    end

    item.extra[field .. "_2"] = value
    return item
end

-- 构建一个法宝
function RewardContainer:buildArtifact(rewardStr)
    local artifact = {
        intimacy = 0,
        exp = 0
    }

    local hasLevelAlready = false
    local artifactInfoList = gf:splitBydelims(rewardStr, {"%", "$"})

    for i = 1, #artifactInfoList do
        if string.match(artifactInfoList[i], "%%bind") then
            --限制交易属性
            artifact["limted"] = true
            if string.match(artifactInfoList[i], "%%bind=(.*)") then
                artifact["gift"] = - tonumber(string.match(artifactInfoList[i], "%%bind=(.*)")) - (gf:getServerTime() + Const.DELAY_TIME_BALANCE)
            else
                artifact["gift"] = 2
            end
        elseif string.match(artifactInfoList[i], "%%deadline") then
            -- 限时属性
            artifact["time_limited"] = true
            artifact["deadline"] = gf:convertStrToTime(string.match(artifactInfoList[i], "%%deadline=(.*)"))
            artifact["isTimeLimitedReward"] = true

            -- 限时必为永久限制交易
            artifact["gift"] = 2
            artifact["limted"] = true
        elseif string.match(artifactInfoList[i], "$friendliness=(.*)") then
            -- 亲密度
            artifact["intimacy"] = tonumber(string.match(artifactInfoList[i], "$friendliness=(.*)"))
        elseif string.match(artifactInfoList[i], "$spskill=(.*)") then
            -- 法宝特殊技能
            local skillNo = tonumber(string.match(artifactInfoList[i], "$spskill=(.*)"))
            artifact["extra_skill"] = ARTIFACT_SPSKILL[skillNo]
        elseif string.match(artifactInfoList[i], "$spskillLV=(.*)") then
            -- 法宝特殊技能等级
            artifact["extra_skill_level"] = tonumber(string.match(artifactInfoList[i], "$spskillLV=(.*)"))
        elseif string.match(artifactInfoList[i], "$(%d)") then
            -- 为等级/相性
            if hasLevelAlready then
                artifact.item_polar = tonumber(string.match(artifactInfoList[i], "$(.+)"))
            else
                artifact.level = tonumber(string.match(artifactInfoList[i], "$(.+)"))
                hasLevelAlready = true
            end
        elseif string.match(artifactInfoList[i], "$id=") then
            -- id客户端不关心，所以不需要处理
        elseif string.match(artifactInfoList[i], "$nimbus=") then
            artifact["nimbus"] = tonumber(string.match(artifactInfoList[i], "$nimbus=(.*)"))
        elseif string.match(artifactInfoList[i], "$exp=") then
            artifact["exp"] = tonumber(string.match(artifactInfoList[i], "$exp=(.*)"))
        else
            local name = artifactInfoList[i]
            if string.match(name, ".+=(F)") then
                name = string.match(name, "(.+)=F")
            end

            artifact["name"] = artifactInfoList[i]
        end
    end

    if artifact.level then
        artifact.exp_to_next_level = 30 * math.pow(artifact.level, 5) + 300 * math.pow(artifact.level, 3) + 1500

        if artifact.exp >= artifact.exp_to_next_level then
            artifact.exp = artifact.exp_to_next_level - 1
        end

        -- 默认当前灵气为灵气上限值
        local maxNimbus = Formula:getArtifactMaxNimbus(artifact.level)
        if not artifact["nimbus"] then
            artifact.nimbus = maxNimbus
        end

        if artifact.nimbus > maxNimbus then
            artifact.nimbus = maxNimbus
        end
    end

    -- 默认法宝特殊技能等级为1级
    if artifact.extra_skill and not artifact.extra_skill_level then
        artifact.extra_skill_level = 1
    end

    return artifact
end

function RewardContainer:setCellData(cell, reward)
    local function imagePanelTouch(sender, eventType)
        if ccui.TouchEventType.ended == eventType then
            local rect = self:getBoundingBoxInWorldSpace(sender)
            rect.height = rect.height * self.parentScale
            rect.width = rect.width * self.parentScale
            if reward[1] == CHS[6000078] or reward[1] == CHS[3000059] then       -- 道具
                local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
                local item = TaskMgr:spliteItemInfo(itemInfoList)
                if string.match(item["name"], ".+=(F)") then  -- 不是具体的道具
                    self:showCommonReward(cell, reward)
                else

                    local dlg = DlgMgr:openDlg("ItemInfoDlg")
                    dlg:setInfoFormCard(item)
                    dlg:setFloatingFramePos(rect)
                end
            elseif reward[1] == CHS[7000144] then -- 法宝
                if string.match(reward[2], ".+=(F)") then  -- 不是具体的法宝
                    self:showCommonReward(cell, reward)
                else
                    local artifact = self:buildArtifact(reward[2])
                    InventoryMgr:showArtifact(artifact ,rect, true)
                end
            elseif reward[1] == CHS[6200002] then -- 变身卡
                self:showChangeCard(cell, reward)
            elseif reward[1] == CHS[3002169] then
                local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
                local itemInfo = TaskMgr:spliteItemInfo(itemInfoList)

                if string.match(itemInfo["name"], ".+=(T)") then
                    local item = {}
                    item.item_type = ITEM_TYPE.EQUIPMENT
                    item.unidentified = 1
                    item.name = string.gsub(itemInfo["name"],"=T","")
                    item.level = itemInfo["level"] or 0
                    item.req_level = itemInfo["level"] or 0
                    item.limted = itemInfo.limted
                    item.color = CHS[3004104]

                    -- InventoryMgr:showBasicMessageDlg(item, rect)
                    local dlg = DlgMgr:openDlg("ItemInfoDlg")
                    dlg:setInfoFormCard(item)
                    dlg:setFloatingFramePos(rect)
                else
                    -- 不需要弹出悬浮框
                    self:showCommonReward(cell, reward)
                end
            elseif reward[1] == CHS[5420176] then   -- 家具
                local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
                local item = TaskMgr:spliteItemInfo(itemInfoList, reward)
                local furn = HomeMgr:getFurnitureInfo(item.name)
                if string.match(item["name"], ".+=(F)") or not furn then  -- 不是具体的家具
                    self:showCommonReward(sender, reward)
                else
                    item.item_type = ITEM_TYPE.FURNITURE
                    InventoryMgr:showItemByItemData(item, rect)
                end
            elseif reward[1] == CHS[4100655] then       -- 时装
                local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
                local item = TaskMgr:spliteItemInfo(itemInfoList, reward)

                InventoryMgr:showFashioEquip(item, rect, true)
            elseif TaskMgr:isAboutMajorR(reward[1]) then   -- 聊天头像框、聊天底框、特殊角色特效、空间头像、空间装饰
                local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
                local item = TaskMgr:spliteItemInfo(itemInfoList, reward)

                local dlg = DlgMgr:openDlg("ItemInfoDlg")
                dlg:setInfoFormCard(item)
                dlg:setFloatingFramePos(rect)
            else
                -- 不需要弹出悬浮框
                self:showCommonReward(cell, reward)
            end
        end
    end

    cell:addTouchEventListener(imagePanelTouch)

    -- 奖励图片
    local imgPath = self:getSamllImage(reward[1])
    local iconImg = ccui.ImageView:create(imgPath, ccui.TextureResType.plistType)
    iconImg:setPosition(0, cell:getContentSize().height / 2)
    iconImg:setAnchorPoint(0, 0.5)
    table.insert(self.imgCtrls, iconImg)
    cell:addChild(iconImg)

    gf:setSmallRewardImageSize(iconImg)
    -- 道具增加数量显示
  --[[  if reward[1] == CHS[6000078] or reward[1] == "未鉴定" then
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList)

        if item["number"] ~= nil and tonumber(item["number"]) > 1 then
            -- 道具数量
            Dialog.setNumImgForPanel(nil, cell, ART_FONT_COLOR.NORMAL_TEXT, item.number,
                                     false, LOCATE_POSITION.RIGHT_BOTTOM, 21)
        end

        -- 等级数字图片
        local level = tonumber(item.level)
        if level and level > 0 then
            Dialog.setNumImgForPanel(nil, cell, ART_FONT_COLOR.NORMAL_TEXT, level,
                                     false, LOCATE_POSITION.LEFT_TOP, 19)
        end

        if item["bind"] == true then
            InventoryMgr:addLogoBinding(iconImg)
        end

    end]]

    -- 奖励文本描述
    local descStr = self:getRewardDesc(reward)
    local text = ccui.Text:create()
    text:setColor(self.defaultColor)
    text:setAnchorPoint(0, 0.5)
    text:setPosition(iconImg:getContentSize().width + 1, cell:getContentSize().height / 2)
    text:setString(descStr)
    text:setFontSize(19)
    cell:addChild(text)
end

function RewardContainer:getRewardInfo(reward)
    local rewardInfo = {}
    rewardInfo.imagePath, rewardInfo.resType= self:getRewardPath(reward)
    rewardInfo.basicInfo = self:getTextList(reward)
    rewardInfo.desc = rewardInfo.basicInfo[1] and REWAR_DESC[rewardInfo.basicInfo[1]] or REWAR_DESC[reward[1]]
    rewardInfo.time_limited, rewardInfo.time_limitedStr = TaskMgr:isTimeLimited(reward[2])
    if rewardInfo.time_limited then
        -- 如果是限时，肯定是限制交易永久
        rewardInfo.limted, rewardInfo.limitedStr = TaskMgr:isLimited("%bind")
    else
        rewardInfo.limted, rewardInfo.limitedStr = TaskMgr:isLimited(reward[2])
    end


    return rewardInfo
end

function RewardContainer:showCommonReward(cell, reward)
   --[[ local rect = self:getBoundingBoxInWorldSpace(cell)
    local dlg = DlgMgr:openDlg("RewardShowInfoDlg")
    local showContainer = self:createRewardCell(reward)
    dlg.root:addChild(showContainer)
    dlg.root:setContentSize(showContainer:getContentSize().width + CONST_DATA.Space * 2, showContainer:getContentSize().height + CONST_DATA.Space * 2)
    showContainer:setPosition(dlg.root:getContentSize().width / 2, dlg.root:getContentSize().height / 2)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)]]

    local rect = self:getBoundingBoxInWorldSpace(cell)
    rect.height = rect.height * self.parentScale
    rect.width = rect.width * self.parentScale

    local rewardInfo = self:getRewardInfo(reward)
    local dlg
    if rewardInfo.desc then
        dlg = DlgMgr:openDlg("BonusInfoDlg")
    else
        dlg = DlgMgr:openDlg("BonusInfo2Dlg")
    end

    dlg:setRewardInfo(rewardInfo)
    dlg.root:setAnchorPoint(0, 0)
    dlg:setFloatingFramePos(rect)
end

function RewardContainer:createRewardCell(reward)
    local layout = ccui.Layout:create()
    layout:setAnchorPoint(0.5, 0.5)

    -- 加载奖励图标
    local imgPath,textureResType = self:getRewardPath(reward)
    local iconImg = ccui.ImageView:create(imgPath, textureResType)
    iconImg:setAnchorPoint(0, 1)
    gf:setItemImageSize(iconImg)
    layout:addChild(iconImg)


    if reward[1] == CHS[3002170] or reward[1] == CHS[3002168] or  reward[1] == CHS[3002169]  or reward[1] == CHS[3002172] or reward[1] == CHS[3002166] then
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList)

        -- 加限时或者限制交易标识
        if item and item["time_limited"] then
            InventoryMgr:addLogoTimeLimit(iconImg)
        elseif item and item["limted"] then
            InventoryMgr:addLogoBinding(iconImg)
        end
    end

    if reward[1] == CHS[7000144] then  -- 法宝
        local item = self:buildArtifact(reward[2])

        -- 加限时或者限制交易标识
        if item and item["time_limited"] then
            InventoryMgr:addLogoTimeLimit(iconImg)
        elseif item and item["limted"] then
            InventoryMgr:addLogoBinding(iconImg)
        end
    end

    if  reward[1] == CHS[3002172] then
        if  string.match(reward[2], "$Valid") then
            InventoryMgr:addLogoTimeLimit(iconImg)
        elseif string.match(reward[2], "%%bind") then
            InventoryMgr:addLogoBinding(iconImg)
        end
    end


    -- 加载文字
    local textList = self:getTextList(reward)
    local textLayout = ccui.Layout:create()
    local textMaxWidth = 0
    local innerHeight = 0
    local colorListTable = {}

    for i = #textList, 1, -1  do
        if reward[1] == CHS[6000080] and  i == 2 then -- 金钱
            textList[i] = gf:getMoneyDesc(tonumber(textList[i]))
        end

        local lableText = CGAColorTextList:create()
        lableText:setFontSize(18)
        lableText:setString(textList[i])
        lableText:setContentSize(CONST_DATA.WordWidth, 0)
        lableText:updateNow()
        local labelW, labelH = lableText:getRealSize()
        local colorLayer = tolua.cast(lableText, "cc.LayerColor")
        colorLayer:setAnchorPoint(0, 0)
        colorLayer:setPosition(0, innerHeight)
        textLayout:addChild(colorLayer)
        innerHeight = innerHeight + labelH
        table.insert(colorListTable, colorLayer)

        if textMaxWidth < labelW then
            textMaxWidth = labelW
        end

        if reward[1] == CHS[3002170] then
            lableText:setDefaultColor(textList["color"].r, textList["color"].g, textList["color"].b)
        else
            lableText:setDefaultColor(COLOR3.TEXT_DEFAULT.r, COLOR3.TEXT_DEFAULT.g, COLOR3.TEXT_DEFAULT.b)
        end
    end

    textLayout:setContentSize(textMaxWidth, innerHeight)
    textLayout:setAnchorPoint(0, 0.5)
    layout:addChild(textLayout)

    for i = 1,#colorListTable do
        local lableText = tolua.cast(colorListTable[i], "CGAColorTextList")
        local x,y = colorListTable[i]:getPosition()
        local labelW, labelH = lableText:getRealSize()
        colorListTable[i]:setPosition((textMaxWidth-labelW) / 2, y)
    end

    local height = 0

    if iconImg:getContentSize().height > innerHeight then
        height = iconImg:getContentSize().height
    else
        height = innerHeight
    end

    iconImg:setPosition(0, height)
    textLayout:setPosition(iconImg:getContentSize().width + CONST_DATA.Space, height / 2)
    layout:setContentSize(iconImg:getContentSize().width + textMaxWidth + CONST_DATA.Space, height)

    return layout
end

-- 获取指定 node 在屏幕坐标系中的区域
function RewardContainer:getBoundingBoxInWorldSpace(node)
    if not node then
        return
    end

    local rect = node:getBoundingBox()
    local pt = node:convertToWorldSpace(cc.p(0, 0))
    rect.x = pt.x
    rect.y = pt.y

    return rect
end

-- 获取奖励图片路径
function RewardContainer:getRewardPath(reward)
    local imgPath = ""
    local textureResType = ccui.TextureResType.plistType

    if reward[1] == CHS[6000079] then       -- 宠物
        local isRidePet = false
        local rank = string.match(reward[2], ".+%((.+)%).*")
        if rank == CHS[6000519] or rank == CHS[6000520] then
            isRidePet = true
        end

        if string.match(reward[2], ".+=(F)") then  -- 不是具体的宠物
            if isRidePet then
                imgPath = ResMgr.ui["ride_pet_common"]
            else
                imgPath = ResMgr.ui["pet_common"]
            end
        else
            -- WDSY-27344 中改名
            reward[2] = string.gsub(reward[2], CHS[6000310], CHS[5440001])
            reward[2] = string.gsub(reward[2], CHS[6000324], CHS[5440002])

            local content = gf:split(reward[2], "(")
            imgPath = ResMgr:getSmallPortrait(PetMgr:getPetIcon(content[1]))
            textureResType = ccui.TextureResType.localType
        end
    elseif reward[1] == CHS[6000078] or reward[1] == CHS[3000059] then   -- 道具
        if string.match(reward[2], ".+=(F)") then  -- 不是具体的道具
            imgPath = ResMgr.ui["item_common"]
        else
            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local item = TaskMgr:spliteItemInfo(itemInfoList)

            -- WDSY-13676中删除
            if item.name == CHS[5410026] then item.name = CHS[6400035] end

            -- WDSY-18128 中改名
            if item.name == CHS[5410028] then item.name = CHS[6400034] end
            if item.name == CHS[5410029] then item.name = CHS[6400035] end

            local icon = InventoryMgr:getIconByName(item.name)
            if InventoryMgr:getIsGuard(item.name) then
                imgPath = ResMgr:getSmallPortrait(icon)
            else
                imgPath = ResMgr:getItemIconPath(icon)
            end

            textureResType = ccui.TextureResType.localType
        end
    elseif reward[1] == CHS[7000144] then -- 法宝
        if string.match(reward[2], ".+=(F)") then
            imgPath = ResMgr.ui["big_artifact"]
        else
            local artifact = self:buildArtifact(reward[2])
            local icon = InventoryMgr:getIconByName(artifact.name)
            imgPath = ResMgr:getItemIconPath(icon)

            textureResType = ccui.TextureResType.localType
        end
    elseif reward[1] == CHS[6000041]  then  -- 金元宝
        imgPath = ResMgr.ui["big_gold"]
    elseif reward[1] == CHS[6000042] then   -- 银元宝
        imgPath = ResMgr.ui["big_yinyuanbao"]
    elseif reward[1] == CHS[6000080] then   -- 金钱
        imgPath = ResMgr.ui["big_cash"]
    elseif reward[1] == CHS[3002145] then -- 代金券
        imgPath = ResMgr.ui["voucher"]
    elseif reward[1] == CHS[6000081] then   -- 经验
        imgPath = ResMgr.ui["experience"]
    elseif reward[1] == CHS[3000049] then   -- 道行
        imgPath = ResMgr.ui["daohang"]
    elseif reward[1] == CHS[3000050] then   -- 武学
        imgPath = ResMgr.ui["big_wuxue"]
    elseif reward[1] == CHS[5400594] then
        imgPath = ResMgr.ui["big_tao_wu"]
    elseif reward[1] == CHS[4300075] then   -- 刷道积分
        imgPath = ResMgr.ui["shuadao_jifen"]
    elseif reward[1] == CHS[3002151] then
        imgPath = ResMgr.ui["pot_icon"]
    elseif reward[1] == CHS[7000282] then
        imgPath = ResMgr.ui["big_daofa"]
    elseif reward[1] == CHS[7000284] then
        imgPath = ResMgr.ui["big_ziqihongmeng"]
    elseif reward[1] == CHS[3002169] or  reward[1] == CHS[3002168] or reward[1] == CHS[3002170] then -- 首饰、未鉴定
        if string.match(reward[2],".+=(T)") then -- 能匹配到具体
            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local item = TaskMgr:spliteItemInfo(itemInfoList)
            item.name = string.gsub(item["name"],"=T","")
            local icon = InventoryMgr:getIconByName(item.name)
            imgPath = ResMgr:getItemIconPath(icon)
            textureResType = ccui.TextureResType.localType
        else
            if reward[1] == CHS[3002169]  then
                imgPath = ResMgr.ui["big_identify_equip"]
            elseif reward[1] == CHS[3002168] then
                imgPath = ResMgr.ui["big_jewelry"]
            elseif reward[1] == CHS[3002170] then
                imgPath = ResMgr.ui["big_equip"]
            end
        end
    elseif reward[1] == CHS[3002171] or reward[1] == CHS[4100818] then
        imgPath = ResMgr.ui["title"]
    elseif reward[1] == CHS[3002157] then
        imgPath = ResMgr.ui["big_banggong"]
    elseif reward[1] == CHS[3002159] then
        imgPath = ResMgr.ui["big_party_active"]
    elseif reward[1] == CHS[3002163] then
        imgPath = ResMgr.ui["big_reputation"]
    elseif reward[1] == CHS[3002161] then
        imgPath = ResMgr.ui["big_party_contribution"]
    elseif reward[1] == CHS[3002173] then
        imgPath = ResMgr.ui["reward_big_VIP"]
    elseif reward[1] == CHS[3002174] then
        imgPath = ResMgr:getIconPathByName(CHS[3002174])
        textureResType = ccui.TextureResType.localType
    elseif reward[1] == CHS[6000222] then
        imgPath = ResMgr.ui["jdong_card"]
    elseif reward[1] == CHS[6400008] then -- 充值好礼
        imgPath = ResMgr.ui["get_reward_icon"]
    elseif reward[1] == CHS[6200002] then -- 变身卡
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteChangeCardInfo(itemInfoList)

        if string.match(reward[2], ".+=(F)") then  -- 不是具体的变身卡
            imgPath = ResMgr.ui["big_change_card"]
        else
            local icon = InventoryMgr:getIconByName(item.name)
            imgPath = ResMgr:getItemIconPath(icon)
            textureResType = ccui.TextureResType.localType
        end
    elseif reward[1] == CHS[6000260] then -- 友好度
        imgPath = ResMgr.ui["big_friendly_icon"]
    elseif reward[1] == CHS[6400052] then -- 技能
        imgPath = ResMgr.ui["big_skill_icon"]
    elseif reward[1] == CHS[6200024] then -- 离线时间
        imgPath = ResMgr.ui["big_off_line_time"]
    elseif reward[1] == CHS[5420113] then -- 纯金玫瑰
        imgPath = ResMgr.ui["big_gold_rose"]
    elseif reward[1] == CHS[4200315] then --
        imgPath = ResMgr.ui.huiguiScore
    elseif reward[1] == CHS[4200316] then --召回
        imgPath = ResMgr.ui.zhaohuiScore
    elseif reward[1] == CHS[2000244] then -- 相性上限
        imgPath = ResMgr.ui["big_polar_upper"]
    elseif reward[1] == CHS[2000245] then -- 等级上限
        imgPath = ResMgr.ui["big_level_upper"]
    elseif reward[1] == CHS[4100655] then -- 时装
        -- 资源暂无
        -- imgPath = ResMgr.ui["reward_big_fashion"] 这是随机时装，目前暂无
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList, reward)
        local icon = InventoryMgr:getIconByName(item["name"])
        imgPath = ResMgr:getItemIconPath(icon)
        textureResType = ccui.TextureResType.localType
    elseif TaskMgr:isAboutMajorR(reward[1]) then   -- 聊天头像框、聊天底框、特殊角色特效、空间头像、空间装饰
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList, reward)
        local icon = InventoryMgr:getIconByName(item["name"])
        imgPath = ResMgr:getItemIconPath(icon)
        textureResType = ccui.TextureResType.localType
    elseif reward[1] == CHS[5420169] then -- 实物
        local itemInfoList = gf:splitBydelims(reward[2], {"#r"})
        local icon = ITEMNAME_UI_ICONPATH[itemInfoList[1]]
        if icon then
            imgPath = icon
            textureResType = ccui.TextureResType.localType
		else
            imgPath = ResMgr.ui["big_object_reward"]
        end
    elseif reward[1] == CHS[5420170] then -- 话费
        local itemInfoList = gf:splitBydelims(reward[2], {"#r"})
        local icon = ITEMNAME_UI_ICONPATH[itemInfoList[1]]
        if icon then
            imgPath = icon
            textureResType = ccui.TextureResType.localType
        else
            imgPath = ResMgr.ui["big_call_cost_reward"]
        end
    elseif reward[1] == CHS[7100152] then -- 属性点数
        imgPath = ResMgr.ui["big_attrib_point"]
    elseif reward[1] == CHS[7100153] then -- 相性点数
        imgPath = ResMgr.ui["big_polar_point"]
    elseif reward[1] == CHS[4010118] then -- 仙魔点
        imgPath = ResMgr.ui["big_xianmo_point"]
    elseif reward[1] == CHS[5450185] then
        imgPath = ResMgr.ui["big_jewelry_essence"]
    elseif reward[1] == CHS[5400801] then
        imgPath = ResMgr.ui["big_item_lingchen"]
        textureResType = ccui.TextureResType.localType
    elseif reward[1] == CHS[5420304] then  -- 宠风散点数
        imgPath = ResMgr.ui["big_chongfengsan"]
    elseif reward[1] == CHS[7100257] then
        imgPath = ResMgr.ui["big_inn_coin"]
    elseif reward[1] == CHS[7190229] then
        imgPath = ResMgr.ui["big_tan_an_score"]
    elseif reward[1] == CHS[4200712] then
        imgPath = ResMgr.ui["small_child_qinmidu"]
    elseif reward[1] == CHS[7190534] then
        imgPath = ResMgr.ui["big_qinmidu"]
    elseif reward[1] == CHS[7190592] then -- 探索材料
        imgPath = PetExploreTeamMgr:getMaterialIconByName(reward[2])
        textureResType = ccui.TextureResType.localType
    elseif reward[1] == CHS[7120211] then
        imgPath = ResMgr.ui["big_wawazizhi"]
    elseif reward[1] == CHS[5420176] then -- 家具
        if string.match(reward[2], ".+=(F)") then  -- 不是具体的家具
            imgPath = ResMgr.ui["item_common"]
        else
            local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
            local item = TaskMgr:spliteItemInfo(itemInfoList, reward)

            local icon = HomeMgr:getFurnitureIcon(item.name)
            if not icon then
                imgPath = ResMgr.ui["item_common"]
            else
                imgPath = ResMgr:getItemIconPath(icon)
                textureResType = ccui.TextureResType.localType
            end
        end
    else
        imgPath = ResMgr.ui["others_icon"]  -- 没有匹配类型(其他)
    end
    return imgPath,textureResType
end


-- 获取通用文本行数
function RewardContainer:getTextList(reward)
    local textList = {}

    if reward[1] == CHS[6000079] then   --宠物
        if string.match(reward[2], ".+=(F)") then  -- 不是具体的宠物
            textList[1] = string.match(reward[2], "(.+)=F.*")

            local petName, petRank, skillNum = string.match(textList[1], "(.+)%((.+)%).*$.*$(.).*")

            -- 如果无法获取相关信息，说明此为补偿宠物（解析格式不同）
            if not petName then
                petName, petRank = string.match(reward[2], "(.+)%((.+)%)")
            end

            if petName then
                textList[1] = petName
            end

        else
            local petName, petRank, skillNum = string.match(reward[2], "(.+)%((.+)%).*$.*$(.).*")

            -- 如果无法获取相关信息，说明此为补偿宠物（解析格式不同）
            if not petName then
                petName, petRank = string.match(reward[2], "(.+)%((.+)%)")
            end

            skillNum = tonumber(skillNum)
            if nil == skillNum then
                skillNum = 0
            end

            textList[1] = string.format("%s%s", SKILL_NUM[skillNum], petName)
            textList[2] = string.format("(%s)", petRank)
        end
    elseif reward[1] == CHS[7000144] then  -- 法宝
        if string.match(reward[2], ".+=(F)") then
            textList[1] = string.match(reward[2], "(.+)=F.*")
        else
            local artifact = self:buildArtifact(reward[2])
            textList[1] = artifact.name
        end
    elseif reward[1] == CHS[6200002] then -- 变身卡
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteChangeCardInfo(itemInfoList)
        textList[1] = string.match(item["name"], "(.+)=F.*") or item["name"]
    elseif reward[1] == CHS[6000082] then  -- 其他
        textList[1] = reward[2]
    elseif reward[1] == CHS[3002168] or reward[1] == CHS[3002169] or reward[1] == CHS[3002170]  then
        local itemInfoList =  gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList)
        textList[1] = item["name"]
        textList["color"] = item["color"]
        --textList[2] = item["number"]
    elseif reward[1] == CHS[3002171] or reward[1] == CHS[4100818] then -- 称谓  成就
        textList = gf:split(reward[2], "#r")
        local content = gf:split(textList[1], "$")
        textList[1] = content[1]
        if textList[2] then
            local content2 = gf:split(textList[2], "$")
            textList[2] = content2[1]
        end
    elseif reward[1] == CHS[3002166] then
        local itemInfoList =  gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList)
        textList[1] = item["name"]
        textList[1] = string.gsub(textList[1], "=F","")
    elseif reward[1] == CHS[3002173] then
        textList[1] = string.match(reward[2], "(.*)$Time=%d+")
        if textList[1] then
            textList[1] = gf:replaceVipStr(textList[1])
            local pos = gf:findStrByByte(reward[2], "$Time=")
            if nil ~= pos then
                textList[2] = string.sub(reward[2], pos + 6, -1) .. CHS[3002175]
            else
                -- 如果数据错误
                gf:ShowSmallTips(CHS[3002176])
                textList[2] = CHS[3002177]
            end
        else
            textList[1] = gf:replaceVipStr(reward[2])
        end
    elseif reward[1] == CHS[6000041] then -- 金元宝(A+B)
        textList = gf:split(reward[2], "#r")
        if string.match(textList[2], "(%d+)+(%d+)") then
            local A,B = string.match(textList[2], "(%d+)+(%d+)")
            textList[2] = tonumber(A) + tonumber(B)
        end
    elseif reward[1] == CHS[6000260] then -- 友好度
        local list =  gf:splitBydelims(reward[2], {"$", "#r"})
        local friendlyInfo = TaskMgr:spliteFriendlyInfo(list)
        textList[1] = friendlyInfo["name"]
        textList[2] = friendlyInfo["number"]
    elseif reward[1] == CHS[6200024] then -- 离线时间
        textList = gf:split(reward[2], "#r")
        if textList[2] then
            local time = tonumber(textList[2])
            textList[2] = SystemMessageMgr:getTimeStr(time)
        end
    elseif reward[1] == CHS[3000059] then
        textList[1] = string.match(reward[2], "(.+)=F.*") or reward[2]
    elseif reward[1] == CHS[5420176] then -- 家具
        local list =  gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local str = string.match(list[1], "(.+)=F.*")
        if not str then
            str = list[1]
        end

        textList[1] = str
    elseif reward[1] == CHS[3002147] then -- 道行
        textList = gf:split(reward[2], "#r")
        if textList[2] then
            textList[2] = gf:getTaoStr(tonumber(textList[2]), 0)
        end
    else
        textList = gf:split(reward[2], "#r")
    end

    return textList
end

-- 获取小图标
function RewardContainer:getSamllImage(name)
    return TaskMgr:getSamllImage(name)
end

-- 获取所有奖励的描述
function RewardContainer:getRewardDesc(reward)
    local descStr = ""
    if reward[1] == CHS[6000079] then       -- 宠物
        if string.match(reward[2], ".+=(F)") then  -- 不是具体的宠物
            descStr = string.match(reward[2], "(.+)=F.*")
        else
            descStr = string.match(reward[2], "(.+%(.+%)).*")
        end
    elseif reward[1] == CHS[7000144] then  -- 法宝
        if string.match(reward[2], ".+=(F)") then
            descStr = string.match(reward[2], "(.+)=F.*")
        else
            local artifact = self:buildArtifact(reward[2])
            descStr = artifact.name
        end
    elseif reward[1] == CHS[6200002] then -- 变身卡
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteChangeCardInfo(itemInfoList)
        descStr =  string.match(item["name"], "(.+)=F.*") or item["name"]
    elseif reward[1] == CHS[3002166] or reward[1] == CHS[3002170] or reward[1] == CHS[3002168] or reward[1] == CHS[3002169] then   -- 道具类
        local itemInfoList = gf:splitBydelims(reward[2], {"$", "%", "#r"})
        descStr =  itemInfoList[1]

        -- 如果该奖励有别名，需要显示别名
        if itemInfoList[2] and string.match(itemInfoList[2], "$Alias=") then
            descStr = string.match(itemInfoList[2], "$Alias=(.+)")
        end

        if reward[1] == CHS[3002170] or reward[1] == CHS[3002168] or reward[1] == CHS[3002169]  then
            descStr = string.gsub(descStr,"=T","")
        elseif reward[1] == CHS[3002166] then
            descStr = string.gsub(descStr,"=F","")
        end
    elseif reward[1] == CHS[3002171] or reward[1] == CHS[4100818] then
        local textList = gf:split(reward[2], "#r")
        local content = gf:split(textList[1], "$")
        descStr = content[1]..(textList[2] or "")
    elseif reward[1] == CHS[3002173] then
        descStr = string.match(reward[2], "(.*)$Time=%d+") or descStr
    elseif reward[1] == CHS[6000260] then -- 友好度
        local list =  gf:splitBydelims(reward[2], {"$", "#r"})
        local friendlyInfo = TaskMgr:spliteFriendlyInfo(list)

        if friendlyInfo["number"] then
            descStr = friendlyInfo["name"] .. "*" .. friendlyInfo["number"]
        else
            descStr = friendlyInfo["name"]
        end
    elseif reward[1] == CHS[5420176] then -- 家具
        local list =  gf:splitBydelims(reward[2], {"%", "$", "#r"})
        descStr = string.match(list[1], "(.+)=F.*")
        if not descStr then
            descStr = list[1]
        end
    elseif reward[1] == CHS[5000280] then -- 时装
        local list =  gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(list, reward)
        descStr = item["name"]
    elseif TaskMgr:isAboutMajorR(reward[1]) then   -- 聊天头像框、聊天底框、特殊角色特效、空间头像、空间装饰
        local itemInfoList = gf:splitBydelims(reward[2], {"%", "$", "#r"})
        local item = TaskMgr:spliteItemInfo(itemInfoList, reward)
        descStr = item["name"]
    else
        -- 替换#r 为*
        descStr = string.gsub(reward[2],"#r","*")
    end

    return descStr
end

-- 回调函数
function RewardContainer:callBack(funcName, ...)
    if not self.obj then  return end
    local func = self.obj[funcName]
    if self.obj and func then
         func(self.obj, ...)
    end
end

-- 邮件已领取的奖品要置灰
function RewardContainer:grayAllReward()
    for i = 1, #self.imgCtrls do
        gf:grayImageView(self.imgCtrls[i])
    end
end

function RewardContainer:grayOneReward(rewardName)
    for i = 1, #self.imgCtrls do
        local reward = self.imgCtrls[i]:getParent().reward
        if reward and reward[2] and string.match(reward[2], rewardName) then
            gf:grayImageView(self.imgCtrls[i])
        end
    end
end

-- 重置置灰图片
function RewardContainer:resetAllReward()
    for i = 1, #self.imgCtrls do
        gf:resetImageView(self.imgCtrls[i])
    end
end

return RewardContainer
