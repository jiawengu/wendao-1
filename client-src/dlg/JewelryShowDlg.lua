-- JewelryShowDlg.lua
-- Created by huangzz Apr/20/2018
-- 新首饰展示界面

local JewelryShowDlg = Singleton("JewelryShowDlg", Dialog)

function JewelryShowDlg:init(para)
    self:setFullScreen()
    self:bindListener("BlackImage", self.onBlackImage)

    self:setCtrlFullClientEx("BKPanel")
    self.isDoAction = true

    self:setJewelryView(para)
end

function JewelryShowDlg:onBlackImage()
    if not self.isDoAction then
        self:onCloseButton()
    end
end

function JewelryShowDlg:doAction(data)
    if not data[1] then
        self.isDoAction = false
        return
    end

    local info = table.remove(data, 1)
    if info.oldAtt then
        self:doOldAction(info, data)
    else
        self:doNewAction(info, data)
    end
end

function JewelryShowDlg:doOldAction(info, data)
    local ctrl = info.ctrl
    local action = cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.FadeOut:create(1),
        cc.CallFunc:create(function()
            self:doNewAction(info, data)
        end)
    )

    ctrl:runAction(action)
end

-- 播放新属性动画
function JewelryShowDlg:doNewAction(info, data)
    local ctrl = info.ctrl
    ctrl:setString(info.att)
    local size = ctrl:getContentSize()
    local action = cc.Sequence:create(
        cc.FadeIn:create(0.6),
        cc.CallFunc:create(function()
            self:doAction(data)
        end)
    )

    local magic = gf:createSelfRemoveMagic(ResMgr.magic.has_new_att, {frameInterval = 100, blendMode = "add"})
    magic:setAnchorPoint(0.5, 0.5)
    magic:setPosition(size.width / 2, size.height / 2)
    ctrl:addChild(magic)
    ctrl:runAction(action)
end

function JewelryShowDlg:setJewelryView(para)
    if not para then
        return
    end

    local newJewelry = para[1]  -- 新首饰属性
    local oldJewelry = para[2]  -- 旧首饰属性

    if not newJewelry then
        return
    end

    local oldBlueAtt = {}
    if oldJewelry then
        oldBlueAtt = EquipmentMgr:getJewelryBule(oldJewelry)
    end

    local blueAtt = EquipmentMgr:getJewelryBule(newJewelry)
    local cou = #blueAtt
    local showCou
    local panel
    if cou <= 3 then
        panel = self:getControl("SmallPanel")
        showCou = 3
        self:setCtrlVisible("LargePanel", false)
    else
        panel = self:getControl("LargePanel")
        showCou = 5
        self:setCtrlVisible("SmallPanel", false)
    end

    panel:setVisible(true)

    local function isNewAtt(att, oldAtt)
        -- 首饰强化时，属性一样但是属性值不一样，也要标记
        if oldAtt and string.match(oldAtt, ".+  (.+)/") ~= string.match(att, ".+  (.+)/") then
            return true
        end

        if oldAtt and string.match(oldAtt, "(.+)  .+") == string.match(att, "(.+)  .+") then
            return false
        end

        return true
    end

    -- 蓝属性
    local newAtt = {}
    for i = 1, showCou do
        if blueAtt[i] and isNewAtt(blueAtt[i], oldBlueAtt[i]) then
            local label = self:getControl("Attribute" .. i .. "Label", nil, panel)
            if not oldBlueAtt[i] then
                -- 新增首饰
                label:setString(blueAtt[i])
                label:setOpacity(0)
            else
                -- 替换首饰
                label:setString(oldBlueAtt[i])
                label:setOpacity(255)
            end

            table.insert(newAtt, {ctrl = label, att = blueAtt[i], oldAtt = oldBlueAtt[i]})
        else
            self:setLabelText("Attribute" .. i .. "Label", blueAtt[i] or "", panel)
        end
    end

    -- 播放新属性动画
    self:doAction(newAtt)

    --
    local icon = InventoryMgr:getIconByName(newJewelry["name"])
    self:setImage("IconImage", ResMgr:getItemIconPath(icon), panel)

    self:setLabelText("NameLabel", newJewelry["name"], panel)

    -- 调整高度
    if showCou > cou then
        local itemPanel = self:getControl("ItemPanel", nil, panel)
        local size = itemPanel:getContentSize()
        itemPanel:setContentSize(size.width, size.height - (showCou - cou) * 34)
    end
end

return JewelryShowDlg
