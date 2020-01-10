package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61613_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_MASTER_INFO;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

/**
 * 挑战掌门
 */
@Service
public class ChallengeLeaderService {
    /**
     * key:menpai
     */
    private static Map<Integer, Vo_61613_0> default_ZhangmenMap = new HashMap<>();
    /**
     * 通知掌门信息
     * @param menpai
     */
    public static void notifyLeaderInfo(int menpai){
        GameObjectChar.send(new MSG_MASTER_INFO(), getDefaultInfo(menpai));
    }

    private static Vo_61613_0 getDefaultInfo(int menpai){
        if(default_ZhangmenMap.containsKey(menpai)){
            return default_ZhangmenMap.get(menpai);
        }

        String name = GameUtil.getZhangMenName(menpai);
        Npc npc = GameData.that.baseNpcService.findOneByName(name);
        Vo_61613_0 vo_61613_0 = new Vo_61613_0();
        vo_61613_0.menpai = menpai;
        vo_61613_0.isLeader = 0;
        vo_61613_0.name = name;
        vo_61613_0.title = "";
        vo_61613_0.level = "50";
        vo_61613_0.party_name = "";
        /**
         * 套装icon
         */
        vo_61613_0.suit_icon = 0;
        vo_61613_0.weapon_icon = 0;
        vo_61613_0.icon = npc.getIcon();
        //仙魔光效
        vo_61613_0.xianmo = 0;
        //掌门留言
        vo_61613_0.signature = String.format("大家好，我是新一任%s", name);
        vo_61613_0.vipLevel = 0;
        vo_61613_0.gender = 0;

//TODO        default_ZhangmenMap.put(menpai, vo_61613_0);
        return vo_61613_0;
    }

    public static void challengeLeader(Chara chara){
        FightManager.goFightChallengeLeader(chara, chara.menpai);
    }

    /**
     * 修改掌门留言
     * @param menpai
     * @param msg
     */
    public static void changeMsg(int menpai, String msg){

    }
}
