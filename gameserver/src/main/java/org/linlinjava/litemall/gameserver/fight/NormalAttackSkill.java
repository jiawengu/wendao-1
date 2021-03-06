//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;
import java.util.Random;

import org.linlinjava.litemall.gameserver.data.vo.*;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.JiNeng;
import org.linlinjava.litemall.gameserver.process.GameUtil;
import org.linlinjava.litemall.gameserver.util.GmUtil;
import org.linlinjava.litemall.gameserver.util.RandomUtil;

public class NormalAttackSkill implements FightSkill {
    public NormalAttackSkill() {
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        List<FightResult> resultList = new ArrayList();
        int id = fightRequest.id;
        FightObject attFightObject = FightManager.getFightObject(fightContainer, id);
        FightObject victimFightObject = FightManager.getFightObject(fightContainer, fightRequest.vid);

        //烈炎
        if(attFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.LIE_YAN)){
            FightResult fightResult = tianshuSkill(fightContainer, attFightObject, victimFightObject, 164);//焦金砾石
            if(null!=fightResult){
                resultList.add(fightResult);
            }
            return resultList;
        }
        //惊雷
        if(attFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.JING_LEI)){
            FightResult fightResult = tianshuSkill(fightContainer, attFightObject, victimFightObject, 14);//流光异彩
            if(null!=fightResult){
                resultList.add(fightResult);
            }
            return resultList;
        }
        //碎石
        if(attFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.SUI_SHI)){
            FightResult fightResult = tianshuSkill(fightContainer, attFightObject, victimFightObject, 213);//天塌地陷
            if(null!=fightResult){
                resultList.add(fightResult);
            }
            return resultList;
        }
        //青木
        if(attFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.QING_MU)){
            FightResult fightResult = tianshuSkill(fightContainer, attFightObject, victimFightObject, 64);//落叶缤纷
            if(null!=fightResult){
                resultList.add(fightResult);
            }
            return resultList;
        }
        //寒冰
        if(attFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.HAN_BING)){
            FightResult fightResult = tianshuSkill(fightContainer, attFightObject, victimFightObject, 113);//怒波狂涛
            if(null!=fightResult){
                resultList.add(fightResult);
            }
            return resultList;
        }




        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = fightRequest.action;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);

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

        //必杀
        if(jiabei == 1.0F && RandomUtil.checkSuccess(attFightObject.getAttribute(FightAttribtueType.HIT_KILL_RATE))){
            if(!victimFightObject.isActiveTianshu(fightContainer, null, TianShuSkillType.YUN_TI)){//云体
                GameUtil.showImg(fightContainer, fightRequest.id, "必杀");
                jiabei = 2.0F;
            }
        }

        //破天
        float jianFangPer = 1.0F;
        if(attFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.PO_TIAN)){
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
            FightManager.send_LIFE_DELTA(fightContainer, fightResult);
        }

        //连击
        if(RandomUtil.checkSuccess(victimFightObject.getAttribute(FightAttribtueType.CONTI_HIT_RATE))){
            int num = (int) victimFightObject.getAttribute(FightAttribtueType.CONTI_HIT_NUM);
            num = RandomUtil.randomNotZeroInt(num);

            if(victimFightObject.isActiveTianshu(fightContainer, null, TianShuSkillType.XIAN_FENG)){//仙风
                num = 1;
            }

            GameUtil.showImg(fightContainer, fightRequest.id, "连击");
            for(int i=0;i<num;++i){
                vo_19945_0 = new Vo_19945_0();
                vo_19945_0.id = fightRequest.vid;
                vo_19945_0.hid = fightRequest.id;
                vo_19945_0.para_ex = 0;
                vo_19945_0.missed = 1;
                vo_19945_0.para = 0;
                vo_19945_0.damage_type = 1;
                FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);

                hurt = victimFightObject.reduceShengming(hurt, fabao, false);

                FightResult fightResult = new FightResult();
                fightResult.id = fightRequest.id;
                fightResult.vid = fightRequest.vid;
                fightResult.point = -hurt;
                fightResult.effect_no = 0;
                fightResult.damage_type = 1;

                FightManager.send_LIFE_DELTA(fightContainer, fightResult);
            }

        }

        //反击
        if(victimFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.FAN_JI)){
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


        //魔引
        if(attFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.MO_YIN)){
            int cost = hurt/20;
            if(cost>0){
                FightManager.costMofa(fightContainer, victimFightObject, cost);
                FightManager.send_MANA_DELTA(fightContainer, victimFightObject.fid, -cost);
            }
        }

        //狂暴
        if(attFightObject.isActiveTianshu(fightContainer, victimFightObject, TianShuSkillType.KUANG_BAO)){
            int randomNum = new Random().nextInt(3)+1;
                List<FightObject> targetList = FightManager.findTarget(fightContainer, fightRequest, 1, randomNum);

                Vo_64989_0 vo_64989_0 = new Vo_64989_0();
                vo_64989_0.hid = fightRequest.id;
                vo_64989_0.a = 1;
                Iterator var14 = targetList.iterator();

                while(var14.hasNext()) {
                    FightObject fightObject = (FightObject)var14.next();
                    if(fightObject.id == victimFightObject.id){
                        continue;
                    }

                    vo_64989_0.list.add(fightObject.fid);
                    vo_64989_0.missList.add(1);

                    vo_19945_0 = new Vo_19945_0();
                    vo_19945_0.id = fightObject.id;
                    vo_19945_0.hid = fightRequest.id;
                    vo_19945_0.para_ex = 0;
                    vo_19945_0.missed = 1;
                    vo_19945_0.para = 0;
                    vo_19945_0.damage_type = 1;
                    FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);
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
                        fightResult.damage_type = 1;
                        resultList.add(fightResult);
                    }

                }
            }


        return resultList;
    }

    private FightResult tianshuSkill(FightContainer fightContainer, FightObject attFightObject, FightObject victimFightObject, int skillNo){

        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = attFightObject.id;
        vo_19959_0.vid = victimFightObject.fid;
        vo_19959_0.action = 3;
        vo_19959_0.para = skillNo;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);

        Vo_19945_0 vo_19945_0 = new Vo_19945_0();
        vo_19945_0.hid = attFightObject.id;
        vo_19945_0.id = victimFightObject.fid;
        vo_19945_0.para_ex = 0;
        vo_19945_0.missed = 1;
        vo_19945_0.para = 0;
        vo_19945_0.damage_type = 1;
        FightManager.send(fightContainer, new MSG_C_ACCEPT_HIT(), vo_19945_0);

        Vo_64989_0 vo_64989_0 = new Vo_64989_0();
        vo_64989_0.hid = attFightObject.id;
        vo_64989_0.a = 1;
        vo_64989_0.list.add(victimFightObject.fid);
        FightManager.send(fightContainer, new MSG_C_ACCEPT_MAGIC_HIT(), vo_64989_0);

        int skillAttack = BattleUtils.skillAttack(attFightObject.accurate + attFightObject.accurate_ext, 1, "WS", skillNo);
        int thurt = (int) (2.5*BattleUtils.battle(attFightObject.accurate + attFightObject.accurate_ext, skillAttack, victimFightObject.fangyu + victimFightObject.fangyu_ext));
        victimFightObject.reduceShengming(thurt, false, false);

        FightResult fightResult = new FightResult();
        fightResult.id = attFightObject.id;
        fightResult.vid = victimFightObject.fid;
        fightResult.point = -thurt;
        fightResult.effect_no = 0;
        fightResult.damage_type = 2;
        return fightResult;
    }


    public int getStateType() {
        return 0;
    }
}
