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
import org.linlinjava.litemall.gameserver.data.vo.Vo_7655_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACCEPT_HIT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACCEPT_MAGIC_HIT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_END_ACTION;
import org.linlinjava.litemall.gameserver.domain.JiNeng;

/**
 * 法攻技能
 */
public class CastMagic11Skill implements FightSkill {
    public CastMagic11Skill() {
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        List<FightResult> resultList = new ArrayList();
        int attaNum = jiNeng.range;
        FightObject attFightObject = FightManager.getFightObject(fightContainer, fightRequest.id);
        List<FightObject> targetList = FightManager.findTarget(fightContainer, fightRequest, 1, attaNum);
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = 3;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        int attTimes = 1;
        boolean fabao = true;
        FightFabaoSkill fabaoSkill = attFightObject.getFabaoSkill();
        if (fabaoSkill != null) {
            if (fabaoSkill.getStateType() == 8013 && fabaoSkill.isActive()) {
                fabaoSkill.sendEffect(fightContainer);
                attTimes = 2;
            }

            if (fabaoSkill.getStateType() == 8398 && fabaoSkill.isActive()) {
                fabaoSkill.sendEffect(fightContainer);
                fabao = false;
            }
        }

        if (attFightObject.isActiveTianshu(fightContainer, 7041)) {
            attTimes = 2;
            attFightObject.fightRequest = fightRequest;
        }

        int hurt = 0;
        float jiabei = 1.0F;
        if (attTimes != 2 && jiabei == 1.0F && attFightObject.isActiveTianshu(fightContainer, 7036)) {
            jiabei = 1.5F;
        }

        if (attTimes != 2 && jiabei == 1.0F && attFightObject.isActiveTianshu(fightContainer, 7039)) {
            jiabei = 1.5F;
        }

        Vo_19945_0 vo_19945_0 = new Vo_19945_0();
        vo_19945_0.id = fightRequest.vid;
        vo_19945_0.hid = fightRequest.id;
        vo_19945_0.para_ex = 0;
        vo_19945_0.missed = 1;
        vo_19945_0.para = 0;
        vo_19945_0.damage_type = 2;
        FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);
        Vo_64989_0 vo_64989_0 = new Vo_64989_0();
        vo_64989_0.hid = fightRequest.id;
        vo_64989_0.a = 1;
        Iterator var16 = targetList.iterator();

        FightObject fightObject;
        while(var16.hasNext()) {
            fightObject = (FightObject)var16.next();
            vo_64989_0.list.add(fightObject.fid);
            vo_64989_0.missList.add(1);
        }

        FightManager.send(fightContainer, new MSG_C_ACCEPT_MAGIC_HIT(), vo_64989_0);
        var16 = targetList.iterator();

        int remove;
        FightObject next;
        while(var16.hasNext()) {
            fightObject = (FightObject)var16.next();
            if (hurt == 0) {
                remove = BattleUtils.skillAttack(attFightObject.fashang + attFightObject.fashang_ext, jiNeng.skill_level, "FS", jiNeng.skill_no);
                remove = (int)((float)remove * jiabei);
                int thurt = BattleUtils.battle(attFightObject.fashang + attFightObject.fashang_ext, remove, fightObject.fangyu + fightObject.fangyu_ext);
                hurt = thurt;
            } else {
                hurt = (int)((double)hurt * 0.9D);
            }

            fabaoSkill = fightObject.getFabaoSkill();
            if (!fabao && fabaoSkill != null && fabaoSkill.getStateType() == 8014 && fabaoSkill.isActive()) {
                fabaoSkill.sendEffect(fightContainer);
                List<FightObject> exclude = new ArrayList();
                exclude.add(attFightObject);
                exclude.add(fightObject);
                next = FightManager.getRandomObject(fightContainer, exclude);
                int showhurt = next.reduceShengming(hurt, false);
                FightResult fightResult = new FightResult();
                fightResult.id = fightRequest.id;
                fightResult.vid = next.fid;
                fightResult.point = -showhurt;
                fightResult.effect_no = 0;
                fightResult.damage_type = 2;
                resultList.add(fightResult);
            } else {
                remove = fightObject.reduceShengming(hurt, fabao);
                FightResult fightResult = new FightResult();
                fightResult.id = fightRequest.id;
                fightResult.vid = fightObject.fid;
                fightResult.point = -remove;
                fightResult.effect_no = 0;
                fightResult.damage_type = 2;
                resultList.add(fightResult);
            }
        }

