/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20993_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M20993_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_20993_0 object1 = (Vo_20993_0)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.is_startup));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.total_online));
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.last_online));
/*    */     
/* 19 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.adult_status));
/*    */     
/* 21 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.switch3));
/*    */     
/* 23 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.switch5));
/*    */     
/* 25 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.second_enable));
/*    */     
/* 27 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.switch7));
/*    */     
/* 29 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.player_age));
/*    */     
/* 31 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.is_guest));
/*    */     
/* 33 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.small_age));
/*    */     
/* 35 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.young_coin_cost_limit));
/*    */     
/* 37 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.small_age_online));
/*    */     
/* 39 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.young_online));
/*    */   }
/*    */   
/* 42 */   public int cmd() { return 20993; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M20993_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */