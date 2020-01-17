//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 惊雷：在使用物理攻击命中对手的时候，有一定几率对被攻击方造成附加金系法术伤害。
 * 附加金系伤害技能为 流光异彩   同时会造成2.5倍伤害
 */
public class JingLeiSkill extends FightTianshuSkill {
    public JingLeiSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.JING_LEI;
    }

}
