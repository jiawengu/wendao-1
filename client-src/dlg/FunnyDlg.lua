-- FunnyDlg.lua
-- Created by songcw Jan/23/2018
-- WDSY-26872 趣味界面基类对话框   


local FunnyDlg = Singleton("FunnyDlg", Dialog)

function FunnyDlg:init()
    self:bindListener("TouchPanel", self.onPlayButton)
end

function FunnyDlg:onPlayButton(sender, eventType)    
        local data = {name = ResMgr.ArmatureMagic.funny_magic.name, action = string.format("Bottom0%d", math.random(1, 5))}
        gf:createArmatureOnceMagic(data.name, data.action, gf:getTopLayer()) 
end

return FunnyDlg
