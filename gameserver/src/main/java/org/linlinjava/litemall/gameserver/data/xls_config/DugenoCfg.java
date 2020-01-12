package org.linlinjava.litemall.gameserver.data.xls_config;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.List;

public class DugenoCfg extends ArrayList<DugenoItem> {
    public HashMap<String, DugenoItem> nameMap = new HashMap<>();
    public void init(){
        this.forEach(item->{
            item.init();
            nameMap.put(item.name, item);
        });
    }

    public DugenoItem getByName(String name){
        return nameMap.get(name);
    }

    public DugenoItem getByMapName(String name){
        for (DugenoItem item: nameMap.values()) {
            if(item.map_name.equals(name)){
                return item;
            }
        }
        return null;
    }
}