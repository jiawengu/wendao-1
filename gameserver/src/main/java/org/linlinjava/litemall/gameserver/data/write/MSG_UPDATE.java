/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import java.io.PrintStream;
/*     */ import java.util.HashMap;
/*     */ import java.util.Iterator;
/*     */ import java.util.Map;
/*     */ import java.util.Map.Entry;
/*     */ import java.util.Set;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.UtilObjMap;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*     */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*     */ import org.springframework.stereotype.Service;
/*     */

/**
 * MSG_UPDATE
 */
/*     */ @Service
/*     */ public class MSG_UPDATE
/*     */   extends BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  24 */     ListVo_65527_0 listVo_65527_0 = (ListVo_65527_0)object;
/*  25 */     GameWriteTool.writeInt(writeBuf, Integer.valueOf(listVo_65527_0.id));
/*  26 */     Vo_65527_0 vo = listVo_65527_0.vo_65527_0;
/*  27 */     Map<Object, Object> map = new HashMap();
/*  28 */     map = UtilObjMap.Vo_65527_0(vo);
/*  29 */     Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*  30 */     Entry<Object, Object> entry; while (it.hasNext()) {
/*  31 */       entry = (Entry)it.next();
/*  32 */       if ((entry.getValue() instanceof Integer) ? 
/*  33 */         (!entry.getValue().equals(Integer.valueOf(0))) || (entry.getKey().equals("balance")) || (entry.getKey().equals("gender")) || 
/*  34 */         (entry.getKey().equals("resist_metal")) || (entry.getKey().equals("wood")) || (entry.getKey().equals("water")) || (entry.getKey().equals("fire")) || (entry.getKey().equals("earth")) || (entry.getKey().equals("stamina")) || (entry.getKey().equals("marriage_book_id")) : 
/*     */         
/*     */ 
/*     */ 
/*  38 */         !entry.getValue().equals("")) {}
/*     */     }
/*     */     
/*     */ 
/*     */ 
/*     */ 
/*  44 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  45 */     for (Entry<Object, Object> objectEntry : map.entrySet()) {
/*  46 */       if (BuildFields.data.get((String)objectEntry.getKey()) != null)
/*     */       {
/*  48 */         BuildFields.get((String)objectEntry.getKey()).write(writeBuf, objectEntry.getValue());
/*     */       } else {
/*  50 */         System.out.println(objectEntry.getKey());
/*     */       }
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 221 */     return 65527;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65527_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */