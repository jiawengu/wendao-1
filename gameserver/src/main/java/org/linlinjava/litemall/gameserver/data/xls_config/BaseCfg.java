package org.linlinjava.litemall.gameserver.data.xls_config;

import com.alibaba.fastjson.JSONObject;
import org.linlinjava.litemall.gameserver.game.XLSConfigMgr;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import javax.annotation.PostConstruct;

@Order(value = 1)
public abstract class BaseCfg implements ApplicationRunner {

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

    @Override
    public String toString() {
        return JSONObject.toJSONString(this);
    }
}
