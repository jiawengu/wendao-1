/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.List;
/*     */ import java.util.Random;
/*     */ import org.linlinjava.litemall.db.domain.Experience;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41482_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_SKILLS;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class CMD_SHENMI_DALI_PICK implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  25 */     int index = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);
/*     */     
/*  27 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*     */ 
/*  30 */     if (index == 0) {
/*  31 */       for (int w = 0; w < 8; w++) {
/*  32 */         index = w + 1;
/*  33 */         int time = ((Vo_41480_0)chara.shenmiliwu.get(w)).time;
/*  34 */         if ((chara.online_time / 1000L + (System.currentTimeMillis() - chara.uptime) / 1000L > time) && (((Vo_41480_0)chara.shenmiliwu.get(index - 1)).brate == 0)) {
/*  35 */           String name = "";
/*  36 */           int potentialPoint = 0;
/*  37 */           Random random = new Random();
/*  38 */           int i = random.nextInt(3);
/*  39 */           if (i == 1) {
/*  40 */             name = "潜能";
/*  41 */             potentialPoint = chara.level * 810;
/*  42 */             chara.cash += potentialPoint;
/*  43 */             Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  44 */             vo_20480_0.msg = ("你获得了#R" + potentialPoint + "#n点" + name);
/*  45 */             vo_20480_0.time = 1562593376;
/*  46 */             GameObjectChar.send(new M20480_0(), vo_20480_0);
/*     */           }
/*  48 */           if (i == 2) {
/*  49 */             name = "道行";
/*  50 */             potentialPoint = chara.level * 7;
/*  51 */             GameUtil.adddaohang(chara, potentialPoint);
/*  52 */           } else if (i == 0) {
/*  53 */             name = "经验";
/*  54 */             Experience experience1 = GameData.that.baseExperienceService.findOneByAttrib(Integer.valueOf(chara.level));
/*  55 */             potentialPoint = experience1.getMaxLevel().intValue() * 2 / (chara.level + 9);
/*  56 */             GameUtil.huodejingyan(chara, potentialPoint);
/*     */           }
/*  58 */           ((Vo_41480_0)chara.shenmiliwu.get(index - 1)).name = name;
/*  59 */           ((Vo_41480_0)chara.shenmiliwu.get(index - 1)).brate = 1;
/*     */           
/*  61 */           Vo_41482_0 vo_41482_0 = new Vo_41482_0();
/*  62 */           vo_41482_0.brate = 1;
/*  63 */           vo_41482_0.name = name;
/*  64 */           vo_41482_0.index = index;
/*  65 */           vo_41482_0.result = 0;
/*  66 */           GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41482_0(), vo_41482_0);
/*     */           
/*     */ 
/*  69 */           org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  70 */           GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */           
/*  72 */           List<Vo_32747_0> vo_32747_0List = GameUtil.MSG_UPDATE_SKILLS(chara);
/*  73 */           GameObjectChar.send(new MSG_UPDATE_SKILLS(), vo_32747_0List);
/*     */           
/*  75 */           GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
/*     */           
/*  77 */           Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  78 */           vo_8165_0.msg = ("恭喜，你意外获得了#R" + name + "#n奖励");
/*  79 */           vo_8165_0.active = 0;
/*  80 */           GameObjectChar.send(new M8165_0(), vo_8165_0);
/*     */           
/*  82 */           GameUtil.a49159(chara);
/*     */           
/*     */ 
/*  85 */           List<Vo_41480_0> list = new java.util.LinkedList();
/*  86 */           for (int k = 0; k < chara.shenmiliwu.size(); k++) {
/*  87 */             Vo_41480_0 vo_41480_0 = new Vo_41480_0();
/*  88 */             vo_41480_0.online_time = ((int)(chara.online_time / 1000L + (System.currentTimeMillis() - chara.uptime) / 1000L));
/*  89 */             vo_41480_0.time = ((Vo_41480_0)chara.shenmiliwu.get(k)).time;
/*  90 */             vo_41480_0.name = ((Vo_41480_0)chara.shenmiliwu.get(k)).name;
/*  91 */             vo_41480_0.index = ((Vo_41480_0)chara.shenmiliwu.get(k)).index;
/*  92 */             vo_41480_0.brate = ((Vo_41480_0)chara.shenmiliwu.get(k)).brate;
/*  93 */             list.add(vo_41480_0);
/*     */           }
/*  95 */           GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41480_0(), list);
/*     */         }
/*     */       }
/*  98 */       return;
/*     */     }
/* 100 */     int time = ((Vo_41480_0)chara.shenmiliwu.get(index - 1)).time;
/*     */     
/*     */ 
/*     */ 
/*     */ 
/* 105 */     long times = System.currentTimeMillis();
/* 106 */     boolean istime = chara.online_time / 1000L + (System.currentTimeMillis() - chara.uptime) / 1000L > time;
/* 107 */     if ((istime) && (((Vo_41480_0)chara.shenmiliwu.get(index - 1)).brate == 0)) {
/* 108 */       String name = "";
/* 109 */       int potentialPoint = 0;
/* 110 */       Random random = new Random();
/* 111 */       int i = random.nextInt(3);
/* 112 */       if (i == 1) {
/* 113 */         name = "潜能";
/* 114 */         potentialPoint = chara.level * 810;
/* 115 */         chara.cash += potentialPoint;
/* 116 */         Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 117 */         vo_20480_0.msg = ("你获得了#R" + potentialPoint + "#n点" + name);
/* 118 */         vo_20480_0.time = 1562593376;
/* 119 */         GameObjectChar.send(new M20480_0(), vo_20480_0);
/*     */       }
/* 121 */       if (i == 2) {
/* 122 */         name = "道行";
/* 123 */         potentialPoint = chara.level * 7;
/* 124 */         GameUtil.adddaohang(chara, potentialPoint);
/* 125 */       } else if (i == 0) {
/* 126 */         name = "经验";
/* 127 */         Experience experience1 = GameData.that.baseExperienceService.findOneByAttrib(Integer.valueOf(chara.level));
/* 128 */         potentialPoint = experience1.getMaxLevel().intValue() * 2 / (chara.level + 9);
/* 129 */         GameUtil.huodejingyan(chara, potentialPoint);
/*     */       }
/* 131 */       ((Vo_41480_0)chara.shenmiliwu.get(index - 1)).name = name;
/* 132 */       ((Vo_41480_0)chara.shenmiliwu.get(index - 1)).brate = 1;
/*     */       
/* 134 */       Vo_41482_0 vo_41482_0 = new Vo_41482_0();
/* 135 */       vo_41482_0.brate = 1;
/* 136 */       vo_41482_0.name = name;
/* 137 */       vo_41482_0.index = index;
/* 138 */       vo_41482_0.result = 0;
/* 139 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41482_0(), vo_41482_0);
/*     */       
/*     */ 
/* 142 */       org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 143 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */       
/* 145 */       List<Vo_32747_0> vo_32747_0List = GameUtil.MSG_UPDATE_SKILLS(chara);
/* 146 */       GameObjectChar.send(new MSG_UPDATE_SKILLS(), vo_32747_0List);
/*     */       
/* 148 */       GameUtil.MSG_UPDATE_IMPROVEMENT(chara);
/*     */       
/* 150 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 151 */       vo_8165_0.msg = ("恭喜，你意外获得了#R" + name + "#n奖励");
/* 152 */       vo_8165_0.active = 0;
/* 153 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/*     */       
/* 155 */       GameUtil.a49159(chara);
/*     */       
/*     */ 
/* 158 */       List<Vo_41480_0> list = new java.util.LinkedList();
/* 159 */       for (int k = 0; k < chara.shenmiliwu.size(); k++) {
/* 160 */         Vo_41480_0 vo_41480_0 = new Vo_41480_0();
/* 161 */         vo_41480_0.online_time = ((int)(chara.online_time / 1000L + (System.currentTimeMillis() - chara.uptime) / 1000L));
/* 162 */         vo_41480_0.time = ((Vo_41480_0)chara.shenmiliwu.get(k)).time;
/* 163 */         vo_41480_0.name = ((Vo_41480_0)chara.shenmiliwu.get(k)).name;
/* 164 */         vo_41480_0.index = ((Vo_41480_0)chara.shenmiliwu.get(k)).index;
/* 165 */         vo_41480_0.brate = ((Vo_41480_0)chara.shenmiliwu.get(k)).brate;
/* 166 */         list.add(vo_41480_0);
/*     */       }
/* 168 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M41480_0(), list);
/*     */     }
/*     */     else {}
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 178 */     return 41481;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41481_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */