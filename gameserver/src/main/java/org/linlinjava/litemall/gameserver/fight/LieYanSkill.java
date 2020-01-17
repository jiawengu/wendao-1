//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 烈炎：在使用物理攻击命中对手的时候，有一定几率对被攻击方造成附加火系法术伤害
 * 附加火系法术技能为 焦金烁石    同时会造成2.5倍伤害
 */
public class LieYanSkill extends FightTianshuSkill {
    public LieYanSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.LIE_YAN;
    }

}
