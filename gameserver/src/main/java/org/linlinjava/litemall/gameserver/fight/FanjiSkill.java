//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 反击：受到物理攻击时，有一定几率物理反击。
 * 在对方上来打自己的时候会反击一下 伤害是对方造成伤害的百分之60
 */
public class FanjiSkill extends FightTianshuSkill {
    public FanjiSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.FAN_JI;
    }
}
