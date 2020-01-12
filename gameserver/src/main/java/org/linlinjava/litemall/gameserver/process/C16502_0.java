/*    */ package org.linlinjava.litemall.gameserver.process;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.channel.ChannelHandlerContext;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_61677_0;
/*    */ import org.linlinjava.litemall.gameserver.data.write.M61677_01;
/*    */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
/*    */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*    */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*    */
/*    */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class C16502_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*    */ {
/*    */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*    */   {
/* 21 */     int id = GameReadTool.readInt(buff);
/*    */     
/* 23 */     int from_pos = GameReadTool.readShort(buff);
/*    */     
/* 25 */     int to_pos = GameReadTool.readShort(buff);
/*    */     
/* 27 */     int amount = GameReadTool.readShort(buff);
/* 28 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/* 29 */     for (int i = 0; i < chara.cangku.size(); i++) {
/* 30 */       if (((Goods)chara.cangku.get(i)).pos == from_pos)
/*    */       {
/* 32 */         Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 33 */         vo_40964_0.type = 1;
/* 34 */         vo_40964_0.name = ((Goods)chara.cangku.get(i)).goodsInfo.str;
/* 35 */         vo_40964_0.param = "156482";
/* 36 */         vo_40964_0.rightNow = 2;
/* 37 */         GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);
/*    */         
/* 39 */         ((Goods)chara.cangku.get(i)).pos = GameUtil.beibaoweizhi(chara);
/* 40 */         GameUtil.addwupin((Goods)chara.cangku.get(i), chara);
/* 41 */         chara.cangku.remove(chara.cangku.get(i));
/* 42 */         GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/* 43 */         Vo_61677_0 vo_61677_0 = new Vo_61677_0();
/* 44 */         vo_61677_0.pos = from_pos;
/* 45 */         GameObjectChar.send(new M61677_01(), vo_61677_0);
/*    */       }
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 54 */     return 16502;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C16502_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */