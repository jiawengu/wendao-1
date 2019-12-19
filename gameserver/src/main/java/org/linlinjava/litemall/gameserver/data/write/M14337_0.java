/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_14337_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class M14337_0 extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_14337_0 object1 = (Vo_14337_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 15 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.type));
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.life_plus));
/*    */     
/* 19 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.max_life_plus));
/*    */     
/* 21 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.mana_plus));
/*    */     
/* 23 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.max_mana_plus));
/*    */     
/* 25 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.phy_power_plus));
/*    */     
/* 27 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.mag_power_plus));
/*    */     
/* 29 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.speed_plus));
/*    */     
/* 31 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.def_plus));
/*    */     
/* 33 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.free));
/*    */   }
/*    */   
/* 36 */   public int cmd() { return 14337; }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M14337_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */