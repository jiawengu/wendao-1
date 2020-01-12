package org.linlinjava.litemall.gameserver.util;

/**
 */
public class NpcIds {
    /**
     * 证道殿
     */
   public static int ZHEGN_DAO_NPC_ID_BEGIN = 10000;
   public static int ZHEGN_DAO_NPC_ID_END = 10099;

    /**
     * 英雄会
     */
    public static int HERO_PUB_NPC_ID_BEGIN = 10100;
    public static int HERO_PUB_NPC_ID_END = 10199;

    public static boolean isZhengDaoDianNpc(int npcId){
        return npcId>=ZHEGN_DAO_NPC_ID_BEGIN && npcId<=ZHEGN_DAO_NPC_ID_END;
    }

    /**
     * 英雄会
     * @param npcId
     * @return
     */
    public static boolean isHeroPubNpc(int npcId){
        return npcId>=HERO_PUB_NPC_ID_BEGIN && npcId<=HERO_PUB_NPC_ID_END;
    }
}
