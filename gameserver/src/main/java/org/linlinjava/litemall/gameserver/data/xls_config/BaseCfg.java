package org.linlinjava.litemall.gameserver.data.xls_config;

import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;
import org.linlinjava.litemall.gameserver.game.XLSConfigMgr;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.ResourceLoader;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;
import java.util.ArrayList;
import java.util.List;

@Order(value = 1)
public abstract class BaseCfg implements ApplicationRunner {

    protected static ResourceLoader resourceLoader = new DefaultResourceLoader();
    protected static final Logger log = LoggerFactory.getLogger(BaseCfg.class);

    @Override
    public void run(ApplicationArguments args) throws Exception {
        afterStartup();
    }

    /**
     * 用于运行时加载文件
     */
    public void load() {
        startupLoad();
        afterStartup();
    }

    @PostConstruct
    public abstract void startupLoad();

    public abstract void afterStartup();

    public static <T> List<T> loadJson(String name, Class<T> t)  {
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

    @Override
    public String toString() {
        return JSONObject.toJSONString(this);
    }
}
