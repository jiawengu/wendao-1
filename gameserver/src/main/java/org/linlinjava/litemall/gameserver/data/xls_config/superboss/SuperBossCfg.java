package org.linlinjava.litemall.gameserver.data.xls_config.superboss;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.linlinjava.litemall.gameserver.game.XLSConfigMgr;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
@Order(value = 1)
public class SuperBossCfg implements ApplicationRunner {

    /**
     * BOSS 出现的时间周期：
     * h 小时
     * d 天 凌晨7点出现，晚上0点重置，目前写死以后再做进配置
     * w 周
     * m 月
     **/
    public String timeUnit;
    /**BOSS 出现种类的数量*/
    public int bossTypeCount;
    /**每种 BOSS 出现的数量*/
    public int bossCount;
    /**每个boss 可挑战次数*/
    public int challengeCount;

    public List<SuperBossItem> bosss;
    public List<SuperBossMap> maps;

    public void setBossCount(int bossCount) {
        this.bossCount = bossCount;
    }

    public void setTimeUnit(String timeUnit) {
        this.timeUnit = timeUnit;
    }

    public void setBossTypeCount(int bossTypeCount) {
        this.bossTypeCount = bossTypeCount;
    }

    @Override
    public void run(ApplicationArguments var1) throws Exception {
        load();
    }

    public void load() {
        SuperBossCfg cfg = XLSConfigMgr.loadJson("SuperBossCfg", SuperBossCfg.class).get(0);
        this.bossCount = cfg.bossCount;
        this.bossTypeCount = cfg.bossTypeCount;
        this.challengeCount = cfg.challengeCount;
        this.maps = XLSConfigMgr.loadJson("SuperBossMap", SuperBossMap.class);
        this.bosss = XLSConfigMgr.loadJson("SuperBossItem", SuperBossItem.class);
    }

}