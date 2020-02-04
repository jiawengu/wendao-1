package org.linlinjava.litemall.gameserver.data.game;

import org.linlinjava.litemall.gameserver.domain.Chara;

public class RankUtils {

    public static String[] rankTypeArray = {
            "rank_type:101",
            "rank_type:102:45-79",
            "rank_type:102:80-89",
            "rank_type:102:90-99",
            "rank_type:102:100-109",
            "rank_type:102:110-119",
            "rank_type:102:120-129",
            "rank_type:103",
            "rank_type:104",
            "rank_type:105",
            "rank_type:106",
    };

    /**
     * CHAR_LEVEL            = 101,
     * CHAR_TAO              = 102,    -- 道行排行
     * CHAR_PHY_POWER        = 103,    -- 物攻排行
     * CHAR_MAG_POWER        = 104,    -- 法攻排行
     * CHAR_SPEED            = 105,    -- 速度排行
     * CHAR_DEF              = 106,    -- 防御排行
     * @param chara
     * @param type
     * @return
     */
    public static int getRankValue(Chara chara, int type){
        int value = 0;
        switch (type){
            case 101:
                value = chara.level;
                break;
            case 102:
                value = chara.owner_name;
                break;
            case 103:
                value = chara.phy_power;
                break;
            case 104:
                value = chara.mag_power;
                break;
            case 105:
                value = chara.speed;
                break;
            case 106:
                value = chara.def;
                break;
        }
        return value;
    }

}
