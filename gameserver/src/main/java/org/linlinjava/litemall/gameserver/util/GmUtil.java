package org.linlinjava.litemall.gameserver.util;

import org.linlinjava.litemall.db.domain.StoreInfo;
import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
import org.linlinjava.litemall.gameserver.data.write.*;
import org.linlinjava.litemall.gameserver.domain.Chara;
import org.linlinjava.litemall.gameserver.domain.PetShuXing;
import org.linlinjava.litemall.gameserver.domain.Petbeibao;
import org.linlinjava.litemall.gameserver.fight.FightContainer;
import org.linlinjava.litemall.gameserver.fight.FightManager;
import org.linlinjava.litemall.gameserver.game.GameData;
import org.linlinjava.litemall.gameserver.game.GameObjectChar;
import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
import org.linlinjava.litemall.gameserver.process.GameUtil;

import java.util.Arrays;
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
            result.put("qinmidu", this::qinmidu_handler);
            result.put("coin", this::coin_handler);
            result.put("exitbattle", this::exitbattle_handler);
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
//        GameObjectChar.send(new MSG_UPDATE_PETS(), chara.pets);
//        FightContainer fightContainer = FightManager.getFightContainer(chara.id);
//        if(null!=fightContainer){
//            FightManager.doOver(fightContainer);
//            FightManager.nextRoundOrSendOver(fightContainer);
//        }

//        int coin = Integer.parseInt(cmds[1]);
//        chara.gold_coin += coin;
        ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
        GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);

        GameObjectChar.send(new MSG_UPDATE_PETS(), chara.pets);
    }

    /**
     * 加道行：#gm daohang 道行值
     * @param chara
     * @param cmds
     */
    public void daohang_handler(Chara chara, String[] cmds){
        int daohang = Integer.parseInt(cmds[1]);
        GameUtil.adddaohang(GameObjectChar.getGameObjectChar().chara, daohang);
        ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
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
//        GameData.that.outdoorBossCfg.load();
//        GameData.that.outdoorBossMng.productionBoss();
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
        ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
        GameObjectCharMng.getGameObjectChar(chara.id).sendOne(new MSG_UPDATE(), listVo_65527_0);
    }

    /**
     * 设置宠物：#gm qinmidu 宠物名字 亲密度值
     * @param chara
     * @param cmds
     */
    private void qinmidu_handler(Chara chara, String[] cmds){
        String petName = cmds[1];
        int qinmidu = Integer.parseInt(cmds[2]);
        for(Petbeibao petbeibao:chara.pets){
            PetShuXing petShuXing = petbeibao.petShuXing.get(0);
            if(petShuXing.str.equals(petName)){
                petShuXing.intimacy = qinmidu;

                GameObjectChar.send(new MSG_UPDATE_PETS(), Arrays.asList(petbeibao));
                break;
            }
        }
    }

    /**
     * 添加银元宝：#gm coin 添加的银元宝数值
     * @param chara
     * @param cmds
     */
    public void coin_handler(Chara chara, String[] cmds){
        int coin = Integer.parseInt(cmds[1]);
        chara.gold_coin += coin;
        ListVo_65527_0 listVo_65527_0 = GameUtil.MSG_UPDATE(chara);
        GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
    }

    /**
     * 退出战斗：#gm exitbattle
     * @param chara
     * @param cmds
     */
    public void exitbattle_handler(Chara chara, String[] cmds){
        FightContainer fightContainer = FightManager.getFightContainer(chara.id);
        if(null!=fightContainer){
            FightManager.doOver(fightContainer);
            FightManager.nextRoundOrSendOver(fightContainer);
        }
    }
}
