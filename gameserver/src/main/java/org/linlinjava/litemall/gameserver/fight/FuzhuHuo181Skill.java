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
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.JiNeng;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.GameUtil;

/**
 * 辅助火-提高速度
 */
public class FuzhuHuo181Skill extends FightRoundSkill {
    public FuzhuHuo181Skill() {
    }

    public FuzhuHuo181Skill(FightObject buffObject, int skillRound, FightContainer fightContainer) {
        super(buffObject, fightContainer.round + skillRound - 1, fightContainer);
    }

    public List<FightResult> doSkill(FightContainer fightContainer, FightRequest fightRequest, JiNeng jiNeng) {
        new ArrayList();
        int victim_id = fightRequest.vid;
        Vo_19959_0 vo_19959_0 = new Vo_19959_0();
        vo_19959_0.round = fightContainer.round;
        vo_19959_0.aid = fightRequest.id;
        vo_19959_0.action = fightRequest.action;
        vo_19959_0.vid = fightRequest.vid;
        vo_19959_0.para = fightRequest.para;
        FightManager.send(fightContainer, new MSG_C_ACTION(), vo_19959_0);
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
        List<FightObject> targetList = FightManager.findTarget(fightContainer, fightRequest, 2, jiNeng.range);
        Iterator var10 = targetList.iterator();

        FightObject fightObject;
        while(var10.hasNext()) {
            fightObject = (FightObject)var10.next();
            vo_64989_0.list.add(fightObject.fid);
        }

        FightManager.send(fightContainer, new MSG_C_ACCEPT_MAGIC_HIT(), vo_64989_0);

        FuzhuHuo181Skill that;
        int speed;
        for(var10 = targetList.iterator(); var10.hasNext(); ) {
            fightObject = (FightObject)var10.next();
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
            that = new FuzhuHuo181Skill(fightObject, jiNeng.skillRound, fightContainer);
            fightObject.addSkill(that);
            speed = (int)BattleUtils.extAdd(jiNeng.skill_level, jiNeng.skill_no);
            that.buffObject.parry_ext = that.buffObject.parry * speed / 100;

            if(that.buffObject.isPlayer()){
                GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(that.buffObject.fid);
                if(null!=gameObjectChar){
                    gameObjectChar.sendOne(new MSG_UPDATE(), GameUtil.MSG_UPDATE(gameObjectChar.chara));
//                    System.out.println(that.buffObject.str+":辅助水 enter!"+"accurate_ext:"+that.buffObject.accurate_ext+",fashang_ext："+that.buffObject.fashang_ext);
                }
            }
        }

        return null;
    }

    protected void doRoundSkill() {
    }

    protected void doDisappear() {
        this.buffObject.parry_ext = 0;
        if(this.buffObject.isPlayer()){
            GameObjectChar gameObjectChar = GameObjectCharMng.getGameObjectChar(this.buffObject.fid);
            if(null!=gameObjectChar){
                gameObjectChar.sendOne(new MSG_UPDATE(), GameUtil.MSG_UPDATE(gameObjectChar.chara));
//                System.out.println(this.buffObject.str+":辅助金 exit");
            }
        }
    }

    public int getStateType() {
        return 12032;
    }
}
