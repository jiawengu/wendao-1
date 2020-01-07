-- GoodVoiceTabDlg.lua
-- Created by
--

local TabDlg = require('dlg/TabDlg')
local GoodVoiceTabDlg = Singleton("GoodVoiceTabDlg", TabDlg)

GoodVoiceTabDlg.dlgs = {
    VoiceCheckBox = "GoodVoiceExhibitionDlg",
    CollectionCheckBox = "GoodVoiceCollectionDlg",
    RuleCheckBox = "GoodVoiceRuleDlg",
}

return GoodVoiceTabDlg
