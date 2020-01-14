package org.linlinjava.litemall.gameserver.user_logic;

import java.util.HashMap;

public class UserLogic extends BaseLogic {
    private HashMap<String, BaseLogic> modMap = new HashMap<>();


    public void registerMod(String name, BaseLogic mod){
        modMap.put(name, mod);
    }

    public BaseLogic getMod(String name){
        BaseLogic mod = modMap.get(name);
        if(mod == null){ return null; }
        if(!mod.is_inited){
            mod.init(this.id, this, this.obj);
            mod.is_inited = true;
        }
        return mod;
    }


    @Override
    protected void onInit() {
        super.onInit();

        this.registerMod("party", new UserPartyLogic());
        this.registerMod("party_daily_task", new UserPartyDailyTaskLogic());
    }

    @Override
    public void cacheSave() {
        super.cacheSave();
        this.modMap.forEach((n, mod)->{
            try{
                mod.cacheSave();
            }catch (Exception e){
                e.printStackTrace();
            }
        });
    }

    @Override
    public void dayChange() {
        super.dayChange();
        this.modMap.forEach((n, mod)->{
            try{
                mod.dayChange();
            }catch (Exception e){
                e.printStackTrace();
            }
        });
    }
}
