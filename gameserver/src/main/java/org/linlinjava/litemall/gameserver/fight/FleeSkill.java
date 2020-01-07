//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.List;
import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_8711_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_FLEE;
import org.linlinjava.litemall.gameserver.domain.JiNeng;

/**
 * 逃离
 */
public class FleeSkill implements FightSkill {
    public FleeSkill() {
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        List<FightResult> resultList = new ArrayList();
        int id = fightRequest.id;
        FightObject fightObject = FightManager.getFightObject(id);
        FightObject fightObjectPet = FightManager.getFightObjectPet(fightContainer, fightObject);
        fightObject.run = true;
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = fightRequest.action;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        MSG_C_FLEE msg = new MSG_C_FLEE();
        Vo_8711_0 vo_8711_0 = new Vo_8711_0();
        vo_8711_0.id = id;
        vo_8711_0.success = 1;
        vo_8711_0.die = 0;
        FightManager.send(fightContainer, msg, vo_8711_0);
        if (fightObjectPet != null) {
            fightObjectPet.state = 3;
            msg = new MSG_C_FLEE();
            vo_8711_0 = new Vo_8711_0();
            vo_8711_0.id = fightObjectPet.id;
            vo_8711_0.success = 1;
            vo_8711_0.die = 0;
            FightManager.send(fightContainer, msg, vo_8711_0);
        }

        return resultList;
    }

    public int getStateType() {
        return 0;
    }
}
