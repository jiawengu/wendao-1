package org.linlinjava.litemall.gameserver.user_logic;

import org.linlinjava.litemall.db.dao.UserPartyDailyTaskMapper;
import org.linlinjava.litemall.db.domain.UserPartyDailyTask;
import org.linlinjava.litemall.db.service.UserPartyDailyTaskService;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyDailyTaskCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyDailyTaskItem;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.XLSConfigMgr;

import java.util.ArrayList;

public class UserPartyDailyTaskLogic extends BaseLogic {
    public UserPartyDailyTask data;
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

    public PartyDailyTaskItem getCurTask(int npcId){
        int taskId = data.getCurTaskId();
        PartyDailyTaskCfg taskCfg = (PartyDailyTaskCfg)XLSConfigMgr.getCfg("party_daily_task");
        PartyDailyTaskItem cfgItem = null;
        if(taskId > 0) {
            cfgItem = taskCfg.getById(taskId);
            if (cfgItem.npc_id == npcId) {
                return cfgItem;
            }
        }else{
            if(data.getDayNo() < 50){
                ArrayList<PartyDailyTaskItem> list = taskCfg.randomGroup();
                cfgItem = list.get(0);
                this.data.setCurTaskId(cfgItem.id);
                this.save();
                return cfgItem;
            }
        }
        return null;
    }

    public String openMenu(int npcId){
        PartyDailyTaskItem item = this.getCurTask(npcId);
        if(item != null){
            return "[" + item.show_name + "]" + "[test]";
        }else{
            return null;
        }
    }

    public PartyDailyTaskItem selectMenuItem(int npcId, String menu){
        PartyDailyTaskItem item = this.getCurTask(npcId);
        if(item == null){ return null; }
        if(item.npc_id == npcId) {
            if (item.reward > 0) {
                ((UserPartyLogic) this.userLogic.getMod("party")).addContrib(item.reward);
            }
            if (item.next == 0) {
                this.data.setDayNo(this.data.getDayNo() + 1);
            }
            this.data.setCurTaskId(item.next);
            this.save();
            if(item.next > 0){
                return this.getCfgItem(item.next);
            }
        }
        return null;
    }

    public boolean hasTask(){
        return this.data.getCurTaskId() > 0;
    }

    public PartyDailyTaskItem getCfgItem(int id){
        PartyDailyTaskCfg cfg = (PartyDailyTaskCfg)XLSConfigMgr.getCfg(XLSConfigMgr.PARTY_DAILY_TASK);
        return cfg.getById(id);
    }


}
