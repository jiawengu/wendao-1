/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import org.linlinjava.litemall.db.domain.StoreInfo;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.GameReadTool;
/*     */ import org.linlinjava.litemall.gameserver.data.game.PackUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_INVENTORY;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M8165_0;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsInfo;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C28840_0 implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  31 */     int index = GameReadTool.readInt(buff);
/*     */     
/*  33 */     int type = GameReadTool.readByte(buff);
/*     */     
/*  35 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  37 */     int count = 3;
/*  38 */     if (index / 10 == 10) {
/*  39 */       if (!has(chara, index, "凝香幻彩")) {
/*  40 */         return;
/*     */       }
/*  42 */       deledaoju(chara, index, "凝香幻彩");
/*  43 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("凝香幻彩");
/*  44 */       List<Goods> list = new ArrayList();
/*  45 */       Goods goods1 = new Goods();
/*  46 */       goods1.pos = GameUtil.beibaoweizhi(chara);
/*  47 */       goods1.goodsInfo = new GoodsInfo();
/*  48 */       goods1.goodsDaoju(storeInfo);
/*  49 */       goods1.goodsInfo.degree_32 = 0;
/*  50 */       goods1.goodsInfo.skill = (index % 10 + 1);
/*  51 */       goods1.goodsInfo.owner_id = 1;
/*  52 */       goods1.goodsInfo.damage_sel_rate = 400976;
/*  53 */       goods1.goodsInfo.silver_coin = 6000;
/*  54 */       goods1.goodsLanSe.def = PackUtils.demonStoneValue(index);
/*  55 */       GameUtil.addwupin(goods1, chara);
/*  56 */       list.add(goods1);
/*  57 */       GameObjectChar.send(new MSG_INVENTORY(), list);
/*     */     }
/*     */     
/*  60 */     if (index / 10 == 12) {
/*  61 */       if (!has(chara, index, "炫影霜星")) {
/*  62 */         return;
/*     */       }
/*  64 */       deledaoju(chara, index, "炫影霜星");
/*  65 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("炫影霜星");
/*  66 */       List<Goods> list = new ArrayList();
/*  67 */       Goods goods1 = new Goods();
/*  68 */       goods1.pos = GameUtil.beibaoweizhi(chara);
/*  69 */       goods1.goodsInfo = new GoodsInfo();
/*  70 */       goods1.goodsDaoju(storeInfo);
/*  71 */       goods1.goodsInfo.degree_32 = 0;
/*  72 */       goods1.goodsInfo.skill = (index % 10 + 1);
/*  73 */       goods1.goodsInfo.owner_id = 1;
/*  74 */       goods1.goodsInfo.damage_sel_rate = 400976;
/*  75 */       goods1.goodsInfo.silver_coin = 6000;
/*  76 */       goods1.goodsLanSe.parry = PackUtils.demonStoneValue(index);
/*  77 */       GameUtil.addwupin(goods1, chara);
/*  78 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */     }
/*     */     
/*     */ 
/*  82 */     if (index / 10 == 14) {
/*  83 */       if (!has(chara, index, "风寂云清")) {
/*  84 */         return;
/*     */       }
/*  86 */       deledaoju(chara, index, "风寂云清");
/*  87 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("风寂云清");
/*  88 */       List<Goods> list = new ArrayList();
/*  89 */       Goods goods1 = new Goods();
/*  90 */       goods1.pos = GameUtil.beibaoweizhi(chara);
/*  91 */       goods1.goodsInfo = new GoodsInfo();
/*  92 */       goods1.goodsDaoju(storeInfo);
/*  93 */       goods1.goodsInfo.degree_32 = 0;
/*  94 */       goods1.goodsInfo.skill = (index % 10 + 1);
/*  95 */       goods1.goodsInfo.owner_id = 1;
/*  96 */       goods1.goodsInfo.damage_sel_rate = 400976;
/*  97 */       goods1.goodsInfo.silver_coin = 6000;
/*  98 */       goods1.goodsLanSe.wiz = PackUtils.demonStoneValue(index);
/*  99 */       GameUtil.addwupin(goods1, chara);
/* 100 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */     }
/*     */     
/*     */ 
/*     */ 
/* 105 */     if (index / 10 == 16) {
/* 106 */       if (!has(chara, index, "枯月流魂")) {
/* 107 */         return;
/*     */       }
/* 109 */       deledaoju(chara, index, "枯月流魂");
/* 110 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("枯月流魂");
/* 111 */       List<Goods> list = new ArrayList();
/* 112 */       Goods goods1 = new Goods();
/* 113 */       goods1.pos = GameUtil.beibaoweizhi(chara);
/* 114 */       goods1.goodsInfo = new GoodsInfo();
/* 115 */       goods1.goodsDaoju(storeInfo);
/* 116 */       goods1.goodsInfo.degree_32 = 0;
/* 117 */       goods1.goodsInfo.skill = (index % 10 + 1);
/* 118 */       goods1.goodsInfo.owner_id = 1;
/* 119 */       goods1.goodsInfo.damage_sel_rate = 400976;
/* 120 */       goods1.goodsInfo.silver_coin = 6000;
/* 121 */       goods1.goodsLanSe.accurate = PackUtils.demonStoneValue(index);
/* 122 */       GameUtil.addwupin(goods1, chara);
/* 123 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */     }
/*     */     
/* 126 */     if (index / 10 == 20) {
/* 127 */       if (!has(chara, index, "冰落残阳")) {
/* 128 */         return;
/*     */       }
/* 130 */       deledaoju(chara, index, "冰落残阳");
/* 131 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("冰落残阳");
/* 132 */       List<Goods> list = new ArrayList();
/* 133 */       Goods goods1 = new Goods();
/* 134 */       goods1.pos = GameUtil.beibaoweizhi(chara);
/* 135 */       goods1.goodsInfo = new GoodsInfo();
/* 136 */       goods1.goodsDaoju(storeInfo);
/* 137 */       goods1.goodsInfo.degree_32 = 0;
/* 138 */       goods1.goodsInfo.skill = (index % 10 + 1);
/* 139 */       goods1.goodsInfo.owner_id = 1;
/* 140 */       goods1.goodsInfo.damage_sel_rate = 400976;
/* 141 */       goods1.goodsInfo.silver_coin = 6000;
/* 142 */       goods1.goodsLanSe.dex = PackUtils.demonStoneValue(index);
/* 143 */       GameUtil.addwupin(goods1, chara);
/* 144 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */     }
/*     */     
/* 147 */     if (index / 10 == 18) {
/* 148 */       if (!has(chara, index, "雷极弧光")) {
/* 149 */         return;
/*     */       }
/* 151 */       deledaoju(chara, index, "雷极弧光");
/* 152 */       StoreInfo storeInfo = GameData.that.baseStoreInfoService.findOneByName("雷极弧光");
/* 153 */       List<Goods> list = new ArrayList();
/* 154 */       Goods goods1 = new Goods();
/* 155 */       goods1.pos = GameUtil.beibaoweizhi(chara);
/* 156 */       goods1.goodsInfo = new GoodsInfo();
/* 157 */       goods1.goodsDaoju(storeInfo);
/* 158 */       goods1.goodsInfo.degree_32 = 0;
/* 159 */       goods1.goodsInfo.skill = (index % 10 + 1);
/* 160 */       goods1.goodsInfo.owner_id = 1;
/* 161 */       goods1.goodsInfo.damage_sel_rate = 400976;
/* 162 */       goods1.goodsInfo.silver_coin = 6000;
/* 163 */       goods1.goodsLanSe.mana = PackUtils.demonStoneValue(index);
/* 164 */       GameUtil.addwupin(goods1, chara);
/* 165 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 172 */     return 28840;
/*     */   }
/*     */   
/*     */   public boolean has(Chara chara, int index, String str) {
/* 176 */     int count1 = 0;
/* 177 */     for (int i = 0; i < chara.backpack.size(); i++) {
/* 178 */       Goods goods = (Goods)chara.backpack.get(i);
/* 179 */       if ((goods.goodsInfo.str.equals(str)) && (goods.goodsInfo.skill == index % 10)) {
/* 180 */         count1 += goods.goodsInfo.owner_id;
/*     */       }
/*     */     }
/* 183 */     if (count1 >= 3) {
/* 184 */       return true;
/*     */     }
/* 186 */     return false;
/*     */   }
/*     */   
/*     */   public void deledaoju(Chara chara, int index, String str)
/*     */   {
/* 191 */     int count = 3;
/* 192 */     List<Goods> list = new ArrayList();
/* 193 */     for (int i = 0; i < chara.backpack.size(); i++) {
/* 194 */       Goods goods = (Goods)chara.backpack.get(i);
/* 195 */       if ((goods.goodsInfo.str.equals(str)) && (goods.goodsInfo.skill == index % 10)) {
/* 196 */         if (goods.goodsInfo.owner_id >= count) {
/* 197 */           goods.goodsInfo.owner_id -= count;
/* 198 */           count = 0;
/*     */         } else {
/* 200 */           count -= goods.goodsInfo.owner_id;
/* 201 */           goods.goodsInfo.owner_id = 0;
/*     */         }
/* 203 */         if (goods.goodsInfo.owner_id == 0) {
/* 204 */           list.add(goods);
/*     */         }
/* 206 */         List<Goods> listbeibao = new ArrayList();
/* 207 */         Goods goods1 = new Goods();
/* 208 */         goods1.goodsBasics = null;
/* 209 */         goods1.goodsInfo = null;
/* 210 */         goods1.goodsLanSe = null;
/* 211 */         goods1.pos = goods.pos;
/* 212 */         listbeibao.add(goods1);
/* 213 */         GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
/* 214 */         if (count == 0) {
/*     */           break;
/*     */         }
/*     */       }
/*     */     }
/* 219 */     for (int j = 0; j < list.size(); j++) {
/* 220 */       chara.backpack.remove(list.get(j));
/* 221 */       GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */     }
/* 223 */     GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */     
/* 225 */     Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 226 */     vo_8165_0.msg = "炼制成功";
/* 227 */     vo_8165_0.active = 0;
/* 228 */     GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 229 */     Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 230 */     vo_20480_0.msg = "炼制成功";
/* 231 */     vo_20480_0.time = 1562593376;
/* 232 */     GameObjectChar.send(new M20480_0(), vo_20480_0);
/* 233 */     Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 234 */     vo_40964_0.type = 1;
/* 235 */     vo_40964_0.name = str;
/* 236 */     vo_40964_0.param = "394250";
/* 237 */     vo_40964_0.rightNow = 0;
/* 238 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);
/* 239 */     Vo_9129_0 vo_9129_0 = new Vo_9129_0();
/* 240 */     vo_9129_0.notify = 46;
/* 241 */     vo_9129_0.para = "1";
/* 242 */     GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M9129_0(), vo_9129_0);
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C28840_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */