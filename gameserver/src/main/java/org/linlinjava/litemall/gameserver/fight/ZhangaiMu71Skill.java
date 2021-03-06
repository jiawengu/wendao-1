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
 * 障碍木-中毒状态
 * 中毒伤害：法系伤害
 */
public class ZhangaiMu71Skill extends ZhangaiSkill {
    private int xueliang;

    public ZhangaiMu71Skill() {
    }
    public ZhangaiMu71Skill(FightObject buffObject, int skillRound, FightContainer fightContainer) {
        super(buffObject, fightContainer.round + skillRound - 1, fightContainer);
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        List<FightResult> resultList = new ArrayList();
        FightObject attFightObject = FightManager.getFightObject(fightContainer, fightRequest.id);
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = fightRequest.action;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        boolean fabao = true;
        FightFabaoSkill fabaoSkill = attFightObject.getFabaoSkill();
        if (fabaoSkill != null && fabaoSkill.getStateType() == 8398 && fabaoSkill.isActive()) {
            fabao = false;
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
        vo_64989_0.a = 2;
        List<FightObject> targetList = findTargets(fightContainer, fightRequest, jiNeng.range);
        Iterator var12 = targetList.iterator();

        FightObject fightObject;
        while(var12.hasNext()) {
            fightObject = (FightObject)var12.next();
            vo_64989_0.list.add(fightObject.fid);
        }

        FightManager.send(fightContainer, new MSG_C_ACCEPT_MAGIC_HIT(), vo_64989_0);
        var12 = targetList.iterator();

        while(var12.hasNext()) {
            fightObject = (FightObject)var12.next();
            vo_19959_0 = new Vo_19959_0();
            vo_19959_0.round = fightContainer.round;
            vo_19959_0.aid = fightObject.fid;
            vo_19959_0.action = 43;
            vo_19959_0.vid = fightObject.fid;
            vo_19959_0.para = 0;
            FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
            Vo_7655_0 vo_7655_0 = new Vo_7655_0();
            vo_7655_0.id = fightObject.fid;
            FightManager.send(fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
            fightObject.addBuffState(fightContainer, this.getStateType());
            ZhangaiMu71Skill that = new ZhangaiMu71Skill(fightObject, jiNeng.skillRound, fightContainer);
            fightObject.addSkill(that);
            int showhurt;
            int hurt = 0;
            if (hurt == 0) {
                showhurt = BattleUtils.skillAttack(attFightObject.fashang + attFightObject.fashang_ext, jiNeng.skill_level, "FS", jiNeng.skill_no);
                int thurt = BattleUtils.battle(attFightObject.fashang + attFightObject.fashang_ext, showhurt, fightObject.fangyu + fightObject.fangyu_ext);
                hurt = thurt;
            } else {
                hurt = (int)((double)hurt * 0.9D);
            }

            showhurt = fightObject.reduceShengming(hurt, fabao, true);
            that.xueliang = hurt;
            FightResult fightResult = new FightResult();
            fightResult.id = fightRequest.id;
            fightResult.vid = fightObject.fid;
            fightResult.point = -showhurt;
            fightResult.effect_no = 0;
            fightResult.damage_type = 4;
            resultList.add(fightResult);
        }

        return resultList;
    }

    protected void doRoundSkill() {
        this.xueliang /= 2;
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = this.fightContainer.round;
        vo_19959_0.aid = this.buffObject.fid;
        vo_19959_0.action = 0;
        vo_19959_0.vid = this.buffObject.fid;
        vo_19959_0.para = 0;
        FightManager.send(this.fightContainer, new MSG_C_ACTION(), vo_19959_0);
        vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = this.fightContainer.round;
        vo_19959_0.aid = this.buffObject.fid;
        vo_19959_0.action = 0;
        vo_19959_0.vid = this.buffObject.fid;
        vo_19959_0.para = 0;
        FightManager.send(this.fightContainer, new MSG_C_ACTION(), vo_19959_0);
        this.xueliang = this.buffObject.reduceShengming(this.xueliang, false, true);
        if (this.buffObject.type == 1 || this.buffObject.type == 2) {
            this.buffObject.update(this.fightContainer);
        }

        vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = this.fightContainer.round;
        vo_19959_0.aid = 0;
        vo_19959_0.action = 0;
        vo_19959_0.vid = 0;
        vo_19959_0.para = 0;
        FightManager.send(this.fightContainer, new MSG_C_ACTION(), vo_19959_0);
        Vo_7655_0 vo_7655_0 = new Vo_7655_0();
        vo_7655_0.id = 0;
        FightManager.send(this.fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
        FightResult fightResult = new FightResult();
        fightResult.id = this.buffObject.fid;
        fightResult.vid = this.buffObject.fid;
        fightResult.point = -this.xueliang;
        fightResult.effect_no = 0;
        fightResult.damage_type = 4;
        FightManager.send_LIFE_DELTA(this.fightContainer, fightResult);
        vo_7655_0 = new Vo_7655_0();
        vo_7655_0.id = this.buffObject.fid;
        FightManager.send(this.fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
        vo_7655_0 = new Vo_7655_0();
        vo_7655_0.id = this.buffObject.fid;
        FightManager.send(this.fightContainer, new MSG_C_END_ACTION(), vo_7655_0);
    }

    protected void doDisappear() {
    }

    public int getStateType() {
        return 3842;
    }
}
