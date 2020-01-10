/*    */ package org.linlinjava.litemall.gameserver.data.write;
/*    */ 
/*    */ import io.netty.buffer.ByteBuf;
/*    */ import java.util.List;
/*    */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*    */ import org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0;
/*    */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*    */ import org.springframework.stereotype.Service;
/*    */ 
/*    */ 
/*    */ @Service
/*    */ public class MSG_UPDATE_SKILLS
/*    */   extends BaseWrite
/*    */ {
/*    */   protected void writeO(ByteBuf writeBuf, Object object)
/*    */   {
/* 17 */     List<Vo_32747_0> obj = (List)object;
/* 18 */     if (obj.size() > 0) {
/* 19 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(((Vo_32747_0)obj.get(0)).id));
/*    */     }
/*    */     
/* 22 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(obj.size()));
/* 23 */     for (int i = 0; i < obj.size(); i++) {
/* 24 */       Vo_32747_0 object1 = (Vo_32747_0)obj.get(i);
/*    */       
/* 26 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.skill_no));
/*    */       
/* 28 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.skill_attrib1));
/*    */       
/* 30 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.skill_level));
/*    */       
/* 32 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.level_improved));
/*    */       
/* 34 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.skill_mana_cost));
/*    */       
/* 36 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.skill_nimbus));
/*    */       
/* 38 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.skill_disabled));
/*    */       
/* 40 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.range));
/*    */       
/* 42 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.max_range));
/*    */       
/* 44 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(object1.count1));
/*    */       
/* 46 */       for (int j = 0; j < object1.count1; j++)
/*    */       {
/* 48 */         GameWriteTool.writeString(writeBuf, object1.s1);
/*    */         
/* 50 */         GameWriteTool.writeInt(writeBuf, Integer.valueOf(object1.s2));
/*    */       }
/*    */       
/* 53 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(object1.isTempSkill));
/*    */     }
/*    */   }
/*    */   
/*    */ 
/*    */   public int cmd()
/*    */   {
/* 60 */     return 32747;
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M32747_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */