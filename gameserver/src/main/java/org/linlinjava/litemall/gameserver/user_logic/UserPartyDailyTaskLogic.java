package org.linlinjava.litemall.gameserver.user_logic;

import org.linlinjava.litemall.db.dao.UserPartyDailyTaskMapper;
import org.linlinjava.litemall.db.domain.UserPartyDailyTask;
import org.linlinjava.litemall.db.service.UserPartyDailyTaskService;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.data.write.MSG_TASK_PROMPT;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyDailyTaskCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyDailyTaskItem;
import org.linlinjava.litemall.gameserver.fight.FightContainer;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.fight.FightObject;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.game.XLSConfigMgr;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class UserPartyDailyTaskLogic extends BaseLogic {
    public UserPartyDailyTask data;
    private FightContainer curFc = null;

    @Override
    protected void onInit() {
        super.onInit();

        UserPartyDailyTaskService service = GameData.that.userPartyDailyTaskService;
        data = service.findById(this.id);
        if(data == null){
            data = new UserPartyDailyTask();
            data.setId(this.id);
            data.setCurTaskId(0);
            data.setCurProcess(0);
            data.setDayNo(0);
            service.insert(data);
        }
    }

    @Override
    protected void onSave() {
        super.onSave();

        UserPartyDailyTaskMapper mapper = GameData.that.userPartyDailyTaskService.mapper;
        mapper.updateByPrimaryKey(data);
    }

    public PartyDailyTaskItem checkCurTaskByNpcId(int npcId){
        int taskId = data.getCurTaskId();
        PartyDailyTaskCfg taskCfg = (PartyDailyTaskCfg)XLSConfigMgr.getCfg("party_daily_task");
        PartyDailyTaskItem cfgItem = null;
        if(taskId > 0) {
            cfgItem = taskCfg.getById(taskId);
            if (cfgItem.npc_id == npcId) {
                return cfgItem;
            }
        }else{
            if(npcId != 1006){ return null; }//帮派总管
            //if(data.getDayNo() < 50){
                ArrayList<PartyDailyTaskItem> list = taskCfg.randomGroup();
                cfgItem = list.get(0);
                this.data.setCurTaskId(cfgItem.id);
                this.save();
                return cfgItem;
            //}
        }
        return null;
    }

    public String openMenu(int npcId){
        PartyDailyTaskItem item = this.checkCurTaskByNpcId(npcId);
        if(item != null){
            return "[" + item.show_name + "]" + "[test]";
        }else{
            return null;
        }
    }

    public void selectMenuItem(int npcId, String menu){
        PartyDailyTaskItem item = this.checkCurTaskByNpcId(npcId);
        if(item == null){ return; }
        if(item.npc_id == npcId && menu != null && menu.compareTo(item.show_name) == 0) {
            if (item.reward > 0) {
                ((UserPartyLogic) this.userLogic.getMod("party")).addContrib(item.reward);
            }
            if (item.next == 0) {
                this.data.setDayNo(this.data.getDayNo() + 1);
            }
            this.data.setCurTaskId(item.next);
            this.save();
            if(item.next > 0){
                item = this.getCfgItem(item.next);
            }else{
                item = null;
            }
            this.notifyTaskPrompt(item);
        }
    }

    public boolean hasTask(){
        return this.data.getCurTaskId() > 0;
    }

    public PartyDailyTaskItem getCfgItem(int id){
        PartyDailyTaskCfg cfg = (PartyDailyTaskCfg)XLSConfigMgr.getCfg(XLSConfigMgr.PARTY_DAILY_TASK);
        return cfg.getById(id);
    }

    public void multiMoveCheckMonster(int mapId, int mapX, int mapY){
        if(!this.hasTask()){ return; }
        PartyDailyTaskItem item = this.getCfgItem(this.data.getCurTaskId());
        if(item.map_id == mapId && this.checkMapXYDistance(item.map_x - mapX, item.map_y - mapY)){
            if (item.monster.compareTo("") == 0) {
                return;
            }
            List<String> monsterList = new ArrayList<>();
            monsterList.add(item.monster);
            this.curFc = FightManager.goFight(GameObjectChar.getGameObjectChar().chara, monsterList);
        }
    }

    private boolean checkMapXYDistance(int sx, int sy){
        return Math.abs(sx) <= 4 && Math.abs(sy) <= 4;
    }

    public PartyDailyTaskItem getHasTask(){
        if(!this.hasTask()){ return null; }
        return this.getCfgItem(this.data.getCurTaskId());
    }

    public void fightAfterWin(FightContainer fc, List<FightObject> monsters){
        if(this.curFc == null || this.curFc != fc){ return;}
        PartyDailyTaskItem item = this.getHasTask();
        if(item == null){ return; }
        if (item.reward > 0) {
            ((UserPartyLogic) this.userLogic.getMod("party")).addContrib(item.reward);
        }
        if (item.next == 0) {
            this.data.setDayNo(this.data.getDayNo() + 1);
        }
        this.data.setCurTaskId(item.next);
        this.save();
        if(item.next > 0){
            item = this.getCfgItem(item.next);
        }else{
            item = null;
        }
        this.notifyTaskPrompt(item);
    }

    private void notifyTaskPrompt(PartyDailyTaskItem item){
        if(item != null){
            Vo_61553_0 vo_61553_0 = new Vo_61553_0();
            vo_61553_0.count = 1;
            vo_61553_0.task_type = "帮派日常任务";
            vo_61553_0.task_desc = item.task_desc;
            vo_61553_0.task_prompt = item.task_prompt;
            vo_61553_0.refresh = 1;
            vo_61553_0.task_end_time = 1567909190;
            vo_61553_0.attrib = 1;
            vo_61553_0.reward = item.reward > 0 ? "帮贡x" + item.reward : "";
            vo_61553_0.show_name = item.show_name;
            vo_61553_0.tasktask_extra_para = "";
            vo_61553_0.tasktask_state = "1";
            GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
        }else{
            Vo_61553_0 vo_61553_0 = new Vo_61553_0();
            vo_61553_0.count = 1;
            vo_61553_0.task_type = "帮派日常任务";
            vo_61553_0.task_desc = "";
            vo_61553_0.task_prompt = "";
            vo_61553_0.refresh = 1;
            vo_61553_0.task_end_time = 0;
            vo_61553_0.attrib = 1;
            vo_61553_0.reward = "";
            vo_61553_0.show_name = "";
            vo_61553_0.tasktask_extra_para = "";
            vo_61553_0.tasktask_state = "1";
            GameObjectChar.send(new MSG_TASK_PROMPT(), vo_61553_0);
        }
    }



}
