package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.*;
import org.linlinjava.litemall.gameserver.data.vo.MSG_MENU_LIST_VO;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_DISAPPEAR_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_CLOSED;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.data.xls_config.DugenoCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.DugenoItem;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.process.GameUtilRenWu;

import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

// 通用副本
public class GameDugeon {
    public String name = "";
    public int curStep = 0;
    public int juben_end_id = 0;
    private String juben_form = "";
    private boolean had_call_monster = false;

    private enum ACTION{
        NONE,
        FIGHT_MONSTER,
        CALL_MONSER,
    };

    // 获取当前副本的配置
    public DugenoItem getDugenoItemCfg() {
        DugenoCfg cfgMgr = (DugenoCfg)XLSConfigMgr.getCfg("dugeno");
        DugenoItem cfg = cfgMgr.getByName(this.name);
        return  cfg;
    }

    // 初始化怪物列表
    public void initMonster() {
        if(curStep > 0)
        {
            return;
        }

        curStep += 1;

        GameMap gameMap = GameObjectChar.getGameObjectChar().gameMap;
        callMonster(gameMap);
    }

    // 副本刷怪
    public void callMonster(GameMap gameMap) {
        had_call_monster = true;
        DugenoItem cfg = getDugenoItemCfg();
        if(cfg.monster_list.size() < curStep) return;

        int monsterID = cfg.monster_list.get(curStep - 1);
        RenwuMonster renwuMonster = GameData.that.baseRenwuMonsterService.findById(monsterID);
        if(renwuMonster == null || !renwuMonster.getMapName().equals(gameMap.name))
        {
            // 可能是npc
            updateTaskInfo(GameObjectChar.getGameObjectChar().chara);
            return;
        }

        Vo_65529_0 vo_65529_0 = new Vo_65529_0();
        vo_65529_0.id = renwuMonster.getId();
        vo_65529_0.name = renwuMonster.getName();
        vo_65529_0.type = 2;
        vo_65529_0.leixing = renwuMonster.getType();

        vo_65529_0.mapid = gameMap.id;
        vo_65529_0.x = renwuMonster.getX().intValue();
        vo_65529_0.y = renwuMonster.getY().intValue();
        vo_65529_0.dir = 1;
        vo_65529_0.icon = renwuMonster.getIcon();
        vo_65529_0.org_icon = vo_65529_0.icon;
        vo_65529_0.portrait = vo_65529_0.icon;
        gameMap.send(new MSG_APPEAR(), vo_65529_0);

        updateTaskInfo(GameObjectChar.getGameObjectChar().chara);
    }

    // 副本是否已完成
    public boolean isFinish() {
        if (curStep == 0) return false;
        DugenoItem cfg = getDugenoItemCfg();
        return cfg.max_step <= curStep;
    }

    // 获取怪物索引
    public int getMonsterIdx(int id)
    {
        if(this.name.equals("")){
            return -1;
        }

        DugenoItem cfg = getDugenoItemCfg();
        int curIdx = 0;
        for (int i = 0; i < cfg.monster_list.size(); i++) {
            if(id == cfg.monster_list.get(i)){
                return i;
            }
        }
        return -1;
    }

    // npc对话
    public boolean meetNpc(Chara chara, int id) {
        int idx = getMonsterIdx(id);
        // todo
        if(idx == -1 && id != 1300 && id != 1310 && id != 1311) return false;

        String name = "";
        int icon = 0;
        Npc npc = GameData.that.baseNpcService.findById(id);
        // todo
        if(npc == null)
        {
            RenwuMonster renwuMonster = GameData.that.baseRenwuMonsterService.findById(id);
            name = renwuMonster.getName();
            icon = renwuMonster.getIcon();
        }
        else
        {
            name = npc.getName();
            icon = npc.getIcon();
        }

        DugenoItem cfg = getDugenoItemCfg();
        String tmpName = name;
        // todo特殊npc
        if(id == 1300 || id == 1310) {
            // 同一个副本，进入时和离开时对话不一样
            if(curStep != getDugenoItemCfg().max_step) tmpName = tmpName + "1";
            else  tmpName = tmpName + "2";
        }
        else if(id == 1340){
            // 土地公在不同的副本出现，入口为1，出口为2，
            if(!cfg.next_dugeno.equals("")) tmpName = tmpName + "1";
            else tmpName = tmpName + "2";
        }
        else if(name.contains("玉石琵琶精")){
            // 玉石琵琶精 特殊处理 todo
            tmpName = tmpName + cfg.map_name;
            if(cfg.map_name.equals("烈火涧")) {
                if(curStep > 2) tmpName = tmpName + "2";
                else tmpName = tmpName + "1";
            }
        }

        String content  = "";
        List<NpcDialogueFrame> npcDialogueFramelist = GameData.that.baseNpcDialogueFrameService.findByName(tmpName);
        if(npcDialogueFramelist.size() > 0 && npcDialogueFramelist.get(0).getUncontent() != null) {
            content = npcDialogueFramelist.get(0).getUncontent();
        }

        if(content.equals("")){
            // 对话推进
            if(npcDialogueFramelist.size() > 0 && !(npcDialogueFramelist.get(0)).getNext().equals("")){
                chara.nextJuBen = 0;
                chara.currentJuBens = (npcDialogueFramelist.get(0)).getNext().split(",");
                juben_end_id = Integer.valueOf(chara.currentJuBens[chara.currentJuBens.length - 1]);
                GameUtil.playNextNpcDialogueJuBen();
                juben_form = "meetnpc";
            }
            return true;
        }
        juben_end_id = 0;

        MSG_MENU_LIST_VO vo_8247_0 = new MSG_MENU_LIST_VO();
        vo_8247_0.id = id;
        vo_8247_0.portrait = icon;
        vo_8247_0.pic_no = 1;
        vo_8247_0.content = content;
        vo_8247_0.secret_key = "";
        vo_8247_0.name = name;
        vo_8247_0.attrib = 0;
        GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
        return  true;
    }

    // 当前动作
    public ACTION getCurStepAction(){
        DugenoItem cfg = getDugenoItemCfg();
        if(isFinish()) return ACTION.NONE;
        if(cfg.pet_list.size() < curStep && cfg.monster_list.size() >= curStep) return ACTION.CALL_MONSER;

        List<Integer> list = cfg.pet_list.get(curStep - 1);
        if(list.size() == 0 || !had_call_monster) {
            return ACTION.CALL_MONSER;
        }
        else return ACTION.FIGHT_MONSTER;
    }

    // 挑战npc
    public boolean tryFightNpc(Chara chara, int id) {
        int curIdx = getMonsterIdx(id);
        DugenoItem cfg = getDugenoItemCfg();
        if(curIdx != curStep - 1 && cfg.monster_list.get(curStep - 1) != id) return false;
        curIdx = curStep - 1;
        if(cfg.pet_list.size() <= curIdx) return false;
        List<String> monsterNameList = new LinkedList();
        List<Integer> list = cfg.pet_list.get(curIdx);
        if(list.size() == 0) return false;

        for (int i = 0; i < list.size(); i++) {
            T_FightObject obj = GameData.that.baseFightObjectService.findOneByID(list.get(i));
            monsterNameList.add(obj.getName());
        }

        FightManager.goFight(chara, (List)monsterNameList);
        return true;
    }

    // 挑战胜利
    public void fightWin(Chara chara) {
        // 移除怪物
        removeCurStepMonster(chara);

        curStep += 1;
        had_call_monster = false;

        DugenoItem cfg = getDugenoItemCfg();
        int juben_idx = curStep - 2;
        if(cfg.fightwinjuben_list.size() > juben_idx && cfg.fightwinjuben_list.get(juben_idx).length > 0){
            chara.nextJuBen = 0;
            chara.currentJuBens = cfg.fightwinjuben_list.get(juben_idx);
            juben_end_id = Integer.valueOf(chara.currentJuBens[chara.currentJuBens.length - 1]);
            GameUtil.playNextNpcDialogueJuBen();
            juben_form = "fightwin";
            return;
        }

        if(isFinish()){
            if(cfg.next_dugeno.equals(""))
            {
                leaveBack(chara);
                return;
            }
            return;
        }

        callMonster(GameObjectChar.getGameObjectChar().gameMap);
    }

    // 进入副本
    public void enter(Chara chara) {
        DugenoItem cfg = getDugenoItemCfg();

        if (cfg.enterjuben_list.length > 0){
            chara.nextJuBen = 0;
            chara.currentJuBens = cfg.enterjuben_list;
            GameUtil.playNextNpcDialogueJuBen();
            juben_form = "enter";
        }

        initMonster();
    }

    // 离开副本返回指定位置
    public void leaveBack(Chara chara) {
        DugenoItem cfg = getDugenoItemCfg();
        chara.x = cfg.back_x;
        chara.y = cfg.back_y;
        GameLine.getGameMap(chara.line, cfg.back_map).join(GameObjectCharMng.getGameObjectChar(chara.id));
    }

    // 前往下一个场景
    public void goNextDugeno(Chara chara) {
        DugenoItem cfg = getDugenoItemCfg();
        if(cfg.next_dugeno.equals(("")))
        {
            leaveBack(chara);
            return;
        }

        GameUtil.enterDugeno(chara, cfg.next_dugeno);
    }

