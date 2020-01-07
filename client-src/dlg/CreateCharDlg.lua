-- CreateCharDlg.lua
-- Created by liu Feb/27/2015
-- 创建人物界面

local MALE = 1
local FEMALE = 2

local MOVEDISTANCE = 60
local PANELDISTANCE = 250
local MOVETIME = 0.35
local TOTAL_ROLE = 10

local PANEL = {
    "MetalPanel",
    "WoodPanel",
    "WaterPanel",
    "FirePanel",
    "EarthPanel",
}

local checkBox_Config =
{
    ["MetalCheckBox"] = POLAR.METAL,
    ["WoodCheckBox"] = POLAR.WOOD,
    ["WaterCheckBox"] = POLAR.WATER,
    ["FireCheckBox"] = POLAR.FIRE,
    ["EarthCheckBox"] = POLAR.EARTH,
    ["MaleCheckBox"] = GENDER_TYPE.MALE,
    ["FemaleCheckBox"] = GENDER_TYPE.FEMALE,
}

local ROLE_INDEX =
{
    [POLAR.METAL..GENDER_TYPE.MALE] = 1,
    [POLAR.METAL..GENDER_TYPE.FEMALE] = 2,
    [POLAR.WOOD..GENDER_TYPE.MALE] = 3,
    [POLAR.WOOD..GENDER_TYPE.FEMALE] = 4,
    [POLAR.WATER..GENDER_TYPE.MALE] = 5,
    [POLAR.WATER..GENDER_TYPE.FEMALE] = 6,
    [POLAR.FIRE..GENDER_TYPE.MALE] = 7,
    [POLAR.FIRE..GENDER_TYPE.FEMALE] = 8,
    [POLAR.EARTH..GENDER_TYPE.MALE] = 9,
    [POLAR.EARTH..GENDER_TYPE.FEMALE] = 10,
}

local canTouchCtrl =
{
    ["MetalCheckBox"] = "MetalCheckBox",
    ["WoodCheckBox"] = "WoodCheckBox",
    ["WaterCheckBox"] = "WaterCheckBox",
    ["FireCheckBox"] = "FireCheckBox",
    ["EarthCheckBox"] = "EarthCheckBox",
    ["InputNamePanel"] = "InputNamePanel",
    ["CreateCharButton"] = "CreateCharButton",
    ["DistButton"] = "DistButton",
    ["MaleCheckBox"] = "MaleCheckBox",
    ["FemaleCheckBox"] = "FemaleCheckBox",
}


local CHAR_CHAR_SURNAME = require(ResMgr:getCfgPath("CharSurname.lua"))
local CHAR_CHAR_MAN_SURNAME = require(ResMgr:getCfgPath("CharManSurname.lua"))
local CHAR_CHAR_WOMEN_SURNAME = require(ResMgr:getCfgPath("CharWomenSurname.lua"))
local CHAR_NORMAL_NAME = require(ResMgr:getCfgPath("CharNormalName.lua"))
local RadioGroup = require("ctrl/RadioGroup")

local SUPER_NAME = {
    CHAR_CHAR_SURNAME,
    CHAR_CHAR_MAN_SURNAME,
    CHAR_CHAR_WOMEN_SURNAME,
}

local CreateCharDlg = Singleton("CreateCharDlg", Dialog)

local SHAPE_PANEL_TO_BONES_ICON = {
    ["ShapePanel1"] = ResMgr.DragonBones.creatCharShape1,
    ["ShapePanel2"] = ResMgr.DragonBones.creatCharShape2,
    ["ShapePanel3"] = ResMgr.DragonBones.creatCharShape3,
    ["ShapePanel4"] = ResMgr.DragonBones.creatCharShape4,
    ["ShapePanel5"] = ResMgr.DragonBones.creatCharShape5,
    ["ShapePanel6"] = ResMgr.DragonBones.creatCharShape6,
    ["ShapePanel7"] = ResMgr.DragonBones.creatCharShape7,
    ["ShapePanel8"] = ResMgr.DragonBones.creatCharShape8,
    ["ShapePanel9"] = ResMgr.DragonBones.creatCharShape9,
    ["ShapePanel10"] = ResMgr.DragonBones.creatCharShape10,
}


-- 初始化赋值后
local DESC_MOVE_DIS

function CreateCharDlg:init()
    self:setFullScreen()

    DlgMgr:setVisible("UserLoginDlg", false) -- 隐藏角色界面
    local testPanel = self:getControl("Panel_60")
    DESC_MOVE_DIS = DESC_MOVE_DIS or testPanel:getContentSize().height
    self:bindListener("DistButton", self.onDistButton)
    local disBtn = self:getControl("DistButton")
    local polarPanel = self:getControl("PolarPanel")
    local infoPanel = self:getControl("InfoPanel")
    polarPanel:setLocalZOrder(1)
    infoPanel:setLocalZOrder(1)
    disBtn:setLocalZOrder(1)
    DlgMgr:closeDlg("WaitDlg")
    local winsize = cc.Director:getInstance():getWinSize()
    local createBcak = ccui.ImageView:create(ResMgr.ui["create_role_back"])
    local rootX, rootY = self.root:getPosition()
    --createBcak 与self.root锚点都是0.5,0.5,所以位置就是self.root位置
    createBcak:setPosition(rootX, rootY)
    createBcak:setAnchorPoint(0.5,0.5)
    createBcak:setLocalZOrder(-1)
    self.blank:addChild(createBcak)

    self:setCtrlFullClient(createBcak, nil, true)
    self:setCtrlFullClientEx("BKPanel", nil, true)

    -- 场景龙骨特效
    self:creatUIDragonBones(ResMgr.DragonBones.creatCharBKtree1, "BKTreePanel1", {x = -32, y = 110})
    self:creatUIDragonBones(ResMgr.DragonBones.creatCharBKtree2, "BKTreePanel2", {x = 71, y = -112})

    self:creatUIDragonBones(ResMgr.DragonBones.creatCharUptree1, "UpTreePanel1", {x = -62, y = 0})
    self:creatUIDragonBones(ResMgr.DragonBones.creatCharUptree2, "UpTreePanel2", {x = 120, y = 0})

    local ctl = self:getControl("MainBodyPanel")
    gf:createArmatureMagic(ResMgr.ArmatureMagic.create_char, ctl, tonumber(ResMgr.ArmatureMagic.create_char.name))

    self:bindListener("RandomNameButton", self.onRandomNameButton)
    self:bindListener("CreateCharButton", self.onCreateButton)

    self.radioGroup = RadioGroup.new()
    self.radioGroup:setItems(self, {"MetalCheckBox", "WoodCheckBox", "WaterCheckBox", "FireCheckBox", "EarthCheckBox"}, self.selectPolar)

    self.genderRadioGroup = RadioGroup.new()
    self.genderRadioGroup:setItems(self, {"MaleCheckBox", "FemaleCheckBox"}, self.selectGender)

    -- 左中右位置
    self.posTable  = {}
    local curPos = self:getControl("ShapePanel1"):getPosition()
    table.insert(self.posTable, curPos)
    table.insert(self.posTable, curPos - 250)
    table.insert(self.posTable, curPos + 250)

    local shapePanel = self:getControl(string.format("ShapePanel%d", 1))
    self:creatCharDragonBones(SHAPE_PANEL_TO_BONES_ICON["ShapePanel1"], shapePanel)

    self:setAllDescImageVisible(false)
    local descPanel = self:getControl("DescPanel1", nil, "PolarDescPanel")
    descPanel:setVisible(true)

    for i = 2, 10 do
        local shapePanel = self:getControl(string.format("ShapePanel%d", i))
        self:creatCharDragonBones(SHAPE_PANEL_TO_BONES_ICON[shapePanel:getName()], shapePanel)
        self:setCtrlVisible("DescImage", false, shapePanel)
        self:setCtrlVisible("DescImage_2", false, shapePanel)
  --      shapePanel:setOpacity(0)
        shapePanel:setVisible(false)
    end

    -- 默认选中第一个
    self.selectIndex = 1
    self:initSelectRoleInfoByIndex(self.selectIndex)
    -- 初值化面板位置信息
    self:initChar()

    -- 绑定移动区域
    self:blinkMove()

    -- 设置区组信息
    local distname = Client:getWantLoginDistName()
    self:setLabelText("DistLabel", distname)
    -- 初始化初始选中id
    self.selectId = nil
    -- self:setLabelText("CurrentLabel", self:randomName())

    -- 获取配置文件
    self.cfg = require(ResMgr:getCfgPath('CreateCharInfo.lua'))

    -- 获取配置文件数据
    self:updateData()

    -- gf:CmdToServer("CMD_RANDOM_NAME", {gender = self.data[self.selectId].gender - 1})


    self.newNameEdit = self:createEditBox("InputPanel", nil, nil, function(sender, type)

            if type == "end" then

            elseif type == "changed" then
                local newName = self.newNameEdit:getText()
                if gf:getTextLength(newName) > 12 then
                    newName = gf:subString(newName, 12)
                    self.newNameEdit:setText(newName)
                    gf:ShowSmallTips(CHS[5410160])
                end
            end
    end)
    self.newNameEdit:setPlaceholderFont(CHS[3002368], 23)
    self.newNameEdit:setFont(CHS[3002368], 23)
    self.newNameEdit:setPlaceHolder(CHS[3002369])
    self.newNameEdit:setPlaceholderFontColor(COLOR3.WHITE)
    self.newNameEdit:setFontColor(COLOR3.WHITE)
    self.newNameEdit:setAnchorPoint(0.5, 0.5)
    self.newNameEdit:setPositionX(self:getControl("InputPanel"):getContentSize().width/2)
    self.newNameEdit:setPositionY(self.newNameEdit:getPositionY() - 1)

    self:hookMsg("MSG_RANDOM_NAME")
    self:hookMsg("MSG_EXISTED_CHAR_LIST")
