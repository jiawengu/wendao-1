-- MoneyTreeDlg.lua
-- Created by huangzz July/28/2017
-- 招财纳福界面

local MoneyTreeDlg = Singleton("MoneyTreeDlg", Dialog)

local COST_DUR = 50

function MoneyTreeDlg:init(id)
    self:bindListener("AddButton", self.onAddButton)
    self:bindListener("StartButton", self.onStartButton)
    self:bindListener("RuleButton", self.onRuleButton)
    
    self.id = id
    self.furniture = HomeMgr:getFurnitureById(id)
    self.furnitureX, self.furnitureY = self.furniture.curX, self.furniture.curY
    
    self:createZCS()
    
    -- self:bindRulePanel()
    
    self:MSG_ZCS_FURNITURE_APPLY_DATA()
    
    self:hookMsg("MSG_ZCS_FURNITURE_APPLY_DATA")
    self:hookMsg("MSG_HOUSE_FURNITURE_OPER")
    self:hookMsg("MSG_PLAY_ZCS_EFFECT")
end

function MoneyTreeDlg:cleanup()
    DragonBonesMgr:removeUIDragonBonesResoure(ResMgr.DragonBones.zhaocaishu, "armatureName")
    local path = ResMgr:getUIArmatureFilePath(ResMgr.ArmatureMagic.zcs_play_magic.name)
    ArmatureMgr:removeArmatureFileInfoByName(path)
    
    -- 关闭该界面时，同时关闭各个子界面
    DlgMgr:closeDlg("MoneyTreeRuleDlg")
end

function MoneyTreeDlg:createZCS()
    self.zcs = DragonBonesMgr:createUIDragonBones(ResMgr.DragonBones.zhaocaishu, "armatureName")

    -- 将 Armature 放到某个 node 上
    self.zcsNode = tolua.cast(self.zcs, "cc.Node")
    local zcsImage = self:getControl("ShowImage", nil, "ShowPanel")
    local size = zcsImage:getContentSize()
    self.zcsNode:setPosition(size.width / 2 - 13, -55)
    zcsImage:addChild(self.zcsNode)
    
    DragonBonesMgr:toPlay(self.zcs, "idle", 0)
end

function MoneyTreeDlg:onAddButton(sender, eventType)
    if not self.furniture then
        return
    end
    
    local nowDur, maxDur = HomeMgr:getDurInfo(self.furniture)
    local cosrCash = HomeMgr:getFixCost(nowDur, maxDur)
    HomeMgr:repairItem(self.furniture, cosrCash)
end

function MoneyTreeDlg:setData()
    if not self.furniture then
        return
    end
    
    local icon = self.furniture:queryBasicInt("icon")
    local name = self.furniture:queryBasic("name")
    local maxDur = HomeMgr:getMaxDur(name) or 0
    self.leftDur =  self.furniture:queryBasicInt("durability") or 0

    -- 招财树图片
    -- self:setImage("ShowImage", ResMgr:getFurniturePath(10031), "ShowPanel")
    self:setLabelText("NameLabel_1", name, "NamePanel")

    -- 招财纳福剩余次数
    self:setLabelText("TimeLabel_1", self.leftNum .. "/" .. self.totalNum)

    -- 招财树耐久度
    self:setLabelText("NaijiuLabel_1", self.leftDur .. "/" .. maxDur)
end

function MoneyTreeDlg:onStartButton(sender, eventType)
    local furn = HomeMgr:getFurnitureById(self.id)
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

    -- 若玩家今日可纳福次数为0，则予以如下弹出提示：
    if self.leftNum == 0 then
        gf:ShowSmallTips(CHS[5400107])
        return
    end

    -- 若当前家具耐久度不足num，则予以如下弹出提示：
    if self.leftDur < COST_DUR then
        gf:ShowSmallTips(CHS[5400108])
        return
    end

    -- 若玩家当前包裹空间不足1格，则予以如下弹出提示：
    if InventoryMgr:getEmptyPosCount() == 0 then
        gf:ShowSmallTips(CHS[5400109])
        return
    end

    HomeMgr:cmdHouseUseFurniture(self.id, "zhaocai", "1")
end

function MoneyTreeDlg:onRuleButton(sender, eventType)
    DlgMgr:openDlg("MoneyTreeRuleDlg")
end

function MoneyTreeDlg:bindRulePanel()
    local panel = self:getControl("AttributeFFPanel")

    local function onTouchBegan(touch, event)
        return true
    end

    local function onTouchMove(touch, event)
    end

    local function onTouchEnd(touch, event)
        panel:setVisible(false)
    end


    -- 创建监听事件
    local listener = cc.EventListenerTouchOneByOne:create()

    -- 设置是否需要传递
    listener:setSwallowTouches(false)
    listener:registerScriptHandler(onTouchBegan, cc.Handler.EVENT_TOUCH_BEGAN)
    listener:registerScriptHandler(onTouchMove, cc.Handler.EVENT_TOUCH_MOVED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_ENDED)
    listener:registerScriptHandler(onTouchEnd, cc.Handler.EVENT_TOUCH_CANCELLED)

    -- 添加监听
    local dispatcher = panel:getEventDispatcher()
    dispatcher:addEventListenerWithSceneGraphPriority(listener, panel)
end

-- 更新纳福次数
function MoneyTreeDlg:MSG_ZCS_FURNITURE_APPLY_DATA()
    local data = HomeMgr.zhaoCaiNaFuNum
    if not data then
        return
    end
    
    self.leftNum = data.leftNum
    self.totalNum = data.totalNum
    
    self:setData()
end

-- 更新耐久度
function MoneyTreeDlg:MSG_HOUSE_FURNITURE_OPER(data)
    if data.furniture_pos == self.id and data.durability then
        self:setData()
    end
end

-- 播放招财树光效
function MoneyTreeDlg:MSG_PLAY_ZCS_EFFECT(data)
    local magic = ArmatureMgr:createArmature(ResMgr.ArmatureMagic.zcs_play_magic.name)
    local showImage = self:getControl("ShowImage", nil, "ShowPanel")
    local size = showImage:getContentSize()
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(size.width / 2, size.height / 2)
    
    local function func(sender, etype, id)
        if etype == ccs.MovementEventType.complete then
            magic:stopAllActions()
            magic:removeFromParent(true)
        end
    end
    
    showImage:addChild(magic)
    magic:getAnimation():setMovementEventCallFunc(func)
    magic:getAnimation():play("Bottom")
    DragonBonesMgr:toPlay(self.zcs, "hit", 1)
end

return MoneyTreeDlg
