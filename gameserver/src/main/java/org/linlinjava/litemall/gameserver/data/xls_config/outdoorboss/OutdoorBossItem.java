package org.linlinjava.litemall.gameserver.data.xls_config.outdoorboss;

import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossItem;
import org.linlinjava.litemall.gameserver.data.xls_config.superboss.SuperBossMap;
import org.linlinjava.litemall.gameserver.game.BaseBossMng;
import org.linlinjava.litemall.gameserver.game.GameData;

import java.util.ArrayList;
import java.util.List;

public class OutdoorBossItem extends SuperBossItem {

    public List<SuperBossMap> maps;
    public int level;

    public void setLevel(int level) {
        this.level = level;
    }

    public void setMaps(String maps) {
        this.maps = new ArrayList<>();
        for(String name: maps.split(",")){
            SuperBossMap map = GameData.that.outdoorBossCfg.getMapByname(name);
            if(map != null){
                this.maps.add(map);
            }
        }
    }

    public SuperBossMap getRandomMap(){
        return this.maps.get(BaseBossMng.RANDOM.nextInt(this.maps.size()));
    }
}
