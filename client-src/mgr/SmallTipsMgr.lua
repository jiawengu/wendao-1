-- SmallTipsMgr.lua
-- created by sujl, Nov/14/2016
-- 提示信息管理器

local List = require "core/List"
SmallTipsMgr = Singleton()

SmallTipsMgr.list = List.new()
SmallTipsMgr.dlgLocalZorder = {}

function SmallTipsMgr:addTip(tip)
    if GameMgr:isInBackground() then
        self.list:pushBack(tip)
    else
        local dlg = DlgMgr:openDlg("SmallTipDlg", nil, true)
        if self.rotation then
            dlg.root:setRotation(self.rotation)
        end
        dlg:addTip(tip)
    end
end

-- 2018寒假踩雪块要用，注意，使用后要置为nil
function SmallTipsMgr:setRotation(rotation)
    self.rotation = rotation

    local dlg = DlgMgr:getDlgByName("SmallTipDlg")
    if dlg then
        if self.rotation then
            dlg.root:setRotation(rotation)
        else
            dlg.root:setRotation(0)
        end
    end
end

function SmallTipsMgr:ENTER_FOREGROUND()
    if self.list:size() <= 0 then return end

    local dlg = DlgMgr:openDlg("SmallTipDlg", nil, true)
    repeat
        local tip = self.list:popFront()
        dlg:addTip(tip)
    until self.list:size() <= 0
end

function SmallTipsMgr:setLocalZOrder(zorder, dlgName)
    if zorder then
        table.insert(self.dlgLocalZorder, {zorder, dlgName})
        table.sort(self.dlgLocalZorder, function(l, r)
            return l[1] < r[1]
        end)
    else
        for i = #self.dlgLocalZorder, 1, -1 do
            if self.dlgLocalZorder[i] and self.dlgLocalZorder[i][2] == dlgName then
                table.remove(self.dlgLocalZorder, i)
                break
            end
        end
    end

    if #self.dlgLocalZorder > 0 then
        zorder = self.dlgLocalZorder[#self.dlgLocalZorder][1]
    else
        zorder = Const.ZORDER_SMALLTIP
    end

    local dlg = DlgMgr:getDlgByName("SmallTipDlg")
    if dlg then
        dlg.root:setLocalZOrder(zorder)
    end
end

function SmallTipsMgr:getLocalZOrder()
    if #self.dlgLocalZorder > 0 then
        return self.dlgLocalZorder[#self.dlgLocalZorder][1]
    else
        return Const.ZORDER_SMALLTIP
    end
end

EventDispatcher:addEventListener("ENTER_FOREGROUND", SmallTipsMgr.ENTER_FOREGROUND, SmallTipsMgr)
