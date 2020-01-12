package org.linlinjava.litemall.gameserver.service;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8247_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_MENU_LIST;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameTeam;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.util.MsgUtil;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;

import static org.linlinjava.litemall.gameserver.util.MsgUtil.ZHU_WEI_XIN_KU;

/**
 * 地图守护神
 */
@Service
public class MapGuardianService {
    private static final Logger logger = LoggerFactory.getLogger(MapGuardianService.class);
    private static final Map<String, Template> configMap = new HashMap<>();
    static {
        configMap.put("五龙窟四层守护神", new Template(45, 55));
        configMap.put("蓬莱岛守护神", new Template(45, 56));
        configMap.put("五龙窟五层守护神", new Template(45, 58));
        configMap.put("幽冥涧守护神", new Template(48, 62));
        configMap.put("百花谷一守护神", new Template(53, 67));
        configMap.put("百花谷二守护神", new Template(56, 70));
        configMap.put("百花谷三守护神", new Template(59, 73));
        configMap.put("百花谷四守护神", new Template(62, 76));
        configMap.put("百花谷五守护神", new Template(65, 79));
        configMap.put("百花谷六守护神", new Template(68, 82));
        configMap.put("百花谷七守护神", new Template(71, 85));
        configMap.put("东昆仑守护神", new Template(73, 87));
        configMap.put("绝人阵守护神", new Template(73, 87));
        configMap.put("绝仙阵守护神", new Template(78, 92));
        configMap.put("地绝阵守护神", new Template(83, 97));
        configMap.put("天绝阵守护神", new Template(88, 102));
        configMap.put("海底迷宫守护神", new Template(93, 107));
        configMap.put("昆仑云海守护神", new Template(97, 112));
        configMap.put("雪域冰原守护神", new Template(102, 117));
        configMap.put("迷境花树守护神", new Template(107, 122));
        configMap.put("水云间守护神", new Template(112, 127));
        configMap.put("热砂荒漠守护神", new Template(117, 132));
    }

    private static class Template{
        public final int minLevel;
        public final int maxLevel;

        private Template(int minLevel, int maxLevel) {
            this.minLevel = minLevel;
            this.maxLevel = maxLevel;
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
        Vo_8247_0 vo_8247_0 = GameUtil.MSG_MENU_LIST(npc, content);
        GameObjectChar.send(new MSG_MENU_LIST(), vo_8247_0);
    }

    public static void challenge(Npc npc){
        GameTeam gameTeam= GameObjectChar.getGameObjectChar().gameTeam;
        if(null == gameTeam){
            return;
        }
        //TODO
    }
}
