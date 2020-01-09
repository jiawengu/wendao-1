-- DugeonRuleDlg.lua
-- Created by zhengjh Sep/24/2016
-- 规则界面

local DugeonRuleDlg = Singleton("DugeonRuleDlg", Dialog)

function DugeonRuleDlg:init()
    self.type = nil
end

function DugeonRuleDlg:setType(type)
    self.type = type
    self:setCtrlVisible("EightImmortalsPanel", type == "baxian")
    self:setCtrlVisible("DugeonRulePanel", type == "fuben")
    self:setCtrlVisible("ActivityRulePanel", type == "zhishujiefuben")
    self:setCtrlVisible("DancingPartyPanel", type == "masquerade")
    self:setCtrlVisible("HundredMonsterRulePanel", type == "beastsking")
    self:setCtrlVisible("MysteriousPlaceRulePanel", type == "mijing")
    self:setCtrlVisible("OreWarsPanel", type == "orewars")
    self:setCtrlVisible("InvadePanel", type == "yizuruqin")
    self:setCtrlVisible("ThousandMonsterRulePanel", type == "wyk")
    self:setCtrlVisible("ZongXianPanel", type == "zongxian")
    self:setCtrlVisible("QianlixianghuiPanel", type == "qianlxh") -- 千里相会
    self:setCtrlVisible("ManbuhuacongPanel", type == "manbuhuacong") -- 漫步花丛
    self:setCtrlVisible("XueJingPanel", type == "qiaosxj") -- 巧收雪精
    self:setCtrlVisible("ZhongXianPanel", type == "zhongxian")
    self:setCtrlVisible("ChuQiangPanel", type == "shanzeiyingwai")
    self:setCtrlVisible("ZongLiaoPanel", type == "ZongLiao")
    self:setCtrlVisible("RenKouPanel", type == "TanAnRksz")
    self:setCtrlVisible("LvLinPanel", type == "TanAnJhll")
    self:setCtrlVisible("MiXianPanel", type == "TanAnMxza")
    self:setCtrlVisible("CaiJiMeiGuiPanel", type == "valentine_2019_cjmg")
    self:setCtrlVisible("AprilFoolsDayPanel", type == "qmjh")
    self:setCtrlVisible("TongTianTopPanel", type == "ttttop")

    if type == "qmjh" then
        local task = TaskMgr:getTaskByName(CHS[5450341])
        if task and task.task_extra_para then
            local info = gf:split(task.task_extra_para, "|")
            for i = 1, 5 do
                if string.isNilOrEmpty(info[i]) then
                    self:setLabelText("Label_" .. i, CHS[5450346], "AprilFoolsDayPanel")
                else
                    self:setLabelText("Label_" .. i, info[i], "AprilFoolsDayPanel")
                end
            end
        end
    end
end

function DugeonRuleDlg:cleanup()
    if self.type == "ZongLiao" then
        gf:CmdToServer("CMD_DUANWU_2018_EXPLAIN")
    elseif self.type == "valentine_2019_cjmg" then

        local task = TaskMgr:getTaskByName(CHS[4101237])
        if task and task.task_extra_para == "2" then
            gf:CmdToServer("CMD_VALENTINE_2019_PREPARE_START_GAME")
        end

    end
end

function DugeonRuleDlg:onDlgOpened(type)
    self:setType(type[1])
end

return DugeonRuleDlg
