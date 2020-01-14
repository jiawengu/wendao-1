package org.linlinjava.litemall.gameserver.data.xls_config.superboss;

public class SuperBossReward {

    /**
     * 道行、武学、妖石、首饰、商城道具、幼兽、坐骑、经验
     */
    public String type;

    public String value;

    public SuperBossReward(String type, String value){
        this.type = type;
        this.value = value;
    }
}
