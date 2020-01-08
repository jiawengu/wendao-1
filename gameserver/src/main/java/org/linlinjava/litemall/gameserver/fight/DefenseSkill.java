//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.domain.JiNeng;

/**
 * 防御技能
 */
public class DefenseSkill extends FightRoundSkill {
    public DefenseSkill() {
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
        FightObject fightObject = FightManager.getFightObject(fightContainer, fightRequest.id);
        fightObject.addBuffState(fightContainer, this.getStateType());
        fightObject.addSkill(this);
        fightObject.fangyu_ext = fightObject.fangyu / 2;
        this.buffObject = fightObject;
        return resultList;
    }

    protected void doRoundSkill() {
    }

    protected void doDisappear() {
        this.buffObject.fangyu_ext = 0;
    }

    public int getStateType() {
        return 36608;
    }
}
