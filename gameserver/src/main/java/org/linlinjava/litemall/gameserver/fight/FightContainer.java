//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import org.linlinjava.litemall.gameserver.domain.CharaStatue;

import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.atomic.AtomicInteger;
import java.util.function.Consumer;

public class FightContainer {
    /**
     * 战斗类型
     */
    public BattleType battleType;
    public int id = 1000;
    public List<FightResult> resultList = new ArrayList();
    /**
     * 回合
     */
    public int round = 1;
    /**
     * 1:等待选择技能
     * 3:doAction
     * 4:战斗结束
     * 5:移除战斗队列
     */
    public AtomicInteger state = new AtomicInteger(1);
    public List<FightTeam> teamList = new ArrayList();
    public List<FightObject> doActionList;
    /**
     * 本回合开始时间
     */
    public long roundTime = System.currentTimeMillis();
    public Consumer<Boolean> fightCallback;

    public CharaStatue charaStatue;
    public IFightNpcSuccess success;

    public FightContainer() {
    }
    public FightContainer(BattleType battleType) {
        this.battleType = battleType;
    }
    public boolean isBattleType(BattleType checkType){
        if(null == battleType){
            return false;
        }
        return battleType == checkType;
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
