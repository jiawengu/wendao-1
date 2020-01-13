package org.linlinjava.litemall.gameserver.game;


import org.linlinjava.litemall.core.util.DateTimeUtil;
import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.service.DynamicNpcDialogService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.time.LocalDateTime;
import java.util.*;

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
public class SuperBossMng {

    public static class SuperBossNpc extends Npc {
        public int index;
        //BOSS 当前所在的地图，当玩家进入该地图或者在天机老人查询时使用
        public String mapName = "";
        //当前BOSS的可挑战次数
        public int count = 50;
        //奖品
        public List<SuperBossReward> rewards;

        public void setRewards(List<SuperBossReward> rewards) {
            this.rewards = rewards;
        }

        public void setIndex(int index) {
            this.index = index;
        }

        public void setCount(int count) {
            this.count = count;
        }

        public void setMapName(String mapName) {
            this.mapName = mapName;
        }

    }

    public static final Random RANDOM = new Random();
    @Autowired
    public SuperBossCfg cfg;

    public List<SuperBossNpc> bossList = new ArrayList<>();
    public Map<Integer, SuperBossNpc> bossMap = new HashMap<>();

    /**
     * 获取随机 BOSS
     * @return
     */
    public List<SuperBossNpc> getRandomBossList(){
        List<SuperBossNpc> list = new ArrayList<>();
        //随机获取种类
        List<Integer> temps = new ArrayList<>();
        int id = 0, index = 0;
        if(cfg.cfg.bossTypeCount > cfg.bosss.size()){ cfg.cfg.bossTypeCount = cfg.bosss.size(); }
        for(int i = 0; i < cfg.cfg.bossTypeCount; i++){
            do{ id = SuperBossMng.RANDOM.nextInt(cfg.bosss.size()); } while (temps.contains(id));
            temps.add(id);
            SuperBossItem item = cfg.bosss.get(id);
            for(int j = 0; j < cfg.cfg.bossCount; j++){
                SuperBossNpc npc = new SuperBossNpc();
                npc.setId(item.id);
                npc.setName(item.name);
                npc.setIcon(item.icon);
                npc.setCount(cfg.cfg.challengeCount);
                npc.setRewards(item.rewards);
                npc.setIndex(index++);
                setBossRandomMap(npc);
                list.add(npc);
                bossMap.put(npc.getId(), npc);
            }
        }

        return list;
    }

    public SuperBossMap getRandomMap(){
        return cfg.maps.get(SuperBossMng.RANDOM.nextInt(cfg.maps.size()));
    }

    /**
     * 将 BOSS 随机分配到某个地图上的某个坐标
     * @param boss
     */
    public void setBossRandomMap(SuperBossNpc boss){
        SuperBossMap map = getRandomMap();
        SuperBossPosition pos = map.getRandomPosition();
        boss.setMapId(map.mapid);
        boss.setMapName(map.name);
        boss.setMapId(map.mapid);
        boss.setX(pos.x);
        boss.setY(pos.y);
    }

    public List<Npc> getBossListByMapid(int id){
        List<Npc> list = new ArrayList<>();
        for(SuperBossNpc boss : this.bossList){
            if(boss.getMapId() == id){
                list.add(boss);
            }
        }
        return list;
    }

    public SuperBossNpc getBossByid(int id){
        return this.bossMap.get(id);
    }
    public SuperBossNpc getBossByname(String name){
        for(SuperBossNpc boss : this.bossList){
            if(name.equals(boss.getName())){
                return boss;
            }
        }
        return null;
    }

    public boolean isBoss(int id){
        return getBossByid(id) != null;
    }

    public void sendBossFight(Chara chara, int id){
        SuperBossNpc boss = getBossByid(id);
        if(boss != null){
            List<String> monsterList = new ArrayList<String>();
            monsterList.add(boss.getName());
            FightManager.goFight(chara, monsterList);
        }
    }

    public void sendRewards(Chara chara, String name){
        SuperBossNpc boss = getBossByname(name);
        sendRewards(chara, boss.getId());
    }

    /**
     * 发送奖励
     * @param id boss id
     */
    public void sendRewards(Chara chara, int id){
        SuperBossNpc boss = getBossByid(id);
        if(boss != null){
            updateBossChallengeCount(id);
            for(SuperBossReward reward: boss.rewards){
                if("道行".equals(reward.type)){
                    int v = Integer.valueOf(reward.value);
                    GameUtil.adddaohang(chara, v);
                }
                else if("武学".equals(reward.type)){

                }
                else if("妖石".equals(reward.type)){

                }
                else if("首饰".equals(reward.type)){

                }
                else if("商城道具".equals(reward.type)){

                }
                else if("幼兽".equals(reward.type)){

                }
                else if("坐骑".equals(reward.type)){

                }
                else if("物品".equals(reward.type)){
                    for(String vs: reward.value.split(",")){
                        String[] v = vs.split(":");
                        org.linlinjava.litemall.db.domain.StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(v[0]);
                        GameUtil.huodedaoju(chara, info, 1);
                    }
                }
                else if("金币".equals(reward.type)){
                    int v = Integer.valueOf(reward.value);
                    GameUtil.addCoin(chara, v);
                }
                else if("元宝".equals(reward.type)){
                    int v = Integer.valueOf(reward.value);
                    GameUtil.addYuanBao(chara, v);
                }
                else if("经验".equals(reward.type)){
                    int v = Integer.valueOf(reward.value);
                    GameUtil.addjingyan(chara, v);
//                    GameUtil.add4121();
//                    GameUtil.addfabaojingyan();
//                    GameUtil.addpetjingyan();
//                    GameUtil.addshouhu();
//                    GameUtil.addwupin();
//                    GameUtil.addVip();
//                    GameUtil.addYuanBao();
//                    GameUtil.addCoin();
//                    GameUtil.adddaohang();
//
//                    GameUtil.huodecaifen();
//                    GameUtil.huodechoujiang();
//                    GameUtil.huodedaoju();
//                    GameUtil.huodejingyan();
//                    GameUtil.huodezhuangbeixiangwu();
//                    GameUtil.huodezhuangbei();


                }
            }
        }
    }

    public void test(){
        if(!isExtBoss())
        this.bossList = getRandomBossList();
    }

    public void productionBoss (){
        if(cfg.cfg != null){
            test();
//            if("d".equals(cfg.cfg.timeUnit)){
//                String h = DateTimeUtil.getDateTimeFormatterString(LocalDateTime.now(), "HHmms");
//                if("00:00:0".equals(h) ){
//                    // 表示每日的 0 点
//                    this.bossList = new ArrayList<>();
//                }
//                else if ("07:00:0".equals(h) ){
//                    //表示每日早上的7点
//                    this.bossList = getRandomBossList();
//                }
//            }
        }
    }

    public boolean isExtBoss(){
        return this.bossList.size() > 0;
    }

    /**
     * 更新 Boss 挑战次数
     */
    public void updateBossChallengeCount(int id){
        SuperBossNpc boss = getBossByid(id);
        if(boss != null){
            if(--boss.count <= 0){
                // 挑战数量消耗殆尽，场上NPC消失
                this.bossList.remove(boss.index);
                this.bossMap.remove(id);
            }
        }
    }

    public void sendBossDlg(int id){
        SuperBossNpc boss = getBossByid(id);
        if(boss != null) {
            DynamicNpcDialogService.sendNpcDlg(boss, String.format("你好！小道长，我是#R%s#n，想要挑战我吗？ [我要挑战你/我要挑战超级大BOSS][离开/离开]", boss.getName()));
        }
    }

    /**
     * 用于查询 Boss 所在的对话框
     */
    public void sendBossPosDlg(Npc npc){
        StringBuffer str = new StringBuffer();
        if(isExtBoss()){
            for(SuperBossNpc boss: this.bossList){
                str.append(String.format("#R%s#n在#R%s#n作乱", boss.getName(), boss.mapName)).append("\r\n");
            }
        }
        else {
            str.append("目前还没有妖魔来犯，道友切莫心急！");
        }
        str.append("[离开/离开]");
        DynamicNpcDialogService.sendNpcDlg(npc, str.toString());
    }

    public void resetBoss(){
        this.bossMap = new HashMap<>();
        this.bossList = new ArrayList<>();
    }
}
