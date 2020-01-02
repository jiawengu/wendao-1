package org.linlinjava.litemall.gameserver.domain;

import org.linlinjava.litemall.core.util.JSONUtils;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameData;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

public class GameParty {
    public Party data;
    public int id;
    public boolean dirty = false;
    public HashMap<Integer, PartyMember> members;

    public GameParty(){
    }

    class PartyMembers{
        public List<PartyMember> members;
    }

    public GameParty init(Party p, Chara c){
        this.data = p;
        this.id = p.getId();
        this.members = new HashMap<>();
        PartyMembers ms = JSONUtils.parseObject(this.data.getMember(), PartyMembers.class);
        ms.members.forEach(m->{
            this.members.put(m.id, m);
        });

        if(c != null){
            this.data.setCreator(c.name);
        }
        this.dirty = true;
        return this;
    }

    public void saveDirty(){
        List<PartyMember> list = new ArrayList<>();
        this.members.forEach((id, m)->{
            list.add(m);
        });
        String memstr = JSONUtils.toJSONString(list);
        this.data.setMember(memstr);
        GameData.that.basePartyService.updateById(this.data);
        this.dirty = false;
    }

    public void addMember(Chara c){
        if(this.members.get(c.id) != null){
            return;
        }
        this.dirty = true;
        PartyMember m = new PartyMember(c);
        this.members.put(c.id, m);
    }
}
