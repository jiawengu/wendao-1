//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 *  青木：在使用物理攻击命中对手的时候，有一定几率对被攻击方造成附加木系法术伤害
 *  附加木系伤害技能为 落英缤纷   同时会造成2.5倍伤害
 */
public class QingMuSkill extends FightTianshuSkill {
    public QingMuSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.QING_MU;
    }

}
