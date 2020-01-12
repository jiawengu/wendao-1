/*    */ package org.linlinjava.litemall.gameserver.domain;
/*    */ 
/*    */ import java.util.UUID;
/*    */ import org.linlinjava.litemall.db.domain.StoreInfo;
/*    */ import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
/*    */ 
/*    */ 
/*    */ public class Goods
/*    */ {
    /**
     * 佩戴位置
     * 9：法宝
     * 37：跟宠
     */
    /* 10 */   public int pos = 45;
/* 11 */   public GoodsInfo goodsInfo = new GoodsInfo();
/* 12 */   public GoodsBasics goodsBasics = new GoodsBasics();
/* 13 */   public GoodsLanSe goodsLanSe = new GoodsLanSe();
/* 14 */   public GoodsFenSe goodsFenSe = new GoodsFenSe();
/* 15 */   public GoodsHuangSe goodsHuangSe = new GoodsHuangSe();
/* 16 */   public GoodsLvSe goodsLvSe = new GoodsLvSe();
/* 17 */   public GoodsGaiZao goodsGaiZao = new GoodsGaiZao();
/* 18 */   public GoodsGaiZaoGongMing goodsGaiZaoGongMing = new GoodsGaiZaoGongMing();
/* 19 */   public GoodsGaiZaoGongMingChengGong goodsGaiZaoGongMingChengGong = new GoodsGaiZaoGongMingChengGong();
/* 20 */   public GoodsLvSeGongMing goodsLvSeGongMing = new GoodsLvSeGongMing();
/*    */   
/*    */   public void goodsDaoju(StoreInfo info)
/*    */   {
/* 24 */     if (info.getQuality() != null) {
/* 25 */       this.goodsInfo.quality = info.getQuality();
/*    */     }
/* 27 */     if (info.getSilverCoin() != null) {
/* 28 */       this.goodsInfo.silver_coin = info.getSilverCoin().intValue();
/*    */     }
/* 30 */     if (info.getName().equals("血玲珑")) {
/* 31 */       this.goodsBasics.max_life = 4000000;
/* 32 */       this.goodsInfo.phy_rebuild_level = "剩余血量：4,000,000";
/*    */     }
/* 34 */     if (info.getName().equals("法玲珑")) {
/* 35 */       this.goodsBasics.max_mana = 4000000;
/* 36 */       this.goodsInfo.phy_rebuild_level = "剩余法力：4,000,000";
/*    */     }
/* 38 */     if (info.getName().equals("中级血玲珑")) {
/* 39 */       this.goodsBasics.max_life = 10000000;
/* 40 */       this.goodsInfo.phy_rebuild_level = "剩余血量：10,000,000";
/*    */     }
/* 42 */     if (info.getName().equals("中级法玲珑")) {
/* 43 */       this.goodsBasics.max_mana = 10000000;
/* 44 */       this.goodsInfo.phy_rebuild_level = "剩余法力：10,000,000";
/*    */     }
/* 46 */     if (info.getName().equals("火眼金睛")) {
/* 47 */       this.goodsInfo.max_durability = 10;
/*    */     }
/* 49 */     this.goodsInfo.type = info.getType().intValue();
/* 50 */     this.goodsInfo.str = info.getName();
/*    */     
/* 52 */     this.goodsInfo.recognize_recognized = 0;
/* 53 */     this.goodsInfo.auto_fight = UUID.randomUUID().toString();
/* 54 */     this.goodsInfo.total_score = info.getTotalScore().intValue();
/* 55 */     this.goodsInfo.rebuild_level = info.getRebuildLevel().intValue();
/* 56 */     this.goodsInfo.value = info.getValue().intValue();
/* 57 */     this.goodsInfo.degree_32 = 1;
/*    */   }
/*    */   
/*    */   public void goodsCreate(ZhuangbeiInfo info) {
/* 61 */     this.goodsInfo.amount = info.getAmount().intValue();
/* 62 */     this.goodsInfo.auto_fight = UUID.randomUUID().toString();
/* 63 */     this.goodsInfo.master = info.getMaster().intValue();
/* 64 */     this.goodsInfo.type = info.getType().intValue();
/* 65 */     this.goodsInfo.str = info.getStr();
/* 66 */     this.goodsInfo.metal = info.getMetal().intValue();
/* 67 */     this.goodsInfo.quality = info.getQuality();
/* 68 */     this.goodsInfo.attrib = info.getAttrib().intValue();
/* 69 */     this.goodsInfo.total_score = 1;
/*    */     
/*    */ 
/* 72 */     this.goodsInfo.rebuild_level = 1500;
/* 73 */     this.goodsInfo.recognize_recognized = 1;
/* 74 */     this.goodsInfo.damage_sel_rate = 1000;
/* 75 */     this.goodsInfo.owner_id = 1;
/* 76 */     this.goodsInfo.dunwu_times = 0;
/*    */     
/*    */ 
/* 79 */     this.goodsInfo.gift = 0;
/*    */     
/* 81 */     this.goodsInfo.nick = 0;
/* 82 */     this.goodsInfo.power = 0;
/* 83 */     this.goodsInfo.wrestlescore = 0;
/* 84 */     this.goodsInfo.skill = 0;
/* 85 */     this.goodsInfo.store_exp = 0;
/* 86 */     this.goodsInfo.suit_degree = 0;
/* 87 */     this.goodsInfo.party_stage_party_name = 0;
/*    */     
/* 89 */     this.goodsInfo.mailing_item_times = 0;
/* 90 */     this.goodsInfo.suit_enabled = 0;
/* 91 */     this.goodsInfo.degree_32 = 0;
/* 92 */     this.goodsInfo.value = 8388608;
/* 93 */     this.goodsInfo.color = 0;
/* 94 */     this.goodsBasics.accurate = info.getAccurate().intValue();
/* 95 */     this.goodsBasics.def = info.getDef().intValue();
/* 96 */     this.goodsBasics.dex = info.getDex().intValue();
/* 97 */     this.goodsBasics.mana = info.getMana().intValue();
/* 98 */     this.goodsBasics.parry = info.getParry().intValue();
/* 99 */     this.goodsBasics.wiz = info.getWiz().intValue();
/*    */   }
/*    */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\domain\Goods.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */