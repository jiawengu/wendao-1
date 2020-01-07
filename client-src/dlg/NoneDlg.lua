-- NoneDlg.lua
-- Created by songcw Dec/12/2018
-- 什么都没有的界面
-- 当前用于标记所有主界面隐藏

local NoneDlg = Singleton("NoneDlg", Dialog)

function NoneDlg:init()
    self:setFullScreen()
    self:setCtrlFullClient("TouchPanel")

    local char = CharMgr:getCharByName(CHS[4200636])
    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:setCenterChar(char:getId())
    end

    CharMgr:doCharHideStatus(Me)
    self.allInvisbleDlgs = DlgMgr:getAllInVisbleDlgs()
    DlgMgr:showAllOpenedDlg(false, { [self.name] = 1 })
end

function NoneDlg:cleanup()
    if GameMgr.scene and GameMgr.scene.map then
        GameMgr.scene.map:setCenterChar(nil)
    end

    CharMgr:doCharHideStatus(Me)

    local t = {}
    if self.allInvisbleDlgs then
        for i = 1, #(self.allInvisbleDlgs) do
            t[self.allInvisbleDlgs[i]] = 1
        end
    end

    DlgMgr:showAllOpenedDlg(true, t)
    Me:setVisible(true)

    gf:closeCountDown()

    TttSmfjMgr:clearAllBxfObj()
end

return NoneDlg
