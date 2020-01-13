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

import static org.linlinjava.litemall.gameserver.data.constant.TitleConst.*;
import static org.linlinjava.litemall.gameserver.util.MsgUtil.KONG_PA_SHI_LI_BU_GOU;
import static org.linlinjava.litemall.gameserver.util.MsgUtil.WO_YAO_YI_DU_HU_FA;

/**
 * 证道殿
 */
@Service
public class ZhengDaoDianService {
    public static final int MAP_ID = 29002;
    public static final String[] titles = new String[]{TITLE_ZHENGDAODIAN_70, TITLE_ZHENGDAODIAN_80, TITLE_ZHENGDAODIAN_90, TITLE_ZHENGDAODIAN_100, TITLE_ZHENGDAODIAN_110, TITLE_ZHENGDAODIAN_120};
    public static final String[] contents = new String[]{MsgUtil.WO_YAO_TIAO_ZHAN_70, MsgUtil.WO_YAO_TIAO_ZHAN_80, MsgUtil.WO_YAO_TIAO_ZHAN_90, MsgUtil.WO_YAO_TIAO_ZHAN_100,
            MsgUtil.WO_YAO_TIAO_ZHAN_110, MsgUtil.WO_YAO_TIAO_ZHAN_120};
    public static final Integer[][] manPos = {{61,29}, {55,26}, {49,23}, {43,20}, {37,17}, {31,14}};
    public static final Integer[][] womanPos = {{43,38}, {37,35}, {31,32}, {25,29}, {19,26}, {13,23}};
    public static final String DEFAULT_PET_NAME = "羸弱的新晋护法";
    public static final String NPC_NAME = "证道殿";

    public static void openMenu(Chara chara, int npcId){
        CharaStatue charaStatue = getCharStaure(chara.menpai, npcId);

        Npc npc = new Npc();
        npc.setId(npcId);
        npc.setIcon(GameUtil.getCharWaiGuan(chara.menpai, isMan(npcId)?1:2));
        npc.setName(charaStatue.name);

        String content = "助本门弟子修心证道乃是吾等职责，但需功力深厚者方能担当证道之人。"+
                MsgUtil.getTalk(ZhengDaoDianService.getContent(npcId))+
                MsgUtil.getTalk(WO_YAO_YI_DU_HU_FA)+
                MsgUtil.getTalk(KONG_PA_SHI_LI_BU_GOU);
        Vo_8247_0 vo_8247_0 = GameUtil.MSG_MENU_LIST(npc, content);
        GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
    }

    public static Npc createNpc(int npcId){
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        boolean isMan = isMan(npcId);
        int index = getIndex(npcId);

        Npc npc = new Npc();
        npc.setId(npcId);
        npc.setName(NPC_NAME+(npcId-NpcIds.ZHEGN_DAO_NPC_ID_BEGIN));
        npc.setMapId(MAP_ID);
        npc.setIcon(GameUtil.getCharWaiGuan(chara.menpai, isMan?1:2));
        Integer[] pos = null;
        if(isMan){
            pos = manPos[index];
        }else{
            pos = womanPos[index];
        }

        npc.setX(pos[0]);
        npc.setY(pos[1]);
        return npc;
    }

    public static void notifyPanel(Chara chara, int npcId){
        Vo_20689_0 vo_20689_0 = new Vo_20689_0();
        CharaStatue charaStatue = getCharStaure(chara.menpai, npcId);
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
        if(null!=leader&&null!=leader.chara.zdd_Notice){
            vo_20689_0.signature = leader.chara.zdd_Notice;
        }else{
            vo_20689_0.signature = String.format("大家好，我是新晋护法");
        }
        vo_20689_0.vipLevel = 0;
        vo_20689_0.gender = charaStatue.sex;
        GameObjectChar.send(new MSG_OVERCOME_NPC_INFO(), vo_20689_0);
    }

    public static void challenge(Chara chara, int npcId){
        int index = getIndex(npcId);
        CharaStatue charaStatue = getCharStaure(chara.menpai, npcId);

        Npc npc = new Npc();
        npc.setId(npcId);
        npc.setIcon(GameUtil.getCharWaiGuan(chara.menpai, isMan(npcId)?1:2));
        npc.setName(charaStatue.name);

        if(chara.level<70+index*10){
            GameUtil.notifyOpenMenu(npc, MsgUtil.WU_XUE_SHANG_QIQN);
            return;
        }
        if(chara.level>70+index*10+9){
            GameUtil.notifyOpenMenu(npc, MsgUtil.DAO_LI_GAO_SHEN);
            return;
        }
        int npcSex = isMan(npcId)?1:2;
        if(npcSex!=chara.sex){
            GameUtil.notifyOpenMenu(npc, MsgUtil.NAN_NV_YOU_BIE);
            return;
        }
        FightManager.goFightChallengeCharaStatue(chara, charaStatue, BattleType.ZHEGN_DAO_DIAN, (fightContainer)->{
            //称号
            if(charaStatue.id>0 && charaStatue.id!=chara.id){
                //撤销旧的称号
                TitleService.removeUserTitle(charaStatue.id, TitleConst.TITLE_EVENT_SHI_DAO_DIAN);
                TitleService.grantTitle(GameObjectChar.getGameObjectChar(), TitleConst.TITLE_EVENT_SHI_DAO_DIAN, titles[index]);
            }else{
                TitleService.grantTitle(GameObjectChar.getGameObjectChar(), TitleConst.TITLE_EVENT_SHI_DAO_DIAN, titles[index]);
            }
            fightContainer.charaStatue.copyChengHao(titles[index]);

            //雕像
            CharaStatueService.saveCharaStature(getNpcName(chara.menpai, npcId), fightContainer.charaStatue);
            //刷新npc视野信息
            npc.setName(getNpcName(chara.menpai, npcId));
            npc.setMapId(MAP_ID);
            Integer[] pos = null;
            if(isMan(npcId)){
                pos = manPos[index];
            }else{
                pos = womanPos[index];
            }
            npc.setX(pos[0]);
            npc.setY(pos[1]);
            GameObjectChar.getGameObjectChar().sendOne(new MSG_APPEAR_NPC(), npc);
        });
    }

    private static boolean isMan(int npcId){
        return (npcId-NpcIds.ZHEGN_DAO_NPC_ID_BEGIN)<manPos.length;
    }
    private static int getIndex(int npcId){
        return (npcId-NpcIds.ZHEGN_DAO_NPC_ID_BEGIN) % manPos.length;
    }
    public static String getContent(int npcId){
        return contents[getIndex(npcId)];
    }

    private static String getNpcName(int menpai, int npcId){
        return NPC_NAME+"_"+menpai+"_"+(npcId-NpcIds.ZHEGN_DAO_NPC_ID_BEGIN);
    }

    public static void onEnterMap(GameObjectChar gameObjectChar){
        Chara chara = gameObjectChar.chara;
        //男
        for(int i=0;i<manPos.length;++i){
            Npc npc = new Npc();
            npc.setId(NpcIds.ZHEGN_DAO_NPC_ID_BEGIN+i);
            npc.setName(getNpcName(chara.menpai, npc.getId()));
            npc.setMapId(MAP_ID);
            npc.setIcon(GameUtil.getCharWaiGuan(chara.menpai, 1));
            Integer[] pos = manPos[i];
            npc.setX(pos[0]);
            npc.setY(pos[1]);

            checkInitCharStatue(chara.menpai, npc, titles[i]);

            gameObjectChar.sendOne(new MSG_APPEAR_NPC(), npc);
        }
        //女
        for(int i=0;i<womanPos.length;++i){
            Npc npc = new Npc();
            npc.setId(NpcIds.ZHEGN_DAO_NPC_ID_BEGIN+i+manPos.length);
            npc.setName(getNpcName(chara.menpai, npc.getId()));
            npc.setMapId(MAP_ID);
            npc.setIcon(GameUtil.getCharWaiGuan(chara.menpai, 2));
            Integer[] pos = womanPos[i];
            npc.setX(pos[0]);
            npc.setY(pos[1]);

            checkInitCharStatue(chara.menpai, npc, titles[i]);

            gameObjectChar.sendOne(new MSG_APPEAR_NPC(), npc);
        }
    }

    private static void checkInitCharStatue(int menpai, Npc npc, String title){
        CharaStatue charaStatue = getCharStaure(menpai, npc.getId());
        if(null == charaStatue){
            charaStatue = new CharaStatue();
            charaStatue.name = DEFAULT_PET_NAME;
            charaStatue.waiguan = npc.getIcon();
            charaStatue.chengHao = title;
            charaStatue.level = 50;
            charaStatue.sex = isMan(npc.getId())?1:2;

            charaStatue.fangyu = 1000;
            charaStatue.fashang = 1000;
            charaStatue.accurate = 1000;

            putCharStaure(menpai, npc.getId(), charaStatue);
        }
    }

    private static CharaStatue getCharStaure(int menpai, int npcId){
        return CharaStatueService.getCharStaure(getNpcName(menpai, npcId));
    }
    private static void putCharStaure(int menpai, int npcId, CharaStatue charaStatue){
        CharaStatueService.putCache(getNpcName(menpai, npcId), charaStatue);
    }

    public static void changeNotice(int id, String msg){
        GameObjectChar.getGameObjectChar().chara.zdd_Notice = msg;
    }

}
