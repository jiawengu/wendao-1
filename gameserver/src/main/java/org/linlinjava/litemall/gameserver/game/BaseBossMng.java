package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossMap;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossPosition;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossReward;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.service.DynamicNpcDialogService;
import org.springframework.context.annotation.Configuration;
import org.springframework.scheduling.annotation.EnableScheduling;
import org.springframework.scheduling.annotation.SchedulingConfigurer;

import java.util.List;
import java.util.Random;

@Configuration
@EnableScheduling
public abstract class BaseBossMng implements SchedulingConfigurer {
    public static final Random RANDOM = new Random();
    public static class BossNpc extends Npc {
        public int index;
        //BOSS 当前所在的地图，当玩家进入该地图或者在天机老人查询时使用
        public String mapName = "";
        //当前BOSS的可挑战次数
        public int count = 50;
        //奖品
        public List<SuperBossReward> rewards;
        public String dlgContent;
        public String startButtonTip;
        public String exitButtonTip;

        public void setDlgContent(String dlgContent) {
            this.dlgContent = dlgContent;
        }

        public void setStartButtonTip(String startButtonTip) {
            this.startButtonTip = startButtonTip;
        }

        public void setExitButtonTip(String exitButtonTip) {
            this.exitButtonTip = exitButtonTip;
        }

        public void setRewards(List<SuperBossReward> rewards) {
            this.rewards = rewards;
        }

        public void setIndex(int index, int id) {
            this.index = index;
            this.setId(index + id);
        }

        public void setCount(int count) {
            this.count = count;
        }

        public void setMapName(String mapName) {
            this.mapName = mapName;
        }
    }
    public abstract void productionBoss ();
    /**
     * 获取随机 BOSS
     * @return
     */
    public abstract <T> List<? extends BossNpc> getRandomBossList();
    public abstract List<Npc> getBossListByMapid(int id);
    public abstract BossNpc getBossByid(int id);
    public abstract BossNpc getBossByname(String name);
    public boolean isBoss(int id){
        return getBossByid(id) != null;
    }
    public abstract boolean isExtBoss();
    public abstract void afterBattle(int id);
    public abstract void sendBossFight(Chara chara, int id);
    public void sendRewards(Chara chara, String name){
        BossNpc boss = getBossByname(name);
        sendRewards(chara, boss.getId());
    }
    public abstract void resetBoss();
    /**
     * 发送奖励
     * @param id boss id
     */
    public void sendRewards(Chara chara, int id){
        BossNpc boss = getBossByid(id);
        if(boss != null){
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

    public void sendBossDlg(int id){
        BossNpc boss = getBossByid(id);
        if(boss != null) {
            DynamicNpcDialogService.sendNpcDlg(boss, String.format("%s [%s/我要挑战BOSS][%s/离开]", boss.dlgContent, boss.startButtonTip, boss.exitButtonTip));
        }
    }
}
