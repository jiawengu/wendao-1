//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 修罗术：使用法术攻击对方时，有一定几率出现连击效果。
 * 出现法术连击效果 最多连击五次  每次连击只有上次连击的百分之五十伤害
 */
public class XiuluoshuSkill extends FightTianshuSkill {
    public XiuluoshuSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.XIU_LUO;
    }

}
