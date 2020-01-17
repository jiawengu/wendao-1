//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 *   云体：宠物在受到物理必杀攻击时，有一定几率使此次必杀无效。
 * 有几率忽视物理必杀
 */
public class YunTiSkill extends FightTianshuSkill {
    public YunTiSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.YUN_TI;
    }

}
