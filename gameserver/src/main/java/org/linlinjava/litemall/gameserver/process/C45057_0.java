/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45056_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M45056_0;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class C45057_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 20 */     int id = GameReadTool.readInt(buff);
/*    */     
/* 22 */     int type = GameReadTool.readShort(buff);
/*    */     
/* 24 */     String para = GameReadTool.readString(buff);
/*    */     
/* 26 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
/*    */     
/*    */ 
/* 29 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 30 */     Vo_45056_0 vo_45056_0 = GameUtil.a45056(chara);
/* 31 */     GameObjectChar.send(new M45056_0(), vo_45056_0);
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 37 */     return 45057;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C45057_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */