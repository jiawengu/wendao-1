//
// Source code recreated from a .class file by IntelliJ IDEA
// (powered by Fernflower decompiler)
//

package org.linlinjava.litemall.gameserver.fight;

import java.util.ArrayList;
import java.util.List;

import org.linlinjava.litemall.gameserver.data.vo.Vo_19959_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_64971_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_65017_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_7653_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ACTION;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_SET_FIGHT_PET;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_REFRESH_PET_LIST;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ADD_OPPONENT;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_ADD_FRIEND;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
import org.linlinjava.litemall.gameserver.data.write.MSG_C_QUIT_COMBAT;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.JiNeng;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.GameUtil;

/**
 * 招出宠物
 */
public class ZhaoChuSkill implements FightSkill {
    public ZhaoChuSkill() {
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = fightRequest.action;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
        FightObject charObject = FightManager.getFightObject(fightContainer, fightRequest.id);
        FightObject fightObjectPet = FightManager.getFightObjectPet(fightContainer, charObject);
        if (fightObjectPet != null) {
            Vo_7653_0 vo_7653_0 = new Vo_7653_0();
            vo_7653_0.id = fightObjectPet.fid;
            FightManager.send(fightContainer, new MSG_C_QUIT_COMBAT(), vo_7653_0);
            FightManager.remove(fightContainer, fightObjectPet);
            Vo_64971_0 vo_64971_0 = new Vo_64971_0();
            vo_64971_0.count = 1;
            vo_64971_0.id = fightObjectPet.id;
            vo_64971_0.haveCalled = 0;
            GameObjectCharMng.getGameObjectChar(fightObjectPet.cid).sendOne(new MSG_C_REFRESH_PET_LIST(), vo_64971_0);
            vo_64971_0 = new Vo_64971_0();
            vo_64971_0.id = fightObjectPet.id;
            vo_64971_0.haveCalled = 0;
            FightManager.send(fightContainer, new MSG_C_SET_FIGHT_PET(), vo_64971_0);
        }

        Chara chara = GameObjectCharMng.getGameObjectChar(fightRequest.id).chara;
        FightTeam friendsFightTeam = FightManager.getFightTeam(fightContainer, fightRequest.id);
        FightTeam opponentsFightTeam = FightManager.getFightTeamDM(fightContainer, fightRequest.id);
        List<Petbeibao> pets = GameObjectCharMng.getGameObjectChar(fightRequest.id).chara.pets;
        FightObject fightObject = null;
        Petbeibao petbeibaoChuzhan = null;

        for(int j = 0; j < pets.size(); ++j) {
            Petbeibao petbeibao = (Petbeibao)pets.get(j);
            if (petbeibao.id == fightRequest.vid) {
                chara.chongwuchanzhanId = fightRequest.vid;
                fightObject = new FightObject(petbeibao);
                fightObject.pos = charObject.pos + 5;
                fightObject.fid = petbeibao.id;
                fightObject.id = petbeibao.id;
                fightObject.cid = chara.id;
                petbeibaoChuzhan = petbeibao;

                friendsFightTeam.add(fightObject);
                break;
            }
        }

        if (fightObject == null) {
            return null;
        } else {
            List<Vo_65017_0> list65017 = new ArrayList();
            list65017.add(GameUtil.vo_65017_0(fightObject));
            FightManager.sendTeam(fightContainer, friendsFightTeam.fightObjectList, new MSG_C_ADD_FRIEND(), list65017);
            FightManager.sendTeam(fightContainer, opponentsFightTeam.fightObjectList, new MSG_C_ADD_OPPONENT(), list65017);
            Vo_64971_0 vo_64971_0 = new Vo_64971_0();
            vo_64971_0.count = 1;
            vo_64971_0.id = fightObject.id;
            vo_64971_0.haveCalled = 1;
            GameObjectCharMng.getGameObjectChar(fightObject.cid).sendOne(new MSG_C_REFRESH_PET_LIST(), vo_64971_0);
            List list = new ArrayList();
            list.add(petbeibaoChuzhan);
            GameObjectCharMng.getGameObjectChar(fightObject.cid).sendOne(new MSG_UPDATE_PETS(), list);
            vo_64971_0 = new Vo_64971_0();
            vo_64971_0.id = fightObject.id;
            vo_64971_0.haveCalled = 1;
            GameObjectCharMng.getGameObjectChar(fightObject.cid).sendOne(new MSG_C_SET_FIGHT_PET(), vo_64971_0);
            return null;
        }
    }

    public int getStateType() {
        return 0;
    }
}
