package org.linlinjava.litemall.gameserver.data.xls_config.superboss;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.linlinjava.litemall.gameserver.data.xls_config.BaseCfg;
import org.linlinjava.litemall.gameserver.game.XLSConfigMgr;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class SuperBossCfg extends BaseCfg {

    /**
     * BOSS 出现的时间周期：
     * h 小时
     * d 天 凌晨7点出现，晚上0点重置，目前写死以后再做进配置
     * w 周
     * m 月
     **/
    public String startTime;
    public String endTime;
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

    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }

    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }

    public void setBossTypeCount(int bossTypeCount) {
        this.bossTypeCount = bossTypeCount;
    }

    @Override
    public void startupLoad(){
        SuperBossCfg cfg = loadJson("SuperBossCfg", SuperBossCfg.class).get(0);
        this.bossCount = cfg.bossCount;
        this.bossTypeCount = cfg.bossTypeCount;
        this.challengeCount = cfg.challengeCount;
        this.startTime = cfg.startTime;
        this.endTime = cfg.endTime;
        this.bosss = loadJson("SuperBossItem", SuperBossItem.class);
    }

    @Override
    public void afterStartup(){
        // 由于有些操作需要调用数据库，所以要在系统启动后加载文件
        this.maps = loadJson("SuperBossMap", SuperBossMap.class);
    }

}