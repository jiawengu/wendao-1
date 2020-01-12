package org.linlinjava.litemall.gameserver.game;

import org.linlinjava.litemall.db.domain.Party;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.GameParty;
import org.linlinjava.litemall.gameserver.domain.PartyRequest;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicReference;

public class PartyMgr {
    public static final String OFFICE_MONSTER = "帮主";
    public static final  String OFFICE_NORMAL = "帮众";


    private HashMap<Integer, GameParty> map = new HashMap<>();
    private boolean inited = false;
    private AtomicBoolean lock = new AtomicBoolean(false);
    public boolean lock() {
        return this.lock.compareAndSet(false, true);
    }
    public void unlock() {
        this.lock.set(false);
    }

    public void init(){
//        this.map = new HashMap<>();
//        Party a7913 = GameData.that.basePartyService.findById(7913);
//        List<Party> list = GameData.that.basePartyService.getAll();
//        list.forEach(item->{
//            this.map.put(item.getId(), new GameParty().init(item, null));
//        });
//        this.inited = true;
    }

    public List<GameParty> getAll(){
        List<GameParty> l = new ArrayList<>();
        this.lock();
        this.map.forEach((id, item)->{
            l.add(item);
        });
        this.unlock();
        return l;
    }

    public GameParty get(Integer id) {
        return this.map.get(id);
    }

    public GameParty checkExist(String name){
        GameParty exist = null;
        this.lock();
        for(GameParty item : this.map.values()){
            if(item.data.getName().compareTo(name) == 0){
                exist = item;
                break;
            }
        }
        this.unlock();
        return exist;
    }

    public GameParty newParty(String name, Chara c){
        Party data = new Party();
        data.setId(this.randomId());
        data.setName(name);
        data.setAnnounce("");
        data.setConstruction(0);
        data.setLevel(1);
        data.setCreator(c.name);
        GameData.that.basePartyService.insert(data);

        GameParty p = new GameParty();
        p.init(data, c);
        this.lock();
        this.map.put(p.id, p);
        this.unlock();
        return p;
    }

    //ID一定要10位字符
    private int randomId(){
        while(true){
            int id =(int) (Math.floor(Math.random() * 999999999) + 1000000000);
            if(this.map.get(id) == null){
                return id;
            }
        }
    }
    public static String makeIdStr(int id){
        return "xxxx" + id;
    }

    public static int parseStrId(String str){
        return Integer.valueOf(str.substring(4, str.length() - 1));
    }


    public void checkDirty(){
        if(!this.inited){
            return;
        }
        List<GameParty> list = new ArrayList<>();
        this.lock();
        this.map.forEach((id, item)->{
            list.add(item);
        });
        this.unlock();
        list.forEach(item->{
            item.saveDirty();
        });
    }
}