    // 更新任务信息
    private void updateTaskInfo(Chara chara){
        DugenoItem cfg = getDugenoItemCfg();
        String task_type = cfg.task_type;
        String task_prompt = cfg.taskinfo_list.get(curStep -1);
        if(task_type.equals("") || task_prompt.equals("")){
            return;
        }

        GameMap gameMap = GameObjectCharMng.getGameObjectChar(chara.id).gameMap;
        String rex = "#(.*?)#";
        Pattern pattern = Pattern.compile(rex);
        Matcher matcher = pattern.matcher(task_prompt);
        if (matcher.find()){
            String rs = matcher.group(1);
            boolean isFind = false;
            List<RenwuMonster> reList = GameData.that.baseRenwuMonsterService.findByName(rs);
            for (RenwuMonster renwuMonster: reList) {
                if(renwuMonster.getMapName().equals(cfg.map_name)){
                    rs = String.format("#P%s|%s(%d,%d)#P", rs, renwuMonster.getMapName(), renwuMonster.getX(), renwuMonster.getY());
                    isFind = true;
                    break;
                }
            }

            if(!isFind) {
                List<Npc> list = GameData.that.baseNpcService.findByName(rs);
                for (Npc npc : list) {
                    String npcMapName = GameData.that.baseMapService.findOneByMapId(npc.getMapId()).getName();
                    if (npcMapName.equals(cfg.map_name)) {
                        rs = String.format("#P%s|%s(%d,%d)#P", rs, gameMap.name, npc.getX(), npc.getY());
                        isFind = true;
                    }
                }
            }

            if(isFind) task_prompt = task_prompt.replaceAll(matcher.group(), rs);
        }

        GameUtilRenWu.renwukuangkuang(task_type, task_prompt, "", chara);

        Vo_45063_0 vo_45063_0 = new Vo_45063_0();
        vo_45063_0.task_name = task_prompt;
        vo_45063_0.check_point = 147761859;
        GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara.id);
    }

    // 选择npc选项
    public void selectNpc(Chara chara1, int id, String menu_item, String para) {
        if("离开".equals(menu_item)){
            return;
        }

        // 有对话，先对话
        List<NpcDialogueFrame> npcDialogueFrame = GameData.that.baseNpcDialogueFrameService.findByName(menu_item + para);
        if(npcDialogueFrame.size() > 0 && !(npcDialogueFrame.get(0)).getNext().equals("")){
            GameObjectChar.send(new MSG_MENU_CLOSED(), Integer.valueOf(id));

            chara1.nextJuBen = 0;
            chara1.currentJuBens = (npcDialogueFrame.get(0)).getNext().split(",");
            juben_end_id = Integer.valueOf(chara1.currentJuBens[chara1.currentJuBens.length - 1]);
            GameUtil.playNextNpcDialogueJuBen();
            juben_form = "selectnpc";
            return;
        }

        if (isFinish())
        {
            // 已完成前往下一层
            goNextDugeno(chara1);
            return;
        }

        if(tryFightNpc(chara1, id)) return;
/*
        // 有些只有一步的
        if (isFinish())
        {
            // 已完成前往下一层
            goNextDugeno(chara1);
            return;
        }
*/
        int idx = getMonsterIdx(id);
        DugenoItem cfg = getDugenoItemCfg();
        if(idx != curStep - 1 && cfg.monster_list.get(curStep - 1) != id) return;
        // 刷下一波怪
        GameMap gameMap = GameObjectCharMng.getGameObjectChar(chara1.id).gameMap;
        if(cfg.monster_list.size() > curStep){
            curStep = curStep + 1;
            callMonster(gameMap);
        }
    }

    // 剧本结束
    public void OnJuBenEnd(Chara chara, int juben_id) {
        int tmp_id = juben_end_id;
        juben_end_id = 0;
        DugenoItem cfg = getDugenoItemCfg();
        if(juben_id == tmp_id){
            ACTION action = getCurStepAction();
            if(action == ACTION.CALL_MONSER)
            {
                if(!juben_form.equals("fightwin")) {
                    removeCurStepMonster(chara);
                    curStep += 1;
                }
                callMonster(GameObjectCharMng.getGameObjectChar(chara.id).gameMap);
                return;
            }
            else if(action == ACTION.FIGHT_MONSTER){
                tryFightNpc(chara, cfg.monster_list.get(curStep - 1));
                return;
            }
        }

        if(juben_form.equals("fightwin") && curStep <= cfg.monster_list.size() && curStep > cfg.pet_list.size()) {
            // 来自胜利的剧本，并且当前需要对话，不检查完成
            updateTaskInfo(chara);
            return;
        }

        if(isFinish()){
            // 前往下一个副本
            goNextDugeno(chara);
            return;
        }

        updateTaskInfo(chara);
    }

    // 删除怪物
    public void removeCurStepMonster(Chara chara) {
        DugenoItem cfg = getDugenoItemCfg();
        GameMap gameMap = GameObjectCharMng.getGameObjectChar(chara.id).gameMap;
        RenwuMonster renwuMonster = GameData.that.baseRenwuMonsterService.findById(cfg.monster_list.get(curStep - 1));
        if(renwuMonster == null || !renwuMonster.getMapName().equals(gameMap.name)) return;
        int id = renwuMonster.getId();
        GameObjectChar.sendduiwu(new MSG_DISAPPEAR_0(), Integer.valueOf(id), chara.id);
    }
}
