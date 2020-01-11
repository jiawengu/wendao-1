package org.linlinjava.litemall.gameserver.data.xls_config.superboss;

import com.alibaba.fastjson.JSONObject;
import com.fasterxml.jackson.annotation.JsonValue;

import java.util.*;

public class SuperBossItem {
    public Integer id;
    public String name;
    public Integer icon;
    //分身数量
    public Integer count;
    public List<SuperBossReward> rewards;
    //经验#500,道行#500,装备#蓝色:200,物品#[风寂云清'枯月流魂'雷极弧光'凝香幻彩'炫影霜星'冰落残阳]:200
    public void setRewards(String rewards) {
        this.rewards = new ArrayList<>();
        for(String str: rewards.split("\\|")){
            String [] rs = str.split("#");
            this.rewards.add(new SuperBossReward(rs[0],rs[1]));
        }
    }

    public void setId(Integer id) {
        this.id = id;
    }

    public void setName(String name) {
        this.name = name;
    }

    public void setIcon(Integer icon) {
        this.icon = icon;
    }

    public void setCount(Integer count) {
        this.count = count;
    }

    public Integer getId() {
        return id;
    }

    public String getName() {
        return name;
    }

    public Integer getCount() {
        return count;
    }

    public Integer getIcon() {
        return icon;
    }
    @Override
    public String toString() {
        return JSONObject.toJSONString(this);
    }
}
