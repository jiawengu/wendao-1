/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.Date;
/*    */ import java.util.LinkedList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M41480_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */

/**
 * 请求神秘大礼数据 -- 砸蛋版本
 */
/*    */ @Service
/*    */ public class CMD_SHENMI_DALI_OPEN
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 23 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*    */     
/*    */ 
/* 26 */     Date date = new Date(chara.updatetime);
/* 27 */     boolean isnow = GameUtil.isToday(date);
/* 28 */     if ((!isnow) && (chara.online_time != 0L)) {
/* 29 */       chara.online_time = 0L;
/* 30 */       for (int i = 0; i < chara.shenmiliwu.size(); i++) {
/* 31 */         ((Vo_41480_0)chara.shenmiliwu.get(i)).online_time = 0;
/* 32 */         ((Vo_41480_0)chara.shenmiliwu.get(i)).name = "";
/* 33 */         ((Vo_41480_0)chara.shenmiliwu.get(i)).brate = 0;
/*    */       }
/*    */     }
/* 36 */     List<Vo_41480_0> list = new LinkedList();
/* 37 */     for (int i = 0; i < chara.shenmiliwu.size(); i++) {
/* 38 */       Vo_41480_0 vo_41480_0 = new Vo_41480_0();
/* 39 */       vo_41480_0.online_time = ((int)(chara.online_time / 1000L + (System.currentTimeMillis() - chara.uptime) / 1000L));
/* 40 */       vo_41480_0.time = ((Vo_41480_0)chara.shenmiliwu.get(i)).time;
/* 41 */       vo_41480_0.name = ((Vo_41480_0)chara.shenmiliwu.get(i)).name;
/* 42 */       vo_41480_0.index = ((Vo_41480_0)chara.shenmiliwu.get(i)).index;
/* 43 */       vo_41480_0.brate = ((Vo_41480_0)chara.shenmiliwu.get(i)).brate;
/* 44 */       list.add(vo_41480_0);
/*    */     }
/* 46 */     GameObjectChar.send(new M41480_0(), list);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 51 */     return 41479;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41479_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */