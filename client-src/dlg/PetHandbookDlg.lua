-- PetHandbookDlg.lua
-- Created by chenyq Jan/04/2014
-- 宠物图鉴界面

local Group = require('ctrl/RadioGroup')
local PageTag = require('ctrl/PageTag')
local GridPanel = require('ctrl/GridPanel')
local PetHandbookDlg = Singleton("PetHandbookDlg", Dialog)

-- 普遍宠物列表信息
local normalPetList = require(ResMgr:getCfgPath('NormalPetList.lua'))

-- 变异宠物列表信息
local elitePetList = require(ResMgr:getCfgPath('VariationPetList.lua'))

-- 神兽宠物列表信息
local epicPetList = require(ResMgr:getCfgPath('EpicPetList.lua'))

-- 其他宠物列表信息
local otherPetList = require(ResMgr:getCfgPath('OtherPetList.lua'))

-- 精怪宠物列表
local jingguaiPetList = require(ResMgr:getCfgPath('JingGuai.lua'))

-- 纪念宠物列表
local jinianPetList = require(ResMgr:getCfgPath("JinianPetList.lua"))

-- 目前支持的最大页数
local MAX_PAGE_NUM = 7

-- 每页显示列数、行数、总个数
local COL_PER_PAGE = 3
local ROW_PER_PAGE = 6
local NUM_PER_PAGE = COL_PER_PAGE * ROW_PER_PAGE

-- 格子的高宽
local GRID_WIDTH = 74
local GRID_HEIGHT = 74

-- 格子间的间隔
local GRID_MARGIN_WIDTH = 12.5
local GRID_MARGIN_HEIGHT = 4

-- 设置文本Margin
local TEXT_MARGIN_RIGHT = 20
local TEXT_MARGIN_BOTTOM = 15

-- 捕捉信息提示控件宽高
local CATCH_NOTE_CTRL_W = 450
local CATCH_NOTE_CTRL_H = 40

local CATCH_NOTE_FLAG = 766

-- 默认选中宝宝标签页第一只宠物
PetHandbookDlg.lastShowIdx = 1
PetHandbookDlg.showBaby = true

local PET_TYPE = {
    NORMAL = 1,
    ELITE = 2,
    EPIC = 3,
    OTHER = 4,
    JINGGUAI = 5,
    JINIAN = 6,
}

local PET_TYPE_STR = {
    [PET_TYPE.NORMAL] = CHS[3000024], --"宝宝",
    [PET_TYPE.ELITE] = CHS[3000025], -- "变异",
    [PET_TYPE.EPIC] = CHS[3003814], -- "神兽",
    [PET_TYPE.OTHER] = CHS[6000082], -- "其他",
    [PET_TYPE.JINGGUAI] = CHS[6000519], --"精怪",
    [PET_TYPE.JINIAN] = CHS[7002139], -- "纪念",
}

local STR_FORMAT = CHS[3003399]

function PetHandbookDlg:init()

    -- 绑定菜单事件
    self:bindListener("PetTypeCheckBox", function(send, eventType)
        local choseMenuPanel = self:getControl("ChoseMenuPanel", Const.UIPanel)
        local isVisible = choseMenuPanel:isVisible()
        choseMenuPanel:setVisible(not isVisible)
    end)

    PetHandbookDlg.showBaby = PET_TYPE.NORMAL
    self:setCtrlVisible("PreviewButton", false)

    -- 绑定菜单内容事件
    self:bindListener("PetsPanel", function (send, eventType)

        self:setCtrlVisible("PreviewButton", false)

        local choseMenuPanel = self:getControl("ChoseMenuPanel", Const.UIPanel)
        choseMenuPanel:setVisible(false)
        local petTypeCheckBox = self:getControl("PetTypeCheckBox", Const.UICheckBox)
        self:setLabelText("Label1", CHS[4100355])

        if self.showBaby ~= PET_TYPE.NORMAL then
            self.showBaby = PET_TYPE.NORMAL
            self:setPetList(normalPetList)
            self:setCtrlVisible("MallBuyButton", true)
            self:setCtrlVisible("MaketBuyButton", true)
            self:setCtrlVisible("CallButton", false)
            local button = self:getControl("CatchNoteButton", Const.UIButton)
            button:setVisible(true)
            self:setCtrlVisible("Label_1", true, button)
            self:setCtrlVisible("Label_2", true, button)
            self:setCtrlVisible("Label_3", false, button)
            self:setCtrlVisible("Label_4", false, button)
            self:setCtrlVisible("Label_5", false, button)
            self:setCtrlVisible("Label_6", false, button)
        end

    end)
    self:bindListener("VariationPetsPanel", function (send, eventType)
        local choseMenuPanel = self:getControl("ChoseMenuPanel", Const.UIPanel)
        choseMenuPanel:setVisible(false)
        local petTypeCheckBox = self:getControl("PetTypeCheckBox", Const.UICheckBox)
        self:setLabelText("Label1", CHS[4100356])

        self:setCtrlVisible("PreviewButton", false)

        if self.showBaby ~= PET_TYPE.ELITE then
            self.showBaby = PET_TYPE.ELITE
            self:setPetList(elitePetList)
            self:setCtrlVisible("MallBuyButton", false)
            self:setCtrlVisible("MaketBuyButton", true)
            self:setCtrlVisible("CallButton", false)
            local button = self:getControl("CatchNoteButton", Const.UIButton)
            button:setVisible(true)
            self:setCtrlVisible("Label_1", false, button)
            self:setCtrlVisible("Label_2", false, button)
            self:setCtrlVisible("Label_3", true, button)
            self:setCtrlVisible("Label_4", true, button)
            self:setCtrlVisible("Label_5", false, button)
            self:setCtrlVisible("Label_6", false, button)
        end
    end)
    self:bindListener("EpicPetsPanel", function (send, eventType)
        local choseMenuPanel = self:getControl("ChoseMenuPanel", Const.UIPanel)
        choseMenuPanel:setVisible(false)
        local petTypeCheckBox = self:getControl("PetTypeCheckBox", Const.UICheckBox)
        self:setLabelText("Label1", CHS[7190030])

        self:setCtrlVisible("PreviewButton", false)

        if self.showBaby ~= PET_TYPE.EPIC then
            self.showBaby = PET_TYPE.EPIC
            self:setPetList(epicPetList)
            self:setCtrlVisible("MallBuyButton", false)
            self:setCtrlVisible("MaketBuyButton", true)
            self:setCtrlVisible("CallButton", false)
            local button = self:getControl("CatchNoteButton", Const.UIButton)
            button:setVisible(true)
            self:setCtrlVisible("Label_1", false, button)
            self:setCtrlVisible("Label_2", false, button)
            self:setCtrlVisible("Label_3", false, button)
            self:setCtrlVisible("Label_4", false, button)
            self:setCtrlVisible("Label_5", true, button)
            self:setCtrlVisible("Label_6", true, button)
        end
    end)

    self:bindListener("OtherPetsPanel", function (send, eventType)
        local choseMenuPanel = self:getControl("ChoseMenuPanel", Const.UIPanel)
        choseMenuPanel:setVisible(false)
        local petTypeCheckBox = self:getControl("PetTypeCheckBox", Const.UICheckBox)
        self:setLabelText("Label1", CHS[4100357])

        self:setCtrlVisible("PreviewButton", false)

        if self.showBaby ~= PET_TYPE.OTHER then
            self.showBaby = PET_TYPE.OTHER
            self:setPetList(otherPetList)
            self:setCtrlVisible("MallBuyButton", false)
            self:setCtrlVisible("MaketBuyButton", true)
            self:setCtrlVisible("CatchNoteButton", false)
            self:setCtrlVisible("CallButton", false)
        end
    end)

    self:bindListener("MountPetsPanel", function (send, eventType)
        local choseMenuPanel = self:getControl("ChoseMenuPanel", Const.UIPanel)
        choseMenuPanel:setVisible(false)
        local petTypeCheckBox = self:getControl("PetTypeCheckBox", Const.UICheckBox)
        self:setLabelText("Label1", CHS[6000513])

        self:setCtrlVisible("PreviewButton", true)

        if self.showBaby ~= PET_TYPE.JINGGUAI then
            self.showBaby = PET_TYPE.JINGGUAI
            self:setPetList(jingguaiPetList)
            self:setCtrlVisible("MallBuyButton", false)
            self:setCtrlVisible("MaketBuyButton", true)
            self:setCtrlVisible("CatchNoteButton", false)
            self:setCtrlVisible("CallButton", true)
        end
    end)

    self:bindListener("JinianPetsPanel", function (send, eventType)
        local choseMenuPanel = self:getControl("ChoseMenuPanel", Const.UIPanel)
        choseMenuPanel:setVisible(false)
        local petTypeCheckBox = self:getControl("PetTypeCheckBox", Const.UICheckBox)
        self:setLabelText("Label1", CHS[7002138])

        self:setCtrlVisible("PreviewButton", false)

        if self.showBaby ~= PET_TYPE.JINIAN then
            self.showBaby = PET_TYPE.JINIAN
            self:setPetList(jinianPetList)
            self:setCtrlVisible("MallBuyButton", false)
            self:setCtrlVisible("MaketBuyButton", true)
            self:setCtrlVisible("CatchNoteButton", false)
            self:setCtrlVisible("CallButton", false)
        end
    end)

    self.curPet = {}    -- 当前选中的宠物信息
    self.showList = {}  -- 当前显示的宠物列表

    self.curPageIndex = 1
    self.pageLastSelectIndex = {[1] = 1}
    -- 初始化baby
    self:setPetList(normalPetList)

    -- 设置技能信息
    for i = 1, 3 do
        local panel = self:getControl('RawSkillPanel' .. i, Const.UIPanel)
        local img = self:getControl('RawSkillImage' .. i, Const.UIImage, panel)
        img:removeAllChildren()
        img:setVisible(false)
        self:getControl("ChosenEffectImage", Const.UIImage, panel):setVisible(false)
    end

    self:bindListener("CallButton", self.OnCallButton)
    self:setCtrlVisible("ChoseMenuPanel", false)
    self:setCtrlVisible("CallButton", false)

    self:bindListener("LeftButton", self.onLeftButton)
    self:bindListener("RightButton", self.onRightButton)
    self:onLeftButton()

    -- 点评
    self:bindListener("CommentButton", self.onCommentButton)

    -- 预览
    self:bindListener("PreviewButton", self.onPreviewButton)
    self:bindFloatPanelListener("ShowPanel")
end


-- 预览
function PetHandbookDlg:onPreviewButton(sender)
    if self.showBaby ~= PET_TYPE.JINGGUAI then return end
    if not self.curData then return end
    self:setCtrlVisible("ShowPanel", true)


        -- 设置形象
    local icon = PetMgr:getYulingIcon(self.curData.cfg.icon)
    local yulingIcon = icon
    icon = PetMgr:getMountIcon(Me:queryBasicInt("org_icon"), yulingIcon)
    local petIcon = yulingIcon


    local weapon = 0
    local orgIcon = 0


    self:setPortraitByArgList(
        {
            panelName = "PetPreViewIconPanel",
            icon = icon,
            weapon = weapon,
            root = self.root,
            showActionByClick = "walk",
            action = nil,
            clickCb = nil,
            offPos = cc.p(0, -36),
            orgIcon = orgIcon,
            syncLoad = nil,
            dir = nil,
            petIcon = petIcon,
        })
end

-- 点评
function PetHandbookDlg:onCommentButton(sender)
    if not self.curData then return end

    if not DistMgr:checkCrossDist() then return end

    local dlg = DlgMgr:openDlg("BookCommentDlg")
    dlg:setCommentObj({name = self.curData.name, icon = self.curData.cfg.icon})
end

function PetHandbookDlg:selectType(type)
	if type == "mount" then
        local choseMenuPanel = self:getControl("ChoseMenuPanel", Const.UIPanel)
        choseMenuPanel:setVisible(false)
        local petTypeCheckBox = self:getControl("PetTypeCheckBox", Const.UICheckBox)
        self:setLabelText("Label1", CHS[6000513])

        if self.showBaby ~= PET_TYPE.JINGGUAI then
            self.showBaby = PET_TYPE.JINGGUAI
            self:setPetList(jingguaiPetList)
            self:setCtrlVisible("MallBuyButton", false)
            self:setCtrlVisible("MaketBuyButton", false)
            self:setCtrlVisible("CatchNoteButton", false)
            self:setCtrlVisible("CallButton", true)
        end
	end
end

-- 显示宠物列表
function PetHandbookDlg:setPetList(petList)
    self.curPageIndex = 1
    local pageTagPanel = self:getControl("PageTagPanel")
    pageTagPanel:removeAllChildren()
    local pageView = self:getControl('PageView', Const.UIPageView)
    local contentSize = pageView:getContentSize()
    pageView:removeAllPages()

    -- 要显示的宠物的等级要求
    local meLevel = Me:queryBasicInt("level")
    local level = meLevel + 5

    -- 获取达到等级要求的宠物列表
    local len = 0
    self.showList = {}
    for name, info in pairs(petList) do
        -- 公测需要限制某些宠物的显示
        if not DistMgr:curIsTestDist() and info.needHideInPublic then
        else
            local data = {}
            data.name = name

            -- 设置要显示的文本
            data.level = tostring(info.level_req)
            if info.level_req > meLevel then
                data.textColor = COLOR3.RED
                data.grayImg = true
            end

            -- 设置要显示的图片
            data.imgFile = ResMgr:getSmallPortrait(info.icon)

            data.cfg = info

            table.insert(self.showList, data)
            len = len + 1
        end
    end

    if len == 0 then
        self:clearPetInfo()
        pageTagPanel:removeAllChildren()
        return
    end

    if self.showBaby == PET_TYPE.NORMAL then
        -- 按等级排序
        table.sort(self.showList, function(l, r)
            if l.cfg.level_req < r.cfg.level_req then return true end
            if l.cfg.level_req > r.cfg.level_req then return false end
            if l.cfg.index < r.cfg.index then return true end
            if l.cfg.index > r.cfg.index then return false end
        end)
    elseif self.showBaby == PET_TYPE.ELITE or
           self.showBaby == PET_TYPE.EPIC or
           self.showBaby == PET_TYPE.JINGGUAI or
           self.showBaby == PET_TYPE.OTHER or
           self.showBaby == PET_TYPE.JINIAN then
        table.sort(self.showList, function(l, r) return l.cfg.order < r.cfg.order end)
    end

    self.showList.count = len
    local pageNum = math.ceil(len / NUM_PER_PAGE)
    if pageNum > MAX_PAGE_NUM then
        Log:D("PetHandbookDlg:setPetList too many page")
        pageNum = MAX_PAGE_NUM
    end

    -- 设置宠物列表
    local idx = 0
    local startIndex = 1
    self.pageLastSelectIndex = {}

    for i = 1, pageNum do
        local page = GridPanel.new(contentSize.width, contentSize.height,
            ROW_PER_PAGE, COL_PER_PAGE,  GRID_WIDTH, GRID_HEIGHT, GRID_MARGIN_HEIGHT, GRID_MARGIN_WIDTH)

        -- 额外设置grid上边距
        page:setGridTop(0)
        -- 额外设置文本margin
        page:setTextMargin(TEXT_MARGIN_RIGHT, TEXT_MARGIN_BOTTOM)
        page:setData(self.showList, startIndex, function(index, sender)
            self:showPetInfo(index)
        end)
        self.page = page

        page:setSelectedGrid(1, 1)

        pageView:addPage(page)
        self.pageLastSelectIndex[i] = (i - 1) * NUM_PER_PAGE + 1
        startIndex = startIndex + NUM_PER_PAGE
    end

    pageView:requestDoLayout()

    -- 绑定分页控件和分页标签
    local pageTag = PageTag.new(pageNum)
    local tagPanelSz = pageTagPanel:getContentSize()
    pageTag:ignoreAnchorPointForPosition(false)
    pageTag:setAnchorPoint(0.5, 0)
    pageTag:setPositionX(tagPanelSz.width / 2)
    pageTagPanel:addChild(pageTag)
    self:bindPageViewAndPageTag(pageView, pageTag, self.onPageChanged)
    pageTag:setPage(1)
    performWithDelay(self.root, function()
        -- 显示选中的宠物信息
        self:showPetInfo(1)
    end, 0)
end

-- 换页面了
function PetHandbookDlg:onPageChanged(pageIdx)
    local lastSelectIndex = self.pageLastSelectIndex[pageIdx]
    self.curPageIndex = pageIdx
    self:showPetInfo(lastSelectIndex)

end

-- 显示指定宠物信息
function PetHandbookDlg:showPetInfo(idx)
    local data = self.showList[idx]
    if not data then
        return
    end

    self.lastShowIdx = idx

    local info = data.cfg
    self.curData = data

    -- 设置宠物形象
    self.curPet = info
    self:setPortrait('PetIconPanel', info.icon, 0, self.root, true)

    -- 设置相性

    self:setImagePlist("PetPolarImage", ResMgr:getPolarImagePath(info.polar), "PetPolarPanel")

    -- 设置名字
    if self.showBaby == PET_TYPE.NORMAL then
        self:setLabelText('PetNameLabel', data.name)
    else
        self:setLabelText('PetNameLabel', data.cfg.name)
    end

    -- 能力阶位
    local capacity_level = data.cfg.capacity_level
    if capacity_level then
        self:setLabelText("PetHorseLevelLabel", string.format(CHS[2000162], capacity_level))
    else
        self:setLabelText("PetHorseLevelLabel", "")
    end

    -- 携带等级
    self:setLabelText("PetLevelLabel", CHS[3003400] .. data.cfg.level_req)

    -- 设置成长信息
    local disLife, lifeUpgradeDif = self:setGrowInfo('LifeEffectLabel', info.life, 10, "life")
    local disMana, manaUpgradeDif= self:setGrowInfo('ManaEffectLabel', info.mana, 10, "mana")
    local disPhy, phyUpgradeDif= self:setGrowInfo('PhyEffectLabel', info.phy_attack, 10, "phy")
    local disMag, magUpgradeDif= self:setGrowInfo('MagEffectLabel', info.mag_attack, 10, "mag")
    local disSpeed, speedUpgradeDif= self:setGrowInfo('SpeedEffectLabel', info.speed, 5, "speed")

    local total = disLife + disMana + disPhy + disMag + disSpeed

    local totalRange = 0
    if self.showBaby ~= PET_TYPE.ELITE and self.showBaby ~= PET_TYPE.EPIC then
        -- 飞升后区间不再是固定波动（最小值和最大值的差值不再固定），要加上飞升带来的影响
        totalRange = 10 + lifeUpgradeDif +
                     10 + manaUpgradeDif +
                     10 + phyUpgradeDif +
                     10 + magUpgradeDif +
                     5 +  speedUpgradeDif
    end

    if self.showBaby == PET_TYPE.JINGGUAI or self.showBaby == PET_TYPE.JINIAN then
        -- 精怪和纪念宠没有野生，成长区间以宝宝成长区间为准
        self:setLabelText("TotalEffectLabel1", total)
    else
        self:setLabelText("TotalEffectLabel1", total - totalRange)
    end

    self:setLabelText("TotalEffectLabel3", total + totalRange)


    -- 设置技能信息
     for i = 1, 3 do
        local panel = self:getControl('RawSkillPanel' .. i, Const.UIPanel)
        local img = self:getControl('RawSkillImage' .. i, Const.UIImage, panel)
        img:removeAllChildren()
        img:setVisible(false)
        self:getControl("ChosenEffectImage", Const.UIImage, panel):setVisible(false)
    end

    local skills = info.skills or {}
    for i = 1, 3 do
        local panel = self:getControl('RawSkillPanel' .. i, Const.UIPanel)
        local img = self:getControl('RawSkillImage' .. i, Const.UIImage, panel)
        img:removeAllChildren()

        if skills[i] then
            local imgSize = img:getContentSize()
            local btn = ccui.Button:create(SkillMgr:getSkillIconFilebyName(skills[i]), SkillMgr:getSkillIconFilebyName(skills[i]), '', 0)

            btn:setAnchorPoint(0.5, 0.5)
            btn:setPosition(imgSize.width / 2, imgSize.height / 2)
            btn:setTag(i)
            gf:setItemImageSize(btn)
            img:addChild(btn)
            self:bindTouchEndEventListener(btn, self.onSkillButton)
            img:setVisible(true)
        end
    end

    -- 绑定获取事件
    self:bindListener("CatchNoteButton", function(sender, eventType)
        if self.showBaby == PET_TYPE.NORMAL then
            if Me:queryBasicInt("level") >= 15 then
                if PracticeMgr:getIsUseExorcism() then
                    gf:confirm(CHS[4300011], function()
                        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_CLOSE_EXORCISM)
                        local x, y = self:getFlyPosition(info.zoon[1])
                        if x ~= nil and y ~= nil then
                            local autoWalkStr = string.format("#Z%s|%s(%d,%d)|$1#Z", info.zoon[1], info.zoon[1], x, y)
                            AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
                        end
                        self:onCloseButton()
                    end)
                else
                    local x, y = self:getFlyPosition(info.zoon[1])
                    if x ~= nil and y ~= nil then
                        local autoWalkStr = string.format("#Z%s|%s(%d,%d)|$1#Z", info.zoon[1], info.zoon[1], x, y)
                        AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
                    end
                    self:onCloseButton()
                end
            else
                gf:ShowSmallTips(CHS[3003401])
            end
        elseif self.showBaby == PET_TYPE.EPIC then -- 神兽
            local autoWalkStr = string.format(CHS[7190031], self.curData.name)
            AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
            self:onCloseButton()
        else
            local autoWalkStr = string.format(CHS[3003402], self.curData.name)
            AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
            self:onCloseButton()
        end
    end)
    self:bindListener("MallBuyButton", function(sender, eventType)
        local autoWalkStr = string.format(CHS[3003403], self.curData.cfg.level_req, self.curData.name)
        AutoWalkMgr:beginAutoWalk(gf:findDest(autoWalkStr))
        self:onCloseButton()
    end)
    self:bindListener("MaketBuyButton", function(sender, eventType)
        if not DistMgr:checkCrossDist() then return end

        local param = CHS[3003405]
        if self.showBaby == PET_TYPE.ELITE then
            param = param .. ":" .. CHS[3003407]
        elseif self.showBaby == PET_TYPE.EPIC then
            param = param .. ":" .. CHS[3003814]
        elseif self.showBaby == PET_TYPE.JINGGUAI then
            local searchThirdClass = info.capacity_level .. CHS[3002813]
            if info.capacity_level >= 6 then
                searchThirdClass = CHS[7000305]
            end

            param = param .. ":" .. CHS[6000519] .. "/" .. CHS[6000520] .. ":" .. searchThirdClass
        elseif self.showBaby == PET_TYPE.OTHER then
            param = param .. ":" .. CHS[4100360]
        elseif self.showBaby == PET_TYPE.JINIAN then
            param = param .. ":" .. CHS[7002139]
        else
            local searchThirdClass = info.polar .. CHS[7000326]
            param = param .. ":" .. CHS[3003406] .. ":" .. searchThirdClass
        end

        DlgMgr:openDlgAndsetParam({"MarketBuyDlg", param})
    end)

    self.pageLastSelectIndex[self.curPageIndex] = idx
end

-- 获取传送位置
function PetHandbookDlg:getFlyPosition(mapName)
    local mapInfo =  MapMgr:getMapinfo()

    for k,v in pairs(mapInfo) do
        if v["map_name"] == mapName then
            return v["teleport_x"],v["teleport_y"]
        end
    end

    gf:ShowSmallTips(CHS[6000073])
end

-- 清除宠物相关信息
function PetHandbookDlg:clearPetInfo()
    self.curPet = {}
    self:setPortrait('PetIconPanel', 0)
    self:setLabelText('PetTypeLabel', '')
    self:setLabelText('PetPolarLabel', '')
    self:setLabelText('PetNameLabel', '')
    self:setLabelText('LifeEffectLabel', '')
    self:setLabelText('ManaEffectLabel', '')
    self:setLabelText('PhyEffectLabel', '')
    self:setLabelText('MagEffectLabel', '')
    self:setLabelText('SpeedEffectLabel', '')

    for i = 1, 3 do
        local panel = self:getControl('RawSkillPanel' .. i, Const.UIPanel)
        panel:removeAllChildren()
    end

    self.catchNoteText:setString('')
    self.catchNoteText:updateNow()

end

-- 设置成长信息
function PetHandbookDlg:setGrowInfo(label, effect, range, field)
    local additional = 0 -- 变异,神兽有附加值
    if self.showBaby == PET_TYPE.ELITE or self.showBaby == PET_TYPE.EPIC then
        range = 0
        additional = Formula:getElitePetBasicAddByValue(effect)
    end

    local minUpgradeEff = 0
    local maxUpgradeEff = 0
    if self.isUpgradeCheck then
        minUpgradeEff = Formula:getPerFlyUpgradeAddValue(effect + 40, PET_TYPE_STR[self.showBaby], field)
        maxUpgradeEff = Formula:getPerFlyUpgradeAddValue(effect + 40 + range, PET_TYPE_STR[self.showBaby], field)
    end

    if self.showBaby == PET_TYPE.JINGGUAI or self.showBaby == PET_TYPE.JINIAN then
        self:setLabelText(label.."1", effect + 40 + additional + minUpgradeEff)  -- 精怪没有野生，成长区间以宝宝成长区间为准
    else
        self:setLabelText(label.."1", effect + 40 - range + additional + minUpgradeEff)
    end

    self:setLabelText(label.."3", effect + 40 + range + additional + maxUpgradeEff)

    return effect + 40 + additional + minUpgradeEff, maxUpgradeEff - minUpgradeEff
end

-- 选中宠物类型
function PetHandbookDlg:onSelectPetType(sender, idx)
    self.showBaby = idx
    self.lastShowIdx = 1
    self:getControl("PageTagPanel"):removeAllChildren()

    if self.showBaby == PET_TYPE.NORMAL then
        self:setPetList(normalPetList)
        self:setCtrlVisible("BuyButton", true)
    elseif self.showBaby == PET_TYPE.ELITE then
        self:setPetList(elitePetList)
        self:setCtrlVisible("BuyButton", false)
    end
end

function PetHandbookDlg:onCatchMsgButton(sender, eventType)
    if self.showBaby == PET_TYPE.NORMAL then
        gf:showTipInfo(CHS[3000027], self:getControl('CatchNotePanel', Const.UIPanel))
    elseif self.showBaby == PET_TYPE.ELITE then
        gf:showTipInfo(CHS[4000323], self:getControl('CatchNotePanel', Const.UIPanel))
    end
end

-- 点击技能图标的响应函数
function PetHandbookDlg:onSkillButton(sender, eventType)
    local skills = self.curPet.skills or {}
    local idx = sender:getTag()
    if not skills[idx] then
        return
    end

    for i=1, 3 do
        local panel = self:getControl('RawSkillPanel' .. i, Const.UIPanel)
        self:getControl("ChosenEffectImage", Const.UIImage, panel):setVisible(false)
    end

    local panel = self:getControl('RawSkillPanel' .. idx, Const.UIPanel)
    self:getControl("ChosenEffectImage", Const.UIImage, panel):setVisible(true)
    -- 显示技能描述信息界面
    local rect = sender:getBoundingBox()
    local pt = sender:convertToWorldSpace(cc.p(0,0))
    rect.x = pt.x
    rect.y = pt.y
    SkillMgr:showSkillDescDlg(skills[idx], 0, true, rect)
end

-- 获取改区域的怪物列表
function PetHandbookDlg:getMosterList(mapName)
    local mosterList = {}

	for k, v in pairs(normalPetList) do
	   if v["zoon"] == mapName then
            table.insert(mosterList, v)
	   end
	end

	return mosterList
end

function PetHandbookDlg:OnCallButton()
    local dest = gf:findDest(CHS[7000094])
    local dlgName = self.name
    gf:confirm(CHS[7000090], function()
        AutoWalkMgr:beginAutoWalk(dest)
        DlgMgr:closeDlg(dlgName)
    end)
end

function PetHandbookDlg:close(now)
    if DlgMgr.dlgs["SkillFloatingFrameDlg"] then
        DlgMgr:closeDlg("SkillFloatingFrameDlg")
    end

    Dialog.close(self, now)
end

-- 飞升前
function PetHandbookDlg:onLeftButton(sender, eventType)
    self.isUpgradeCheck = false

    self:setCtrlVisible("LeftImage", true)
    self:setCtrlVisible("RightImage", false)

    self:showPetInfo(self.lastShowIdx)
end

-- 飞升后
function PetHandbookDlg:onRightButton(sender, eventType)
    self.isUpgradeCheck = true

    self:setCtrlVisible("LeftImage", false)
    self:setCtrlVisible("RightImage", true)
    self:showPetInfo(self.lastShowIdx)
end

return PetHandbookDlg
