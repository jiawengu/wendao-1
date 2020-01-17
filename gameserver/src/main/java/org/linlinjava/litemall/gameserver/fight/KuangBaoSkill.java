//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 狂暴：物理攻击命中对手的时候，有一定几率同时使被攻击方周围的几个目标也受到伤害
 * 最多造成四个目标减血  除了主目标外  其他目标血量只减少伤害的一半
 */
public class KuangBaoSkill extends FightTianshuSkill {
    public KuangBaoSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.KUANG_BAO;
    }

}
