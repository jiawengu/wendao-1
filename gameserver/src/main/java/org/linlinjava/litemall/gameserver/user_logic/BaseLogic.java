package org.linlinjava.litemall.gameserver.user_logic;

import org.linlinjava.litemall.gameserver.game.GameObjectChar;

public class BaseLogic {
    public int id = 0;
    private boolean save_flag = false;
    public boolean is_inited = false;
    public void save(){
        save_flag = true;
    }

    protected UserLogic userLogic;
    protected GameObjectChar obj;
    public void init(int id, UserLogic lg, GameObjectChar obj){
        this.id = id;
        this.userLogic = lg;
        this.obj = obj;
        this.onInit();
        this.is_inited = true;
    }

    public void cacheSave(){
        if(this.save_flag){
            this.onSave();
            this.save_flag = false;
        }
    }

    public void dayChange(){ this.onDayChange(); }

    protected void onSave(){}
    protected void onInit(){}
    protected void onDayChange(){}


}
