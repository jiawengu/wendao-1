package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.xls_config.outdoorboss.OutdoorBossItem;
import org.linlinjava.litemall.gameserver.data.xls_config.pirate.PirateCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.pirate.PirateItem;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossMap;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossPosition;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.service.DynamicNpcDialogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.Trigger;
import org.springframework.scheduling.TriggerContext;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.support.CronTrigger;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.function.Consumer;

@Component
public class PirateMng extends BaseBossMng {

    public static class PirateNpc extends BossNpc {
        public int level;
        /**可挑战等级*/
        public int challengingLevel;

        public void setLevel(int level) {
            this.level = level;
        }
        public void setChallengingLevel(int challengingLevel) {
            this.challengingLevel = challengingLevel;
        }
    }

    @Autowired
    public PirateCfg cfg;
    public List<PirateNpc> pirateList = new ArrayList<PirateNpc>();
    public Map<Integer, PirateNpc> pirateMap = new HashMap<Integer, PirateNpc>();

    @Override
    public void productionBoss() {
        if(cfg.pirateMap != null){
            System.out.println("生产海盗");
            this.pirateList = getRandomBossList();
        }
    }

    @Override
    public List<PirateNpc> getRandomBossList() {
        List<PirateNpc> list = new ArrayList<PirateNpc>();
        this.pirateMap = new HashMap<Integer, PirateNpc>();
        int id = 0, index = 0;
        for(PirateItem item: cfg.pirateList){
            for(int i = 0; i < item.count; i++){
                PirateNpc boss = new PirateNpc();
                boss.setLevel(item.level);
                boss.setIndex(index++, 20);
                boss.setCount(item.count);
                boss.setRewards(item.rewards);
                boss.setIcon(item.icon);
                boss.setName(item.name);

                SuperBossMap map = item.getRandomMap();
                boss.setMapName(map.name);
                boss.setMapId(map.mapid);

                SuperBossPosition pos = map.getRandomPosition();
                boss.setX(pos.x);
                boss.setY(pos.y);
                boss.setDlgContent(item.dlgContent);
                boss.setStartButtonTip(item.startButtonTip);
                boss.setExitButtonTip(item.exitButtonTip);

                pirateMap.put(boss.getId(), boss);
                list.add(boss);
            }
        }
        return list;
    }

    @Override
    public List<Npc> getBossListByMapid(int id) {
        List<Npc> list = new ArrayList<>();
        for(BossNpc boss : this.pirateList){
            if(boss.getMapId() == id){
                list.add(boss);
            }
        }
        return list;
    }

    @Override
    public PirateNpc getBossByid(int id) {
        return this.pirateMap.get(id);
    }

    @Override
    public PirateNpc getBossByname(String name) {
        for(PirateNpc boss : this.pirateList){
            if(name.equals(boss.getName())){
                return boss;
            }
        }
        return null;
    }

    @Override
    public boolean isExtBoss() {
        return this.pirateList.size() > 0;
    }

    @Override
    public void afterBattle(int id) {
        BossNpc boss = getBossByid(id);
        if(boss != null){
            this.pirateList.remove(boss.index);
            this.pirateList.remove(boss);
        }
    }

    @Override
    public void sendBossFight(Chara chara, int id) {
        PirateNpc boss = getBossByid(id);
        if(boss != null){
            if(chara.level < boss.challengingLevel){
                GameUtil.sendTips("不能低于海盗[%s]级", boss.challengingLevel);
                return ;
            }
            if (GameObjectChar.getGameObjectChar().gameTeam == null) {
                GameUtil.sendTips("请先创建队伍");
                return ;
            }
            List<Chara> duiwu = GameObjectChar.getGameObjectChar().gameTeam.duiwu;
            if (duiwu.size() < 3) {
                GameUtil.sendTips("人数不足3人");
                return;
            }
            List<String> monsterList = new ArrayList<String>();
            monsterList.add(boss.getName());
            monsterList.addAll(cfg.pirateMap.get(boss.getName()).xiaoGuai);
            FightManager.goFightBoss(chara, monsterList, new Consumer<Chara>() {
                @Override
                public void accept(Chara chara) {
                    afterBattle(id);
                    sendRewards(chara, id);
                }
            });
        }
    }

    @Override
    public void resetBoss() {
        this.pirateList = new ArrayList<>();
        this.pirateMap = new HashMap<>();
    }

    @Override
    public void configureTasks(ScheduledTaskRegistrar scheduledTaskRegistrar) {
        scheduledTaskRegistrar.addTriggerTask(new Runnable() {
            @Override
            public void run() {
                try {
                    productionBoss();
                    Thread.sleep(cfg.duration * 60 * 60 * 1000);
                    resetBoss();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }, new Trigger() {
            @Override
            public Date nextExecutionTime(TriggerContext triggerContext) {
                return new CronTrigger(cfg.startTime).nextExecutionTime(triggerContext);
            }
        });
    }
}
