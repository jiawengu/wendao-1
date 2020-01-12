package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.util.MsgUtil;
import org.springframework.stereotype.Service;

import static org.linlinjava.litemall.gameserver.util.MsgUtil.*;

/**
 * 地图守护神
 */
@Service
public class GuardianService {

    /**
     * 是否是守护神
     * @param npcName
     * @return
     */
    public static boolean isProtector(String npcName){
        return npcName.endsWith("守护神");
    }

    public static void openMenu(Chara chara, Npc npc){
        String content = "我们就是传说中美貌与智慧并存、英雄与侠义的化身——人见人爱的"+npc.getName()+"!我们守护着这片土地的一草一木。"+
                MsgUtil.getTalk(KAN_KAN_NI_MEN_SHI_LI)+
                MsgUtil.getTalk(WO_YAO_YI_DU_HU_FA)+
                MsgUtil.getTalk(KONG_PA_SHI_LI_BU_GOU);
        Vo_8247_0 vo_8247_0 = GameUtil.MSG_MENU_LIST(npc, content);
        GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
    }

}
