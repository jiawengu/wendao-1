package org.linlinjava.litemall.gameserver.data.xls_config;

import java.awt.*;
import java.util.ArrayList;
import java.util.HashMap;

public class PartyShopCfg extends ArrayList<PartyShopItem> {
    public HashMap<String, PartyShopItem> nameMap = new HashMap<>();
    public void init(){
        this.forEach(item->{
            nameMap.put(item.name, item);
        });
    }

    public PartyShopItem getByName(String name){
        return nameMap.get(name);
    }
}
