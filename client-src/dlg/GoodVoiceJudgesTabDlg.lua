-- GoodVoiceJudgesTabDlg.lua
-- Created by
--

local TabDlg = require('dlg/TabDlg')
local GoodVoiceJudgesTabDlg = Singleton("GoodVoiceJudgesTabDlg", TabDlg)

GoodVoiceJudgesTabDlg.dlgs = {
    ReviewCheckBox = "GoodVoiceReviewDlg",
    RankingCheckBox = "GoodVoiceRankingDlg",
    JudgesCheckBox = "GoodVoiceJudgesDlg",
}


return GoodVoiceJudgesTabDlg
