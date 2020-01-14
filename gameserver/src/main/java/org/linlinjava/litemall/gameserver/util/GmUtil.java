package org.linlinjava.litemall.gameserver.util;

import org.linlinjava.litemall.db.domain.Npc;
import org.linlinjava.litemall.db.domain.StoreInfo;
import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR_NPC;
import org.linlinjava.litemall.gameserver.data.write.MSG_MESSAGE_EX;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.write.MSG_APPEAR_NPC;
import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.GameUtil;

import java.util.Collections;
import java.util.HashMap;
import java.util.Map;

/**
 * gm指令格式:#gm 指令 参数1 参数2 参数3
 */
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
            result.put("goods", this::goods_handler);
            result.put("pos", this::npc_pos);
            result.put("loadbossxls", this::loadbossxls);
            result.put("exp", this::exp_handler);
            result.put("level", this::level_handler);
            result.put("daohang", this::daohang_handler);
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
//        Npc npc = GameData.that.baseNpcService.findOneByName("金系掌门");
//        GameObjectChar.getGameObjectChar().sendOne(new MSG_APPEAR_NPC(), npc);

        int daohang = Integer.parseInt(cmds[1]);
        GameUtil.adddaohang(GameObjectChar.getGameObjectChar().chara, daohang);
        ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
        GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
    }

    /**
     * 加道行：#gm daohang 道行值
     * @param chara
     * @param cmds
     */
    public void daohang_handler(Chara chara, String[] cmds){
        int daohang = Integer.parseInt(cmds[1]);
        GameUtil.adddaohang(GameObjectChar.getGameObjectChar().chara, daohang);
        ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
        GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
    }

    /**
     * 添加物品:#gm goods 物品名字 物品数量
     * @param chara
     * @param cmds
     */
    public void goods_handler(Chara chara, String[] cmds){
        String goodsName = cmds[1];
        int num = cmds.length>=3?Integer.parseInt(cmds[2]):1;
        StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(goodsName);
        if(null==info){
            System.out.println("在StoreInfo里没有找到物品："+goodsName);
        }
        for(int i=0;i<num;++i){
            GameUtil.huodedaoju(chara, info, 1);
        }
    }

    public void npc_pos(Chara chara, String[] cmds){
        Vo_16383_0 vo_16383_0 = GameUtil.a16383(chara, String.format("%s, %s", chara.x, chara.y), 1);
        GameObjectChar.send(new MSG_MESSAGE_EX(), vo_16383_0);
    }

    public void loadbossxls(Chara chara, String[] cmds){
        GameData.that.superBossMng.resetBoss();
        GameData.that.superBossCfg.load();
        GameData.that.superBossMng.productionBoss();
    }
    /**
     * 添加经验:#gm exp 经验数量
     * @param chara
     * @param cmds
     */
    public void exp_handler(Chara chara, String[] cmds){
        int exp = Integer.parseInt(cmds[1]);
        GameUtil.huodejingyan(chara, exp);
    }
    /**
     * 设置等级:#gm level 当前等级
     * @param chara
     * @param cmds
     */
    public void level_handler(Chara chara, String[] cmds){
        int level = Integer.parseInt(cmds[1]);
        chara.level = level;
        ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
    }
}
