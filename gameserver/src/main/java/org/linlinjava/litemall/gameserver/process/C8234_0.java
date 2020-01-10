/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.ArrayList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class C8234_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 26 */     int from_pos = GameReadTool.readByte(buff);
/*    */     
/* 28 */     int to_pos = GameReadTool.readByte(buff);
/* 29 */     if (to_pos < 0) {
/* 30 */       to_pos = 129 + to_pos + 127;
/*    */     }
/* 32 */     GameObjectChar session = GameObjectChar.getGameObjectChar();
/* 33 */     Chara chara = session.chara;
/* 34 */     List<Goods> list = new ArrayList();
/* 35 */     List<Goods> listbeibao = new ArrayList();
/* 36 */     for (Goods goods : chara.backpack) {
/* 37 */       if (goods.pos == from_pos) {
/* 38 */         goods.pos = to_pos;
/* 39 */         Goods goods1 = new Goods();
/* 40 */         goods1.goodsBasics = null;
/* 41 */         goods1.goodsInfo = null;
/* 42 */         goods1.pos = from_pos;
/* 43 */         listbeibao.add(goods1);
/* 44 */         GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
/* 45 */         GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*    */       }
/*    */     }
/*    */     
/*    */ 
/*    */ 
/* 51 */     GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
/*    */     
/* 53 */     ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 54 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 59 */     return 8234;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8234_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */