package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR_NPC;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.CharaStatue;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.util.NpcIds;
import org.springframework.stereotype.Service;

/**
 * 证道殿
 */
@Service
public class ZhengDaoDianService {
    public static final int MAP_ID = 29002;
    public static final String[] titles = new String[]{"新入道途", "初领妙道", "进入佳境", "道心稳固", "妙领天机", "脱胎换骨"};
    public static final Integer[][] manPos = {{61,29}, {55,26}, {49,23}, {43,20}, {37,17}, {31,14}};
    public static final Integer[][] womanPos = {{43,38}, {37,35}, {31,32}, {25,29}, {19,26}, {13,23}};
    public static final String DEFAULT_PET_NAME = "羸弱的新晋护法";
    public static final String NPC_NAME = "证道殿";

    public static void onEngerMap(GameObjectChar gameObjectChar){
        Chara chara = gameObjectChar.chara;
        //男
        for(int i=0;i<manPos.length;++i){
            Npc npc = new Npc();
            npc.setId(NpcIds.ZHEGN_DAO_NPC_ID_BEGIN+i);
            npc.setName(NPC_NAME+i);
            npc.setMapId(MAP_ID);
            npc.setIcon(GameUtil.getCharWaiGuan(chara.menpai, 1));
            Integer[] pos = manPos[0];
            npc.setX(pos[0]);
            npc.setY(pos[1]);

            checkInitCharStatue(npc);

            gameObjectChar.sendOne(new MSG_APPEAR_NPC(), npc);
        }
        //女
        for(int i=0;i<womanPos.length;++i){
            Npc npc = new Npc();
            npc.setId(NpcIds.ZHEGN_DAO_NPC_ID_BEGIN+i+manPos.length);
            npc.setName(NPC_NAME+i+manPos.length);
            npc.setMapId(MAP_ID);
            npc.setIcon(GameUtil.getCharWaiGuan(chara.menpai, 2));
            Integer[] pos = womanPos[0];
            npc.setX(pos[0]);
            npc.setY(pos[1]);

            checkInitCharStatue(npc);

            gameObjectChar.sendOne(new MSG_APPEAR_NPC(), npc);
        }
    }

    private static void checkInitCharStatue(Npc npc){
        CharaStatue charaStatue = CharaStatueService.getCharStaure(npc.getName());
        if(null == charaStatue){
            charaStatue = new CharaStatue();
            charaStatue.name = DEFAULT_PET_NAME;
            charaStatue.waiguan = npc.getIcon();

            CharaStatueService.putCache(npc.getName(), charaStatue);
        }
    }

}
