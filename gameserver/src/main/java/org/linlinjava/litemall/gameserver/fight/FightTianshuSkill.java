//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.List;
import org.linlinjava.litemall.gameserver.data.vo.Vo_12028_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_ATTACH_SKILL_LIGHT_EFFECT;
import org.linlinjava.litemall.gameserver.domain.JiNeng;

public abstract class FightTianshuSkill implements FightSkill {
    protected FightObject buffObject = null;

    public FightTianshuSkill() {
    }

    public boolean isActive() {
        return FightManager.RANDOM.nextInt(100)<10;
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        return null;
    }

    public void sendEffect(FightContainer fightContainer) {
        Vo_12028_0 vo_12028_0 = new Vo_12028_0();
        vo_12028_0.id = this.buffObject.fid;
        vo_12028_0.effect_no = 0;
        vo_12028_0.type = 4;
        vo_12028_0.name = this.getType().getName();
        FightManager.send(fightContainer, new MSG_ATTACH_SKILL_LIGHT_EFFECT(), vo_12028_0);
    }

    public abstract TianShuSkillType getType();

    @Override
    public int getStateType() {
        return getType().getId();
    }
}
