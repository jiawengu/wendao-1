/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53377_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M53377_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_53377_0 object1 = (Vo_53377_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.dsicountMonthPrice));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.dsicountQuaterPrice));
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.dsicountYearPrice));
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.startTime));
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.endTime));
/*    */   }
/*    */   
/* 24 */   public int cmd() { return 53377; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M53377_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */