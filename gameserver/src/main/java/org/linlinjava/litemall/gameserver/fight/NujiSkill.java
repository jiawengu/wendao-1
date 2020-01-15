//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 怒击：使用法术攻击命中对方时，有一定几率使法术攻击力增强
 * 造成2.5倍法术伤害
 */
public class NujiSkill extends FightTianshuSkill {
    public NujiSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.NU_JI;
    }

}
