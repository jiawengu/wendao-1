//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;

public class FightContainer {
    public int id = 1000;
    public List<FightResult> resultList = new ArrayList();
    public int round = 1;
    public AtomicInteger state = new AtomicInteger(1);
    public List<FightTeam> teamList = new ArrayList();
    public List<FightObject> doActionList;
    public long roundTime = System.currentTimeMillis();
    public Consumer<Boolean> fightCallback;

    public FightContainer() {
    }

    public boolean isPlayerWin() {
        FightTeam playerTeam = teamList.get(0);

        for (FightObject fightObject : playerTeam.fightObjectList) {
            if (fightObject.shengming > 0) {
                return true;
            }
        }

        return false;
    }
}