end


function CreateCharDlg:creatMagic(icon, titlePanel)
    local magic = ArmatureMgr:createArmature(icon)
    titlePanel:addChild(magic)
    local size = titlePanel:getContentSize()
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(size.width * 0.5, size.height * 0.5)
    magic:getAnimation():play("Bottom")
end

function CreateCharDlg:creatCharDragonBones(icon, root)
    local dbMagic = DragonBonesMgr:createCharDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local panel = self:getControl("PlayerPanel", nil, root)
    self:setCtrlVisible("ShapeImage", false, panel)

    local magic = tolua.cast(dbMagic, "cc.Node")

    magic:setPosition(panel:getContentSize().width * 0.5, panel:getContentSize().height * 0.5 )
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)
    --  magic:setRotationSkewY(180)

    DragonBonesMgr:toPlay(dbMagic, "stand", 0)
end

function CreateCharDlg:creatUIDragonBones(icon, panelName, pos)
    local dbMagic = DragonBonesMgr:createUIDragonBones(icon, string.format("%05d", icon))
    if not dbMagic then return end

    local panel = self:getControl(panelName)

    local magic = tolua.cast(dbMagic, "cc.Node")

    magic:setPosition(pos.x, pos.y)
    magic:setName("charPortrait")
    magic:setTag(icon)
    panel:addChild(magic)
    --  magic:setRotationSkewY(180)

    DragonBonesMgr:toPlay(dbMagic, "stand", 0)
end

function CreateCharDlg:setSelectIndex(ploarIndex, genderIndex)
    local key = ploarIndex .. genderIndex
    self.selectIndex = ROLE_INDEX[key]
end
function CreateCharDlg:onDistButton(sender, enventType)

    performWithDelay(sender,function ()
        GameMgr:changeScene('LoginScene', true)
        DlgMgr:closeDlg(self.name)
        --CommThread:stopAAA()
        CommThread:stop()-- 断开gs
    end, 0)

    if not DlgMgr.dlgs["LoginChangeDistDlg"] then
        DlgMgr:setVisible("UserLoginDlg", true)
    end
end

function CreateCharDlg:selectPolar(sender, envetType)
    local name = sender:getName()
    local ploarIndex = checkBox_Config[name]
    self.selectGenderIndex = self.selectGenderIndex or GENDER_TYPE.MALE
    self:selectRole(ROLE_INDEX[ploarIndex .. self.selectGenderIndex])
    self.selectPolarIndex = ploarIndex
    self:setSelectIndex(ploarIndex, self.selectGenderIndex)
    self.genderRadioGroup:selectRadio(self.selectGenderIndex, true)

    self.picking = true
end

function CreateCharDlg:selectRole(index)
    if index > self.selectIndex then
        self:setAllDescImageVisible(false)
        self:palyNextCharAction(index)
    elseif index < self.selectIndex then
        self:setAllDescImageVisible(false)
        self:palyLastCharAction(index)
    end
end

function CreateCharDlg:selectGender(sender, eventType)
    local name = sender:getName()
    self.selectGenderIndex = checkBox_Config[name]
    self:selectRole(ROLE_INDEX[self.selectPolarIndex .. self.selectGenderIndex])
    self:setSelectIndex(self.selectPolarIndex, self.selectGenderIndex)

    self.picking = true
end


function CreateCharDlg:initSelectRoleInfoByIndex(index)
    self.selectGenderIndex = index % 2
    if self.selectGenderIndex == 0 then
        self.selectGenderIndex = GENDER_TYPE.FEMALE
    end

    self.selectPolarIndex = math.ceil(index / 2)
    self.radioGroup:selectRadio(self.selectPolarIndex, true)
    self.genderRadioGroup:selectRadio(self.selectGenderIndex, true)
    self:initChar()
end


function CreateCharDlg:initChar(index)
    self.curCharPanel = self:getControl(string.format("ShapePanel%d", self.selectIndex))
    self.curCharPanel:setPositionX(self.posTable[1])

    local rightIndex, leftIndex

    if index and index > self.selectIndex then
        rightIndex = index
    else
        rightIndex = self:getRigtIndex()
    end

    self.rightCharPanel = self:getControl(string.format("ShapePanel%d", rightIndex))
    self.rightCharPanel:setPositionX(self.posTable[3])

    if index and index < self.selectIndex then
        leftIndex = index
    else
        leftIndex = self:getLeftIndex()
    end
    --
    self.leftCharPanel = self:getControl(string.format("ShapePanel%d", leftIndex))


    -- 边界时候位置重置了
    if leftIndex ~= rightIndex or leftIndex ~= TOTAL_ROLE then
        self.leftCharPanel:setPositionX(self.posTable[2])
    end
    --]]
end

function CreateCharDlg:getRigtIndex()
    local rightIndex
    if self.selectIndex then
        if self.selectIndex + 1 > TOTAL_ROLE then
            rightIndex = 1
        else
            rightIndex =  self.selectIndex + 1
        end
    end

    return rightIndex
end

function CreateCharDlg:getLeftIndex()
    local leftIndex
    if self.selectIndex - 1 < 1 then
        leftIndex = TOTAL_ROLE
    else
        leftIndex = self.selectIndex - 1
    end

    return leftIndex
end

function CreateCharDlg:palyNextCharAction(index)
    self.curCharPanel:stopAllActions()
    self.leftCharPanel:stopAllActions()
    self.rightCharPanel:stopAllActions()
    self:setCharBonesVisible(self.curCharPanel, false)
    self:setCharBonesVisible(self.rightCharPanel, false)
    self:setCharBonesVisible(self.leftCharPanel, false)

    self:resetPos()
    self:initChar(index)

    self:setCharBonesVisible(self.curCharPanel, true)
    self:setCharBonesVisible(self.rightCharPanel, true)

    local moveTo = cc.MoveTo:create(MOVETIME,cc.p(self.posTable[1], 0))

    self.rightCharPanel:runAction(moveTo)
    local moveTo = cc.MoveTo:create(MOVETIME, cc.p(self.posTable[2], 0))
    local func = cc.CallFunc:create(function()
        self.selectIndex = index
        self:onUpdate()
        self:initChar(index)
        self:setAllDescEff()
    end)

    local action = cc.Sequence:create(moveTo, func)
    self.curCharPanel:runAction(action)
end

function CreateCharDlg:resetPos()
    for i = 1, 10 do
        local panel = self:getControl(string.format("ShapePanel%d", i))
        panel:setPositionX(self.posTable[2] - 200)
        self:setOpacityAndScaleByPanel(panel)
    end
end

function CreateCharDlg:palyLastCharAction(index)
--
    self.curCharPanel:stopAllActions()
    self.leftCharPanel:stopAllActions()
    self.rightCharPanel:stopAllActions()

    self:setCharBonesVisible(self.curCharPanel, false)
    self:setCharBonesVisible(self.rightCharPanel, false)
    self:setCharBonesVisible(self.leftCharPanel, false)

    self:resetPos()
    self:initChar(index)

    self:setCharBonesVisible(self.curCharPanel, true)
    self:setCharBonesVisible(self.leftCharPanel, true)
    local moveTo = cc.MoveTo:create(MOVETIME,cc.p(self.posTable[1], 0))
    self.leftCharPanel:runAction(moveTo)
--]]
    local moveTo = cc.MoveTo:create(MOVETIME, cc.p(self.posTable[3], 0))
    local func = cc.CallFunc:create(function()
        self.selectIndex = index
        self:onUpdate()
        self:initChar(index)
        self:setAllDescEff()
    end)

    local action = cc.Sequence:create(moveTo, func)
    self.curCharPanel:runAction(action)
end

function CreateCharDlg:updateData()
    local data = {}
    for i = 1, #self.cfg do
        local polar = self.cfg[i][1]
        local polarDes = self.cfg[i][2]
        local icon = self.cfg[i][3]
        local gender = self.cfg[i][4]
        local des = self.cfg[i][5]
        if CHS[5000066] == gender then
            gender = MALE
        elseif CHS[5000067] == gender then
            gender = FEMALE
        end

        local info = {polar = polar, polarDes = polarDes, icon = icon, gender = gender, des = des}
        data[i] = info
    end
    self.data = data
end

function CreateCharDlg:onClickChar(sender, eventType)
    local selectId = sender.id
    if self.selectId == selectId then
        return
    end

    self.selectId = selectId
    self:setLabelText("PolarLabel", self.data[selectId].polarDes)
    self:setLabelText("InstructionLabel", self.data[selectId].des)

    -- 设置选择框
    local selectImg = self:getSelectImg()
    selectImg:removeFromParent(false)
    sender:addChild(selectImg)
    gf:CmdToServer("CMD_RANDOM_NAME", {gender = self.data[self.selectId].gender - 1})
end

-- 获取选择Img
function CreateCharDlg:getSelectImg()
    if nil == self.selectImg then
        -- 创建选择框
        self.selectImg = self:getControl("ChosenEffectImage", Const.UIImage)
        self.selectImg:retain()
        self.selectImg:setPosition(0, 0)
        self.selectImg:setAnchorPoint(0, 0)
    end

    return self.selectImg
end

function CreateCharDlg:cleanup()
    self.touchTimes = 0
    self:releaseCloneCtrl("selectImg")

    DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.creatCharBKtree1, string.format("%05d", ResMgr.DragonBones.creatCharBKtree1))
    DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.creatCharBKtree2, string.format("%05d", ResMgr.DragonBones.creatCharBKtree2))
    DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.creatCharUptree1, string.format("%05d", ResMgr.DragonBones.creatCharUptree1))
    DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.creatCharUptree2, string.format("%05d", ResMgr.DragonBones.creatCharUptree2))
end

function CreateCharDlg:onRandomNameButton(sender, eventType)
    gf:CmdToServer("CMD_RANDOM_NAME", {gender = self.data[self.selectIndex].gender - 1})
end

function CreateCharDlg:onCreateButton(sender, eventType)
    if nil == self.selectIndex then
        return
    end

    local id = self.selectIndex
    local data = {}
    local nameLabelCtrl = self:getControl("CurrentLabel")
    local name = self.newNameEdit:getText()
    if nil == name or name == "" then
        gf:ShowSmallTips(CHS[3002370])
        return
    end

    local name, fitStr = gf:filtText(name)

    if fitStr then
        return
    end

    if not self:isOutLimitTime("lastTime", 1000) then
        return
    end

    self:setLastOperTime("lastTime", gfGetTickCount())
    -- if not GameMgr.normalLogin then
    --     name = name .. "GM"
    -- end

    name = string.trim(name)
    data["char_name"] = name
    data["gender"] = self.data[id].gender -- 性别
    data["polar"] = self.data[id].polar
    gf:CmdToServer("CMD_CREATE_NEW_CHAR", data)
    Client:setLoginChar(name)
    Client:setIsNeedEnterGame(true)
end

function CreateCharDlg:MSG_RANDOM_NAME(data)
    if not data.new_name then return end
    self.newNameEdit:setText(data.new_name)
end

function CreateCharDlg:setAllDescImageVisible(isVisible)

    local panel = self:getControl("PolarDescPanel")
    for i = 1, 10 do
        self:setCtrlVisible("DescPanel" .. i, isVisible)
    end
--[[
    self:setDescImageVisible(isVisible, self.leftCharPanel)
    self:setDescImageVisible(isVisible, self.rightCharPanel)
    self:setDescImageVisible(isVisible, self.curCharPanel)
--]]
    self.isShowAct = true
end

function CreateCharDlg:setDescImageVisible(isVisible, panel)
    local iamge1 = self:getControl("DescImage", nil, panel)
    local iamge2 = self:getControl("DescImage_2", nil, panel)

    iamge1:setVisible(isVisible)
    iamge2:setVisible(isVisible)

    local testPanel = self:getControl("Panel_60", nil, panel)
    if testPanel and not isVisible then
        testPanel:setContentSize(testPanel:getContentSize().width, 0)
    end
end

function CreateCharDlg:setAllDescEff()
    if self.isShowAct or self.picking then
    self:descImageDisplayEff(self.curCharPanel)
 --   self:descImageDisplayEff(self.leftCharPanel)
 --   self:descImageDisplayEff(self.rightCharPanel)

        for i = 1, 10 do
            if string.format("ShapePanel%d", i) ~= self.curCharPanel:getName() then
                local panel = self:getControl(string.format("ShapePanel%d", i))
                self:setCharBonesVisible(panel, false)
            end
        end
    end
    self.isShowAct = false
    self.picking = false
    self.touchTimes = 0
end

function CreateCharDlg:setCharBonesVisible(panel, isVisible)
    panel:setVisible(isVisible)
    --self:setCtrlVisible("PlayerPanel", isVisible, panel)
end

function CreateCharDlg:descImageDisplayEff(panel)

    local n = string.match(panel:getName(), "ShapePanel(.+)")
    local descPanel = self:getControl("DescPanel" .. n, nil, "PolarDescPanel")
    descPanel:setVisible(true)
    local iamge1 = self:getControl("DescImage", nil, descPanel)
    local iamge2 = self:getControl("DescImage_2", nil, descPanel)
    local testPanel = self:getControl("Panel_60", nil, descPanel)
    --
    iamge1:setVisible(true)
    iamge2:setVisible(true)

    iamge1:setOpacity(0)
    iamge2:setOpacity(0)

    iamge1:stopAllActions()
    iamge2:stopAllActions()

    if testPanel then
        local imSize = iamge2:getContentSize()
        testPanel:setContentSize(imSize.width, 0)
    end
    local isGoOn = false

    local fadeIn1 = cc.FadeIn:create(0.35)
    local delay = cc.DelayTime:create(0.3)
    local fadeIn2 = cc.FadeIn:create(0.5)
    local delay2 = cc.DelayTime:create(0)
    local disAct = cc.CallFunc:create(function()

        local size = testPanel:getContentSize()
            if size.height < DESC_MOVE_DIS and isGoOn then

            testPanel:setContentSize(size.width, size.height + 4)
            local im = self:getControl("DescImage_2", nil, testPanel)
            im:setOpacity(255)
            local imSize = im:getContentSize()
            im:setPositionY(size.height + 2 - (imSize.height) * 0.5)
            testPanel:requestDoLayout()
        end
    end)

    local endAc = cc.CallFunc:create(function()
            isGoOn = true
        end)

    iamge1:runAction(cc.Sequence:create(fadeIn1, endAc))

    local testPanel = self:getControl("Panel_60", nil, descPanel)
    if testPanel then
        local ac = cc.Sequence:create(delay2, disAct)
        local delay3 = cc.DelayTime:create(1)
        local ss = cc.Sequence:create(delay3, cc.RepeatForever:create(ac))
        iamge2:runAction(cc.RepeatForever:create(ac))

    else
        iamge2:runAction(cc.Sequence:create(delay, fadeIn2))
    end
end


function CreateCharDlg:blinkMove()
    local movePanel = self:getControl("MovePanel")
    local sartPos, rect
    self.isAutoMoving = false

    local function endAction(toPos)
        if self.isAutoMoving then return end
        local dif = toPos.x - sartPos.x
        if dif > MOVEDISTANCE then
            self:setCharBonesVisible(self.curCharPanel, true)
            self:setCharBonesVisible(self.leftCharPanel, true)
            self:setCharBonesVisible(self.rightCharPanel, false)
        elseif dif < -MOVEDISTANCE then
            self:setCharBonesVisible(self.curCharPanel, true)
            self:setCharBonesVisible(self.leftCharPanel, false)
            self:setCharBonesVisible(self.rightCharPanel, true)
        else
            self:setCharBonesVisible(self.leftCharPanel, false)
            self:setCharBonesVisible(self.rightCharPanel, false)
        end


        local time = 0.25
        if time < 0 then time = 0 - time end
        if dif <= MOVEDISTANCE and dif + MOVEDISTANCE >= 0 then
            local moveTo = cc.MoveTo:create(time, cc.p(self.posTable[3], 0))
            self.rightCharPanel:runAction(moveTo)
            moveTo = cc.MoveTo:create(time, cc.p(self.posTable[2], 0))
            self.leftCharPanel:runAction(moveTo)

            local func = cc.CallFunc:create(function()
                self:resetPos()
                self:initSelectRoleInfoByIndex(self.selectIndex)
                self:initChar()
                self:setAllDescEff()
            end)
            local moveTo = cc.MoveTo:create(time, cc.p(self.posTable[1], 0))
            local action = cc.Sequence:create(moveTo, func)
            self.curCharPanel:runAction(action)
        elseif dif > MOVEDISTANCE then
            local moveTo = cc.MoveTo:create(time,cc.p(self.posTable[1], 0))
            self.leftCharPanel:runAction(moveTo)
            local moveTo = cc.MoveTo:create(time, cc.p(self.posTable[3], 0))
            local func = cc.CallFunc:create(function()
                self.selectIndex = self:getLeftIndex()
                self:initSelectRoleInfoByIndex(self.selectIndex)
                self:setAllDescEff()
                --self:initChar()
            end)

            local action = cc.Sequence:create(moveTo, func)
            self.curCharPanel:runAction(action)

        elseif dif + MOVEDISTANCE < 0 then
            local moveTo = cc.MoveTo:create(time,cc.p(self.posTable[1], 0))
            self.rightCharPanel:runAction(moveTo)
            local moveTo = cc.MoveTo:create(time, cc.p(self.posTable[2], 0))
            local func = cc.CallFunc:create(function()
                self.selectIndex = self:getRigtIndex()
                self:initSelectRoleInfoByIndex(self.selectIndex)
                self:setAllDescEff()
                --self:initChar()
            end)

            local action = cc.Sequence:create(moveTo, func)
            self.curCharPanel:runAction(action)
        end
    end

    gf:bindTouchListener(movePanel, function(touch, event)
            local toPos = touch:getLocation()
            local eventCode = event:getEventCode()
            if eventCode == cc.EventCode.BEGAN then
                if self.picking then return end -- 玩家选择，动画中
                self.touchTimes = (self.touchTimes or 0) + 1
                if self.touchTimes > 1 then
                    self.touchTimes = self.touchTimes - 1
                    return
                end

                rect = self:getBoundingBoxInWorldSpace(movePanel)
                if cc.rectContainsPoint(rect, toPos) then
                    for k,v in pairs(canTouchCtrl) do
                        local ctrl = self:getControl(k)
                        local ctrRect = self:getBoundingBoxInWorldSpace(ctrl)

                        if cc.rectContainsPoint(ctrRect, toPos) then
                            self.touchTimes = self.touchTimes - 1
                            return false
                        end
                    end

                    self.curCharPanel:stopAllActions()
                    self.leftCharPanel:stopAllActions()
                    self.rightCharPanel:stopAllActions()
                    sartPos = toPos
                    return true
                end

                self.touchTimes = self.touchTimes - 1
            elseif eventCode == cc.EventCode.MOVED then
                if self.picking then return end -- 玩家选择，动画中
                if self.isAutoMoving then return end
                if self.touchTimes > 1 then return end
                self:setAllDescImageVisible(false)
                local dif = toPos.x - sartPos.x


                if math.abs(dif) < MOVEDISTANCE then
                    self:setCharBonesVisible(self.leftCharPanel, false)
                    self:setCharBonesVisible(self.rightCharPanel, false)
                    self.leftCharPanel:setPositionX(self.posTable[2] + dif)
                    self.curCharPanel:setPositionX(self.posTable[1] + dif)
                    self.rightCharPanel:setPositionX(self.posTable[3] + dif)
                else
                    endAction(toPos)
                    self.isAutoMoving = true
                end
            else
                self.touchTimes = self.touchTimes - 1
                if self.touchTimes == 0 then
                    endAction(toPos)
                end
                self.touchTimes = 0
                self.isAutoMoving = false
            end
    end, {
        cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_MOVED,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED,
    }, false)
end

function CreateCharDlg:onUpdate()
    self:setOpacityAndScaleByPanel(self.leftCharPanel, "leftCharPanel")
    self:setOpacityAndScaleByPanel(self.rightCharPanel, "rightCharPanel")
    self:setOpacityAndScaleByPanel(self.curCharPanel, "curCharPanel")
end

function CreateCharDlg:setOpacityAndScaleByPanel(panel, name)
    if panel == nil then return end

    local n = string.match(panel:getName(), "ShapePanel(.+d)")


    local MIN_SCALE = 0.74

    local opacity = 0
    local sacle = MIN_SCALE
    local posx = panel:getPositionX()
-- 140 0 280
    if posx > self.posTable[2] and posx <= self.posTable[1] then
        opacity = math.min((posx - self.posTable[2]) / PANELDISTANCE * 255, 255)
        sacle = math.min((posx - self.posTable[2]) / PANELDISTANCE * (1 - MIN_SCALE) + MIN_SCALE, 1)

    elseif posx > self.posTable[1] and posx < self.posTable[3] then
        local dis = PANELDISTANCE
        opacity = 255 - math.min((posx - self.posTable[1]) / (dis)* 255, 255)
        sacle = 1 - (posx - self.posTable[1]) / dis * (1 - MIN_SCALE)
    end
--    panel:setOpacity(opacity) 透明度

    local playerPanel = self:getControl("PlayerPanel", nil, panel)
    if playerPanel then
        playerPanel:setScale(sacle)
    else
        panel:setScale(sacle)
    end
    --]]

end

function CreateCharDlg:MSG_CREATE_NEW_CHAR(data)
    self.charGid = data.gid
    Client:setLoginChar(data.name)
end

function CreateCharDlg:MSG_EXISTED_CHAR_LIST(data)
    if not self.charGid then return end

    local gid = self.charGid
    self.charGid = nil
    local roleList = Client:getCharListInfo()
    if roleList then
        local roleName = nil
        for i = 1, roleList.count do
            if roleList[i].gid == gid then
                roleName = roleList[i].name
                break
            end
        end

        if roleName then
            local distName = Client:getWantLoginDistName() or ""
            LeitingSdkMgr:createRole({
                ["roleName"] = roleName,
                ["roleId"] = gid,
                ["roleLevel"] = 1,
                ["zoneId"] = distName,
                ["zoneName"] = distName,
            })
        end
    end
end

MessageMgr:regist("MSG_CREATE_NEW_CHAR", CreateCharDlg)

return CreateCharDlg
