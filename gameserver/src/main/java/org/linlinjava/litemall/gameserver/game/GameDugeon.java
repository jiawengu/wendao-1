package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.*;
import org.linlinjava.litemall.gameserver.data.vo.Vo_45063_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61553_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65529_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0;
import org.linlinjava.litemall.gameserver.data.write.M12285_0;
import org.linlinjava.litemall.gameserver.data.write.M65529_npc;
import org.linlinjava.litemall.gameserver.data.write.M8247_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR;
import org.linlinjava.litemall.gameserver.data.xls_config.DugenoCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.DugenoItem;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyShopCfg;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.process.GameUtilRenWu;

import java.util.LinkedList;
import java.util.List;

// 通用副本
public class GameDugeon {
    public String name = "";
    public int curStep = 0;

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
        DugenoItem cfg = getDugenoItemCfg();
        if(cfg.monster_list.size() < curStep) return;

        RenwuMonster renwuMonster = GameData.that.baseRenwuMonsterService.findById(cfg.monster_list.get(curStep - 1));
        if(renwuMonster == null)
        {
            // 可能是npc
            return;
        }

        Vo_65529_0 vo_65529_0 = new Vo_65529_0();
        vo_65529_0.id = cfg.monster_list.get(curStep - 1);
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

        updateTaskInfo(GameObjectChar.getGameObjectChar().chara, cfg.task_type, cfg.taskinfo_list.get(curStep));
    }

    // 副本是否已完成
    public boolean isFinish() {
        if (curStep == 0) return false;
        DugenoItem cfg = getDugenoItemCfg();
        return cfg.max_step <= curStep;
    }

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

        List<NpcDialogueFrame> npcDialogueFramelist = GameData.that.baseNpcDialogueFrameService.findByName(name);
        String content  = "";
        if(npcDialogueFramelist.size() > 0) {
            content = npcDialogueFramelist.get(0).getUncontent();
        }

        // todo特殊npc
        if(id == 1300){
            if(!isFinish()) content = "黑风洞凶险无比，一切小心为上！[阁下是杨校尉][请帮我传出副本/请帮我传出副本][路过]";
            else content = "黑风洞凶险无比，一切小心为上！[强盗已经伏诛了][请帮我传出副本/请帮我传出副本][路过]";
        }

        if(id == 1310){
            if(!isFinish()) content = "鸠占鹊巢，令我有家归不得，实在可恨！[前辈打搅了][请帮我传出副本/请帮我传出副本][路过]";
            else content = "鸠占鹊巢，令我有家归不得，实在可恨！[狼妖的爪牙已全部除去][请帮我传出副本/请帮我传出副本][路过]";
        }

        if(id == 1311){
            if(!isFinish()) content = "嘿嘿嘿，又来了一群不自量力的小鬼！[看看是谁不自量力][等我准备好再来对付你]";
            else content = "鸠占鹊巢，令我有家归不得，实在可恨！[前辈打搅了][请帮我传出副本/请帮我传出副本][路过]";
        }

        if(content.equals("")) return false;

        Vo_8247_0 vo_8247_0 = new Vo_8247_0();
        vo_8247_0.id = id;
        vo_8247_0.portrait = icon;
        vo_8247_0.pic_no = 1;
        vo_8247_0.content = content;
        vo_8247_0.secret_key = "";
        vo_8247_0.name = name;
        vo_8247_0.attrib = 0;
        GameObjectChar.send(new M8247_0(), vo_8247_0);
        return  true;
    }

    // 挑战npc
    public boolean tryFightNpc(Chara chara, int id) {
        int curIdx = getMonsterIdx(id);
        if(curIdx == -1) return false;

        DugenoItem cfg = getDugenoItemCfg();
        List<String> monsterNameList = new LinkedList();
        List<Integer> list = cfg.pet_list.get(curIdx);
        for (int i = 0; i < list.size(); i++) {
            Pet pet = GameData.that.basePetService.findById(list.get(i));
            monsterNameList.add(pet.getName());
        }

        FightManager.goFight(chara, (List)monsterNameList);
        return true;
    }

    // 挑战胜利
    public void fightWin(Chara chara) {
        DugenoItem cfg = getDugenoItemCfg();
        if(curStep == 0) curStep += 1;
        RenwuMonster renwuMonster = GameData.that.baseRenwuMonsterService.findById(cfg.monster_list.get(curStep - 1));
        if(renwuMonster == null) return;
        int id = renwuMonster.getId();
        GameObjectChar.sendduiwu(new M12285_0(), Integer.valueOf(id), chara.id);

        curStep += 1;
        if(isFinish()){
            if(cfg.next_dugeno.equals(""))
            {
                Map map = GameData.that.baseMapService.findById(cfg.back_map);
                chara.y = cfg.back_x;
                chara.x = cfg.back_y;
                GameLine.getGameMapname(chara.line, map.getName()).join(GameObjectCharMng.getGameObjectChar(chara.id));
                return;
            }

            updateTaskInfo(chara, cfg.task_type, cfg.taskinfo_list.get(curStep));
            return;
        }

        callMonster(GameObjectChar.getGameObjectChar().gameMap);
    }

    public void enter(Chara chara) {
        DugenoItem cfg = getDugenoItemCfg();
        updateTaskInfo(chara, cfg.task_type, cfg.taskinfo_list.get(curStep));
    }

    // 前往下一个场景
    public void goNextDugeno(Chara chara) {
        DugenoItem cfg = getDugenoItemCfg();
        if(cfg.next_dugeno.equals(("")))
        {
            return;
        }

        GameUtil.enterDugeno(chara, cfg.next_dugeno);
    }

    // 更新任务信息
    private void updateTaskInfo(Chara chara, String task_type, String task_prompt){
        if(task_type.equals("") || task_prompt.equals("")){
            return;
        }

        GameUtilRenWu.renwukuangkuang(task_type, task_prompt, "", chara);

        Vo_45063_0 vo_45063_0 = new Vo_45063_0();
        vo_45063_0.task_name = task_prompt;
        vo_45063_0.check_point = 147761859;
        GameObjectChar.sendduiwu(new org.linlinjava.litemall.gameserver.data.write.M45063_0(), vo_45063_0, chara.id);
    }

    public void selectNpc(Chara chara1, int id) {
        if(tryFightNpc(chara1, id)) return;

        if (isFinish())
        {
            // 已完成前往下一层
            goNextDugeno(chara1);
            return;
        }

        // 未刷怪开始刷怪
        initMonster();
    }
}
