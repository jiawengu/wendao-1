/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.db.domain.CreepsStore;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ @Service
/*    */ public class M40967_0
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 16 */     List<CreepsStore> list = (List)object;
/* 17 */     GameWriteTool.writeByte(writeBuf, Integer.valueOf(1));
/* 18 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(list.size()));
/* 19 */     for (int i = 0; i < list.size(); i++) {
/* 20 */       GameWriteTool.writeString(writeBuf, ((CreepsStore)list.get(i)).getName());
/* 21 */       GameWriteTool.writeInt(writeBuf, ((CreepsStore)list.get(i)).getPrice());
/* 22 */       GameWriteTool.writeString(writeBuf, "cash");
/*    */     }
/*    */   }
/*    */   
/*    */   public int cmd()
/*    */   {
/* 28 */     return 40967;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M40967_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */