-- FightTalkMenuDlg.lua
-- Created by chenyq Dec/13/2014
-- 战斗对话菜单界面

local MenuItem = require('ctrl/MenuItem')
local NpcDlg = require('dlg/NpcDlg')
local FightTalkMenuDlg = Singleton("FightTalkMenuDlg", NpcDlg)

function FightTalkMenuDlg:init()
    NpcDlg.init(self)
    self.menus = {}
end

function FightTalkMenuDlg:setMenu(content)
    self.menus = {}
    NpcDlg.setMenu(self, content)
end

function FightTalkMenuDlg:cleanup()
    self.menus = {}
    NpcDlg.cleanup(self)
end

function FightTalkMenuDlg:getCfgFileName()
    -- 与 NpcDlg 共用配置
    return ResMgr:getDlgCfg("NpcDlg");
end

function FightTalkMenuDlg:createMenuItem(text, id, key)
    local menu = MenuItem.new(text, id, key)
    menu.isFightMenu = true
    menu.canProcessMenu = (Me:getId() == id)
    menu.relativeDlg = 'FightTalkMenuDlg'
    
    self.menus[text] = menu
    
    return menu
end

-- 让菜单闪烁，闪烁结束后关闭对话框
function FightTalkMenuDlg:blinkMenu(text)
    if not self.menus or not self.menus[text] then
        return
    end
    
    local action = cc.Sequence:create(
        cc.Blink:create(1, 4),
        cc.CallFunc:create(function() DlgMgr:closeDlg('FightTalkMenuDlg') end, self)
    )
    
    self.menus[text]:runAction(action)
end

function FightTalkMenuDlg:menuIsClosed(text)
    if not self.menus or not self.menus[text] then
        return true
    end
    
    return false
end

return FightTalkMenuDlg
