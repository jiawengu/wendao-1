-- GMRolePropertiesDlg.lua
-- Created by songcw Mar/04/2017
-- GM角色属性配置

local GMRolePropertiesDlg = Singleton("GMRolePropertiesDlg", Dialog)
local RadioGroup = require("ctrl/RadioGroup")

-- 代码中会更新这个表，修改时也要修改更新
GMRolePropertiesDlg.VALUE_RANGE = {
    ["LevelNumPanel"] = {MIN = 1, MAX = Const.PLAYER_MAX_LEVEL, DEF = Me:queryInt("level"), notNeedChanegColor = true},
    ["PotNumPanel"] = {MIN = 0, MAX = 2 * math.pow(10, 9), DEF = Me:query("pot"), notNeedChanegColor = true},
    ["TaoNumPanel_1"] = {MIN = 0, MAX = 1 * math.pow(10, 5), DEF = math.floor(Me:queryBasicInt("tao") / 360), notNeedChanegColor = true},
    ["LifeNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("max_life")},
    ["ManaNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("max_mana")},
    ["Phy_powerNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("phy_power")},
    ["Mag_powerNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("mag_power")},
    ["DefenceNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("def")},
    ["SpeedNumPanel"] = {MIN = 1, MAX = 30000, DEF = Me:queryInt("speed")},
}

local UPGRADE_TYPE_CHECH_BOX = {
    "UpgradeCheckBox1", "UpgradeCheckBox2", 
}

function GMRolePropertiesDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)
    self:bindListener("RefineButton", self.onRefineButton)    
    
    self:updataValueConst()

--  不用单选框时因为，它能取消！    
    self:bindListener("UpgradeCheckBox1", self.setUpgradeCheckBox)
    self:bindListener("UpgradeCheckBox2", self.setUpgradeCheckBox)
    self:bindListener("UpgradeCheckBox3", self.setUpgradeXianmoCheckBox)
    
    GMMgr:bindEditBoxForGM(self, "LevelNumPanel", self.levelDownCallBack)
    GMMgr:bindEditBoxForGM(self, "PotNumPanel")
    GMMgr:bindEditBoxForGM(self, "TaoNumPanel_1", self.taoDownCallBack)
    GMMgr:bindEditBoxForGM(self, "LifeNumPanel")
    GMMgr:bindEditBoxForGM(self, "ManaNumPanel")
    GMMgr:bindEditBoxForGM(self, "Phy_powerNumPanel")
    GMMgr:bindEditBoxForGM(self, "Mag_powerNumPanel")
    GMMgr:bindEditBoxForGM(self, "DefenceNumPanel")
    GMMgr:bindEditBoxForGM(self, "SpeedNumPanel")
    
    -- 设置当前属性属性
    self:setNowUserAttrib()    
    
    self:hookMsg("MSG_UPDATE_IMPROVEMENT")
    self:hookMsg("MSG_UPDATE")
end

function GMRolePropertiesDlg:setUpgradeCheckBox(sender, eventType)  
    if sender:getSelectedState() == true then
    
        local otherCheckBox = sender:getName() == "UpgradeCheckBox2" and "UpgradeCheckBox1" or "UpgradeCheckBox2"
    
        self:setCheck(otherCheckBox, false)
        if Me:queryInt("level") < 110 then
            gf:ShowSmallTips(CHS[4200483])
            sender:setSelectedState(false)
            self:setLabelText("UpgradeLabel2_1", CHS[4200484])
            return
        end
        
        if sender:getName() == "UpgradeCheckBox2" then
            self:setLabelText("UpgradeLabel2_1", CHS[4200485])            
        else
            self:setLabelText("UpgradeLabel2_1", CHS[4200486])
        end
    else
        if Me:queryInt("level") > 115 then
            gf:ShowSmallTips(CHS[4200487])
            sender:setSelectedState(true)
            return
        end
        
        self:setLabelText("UpgradeLabel2_1", CHS[4200484])
    end 
end

function GMRolePropertiesDlg:setUpgradeXianmoCheckBox(sender, eventType)    
    if sender:getSelectedState() == true then
        if Me:queryInt("level") < 120 then
            gf:ShowSmallTips(CHS[4200488])
            sender:setSelectedState(false)
            return
        end
        
        if not self:isCheck("UpgradeCheckBox1") and not self:isCheck("UpgradeCheckBox2") then
            gf:ShowSmallTips(CHS[4200489])
            sender:setSelectedState(false)
            return
        end
        
    else
    end
end

--[[
function GMRolePropertiesDlg:onXueYingCheckBox(sender, eventType)
    if sender:getSelectedState() == true then
        self:setCheck("UpgradeCheckBox1", false)
        if Me:queryInt("level") < 110 then
            gf:ShowSmallTips("角色等级需大于110级才可进行小飞操作。")
            sender:setSelectedState(false)
            return
        end
    else
        if Me:queryInt("level") > 115 then
            gf:ShowSmallTips("角色等级需小于115级才可取消小飞状态。")
            return
        end
    end
end
--]]
-- 等级输入完成后的回调
function GMRolePropertiesDlg:levelDownCallBack(sender, value)
    local level = value

    -- 设置玩家等级
    GMMgr:setAdminLevel(level)    
end

-- 等级道行完成后的回调
function GMRolePropertiesDlg:taoDownCallBack(sender, value)
    local tao = value

    if tao == 0 then
        self:setLabelText("TaoLabel_2", string.format(CHS[4100474], tao))
        return
    end

    local level = Me:queryBasicInt("level")
    self:setLabelText("TaoLabel_2", string.format(CHS[4100474], tao * 360 / math.floor(Formula:getStdTao(level))))
end

function GMRolePropertiesDlg:updataValueConst()
    self.VALUE_RANGE = {
        ["LevelNumPanel"] = {MIN = 1, MAX = Const.PLAYER_MAX_LEVEL, DEF = Me:queryInt("level"), notNeedChanegColor = true},
        ["PotNumPanel"] = {MIN = 0, MAX = 2 * math.pow(10, 9), DEF = Me:query("pot"), notNeedChanegColor = true},
        ["TaoNumPanel_1"] = {MIN = 0, MAX = 1 * math.pow(10, 5), DEF = math.floor(Me:queryBasicInt("tao") / 360), notNeedChanegColor = true},
        ["LifeNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("max_life")},
        ["ManaNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("max_mana")},
        ["Phy_powerNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("phy_power")},
        ["Mag_powerNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("mag_power")},
        ["DefenceNumPanel"] = {MIN = 1, MAX = 1 * math.pow(10, 6), DEF = Me:queryInt("def")},
        ["SpeedNumPanel"] = {MIN = 1, MAX = 30000, DEF = Me:queryInt("speed")},
    }
end

-- 设置当前
function GMRolePropertiesDlg:setNowUserAttrib()
    -- 姓名
    self:setInputText("NameTextField", Me:queryBasic("name"), nil, COLOR3.WHITE)

    -- 道行
    GMMgr:setEditBoxValue(self, "TaoNumPanel_1", math.floor(Me:queryBasicInt("tao") / 360), COLOR3.WHITE)

    self:taoDownCallBack(nil, math.floor(Me:queryBasicInt("tao") / 360))

    -- 等级
    GMMgr:setEditBoxValue(self, "PotNumPanel", Me:queryInt("level"), COLOR3.WHITE)

    -- 潜能
    GMMgr:setEditBoxValue(self, "PotNumPanel", Me:query("pot"), COLOR3.WHITE)

    -- 气血
    local color = COLOR3.WHITE
    if Me:queryInt("gm_attribs/max_life") < 0 then color = COLOR3.RED end
    if Me:queryInt("gm_attribs/max_life") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "LifeNumPanel", (Me:queryInt("max_life")), color)

    -- 法力
    color = COLOR3.WHITE
    if Me:queryInt("gm_attribs/max_mana") < 0 then color = COLOR3.RED end
    if Me:queryInt("gm_attribs/max_mana") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "ManaNumPanel", Me:queryInt("max_mana"), color)

    -- 物伤
    color = COLOR3.WHITE
    if Me:queryInt("gm_attribs/phy_power") < 0 then color = COLOR3.RED end
    if Me:queryInt("gm_attribs/phy_power") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "Phy_powerNumPanel", Me:query("phy_power"), color)

    -- 法伤
    color = COLOR3.WHITE
    if Me:queryInt("gm_attribs/mag_power") < 0 then color = COLOR3.RED end
    if Me:queryInt("gm_attribs/mag_power") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "Mag_powerNumPanel", Me:query("mag_power"), color)

    -- 防御
    color = COLOR3.WHITE
    if Me:queryInt("gm_attribs/def") < 0 then color = COLOR3.RED end
    if Me:queryInt("gm_attribs/def") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "DefenceNumPanel", Me:query("def"), color)

    -- 速度
    color = COLOR3.WHITE
    if Me:queryInt("gm_attribs/speed") < 0 then color = COLOR3.RED end
    if Me:queryInt("gm_attribs/speed") > 0 then color = COLOR3.GREEN end
    GMMgr:setEditBoxValue(self, "SpeedNumPanel", Me:query("speed"), color)
    
    self:updateUpgrade()
end

-- 设置回原始
function GMRolePropertiesDlg:resetUserAttrib()
    -- 姓名
    self:setInputText("NameTextField", Me:queryBasic("name"), nil, COLOR3.WHITE)
    
    -- 道行
    GMMgr:setEditBoxValue(self, "TaoNumPanel_1", math.floor(Me:queryBasicInt("tao") / 360), COLOR3.WHITE)
    
    self:taoDownCallBack(nil, math.floor(Me:queryBasicInt("tao") / 360))
    
    -- 等级
    GMMgr:setEditBoxValue(self, "LevelNumPanel", Me:queryInt("level"), COLOR3.WHITE)
    
    -- 潜能
    GMMgr:setEditBoxValue(self, "PotNumPanel", Me:query("pot"), COLOR3.WHITE)
    
    -- 气血
    GMMgr:setEditBoxValue(self, "LifeNumPanel", (Me:queryInt("max_life") - Me:queryInt("gm_attribs/max_life")), COLOR3.WHITE)
    
    -- 法力
    GMMgr:setEditBoxValue(self, "ManaNumPanel", Me:queryInt("max_mana") - Me:queryInt("gm_attribs/max_mana"), COLOR3.WHITE)
    
    -- 物伤
    GMMgr:setEditBoxValue(self, "Phy_powerNumPanel", Me:queryInt("phy_power") - Me:queryInt("gm_attribs/phy_power"), COLOR3.WHITE)
    
    -- 法伤
    GMMgr:setEditBoxValue(self, "Mag_powerNumPanel", Me:queryInt("mag_power") - Me:queryInt("gm_attribs/mag_power"), COLOR3.WHITE)
    
    -- 防御
    GMMgr:setEditBoxValue(self, "DefenceNumPanel", Me:queryInt("def") - Me:queryInt("gm_attribs/def"), COLOR3.WHITE)
    
    -- 速度
    GMMgr:setEditBoxValue(self, "SpeedNumPanel", Me:queryInt("speed") - Me:queryInt("gm_attribs/speed"), COLOR3.WHITE)
    
    self:updateUpgrade()
end

function GMRolePropertiesDlg:onConfirmButton(sender, eventType)

    -- 潜能
    local pot = tonumber(GMMgr:getEditBoxValue(self, "PotNumPanel"))
    
    -- 道行
    local tao = tonumber(GMMgr:getEditBoxValue(self, "TaoNumPanel_1"))
    
    -- 气血
    local life = tonumber(GMMgr:getEditBoxValue(self, "LifeNumPanel")) - (Me:queryInt("max_life") - Me:queryInt("gm_attribs/max_life"))
    
    -- 法力
    local mana = tonumber(GMMgr:getEditBoxValue(self, "ManaNumPanel")) - (Me:queryInt("max_mana") - Me:queryInt("gm_attribs/max_mana"))
    
    -- 物伤
    local phy = tonumber(GMMgr:getEditBoxValue(self, "Phy_powerNumPanel")) - (Me:queryInt("phy_power") - Me:queryInt("gm_attribs/phy_power"))
    
    -- 法伤
    local mag = tonumber(GMMgr:getEditBoxValue(self, "Mag_powerNumPanel")) - (Me:queryInt("mag_power") - Me:queryInt("gm_attribs/mag_power"))

    -- 防御
    local def = tonumber(GMMgr:getEditBoxValue(self, "DefenceNumPanel")) - (Me:queryInt("def")   - Me:queryInt("gm_attribs/def"))
    
    -- 速度
    local speed = tonumber(GMMgr:getEditBoxValue(self, "SpeedNumPanel")) - (Me:queryInt("speed") - Me:queryInt("gm_attribs/speed"))
    
    local flyTag = CHILD_TYPE.NO_CHILD
    if self:isCheck("UpgradeCheckBox1") then
        flyTag = CHILD_TYPE.YUANYING
        if self:isCheck("UpgradeCheckBox3") then
            flyTag = CHILD_TYPE.UPGRADE_IMMORTAL
        end
    elseif self:isCheck("UpgradeCheckBox2") then
        flyTag = CHILD_TYPE.XUEYING
        if self:isCheck("UpgradeCheckBox3") then
            flyTag = CHILD_TYPE.UPGRADE_MAGIC
        end
    end
    
    local attrib = pot .. "|" .. tao .. "|" .. life .. "|" .. mana .. "|" .. phy .. "|" .. mag .. "|" .. def .. "|" .. speed .. "|" .. flyTag
    
    GMMgr:setAdminAttrib(attrib)
end

function GMRolePropertiesDlg:onRefineButton(sender, eventType)
    self:resetUserAttrib()
end

function GMRolePropertiesDlg:MSG_UPDATE_IMPROVEMENT(data)
    self:updataValueConst()
    self:setNowUserAttrib()
end

-- 刷新元婴、血婴、仙魔信息
function GMRolePropertiesDlg:updateUpgrade()

    self:setCheck("UpgradeCheckBox1", Me:getChildType() == CHILD_TYPE.YUANYING or Me:getChildType() == CHILD_TYPE.UPGRADE_IMMORTAL)
    self:setCheck("UpgradeCheckBox2", Me:getChildType() == CHILD_TYPE.XUEYING or Me:getChildType() == CHILD_TYPE.UPGRADE_MAGIC)
    self:setCheck("UpgradeCheckBox3", Me:isFlyToXianMo())
    
    if self:isCheck("UpgradeCheckBox2") then
        self:setLabelText("UpgradeLabel2_1", CHS[4200485])            
    elseif self:isCheck("UpgradeCheckBox1") then
        self:setLabelText("UpgradeLabel2_1", CHS[4200486])
    end
end

function GMRolePropertiesDlg:MSG_UPDATE(data)
    if data["upgrade/type"] then
        self:updateUpgrade()
    end
end

return GMRolePropertiesDlg
