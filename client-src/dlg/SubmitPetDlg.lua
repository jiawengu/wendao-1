-- SubmitPetDlg.lua
-- Created by songcw June/29/2015
-- 宠物提交界面

local SubmitPetDlg = Singleton("SubmitPetDlg", Dialog)

function SubmitPetDlg:init()

    self:bindListener("SubmitButton", self.onSubmitButton)
    self:bindListener("CancelButton", self.onCancelButton)

    self:bindListViewListener("PetListView", self.onSelectPetListView)

    self.petListView = self:getControl("PetListView"):clone()
    self.petListView:retain()

    -- 克隆选中效果
    self.selectEff = self:getControl("ChosenEffectImage"):clone()
    self.selectEff:setVisible(true)
    self.selectEff:retain()

    -- 克隆单个Panel
    self.petPanel = self:getControl("SinglePetPanel")
    self.petPanel:retain()
    self.petPanel:removeFromParent()

    self.pets = nil
    self.petId = 0

    self:setCtrlVisible("StatusImage_0", false, self.petPanel)
    self:setCtrlVisible("StatusImage", false, self.petPanel)

    self:hookMsg("MSG_ENTER_GAME")
end

function SubmitPetDlg:cleanup()
    self:releaseCloneCtrl("petPanel")
    self:releaseCloneCtrl("selectEff")
    self:releaseCloneCtrl("petListView")
end

-- pets 宠物列表
function SubmitPetDlg:setSubmintPet(pets, type)
    if #pets == 0 then
        self:setPetAttrib()
        return
    end

    self.pets = pets

    local listView = self:resetListView("PetListView", 5, ccui.ListViewGravity.centerHorizontal)

    for id, pet in pairs(pets) do
        local singelPanel = self.petPanel:clone()
        singelPanel:setTag(pet:getId())
        self:setPet(pet, singelPanel)
        listView:pushBackCustomItem(singelPanel)
    end

    self:onSelectPetListView(listView)

    self.type = type
    self:doTypeUI()
end

function SubmitPetDlg:doTypeUI()
    local type = self.type
    if not type then
        return
    end

    if type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_FEISHENG then
       self:setLabelText("Label_1", CHS[7003083],"SubmitButton")
       self:setLabelText("Label_2", CHS[7003083],"SubmitButton")
       self:setLabelText("Label_1", CHS[7003082],"TitlePanel")
        self:setLabelText("Label_2", CHS[7003082],"TitlePanel")
    end

    if type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_BUYBACK then
        self:setLabelText("Label_1", CHS[5420165], "TitlePanel")
        self:setLabelText("Label_2", CHS[5420165], "TitlePanel")
    end
end

function SubmitPetDlg:setPet(pet, panel)
    -- 头像
    local portrait = pet:queryBasicInt("portrait")
    self:setImage("GuardImage", ResMgr:getSmallPortrait(portrait), panel)
    self:setItemImageSize("GuardImage", panel)

    -- 等级
    self:setLabelText("LevelLabel", "LV." .. pet:queryBasic("level"), panel)

    -- 名字
  --[[  local type = pet:queryInt('rank')
    local typeStr = ""
    if type == Const.PET_RANK_WILD then
        typeStr = CHS[3003664]
    elseif type == Const.PET_RANK_BABY then
        typeStr = CHS[3003665]
    elseif type == Const.PET_RANK_ELITE then
        typeStr = CHS[3003666]
    elseif type == Const.PET_RANK_EPIC then
        typeStr = CHS[3003667]
    elseif type == Const.PET_RANK_GUARD then
        typeStr = CHS[3003668]
    end]]
    self:setLabelText("NameLabel", gf:getPetName(pet.basic), panel)

    -- 参战状态
    local pet_status = pet:queryInt("pet_status")
    if pet_status == 1 then
        -- 参战
        self:setImage("StatusImage", ResMgr.ui.canzhan_flag, panel)
    elseif pet_status == 2 then
        -- 掠阵
        self:setImage("StatusImage", ResMgr.ui.luezhen_flag, panel)
    elseif PetMgr:isRidePet(pet:getId()) then
        -- 骑乘
        self:setCtrlVisible("StatusImage", true, panel)
        self:setImage("StatusImage", ResMgr.ui.ride_flag, panel)
    else
        -- 透明图片
        self:setImagePlist("StatusImage", ResMgr.ui.touming, panel)
    end
end

function SubmitPetDlg:addSelectEffect(sender)
    self.selectEff:removeFromParent()
    sender:addChild(self.selectEff)
end

function SubmitPetDlg:onSelectPetListView(sender, eventType)
    -- 选中效果
    local panel = self:getListViewSelectedItem(sender)
    self:addSelectEffect(panel)

    local petId = self:getListViewSelectedItemTag(sender)
    self:setPetAttrib(petId)

    self.petId = petId
end

function SubmitPetDlg:setPetAttrib(petId)
    local panel = self:getControl("PetInfoPanel")
    local pet = PetMgr.pets[petId]
    if petId == nil or pet == nil then
        self:setLabelText("LifeValueLabel", "", panel)
        self:setLabelText("ManaValueLabel", "", panel)
        self:setLabelText("SpeedValueLabel", "", panel)
        self:setLabelText("PhyValueLabel", "", panel)
        self:setLabelText("MagValueLabel", "", panel)
        self:setLabelText("IntimacyValueLabel", "", panel)
        self:setLabelText("MartialValueLabel", "", panel)
        return
    end

    -- 头像
    local portrait = pet:queryBasicInt("portrait")
    self:setImage("PetIconImage", ResMgr:getSmallPortrait(portrait), panel)
    self:setItemImageSize("PetIconImage", panel)

    local mount_type = pet:queryInt("mount_type")
    if 0  ~= mount_type then
        -- 阶位
        self:setLabelText("LevelValueLabel",  string.format(CHS[6000532], PetMgr:getMountRankStr(pet)))
    else
        -- 阶位
        self:setLabelText("LevelValueLabel", CHS[3001385])
    end

    -- 等级
    self:setLabelText("LevelLabel", "LV." .. pet:queryBasic("level"), "PetItemPanel")

    -- 名字
    self:setLabelText("NameLabel", gf:getPetName(pet.basic), panel)

    -- 血量
    self:setLabelText("LifeValueLabel", pet:queryInt("pet_life_shape"), panel)
    -- 法力
    self:setLabelText("ManaValueLabel", pet:queryInt("pet_mana_shape"), panel)
    -- 速度
    self:setLabelText("SpeedValueLabel", pet:queryInt("pet_speed_shape"), panel)
    -- 物理
    self:setLabelText("PhyValueLabel", pet:queryInt("pet_phy_shape"), panel)
    -- 法攻
    self:setLabelText("MagValueLabel", pet:queryInt("pet_mag_shape"), panel)
    -- 亲密
    self:setLabelText("IntimacyValueLabel", pet:queryInt("intimacy"), panel)
    -- 武学
    self:setLabelText("MartialValueLabel", pet:queryInt("martial"), panel)
end

function SubmitPetDlg:onSubmitButton(sender, eventType)

    local ctrlView = self:getControl("PetListView")
    local petId = self.petId

    local pet = PetMgr:getPetById(petId)
    local type = self.type
    if not pet then return end

    if PetMgr:isFeedStatus(pet) then
        gf:ShowSmallTips(CHS[5410091])
        return
    end

   if PetMgr:isCFZHStatus(pet) then
        gf:ShowSmallTips(CHS[2500066])
        return
   end

    if type ~= SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_FEISHENG
        and self.type ~= SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_BUYBACK
        and self.type ~= SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_FEED then
        -- 宠物飞升提交宠物允许提交参战/掠阵宠物

        -- 参战状态
        local pet_status = pet:queryInt("pet_status")
        if pet_status == 1 then
            -- 参战
            gf:ShowSmallTips(CHS[3003669])
            return
        elseif pet_status == 2 then
            -- 掠阵
            gf:ShowSmallTips(CHS[3003670])
            return
        end
    end

    if type == "jingguai" then --精怪提交

        -- 如果精怪已经超时了，则弹出提示并刷新宠物列表
        if PetMgr:isPetTimeOut(pet) then
            gf:ShowSmallTips(CHS[7000099])
            local petList = {}
            for i = 1, #self.pets do
                if self.pets[i] ~= pet then
                    table.insert(petList, self.pets[i])
                end
            end

            -- 如果列表为空，直接关闭界面
            if #petList == 0 then
                self:close()
                return
            end

            self:getControl("PetListView"):removeFromParent()
            self:getControl("PetPanel"):addChild(self.petListView:clone())
            self:setSubmintPet(petList, "jingguai")
            return
        end

        -- 通知PetHorseTameDlg提交的是哪一只精怪
        DlgMgr:sendMsg("PetHorseTameDlg", "refreshBasicInfo", pet)
        self:onCloseButton()
    elseif self.type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_BUYBACK then
        -- 参战状态
        local pet_status = pet:queryInt("pet_status")
        if pet_status == 1 then
            -- 参战
            gf:ShowSmallTips(string.format(CHS[5420166], CHS[2000026]))
            return
        elseif pet_status == 2 then
            -- 掠阵
            gf:ShowSmallTips(string.format(CHS[5420166], CHS[2000027]))
            return
        elseif PetMgr:isRidePet(pet:getId()) then
            -- 骑乘
            gf:ShowSmallTips(string.format(CHS[5420166], CHS[5420167]))
            return
        end

        gf:CmdToServer("CMD_DESTROY_VALUABLE",
            {type = Const.BUYBACK_TYPE_PET, id = petId})
    elseif self.type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_FEED or self.type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_INNER_ALLCHEMY then
        gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SUBMIT_PET, petId)
        self:onCloseButton()
    else
        local tip = CHS[3003671]
        if self.type and self.type == SUBMIT_PET_TYPE.SUBMIT_PET_TYPE_FEISHENG then
            -- 宠物飞升提交宠物的提示不同
            tip = CHS[7003084]
        end

        gf:confirm(string.format(tip, gf:getPetName(pet.basic)), function()
            -- 宠物提交
            gf:sendGeneralNotifyCmd(NOTIFY.NOTIFY_SUBMIT_PET, petId)
            self:onCloseButton()
        end)
    end
end

function SubmitPetDlg:onCancelButton(sender, eventType)
    self:onCloseButton()
end

function SubmitPetDlg:MSG_ENTER_GAME(data)
    self:onCloseButton()
end

return SubmitPetDlg
