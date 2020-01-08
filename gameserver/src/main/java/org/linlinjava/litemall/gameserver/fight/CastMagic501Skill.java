//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19945_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_64989_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACCEPT_HIT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACCEPT_MAGIC_HIT;
import org.linlinjava.litemall.gameserver.domain.JiNeng;

/**
 * 物理攻击-力破千钧：对敌方使用，令对手及其身边的数个目标受到与任务物理攻击相关的物理伤害。
 */
public class CastMagic501Skill implements FightSkill {
    public CastMagic501Skill() {
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        List<FightResult> resultList = new ArrayList();
        int attaNum = jiNeng.range;
        FightObject attFightObject = FightManager.getFightObject(fightContainer, fightRequest.id);
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = 2;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        boolean fabao = true;
        FightFabaoSkill fabaoSkill = attFightObject.getFabaoSkill();
        float jiabei = 1.0F;
        if (fabaoSkill != null) {
            if (fabaoSkill.getStateType() == 8398 && fabaoSkill.isActive()) {
                fabao = false;
                fabaoSkill.sendEffect(fightContainer);
            }

            if (fabaoSkill.getStateType() == 8016 && fabaoSkill.isActive()) {
                fabaoSkill.sendEffect(fightContainer);
                jiabei = 2.5F;
            }
        }

        List<FightObject> targetList = FightManager.findTarget(fightContainer, fightRequest, 1, attaNum);
        Vo_19945_0 vo_19945_0 = new Vo_19945_0();
        vo_19945_0.id = fightRequest.vid;
        vo_19945_0.hid = fightRequest.id;
        vo_19945_0.para_ex = 0;
        vo_19945_0.missed = 1;
        vo_19945_0.para = 0;
        vo_19945_0.damage_type = 1;
        FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);
        Vo_64989_0 vo_64989_0 = new Vo_64989_0();
        vo_64989_0.hid = fightRequest.id;
        vo_64989_0.a = 1;
        Iterator var14 = targetList.iterator();

        while(var14.hasNext()) {
            FightObject fightObject = (FightObject)var14.next();
            vo_64989_0.list.add(fightObject.fid);
            vo_64989_0.missList.add(1);
        }

        FightManager.send(fightContainer, new MSG_C_ACCEPT_MAGIC_HIT(), vo_64989_0);
        int hurt = 0;
        Iterator var20 = targetList.iterator();

        while(var20.hasNext()) {
            FightObject fightObject = (FightObject)var20.next();
            int showhurt;
            if (hurt == 0) {
                showhurt = BattleUtils.skillAttack(attFightObject.accurate + attFightObject.accurate_ext, jiNeng.skill_level, "WS", jiNeng.skill_no - 501);
                showhurt = (int)((float)showhurt * jiabei);
                int thurt = BattleUtils.battle(attFightObject.accurate + attFightObject.accurate_ext, showhurt, fightObject.fangyu + fightObject.fangyu_ext);
                hurt = thurt;
            } else {
                hurt = (int)((double)hurt * 0.9D);
            }

            showhurt = fightObject.reduceShengming(hurt, fabao);
            FightResult fightResult = new FightResult();
            fightResult.id = fightRequest.id;
            fightResult.vid = fightObject.fid;
            fightResult.point = -showhurt;
            fightResult.effect_no = 0;
            fightResult.damage_type = 4097;
            resultList.add(fightResult);
        }

        return resultList;
    }

    public int getStateType() {
        return 0;
    }
}
