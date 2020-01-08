/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */ import java.util.ArrayList;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class C16504_0
/*    */   implements GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 23 */     int id = GameReadTool.readInt(buff);
/*    */     
/* 25 */     int from_pos = GameReadTool.readShort(buff);
/*    */     
/* 27 */     int to_pos = GameReadTool.readShort(buff);
/*    */     
/* 29 */     int amount = GameReadTool.readShort(buff);
/*    */     
/* 31 */     String container = GameReadTool.readString(buff);
/*    */     
/* 33 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 34 */     for (int i = 0; i < chara.backpack.size(); i++) {
/* 35 */       if (((Goods)chara.backpack.get(i)).pos == from_pos) {
/* 36 */         List<Goods> listbeibao = new ArrayList();
/* 37 */         Goods goods1 = new Goods();
/* 38 */         goods1.goodsBasics = null;
/* 39 */         goods1.goodsInfo = null;
/* 40 */         goods1.goodsLanSe = null;
/* 41 */         goods1.pos = from_pos;
/* 42 */         listbeibao.add(goods1);
/* 43 */         GameUtil.cangkuaddwupin((Goods)chara.backpack.get(i), chara);
/* 44 */         chara.backpack.remove(chara.backpack.get(i));
/* 45 */         GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
/* 46 */         Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/* 47 */         vo_61677_0.list = chara.cangku;
/* 48 */         GameObjectChar.send(new M61677_0(), vo_61677_0);
/* 49 */         break;
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 58 */     return 16504;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C16504_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */