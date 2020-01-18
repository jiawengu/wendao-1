package org.linlinjava.litemall.gameserver.data.xls_config.pirate;

import org.linlinjava.litemall.gameserver.data.xls_config.outdoorboss.OutdoorBossItem;

public class PirateItem extends OutdoorBossItem {

    /**可挑战等级*/
    public int challengingLevel;

    public void setChallengingLevel(int challengingLevel) {
        this.challengingLevel = challengingLevel;
    }
}
