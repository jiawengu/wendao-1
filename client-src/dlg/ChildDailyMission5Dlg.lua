-- ChildDailyMission5Dlg.lua
-- Created by songcw Apir/14/2019
-- 娃娃日常-【养育】慧眼识娃

local ChildDailyMission5Dlg = Singleton("ChildDailyMission5Dlg", Dialog)

-- init中赋值
local NPC_POS = {}

local MAX_GUANKA = 4        -- 通过需要的关卡
local GUANKA_RUN_COUNT = 5       -- 每关跑的次数

function ChildDailyMission5Dlg:init(data)
    self:setFullScreen()
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("RestartButton", self.onRestartButton)
    self:bindListener("QuitButton2_0", self.onQuitButton2_0)
    self:setCtrlVisible("ResultPanel", false)
    --self:bindListener("MyPanel", self.onMyPanel)
    self:setChoosePanelVisible(false)
    for i = 1, 6 do
        self:getControl("ChooseButton", nil, "ChoosePanel" .. i):setTag(i)
        self:bindListener("ChooseButton", self.onChooseButton, "ChoosePanel" .. i)
        self:getControl("CharPanel" .. i):setTag(i)
        self:bindListener("CharPanel" .. i, self.onCharPanel)
    end

    self.data = data
    self.isWin = false
    self.isGuss = false
    self.isResulting = false

    NPC_POS = {}
    for i = 1, 6 do
        local x,y = self:getControl("CharPanel" .. i):getPosition()
        table.insert( NPC_POS, cc.p(x + 25,y))
    end

    -- 隐藏主界面相关操作
    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1, ["LoadingDlg"] = 1 })

    -- 初始化NPC
    self:initChildNpc()

    -- 初始化战斗背景
    self:addFightBg()

    self.guanka = 1
    self.times = 0

    self:hookMsg("MSG_CHILD_GAME_RESULT")
end

function ChildDailyMission5Dlg:setChoosePanelVisible(isVisible)
    for i = 1, 6 do
        self:setCtrlVisible("ChoosePanel" .. i, isVisible)
    end
end

function ChildDailyMission5Dlg:updateFlag()
    for _, info in pairs(self.objectList) do
        for i = 1, 6 do
            if info.curX == NPC_POS[i].x and info.curY == NPC_POS[i].y then
                info.flag = i
            end
        end
    end
end

function ChildDailyMission5Dlg:initChildNpc()
    self.objectList = {}

    local rand = math.random( 1, 6 )
    for i = 1, #NPC_POS do
        local info = {icon = self.data.child_icon, name = CHS[4101498], dir = 5, life = 150}
        if i == rand then
         --   info.name = "就是我！"
            info.myChild = 1
        end

        local char = self:createChar(info, NPC_POS[i])
        char.flag = i
        table.insert( self.objectList, char )
    end

    local info = {icon = Me:queryBasicInt("org_icon"), name = Me:queryBasic("name"), dir = 1}
    local x,y = self:getControl("MyPanel"):getPosition()
    self.char = self:createChar(info, cc.p(x,y))
end

-- 创建角色
function ChildDailyMission5Dlg:createChar(info, pos)
    local char = require("obj/activityObj/ChildHyswNpc").new()
    char:absorbBasicFields({
        icon = info.icon,
        name = info.name or "",
        dir = info.dir or 7,
        org_x = pos.x,
        org_y = pos.y,
        myChild = info.myChild or 0
    })

    char:onEnterScene(pos.x, pos.y, self:getControl("CharPanel"))
    char:setAct(Const.FA_STAND)
    return char
end

function ChildDailyMission5Dlg:onCloseButton()

    if self.isResulting then
        DlgMgr:closeDlg(self.name)
        gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
        return
    end

    gf:confirm(CHS[4101499], function ()
        DlgMgr:closeDlg(self.name)
        gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
    end)
end

function ChildDailyMission5Dlg:cleanAllChild()
    for _, info in pairs(self.objectList) do
        info:cleanup()
    end
    self.objectList = {}

    if self.char then
        self.char:cleanup()
        self.char = nil
    end
end

function ChildDailyMission5Dlg:cleanup()

    performWithDelay(gf:getUILayer(), function ()
        DlgMgr:showAllOpenedDlg(true)
    end)
    Me:setVisible(true)

    self:cleanAllChild()

    FightMgr:removeFightBg()
    if self.bgImage then
        self.bgImage:removeFromParent()
        self.bgImage = nil
    end

    if self.bgImage2 then
     --   self.bgImage2:removeFromParent()
        self.bgImage2 = nil
    end

    if self.croplandLayer then
        self.croplandLayer:removeFromParent()
        self.croplandLayer = nil
    end
end

function ChildDailyMission5Dlg:onChooseButton(sender, eventType)


    if self.isWin then return end
    self.isSelected = true
    local tag = sender:getTag()
    local selectChar
    for i = 1, 6 do
        if self.objectList[i].flag == tag then
            selectChar = self.objectList[i]
        end
    end

    if selectChar:queryBasicInt("myChild") == 1 then
        selectChar:setChat({msg = CHS[4200773], show_time = 3}, nil, true)

        if self.guanka == MAX_GUANKA then
            local panel = self:getControl("CharPanel" .. tag)
            local x, y = panel:getPosition()
            self.char:setEndPos(x + 50, y - 30, nil, 1)
            performWithDelay(self.root, function ( )
                -- body
                self.guanka = self.guanka + 1
                self:nextGuank(self.guanka)
            end,2)
        else
            performWithDelay(self.root, function ( )
                -- body
                self.guanka = self.guanka + 1
                self:nextGuank(self.guanka)
            end,2)
        end
    else
        gf:CmdToServer("CMD_CHILD_FINISH_GAME", {task_name = self.data.task_name, result = gfEncrypt("fail", self.data.pwd), guanka = self.guanka})
        selectChar:setChat({msg = CHS[4200774], show_time = 3}, nil, true)
        performWithDelay(self.root, function ( )
            -- body
            self:setCtrlVisible("ResultPanel", true)
            self:setCtrlVisible("FailPanel", true, "ResultPanel")
            self:setCtrlVisible("SuccPanel", false, "ResultPanel")
        end,2)
    end
    self:setChoosePanelVisible(false)
end

function ChildDailyMission5Dlg:onCharPanel(tag, eventType)
    if not self.isGuss then return end
    if self.isSelected then return end
    for i = 1, 6 do
        self:setCtrlVisible("ChoosePanel" .. i, tag == i)
    end
end

function ChildDailyMission5Dlg:getGaussSatge()
    return self.isGuss
end

function ChildDailyMission5Dlg:nextGuank(guanka)
    self.guanka = guanka
    if guanka > MAX_GUANKA then
        gf:CmdToServer("CMD_CHILD_FINISH_GAME", {task_name = self.data.task_name, result = gfEncrypt("succ", self.data.pwd)})
        self.isWin = true
        return
    end

    self:updateGuanka()
    self:cleanAllChild()
    self:initChildNpc()
    self.times = 0
    self:beginRun()
end

function ChildDailyMission5Dlg:onStartButton(sender, eventType)
    sender:setVisible(false)

    self.times = 0
    self:beginRun()
end

function ChildDailyMission5Dlg:getRanRunPos()
    local initPositions = gf:deepCopy(NPC_POS)
    local readyPositions = {}
    local ret = {}
    for i = 1, #initPositions do
        -- 复制一份可选坐标
        local temp = gf:deepCopy(initPositions)

        -- 排除自身当前位置
        table.remove( temp, i )

        -- 排除己选择的位置
        for j = 1, #readyPositions do
            for n = 1, #temp do
                if readyPositions[j].x == temp[n].x and readyPositions[j].y == temp[n].y then
                    table.remove( temp, n )
                    break
                end
            end
        end

        local rand = math.random( 1, #temp )
        table.insert( readyPositions, temp[rand] )


        local pos = temp[rand]
        if not pos then
            -- 随机到最后一个无路可走，重新随机
            return self:getRanRunPos()
        end

        local org_pos = 0
        for j = 1, 6 do
            if pos.x == initPositions[j].x and pos.y == initPositions[j].y then
                org_pos = j
            end
        end

        local curPos
        for j = 1, 6 do
            if self.objectList[j].flag == i then
                curPos = j
            end
        end

        table.insert(ret, org_pos)
    end

    --[[
    for i = 1, 6 do

        local tips = "当前位置" .. i .. "跑到" .. ret[i]
        Log:D(tips)
        gf:ShowSmallTips(tips)

    end
    --]]
    return ret
end


function ChildDailyMission5Dlg:everyBabyRun()
    self.isSelected = false
    self.times = self.times + 1
    local arrivePositions = {}
    local ret = self:getRanRunPos()
    for i = 1, 6 do

        local curPos
        for j = 1, 6 do
            if self.objectList[j].flag == i then
                curPos = j
            end
        end

        local function callBack(  )
            table.insert( arrivePositions, i )
            self.objectList[curPos]:setAct(Const.FA_STAND)
            if #arrivePositions == 6 then
                self:updateFlag()
                if self.times >= GUANKA_RUN_COUNT then
                    self:gussMyChild()
                    gf:ShowSmallTips(CHS[4101500])
                else

                    self:everyBabyRun()
                    --[[
                    performWithDelay(self.root, function ( )
                            self:everyBabyRun()
                    end, 1.5)
                    --]]
                end
                --]]
            end
        end

        local funData = {func = callBack, para = ""}
        local pos = NPC_POS[ret[i]]
        self.objectList[curPos]:setEndPos(pos.x, pos.y, funData, self.guanka)
    end
end

function ChildDailyMission5Dlg:gussMyChild()
    self.isGuss = true
    local map = {1,2,3,4,5,6}
    local ran = math.random( 1, #map)
    self.objectList[map[ran]]:setChat({msg = CHS[4101501], show_time = 3}, nil, true)

    table.remove( map, ran )
    local ran = math.random( 1, #map)
    self.objectList[map[ran]]:setChat({msg = CHS[4101501], show_time = 3}, nil, true)
end

function ChildDailyMission5Dlg:updateGuanka()
    self:setLabelText("Label_45", string.format( CHS[4101502], self.guanka))
end

function ChildDailyMission5Dlg:beginRun()
    self.isGuss = false
    for _, char in pairs(self.objectList) do
        char:addMagicOnWaist(ResMgr.magic.grey_fog, false)

        if char:queryBasicInt("myChild") == 1 then
            char:setChat({msg = CHS[4101503], show_time = 2}, nil, true)
        end
    end

    performWithDelay(self.root, function ( )
        self:everyBabyRun()
    end, 2)
end

function ChildDailyMission5Dlg:onMyPanel(sender, eventType)
 --   self:everyBabyRun()
end

function ChildDailyMission5Dlg:onRestartButton(sender, eventType)
    self:nextGuank(self.guanka)
    self:setCtrlVisible("ResultPanel", false)
end

function ChildDailyMission5Dlg:onQuitButton2_0(sender, eventType)
    gf:CmdToServer("CMD_CHILD_QUIT_GAME", {is_get_reward = 0})
    DlgMgr:closeDlg(self.name)
end

function ChildDailyMission5Dlg:addFightBg()
    -- 背景地图
    if not self.bgImage then
        self.bgImage = ccui.ImageView:create(ResMgr.ui.fight_bg_img)
        self.bgImage:setAnchorPoint(0.5, 0.5)

        -- 背景黑色进行缩放
        local destScale = math.max((Const.WINSIZE.width + 40) / self.bgImage:getContentSize().width, (Const.WINSIZE.height + 40) / self.bgImage:getContentSize().height)

        self.bgImage:setScale(destScale)
        self.bgImage:setOpacity(204)
    end

    if not self.bgImage2 then
        self.bgImage2 = ccui.ImageView:create(ResMgr.ui.fight_bg_img_center)
        self.bgImage2:setAnchorPoint(0.5, 0.5)
    end

    self.bgImage:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
        Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY())

    self.bgImage2:setPosition(Const.WINSIZE.width / 2 - gf:getMapLayer():getPositionX(),
        Const.WINSIZE.height / 2 - gf:getMapLayer():getPositionY() - 74)

    if not self.bgImage:getParent() then
    gf:getMapLayer():addChild(self.bgImage)
    end

    if not self.bgImage2:getParent() then
  --  gf:getMapLayer():addChild(self.bgImage2)
    end

    -- 创建层，隔绝地板点击事件
 self.croplandLayer = cc.Layer:create()
--    self.croplandLayer = cc.LayerColor:create(cc.c4b(0, 0, 0, 153))
    self.croplandLayer:setPosition(-gf:getMapLayer():getPositionX(), -gf:getMapLayer():getPositionY())

    gf:getMapLayer():addChild(self.croplandLayer)

    local function clickCropLand(sender, event)
        return true
    end

    gf:bindTouchListener(self.croplandLayer, clickCropLand, {
    cc.Handler.EVENT_TOUCH_BEGAN,
        cc.Handler.EVENT_TOUCH_ENDED,
        cc.Handler.EVENT_TOUCH_CANCELLED
    }, false)
end

function ChildDailyMission5Dlg:MSG_CHILD_GAME_RESULT(data)
    self.isResulting = true

    self:setCtrlVisible("ResultPanel", true)
    local panel = self:setCtrlVisible("SuccPanel", true, "ResultPanel")
    self:setCtrlVisible("FailPanel", false, "ResultPanel")

    local xinPanel = self:getControl("Item1Panel")
    self:setImagePlist("RewardImage", ResMgr.ui["small_child_qinmidu"], xinPanel)
    self:setLabelText("NumLabel", CHS[7190534] .. "：" .. data.qinmi, xinPanel)

    self:setCtrlVisible("Item2Panel", false)
    self:setCtrlVisible("Item3Panel", false)

    --[[
        -- 道法
    local daoPanel = self:getControl("Item1Panel")
    self:setImage("RewardImage", ResMgr:getIconPathByName(CHS[4101504]), daoPanel)
    self:setLabelText("NumLabel", CHS[4101504] .. " * " .. data.daofa, daoPanel)

    local xinPanel = self:getControl("Item2Panel")
    self:setImage("RewardImage", ResMgr:getIconPathByName(CHS[4101505]), xinPanel)
    self:setLabelText("NumLabel", CHS[4101505] .. " * " .. data.xinfa, xinPanel)

    local xinPanel = self:getControl("Item3Panel")
    self:setImage("RewardImage", ResMgr:getIconPathByName(CHS[7190534]), xinPanel)
    self:setLabelText("NumLabel", CHS[7190534] .. " * " .. data.qinmi, xinPanel)
--]]
    --self:setCtrlVisible("Item3Panel", false)
end

return ChildDailyMission5Dlg
