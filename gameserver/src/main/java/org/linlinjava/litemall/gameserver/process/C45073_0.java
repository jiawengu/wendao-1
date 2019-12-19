/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.io.UnsupportedEncodingException;
/*    */ import java.util.Random;
/*    */ import org.linlinjava.litemall.db.service.base.BaseCharactersService;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45072_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M45072_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class C45073_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 22 */     int gender = GameReadTool.readByte(buff);
/*    */     
/* 24 */     String arr = getRandomJianHan();
/* 25 */     Vo_45072_0 vo_45072_0 = new Vo_45072_0();
/* 26 */     vo_45072_0.new_name = getRandomJianHan();
/* 27 */     ByteBuf write = new M45072_0().write(vo_45072_0);
/* 28 */     ctx.writeAndFlush(write);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 33 */     return 45073;
/*    */   }
/*    */   
/*    */   public String getRandomJianHan() {
/* 37 */     Random random = new Random();
/* 38 */     int len = random.nextInt(2) + 3;
/* 39 */     String ret = "";
/* 40 */     for (int i = 0; i < len; i++) {
/* 41 */       String str = null;
/*    */       
/* 43 */       int hightPos = 176 + Math.abs(random.nextInt(39));
/* 44 */       int lowPos = 161 + Math.abs(random.nextInt(93));
/* 45 */       byte[] b = new byte[2];
/* 46 */       b[0] = new Integer(hightPos).byteValue();
/* 47 */       b[1] = new Integer(lowPos).byteValue();
/*    */       try {
/* 49 */         str = new String(b, "GBK");
/*    */       } catch (UnsupportedEncodingException ex) {
/* 51 */         ex.printStackTrace();
/*    */       }
/* 53 */       ret = ret + str;
/*    */     }
/* 55 */     if (GameData.that.baseCharactersService.findOneByName(ret) != null) {
/* 56 */       getRandomJianHan();
/*    */     }
/* 58 */     return ret;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C45073_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */