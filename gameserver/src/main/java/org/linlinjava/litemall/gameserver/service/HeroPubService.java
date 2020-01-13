package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.constant.TitleConst;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20689_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR_NPC;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.data.write.MSG_OVERCOME_NPC_INFO;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.CharaStatue;
import org.linlinjava.litemall.gameserver.fight.BattleType;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.util.MsgUtil;
import org.linlinjava.litemall.gameserver.util.NpcIds;
import org.springframework.stereotype.Service;

import static org.linlinjava.litemall.gameserver.util.MsgUtil.KONG_PA_SHI_LI_BU_GOU;
import static org.linlinjava.litemall.gameserver.util.MsgUtil.WO_YAO_YI_DU_YING_XIONG;

/**
 * 英雄会
 */
@Service
public class HeroPubService {
    public static final int MAP_ID = 5004;
    public static final String[] titles = new String[]{"初出江湖", "初显锋芒", "声名鹊起", "锋芒毕露", "声名显赫", "如雷贯耳"};
    public static final String[] contents = new String[]{MsgUtil.WO_XIANG_SHI_70, MsgUtil.WO_XIANG_SHI_80, MsgUtil.WO_XIANG_SHI_90, MsgUtil.WO_XIANG_SHI_100,
            MsgUtil.WO_XIANG_SHI_110, MsgUtil.WO_XIANG_SHI_120};
    public static final Integer[][] POS = {{37,30}, {41,28}, {45,26}, {18,22}, {25,19}, {31,16}};
    public static final String DEFAULT_PET_NAME = "英雄会评议员";
    public static final int ICON = 6223;
    public static final String NPC_NAME = "英雄会";

    public static void openMenu(Chara chara, int npcId){
        CharaStatue charaStatue = getCharStaure(npcId);

        Npc npc = new Npc();
        npc.setId(npcId);
        npc.setIcon(ICON);
        npc.setName(charaStatue.name);

        String content = "英雄会高手如云，必须拥有过人本领方能有一席之地。"+
                MsgUtil.getTalk(HeroPubService.getContent(npcId))+
                MsgUtil.getTalk(WO_YAO_YI_DU_YING_XIONG)+
                MsgUtil.getTalk(KONG_PA_SHI_LI_BU_GOU);
        Vo_8247_0 vo_8247_0 = GameUtil.MSG_MENU_LIST(npc, content);
        GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
    }

    public static void notifyPanel(Chara chara, int npcId){
        Vo_20689_0 vo_20689_0 = new Vo_20689_0();
        CharaStatue charaStatue = getCharStaure(npcId);
        int index = getIndex(npcId);

        vo_20689_0.npcId = npcId;
        vo_20689_0.isLeader = charaStatue.id == chara.id?1:0;
        vo_20689_0.name = charaStatue.name;
        vo_20689_0.title = titles[index];
        vo_20689_0.level = ""+charaStatue.level;
        vo_20689_0.party_name = charaStatue.partyName;
        /**
         * 套装icon
         */
        vo_20689_0.suit_icon = charaStatue.suit_icon;
        vo_20689_0.weapon_icon = charaStatue.weapon_icon;
        vo_20689_0.icon = charaStatue.waiguan;
        //仙魔光效
        vo_20689_0.xianmo = 0;
        //留言
        GameObjectChar leader = GameObjectCharMng.getGameObjectChar(charaStatue.id);
        if(null!=leader&&null!=leader.chara.yxh_Notice){
            vo_20689_0.signature = leader.chara.yxh_Notice;
        }else{
            vo_20689_0.signature = String.format("大家好，我是新晋英雄");
        }
        vo_20689_0.vipLevel = 0;
        vo_20689_0.gender = charaStatue.sex;
        GameObjectChar.send(new MSG_OVERCOME_NPC_INFO(), vo_20689_0);
    }

    public static void challenge(Chara chara, int npcId){
        int index = getIndex(npcId);
        CharaStatue charaStatue = getCharStaure(npcId);

        Npc npc = new Npc();
        npc.setId(npcId);
        npc.setIcon(ICON);
        npc.setName(charaStatue.name);

        if(chara.level<70+index*10){
            GameUtil.notifyOpenMenu(npc, MsgUtil.WU_XUE_SHANG_QIQN);
            return;
        }
        if(chara.level>70+index*10+9){
            GameUtil.notifyOpenMenu(npc, MsgUtil.DAO_LI_GAO_SHEN);
            return;
        }

        FightManager.goFightChallengeCharaStatue(chara, charaStatue, BattleType.HERO_PUB, (fightContainer)->{
            //称号
            if(charaStatue.id>0 && charaStatue.id!=chara.id){
                //撤销旧的称号
                TitleService.removeUserTitle(charaStatue.id, TitleConst.TITLE_EVENT_HERO_CHALLENGE);
                TitleService.grantTitle(GameObjectChar.getGameObjectChar(), TitleConst.TITLE_EVENT_HERO_CHALLENGE, titles[index]);
            }else{
                TitleService.grantTitle(GameObjectChar.getGameObjectChar(), TitleConst.TITLE_EVENT_HERO_CHALLENGE, titles[index]);
            }
            fightContainer.charaStatue.copyChengHao(titles[index]);

            //雕像
            CharaStatueService.saveCharaStature(chara, getNpcName(npcId), fightContainer.charaStatue);
            //刷新npc视野信息
            npc.setName(getNpcName(npcId));
            npc.setMapId(MAP_ID);
            Integer[] pos = POS[index];
            npc.setX(pos[0]);
            npc.setY(pos[1]);
            GameObjectChar.getGameObjectChar().sendOne(new MSG_APPEAR_NPC(), npc);
        });
    }

    private static int getIndex(int npcId){
        return npcId-NpcIds.HERO_PUB_NPC_ID_BEGIN;
    }
    public static String getContent(int npcId){
        return contents[getIndex(npcId)];
    }

    private static String getNpcName(int npcId){
        return NPC_NAME+"_"+(npcId-NpcIds.HERO_PUB_NPC_ID_BEGIN);
    }

    public static void onEnterMap(GameObjectChar gameObjectChar){
        Chara chara = gameObjectChar.chara;

        for(int i = 0; i< POS.length; ++i){
            Npc npc = new Npc();
            npc.setId(NpcIds.HERO_PUB_NPC_ID_BEGIN+i);
            npc.setName(getNpcName(npc.getId()));
            npc.setMapId(MAP_ID);
            npc.setIcon(ICON);
            Integer[] pos = POS[i];
            npc.setX(pos[0]);
            npc.setY(pos[1]);

            checkInitCharStatue(chara.menpai, npc, titles[i]);

            gameObjectChar.sendOne(new MSG_APPEAR_NPC(), npc);
        }
    }

    private static void checkInitCharStatue(int menpai, Npc npc, String title){
        CharaStatue charaStatue = getCharStaure(npc.getId());
        if(null == charaStatue){
            charaStatue = new CharaStatue();
            charaStatue.name = DEFAULT_PET_NAME;
            charaStatue.waiguan = npc.getIcon();
            charaStatue.chengHao = title;
            charaStatue.level = 50;

            charaStatue.fangyu = 1000;
            charaStatue.fashang = 1000;
            charaStatue.accurate = 1000;

            putCharStaure(npc.getId(), charaStatue);
        }
    }

    private static CharaStatue getCharStaure(int npcId){
        return CharaStatueService.getCharStaure(getNpcName(npcId));
    }
    private static void putCharStaure(int npcId, CharaStatue charaStatue){
        CharaStatueService.putCache(getNpcName(npcId), charaStatue);
    }

    public static void changeNotice(int id, String msg){
        GameObjectChar.getGameObjectChar().chara.yxh_Notice = msg;
    }

}
