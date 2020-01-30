/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class MSG_UPDATE_3
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 16 */     List object1 = (List)object;
/*    */     
/* 18 */     GameWriteTool.writeInt(writeBuf, (Integer)object1.get(0));
/*    */     
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(2));
/* 21 */     BuildFields.get("exp").write(writeBuf, object1.get(1));
/* 22 */     BuildFields.get("exp_to_next_level").write(writeBuf, object1.get(2));
/*    */   }
/*    */   
/*    */ 
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 29 */     return 65527;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65527_3.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */