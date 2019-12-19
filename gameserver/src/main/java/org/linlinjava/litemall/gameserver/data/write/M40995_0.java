/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40995_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M40995_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_40995_0 object1 = (Vo_40995_0)object;
/* 13 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.flag));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.money));
/*    */     
/* 17 */     GameWriteTool.writeString(writeBuf, object1.surlus);
/*    */     
/* 19 */     GameWriteTool.writeString(writeBuf, object1.overflow);
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.amount));
/*    */     
/* 23 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.choice));
/*    */     
/* 25 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.prize));
/*    */     
/* 27 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.leftCount));
/*    */   }
/*    */   
/* 30 */   public int cmd() { return 40995; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M40995_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */