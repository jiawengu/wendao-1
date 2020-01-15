//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 降魔斩：使用法术攻击命中对方时，有一定几率忽视对方的法术抗性
 * 出降魔斩效果时 造成的伤害是平时的双倍
 */
public class XiangMoZhanSkill extends FightTianshuSkill {
    public XiangMoZhanSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.XIANG_MO_ZHAN;
    }

}
