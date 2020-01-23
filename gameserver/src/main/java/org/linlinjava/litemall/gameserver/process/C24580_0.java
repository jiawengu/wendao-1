/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C24580_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 18 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 19 */     ListVo_65527_0 vo_65527_0 = GameUtil.MSG_UPDATE(chara);
/* 20 */     GameObjectChar.send(new MSG_UPDATE(), vo_65527_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 25 */     return 24580;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C24580_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */