/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import java.util.Random;
/*     */ import org.json.JSONObject;
/*     */ import org.linlinjava.litemall.db.domain.Pet;
/*     */
/*     */ import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40991_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_8165_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.*;
/*     */
/*     */
import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.Goods;
/*     */
/*     */
/*     */ import org.linlinjava.litemall.gameserver.domain.JiNeng;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ 
/*     */ @org.springframework.stereotype.Service
/*     */ public class CMD_FEED_PET implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(io.netty.channel.ChannelHandlerContext ctx, io.netty.buffer.ByteBuf buff)
/*     */   {
/*  29 */     int no = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);
/*     */     
/*  31 */     int pos = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);
/*     */     
/*  33 */     String para = org.linlinjava.litemall.gameserver.data.GameReadTool.readString(buff);
/*     */     
/*  35 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*     */ 
/*     */ 
/*  39 */     if ("inset".equals(para)) {
/*  40 */       for (int i = 0; i < chara.backpack.size(); i++) {
/*  41 */         if (pos == ((Goods)chara.backpack.get(i)).pos) {
/*  42 */           Goods goods = (Goods)chara.backpack.get(i);
/*     */           
/*  44 */           for (int j = 0; j < chara.pets.size(); j++) {
/*  45 */             int weizhi = 12;
/*  46 */             if (((Petbeibao)chara.pets.get(j)).no == no) {
/*  47 */               for (int k = 0; k < ((Petbeibao)chara.pets.get(j)).petShuXing.size(); k++) {
/*  48 */                 if (((PetShuXing)((Petbeibao)chara.pets.get(j)).petShuXing.get(k)).str.equals(goods.goodsInfo.str)) {
/*  49 */                   Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  50 */                   vo_8165_0.msg = "不可重复打入！";
/*  51 */                   vo_8165_0.active = 0;
/*  52 */                   GameObjectChar.send(new M8165_0(), vo_8165_0);
/*  53 */                   return;
/*     */                 }
/*     */               }
/*  56 */               weizhi = weizhi(weizhi, ((Petbeibao)chara.pets.get(j)).petShuXing);
/*     */               
/*  58 */               PetShuXing petShuXing = new PetShuXing();
/*  59 */               petShuXing.no = weizhi;
/*  60 */               petShuXing.type1 = 2;
/*  61 */               petShuXing.skill = goods.goodsInfo.skill;
/*  62 */               petShuXing.str = goods.goodsInfo.str;
/*  63 */               petShuXing.accurate = goods.goodsLanSe.accurate;
/*  64 */               petShuXing.wiz = goods.goodsLanSe.wiz;
/*  65 */               petShuXing.parry = goods.goodsLanSe.parry;
/*  66 */               petShuXing.def = goods.goodsLanSe.def;
/*  67 */               petShuXing.dex = goods.goodsLanSe.dex;
/*  68 */               petShuXing.mana = goods.goodsLanSe.mana;
/*  69 */               petShuXing.silver_coin = 8000;
/*  70 */               ((Petbeibao)chara.pets.get(j)).petShuXing.add(petShuXing);
/*  71 */               List list = new ArrayList();
/*  72 */               list.add(chara.pets.get(j));
/*  73 */               GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*     */               
/*  75 */               Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/*  76 */               vo_8165_0.msg = "打入妖石成功";
/*  77 */               vo_8165_0.active = 0;
/*  78 */               GameObjectChar.send(new M8165_0(), vo_8165_0);
/*  79 */               org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0 vo_9129_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_9129_0();
/*  80 */               vo_9129_0.notify = 12000;
/*  81 */               vo_9129_0.para = "383174";
/*  82 */               GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M9129_0(), vo_9129_0);
/*     */             }
/*     */           }
/*     */           
/*     */ 
/*  87 */           goods.goodsInfo.owner_id -= 1;
/*  88 */           if (goods.goodsInfo.owner_id == 0) {
/*  89 */             List<Goods> listbeibao = new ArrayList();
/*  90 */             Goods goods1 = new Goods();
/*  91 */             goods1.goodsBasics = null;
/*  92 */             goods1.goodsInfo = null;
/*  93 */             goods1.goodsLanSe = null;
/*  94 */             goods1.pos = goods.pos;
/*  95 */             listbeibao.add(goods1);
/*  96 */             chara.backpack.remove(goods);
/*  97 */             GameObjectChar.send(new MSG_INVENTORY(), listbeibao);
/*     */           }
/*  99 */           GameObjectChar.send(new MSG_INVENTORY(), chara.backpack);
/*     */         }
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*     */ 
/* 106 */     if ("".equals(para)) {
/* 107 */       for (int i = 0; i < chara.backpack.size(); i++) {
/* 108 */         if (pos == ((Goods)chara.backpack.get(i)).pos) {
/* 109 */           Goods goods = (Goods)chara.backpack.get(i);
/* 110 */           if (((Goods)chara.backpack.get(i)).goodsInfo.str == "风灵丸") {
/* 111 */             GameUtil.removemunber(chara, "风灵丸", 1);
/* 112 */             for (int j = 0; j < chara.pets.size(); j++) {
/* 113 */               if (((Petbeibao)chara.pets.get(j)).no != no) {}
/*     */             }
/*     */           }
/*     */           
/*     */ 
/*     */ 
/*     */ 
/* 120 */           for (int j = 0; j < chara.pets.size(); j++) {
/* 121 */             if (((Petbeibao)chara.pets.get(j)).no == no) {
/* 122 */               List list = new ArrayList();
/* 123 */               list.add(chara.pets.get(j));
/* 124 */               GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/* 125 */               boolean isfagong = ((PetShuXing)((Petbeibao)chara.pets.get(j)).petShuXing.get(0)).rank > ((PetShuXing)((Petbeibao)chara.pets.get(j)).petShuXing.get(0)).pet_mag_shape;
/* 126 */               GameUtil.dujineng(1, ((PetShuXing)((Petbeibao)chara.pets.get(j)).petShuXing.get(0)).metal, ((PetShuXing)((Petbeibao)chara.pets.get(j)).petShuXing.get(0)).skill, isfagong, ((Petbeibao)chara.pets.get(j)).id, chara);
/* 127 */               org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0 vo_12023_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_12023_0();
/* 128 */               vo_12023_0.owner_id = chara.id;
/* 129 */               vo_12023_0.id = ((Petbeibao)chara.pets.get(j)).id;
/* 130 */               vo_12023_0.god_book_skill_name = goods.goodsInfo.str;
/* 131 */               vo_12023_0.god_book_skill_level = ((int)(chara.level * 1.6D));
/* 132 */               vo_12023_0.god_book_skill_power = 6000;
/* 133 */               vo_12023_0.god_book_skill_disabled = 0;
/* 134 */               ((Petbeibao)chara.pets.get(j)).tianshu.add(vo_12023_0);
/* 135 */               GameObjectChar.send(new MSG_REFRESH_PET_GODBOOK_SKILLS_0(), ((Petbeibao)chara.pets.get(j)).tianshu);
/*     */               
/*     */ 
/* 138 */               org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0 vo_20481_0 = new org.linlinjava.litemall.gameserver.data.vo.Vo_20481_0();
/* 139 */               vo_20481_0.msg = ("恭喜，你的宠物#Y" + ((PetShuXing)((Petbeibao)chara.pets.get(j)).petShuXing.get(0)).str + "#n领悟了新的天书技能");
/* 140 */               vo_20481_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 141 */               GameObjectChar.send(new MSG_NOTIFY_MISC_EX(), vo_20481_0);
/* 142 */               GameUtil.removemunber(chara, goods.goodsInfo.str, 1);
/*     */             }
/*     */           }
/*     */         }
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*     */ 
/*     */ 
/* 152 */     if ("mag".equals(para)) {
/* 153 */       for (int i = 0; i < chara.pets.size(); i++) {
/* 154 */         Petbeibao petbeibao = (Petbeibao)chara.pets.get(i);
/* 155 */         if (petbeibao.no == no) {
/* 156 */           Pet pet = GameData.that.basePetService.findOneByName(((PetShuXing)petbeibao.petShuXing.get(0)).str);
/* 157 */           int[] ints = org.linlinjava.litemall.gameserver.data.game.PetAttributesUtils.upgradePet(true, pet.getMagAttack().intValue(), ((PetShuXing)petbeibao.petShuXing.get(0)).raw_name, ((PetShuXing)petbeibao.petShuXing.get(0)).life_add_temp);
/* 158 */           if (((PetShuXing)petbeibao.petShuXing.get(0)).raw_name < ints[0]) {
/* 159 */             ((PetShuXing)petbeibao.petShuXing.get(0)).pet_life_shape_temp += ints[1];
/* 160 */             ((PetShuXing)petbeibao.petShuXing.get(0)).rank += ints[1];
/* 161 */             ((PetShuXing)petbeibao.petShuXing.get(0)).life_add_temp = 0;
/* 162 */             ((PetShuXing)petbeibao.petShuXing.get(0)).raw_name = ints[0];
/* 163 */             Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 164 */             vo_8165_0.msg = "恭喜强化成功！";
/* 165 */             vo_8165_0.active = 0;
/* 166 */             GameObjectChar.send(new M8165_0(), vo_8165_0);
/*     */           } else {
/* 168 */             ((PetShuXing)petbeibao.petShuXing.get(0)).life_add_temp = ints[2];
/* 169 */             Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 170 */             vo_8165_0.msg = "成长完成度增加了！";
/* 171 */             vo_8165_0.active = 0;
/* 172 */             GameObjectChar.send(new M8165_0(), vo_8165_0);
/*     */           }
/* 174 */           GameUtil.removemunber(chara, "宠物强化丹", 1);
/* 175 */           List list = new ArrayList();
/* 176 */           BasicAttributesUtils.petshuxing((PetShuXing)petbeibao.petShuXing.get(0));
/* 177 */           list.add(petbeibao);
/*     */           
/*     */ 
/* 180 */           GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*     */         }
/*     */       }
/*     */     }
/* 184 */     if ("phy".equals(para)) {
/* 185 */       for (int i = 0; i < chara.pets.size(); i++) {
/* 186 */         Petbeibao petbeibao = (Petbeibao)chara.pets.get(i);
/* 187 */         if (petbeibao.no == no) {
/* 188 */           Pet pet = GameData.that.basePetService.findOneByName(((PetShuXing)petbeibao.petShuXing.get(0)).str);
/* 189 */           int[] ints = org.linlinjava.litemall.gameserver.data.game.PetAttributesUtils.upgradePet(false, pet.getPhyAttack().intValue(), ((PetShuXing)petbeibao.petShuXing.get(0)).mag_rebuild_level, ((PetShuXing)petbeibao.petShuXing.get(0)).mag_rebuild_rate);
/*     */           
/*     */ 
/* 192 */           if (((PetShuXing)petbeibao.petShuXing.get(0)).mag_rebuild_level < ints[0]) {
/* 193 */             ((PetShuXing)petbeibao.petShuXing.get(0)).mag_rebuild_add += ints[1];
/* 194 */             ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape += ints[1];
/* 195 */             ((PetShuXing)petbeibao.petShuXing.get(0)).mag_rebuild_rate = 0;
/* 196 */             ((PetShuXing)petbeibao.petShuXing.get(0)).mag_rebuild_level = ints[0];
/* 197 */             Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 198 */             vo_8165_0.msg = "恭喜强化成功！";
/* 199 */             vo_8165_0.active = 0;
/* 200 */             GameObjectChar.send(new M8165_0(), vo_8165_0);
/*     */           }
/*     */           else
/*     */           {
/* 204 */             ((PetShuXing)petbeibao.petShuXing.get(0)).mag_rebuild_rate = ints[2];
/* 205 */             Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 206 */             vo_8165_0.msg = "成长完成度增加了！";
/* 207 */             vo_8165_0.active = 0;
/* 208 */             GameObjectChar.send(new M8165_0(), vo_8165_0);
/*     */           }
/* 210 */           List list = new ArrayList();
/* 211 */           BasicAttributesUtils.petshuxing((PetShuXing)petbeibao.petShuXing.get(0));
/* 212 */           list.add(petbeibao);
/*     */           
/* 214 */           GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/* 215 */           GameUtil.removemunber(chara, "宠物强化丹", 1);
/*     */         }
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*     */ 
/* 222 */     if ("reset".equals(para)) {
/* 223 */       for (int i = 0; i < chara.pets.size(); i++) {
/* 224 */         Petbeibao petbeibao = (Petbeibao)chara.pets.get(i);
/* 225 */         if (petbeibao.no == no) {
/* 226 */           Pet pet = GameData.that.basePetService.findOneByName(((PetShuXing)petbeibao.petShuXing.get(0)).str);
/*     */           
/* 228 */           PetShuXing shuXing = (PetShuXing)petbeibao.petShuXing.get(0);
/* 229 */           shuXing.penetrate = 2;
/* 230 */           shuXing.skill = 1;
/* 231 */           shuXing.pot = 0;
/* 232 */           shuXing.resist_poison = 258;
/* 233 */           shuXing.mana_effect = (pet.getLife().intValue() - 40 - subtraction());
/* 234 */           shuXing.attack_effect = (pet.getMana().intValue() - 40 - subtraction());
/* 235 */           shuXing.mag_effect = (pet.getPhyAttack().intValue() - 40 - subtraction());
/* 236 */           shuXing.phy_absorb = (pet.getMagAttack().intValue() - 40 - subtraction());
/* 237 */           shuXing.phy_effect = (pet.getSpeed().intValue() - 40 - subtraction());
/* 238 */           shuXing.pet_mana_shape = (shuXing.mana_effect + 40);
/* 239 */           shuXing.pet_speed_shape = (shuXing.attack_effect + 40);
/* 240 */           shuXing.pet_phy_shape = (shuXing.phy_effect + 40);
/* 241 */           shuXing.pet_mag_shape = (shuXing.mag_effect + 40);
/* 242 */           shuXing.rank = (shuXing.phy_absorb + 40);
/* 243 */           shuXing.phy_power = 1;
/* 244 */           shuXing.mag_power = 1;
/* 245 */           shuXing.life = 1;
/* 246 */           shuXing.speed = 1;
/* 247 */           shuXing.polar_point = 4;
/* 248 */           shuXing.resist_point = (shuXing.pet_mana_shape + shuXing.pet_speed_shape + shuXing.pet_phy_shape + shuXing.pet_mag_shape + shuXing.rank);
/* 249 */           List list = new ArrayList();
/* 250 */           BasicAttributesUtils.petshuxing((PetShuXing)petbeibao.petShuXing.get(0));
/* 251 */           shuXing.max_life = shuXing.def;
/* 252 */           shuXing.max_mana = shuXing.dex;
/* 253 */           list.add(petbeibao);
/*     */           
/*     */ 
/* 256 */           boolean isfagong = shuXing.rank > shuXing.pet_mag_shape;
/*     */           
/* 258 */           List<JiNeng> jiNengList = new ArrayList();
/* 259 */           List<JSONObject> nomelSkills = org.linlinjava.litemall.gameserver.data.game.PetAndHelpSkillUtils.getNomelSkills(1, shuXing.metal, 100, isfagong);
/* 260 */           for (int j = 0; j < nomelSkills.size(); j++) {
/* 261 */             JiNeng jiNeng = new JiNeng();
/* 262 */             JSONObject jsonObject = (JSONObject)nomelSkills.get(j);
/* 263 */             jiNeng.id = petbeibao.id;
/* 264 */             jiNeng.skill_no = Integer.parseInt((String)jsonObject.get("skillNo"));
/* 265 */             jiNeng.skill_attrib = 0;
/* 266 */             jiNeng.skill_level = 0;
/* 267 */             jiNeng.level_improved = 0;
/* 268 */             jiNeng.skill_mana_cost = 0;
/* 269 */             jiNeng.skill_nimbus = 42949672;
/* 270 */             jiNeng.skill_disabled = 0;
/* 271 */             jiNeng.range = 0;
/* 272 */             jiNeng.max_range = 0;
/* 273 */             jiNengList.add(jiNeng);
/*     */           }
/* 275 */           List<org.linlinjava.litemall.gameserver.data.vo.Vo_32747_0> vo_32747_0List = GameUtil.MSG_UPDATE_SKILLS(jiNengList);
/* 276 */           GameObjectChar.send(new MSG_UPDATE_SKILLS(), vo_32747_0List);
/*     */           
/*     */ 
/* 279 */           GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/* 280 */           Vo_40991_0 vo_40991_0 = new Vo_40991_0();
/* 281 */           vo_40991_0.result = 0;
/* 282 */           GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40991_0(), vo_40991_0);
/* 283 */           Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 284 */           vo_8165_0.msg = ("洗练成功，宠物#Y" + pet.getName() + "(野生)#n已洗炼成为1级#Y" + pet.getName() + "(宝宝)#n");
/* 285 */           vo_8165_0.active = 0;
/* 286 */           GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 287 */           GameUtil.removemunber(chara, "超级归元露", 1);
/*     */         }
/*     */       }
/*     */     }
/*     */     
/*     */ 
/* 293 */     if ("refine".equals(para)) {
/* 294 */       for (int i = 0; i < chara.pets.size(); i++) {
/* 295 */         Petbeibao petbeibao = (Petbeibao)chara.pets.get(i);
/* 296 */         if (petbeibao.no == no) {
/* 297 */           Pet pet = GameData.that.basePetService.findOneByName(((PetShuXing)petbeibao.petShuXing.get(0)).str);
/* 298 */           PetShuXing shuXing = (PetShuXing)petbeibao.petShuXing.get(0);
/*     */           
/*     */ 
/* 301 */           shuXing.pet_mana_shape_temp = (pet.getLife().intValue() - subtraction() - shuXing.mana_effect - 40);
/*     */           
/* 303 */           shuXing.pet_speed_shape_temp = (pet.getMana().intValue() - subtraction() - shuXing.attack_effect - 40);
/*     */           
/*     */ 
/* 306 */           shuXing.pet_phy_shape_temp = (pet.getSpeed().intValue() - subtraction() - shuXing.phy_effect - 40);
/*     */           
/* 308 */           shuXing.pet_mag_shape_temp = (pet.getPhyAttack().intValue() - subtraction() - shuXing.mag_effect - 40);
/*     */           
/* 310 */           shuXing.evolve_degree = (pet.getMagAttack().intValue() - subtraction() - shuXing.phy_absorb - 40);
/*     */           
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/* 323 */           if (shuXing.mana_effect + 40 == pet.getLife().intValue()) {
/* 324 */             shuXing.pet_mana_shape_temp = 0;
/*     */           }
/* 326 */           if (shuXing.attack_effect + 40 == pet.getMana().intValue()) {
/* 327 */             shuXing.pet_speed_shape_temp = 0;
/*     */           }
/* 329 */           if (shuXing.phy_absorb + 40 == pet.getMagAttack().intValue()) {
/* 330 */             shuXing.evolve_degree = 0;
/*     */           }
/* 332 */           if (shuXing.mag_effect + 40 == pet.getPhyAttack().intValue()) {
/* 333 */             shuXing.pet_mag_shape_temp = 0;
/*     */           }
/* 335 */           if (shuXing.phy_effect + 40 == pet.getSpeed().intValue()) {
/* 336 */             shuXing.pet_phy_shape_temp = 0;
/*     */           }
/* 338 */           List list = new ArrayList();
/* 339 */           BasicAttributesUtils.petshuxing((PetShuXing)petbeibao.petShuXing.get(0));
/*     */           
/* 341 */           list.add(petbeibao);
/*     */           
/* 343 */           GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/* 344 */           Vo_40991_0 vo_40991_0 = new Vo_40991_0();
/* 345 */           vo_40991_0.result = 0;
/* 346 */           GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40991_0(), vo_40991_0);
/* 347 */           Vo_8165_0 vo_8165_0 = new Vo_8165_0();
/* 348 */           vo_8165_0.msg = ("你的#Y" + pet.getName() + "#n经过洗炼，基础成长已重新生成。");
/* 349 */           vo_8165_0.active = 0;
/* 350 */           GameObjectChar.send(new M8165_0(), vo_8165_0);
/* 351 */           GameUtil.removemunber(chara, "超级归元露", 1);
/*     */         }
/*     */       }
/*     */     }
/*     */     
/*     */ 
/*     */ 
/* 358 */     if (57 == pos) {}
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 367 */     return 8270;
/*     */   }
/*     */   
/*     */   public int subtraction() {
/* 371 */     Random r = new Random();
/*     */     
/* 373 */     return r.nextInt(10);
/*     */   }
/*     */   
/*     */   public int weizhi(int weizhi, List<PetShuXing> shuXings) {
/* 377 */     for (int i = 0; i < shuXings.size(); i++) {
/* 378 */       if (((PetShuXing)shuXings.get(i)).no == weizhi) {
/* 379 */         weizhi++;
/* 380 */         weizhi(weizhi, shuXings);
/*     */       }
/*     */     }
/* 383 */     return weizhi;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C8270_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */