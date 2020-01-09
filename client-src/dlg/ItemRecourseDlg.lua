-- ItemRecourseDlg.lua
-- Created by songcw Jan/9/2015
-- 物品来源对话框

local ItemRecourseDlg = Singleton("ItemRecourseDlg", Dialog)

local changeCardInfo = require(ResMgr:getCfgPath("ChangeCardInfo.lua"))

local POLAR_TO_NAME =
{     
    [0] = CHS[6200027], 
    [1] = CHS[3000334], 
    [2] = CHS[3000335], 
    [3] = CHS[3000336], 
    [4] = CHS[3000337], 
    [5] = CHS[3000338]
}
local limitTip = 
-- activity：点击该来源需要判断对应活动是否开启，若未开启给出提示
{
    [1] = {key = CHS[3002837], level = 35, tip = CHS[3002838]},
    [2] = {key = CHS[3002839], level = 30, tip = CHS[3002840]},
    [3] = {key = CHS[3002841], level = 30, tip = CHS[3002840]},
    [4] = {key = CHS[3002842], level = 0, tip = CHS[3002843]},
    [5] = {key = CHS[3002844], level = 0, tip = CHS[3002843]},
    [6] = {key = CHS[3002845], level = 0, tip = CHS[3002843]},
    [7] = {key = "ActivitiesDlg", level = 0, tip = CHS[3002843]},
    [8] = {key = "ArenaStoreDlg", level = 30, tip = CHS[3002840]},
    [9] = {key = CHS[3002846], level = 30, tip = CHS[3002840]},
    [10] = {key = CHS[7000125], level = 0, activity = CHS[7000125], tip = CHS[7002019]},
    [11] = {key = CHS[6200075], level = 0, activity = CHS[6200075], tip = CHS[7002019]},
    [12] = {key = CHS[7002018], level = 0, activity = CHS[7002018], tip = CHS[7002019]},
}

ItemRecourseDlg.rootSize = nil

function ItemRecourseDlg:init()
    self.itemRecourse = {}
    self:bindListener("ItemRecourseDlg", self.onCloseButton)
    
    local recoursePanel = self:getControl("RecourseButton")
    self.recoursePanel = recoursePanel:clone()
    self.recoursePanel:retain()
    recoursePanel:removeFromParent()
    
    self.root:setAnchorPoint(0,0)
    self.rootSize = self.rootSize or self.root:getContentSize()
    self.listSize = self.listSize or self:getControl("ListView"):getContentSize()
    self.blank:setLocalZOrder(Const.ZORDER_FLOATING)
    
    -- 是否是带属性的黑水晶
    self.isAttribBlackCrystal = false
    self.itemName = nil
    self.item = nil
    
    -- 需要获取活动开始时间
    local activityStartTime = ActivityMgr:getStartTimeList()
    if not activityStartTime then
        ActivityMgr:CMD_ACTIVITY_LIST()
    end
end

function ItemRecourseDlg:cleanup()
    if self.recoursePanel then
        self.recoursePanel:release()  
        self.recoursePanel = nil
    end
end

function ItemRecourseDlg:setBlackCrystakType(hasAtt)
    self.isAttribBlackCrystal = hasAtt
end

function ItemRecourseDlg:setInfo(itemName, rect, btnRect, item)
    self.itemName = itemName
    self.item = item
    local itemRecourse = InventoryMgr:getRescourse(itemName, item)
    if self.isAttribBlackCrystal then
        itemRecourse = InventoryMgr:getRescourseByHasAttBlackCrystal(item)
    end
    local list, listSize = self:resetListView("ListView")
    local height = 0
    self.itemRecourse = itemRecourse
    for _, item in pairs(itemRecourse) do
        local recourseButton = self.recoursePanel:clone()       
        recourseButton:setTag(_) 
        local textCtrl = CGAColorTextList:create()
        textCtrl:setString(item)
        textCtrl:updateNow()
        recourseButton:setTitleText(textCtrl:getTextContant())
        local function ctrlTouch(sender, eventType)
            if ccui.TouchEventType.ended == eventType then
                if not DistMgr:checkCrossDist() then return end
                
                if next(self.itemRecourse) == nil then return end 
                local textCtrl = CGAColorTextList:create()
                textCtrl:setString(item)
            
                for i = 1, #limitTip do
                    if gf:findStrByByte(textCtrl:getString(), limitTip[i].key) then
                        -- 等级判断
                        if Me:queryBasicInt("level") < limitTip[i].level then
                            gf:ShowSmallTips(limitTip[i].tip)
                            self:onCloseButton()
                            return
                        end
                        
                        if limitTip[i].level == 0 then
                            if limitTip[i].activity then
                                -- 活动是否开启判断
                                local activityName = limitTip[i].activity
                                if activityName == CHS[7002018] then
                                    -- 活跃抽大奖
                                    if not GiftMgr:isActiveDrawOpen() then
                                        gf:ShowSmallTips(limitTip[i].tip)
                                        return
                                    end
                                else
                                    -- 福利活动列表中的活动
                                    if not ActivityMgr:isWelfareActivityBegin(activityName) then
                                        gf:ShowSmallTips(limitTip[i].tip)
                                        return
                                    end
                                end
                            else
                                -- 图标开启判断
                                -- 18为活动图标，具体看cfg/MainIconItemInfo.lua
                                if not GuideMgr:isIconExist(18) then
                                    gf:ShowSmallTips(limitTip[i].tip)
                                    return
                                end
                            end
                        end
                    end
                end
                
                -- 修炼卷轴，需要判断是否有师徒关系
                if item == CHS[4100326] and self.itemName == CHS[4100323] then
                    if not MasterMgr:isHasMasterRelation() then
                        gf:ShowSmallTips(CHS[4100327])
                        self:onCloseButton()
                        return
                    end
                end
                
                -- 设置来源打开的物品。时装需要更具具体物品，显示商城、集市
                local itemInfo = InventoryMgr:getItemInfoByName(self.itemName)
                if itemInfo and itemInfo.item_class == ITEM_CLASS.FASHION then
                    if self.item then
                        InventoryMgr:setRecourseItem(self.item)
                    else
                        local tempItem = {name = self.itemName, alias = self.itemName .. "·30天", fasion_type = FASION_TYPE.FASION}
                        InventoryMgr:setRecourseItem(tempItem)
                    end
                else
                    InventoryMgr:setRecourseItem()
                end
                
            
                -- 处理类型点击
                local callBackType = gf:onCGAColorText(textCtrl)
                if callBackType == CONST_DATA.CS_TYPE_ZOOM or callBackType == CONST_DATA.CS_TYPE_NPC then
                    -- 关闭一般性界面
                    DlgMgr:closeAllNormalDlg()
                end                
                
                if CONST_DATA.CS_TYPE_STRING ~= callBackType then
                    self:onCloseButton()
                    DlgMgr:closeDlg("ItemInfoDlg")
                    DlgMgr:closeDlg("ChangeCardInfoDlg")
                    DlgMgr:closeDlg("FashionDressInfoDlg")
                end
                
            end
        end
        
        recourseButton:setTouchEnabled(true)
        recourseButton:addTouchEventListener(ctrlTouch)
        list:pushBackCustomItem(recourseButton)
        height = recourseButton:getContentSize().height + height
    end 

    
    if height > self.listSize.height then height = self.listSize.height end
    local dis = self.listSize.height - height
    list:setContentSize(self.listSize.width, height)
    self.root:setContentSize(self.rootSize.width,self.rootSize.height - dis)
    
    if not rect then
        self:align(ccui.RelativeAlign.centerInParent)
        return
    end

    local midX = rect.x / Const.UI_SCALE + rect.width * 0.5
    local size = self.root:getContentSize()
    if midX >= Const.WINSIZE.width * 0.5 then
    -- 显示在左边
        local pos = cc.p(rect.x / Const.UI_SCALE - size.width, (rect.y + rect.height) / Const.UI_SCALE - size.height)
        if pos.x < 0 and btnRect then
            self:setFloatingFramePos(btnRect)
        else
            self.root:setPosition(pos)
        end
    else
    -- 显示在右边
        local pos = cc.p((rect.x + rect.width) / Const.UI_SCALE, (rect.y + rect.height) / Const.UI_SCALE - size.height)
        if pos.x > Const.WINSIZE.width - self.rootSize.width and btnRect then
            self:setFloatingFramePos(btnRect)
        else
            self.root:setPosition(pos)
        end
    end
end

function ItemRecourseDlg:chooseButtion(sender, eventType)
    self:onCloseButton()
end

return ItemRecourseDlg
