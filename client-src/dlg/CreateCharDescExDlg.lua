-- CreateCharDescExDlg.lua
-- Created by lixh2 Mar/08/2019
-- 预充值界面,带页签,复用 ReserveRechargeDlg

local CreateCharDescDlg = require('dlg/CreateCharDescDlg')
local CreateCharDescExDlg = Singleton("CreateCharDescExDlg", CreateCharDescDlg)

function CreateCharDescExDlg:init()
    CreateCharDescDlg.init(self)

    NoticeMgr:showPreCreateDescDlg(true)
end

return CreateCharDescExDlg
