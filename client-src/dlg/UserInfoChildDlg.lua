-- UserInfoChildDlg.lua
-- Created by cheny Dec/17/2014
-- 角色基本属性界面

local UserInfoChildDlg = Singleton("UserInfoChildDlg", Dialog)

function UserInfoChildDlg:init()
    self:resetInfo()
    self:hookMsg("MSG_PRE_ASSIGN_ATTRIB")
end

function UserInfoChildDlg:resetInfo(notResetAddValue)
    self:setLabelText("LifeValueLabel", Me:query("max_life"))
    self:setLabelText("ManaValueLabel", Me:query("max_mana"))
    self:setLabelText("PhyPowerValueLabel", Me:query("phy_power"))
    self:setLabelText("MagPowerValueLabel", Me:query("mag_power"))
    self:setLabelText("SpeedValueLabel", Me:query("speed"))
    self:setLabelText("DefenceValueLabel", Me:query("def"))
    
    if notResetAddValue then
        return
    end
    
    self:setDelta("LifeAddValueLabel", 0)
    self:setDelta("ManaAddValueLabel", 0)
    self:setDelta("PhyPowerAddValueLabel", 0)
    self:setDelta("MagPowerAddValueLabel", 0)
    self:setDelta("SpeedAddValueLabel", 0)
    self:setDelta("DefenceAddValueLabel", 0)
end

function UserInfoChildDlg:setDelta(name, value)
    local ctl = self:getControl(name)
    if ctl == nil then return end

    if value > 0 then
        ctl:setString("+" .. value)
        ctl:setColor(COLOR3.GREEN)
    elseif value < 0 then
        ctl:setString(tostring(value))
        ctl:setColor(COLOR3.RED)
    else
        ctl:setString("")
    end
end

function UserInfoChildDlg:MSG_PRE_ASSIGN_ATTRIB(data)
    if data.id ~= 0 then return end -- 不是自己

    self:setDelta("LifeAddValueLabel", data.max_life_plus)
    self:setDelta("ManaAddValueLabel", data.max_mana_plus)
    self:setDelta("PhyPowerAddValueLabel", data.phy_power_plus)
    self:setDelta("MagPowerAddValueLabel", data.mag_power_plus)
    self:setDelta("SpeedAddValueLabel", data.speed_plus)
    self:setDelta("DefenceAddValueLabel", data.def_plus)
    self:updateLayout("AttribValuePanel")
end

return UserInfoChildDlg