        if (attTimes == 2) {
            if (resultList != null) {
                var16 = resultList.iterator();

                while(var16.hasNext()) {
                    FightResult fightResult = (FightResult)var16.next();
                    FightManager.send_LIFE_DELTA(fightContainer, fightResult);
                }
            }

            Vo_7655_0 vo_7655_0 = new Vo_7655_0();
            vo_7655_0.id = attFightObject.fid;
            FightManager.send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
            Iterator<FightObject> iterator = targetList.iterator();
            remove = 0;

            while(iterator.hasNext()) {
                next = (FightObject)iterator.next();
                if (next.isDead()) {
                    iterator.remove();
                    ++remove;
                }
            }

            List<FightObject> fightObjectList = FightManager.getFightTeamDM(fightContainer, attFightObject.fid).fightObjectList;
            Iterator var31 = fightObjectList.iterator();

            FightObject object;
            while(var31.hasNext()) {
                object = (FightObject)var31.next();
                if (remove == 0) {
                    break;
                }

                if (!object.isDead() && !targetList.contains(object)) {
                    targetList.add(object);
                    --remove;
                }
            }

            if (FightManager.getFightObject(fightContainer, fightRequest.vid).isDead() && targetList.size() > 0) {
                fightRequest.vid = ((FightObject)targetList.get(0)).fid;
            }

            vo_19959_0 = new Vo_19959_0();
            vo_19959_0.round = fightContainer.round;
            vo_19959_0.aid = fightRequest.id;
            vo_19959_0.action = 3;
            vo_19959_0.vid = fightRequest.vid;
            vo_19959_0.para = fightRequest.para;
            FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
            vo_19945_0 = new Vo_19945_0();
            vo_19945_0.id = fightRequest.vid;
            vo_19945_0.hid = fightRequest.id;
            vo_19945_0.para_ex = 0;
            vo_19945_0.missed = 1;
            vo_19945_0.para = 0;
            vo_19945_0.damage_type = 2;
            FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);
            vo_64989_0 = new Vo_64989_0();
            vo_64989_0.hid = fightRequest.id;
            vo_64989_0.a = 1;
            var31 = targetList.iterator();

            while(var31.hasNext()) {
                object = (FightObject)var31.next();
                vo_64989_0.list.add(object.fid);
                vo_64989_0.missList.add(1);
            }

            FightManager.send(fightContainer, new MSG_C_ACCEPT_MAGIC_HIT(), vo_64989_0);
            resultList = new ArrayList();
            hurt = 0;
            var31 = targetList.iterator();

            while(var31.hasNext()) {
                object = (FightObject)var31.next();
                int showhurt;
                if (hurt == 0) {
                    showhurt = BattleUtils.skillAttack(attFightObject.fashang + attFightObject.fashang_ext, jiNeng.skill_level, "FS", jiNeng.skill_no);
                    int thurt = BattleUtils.battle(attFightObject.fashang + attFightObject.fashang_ext, showhurt, object.fangyu + object.fangyu_ext);
                    hurt = thurt;
                } else {
                    hurt = (int)((double)hurt * 0.9D);
                }

                showhurt = object.reduceShengming(hurt, fabao);
                FightResult fightResult = new FightResult();
                fightResult.id = fightRequest.id;
                fightResult.vid = object.fid;
                fightResult.point = -showhurt;
                fightResult.effect_no = 0;
                fightResult.damage_type = 2;
                resultList.add(fightResult);
            }
        }

        return resultList;
    }

    public int getStateType() {
        return 0;
    }
}
