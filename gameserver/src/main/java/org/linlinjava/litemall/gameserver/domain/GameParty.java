package org.linlinjava.litemall.gameserver.domain;

import com.alibaba.druid.sql.visitor.functions.Char;
import org.linlinjava.litemall.core.util.JSONUtils;
import org.linlinjava.litemall.db.domain.Characters;
import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.gameserver.game.GameCore;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.PartyMgr;
import org.springframework.objenesis.instantiator.util.ClassDefinitionUtils;

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class GameParty {
    public Party data;
    public int id;
    public boolean dirty = false;
    public HashMap<Integer, PartyMember> members = new HashMap<>();
    private HashMap<Integer, PartyRequest> requestList = new HashMap<>();
    private AtomicBoolean lock = new AtomicBoolean(false);
    public PartyOfficers officers;
    public boolean lock() {
        return this.lock.compareAndSet(false, true);
    }
    public void unlock() {
        this.lock.set(false);
    }

    public GameParty(){
    }

    public GameParty init(Party p, Chara creator){
        this.lock();
        this.data = p;
        this.id = p.getId();
        if(p.getOfficer() != null){
            officers = JSONUtils.parseObject(p.getOfficer(), PartyOfficers.class);
        }else{
            officers = new PartyOfficers();
        }
        String memstr = p.getMember();
        if(memstr != null && memstr != ""){
            List<Object> list = (List<Object>)JSONUtils.parseObject(memstr, Object.class);
            assert list != null;
            list.forEach(obj->{
                HashMap<String, Object> map = (HashMap<String, Object>)obj;
                PartyMember m = new PartyMember();
                for(Field f : m.getClass().getDeclaredFields()){
                    try {
                        f.set(m, map.get(f.getName()));
                    } catch (IllegalAccessException e) {
                        e.printStackTrace();
                    }
                }
                this.members.put(m.id, m);
            });


        }

        if(creator != null){
            this.addMember(creator);
            this.officers.put(PartyMgr.OFFICE_MONSTER, new PartyOfficers.Office(creator.id, creator.name));
            this.data.setCreator(creator.name);
        }
        this.unlock();
        return this;
    }

    public void saveDirty(){
        if(!this.dirty){ return; }
        List<PartyMember> list = new ArrayList<>();
        this.lock();
        this.members.forEach((id, m)->{
            list.add(m);
        });
//        MembersS S = new MembersS();
//        S.members = list;
        String memstr = JSONUtils.toJSONString(list);
        this.data.setMember(memstr);
        this.data.setOfficer(JSONUtils.toJSONString(this.officers));
        GameData.that.basePartyService.updateById(this.data);
        this.dirty = false;
        this.unlock();
    }

    public void addMember(Chara c){
        this.lock();
        if(this.members.get(c.id) != null){
            this.unlock();
            return;
        }
        this.dirty = true;
        PartyMember m = new PartyMember();
        m.id = c.id;
        this.members.put(c.id, m);
        this.unlock();
    }

    public List<PartyMember> listMembers(){
        List<PartyMember> list = new ArrayList<>();
        this.lock();
        this.members.forEach((id, m)->{
            list.add(m);
        });
        this.unlock();
        return list;
    }

    public PartyMember getMemberByName(String name){
        return null;
    }

    public void requestJoin(Chara c){
        PartyRequest req = new PartyRequest();
        req.id = c.id;
        this.requestList.put(req.id, req);
        this.addMember(c);
        c.partyId = this.id;
        c.partyName = this.data.getName();
    }

    public List<PartyRequest> getRequestList(){
        List<PartyRequest> list = new ArrayList<>();
        this.requestList.forEach((id, req)->{
            list.add(req);
        });
        return list;
    }

    public int addContrib(int v){
        int constrib = this.data.getConstruction() + v;
        if(constrib < 0){ constrib = 0; }
        this.data.setConstruction(constrib);
        this.dirty = true;
        return constrib;
    }
}
