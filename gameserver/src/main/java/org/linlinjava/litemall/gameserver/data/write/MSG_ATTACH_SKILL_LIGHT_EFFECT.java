/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12028_0;
/*    */ 
/*    */ @org.springframework.stereotype.Service
/*    */ public class MSG_ATTACH_SKILL_LIGHT_EFFECT extends org.linlinjava.litemall.gameserver.netty.BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 12 */     Vo_12028_0 object1 = (Vo_12028_0)object;
/* 13 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.id));
/*    */     
/* 15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.effect_no));
/*    */     
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.type));
/* 18 */     if (object1.name != null)
/* 19 */       GameWriteTool.writeString(writeBuf, object1.name);
/*    */   }
/*    */   
/*    */   public int cmd() {
/* 23 */     return 12028;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M12028_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */