//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.List;

public class FightTeam {
    public List<FightObject> fightObjectList = new ArrayList();
    public int leader;
    /**
     * 1：攻击方
     * 2：防守方
     */
    public int type;

    public FightTeam() {
    }

    public void add(FightObject fo) {
        this.fightObjectList.add(fo);
    }
}
