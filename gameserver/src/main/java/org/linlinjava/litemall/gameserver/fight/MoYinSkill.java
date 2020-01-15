//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 *   魔引：物理攻击命中对手的时候，有一定几率造成被攻击方的法力消耗。
 * 造成的法力消耗大概是物理伤害的二十分之一
 */
public class MoYinSkill extends FightTianshuSkill {
    public MoYinSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.MO_YIN;
    }

}
