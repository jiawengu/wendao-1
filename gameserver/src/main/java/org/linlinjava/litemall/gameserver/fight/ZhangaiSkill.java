package org.linlinjava.litemall.gameserver.fight;

import java.util.Iterator;
import java.util.List;

/**
 * 障碍技能
 */
public abstract class ZhangaiSkill extends FightRoundSkill{
    public ZhangaiSkill() {
    }

    public ZhangaiSkill(FightObject buffObject, int removeRound, FightContainer fightContainer) {
        super(buffObject, removeRound, fightContainer);
    }

    /**
     * 障碍技能选择目标
     * @param fightContainer
     * @param fightRequest
     * @param num
     * @return
     */
    public List<FightObject> findTargets(FightContainer fightContainer, FightRequest fightRequest, int num){
        List<FightObject> targetList = FightManager.findTarget(fightContainer, fightRequest, 1, num);
        FightObject att = FightManager.getFightObject(fightContainer, fightRequest.id);

        for(Iterator<FightObject> iter = targetList.iterator();iter.hasNext();){
            FightObject aff = iter.next();
            if(att.friend<aff.friend){
                iter.remove();
            }
        }
        return targetList;
    }

}
