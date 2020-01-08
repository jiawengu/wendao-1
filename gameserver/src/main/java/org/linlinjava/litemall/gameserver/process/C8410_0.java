/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import org.linlinjava.litemall.db.domain.StoreGoods;
/*     */ import org.linlinjava.litemall.db.domain.StoreInfo;
/*     */ import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
/*     */
/*     */
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C8410_0 implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  30 */     String barcode = GameReadTool.readString(buff);
/*     */     
/*  32 */     int amount = GameReadTool.readShort(buff);
/*     */     
/*  34 */     String coin_pwd = GameReadTool.readString(buff);
/*     */     
/*  36 */     String coin_type = GameReadTool.readString(buff);
/*     */     
/*  38 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*  39 */     if (barcode.equals("C0000001")) {
/*  40 */       chara.balance += 3000000;
/*  41 */       chara.extra_life -= 300;
/*  42 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  43 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*  44 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/*  45 */       vo_40964_0.type = 3;
/*  46 */       vo_40964_0.name = "金钱";
/*  47 */       vo_40964_0.param = "3000000";
/*  48 */       vo_40964_0.rightNow = 0;
/*  49 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/*  50 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  51 */       vo_20480_0.msg = "你花费#R300#n个金元宝购买了#Y3,000,000#n文钱#n。";
/*  52 */       vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  53 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/*  54 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  55 */       vo_8165_0.msg = "购买成功";
/*  56 */       vo_8165_0.active = 0;
/*  57 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/*  58 */       return;
/*     */     }
/*  60 */     if (barcode.equals("C0000002")) {
/*  61 */       chara.balance += 6000000;
/*  62 */       chara.extra_life -= 600;
/*  63 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  64 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*  65 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/*  66 */       vo_40964_0.type = 3;
/*  67 */       vo_40964_0.name = "金钱";
/*  68 */       vo_40964_0.param = "6000000";
/*  69 */       vo_40964_0.rightNow = 0;
/*  70 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/*  71 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  72 */       vo_20480_0.msg = "你花费#R600#n个金元宝购买了#Y6,000,000#n文钱#n。";
/*  73 */       vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  74 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/*  75 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  76 */       vo_8165_0.msg = "购买成功";
/*  77 */       vo_8165_0.active = 0;
/*  78 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/*  79 */       return;
/*     */     }
/*  81 */     if (barcode.equals("C0000003")) {
/*  82 */       chara.balance += 10000000;
/*  83 */       chara.extra_life -= 1100;
/*  84 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  85 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*  86 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/*  87 */       vo_40964_0.type = 3;
/*  88 */       vo_40964_0.name = "金钱";
/*  89 */       vo_40964_0.param = "6000000";
/*  90 */       vo_40964_0.rightNow = 0;
/*  91 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/*  92 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/*  93 */       vo_20480_0.msg = "你花费#R1100#n个金元宝购买了#Y10,000,000#n文钱#n。";
/*  94 */       vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/*  95 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/*  96 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  97 */       vo_8165_0.msg = "购买成功";
/*  98 */       vo_8165_0.active = 0;
/*  99 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 100 */       return;
/*     */     }
/* 102 */     if (barcode.equals("C0000004")) {
/* 103 */       chara.balance += 30000000;
/* 104 */       chara.extra_life -= 3300;
/* 105 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 106 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/* 107 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 108 */       vo_40964_0.type = 3;
/* 109 */       vo_40964_0.name = "金钱";
/* 110 */       vo_40964_0.param = "6000000";
/* 111 */       vo_40964_0.rightNow = 0;
/* 112 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/* 113 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 114 */       vo_20480_0.msg = "你花费#R3300#n个金元宝购买了#Y30,000,000#n文钱#n。";
/* 115 */       vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 116 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/* 117 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 118 */       vo_8165_0.msg = "购买成功";
/* 119 */       vo_8165_0.active = 0;
/* 120 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 121 */       return;
/*     */     }
/* 123 */     if (barcode.equals("C0000005")) {
/* 124 */       chara.balance += 60000000;
/* 125 */       chara.extra_life -= 7200;
/* 126 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 127 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/* 128 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 129 */       vo_40964_0.type = 3;
/* 130 */       vo_40964_0.name = "金钱";
/* 131 */       vo_40964_0.param = "6000000";
/* 132 */       vo_40964_0.rightNow = 0;
/* 133 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/* 134 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 135 */       vo_20480_0.msg = "你花费#R7200#n个金元宝购买了#Y60,000,000#n文钱#n。";
/* 136 */       vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 137 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/* 138 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 139 */       vo_8165_0.msg = "购买成功";
/* 140 */       vo_8165_0.active = 0;
/* 141 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 142 */       return;
/*     */     }
/* 144 */     if (barcode.equals("C0000006")) {
/* 145 */       chara.balance += 100000000;
/* 146 */       chara.extra_life -= 7200;
/* 147 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 148 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/* 149 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 150 */       vo_40964_0.type = 3;
/* 151 */       vo_40964_0.name = "金钱";
/* 152 */       vo_40964_0.param = "100000000";
/* 153 */       vo_40964_0.rightNow = 0;
/* 154 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/* 155 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 156 */       vo_20480_0.msg = "你花费#R12000#n个金元宝购买了#Y100,000,000#n文钱#n。";
/* 157 */       vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 158 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/* 159 */       Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 160 */       vo_8165_0.msg = "购买成功";
/* 161 */       vo_8165_0.active = 0;
/* 162 */       GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 163 */       return;
/*     */     }
/*     */     
/*     */ 
/* 167 */     StoreGoods oneByBarcode = GameData.that.baseStoreGoodsService.findOneByBarcode(barcode);
/*     */     
/*     */ 
/*     */ 
/* 171 */     if (oneByBarcode.getForSale().intValue() == 1) {
/* 172 */       coin_type = "gold_coin";
/*     */     }
/* 174 */     if (coin_type.equals("")) {
/* 175 */       if (oneByBarcode.getCoin().intValue() * amount <= chara.gold_coin) {
/* 176 */         chara.gold_coin -= oneByBarcode.getCoin().intValue() * amount;
/* 177 */       } else if (oneByBarcode.getCoin().intValue() * amount <= chara.extra_life) {
/* 178 */         chara.extra_life -= oneByBarcode.getCoin().intValue() * amount;
/*     */       }
/* 180 */     } else if ((coin_type.equals("gold_coin")) && (oneByBarcode.getCoin().intValue() * amount < chara.extra_life)) {
/* 181 */       chara.extra_life -= oneByBarcode.getCoin().intValue() * amount;
/*     */     } else {
/* 183 */       return;
/*     */     }
/*     */     
/* 186 */     if ((barcode.equals("R0004026")) || (barcode.equals("R0004025")) || (barcode.equals("R0004024")))
/*     */     {
/* 188 */       ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr(oneByBarcode.getName());
/*     */       
/* 190 */       GameUtil.huodezhuangbei(chara, oneByStr, 0, amount);
/* 191 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 192 */       vo_40964_0.type = 1;
/* 193 */       vo_40964_0.name = oneByStr.getStr();
/* 194 */       vo_40964_0.param = "-1";
/* 195 */       vo_40964_0.rightNow = 0;
/* 196 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/*     */     } else {
/* 198 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName(oneByBarcode.getName());
/* 199 */       GameUtil.huodedaoju(chara, storeInfo, amount);
/* 200 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 201 */       vo_40964_0.type = 1;
/* 202 */       vo_40964_0.name = storeInfo.getName();
/* 203 */       vo_40964_0.param = "-1";
/* 204 */       vo_40964_0.rightNow = 0;
/* 205 */       GameObjectChar.send(new M40964_0(), vo_40964_0);
/*     */     }
/*     */     
/*     */ 
/* 209 */     ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 210 */     GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 216 */     return 8410;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8410_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */