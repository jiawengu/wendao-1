-- PetRawSkillChildDlg.lua
-- Created by liuhb Jan/27/2015
-- 宠物天生技能界面

local PetRawSkillChildDlg = Singleton("PetRawSkillChildDlg", Dialog)

local MARGIN = 0

function PetRawSkillChildDlg:getCfgFileName()
    return ResMgr:getDlgCfg("PetDevelopSkillChildDlg");
end

function PetRawSkillChildDlg:init()
    self:bindListener("ReturnButton", self.onReturnButton)
    self:bindListener("UpButton", self.onUpButton)
    self:hookMsg("MSG_UPDATE_SKILLS")

    -- 添加PageView事件
    self.pageView = self:getControl("PageView", Const.UIPageView)
    self.pageView:scrollToPage(1)
    performWithDelay(self.pageView, function()
        if nil == self.pageView then return end

        self.pageView:scrollToPage(0)
        DlgMgr:sendMsg("PetSkillDlg", "setOpenSmallDlg", false)
        
        -- 绑定关闭窗口监听
        self.pageView:addEventListener(function(sender, eventType)
            Log.D("", CHS[3003409] .. self.name .. "eventType : " .. eventType)
            if ccui.PageViewEventType.turning == eventType and 1 == self.pageView:getCurPageIndex() then
                if true == DlgMgr:isDlgOpened(self.name) then
                    Dialog.close(self)
                end
            end
        end)
    end, 0)
end

function PetRawSkillChildDlg:MSG_UPDATE_SKILLS(data)
    self:setSkillInfo(self.no)
end

function PetRawSkillChildDlg:cleanup()
    self.pageView = nil
    DlgMgr:sendMsg("PetSkillDlg", "setOpenSmallDlg", false)
end

function PetRawSkillChildDlg:onReturnButton(sender, eventType)
    self.pageView = self:getControl("PageView", Const.UIPageView)
    self.pageView:scrollToPage(1)
end

function PetRawSkillChildDlg:onUpButton(sender, eventType)
    -- 获取宠物信息
    local pet = DlgMgr:sendMsg("PetListChildDlg", "getCurrentPet")

    local partyName = Me:queryBasic("party/name")
    if partyName == "" then
        gf:ShowSmallTips(CHS[3000123])
        return
    end

    -- 获取帮贡跟金钱信息
    local skillWithPet = SkillMgr:getSkill(pet:getId(), self.no)
    local costCash = skillWithPet.cost_cash or 0
    local costContrib = skillWithPet["cost_party/contrib"] or 0
    local meCash = Me:queryInt("cash") or 0
    local meContrib = Me:queryInt("party/contrib") or 0

    if costCash <= meCash and costContrib <= meContrib then
    -- 进行计算消耗
        PetMgr:studyInnateSkill( pet:getId(), self.no)
    else
        -- 提示条件不足
        gf:ShowSmallTips(CHS[2000003])
        
    end
end

-- 设置宠物名称
function PetRawSkillChildDlg:setPetName(petName)
    self:setLabelText('NameLabel', petName)
end

function PetRawSkillChildDlg:setSkillInfo( skillNo )
    if nil == skillNo then return end

    -- 获取宠物信息
    local pet = DlgMgr:sendMsg("PetListChildDlg", "getCurrentPet")
    local level = pet:queryBasicInt("level")

    -- 获取技能信息
    local skillName = SkillMgr:getSkillName(skillNo) -- 名称
    self.no = skillNo
    local skillWithPet = SkillMgr:getSkill(pet:getId(), skillNo)
    local skillDis = SkillMgr:getSkillDesc(skillName)
    local skillIconPath = SkillMgr:getSkillIconPath(skillNo)
    if nil == skillIconPath then return end

    -- 设置窗口技能信息
    self:setImage("SkillImage", skillIconPath)
    self:setItemImageSize("SkillImage")
    self:setLabelText("SkillNameLabel", skillName)
    local desc = skillDis.pet_desc
    if nil == desc then desc = skillDis.desc end
    self:setLabelText("DescriptionLabel", string.format(CHS[5000002], desc))
    
    --[[
    local textCtrl = self:getControl("DescriptionLabel")
    local contentSize = textCtrl:getContentSize()

    -- 创建listView
    local list = ccui.ListView:create()
    if nil == list then return end

    list:setContentSize(contentSize)
    list:removeAllItems()
    list:setGravity(ccui.ListViewGravity.left)
    list:setTouchEnabled(true)
    list:setItemsMargin(0)
    list:setClippingEnabled(true)

    -- 获取labelText
    local item = CGAColorTextList:create()
    item:setFontSize(20)
    item:setContentSize(contentSize.width - MARGIN * 2, 0)
    item:setString(string.format(CHS[5000002], desc))
    item:setPosition(MARGIN, contentSize.height - MARGIN)
    item:updateNow()

    local panel = ccui.Layout:create()
    local itemW, itemH = item:getRealSize()
    panel:setContentSize({height = itemH, width = itemW})
    local layer = tolua.cast(item, "cc.LayerColor")
    panel:addChild(layer)
    gf:align(layer, panel:getContentSize(), ccui.RelativeAlign.alignParentTopLeft)
    list:pushBackCustomItem(panel)

    textCtrl:addChild(list) --]]

    if nil == skillWithPet then
        self:setLabelText("SkillLevelLabel", "")
        self:setLabelText("TargetNumLabel", "")
        self:setLabelText("CostManaLabel", "")
        return
    end
    self:setLabelText("SkillLevelLabel", string.format(CHS[3003410], skillWithPet.skill_level, math.floor(level * 1.6)))
    self:setLabelText("TargetNumLabel", string.format(CHS[5000004], skillWithPet.range))
    self:setLabelText("CostManaLabel", string.format(CHS[5000005], skillWithPet.skill_mana_cost))

    -- 获取帮贡跟金钱信息
    local costCash = skillWithPet.cost_cash or 0
    local costContrib = skillWithPet["cost_party/contrib"] or 0

    local meCash = Me:queryInt("cash") or 0
    local meContrib = Me:queryInt("party/contrib") or 0

    if costCash > meCash then
        self:setLabelText("CashValueLabel", costCash, nil, COLOR3.RED)
    else
        self:setLabelText("CashValueLabel", costCash, nil, COLOR3.BLACK)
    end

    if costContrib > meContrib then
        self:setLabelText("ContribValueLabel", costContrib, nil, COLOR3.RED)
    else
        self:setLabelText("ContribValueLabel", costContrib, nil, COLOR3.BLACK)
    end
end

return PetRawSkillChildDlg
