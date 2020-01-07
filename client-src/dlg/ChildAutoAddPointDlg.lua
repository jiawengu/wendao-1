-- ChildAutoAddPointDlg.lua
-- Created by lixh Apr/01/2019
-- 娃娃属性自动加点界面

local ChildAutoAddPointDlg = Singleton("ChildAutoAddPointDlg", Dialog)

local ADD_POINT_TYPE = {"Con", "Wiz", "Str", "Dex"}

function ChildAutoAddPointDlg:init()
    self:bindListener("ConfirmButton", self.onConfirmButton)

    for i = 1, #ADD_POINT_TYPE do
        self:bindAttribButtonEvent(ADD_POINT_TYPE[i])
    end

    self.attribPanelRoot = self:getControl("AttribValuePanel")
    self.planPanelRoot = self:getControl("AddPointPanel")

    self:hookMsg("MSG_CHILD_PRE_ASSIGN_ATTRIB")
    self:hookMsg("MSG_UPDATE_CHILDS")
end

function ChildAutoAddPointDlg:setData(cid)
    self.cid = cid

    local kid = HomeChildMgr:getKidByCid(cid)
    if not kid then
        return
    end

    -- 加点方案
    self:setAddPointPlan(kid)

    -- 当前属性
    self:setCurAttribValue(kid)
end

-- 绑定预加点按钮事件
function ChildAutoAddPointDlg:bindAttribButtonEvent(attribName)
    local addBtn = self:getControl(string.format("%sAddButton", attribName), self.planPanelRoot)
    addBtn.type = attribName
    local reduceBtn = self:getControl(string.format("%sReduceButton", attribName), self.planPanelRoot)
    reduceBtn.type = attribName

    addBtn:addTouchEventListener(function(sender, eventType)
        if eventType ~= ccui.TouchEventType.ended then
            return
        end

        local type = sender.type
        if type and self.curPointInfo[type] then
            if self.leftPoint and self.leftPoint > 0 then
                self.leftPoint = self.leftPoint - 1
                self.curPointInfo[type] = self.curPointInfo[type] + 1

                local plan = string.format("%d:%d:%d:%d", self.curPointInfo.Con, self.curPointInfo.Wiz,
                    self.curPointInfo.Str, self.curPointInfo.Dex)
                gf:CmdToServer("CMD_CHILD_PRE_ASSIGN_ATTRIB", {cid = self.cid, plan = plan})
            end
        end
    end)

    reduceBtn:addTouchEventListener(function(sender, eventType)
        if eventType ~= ccui.TouchEventType.ended then
            return
        end

        local type = sender.type
        if type and self.curPointInfo[type] and self.curPointInfo[type] > 0 and self.leftPoint < 4 then
            self.curPointInfo[type] = self.curPointInfo[type] - 1
            self.leftPoint = self.leftPoint + 1

            local plan = string.format("%d:%d:%d:%d", self.curPointInfo.Con, self.curPointInfo.Wiz,
                self.curPointInfo.Str, self.curPointInfo.Dex)
            gf:CmdToServer("CMD_CHILD_PRE_ASSIGN_ATTRIB", {cid = self.cid, plan = plan})
        end
    end)
end

-- 加点方案
function ChildAutoAddPointDlg:setAddPointPlan(kid)
    -- 当前剩余加点数
    self.leftPoint = kid:getLeftAttribPoint()
    self.curPointInfo = {
        ["Con"] = kid:queryInt("attrib_assign/con"),
        ["Wiz"] = kid:queryInt("attrib_assign/wiz"),
        ["Str"] = kid:queryInt("attrib_assign/str"),
        ["Dex"] = kid:queryInt("attrib_assign/dex"),
    }

    self:refreshAddPointPlan()
end

-- 刷新加点方案内容
function ChildAutoAddPointDlg:refreshAddPointPlan()
    self:setLabelText("PointLabel", string.format(CHS[7100444], self.leftPoint), self.planPanelRoot)
    local addAttribFlag = self.leftPoint > 0
    
    for i = 1, #ADD_POINT_TYPE do
        local labelName = string.format("%sValueLabel", ADD_POINT_TYPE[i])
        self:setLabelText(labelName, self.curPointInfo[ADD_POINT_TYPE[i]], self.planPanelRoot)
        
        local addBtnName = string.format("%sAddButton", ADD_POINT_TYPE[i])
        self:setCtrlEnabled(addBtnName, addAttribFlag, self.planPanelRoot)

        local reduceBtnName = string.format("%sReduceButton", ADD_POINT_TYPE[i])
        if self.curPointInfo[ADD_POINT_TYPE[i]] > 0 then
            self:setCtrlEnabled(reduceBtnName, true, self.planPanelRoot)
        else
            self:setCtrlEnabled(reduceBtnName, false, self.planPanelRoot)
        end
    end
end

-- 设置当前属性
function ChildAutoAddPointDlg:setCurAttribValue(kid)
    self.curProp = {
        life = kid:queryInt("max_life"),
        mana = kid:queryInt("max_mana"),
        phy_power = kid:queryInt("phy_power"),
        mag_power = kid:queryInt("mag_power"),
        speed = kid:queryInt("speed"),
        def = kid:queryInt("def"),
    }

    self:setLabelText("LifeValueLabel", self.curProp.life, self.attribPanelRoot)
    self:setLabelText("ManaValueLabel", self.curProp.mana, self.attribPanelRoot)
    self:setLabelText("PhyPowerValueLabel", self.curProp.phy_power, self.attribPanelRoot)
    self:setLabelText("MagPowerValueLabel", self.curProp.mag_power, self.attribPanelRoot)
    self:setLabelText("SpeedValueLabel", self.curProp.speed, self.attribPanelRoot)
    self:setLabelText("DefenceValueLabel", self.curProp.def, self.attribPanelRoot)

    self:setPreAddAttribValue("LifeAddValueLabel", 0)
    self:setPreAddAttribValue("ManaAddValueLabel", 0)
    self:setPreAddAttribValue("PhyPowerAddValueLabel", 0)
    self:setPreAddAttribValue("MagPowerAddValueLabel", 0)
    self:setPreAddAttribValue("SpeedAddValueLabel", 0)
    self:setPreAddAttribValue("DefenceAddValueLabel", 0)
end

-- 更新预加点属性
function ChildAutoAddPointDlg:updatePreAddAttrib(data)
    self:setPreAddAttribValue("LifeAddValueLabel", data.max_life - self.curProp.life)
    self:setPreAddAttribValue("ManaAddValueLabel", data.max_mana - self.curProp.mana)
    self:setPreAddAttribValue("PhyPowerAddValueLabel", data.phy_power - self.curProp.phy_power)
    self:setPreAddAttribValue("MagPowerAddValueLabel", data.mag_power - self.curProp.mag_power)
    self:setPreAddAttribValue("SpeedAddValueLabel", data.speed - self.curProp.speed)
    self:setPreAddAttribValue("DefenceAddValueLabel", data.def - self.curProp.def)
end

-- 设置预加点属性预览
function ChildAutoAddPointDlg:setPreAddAttribValue(labelName, value)
    local ctl = self:getControl(labelName, nil, self.attribPanelRoot)
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

function ChildAutoAddPointDlg:MSG_CHILD_PRE_ASSIGN_ATTRIB(data)
    self:updatePreAddAttrib(data)
    self:refreshAddPointPlan()
end

function ChildAutoAddPointDlg:MSG_UPDATE_CHILDS(data)
    for i = 1, data.count do
        if data[i].cid == self.cid then
            self:setCurAttribValue(HomeChildMgr:getKidByCid(self.cid))
            DlgMgr:sendMsg("KidInfoDlg", "refreshAttribPointPlan")
            break
        end
    end
end

function ChildAutoAddPointDlg:onConfirmButton(sender, eventType)
    if not self.cid then
        return
    end

    local kid = HomeChildMgr:getKidByCid(self.cid)
    if kid and kid:queryInt("attrib_assign/con") == self.curPointInfo.Con
        and kid:queryInt("attrib_assign/wiz") == self.curPointInfo.Wiz
        and kid:queryInt("attrib_assign/str") == self.curPointInfo.Str
        and kid:queryInt("attrib_assign/dex") == self.curPointInfo.Dex then
        -- 加点方案没有变化，直接关闭界面
        DlgMgr:closeDlg(self.name)
        return
    end

    local plan = string.format("%d:%d:%d:%d", self.curPointInfo.Con, self.curPointInfo.Wiz,
        self.curPointInfo.Str, self.curPointInfo.Dex)
    gf:CmdToServer("CMD_CHILD_SURE_ASSIGN_ATTRIB", {cid = self.cid, plan = plan})
end

function ChildAutoAddPointDlg:cleanup()
    self.cid = nil
    self.curProp = {}
    self.curPointInfo = {}
end

return ChildAutoAddPointDlg
