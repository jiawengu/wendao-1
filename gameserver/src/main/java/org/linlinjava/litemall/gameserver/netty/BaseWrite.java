/*    */ package org.linlinjava.litemall.gameserver.netty;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import io.netty.buffer.Unpooled;
/*    */ import org.linlinjava.litemall.gameserver.GameHandler;
import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.slf4j.Logger;
/*    */ import org.slf4j.LoggerFactory;

import java.util.List;

/*    */
/*    */ 
/*    */ public abstract class BaseWrite
/*    */ {
/* 12 */   Logger log = LoggerFactory.getLogger(BaseWrite.class);
/*    */
/*    */   private int beforeWrite(ByteBuf writeBuf) {
/* 15 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(19802));
/* 16 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
/* 17 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf((int)System.currentTimeMillis() / 1000));
/* 18 */     int writerIndex = writeBuf.writerIndex();
/* 19 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(0));
/* 20 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(cmd()));
/* 21 */     return writerIndex;
/*    */   }
/*    */   
/* 24 */   private void afterWrite(ByteBuf writeBuf, int writerIndex) { int len = writeBuf.writerIndex() - writerIndex - 2;
/* 25 */     writeBuf.markWriterIndex();
/* 26 */     writeBuf.writerIndex(writerIndex).writeShort(len);
/* 27 */     writeBuf.resetWriterIndex();
/*    */   }
/*    */   
/* 30 */   public ByteBuf write(Object object) { int writerIndex = 0;
/* 31 */     ByteBuf writeBuf = Unpooled.buffer();
/* 32 */     writerIndex = beforeWrite(writeBuf);
/* 33 */     writeO(writeBuf, object);
/* 34 */     afterWrite(writeBuf, writerIndex);
/* 35 */     return writeBuf;
/*    */   }
/*    */   
/*    */   protected abstract void writeO(ByteBuf paramByteBuf, Object paramObject);
/*    */   
/*    */   public abstract int cmd();
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\netty\BaseWrite.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */