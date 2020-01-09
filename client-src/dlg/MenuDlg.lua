-- MenuDlg.lua
-- Created by chenyq Jan/13/2015
-- 通用菜单对话框

local MenuDlg = Singleton("MenuDlg", Dialog)

function MenuDlg:init()
    self.list = self:getControl('ListView', Const.UIPanel)
    self.listSize = self.list:getContentSize()

    self.item = self:getControl('ChildButton', Const.UIButton)
    self.item:retain()

    -- 获取列表项之间的间隔
    self.interval = self.list:getItemsMargin()

    -- 获取列表在 Y 方向上的偏移
    self.rootSize = self.root:getContentSize()
    self.offsetY = self.rootSize.height - (self.list:getPositionY() + self.listSize.height)

    self.root:setAnchorPoint(0, 0)
end

function MenuDlg:cleanup()
    self:releaseCloneCtrl("item")
end

-- menuList: 菜单列表数组
-- relativeDlgName：关联的对话框名字，回调函数名为 onClickMenu，参数为菜单项索引
function MenuDlg:setMenus(menuList, relativeDlgName)
    if not self.root or not self.item then
        return
    end

    -- 删除已有内容
    self.list:removeAllChildren()

    self.relativeDlgName = relativeDlgName

    -- 重新设置对话框高度
    local len = #menuList
    self.listSize.height = len * (self.item:getContentSize().height + self.interval) - self.interval
    self.root:setContentSize(self.rootSize.width, self.listSize.height + self.offsetY * 2)
    self.list:setContentSize(self.listSize)

    for i = 1, len do
        local menu = self.item:clone()
        menu:setTitleText(menuList[i])
        menu:setTouchEnabled(true)
        menu:setTag(i)
        self:bindTouchEndEventListener(menu, self.onClickMenu)
        self.list:addChild(menu)
    end
end

function MenuDlg:onClickMenu(sender, eventType)
    if not DlgMgr:isDlgOpened(self.relativeDlgName) then
        self:close()
        return
    end

    local dlg = DlgMgr:openDlg(self.relativeDlgName)
    if type(dlg['onClickMenu']) == 'function' then
        dlg:onClickMenu(sender:getTag())
    end
end

return MenuDlg