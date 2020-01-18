package org.linlinjava.litemall.gameserver.user_logic;

import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;

import java.util.ArrayList;
import java.util.List;

public class UserPartyDailyChallengeLogic extends BaseLogic {

    public static final String MENU_STR = "【日常挑战】 帮派日常挑战";

    public String openMenu(int npcId){
        if(npcId == 1006){
            return "[" + UserPartyDailyChallengeLogic.MENU_STR + "]";
        }
        return null;
    }

    public void selectMenuItem(int npcId, String menu) {
        if(npcId == 1006 && menu != null && menu.compareTo(MENU_STR) == 0){
            List<String> monsterList = new ArrayList<>();
            monsterList.add("天兵女");
            monsterList.add("天兵男");
            FightManager.goFight(GameObjectChar.getGameObjectChar().chara, monsterList);
        }
    }

}
