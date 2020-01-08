package org.linlinjava.litemall.gameserver.game;

import net.sf.json.JSON;
import org.linlinjava.litemall.core.util.JSONUtils;
import org.linlinjava.litemall.gameserver.data.game.PetAndHelpSkillUtils;
import org.linlinjava.litemall.gameserver.data.xls_config.PartyShopCfg;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.core.io.DefaultResourceLoader;
import org.springframework.core.io.Resource;
import org.springframework.core.io.ResourceLoader;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.List;

public class XLSConfigMgr {
    private static HashMap<String, Object> caches = new HashMap<>();
    private static ResourceLoader resourceLoader = new DefaultResourceLoader();
    private static final Logger log = LoggerFactory.getLogger(XLSConfigMgr.class);

    public static void loadXls(String name, Class T){
        Resource resource = resourceLoader.getResource("classpath:xls_config/" + name + ".json");
        BufferedReader br = null;
        try {
            InputStream inputStream = resource.getInputStream();
            InputStreamReader fr = new InputStreamReader(inputStream);
            br = new BufferedReader(fr);
        } catch (IOException var4) {
            log.error("", var4);
            return;
        }
        StringBuilder sb = new StringBuilder();
        br.lines().forEach((f) -> {
            sb.append(f);
        });
        Object obj = JSONUtils.parseObject(sb.toString(), T);
        assert (obj != null);
        Method initfn = null;
        try {
            initfn = T.getMethod("init", null);
            if(initfn != null){
                initfn.invoke(obj);
            }
        } catch (Exception e){
            e.printStackTrace();
        }
        caches.put(name, obj);
    }

    public static void init(){
        loadXls("party_shop", PartyShopCfg.class);
    }

    public static Object getCfg(String name){
        return caches.get(name);
    }


}
