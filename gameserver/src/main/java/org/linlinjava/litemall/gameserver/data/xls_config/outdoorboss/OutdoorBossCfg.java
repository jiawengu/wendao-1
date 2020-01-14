package org.linlinjava.litemall.gameserver.data.xls_config.outdoorboss;

import org.linlinjava.litemall.gameserver.data.xls_config.BaseCfg;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossItem;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossMap;
import org.linlinjava.litemall.gameserver.game.XLSConfigMgr;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 野外BOSS 的配置文件
 */
@Component
public class OutdoorBossCfg extends BaseCfg {
    public String resetTime;
    public int upperLimit;
    public int lowerLimit;

    public List<SuperBossMap> maps;
    public List<OutdoorBossItem> bossList;
    public Map<Integer, OutdoorBossItem> bossMap;

    public void setResetTime(String resetTime) {
        this.resetTime = resetTime;
    }

    public void setLowerLimit(int lowerLimit) {
        this.lowerLimit = lowerLimit;
    }

    public void setUpperLimit(int upperLimit) {
        this.upperLimit = upperLimit;
    }

    public OutdoorBossItem getBossByid(int id){
        return this.bossMap.get(id);
    }
    public SuperBossMap getMapByname(String name){
        if(maps != null){
            for(SuperBossMap map: maps){
                if(map.name.equals(name)){
                    return map;
                }
            }
        }
        return null;
    }

    @Override
    public void startupLoad() {
        OutdoorBossCfg cfg = loadJson("OutdoorBossCfg", OutdoorBossCfg.class).get(0);
        this.resetTime = cfg.resetTime;
        this.lowerLimit = cfg.lowerLimit;
        this.upperLimit = cfg.upperLimit;
    }

    @Override
    public void afterStartup() {
        this.maps = loadJson("OutdoorBossMap", SuperBossMap.class);
        this.bossList = loadJson("OutdoorBossItem", OutdoorBossItem.class);
        this.bossMap = new HashMap<>();
        for(OutdoorBossItem item: this.bossList){
            this.bossMap.put(item.id, item);
        }
    }
}
