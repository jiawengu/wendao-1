package org.linlinjava.litemall.gameserver.game;


import org.linlinjava.litemall.core.util.DateTimeUtil;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.service.DynamicNpcDialogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.Trigger;
import org.springframework.scheduling.TriggerContext;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.SchedulingConfigurer;
import org.springframework.scheduling.config.CronTask;
import org.springframework.scheduling.config.ScheduledTaskRegistrar;
import org.springframework.scheduling.support.CronTrigger;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;
import java.util.function.Consumer;

/**
 * 超级大BOSS 管理类
 * 目前的逻辑思路是：
 * 1、现在实现随机在某地图上将 一个BOSS 刷出去
 *  1、在玩家进入地图时将 BOSS NPC 放置到地图的某个坐标上
 *  2、点击 BOSS 弹出进入战斗对话框，可以选择是否挑战
 *  3、选择挑战的则进入战斗房间进行战斗
 *  4、战斗结束后给予玩家奖励
 * 2、实现 BOSS 出现地图和坐标的随机性
 * 3、实现 BOSS 分身控制，分身被打败后数量递减，这会涉及到一个问题，就是分身那么多 到底是分批挑战还是一起挑战，如果是分批挑战那最后的奖励给谁
 * 4、实现 BOSS 的挑战条件、奖励条件和奖励礼品、
 *
 * ------20200109------------------
 * 1、先按照规则生成一定数量的 BOSS
 * 2、再将每个BOSS 分别放置到随机地图中
 */
@Component
public class SuperBossMng extends BaseBossMng {

    @Autowired
    public SuperBossCfg cfg;
    public List<BossNpc> bossList = new ArrayList<>();
    public Map<Integer, BossNpc> bossMap = new HashMap<>();

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
                return new CronTrigger(cfg.startTime).nextExecutionTime(triggerContext);
            }
        });

        scheduledTaskRegistrar.addTriggerTask(new Runnable() {
            @Override
            public void run() {
                resetBoss();
            }
        }, new Trigger() {
            @Override
            public Date nextExecutionTime(TriggerContext triggerContext) {
                return new CronTrigger(cfg.endTime).nextExecutionTime(triggerContext);
            }
        });
    }
    /**
     * 获取随机 BOSS
     * @return
     */
    @Override
    public List<BossNpc> getRandomBossList(){
        List<BossNpc> list = new ArrayList<>();
        //随机获取种类
        List<Integer> temps = new ArrayList<>();
        int id = 0, index = 0;
        this.bossMap = new HashMap<>();
        if(cfg.bossTypeCount > cfg.bossList.size()){ cfg.bossTypeCount = cfg.bossList.size(); }
        for(int i = 0; i < cfg.bossTypeCount; i++){
            do{ id = RANDOM.nextInt(cfg.bossList.size()); } while (temps.contains(id));
            temps.add(id);
            SuperBossItem item = cfg.bossList.get(id);
            for(int j = 0; j < cfg.bossCount; j++){
                BossNpc boss = new BossNpc();
                boss.setName(item.name);
                boss.setIcon(item.icon);
                boss.setCount(cfg.challengeCount);
                boss.setRewards(item.rewards);
                boss.setIndex(index++, 30);

                SuperBossMap map = cfg.maps.get(SuperBossMng.RANDOM.nextInt(cfg.maps.size()));
                boss.setMapId(map.mapid);
                boss.setMapName(map.name);

                SuperBossPosition pos = map.getRandomPosition();
                boss.setX(pos.x);
                boss.setY(pos.y);
                boss.setDlgContent(item.dlgContent);
                boss.setStartButtonTip(item.startButtonTip);
                boss.setExitButtonTip(item.exitButtonTip);

                list.add(boss);
                bossMap.put(boss.getId(), boss);
            }
        }

        return list;
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
    public BossNpc getBossByid(int id){
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
    public void sendBossFight(Chara chara, int id){
        BossNpc boss = getBossByid(id);
        if(boss != null){
            if(chara.level < 100){
                GameUtil.sendTips("等级至少100级才能挑战哦");
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
            Map<Integer, String> monsterList = new HashMap<>();
            Integer index = 0;
            monsterList.put(boss.getId(), boss.getName());
            for(String xiaoguai : cfg.bossMap.get(boss.getName()).xiaoGuai){
                monsterList.put(boss.getId() + index++, xiaoguai);
            }
            FightManager.goFightBoss(chara, monsterList, new Consumer<List<Chara>>() {
                @Override
                public void accept(List<Chara> charas) {
                    afterBattle(id);
                    for(Chara chara : charas){
                        sendRewards(chara, id);
                    }
                }
            });
        }
    }

    @Override
    public void productionBoss (){
        if(cfg.maps != null){
//            System.out.println("生产BOSS");
            this.bossList = getRandomBossList();
        }
    }

    @Override
    public boolean isExtBoss(){
        return this.bossList.size() > 0;
    }

    /**
     * 更新 Boss 挑战次数
     */
    @Override
    public void afterBattle(int id){
        BossNpc boss = getBossByid(id);
        if(boss != null){
            if(--boss.count <= 0){
                // 挑战数量消耗殆尽，场上NPC消失
                this.bossList.remove(boss.index);
                this.bossMap.remove(boss);
            }
        }
    }

    /**
     * 用于查询 Boss 所在的对话框
     */
    public void sendBossPosDlg(Npc npc){
        StringBuffer str = new StringBuffer();
        if(isExtBoss()){
            for(BossNpc boss: this.bossList){
                str.append(String.format("#R%s#n在#R%s#n作乱", boss.getName(), boss.mapName)).append("\r\n");
            }
        }
        else {
            str.append("目前还没有妖魔来犯，道友切莫心急！");
        }
        str.append("[离开/离开]");
        DynamicNpcDialogService.sendNpcDlg(npc, str.toString());
    }

    @Override
    public void resetBoss(){
        this.bossMap = new HashMap<>();
        this.bossList = new ArrayList<>();
    }
}
