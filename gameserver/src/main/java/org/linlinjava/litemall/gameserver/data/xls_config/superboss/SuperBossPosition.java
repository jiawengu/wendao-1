package org.linlinjava.litemall.gameserver.data.xls_config.superboss;

import com.alibaba.fastjson.JSONObject;

public class SuperBossPosition {
    public Integer x;
    public Integer y;

    SuperBossPosition(int x, int y){
        this.x = x;
        this.y = y;
    }

    public Integer getX() {
        return x;
    }

    public Integer getY() {
        return y;
    }

    @Override
    public String toString() {
        return JSONObject.toJSONString(this);
    }
}
