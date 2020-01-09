//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import org.linlinjava.litemall.gameserver.data.vo.Vo_19945_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_64989_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7655_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACCEPT_HIT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACCEPT_MAGIC_HIT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_END_ACTION;
import org.linlinjava.litemall.gameserver.domain.JiNeng;

import java.util.Iterator;
import java.util.List;

/**
 * 如意圈
 * 该法术属于战斗技能，只能在战斗中使用，使用后，被施用对象在一定回合数内抵御一定伤害的法术攻击。
 * 说明：
 *  技能等级    持续最大回合数     可抵御的最大次数      可抵御的最大伤害
 *  1           2                   1                   20000
 *  20          2                   2                   21000
 *  ....
 * 1、持续回合数、可抵御的最大次数、可抵御的最大伤害，3项中的任意一项满足，则如意圈效果消失。
 *
 * 2、可抵御的最大伤害累积计算，当受到的伤害大于可抵御的伤害时，目标的技能效果消失后，伤害的差值将会对目标造成伤害。如使用的是1级技能时受到30000的伤害，因为技能只可抵御20000的伤害，
 * 因此在技能效果消失后，仍然将受到10000的伤害。
 */
public class RuYiQuanSkill extends FightRoundSkill {
    /**
     * 可抵御的最大伤害//TODO
     */
    private int fashangHp = 20000;
    /**
     * 可抵御的最大次数//TODO
     */
    private int defNum = 1;

    public RuYiQuanSkill() {
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = fightRequest.action;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        Vo_19945_0 vo_19945_0 = new Vo_19945_0();
        vo_19945_0.id = fightRequest.vid;
        vo_19945_0.hid = fightRequest.id;
        vo_19945_0.para_ex = 0;
        vo_19945_0.missed = 1;
        vo_19945_0.para = 0;
        vo_19945_0.damage_type = 2;
        FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);
        Vo_64989_0 vo_64989_0 = new Vo_64989_0();
        vo_64989_0.hid = fightRequest.id;
        vo_64989_0.a = 2;
        List<FightObject> targetList = FightManager.findTarget(fightContainer, fightRequest, 3, jiNeng.range);
        Iterator var8 = targetList.iterator();

        FightObject fightObject;
        while(var8.hasNext()) {
            fightObject = (FightObject)var8.next();
            vo_64989_0.list.add(fightObject.fid);
        }

        FightManager.send(fightContainer, new MSG_C_ACCEPT_MAGIC_HIT(), vo_64989_0);

        RuYiQuanSkill that;
        for(var8 = targetList.iterator(); var8.hasNext(); ) {
            fightObject = (FightObject)var8.next();
            vo_19959_0 = new Vo_19959_0();
            vo_19959_0.round = fightContainer.round;
            vo_19959_0.aid = fightObject.fid;
            vo_19959_0.action = 43;
            vo_19959_0.vid = fightObject.fid;
            vo_19959_0.para = 0;
            FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
            Vo_7655_0 vo_7655_0 = new Vo_7655_0();
            vo_7655_0.id = fightObject.fid;
            FightManager.send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
            fightObject.addBuffState(fightContainer, this.getStateType());
            that = new RuYiQuanSkill();
            fightObject.addSkill(that);
            that.buffObject = fightObject;
            that.removeRound = fightContainer.round + jiNeng.skillRound - 1;
        }

        return null;
    }

    public int reduceHp(int reduceHp){
        boolean isRemove = false;
        if(fashangHp>reduceHp){
            fashangHp = fashangHp-reduceHp;
            reduceHp = 0;
        }else {
            reduceHp = reduceHp-fashangHp;
            fashangHp = 0;

            isRemove = true;
        }
        defNum--;

        if(defNum<1){
            isRemove = true;
        }
        if(isRemove){
            remove();;
        }

        return reduceHp;
    }

    protected void doRoundSkill() {
    }

    protected void doDisappear(){
    }

    public int getStateType() {
        return 254;
    }
}
