-- HeadTipsDlg.lua
-- Created by lixh Apr/04/2019
-- 主界面储备经验引导

local HeadTipsDlg = Singleton("HeadTipsDlg", Dialog)

function HeadTipsDlg:init()
    self:setFullScreen()
end

return HeadTipsDlg
