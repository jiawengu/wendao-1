package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.vo.Vo_61613_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_MASTER_INFO;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.CharaStatue;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
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
        String zhangMen = GameUtil.getZhangMenName(menpai);
        CharaStatue charaStatue = CharaStatueService.getCharStaure(zhangMen);
        if(null == charaStatue){
            GameObjectChar.send(new MSG_MASTER_INFO(), getDefaultInfo(menpai));
        }else{
            GameObjectChar gameObjectChar = GameObjectChar.getGameObjectChar();

            Vo_61613_0 vo_61613_0 = new Vo_61613_0();
            vo_61613_0.menpai = menpai;
            vo_61613_0.isLeader = gameObjectChar.chara.id == charaStatue.id?1:0;
            vo_61613_0.name = charaStatue.name;
            vo_61613_0.title = zhangMen;
            vo_61613_0.level = ""+charaStatue.level;
            vo_61613_0.party_name = charaStatue.partyName;
            /**
             * 套装icon
             */
            vo_61613_0.suit_icon = charaStatue.suit_icon;
            vo_61613_0.weapon_icon = charaStatue.weapon_icon;
            vo_61613_0.icon = charaStatue.waiguan;
            //仙魔光效
            vo_61613_0.xianmo = 0;
            //掌门留言
            GameObjectChar leader = GameObjectCharMng.getGameObjectChar(charaStatue.id);
            if(null!=leader&&null!=leader.chara.leaderNotice){
                vo_61613_0.signature = leader.chara.leaderNotice;
            }else{
                vo_61613_0.signature = String.format("大家好，我是新一任%s", zhangMen);
            }
            vo_61613_0.vipLevel = 0;
            vo_61613_0.gender = charaStatue.sex;
            GameObjectChar.send(new MSG_MASTER_INFO(), vo_61613_0);
        }
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
        vo_61613_0.title = name;
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

        default_ZhangmenMap.put(menpai, vo_61613_0);//放入缓存
        return vo_61613_0;
    }

    public static void challengeLeader(Chara chara){
        String zhangMen = GameUtil.getZhangMenName(chara.menpai);
        CharaStatue charaStatue = CharaStatueService.getCharStaure(zhangMen);
        if(null == charaStatue){
            FightManager.goFightChallengeLeader(chara, chara.menpai);
        }else{
            FightManager.goFightChallengeLeader(chara, charaStatue);
        }
    }

    /**
     * 修改掌门留言
     * @param menpai
     * @param msg
     */
    public static void changeMsg(int menpai, String msg){
        String zhangMen = GameUtil.getZhangMenName(menpai);
        CharaStatue charaStatue = CharaStatueService.getCharStaure(zhangMen);
        GameObjectChar gameObjectChar = GameObjectChar.getGameObjectChar();
        if(gameObjectChar.chara.id!=charaStatue.id){
            return;
        }
        gameObjectChar.chara.leaderNotice = msg;
    }
}
