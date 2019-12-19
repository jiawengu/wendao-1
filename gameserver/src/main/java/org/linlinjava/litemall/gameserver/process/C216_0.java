/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.StoreGoods;
/*    */ import org.linlinjava.litemall.db.service.base.BaseStoreGoodsService;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M65499_0;
/*    */ import org.linlinjava.litemall.gameserver.game.GameData;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class C216_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 22 */     String name = GameReadTool.readString(buff);
/*    */     
/* 24 */     String para = GameReadTool.readString(buff);
/*    */     
/* 26 */     if (para.equals("")) {
/* 27 */       List<StoreGoods> all = GameData.that.baseStoreGoodsService.findAll();
/* 28 */       GameObjectChar.send(new M65499_0(), all);
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 37 */     return 216;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C216_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */