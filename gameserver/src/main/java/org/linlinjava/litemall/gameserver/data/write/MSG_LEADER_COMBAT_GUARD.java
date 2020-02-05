/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45074_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_LEADER_COMBAT_GUARD extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 15 */     List<Vo_45074_0> object1 = (List)object;
/* 16 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.size()));
/* 17 */     for (int i = 0; i < object1.size(); i++) {
/* 18 */       Vo_45074_0 obj = (Vo_45074_0)object1.get(i);
/*    */       
/* 20 */       GameWriteTool.writeString(writeBuf, obj.guardName);
/*    */       
/* 22 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(obj.guardLevel));
/*    */       
/* 24 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(obj.guardIcon));
/*    */       
/* 26 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(obj.guardOrder));
/*    */       
/* 28 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(obj.guardId));
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 36 */     return 45074;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M45074_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */