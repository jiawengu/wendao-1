package org.linlinjava.litemall.gameserver.data.xls_config.superboss;

import com.alibaba.fastjson.JSONObject;
import org.linlinjava.litemall.gameserver.game.GameData;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;

public class SuperBossMap {
    public static final Random RANDOM = new Random();
    public int id;
    public int mapid;
    public String name;
    public List<SuperBossPosition> positions;

    public void setName(String name) {
        org.linlinjava.litemall.db.domain.Map map = GameData.that.baseMapService.findOneByName(name);
        if(map == null){
            System.out.println(String.format("超级BOSS配置地图【%s】不在数据库", name));
        }
        else {
            this.id = map.getId();
            this.mapid = map.getMapId();
        }
        this.name = name;
    }

    public void setPositions(String positions) {
        this.positions = new ArrayList<SuperBossPosition>();
        for(String poss: Arrays.asList(positions.split("\\|"))){
            String[] pos = poss.split(",");
            this.positions.add(new SuperBossPosition(Integer.valueOf(pos[0]), Integer.valueOf(pos[1])));
        }
    }

    public SuperBossPosition getRandomPosition(){
        return positions.get(SuperBossMap.RANDOM.nextInt(positions.size()));
    }

    public List<SuperBossPosition> getPositions() {
        return positions;
    }

    public String getName() {
        return name;
    }

    public int getId() {
        return id;
    }

    @Override
    public String toString() {
        return JSONObject.toJSONString(this);
    }
}
