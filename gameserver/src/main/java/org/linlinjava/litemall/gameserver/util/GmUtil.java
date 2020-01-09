package org.linlinjava.litemall.gameserver.util;

import org.linlinjava.litemall.gameserver.domain.Chara;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

public class GmUtil {
    /**
     * 是否打开GM指令 //TODO
     */
    private static final boolean IS_GM = true;
    private static final String GM_PREFIX = "#gm ";
    public final Map<String, Handler> handlers;

    private static final GmUtil instance = new GmUtil();
    private GmUtil(){
        Map<String, Handler> result = new HashMap<>();
        //注册处理器
        {
            result.put("ljy", this::ljy_handler);
        }
        handlers = Collections.unmodifiableMap(result);
    }

    public static GmUtil getInstance(){
        return instance;
    }
    public static boolean process(Chara chara, String cmd){
        if(!IS_GM){
            return false;
        }
        if(!cmd.startsWith(GM_PREFIX)){
            return false;
        }
        cmd = cmd.substring(GM_PREFIX.length());
        String[] cmdArray = cmd.split(" ");
        GmUtil gmUtil = getInstance();
        String command = cmdArray[0];
        if(gmUtil.handlers.containsKey(command)){
            gmUtil.handlers.get(command).handle(chara, cmdArray);
        }else{
            System.out.println("gm指令不正确:"+cmd);
        }
        return true;
    }

    private interface Handler{
        void handle(Chara chara, String[] cmds);
    }

    public void ljy_handler(Chara chara, String[] cmds){

    }
}