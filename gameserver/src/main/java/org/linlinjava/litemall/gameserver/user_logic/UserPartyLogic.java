package org.linlinjava.litemall.gameserver.user_logic;

import org.linlinjava.litemall.db.domain.UserParty;
import org.linlinjava.litemall.db.service.base.BaseUserPartyService;
import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.PartyMgr;
import org.springframework.cache.annotation.Cacheable;

import java.util.Date;

public class UserPartyLogic extends BaseLogic {
    public UserParty data;
    public GameParty party;

    @Override
    protected void onInit() {
        super.onInit();

        BaseUserPartyService s = GameData.that.baseUserPartyService;
        data = s.findById(this.id);
        if(data == null){
            data = new UserParty();
            data.setId(id);
            s.insert(data);
        }

        if(this.data.getPartyid() > 0){
            this.party = PartyMgr.that.get(this.data.getPartyid());
            if(this.party == null){
                this.data.setPartyid(0);
                this.data.setPartyname("");
                this.save();
            }
        }
    }

    @Override
    protected void onSave() {
        super.onSave();
        GameData.that.baseUserPartyService.updateById(this.data);
    }

    public boolean hasParty(){
        return data.getPartyid() > 0;
    }

    public void joinParty(int partyId, String partyName){
        data.setPartyid(partyId);
        data.setPartyname(partyName);
        data.setActive(0);
        data.setContrib(0);
        data.setJointime(new Date());
        data.setThisweekactive(0);
        data.setLastweekactive(0);
        this.save();

        this.party = PartyMgr.that.get(partyId);
    }

    public int addContrib(int v){
        if(this.party == null){ return 0; }
        int cur = this.data.getContrib();
        cur += v;
        if(cur < 0){ cur = 0; };
        this.data.setContrib(cur);
        this.notifyShowRewardMsg("获得帮贡#R" + v);
        this.save();
        this.party.addContrib(v);
        return cur;
    }

    private void notifyShowRewardMsg(String msg){
        Vo_20481_0 vo_20481_0 = new Vo_20481_0();
        vo_20481_0.msg = msg;
        vo_20481_0.time = ((int) (System.currentTimeMillis() / 1000L));
        GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
    }
}
