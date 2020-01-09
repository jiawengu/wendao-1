-- JiucDlg.lua
-- Created by 
-- 

local JiucDlg = Singleton("JiucDlg", Dialog)

local NPC_ORDER = {
    CHS[3000802], -- 钱老板
    CHS[3000800], -- 王老板
    CHS[3000804], -- 乐善施
    CHS[3000795], -- 多闻道人
    CHS[3000797], -- 莲花姑娘
    CHS[3000801], -- 贾老板
    CHS[3000799], -- 张老板
    CHS[3000798], -- 赵老板
    CHS[3000806], -- 一叶知秋
    CHS[3000803], -- 卜老板
    CHS[3000805], -- 清静散人
}
function JiucDlg:init(param)
    if not param then return end

    for i = 1, #NPC_ORDER do
        self:setCtrlVisible("FinishImage" .. i, param[NPC_ORDER[i]] == 1)
    end
end

return JiucDlg
