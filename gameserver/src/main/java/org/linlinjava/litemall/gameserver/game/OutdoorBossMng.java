package org.linlinjava.litemall.gameserver.game;

import com.alibaba.fastjson.JSONObject;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.xls_config.outdoorboss.OutdoorBossCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.outdoorboss.OutdoorBossItem;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossMap;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossPosition;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.scheduling.Trigger;
import org.springframework.scheduling.TriggerContext;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.support.CronTrigger;
import org.springframework.stereotype.Component;

import java.util.*;
import java.util.function.Consumer;

/**
 * 野外妖王
 * 修复  妖王刷新后不会消失  除非被击杀  每天凌晨五点重置一次
 * 每种妖王一次刷新三十个
 * 刷新地图上面有
 * 挑战等级最低不能低于妖王15级
 * 不能高于妖王20级
 */
@Component
public class OutdoorBossMng extends BaseBossMng {

    public static class OutdoorBossNpc extends BossNpc {
        public int level;
        public void setLevel(int level) {
            this.level = level;
        }
    }

    @Autowired
    public OutdoorBossCfg cfg;
    public List<OutdoorBossNpc> bossList = new ArrayList<>();
    public Map<Integer, OutdoorBossNpc> bossMap = new HashMap<>();


    @Override
    public void configureTasks(ScheduledTaskRegistrar scheduledTaskRegistrar) {
        scheduledTaskRegistrar.addTriggerTask(new Runnable() {
            @Override
            public void run() {
                productionBoss();
            }
        }, new Trigger() {
            @Override
            public Date nextExecutionTime(TriggerContext triggerContext) {
                return new CronTrigger(cfg.resetTime).nextExecutionTime(triggerContext);
            }
        });
    }

    @Override
    public List<Npc> getBossListByMapid(int id){
        List<Npc> list = new ArrayList<>();
        for(BossNpc boss : this.bossList){
            if(boss.getMapId() == id){
                list.add(boss);
            }
        }
        return list;
    }

    @Override
    public OutdoorBossNpc getBossByid(int id){
        return this.bossMap.get(id);
    }
    @Override
    public BossNpc getBossByname(String name){
        for(BossNpc boss : this.bossList){
            if(name.equals(boss.getName())){
                return boss;
            }
        }
        return null;
    }
    @Override
    public boolean isExtBoss(){
        return this.bossList.size() > 0;
    }

    @Override
    public void sendBossFight(Chara chara, int id){
        OutdoorBossNpc boss = getBossByid(id);
        if(boss != null){
            if(chara.level > boss.level + cfg.upperLimit){
                GameUtil.sendTips("不能高于妖王[%s]级", cfg.upperLimit);
                return ;
            }
            if(chara.level < boss.level - cfg.lowerLimit){
                GameUtil.sendTips("不能低于妖王[%s]级", cfg.lowerLimit);
                return ;
            }

            Map<Integer, String> monsterList = new HashMap<>();
            Integer index = 0;
            monsterList.put(boss.getId(), boss.getName());
            for(String xiaoguai : cfg.bossMap.get(boss.getName()).xiaoGuai){
                monsterList.put(boss.getId() + index++, xiaoguai);
            }
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
    public void sendRewards(Chara chara, String name){
        BossNpc boss = getBossByname(name);
        sendRewards(chara, boss.getId());
    }

    @Override
    public void afterBattle(int id){
        BossNpc boss = getBossByid(id);
        if(boss != null){
            this.bossList.remove(boss.index);
            this.bossMap.remove(boss);
        }
    }

    @Override
    public void productionBoss(){
        if(cfg.maps != null){
            System.out.println("生产野怪");
            this.bossList = getRandomBossList();
        }
    }

    @Override
    public List<OutdoorBossNpc> getRandomBossList() {
        List<OutdoorBossNpc> list = new ArrayList<>();
        this.bossMap = new HashMap<>();
        int id = 10, index = 0;
        for(OutdoorBossItem item: cfg.bossList){
            for(int i = 0; i < item.count; i++){
                OutdoorBossNpc boss = new OutdoorBossNpc();
                boss.setLevel(item.level);
                boss.setIndex(index++, 10);
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

                bossMap.put(boss.getId(), boss);
                list.add(boss);
            }
        }
        return list;
    }

    @Override
    public void resetBoss(){
        this.bossMap = new HashMap<>();
        this.bossList = new ArrayList<>();
    }
}
