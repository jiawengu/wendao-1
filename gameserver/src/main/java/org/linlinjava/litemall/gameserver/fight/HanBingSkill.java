//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

/**
 * 寒冰：在使用物理攻击命中对手的时候，有一定几率对被攻击方造成附加水系法术伤害。
 * 附加水系伤害技能为 怒波狂涛   同时会造成2.5倍伤害
 */
public class HanBingSkill extends FightTianshuSkill {
    public HanBingSkill() {
    }

    @Override
    public TianShuSkillType getType() {
        return TianShuSkillType.HAN_BING;
    }

}
