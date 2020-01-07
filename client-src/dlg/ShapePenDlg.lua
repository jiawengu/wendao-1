-- ShapePenDlg.lua
-- Created by songcw June/16/2017
-- 九曲玲珑笔界面

local ShapePenDlg = Singleton("ShapePenDlg", Dialog)

-- 列表信息，对其他人使用，第一个数据需要修改
local ShapeList = {
    [1] = {icon = Me:queryBasicInt("org_icon"), key = "hide_change_card", name = CHS[4200385]},
    [2] = {icon = 06213, key = "yexingren", name = CHS[4200381]},    -- 夜行人
    [3] = {icon = 20004, key = "tieguaili", name = CHS[7002026]},    -- 铁拐李
    [4] = {icon = 20005, key = "hanzhongli", name = CHS[7002027]},   -- 汉钟离
    [5] = {icon = 20006, key = "lvdongbin", name = CHS[4200382]},    -- 吕洞宾
    [6] = {icon = 20007, key = "lancaihe", name = CHS[4100362]},     -- 蓝采和
}

function ShapePenDlg:init()
    self:bindListener("ChoseButton", self.onChoseButton)

    self.unitPanel = self:toCloneCtrl("ChoseButton")

    self:setListData()

    self.item = nil
    self.id = Me:getId() -- 如果对其他人使用，需要设置id
end

function ShapePenDlg:setListData(member)

    if member then
        self.id = member.id
        ShapeList[1] = {icon = member.org_icon, name = CHS[4200385], key = "hide_change_card"}
    else
        ShapeList[1] = {icon = Me:queryBasicInt("org_icon"), key = "hide_change_card", name = CHS[4200385]}
    end

    local listCtrl = self:resetListView("ListView", 0)
    for i = 1, #ShapeList do
        local data = ShapeList[i]
        local btn = self.unitPanel:clone()
        btn.data = data
        self:setImage("GuardImage", ResMgr:getSmallPortrait(data.icon), btn)
        self:setLabelText("Label_15", data.name, btn)
        listCtrl:pushBackCustomItem(btn)
    end
end

function ShapePenDlg:setItem(item)
    self.item = item
end

function ShapePenDlg:setId(id)
    self.id = id
end

function ShapePenDlg:setPositionByRect(rect)
    local midX = rect.x / Const.UI_SCALE + rect.width * 0.5
    local size = self.root:getContentSize()
    if midX >= Const.WINSIZE.width * 0.5 then
        local pos = cc.p((rect.x - size.width * 0.5) / Const.UI_SCALE, rect.y + size.height * 0.5)
        self.root:setPosition(pos)
    else
        -- 显示在右边
        local pos = cc.p((rect.x + rect.width + size.width * 0.5) / Const.UI_SCALE, rect.y + size.height * 0.5)
        self.root:setPosition(pos)
    end
end

function ShapePenDlg:onChoseButton(sender, eventType)
    -- 若在战斗中直接返回
    if Me:isInCombat() then
        gf:ShowSmallTips(CHS[3003759])
        self:onCloseButton()
        self:onCloseOtherDlg()
        return
    end

    local data = sender.data
    if self.item then
        self:applyJiuQu(self.id, data.key, self.item.pos)
    else
        self:applyJiuQu(self.id, data.key, 0)
    end
    self:onCloseButton()
    self:onCloseOtherDlg()
end

function ShapePenDlg:onCloseOtherDlg()
    DlgMgr:closeDlg("ItemInfoDlg")
    DlgMgr:closeDlg("FloatingMenuDlg")
end

function ShapePenDlg:applyJiuQu(id, type, pos)
    gf:CmdToServer("CMD_APPLY_JIUQU_LINGLONGBI", {id = id, type = type, pos = pos})
end

function ShapePenDlg:cleanup()
    self:releaseCloneCtrl("unitPanel")
end

return ShapePenDlg
