package org.linlinjava.litemall.gameserver.data.xls_config.superboss;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
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
    private static ResourceLoader resourceLoader = new DefaultResourceLoader();

    public static class Cfg {
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

        public void setBossCount(int bossCount) {
            this.bossCount = bossCount;
        }

        public void setTimeUnit(String timeUnit) {
            this.timeUnit = timeUnit;
        }

        public void setBossTypeCount(int bossTypeCount) {
            this.bossTypeCount = bossTypeCount;
        }
    }
    public List<SuperBossItem> bosss;
    public List<SuperBossMap> maps;
    public Cfg cfg;

    @Override
    public void run(ApplicationArguments var1) throws Exception {
        load();
    }

    public void load()  throws Exception {
        this.maps = getResObjList("SuperBossMap", SuperBossMap.class);
        this.bosss = getResObjList("SuperBossItem", SuperBossItem.class);
        this.cfg = getResObjList("SuperBossCfg", Cfg.class).get(0);
    }

    public static <T> List<T> getResObjList(String name, Class<T> t)  throws Exception {
        List<T> list = new ArrayList<T>();
        try {
            JSONArray objs = JSONObject.parseObject(resourceLoader.getResource("classpath:xls_config/" + name + ".json").getInputStream(), JSONArray.class);
            for(int i = 0, l = objs.size(); i < l; i++){
                list.add(objs.getObject(i, t));
            }
        }catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}