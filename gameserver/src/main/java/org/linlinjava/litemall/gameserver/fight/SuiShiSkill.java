//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 碎石：在使用物理攻击命中对手的时候，有一定几率对被攻击方造成附加土系法术伤害
 * 附加土系伤害技能为 天塌地陷 同时会造成2.5倍伤害
 */
public class SuiShiSkill extends FightTianshuSkill {
    public SuiShiSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.SUI_SHI;
    }

}
