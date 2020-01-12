package org.linlinjava.litemall.gameserver.user_logic;

import org.linlinjava.litemall.db.domain.UserParty;
import org.linlinjava.litemall.db.service.base.BaseUserPartyService;
import org.linlinjava.litemall.gameserver.game.GameData;

import java.util.Date;

public class UserPartyLogic extends BaseLogic {
    public UserParty data;
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
    }

    public int addContrib(int v){
        int cur = this.data.getContrib();
        cur += v;
        if(cur < 0){ cur = 0; };
        this.data.setContrib(cur);
        this.save();
        return cur;
    }
}
