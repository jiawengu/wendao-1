-- NewKuafzcgzDlg.lua
-- Created by songcw Jan/06/2019
-- ¿ç·þÕ½³¡2019 

local NewKuafzcgzInZhancDlg = Singleton("NewKuafzcgzInZhancDlg", Dialog)


function NewKuafzcgzInZhancDlg:getCfgFileName()
    return ResMgr:getDlgCfg("NewKuafzcgzDlg")
end

function NewKuafzcgzInZhancDlg:init()
end


return NewKuafzcgzInZhancDlg
