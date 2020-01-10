package org.linlinjava.litemall.gameserver.data.xls_config;

import java.util.ArrayList;
import java.util.HashMap;

public class PartyDailyTaskCfg extends ArrayList<PartyDailyTaskItem> {
    private HashMap<Integer, PartyDailyTaskItem> idMap = new HashMap<Integer, PartyDailyTaskItem>();
    private HashMap<Integer, ArrayList<PartyDailyTaskItem>> groupMap = new HashMap<Integer, ArrayList<PartyDailyTaskItem>>();
    private int group_count = 0;
    public void init(){
        this.forEach(item->{
            idMap.put(item.id, item);
            ArrayList<PartyDailyTaskItem> list = groupMap.get(item.group);
            if(list == null){
                list = new ArrayList<>();
                groupMap.put(item.group, list);
                group_count ++;
            }
            list.add(item);
        });

        this.groupMap.forEach((id, list)->{
            list.sort((a, b)->{
                return a.id < b.id ? -1 : 1;
            });
            for(int i = 0; i < list.size() - 1; i ++){
                list.get(i).next = list.get(i+1).id;
            }
        });
    }

    public PartyDailyTaskItem getById(int id){
        return idMap.get(id);
    }

    public ArrayList<PartyDailyTaskItem> randomGroup(){
        //if(true){ return groupMap.get(4); }
        int group = (int)Math.floor(Math.random() * group_count) + 1;
        if(group > group_count){
            group = group_count;
        }
        return groupMap.get(group);
    }
}
