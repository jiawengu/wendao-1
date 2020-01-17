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
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACCEPT_MAGIC_HIT;
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
        FightObject attFightObject = FightManager.getFightObject(fightContainer, id);
        FightObject victimFightObject = FightManager.getFightObject(fightContainer, fightRequest.vid);
        boolean fabao = true;
        FightFabaoSkill fabaoSkill = attFightObject.getFabaoSkill();
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

        //破天
        float jianFangPer = 1.0F;
        if(attFightObject.isActiveTianshu(fightContainer, TianShuSkillType.PO_TIAN)){
            jianFangPer = 0.5F;
        }

        Vo_19945_0 vo_19945_0 = new Vo_19945_0();
        vo_19945_0.id = fightRequest.vid;
        vo_19945_0.hid = fightRequest.id;
        vo_19945_0.para_ex = 0;
        vo_19945_0.missed = 1;
        vo_19945_0.para = 0;
        vo_19945_0.damage_type = 1;
        FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);
        int hurt = BattleUtils.battle(attFightObject.accurate + attFightObject.accurate_ext, 0, (int) (victimFightObject.fangyu*jianFangPer + victimFightObject.fangyu_ext));
        hurt = (int)((float)hurt * jiabei);
        hurt = victimFightObject.reduceShengming(hurt, fabao, false);
        {
            FightResult fightResult = new FightResult();
            fightResult.id = fightRequest.id;
            fightResult.vid = fightRequest.vid;
            fightResult.point = -hurt;
            fightResult.effect_no = 0;
            fightResult.damage_type = 1;
            resultList.add(fightResult);
        }

        //反击
        if(victimFightObject.isActiveTianshu(fightContainer, TianShuSkillType.FAN_JI)){
            int fanShang = hurt*10/6;
            attFightObject.reduceShengming(fanShang, false, false);

            FightResult fightResult = new FightResult();
            fightResult.id = victimFightObject.fid;
            fightResult.vid = attFightObject.fid;
            fightResult.point = -fanShang;
            fightResult.effect_no = 0;
            fightResult.damage_type = 4097;
            resultList.add(fightResult);
        }

        //烈炎
        if(attFightObject.isActiveTianshu(fightContainer, TianShuSkillType.LIE_YAN)){
            int skillAttack = BattleUtils.skillAttack(attFightObject.fashang + attFightObject.fashang_ext, 1, "FS", 164);//焦金砾石
            int thurt = (int) (2.5*BattleUtils.battle(attFightObject.fashang + attFightObject.fashang_ext, skillAttack, victimFightObject.fangyu + victimFightObject.fangyu_ext));

            victimFightObject.reduceShengming(thurt, false, true);

            FightResult fightResult = new FightResult();
            fightResult.id = attFightObject.id;
            fightResult.vid = victimFightObject.fid;
            fightResult.point = -thurt;
            fightResult.effect_no = 0;
            fightResult.damage_type = 2;
            resultList.add(fightResult);
        }
        //惊雷
        if(attFightObject.isActiveTianshu(fightContainer, TianShuSkillType.JING_LEI)){
            int skillAttack = BattleUtils.skillAttack(attFightObject.fashang + attFightObject.fashang_ext, 1, "FS", 14);//流光异彩
            int thurt = (int) (2.5*BattleUtils.battle(attFightObject.fashang + attFightObject.fashang_ext, skillAttack, victimFightObject.fangyu + victimFightObject.fangyu_ext));

            victimFightObject.reduceShengming(thurt, false, true);

            FightResult fightResult = new FightResult();
            fightResult.id = attFightObject.id;
            fightResult.vid = victimFightObject.fid;
            fightResult.point = -thurt;
            fightResult.effect_no = 0;
            fightResult.damage_type = 2;
            resultList.add(fightResult);
        }
        //碎石
        if(attFightObject.isActiveTianshu(fightContainer, TianShuSkillType.SUI_SHI)){
            int skillAttack = BattleUtils.skillAttack(attFightObject.fashang + attFightObject.fashang_ext, 1, "FS", 213);//天塌地陷
            int thurt = (int) (2.5*BattleUtils.battle(attFightObject.fashang + attFightObject.fashang_ext, skillAttack, victimFightObject.fangyu + victimFightObject.fangyu_ext));

            victimFightObject.reduceShengming(thurt, false, true);

            FightResult fightResult = new FightResult();
            fightResult.id = attFightObject.id;
            fightResult.vid = victimFightObject.fid;
            fightResult.point = -thurt;
            fightResult.effect_no = 0;
            fightResult.damage_type = 2;
            resultList.add(fightResult);
        }
        //青木
        if(attFightObject.isActiveTianshu(fightContainer, TianShuSkillType.QING_MU)){
            int skillAttack = BattleUtils.skillAttack(attFightObject.fashang + attFightObject.fashang_ext, 1, "FS", 64);//落叶缤纷
            int thurt = (int) (2.5*BattleUtils.battle(attFightObject.fashang + attFightObject.fashang_ext, skillAttack, victimFightObject.fangyu + victimFightObject.fangyu_ext));

            victimFightObject.reduceShengming(thurt, false, true);

            FightResult fightResult = new FightResult();
            fightResult.id = attFightObject.id;
            fightResult.vid = victimFightObject.fid;
            fightResult.point = -thurt;
            fightResult.effect_no = 0;
            fightResult.damage_type = 2;
            resultList.add(fightResult);
        }
        //寒冰
        if(attFightObject.isActiveTianshu(fightContainer, TianShuSkillType.HAN_BING)){
            int skillAttack = BattleUtils.skillAttack(attFightObject.fashang + attFightObject.fashang_ext, 1, "FS", 113);//怒波狂涛
            int thurt = (int) (2.5*BattleUtils.battle(attFightObject.fashang + attFightObject.fashang_ext, skillAttack, victimFightObject.fangyu + victimFightObject.fangyu_ext));

            victimFightObject.reduceShengming(thurt, false, true);

            FightResult fightResult = new FightResult();
            fightResult.id = attFightObject.id;
            fightResult.vid = victimFightObject.fid;
            fightResult.point = -thurt;
            fightResult.effect_no = 0;
            fightResult.damage_type = 2;
            resultList.add(fightResult);
        }

        //狂暴
        if(attFightObject.isActiveTianshu(fightContainer, TianShuSkillType.KUANG_BAO)){
            List<FightObject> targetList = FightManager.findTarget(fightContainer, fightRequest, 1, 4);
            vo_19945_0 = new Vo_19945_0();
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
            Iterator var20 = targetList.iterator();

            while(var20.hasNext()) {
                FightObject fightObject = (FightObject)var20.next();
                if(fightObject.id == victimFightObject.id){
                    continue;
                }
                int showhurt = (int)((double)hurt * 0.5D);
                {
                    showhurt = fightObject.reduceShengming(showhurt, fabao, false);
                    FightResult fightResult = new FightResult();
                    fightResult.id = fightRequest.id;
                    fightResult.vid = fightObject.fid;
                    fightResult.point = -showhurt;
                    fightResult.effect_no = 0;
                    fightResult.damage_type = 4097;
                    resultList.add(fightResult);
                }

            }
        }

        return resultList;
    }


    public int getStateType() {
        return 0;
    }
}
