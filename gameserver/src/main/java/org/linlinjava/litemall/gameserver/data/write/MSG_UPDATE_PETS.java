/*     */ package org.linlinjava.litemall.gameserver.data.write;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import java.io.PrintStream;
/*     */ import java.util.HashMap;
/*     */ import java.util.Iterator;
/*     */ import java.util.List;
/*     */ import java.util.Map;
/*     */ import java.util.Map.Entry;
/*     */ import java.util.Set;
/*     */ import org.linlinjava.litemall.gameserver.data.GameWriteTool;
/*     */ import org.linlinjava.litemall.gameserver.data.UtilObjMapshuxing;
/*     */ import org.linlinjava.litemall.gameserver.domain.BuildFields;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.netty.BaseWrite;
/*     */

/**
 * MSG_UPDATE_PETS
 */
/*     */ @org.springframework.stereotype.Service
/*     */ public class MSG_UPDATE_PETS extends BaseWrite
/*     */ {
/*     */   protected void writeO(ByteBuf writeBuf, Object object)
/*     */   {
/*  23 */     List<Petbeibao> list = (List)object;
/*     */     
/*  25 */     GameWriteTool.writeShort(writeBuf, Integer.valueOf(list.size()));
/*     */     
/*  27 */     for (int i = 0; i < list.size(); i++)
/*     */     {
/*  29 */       GameWriteTool.writeByte(writeBuf, Integer.valueOf(((Petbeibao)list.get(i)).no));
/*     */       
/*  31 */       GameWriteTool.writeInt(writeBuf, Integer.valueOf(((Petbeibao)list.get(i)).id));
/*     */       
/*  33 */       GameWriteTool.writeShort(writeBuf, Integer.valueOf(((Petbeibao)list.get(i)).petShuXing.size()));
/*  34 */       Entry<Object, Object> entry; for (int j = 0; j < ((Petbeibao)list.get(i)).petShuXing.size(); j++)
/*     */       {
/*  36 */         PetShuXing petShuXing = (PetShuXing)((Petbeibao)list.get(i)).petShuXing.get(j);
/*  37 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(((PetShuXing)((Petbeibao)list.get(i)).petShuXing.get(j)).no));
/*     */         
/*  39 */         GameWriteTool.writeByte(writeBuf, Integer.valueOf(((PetShuXing)((Petbeibao)list.get(i)).petShuXing.get(j)).type1));
/*     */         
/*  41 */         Map<Object, Object> map = new HashMap();
/*  42 */         map = UtilObjMapshuxing.PetShuXing(petShuXing);
/*  43 */         map.remove("no");
/*  44 */         map.remove("type1");
/*     */         
/*     */ 
/*     */ 
/*  48 */         Iterator<Entry<Object, Object>> it = map.entrySet().iterator();
/*  49 */         while (it.hasNext()) {
/*  50 */           entry = (Entry)it.next();
/*  51 */           if ((!entry.getKey().equals("all_polar")) && (!entry.getKey().equals("upgrade_magic")) && (!entry.getKey().equals("upgrade_total")))
/*     */           {
/*     */ 
/*  54 */             if ((entry.getValue().equals(Integer.valueOf(0))) && ((entry.getKey().equals("dex")) || (entry.getKey().equals("def")) || (entry.getKey().equals("mana")) || (entry.getKey().equals("parry")) || (entry.getKey().equals("accurate")) || (entry.getKey().equals("wiz")))) {
/*  55 */               it.remove();
/*     */             }
/*     */             
/*  58 */             if (entry.getValue().equals(""))
/*  59 */               it.remove();
/*     */           }
/*     */         }
/*  62 */         GameWriteTool.writeShort(writeBuf, Integer.valueOf(map.size()));
/*  63 */         for (Entry<Object, Object> objectEntry : map.entrySet()) {
/*  64 */           if (BuildFields.data.get((String)objectEntry.getKey()) != null) {
/*  65 */             BuildFields.get((String)objectEntry.getKey()).write(writeBuf, objectEntry.getValue());
/*     */           } else {
/*  67 */             System.out.println(objectEntry.getKey());
/*     */           }
/*     */         }
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
/*     */   public int cmd()
/*     */   {
/* 200 */     return 65507;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\data\write\M65507_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */