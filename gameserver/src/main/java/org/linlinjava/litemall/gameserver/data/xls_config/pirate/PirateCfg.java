package org.linlinjava.litemall.gameserver.data.xls_config.pirate;

import org.linlinjava.litemall.gameserver.data.xls_config.BaseCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossMap;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class PirateCfg extends BaseCfg {

    public String startTime;
    /** 小时*/
    public Integer duration;
    public List<PirateItem> pirateList;
    public Map<String, PirateItem> pirateMap;
    public List<SuperBossMap> mapList;

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public void setDuration(Integer duration) {
        this.duration = duration;
    }

    @Override
    public void startupLoad() {
        PirateCfg cfg = loadJson("PirateCfg", PirateCfg.class).get(0);
        this.startTime = cfg.startTime;
        this.duration = cfg.duration;
    }

    @Override
    public void afterStartup() {
        this.mapList = loadJson("PirateMap", SuperBossMap.class);
        this.pirateList = loadJson("PirateItem", PirateItem.class);
        this.pirateMap = new HashMap<>();
        for(PirateItem item: this.pirateList){
            this.pirateMap.put(item.name, item);
        }
    }
}
