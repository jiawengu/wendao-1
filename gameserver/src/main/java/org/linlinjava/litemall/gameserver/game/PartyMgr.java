package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GameParty;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;

public class PartyMgr {
    private HashMap<Integer, GameParty> map;
    private boolean inited = false;

    public void init(){
        this.map = new HashMap<>();
        GameData.that.basePartyService.getAll().forEach(item->{
            this.map.put(item.getId(), new GameParty().init(item, null));
        });
        this.inited = true;
    }

    public List<GameParty> getAll(){
        List<GameParty> l = new ArrayList<>();
        this.map.forEach((id, item)->{
            l.add(item);
        });
        return l;
    }

    public List<Party> getAllData(){
        List<Party> l = new ArrayList<>();
        this.map.forEach((id, item)->{
            l.add(item.data);
        });
        return l;
    }

    public GameParty get(Integer id) {
        return this.map.get(id);
    }

    public boolean checkExist(String name){
        AtomicBoolean exist = new AtomicBoolean(false);
        this.map.forEach((id, item)->{
            if(item.data.getName().compareTo(name) == 0){
                exist.set(true);
            }
        });
        return exist.get();
    }

    public GameParty newParty(Party data, Chara c){
        if(this.map.get(data.getId()) != null){
            return this.map.get(data.getId());
        }
        data.setId(this.randomId());
        GameData.that.basePartyService.insert(data);
        GameParty p = new GameParty();
        p.init(data, c);
        this.map.put(p.id, p);
        return p;
    }

    private int randomId(){
        while(true){
            int id =(int) (Math.floor(Math.random() * 10000) + 1000);
            if(this.map.get(id) == null){
                return id;
            }
        }
    }

    public void checkDirty(){
        if(!this.inited){
            return;
        }
        this.map.forEach((id, item)->{
            if(item.dirty){
                item.dirty = false;
                GameData.that.basePartyService.updateById(item.data);
            }
        });
    }
}
