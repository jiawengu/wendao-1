package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.vo.MSG_MENU_LIST_VO;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.CharaStatue;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameTeam;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.util.MsgUtil;
import org.linlinjava.litemall.gameserver.util.NpcIds;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.*;

import static org.linlinjava.litemall.gameserver.util.MsgUtil.ZHU_WEI_XIN_KU;

/**
 * 地图守护神
 */
@Service
public class MapGuardianService {
    private static final Logger logger = LoggerFactory.getLogger(MapGuardianService.class);
    private static final Map<String, Template> configMap = new LinkedHashMap<>();
    static {
        register("五龙窟四层守护神", 45, 55);
        register("蓬莱岛守护神", 45, 56);
        register("五龙窟五层守护神", 45, 58);
        register("幽冥涧守护神", 48, 62);
        register("百花谷一守护神", 53, 67);
        register("百花谷二守护神", 56, 70);
        register("百花谷三守护神", 59, 73);
        register("百花谷四守护神", 62, 76);
        register("百花谷五守护神", 65, 79);
        register("百花谷六守护神", 68, 82);
        register("百花谷七守护神", 71, 85);
        register("东昆仑守护神", 73, 87);
        register("绝人阵守护神", 73, 87);
        register("绝仙阵守护神", 78, 92);
        register("地绝阵守护神", 83, 97);
        register("天绝阵守护神", 88, 102);
        register("海底迷宫守护神", 93, 107);
        register("昆仑云海守护神", 97, 112);
        register("雪域冰原守护神", 102, 117);
        register("迷境花树守护神", 107, 122);
        register("水云间守护神", 112, 127);
        register("热砂荒漠守护神", 117, 132);
    }

    private static void register(String npcName, int minLevel, int maxLevel){
        Npc npc = GameData.that.baseNpcService.findOneByName(npcName);
        int npcIdBegin = NpcIds.MAP_GUARDIAN_NPC_ID_BEGIN+configMap.size()*5;
        int npcIdEnd = npcIdBegin + 4;
        Template template = new Template(npc, minLevel, maxLevel, npcIdBegin, npcIdEnd);
        configMap.put(npcName, template);
    }

    private static Template getTemplate(int charaStatueId){
        for(Template template:configMap.values()){
            if(charaStatueId>=template.npcIdBegin && charaStatueId<=template.npcIdEnd){
                return template;
            }
        }
        return null;
    }

    private static class Template{
        public final Npc npc;
        public final int minLevel;
        public final int maxLevel;
        public final int npcIdBegin;
        public final int npcIdEnd;

        private Template(Npc npc, int minLevel, int maxLevel, int npcIdBegin, int npcIdEnd) {
            this.npc = npc;
            this.minLevel = minLevel;
            this.maxLevel = maxLevel;
            this.npcIdBegin = npcIdBegin;
            this.npcIdEnd = npcIdEnd;
        }
    }
    /**
     * 是否是守护神
     * @param npcName
     * @return
     */
    public static boolean isProtector(String npcName){
        return npcName.endsWith("守护神");
    }

    public static void openMenu(Chara chara, Npc npc){
        Template template = configMap.get(npc.getName());
        if(null == template){
            logger.error("not found config:"+npc.getName());
            return;
        }
        String content = "我们就是传说中美貌与智慧并存、英雄与侠义的化身——人见人爱的"+npc.getName()+"!我们守护着这片土地的一草一木。"+
                MsgUtil.getTalk("看看你们的实力（"+template.minLevel+"-"+template.maxLevel+"级可挑战）")+
                MsgUtil.getTalk(ZHU_WEI_XIN_KU);
        MSG_MENU_LIST_VO menu_list_vo = GameUtil.MSG_MENU_LIST(npc, content);
        GameObjectChar.send(new MSG_MENU_LIST(), menu_list_vo);
    }
    public static void openMenu(Chara chara, int charaStatueId){
        Template template = getTemplate(charaStatueId);
        Npc npc = new Npc();
        npc.setId(charaStatueId);
        npc.setName(template.npc.getName());
        npc.setIcon(template.npc.getIcon());
        openMenu(chara, npc);
    }

    /**
     * 是否显示原始的npc
     * @param npc
     * @return
     */
    public static boolean isNpcAppear(Npc npc){
        return !CharaStatueService.containsCharStaure(getCharaStatueName(npc.getName(), 0));
    }

    public static void onEnterMap(int mapId, GameObjectChar gameObjectChar){
        for(Template template:configMap.values()){
            if(template.npc.getMapId() != mapId){
                continue;
            }

            List<CharaStatue> list = getCharaStatueList(template.npc.getName());
            if(list.isEmpty()){
                continue;
            }
            notifyNpcApprear(template, list);
        }
    }

    private static void notifyNpcApprear(Template template, List<CharaStatue> list){
        for(int i=0;i<list.size();++i){
            CharaStatue charaStatue = list.get(i);

            Npc chara = new Npc();
            chara.setMapId(template.npc.getMapId());
            chara.setId(template.npcIdBegin+i);
            chara.setIcon(charaStatue.waiguan);
            if(i%2==0){//偶数
                chara.setX(template.npc.getX()-3*i/2);
                chara.setY(template.npc.getY()-3*i/2);
            }else{//奇数
                chara.setX(template.npc.getX()+3*(i+1)/2);
                chara.setY(template.npc.getY()-3*(i+1)/2);
            }

            chara.setName(getCharaStatueName(template.npc.getName(), i));

            GameUtil.notifyNpcAppear(chara);
        }
    }

    public static void challenge(int charaStatue){
        Template template = getTemplate(charaStatue);
        challenge(template.npc);
    }

    public static void challenge(Npc npc){
        GameTeam gameTeam= GameObjectChar.getGameObjectChar().gameTeam;
        if(null == gameTeam || gameTeam.duiwu.size()<5){
            GameUtil.notifyOpenMenu(npc, "我们可不想以多欺少，你还是组满了5个人再来挑战吧。[离开]");
            return;
        }
        Chara chara = GameObjectChar.getGameObjectChar().chara;
        Template template = configMap.get(npc.getName());
        if(chara.level<template.minLevel || chara.level>template.maxLevel){
            GameUtil.notifyOpenMenu(npc, "等级不符合。[离开]");
            return;
        }

        CharaStatue charaStatue = CharaStatueService.getCharStaure(getCharaStatueName(npc.getName(), 0));
        List<CharaStatue> defList = new ArrayList<>();
        if(null==charaStatue){
            charaStatue = new CharaStatue();
            charaStatue.name = npc.getName();
            charaStatue.waiguan = npc.getIcon();
            charaStatue.level = 50;

            charaStatue.fangyu = 1000;
            charaStatue.fashang = 1000;
            charaStatue.accurate = 1000;
            defList.add(charaStatue);
        }else{
            defList.add(charaStatue);
            for(int i=1;i<=4;i++){
                String name = getCharaStatueName(npc.getName(), i);
                charaStatue = CharaStatueService.getCharStaure(name);
                if(null==charaStatue){
                    logger.error("charaStatue is null!"+name);
                    continue;
                }
                defList.add(charaStatue);
            }
        }

        FightManager.goFightMapGuardian(npc.getName(), GameObjectChar.getGameObjectChar().chara, defList);
    }

    private static List<CharaStatue> getCharaStatueList(String npcName){
        List<CharaStatue> list = new ArrayList<>();
        for(int i=0;i<=4;i++){
            String name = getCharaStatueName(npcName, i);
            CharaStatue charaStatue = CharaStatueService.getCharStaure(name);
            if(null==charaStatue){
                continue;
            }
            list.add(charaStatue);
        }
        return list;
    }

    private static String getCharaStatueName(String npcName, int index){
        return npcName+"_"+index;
    }

    public static void onChallengeSuccess(String npcName, List<CharaStatue> attCharaStatue, List<CharaStatue> defCharaStatueList){
        for(int i=0;i<attCharaStatue.size();++i){
            CharaStatue charaStatue = attCharaStatue.get(i);
            charaStatue.copyChengHao(npcName);
            CharaStatueService.saveCharaStature(getCharaStatueName(npcName, i), charaStatue);
        }

        Template template = configMap.get(npcName);
        GameUtil.notifyNpcDisappear(template.npc);
        notifyNpcApprear(template, attCharaStatue);
    }

}
