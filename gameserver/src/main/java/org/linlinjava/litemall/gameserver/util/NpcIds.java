package org.linlinjava.litemall.gameserver.util;

/**
 */
public class NpcIds {
    /**
     * 证道殿
     */
   public static int ZHEGN_DAO_NPC_ID_BEGIN = 10000;
   public static int ZHEGN_DAO_NPC_ID_END = 10099;


    public static boolean isZhengDaoDianNpc(int npcId){
        return npcId>=ZHEGN_DAO_NPC_ID_BEGIN && npcId<=ZHEGN_DAO_NPC_ID_END;
    }
}
