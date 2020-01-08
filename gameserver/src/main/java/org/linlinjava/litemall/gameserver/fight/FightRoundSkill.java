//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

public abstract class FightRoundSkill implements FightSkill {
    protected FightObject buffObject = null;
    protected int removeRound;
    protected FightContainer fightContainer;

    public FightRoundSkill() {
    }

    /**
     * 消失
     * @param fightContainer
     * @return
     */
    public boolean disappear(FightContainer fightContainer) {
        if (this.removeRound <= fightContainer.round) {
            this.doDisappear();
            this.buffObject.removeBuffState(fightContainer, this.getStateType());
            return true;
        } else {
            return false;
        }
    }

    protected abstract void doRoundSkill();

    protected abstract void doDisappear();
}
