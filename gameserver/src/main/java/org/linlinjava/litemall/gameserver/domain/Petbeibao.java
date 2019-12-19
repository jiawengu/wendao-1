/*     */ package org.linlinjava.litemall.gameserver.domain;
/*     */ 
/*     */ import java.util.LinkedList;
/*     */ import java.util.List;
/*     */ import java.util.Random;
/*     */ import org.linlinjava.litemall.db.domain.Pet;
/*     */ import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0;
/*     */ import org.linlinjava.litemall.gameserver.process.GameUtil;
/*     */ 
/*     */ 
/*     */ public class Petbeibao
/*     */ {
/*     */   public int no;
/*     */   public int id;
/*  16 */   public List<PetShuXing> petShuXing = new LinkedList();
/*  17 */   public List<Vo_12023_0> tianshu = new LinkedList();
/*  18 */   public int autofight_select = 0;
/*  19 */   public int autofight_skillaction = 2;
/*  20 */   public int autofight_skillno = 2;
/*     */   
/*     */   public void PetCreate(Pet pet, Chara chara, int suiji, int penetrate) {
/*  23 */     PetShuXing shuXing = new PetShuXing();
/*  24 */     shuXing.type = pet.getIcon().intValue();
/*  25 */     shuXing.passive_mode = pet.getIcon().intValue();
/*  26 */     shuXing.attrib = pet.getLevelReq().intValue();
/*  27 */     shuXing.str = pet.getName();
/*  28 */     shuXing.skill = 1;
/*  29 */     this.id = GameUtil.getCard(chara);
/*  30 */     this.no = GameUtil.getNo(chara, 1);
/*  31 */     shuXing.pot = 0;
/*  32 */     shuXing.resist_poison = 258;
/*  33 */     shuXing.martial = 15000;
/*  34 */     shuXing.double_hit = 100;
/*  35 */     shuXing.suit_polar = pet.getName();
/*  36 */     shuXing.auto_fight += this.id;
/*  37 */     if (pet.getPolar().equals("金")) {
/*  38 */       shuXing.metal = 1;
/*     */     }
/*  40 */     if (pet.getPolar().equals("木")) {
/*  41 */       shuXing.metal = 2;
/*     */     }
/*  43 */     if (pet.getPolar().equals("水")) {
/*  44 */       shuXing.metal = 3;
/*     */     }
/*  46 */     if (pet.getPolar().equals("火")) {
/*  47 */       shuXing.metal = 4;
/*     */     }
/*  49 */     if (pet.getPolar().equals("土")) {
/*  50 */       shuXing.metal = 5;
/*     */     }
/*  52 */     shuXing.mana_effect = (pet.getLife().intValue() - 40 - subtraction(suiji));
/*  53 */     shuXing.attack_effect = (pet.getMana().intValue() - 40 - subtraction(suiji));
/*  54 */     shuXing.mag_effect = (pet.getPhyAttack().intValue() - 40 - subtraction(suiji));
/*  55 */     shuXing.phy_absorb = (pet.getMagAttack().intValue() - 40 - subtraction(suiji));
/*  56 */     shuXing.phy_effect = (pet.getSpeed().intValue() - 40 - subtraction(suiji));
/*  57 */     shuXing.pet_mana_shape = (shuXing.mana_effect + 40);
/*  58 */     shuXing.pet_speed_shape = (shuXing.attack_effect + 40);
/*  59 */     shuXing.pet_phy_shape = (shuXing.phy_effect + 40);
/*  60 */     shuXing.pet_mag_shape = (shuXing.mag_effect + 40);
/*  61 */     shuXing.rank = (shuXing.phy_absorb + 40);
/*  62 */     shuXing.resist_point = (shuXing.pet_mana_shape + shuXing.pet_speed_shape + shuXing.pet_phy_shape + shuXing.pet_mag_shape + shuXing.rank);
/*     */     
/*     */ 
/*  65 */     shuXing.penetrate = penetrate;
/*  66 */     shuXing.polar_point = 4;
/*     */     
/*  68 */     shuXing.enchant_nimbus = 0;
/*  69 */     shuXing.max_enchant_nimbus = 0;
/*  70 */     shuXing.suit_light_effect = 0;
/*  71 */     shuXing.hide_mount = 0;
/*  72 */     shuXing.phy_power = 1;
/*  73 */     shuXing.mag_power = 1;
/*  74 */     shuXing.life = 1;
/*  75 */     shuXing.speed = 1;
/*     */     
/*  77 */     BasicAttributesUtils.petshuxing(shuXing);
/*  78 */     shuXing.max_life = shuXing.def;
/*  79 */     shuXing.max_mana = shuXing.dex;
/*  80 */     this.petShuXing.add(shuXing);
/*     */   }
/*     */   
/*     */ 
/*     */   public void petCreate(Pet pet, Chara chara, int suiji)
/*     */   {
/*  86 */     PetShuXing shuXing = new PetShuXing();
/*  87 */     shuXing.type = pet.getIcon().intValue();
/*  88 */     shuXing.passive_mode = pet.getIcon().intValue();
/*  89 */     shuXing.attrib = pet.getLevelReq().intValue();
/*  90 */     shuXing.str = pet.getName();
/*  91 */     shuXing.skill = 1;
/*  92 */     this.id = GameUtil.getCard(chara);
/*  93 */     this.no = GameUtil.getNo(chara, 1);
/*  94 */     shuXing.pot = 0;
/*  95 */     shuXing.resist_poison = 258;
/*  96 */     shuXing.martial = 15000;
/*  97 */     shuXing.double_hit = 100;
/*  98 */     shuXing.suit_polar = pet.getName();
/*  99 */     shuXing.auto_fight += this.id;
/* 100 */     if (pet.getPolar().equals("金")) {
/* 101 */       shuXing.metal = 1;
/*     */     }
/* 103 */     if (pet.getPolar().equals("木")) {
/* 104 */       shuXing.metal = 2;
/*     */     }
/* 106 */     if (pet.getPolar().equals("水")) {
/* 107 */       shuXing.metal = 3;
/*     */     }
/* 109 */     if (pet.getPolar().equals("火")) {
/* 110 */       shuXing.metal = 4;
/*     */     }
/* 112 */     if (pet.getPolar().equals("土")) {
/* 113 */       shuXing.metal = 5;
/*     */     }
/*     */     
/*     */ 
/* 117 */     shuXing.mana_effect = (pet.getLife().intValue() - 40 - subtraction(suiji));
/* 118 */     shuXing.attack_effect = (pet.getMana().intValue() - 40 - subtraction(suiji));
/* 119 */     shuXing.mag_effect = (pet.getPhyAttack().intValue() - 40 - subtraction(suiji));
/* 120 */     shuXing.phy_absorb = (pet.getMagAttack().intValue() - 40 - subtraction(suiji));
/* 121 */     shuXing.phy_effect = (pet.getSpeed().intValue() - 40 - subtraction(suiji));
/* 122 */     shuXing.pet_mana_shape = (shuXing.mana_effect + 40);
/* 123 */     shuXing.pet_speed_shape = (shuXing.attack_effect + 40);
/* 124 */     shuXing.pet_phy_shape = (shuXing.phy_effect + 40);
/* 125 */     shuXing.pet_mag_shape = (shuXing.mag_effect + 40);
/* 126 */     shuXing.rank = (shuXing.phy_absorb + 40);
/* 127 */     shuXing.resist_point = (shuXing.pet_mana_shape + shuXing.pet_speed_shape + shuXing.pet_phy_shape + shuXing.pet_mag_shape + shuXing.rank);
/* 128 */     this.petShuXing.add(shuXing);
/*     */   }
/*     */   
/*     */   public int subtraction(int i) {
/* 132 */     Random r = new Random();
/* 133 */     if (i == 0) {
/* 134 */       return 0;
/*     */     }
/* 136 */     return r.nextInt(i);
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\domain\Petbeibao.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */