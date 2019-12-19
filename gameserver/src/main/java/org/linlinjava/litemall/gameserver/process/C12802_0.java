/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_11713_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_36889_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_53715_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M11713_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M36889_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M53715_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsInfo;
/*     */ import org.linlinjava.litemall.gameserver.domain.JiNeng;
/*     */ import org.linlinjava.litemall.gameserver.fight.FightContainer;
/*     */ import org.linlinjava.litemall.gameserver.fight.FightManager;
/*     */ import org.linlinjava.litemall.gameserver.fight.FightObject;
/*     */ import org.linlinjava.litemall.gameserver.fight.FightRequest;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class C12802_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  27 */     int id = GameReadTool.readInt(buff);
/*     */     
/*  29 */     int victim_id = GameReadTool.readInt(buff);
/*     */     
/*  31 */     int action = GameReadTool.readInt(buff);
/*     */     
/*  33 */     int para = GameReadTool.readInt(buff);
/*     */     
/*     */ 
/*  36 */     String para1 = GameReadTool.readString(buff);
/*     */     
/*     */ 
/*  39 */     String para2 = GameReadTool.readString(buff);
/*     */     
/*  41 */     String para3 = GameReadTool.readString(buff);
/*     */     
/*  43 */     String skill_talk = GameReadTool.readString(buff);
/*     */     
/*  45 */     FightContainer fightContainer = FightManager.getFightContainer();
/*  46 */     if ((fightContainer == null) || (fightContainer.state.intValue() == 3)) {
/*  47 */       return;
/*     */     }
/*     */     
/*  50 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*     */ 
/*  53 */     boolean checkSkill = false;
/*  54 */     FightObject fightObject = FightManager.getFightObject(fightContainer, id);
/*  55 */     if ((fightObject.fid != chara.id) && (fightObject.cid != chara.id)) {
/*  56 */       return;
/*     */     }
/*     */     
/*     */ 
/*     */ 
/*  61 */     if (fightObject.fightRequest != null) {
/*  62 */       return;
/*     */     }
/*     */     
/*     */ 
/*  66 */     if (action == 3) {
/*  67 */       java.util.List<JiNeng> jiNengList = fightObject.skillsList;
/*  68 */       for (JiNeng jiNeng : jiNengList) {
/*  69 */         if (jiNeng.skill_no == para) {
/*  70 */           checkSkill = true;
/*  71 */           break;
/*     */         }
/*     */       }
/*  74 */       if (!checkSkill) {
/*  75 */         return;
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*  80 */     FightRequest fr = new FightRequest();
/*  81 */     fr.id = id;
/*  82 */     fr.action = action;
/*  83 */     fr.vid = victim_id;
/*  84 */     fr.para = para;
/*  85 */     fr.para1 = para1;
/*  86 */     fr.para2 = para2;
/*  87 */     fr.para3 = para3;
/*  88 */     fr.skill_talk = skill_talk;
/*     */     
/*  90 */     Vo_36889_0 vo_36889_0 = new Vo_36889_0();
/*  91 */     vo_36889_0.count = 1;
/*  92 */     vo_36889_0.id = id;
/*  93 */     vo_36889_0.auto_select = 2;
/*  94 */     vo_36889_0.multi_index = 0;
/*  95 */     vo_36889_0.action = action;
/*  96 */     vo_36889_0.para = para;
/*  97 */     vo_36889_0.multi_count = 0;
/*  98 */     GameObjectChar.send(new M36889_0(), vo_36889_0);
/*     */     
/* 100 */     if (fightObject.type == 1) {
/* 101 */       FightObject fightObjectPet = FightManager.getFightObjectPet(fightContainer, fightObject);
/* 102 */       if ((fightObjectPet == null) || (fightObjectPet.isDead())) {
/* 103 */         Vo_53715_0 vo_53715_0 = new Vo_53715_0();
/* 104 */         vo_53715_0.attacker_id = id;
/* 105 */         vo_53715_0.victim_id = victim_id;
/* 106 */         vo_53715_0.action = action;
/* 107 */         if (para != 2) {
/* 108 */           vo_53715_0.no = para;
/*     */         }
/* 110 */         if (action == 4) {
/* 111 */           Goods beibaowupin = GameUtil.beibaowupin(chara, para);
/* 112 */           if (beibaowupin != null) {
/* 113 */             vo_53715_0.no = beibaowupin.goodsInfo.type;
/* 114 */             fr.item_type = beibaowupin.goodsInfo.type;
/*     */           }
/*     */         }
/* 117 */         GameObjectChar.send(new M53715_0(), vo_53715_0);
/*     */         
/* 119 */         Vo_11713_0 vo_11713_0 = new Vo_11713_0();
/* 120 */         vo_11713_0.id = id;
/* 121 */         vo_11713_0.show = 0;
/* 122 */         GameObjectChar.send(new M11713_0(), vo_11713_0);
/*     */       }
/*     */     } else {
/* 125 */       FightObject fightObjectChar = FightManager.getFightObject(fightContainer, chara.id);
/* 126 */       Vo_53715_0 vo_53715_0 = new Vo_53715_0();
/* 127 */       vo_53715_0.attacker_id = fightObjectChar.fightRequest.id;
/* 128 */       vo_53715_0.victim_id = fightObjectChar.fightRequest.vid;
/* 129 */       vo_53715_0.action = fightObjectChar.fightRequest.action;
/* 130 */       if (vo_53715_0.action != 2) {
/* 131 */         vo_53715_0.no = fightObjectChar.fightRequest.para;
/*     */       }
/* 133 */       if (fightObjectChar.fightRequest.action == 4) {
/* 134 */         Goods beibaowupin = GameUtil.beibaowupin(chara, fightObjectChar.fightRequest.para);
/* 135 */         if (beibaowupin != null) {
/* 136 */           vo_53715_0.no = beibaowupin.goodsInfo.type;
/* 137 */           fightObjectChar.fightRequest.item_type = beibaowupin.goodsInfo.type;
/*     */         }
/*     */       }
/* 140 */       GameObjectChar.send(new M53715_0(), vo_53715_0);
/* 141 */       vo_53715_0 = new Vo_53715_0();
/* 142 */       vo_53715_0.attacker_id = id;
/* 143 */       vo_53715_0.victim_id = victim_id;
/* 144 */       vo_53715_0.action = action;
/* 145 */       if (para != 2) {
/* 146 */         vo_53715_0.no = para;
/*     */       }
/* 148 */       if (action == 4) {
/* 149 */         Goods beibaowupin = GameUtil.beibaowupin(chara, para);
/* 150 */         if (beibaowupin != null) {
/* 151 */           vo_53715_0.no = beibaowupin.goodsInfo.type;
/* 152 */           fr.item_type = beibaowupin.goodsInfo.type;
/*     */         }
/*     */       }
/*     */       
/* 156 */       GameObjectChar.send(new M53715_0(), vo_53715_0);
/*     */       
/* 158 */       Vo_11713_0 vo_11713_0 = new Vo_11713_0();
/* 159 */       vo_11713_0.id = id;
/* 160 */       vo_11713_0.show = 0;
/* 161 */       GameObjectChar.send(new M11713_0(), vo_11713_0);
/*     */     }
/* 163 */     FightManager.changeAutoFightSkill(fightContainer, fightObject, action, para);
/* 164 */     FightManager.addRequest(fightContainer, fr);
/*     */   }
/*     */   
/*     */   public int cmd()
/*     */   {
/* 169 */     return 12802;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C12802_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */