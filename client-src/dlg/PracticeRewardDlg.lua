-- PracticeRewardDlg.lua
-- Created by zhengjh Mar/6/2015
-- 扫荡奖励

local PracticeRewardDlg = Singleton("PracticeRewardDlg", Dialog)

local SWEEPTIMELIMIT = 10 -- 扫荡次数

local CONST_DATA =
{
    [1] =  CHS[6000055],
    [2] =  CHS[6000056],
    [3] =  CHS[6000057],
    [4] =  CHS[6000058],
    [5] =  CHS[6000059],
    [6] =  CHS[6000060],
    [7] =  CHS[6000061],
    [8] =  CHS[6000062],
    [9] =  CHS[6000063],
    [10] = CHS[6000064],
    RewardCellNumber = 10,
    ContainerTag = 999,
    RewardCellLineSpace = 20, -- 每场奖励之间的间隔
    DropGoodsColumnNumber = 5,
    DropGoodsLineSpace = 5, -- 掉落物品的行间隔
    DropGoodsColumnSpace = 10, --掉落物品的列间隔
    PracticeLimitTimes = 100,
}

function PracticeRewardDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("AgainButton", self.onAgainButton)

    self.rewardCell = self:getControl("RewardPanel", Const.UIPanel)

    -- 保留每场战斗cell 用来克隆
    self.rewardMainPanel = self:getControl("RewardMainPanel", Const.UIPanel)
    self.rewardCell:retain()

    -- 保留掉落物品的单元格 用克隆
    self.dropPanel = self:getControl("ItemPanel1", Const.UIPanel)
    self.dropPanel:retain()

    self.rewardMainPanel:removeAllChildren()

    --  创建滑动层
    self.scrollview = ccui.ScrollView:create()
    self.scrollview:setPosition(0, 0)
    self.scrollview:setContentSize(self.rewardMainPanel:getContentSize())
    self.scrollview:setDirection(ccui.ScrollViewDir.vertical)
    self.scrollview:setTouchEnabled(true)
    self.rewardMainPanel:addChild(self.scrollview)

    local  function listViewListener(sender , eventType)
        if eventType == ccui.ScrollviewEventType.scrollToBottom then

        elseif eventType == ccui.ScrollviewEventType.scrollToTop then
            print("ccui.ScrollviewEventType.bounceTop")
        end
    end


    self.scrollview:addEventListener(listViewListener)
    self:hookMsg("MSG_UPDATE")
    self:hookMsg("MSG_AUTO_PRACTICE_BONUS")
    self:MSG_UPDATE()
    self:MSG_AUTO_PRACTICE_BONUS()
    self.isEnter = true
    self:setBtnTouch(false)

end

function PracticeRewardDlg:setMapName(name)
    self.mapName = name
end

function PracticeRewardDlg:onConfirmButton(sender, eventType)
    self:onCloseButton()
end

function PracticeRewardDlg:onAgainButton(sender, eventType)
    self:setBtnTouch(false)
    PracticeMgr:sweep(self.timesStr, self.mapName)
end

function PracticeRewardDlg:onSelectRewardListView(sender, eventType)
end

function PracticeRewardDlg:playRewardAction()
    self.scrollview:scrollToBottom(0.5,false)
end

function PracticeRewardDlg:loadCell()
    self.scrollview:removeAllChildren()
    local container = ccui.Layout:create()
    container:setPosition(0,0)
    local innerSizeheight = 0
    for j = self.loadNumber , 1, -1 do
        local rewardCell = self:createRewardCell(j)
        rewardCell:setTag(j)
        rewardCell:setAnchorPoint(0,0)
        rewardCell:setPosition(0, innerSizeheight)
        innerSizeheight = innerSizeheight + rewardCell:getContentSize().height + CONST_DATA.RewardCellLineSpace
        container:addChild(rewardCell)
    end

    self.scrollview:addChild(container,0 ,CONST_DATA.ContainerTag)

    -- 内容小于显示区域往上移
    if container:getContentSize().height + innerSizeheight < self.scrollview:getContentSize().height then
        for  i = 1 , self.loadNumber do
            local cell = container:getChildByTag(i)
            local posx, posy = cell:getPosition()
            cell:setPosition(posx, posy + self.scrollview:getContentSize().height - innerSizeheight)
        end
    end

    container:setContentSize(self.scrollview:getContentSize().width, innerSizeheight)
    self.scrollview:setInnerContainerSize(container:getContentSize())

    self:playRewardAction()
end

function PracticeRewardDlg:createRewardCell(tag)
    local reward = self.rewardList[tag]
    local rewardCell = self.rewardCell:clone()

    -- 第几场
    local timesLabel = self:getControl("CombatLabel", Const.UILabel, rewardCell)
    timesLabel:setString(string.format(CHS[6000072], tag))

    -- 人物经验
    local playerExpLabel = self:getControl("PlayerExpLabel", Const.UILabel, rewardCell)
    playerExpLabel:setString(reward["user_exp"])

    -- 宠物经验
    local petExpLabel = self:getControl("PetExpLabel", Const.UILabel, rewardCell)
    petExpLabel:setString(reward["pet_exp"])

    -- 钱币
    local cashLabel= self:getControl("CashLabel", Const.UILabel, rewardCell)
    cashLabel:setString(reward["cash"])

    -- 内容延迟显示动画
    local containPanel = self:getControl("CellContainerPanel", Const.UIPanel, rewardCell)
    if tag== self.loadNumber then
        containPanel:setVisible(false)
    end

    local func = cc.CallFunc:create(function()  containPanel:setVisible(true) end)
    local action = cc.Sequence:create(cc.DelayTime:create(0.5), func)
    rewardCell:runAction(action)

    -- 掉落物品
    local dropNumber = #reward

    local listPanel = self:getControl("ItemListPanel", Const.UIPanel, rewardCell)
    listPanel:setAnchorPoint(0,0)
    listPanel:setPosition(0,0)
    listPanel:removeAllChildren()
    local height = rewardCell:getContentSize().height - listPanel:getContentSize().height  -- 扣除list后的高度
    local line = math.floor(dropNumber / CONST_DATA.DropGoodsColumnNumber) + 1
    local left = dropNumber % CONST_DATA.DropGoodsColumnNumber
    local lineCount = 0
    local totalHeight= 0

    if left == 0 then
        totalHeight = (line - 1) * (self.dropPanel:getContentSize().height + CONST_DATA.DropGoodsLineSpace)
    else
        totalHeight = line * (self.dropPanel:getContentSize().height + CONST_DATA.DropGoodsLineSpace)
    end

    listPanel:setContentSize(listPanel:getContentSize().width, totalHeight)
    rewardCell:setContentSize(rewardCell:getContentSize().width, height + totalHeight)
    containPanel:setContentSize(rewardCell:getContentSize().width, height + totalHeight)

    for i = 1, line do
        if line == i then
            lineCount = left
        else
            lineCount = CONST_DATA.DropGoodsColumnNumber
        end

        for j = 1, lineCount do
            local dropTag = (i - 1) * CONST_DATA.DropGoodsColumnNumber + j
            local dropCellPanel = self.dropPanel:clone()
            dropCellPanel:setAnchorPoint(0, 1)
            local x = 35 + (dropCellPanel:getContentSize().width + CONST_DATA.DropGoodsColumnSpace) * (j - 1)
            local y = totalHeight - (dropCellPanel:getContentSize().height + CONST_DATA.DropGoodsLineSpace) * (i - 1)
            self:createDropCell(dropCellPanel, self.rewardList[tag][dropTag], dropTag)
            dropCellPanel:setPosition(x, y)
            listPanel:addChild(dropCellPanel)
        end
    end

    return rewardCell
end

-- 掉落物品单元格
function PracticeRewardDlg:createDropCell(cell, data, tag)
    if tag == 1 and data["baby_name"] ~= "" and data["baby_name"] ~= nil then
       self:createPetCell(cell, data)
    else
       self:createItemCell(cell, data)
    end
end

-- 宠物单元格
function PracticeRewardDlg:createPetCell(cell, pet)
    local imgPath = ResMgr:getSmallPortrait(PetMgr:getPetIcon(pet["baby_name"]))
    local iconImg = ccui.ImageView:create(imgPath)
    iconImg:setPosition(cell:getContentSize().width / 2, cell:getContentSize().height / 2)
    gf:setItemImageSize(iconImg)
    cell:addChild(iconImg)

    local itemCountLabel = self:getControl("NumLabel", Const.UILabel, cell)
    itemCountLabel:setVisible(false)

    self:getControl("LevelLabel", Const.UILabel, cell):setVisible(false)

end

-- 道具单元格
function PracticeRewardDlg:createItemCell(cell, item)

    -- 道具图片
    local imgPath = ResMgr:getItemIconPath(InventoryMgr:getIconByName(item["item_name"]))
    local iconImg = ccui.ImageView:create(imgPath)
    iconImg:setPosition(cell:getContentSize().width / 2, cell:getContentSize().height / 2)
    gf:setItemImageSize(iconImg)
    cell:addChild(iconImg)

    -- 道具等级
    local levelLabel = self:getControl("LevelLabel", Const.UILabel, cell)
    if item["level"] and levelLabel then
        levelLabel :setString(item["level"])
        levelLabel:setVisible(true)
    else
        levelLabel:setVisible(false)
    end

    -- 道具 数量
    local itemCountLabel = self:getControl("NumLabel", Const.UILabel, cell)
    itemCountLabel:setLocalZOrder(1)

    if item["item_num"] <= 1 then
        itemCountLabel:setVisible(false)
    else
        itemCountLabel:setString(item["item_num"])
        itemCountLabel:setVisible(true)
    end
end

function PracticeRewardDlg:onUpdate()
    if self.isEnter then
        if gfGetTickCount() - self.LastPlayActionTime > 1000 and self.loadNumber < #self.rewardList  then
           self.LastPlayActionTime = gfGetTickCount()
           self.loadNumber = self.loadNumber + 1
           self:loadCell()
        elseif self.loadNumber == #self.rewardList and self.loadNumber ~= 0 then
            self.loadNumber = 0
            self.rewardList = {}

            if PracticeMgr:packgeIsFull() == 1 then
                gf:ShowSmallTips(CHS[6000157])
            end

            if tonumber(Me:queryBasic("practice_times")) ~= 0 then
                self:setBtnTouch(true)
            else
                local confirmBtn = self:getControl("ConfirmButton", Const.UIButton)
                confirmBtn:setTouchEnabled(true)
                gf:resetImageView(confirmBtn)
            end

       end
    end
end

function PracticeRewardDlg:MSG_UPDATE()

    local sweepBtn = self:getControl("AgainButton", Const.UIButton)
    local timesLeft = tonumber(Me:queryBasic("practice_times"))
    self.timesStr = tostring(timesLeft)

    if timesLeft > SWEEPTIMELIMIT  then
        timesLeft = 10
        self.timesStr = tostring(timesLeft)
    elseif timesLeft == 0 or timesLeft < 0 then
        timesLeft = 10
        sweepBtn:setTouchEnabled(false)
    end


    sweepBtn:setTitleText(string.format(CHS[6000065], CONST_DATA[timesLeft]))

    -- 扫荡元宝数
    local goldlabel = self:getControl("GoldLabel", Const.UILabel)
    goldlabel:setString(timesLeft * PracticeMgr:getSweepGold())

    -- 练功剩余次数
    local timesLeftLabel = self:getControl("PracticeTimesLabel", Const.UILabel)
    timesLeftLabel:setString(string.format(CHS[6000045], Me:queryBasic("practice_times"), CONST_DATA.PracticeLimitTimes))
end

-- 扫荡刷新
function PracticeRewardDlg:MSG_AUTO_PRACTICE_BONUS()
    self.loadNumber = 0
    self.LastPlayActionTime = gfGetTickCount() - 1000
    self.rewardList = PracticeMgr:getRewardList()
end

function PracticeRewardDlg:cleanup()
    self:releaseCloneCtrl("rewardCell")
    self:releaseCloneCtrl("dropPanel")
end

-- 设置按钮是否可触发
function PracticeRewardDlg:setBtnTouch(enable)
    local confirmBtn = self:getControl("ConfirmButton", Const.UIButton)
    confirmBtn:setTouchEnabled(enable)
    local againBtn = self:getControl("AgainButton", Const.UIButton)
    againBtn:setTouchEnabled(enable)

    if enable then
        gf:resetImageView(confirmBtn)
        gf:resetImageView(againBtn)
    else
        gf:grayImageView(confirmBtn)
        gf:grayImageView(againBtn)
    end
end

return PracticeRewardDlg
