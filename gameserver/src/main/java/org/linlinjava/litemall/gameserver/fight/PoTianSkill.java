//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 破天：使用物理攻击命中对方时，有一定几率破防。
 * 忽视对方百分之50的防御值
 */
public class PoTianSkill extends FightTianshuSkill {
    public PoTianSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.PO_TIAN;
    }

}
