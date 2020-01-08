//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19945_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACCEPT_HIT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.domain.JiNeng;

public class NormalAttackSkill implements FightSkill {
    public NormalAttackSkill() {
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        List<FightResult> resultList = new ArrayList();
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = fightRequest.action;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        int id = fightRequest.id;
        FightObject fightObject = FightManager.getFightObject(fightContainer, id);
        FightObject victimFightObject = FightManager.getFightObject(fightContainer, fightRequest.vid);
        boolean fabao = true;
        FightFabaoSkill fabaoSkill = fightObject.getFabaoSkill();
        float jiabei = 1.0F;
        if (fabaoSkill != null) {
            if (fabaoSkill.getStateType() == 8398 && fabaoSkill.isActive()) {
                fabao = false;
            }

            if (fabaoSkill.getStateType() == 8016 && fabaoSkill.isActive()) {
                fabaoSkill.sendEffect(fightContainer);
                jiabei = 2.5F;
            }
        }

        Vo_19945_0 vo_19945_0 = new Vo_19945_0();
        vo_19945_0.id = fightRequest.vid;
        vo_19945_0.hid = fightRequest.id;
        vo_19945_0.para_ex = 0;
        vo_19945_0.missed = 1;
        vo_19945_0.para = 0;
        vo_19945_0.damage_type = 1;
        FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);
        int hurt = BattleUtils.battle(fightObject.accurate + fightObject.accurate_ext, 0, victimFightObject.fangyu + victimFightObject.fangyu_ext);
        hurt = (int)((float)hurt * jiabei);
        hurt = victimFightObject.reduceShengming(hurt, fabao);
        FightResult fightResult = new FightResult();
        fightResult.id = fightRequest.id;
        fightResult.vid = fightRequest.vid;
        fightResult.point = -hurt;
        fightResult.effect_no = 0;
        fightResult.damage_type = 1;
        resultList.add(fightResult);
        return resultList;
    }

    public int getStateType() {
        return 0;
    }
}
