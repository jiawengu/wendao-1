-- GoodVoiceRankingDlg.lua
-- Created by
--


local GoodVoicePastRankingDlg = require('dlg/GoodVoicePastRankingDlg')
local GoodVoiceRankingDlg = Singleton("GoodVoiceRankingDlg", GoodVoicePastRankingDlg)

function GoodVoiceRankingDlg:init()


    self.rankingPanel = self:retainCtrl("RankingPanel")
    self.selectImage = self:retainCtrl("SelectedImage", self.rankingPanel)
    self:bindListener("Button2", self.onButton2, self.rankingPanel)
    self:bindListener("Button1", self.onButton1, self.rankingPanel)

    self:bindTouchEndEventListener(self.rankingPanel, self.onRankingPanel)

    self:queryRanking(GoodVoiceMgr.seasonData.season_no)


    self:hookMsg("MSG_GOOD_VOICE_RANK_LIST")
    self:hookMsg("MSG_GOOD_VOICE_SCORE_DATA")

end

function GoodVoiceRankingDlg:MSG_GOOD_VOICE_SCORE_DATA(data)
    DlgMgr:openDlgEx("GoodVoiceCommentDlg", data)
end

return GoodVoiceRankingDlg
