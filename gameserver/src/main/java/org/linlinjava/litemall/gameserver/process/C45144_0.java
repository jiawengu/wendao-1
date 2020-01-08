/*    */
package org.linlinjava.litemall.gameserver.process;
/*    */
/*    */

import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;

import org.json.JSONObject;
import org.linlinjava.litemall.db.domain.Accounts;
/*    */ import org.linlinjava.litemall.db.service.base.BaseAccountsService;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45143_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45555_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M45143_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M45555_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;
/*    */ import org.springframework.stereotype.Service;

/**
 * CMD_L_REQUEST_LINE_INFO  -- 请求排队信息
 */
/*    */
/*    */
@Service
/*    */ public class C45144_0 implements org.linlinjava.litemall.gameserver.GameHandler
        /*    */ {
    /* 20 */   private static final Logger logger = LoggerFactory.getLogger(C45144_0.class);

    /*    */
    /*    */
    /*    */
    public void process(ChannelHandlerContext ctx, ByteBuf buff)
    /*    */ {
        /* 25 */
        logger.error("C45144_0:"+buff.toString());
        String token = GameReadTool.readString(buff);
        String account = null;
        try {
            JSONObject jo = new JSONObject(token);
            account = (String) jo.get("account");
            account = account.substring(6);
        }catch (Exception e){
            account = token.substring(6);
        }
        Accounts useraccount = GameData.that.baseAccountsService.findOneByToken(account);

        logger.info("验证不通过的查询参数:" + token);
        logger.info("验证不通过的查询参数:" + account);
        if (useraccount == null) {
            logger.info("验证不通过");
            return;
            /*    */
        }
        logger.info("验证不通过的查询参数:" + useraccount.toString());

        /* 31 */
        Vo_45143_0 vo_45143_0 = new Vo_45143_0();
        /* 32 */
        vo_45143_0.line_name = "";
        /* 33 */
        vo_45143_0.expect_time = 1;
        /* 34 */
        vo_45143_0.reconnet_time = 0;
        /* 35 */
        vo_45143_0.waitCode = 1;
        /* 36 */
        vo_45143_0.count = 1;
        /* 37 */
        vo_45143_0.keep_alive = 1;
        /* 38 */
        vo_45143_0.need_wait = 0;
        /* 39 */
        vo_45143_0.indsider_lv = 255;
        /* 40 */
        vo_45143_0.gold_coin = 0;
        /* 41 */
        vo_45143_0.status = 0;
        /* 42 */
        Vo_45555_0 vo_45555_0 = new Vo_45555_0();
        /* 43 */
        vo_45555_0.type = "normal";
        /* 44 */
        vo_45555_0.cookie = "2960226";
        /*    */
        /* 46 */
        ByteBuf write = new M45143_0().write(vo_45143_0);
        /* 47 */
        ByteBuf write1 = new M45555_0().write(vo_45555_0);
        /* 48 */
        ctx.writeAndFlush(write);
        /* 49 */
        ctx.writeAndFlush(write1);
        /*    */
    }

    /*    */
    /*    */
    public int cmd()
    /*    */ {
        /* 54 */
        return 45144;
        /*    */
    }
    /*    */
}


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C45144_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */