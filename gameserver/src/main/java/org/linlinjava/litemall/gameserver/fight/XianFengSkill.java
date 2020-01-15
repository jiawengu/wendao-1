//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 *  仙风：宠物在受到连击时，有一定几率只受到连击中的第一次伤害，在受到连击死亡后复活，连击也不再继续。
 */
public class XianFengSkill extends FightTianshuSkill {
    public XianFengSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.XIAN_FENG;
    }

}
