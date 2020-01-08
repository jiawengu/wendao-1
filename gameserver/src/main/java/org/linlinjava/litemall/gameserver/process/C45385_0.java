/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */
/*     */ import java.util.ArrayList;
/*     */ import java.util.Hashtable;
/*     */ import java.util.List;
/*     */ import java.util.Random;
/*     */ import org.linlinjava.litemall.db.domain.Choujiang;
/*     */ import org.linlinjava.litemall.db.domain.Pet;
/*     */ import org.linlinjava.litemall.db.domain.StoreInfo;
/*     */ import org.linlinjava.litemall.db.domain.ZhuangbeiInfo;
/*     */
/*     */
/*     */
/*     */ import org.linlinjava.litemall.db.util.JSONUtils;
/*     */ import org.linlinjava.litemall.gameserver.GameHandler;
/*     */ import org.linlinjava.litemall.gameserver.data.game.LuckDrawUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_45382_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M41240_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.M45382_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE_PETS;
/*     */ import org.linlinjava.litemall.gameserver.data.write.MSG_UPDATE;
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.GoodsLanSe;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */ import org.springframework.stereotype.Service;
/*     */ 
/*     */ @Service
/*     */ public class C45385_0 implements GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  39 */     int type = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);
/*     */     
/*     */ 
/*  42 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  44 */     if (1 == type) {
/*  45 */       chara.shadow_self -= 1;
/*  46 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  47 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */       
/*     */ 
/*  50 */       String[] strings = LuckDrawUtils.luckDraw(false);
/*  51 */       huodechoujiang(strings, chara);
/*     */     }
/*     */     
/*     */ 
/*  55 */     if (3 == type) {
/*  56 */       for (int i = 0; i < 10; i++) {
/*  57 */         chara.shadow_self -= 1;
/*  58 */         ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  59 */         GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */         
/*     */ 
/*  62 */         String[] strings = LuckDrawUtils.luckDraw(false);
/*  63 */         huodechoujiang(strings, chara);
/*     */       }
/*     */     }
/*     */     
/*  67 */     if (2 == type)
/*     */     {
/*  69 */       chara.shadow_self -= 10;
/*  70 */       ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  71 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */       
/*     */ 
/*  74 */       String[] strings = LuckDrawUtils.luckDraw(true);
/*  75 */       huodechoujiang(strings, chara);
/*     */     }
/*     */     
/*  78 */     if (4 == type) {
/*  79 */       for (int i = 0; i < 10; i++) {
/*  80 */         chara.shadow_self -= 10;
/*  81 */         ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  82 */         GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */         
/*     */ 
/*  85 */         String[] strings = LuckDrawUtils.luckDraw(true);
/*  86 */         huodechoujiang(strings, chara);
/*     */       }
/*     */     }
/*     */     
/*  90 */     Vo_45382_0 vo_45382_0 = new Vo_45382_0();
/*  91 */     vo_45382_0.reward_str = "#I物品|超级绿水晶#r1#I";
/*  92 */     vo_45382_0.level = 3;
/*  93 */     GameObjectChar.send(new M45382_0(), vo_45382_0);
/*     */     
/*  95 */     GameObjectChar.send(new M41240_0(), null);
/*     */   }
/*     */   
/*     */ 
/*     */   public void huodechoujiang(String[] strings, Chara chara)
/*     */   {
/* 101 */     if (strings[1].equals("变异")) {
/* 102 */       Pet pet = GameData.that.basePetService.findOneByName(strings[0]);
/* 103 */       Petbeibao petbeibao = new Petbeibao();
/* 104 */       petbeibao.PetCreate(pet, chara, 0, 3);
/* 105 */       List<Petbeibao> list = new ArrayList();
/* 106 */       chara.pets.add(petbeibao);
/* 107 */       list.add(petbeibao);
/* 108 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*     */     }
/* 110 */     if (strings[1].equals("神兽")) {
/* 111 */       Pet pet = GameData.that.basePetService.findOneByName(strings[0]);
/* 112 */       Petbeibao petbeibao = new Petbeibao();
/* 113 */       petbeibao.PetCreate(pet, chara, 0, 4);
/* 114 */       List<Petbeibao> list = new ArrayList();
/* 115 */       chara.pets.add(petbeibao);
/* 116 */       list.add(petbeibao);
/* 117 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*     */     }
/* 119 */     if (strings[1].equals("精怪")) {
/* 120 */       int jieshu = stageMounts(strings[0]);
/* 121 */       Pet pet = GameData.that.basePetService.findOneByName(strings[0]);
/* 122 */       Petbeibao petbeibao = new Petbeibao();
/* 123 */       petbeibao.PetCreate(pet, chara, 0, 2);
/* 124 */       List<Petbeibao> list = new ArrayList();
/* 125 */       chara.pets.add(petbeibao);
/* 126 */       list.add(petbeibao);
/* 127 */       ((PetShuXing)petbeibao.petShuXing.get(0)).enchant_nimbus = 0;
/* 128 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_enchant_nimbus = 0;
/* 129 */       ((PetShuXing)petbeibao.petShuXing.get(0)).suit_light_effect = 1;
/* 130 */       ((PetShuXing)petbeibao.petShuXing.get(0)).hide_mount = jieshu;
/* 131 */       PetShuXing shuXing = new PetShuXing();
/* 132 */       shuXing.no = 23;
/* 133 */       shuXing.type1 = 2;
/* 134 */       shuXing.accurate = (4 * (jieshu - 1));
/* 135 */       shuXing.mana = (4 * (jieshu - 1));
/* 136 */       shuXing.wiz = (3 * (jieshu - 1));
/* 137 */       shuXing.all_polar = 0;
/* 138 */       shuXing.upgrade_magic = 0;
/* 139 */       shuXing.upgrade_total = 0;
/* 140 */       petbeibao.petShuXing.add(shuXing);
/* 141 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*     */     }
/* 143 */     if (strings[1].equals("物品")) {
/* 144 */       StoreInfo info = GameData.that.baseStoreInfoService.findOneByName(strings[0]);
/* 145 */       GameUtil.huodedaoju(chara, info, 1);
/*     */     }
/* 147 */     if (strings[1].equals("首饰")) {
/* 148 */       ZhuangbeiInfo oneByStr = GameData.that.baseZhuangbeiInfoService.findOneByStr(strings[0]);
/* 149 */       GameUtil.huodezhuangbei(chara, oneByStr, 0, 1);
/* 150 */       strings[0] = "60级首饰"; }
/*     */     ZhuangbeiInfo zhuangbeiInfo;
/* 152 */     if (strings[1].equals("装备")) {
/* 153 */       Random random = new Random();
/*     */       
/* 155 */       int[] eqType = { 1, 2, 10, 3 };
/* 156 */       int leixing = eqType[random.nextInt(4)];
/* 157 */       String zhuangbname = zhuangbname(chara, leixing);
/* 158 */       List<Hashtable<String, Integer>> hashtables = equipmentLuckDraw(chara.level, leixing);
/* 159 */       if (hashtables.size() > 0)
/*     */       {
/* 161 */         zhuangbeiInfo = GameData.that.baseZhuangbeiInfoService.findOneByStr(zhuangbname);
/* 162 */         for (Hashtable<String, Integer> maps : hashtables) {
/* 163 */           if (((Integer)maps.get("groupNo")).intValue() == 2) {
/* 164 */             maps.put("groupType", Integer.valueOf(2));
/* 165 */             GoodsLanSe gooodsLanSe = (GoodsLanSe)JSONUtils.parseObject(JSONUtils.toJSONString(maps), GoodsLanSe.class);
/* 166 */             GameUtil.huodezhuangbei(chara, zhuangbeiInfo, 0, 1, gooodsLanSe);
/*     */           }
/*     */         }
/*     */       }
/*     */     }
/*     */     
/* 172 */     Choujiang choujiang = GameData.that.baseChoujiangService.findOneByName(strings[0]);
/* 173 */     if (choujiang == null) {
/* 174 */       System.out.println(strings[0]);
/*     */     }
/* 176 */     Vo_45382_0 vo_45382_0 = new Vo_45382_0();
/* 177 */     vo_45382_0.reward_str = choujiang.getDesc();
/* 178 */     vo_45382_0.level = choujiang.getLevel().intValue();
/* 179 */     GameObjectChar.send(new M45382_0(), vo_45382_0);
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 185 */     return 45385;
/*     */   }
/*     */   
/*     */   private int stageMounts(String name) {
/* 189 */     int[] mounts_stage = { 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 8, 8 };
/* 190 */     String[] mounts_name = { "仙阳剑", "凌岩豹", "幻鹿", "赤焰葫芦", "玉豹", "仙葫芦", "无极熊", "岳麓剑", "古鹿", "北极熊", "筋斗云", "太极熊", "墨麒麟" };
/* 191 */     for (int i = 0; i < mounts_name.length; i++) {
/* 192 */       if (mounts_name[i].equalsIgnoreCase(name)) {
/* 193 */         return mounts_stage[i];
/*     */       }
/*     */     }
/* 196 */     return 0;
/*     */   }
/*     */   
/*     */ 
/*     */   private List<Hashtable<String, Integer>> equipmentLuckDraw(int eq_attrib, int leixing)
/*     */   {
/* 202 */     if (eq_attrib < 70) {
/* 203 */       eq_attrib = 70;
/*     */     } else {
/* 205 */       eq_attrib = eq_attrib / 10 * 10;
/*     */     }
/* 207 */     List<Hashtable<String, Integer>> hashtables = org.linlinjava.litemall.gameserver.data.game.ForgingEquipmentUtils.appraisalEquipment(leixing, eq_attrib, 10);
/*     */     
/* 209 */     String[] rareAttributes = { "all_resist_except", "all_resist_polar", "all_polar", "all_skill", "ignore_all_resist_except", "mstunt_rate", "release_forgotten" };
/* 210 */     for (Hashtable<String, Integer> hashtable : hashtables) {
/* 211 */       for (String key : rareAttributes) {
/* 212 */         if (hashtable.contains(key)) {
/* 213 */           Random random = new Random();
/*     */           
/* 215 */           String[] replaceAttributes = { "mag_power", "phy_power", "speed", "life" };
/* 216 */           List<Hashtable<String, Integer>> appraisalList = new ArrayList();
/* 217 */           Hashtable<String, Integer> key_vlaue_tab = new Hashtable();
/* 218 */           key_vlaue_tab.put("groupNo", Integer.valueOf(2));
/* 219 */           key_vlaue_tab.put(replaceAttributes[random.nextInt(4)], Integer.valueOf(eq_attrib / 4));
/* 220 */           appraisalList.add(key_vlaue_tab);
/* 221 */           return appraisalList;
/*     */         }
/*     */       }
/*     */     }
/*     */     
/* 226 */     return hashtables;
/*     */   }
/*     */   
/*     */   public String zhuangbname(Chara chara, int leixing) {
/* 230 */     int eq_attrib = 0;
/* 231 */     if (chara.level < 70) {
/* 232 */       eq_attrib = 70;
/*     */     } else {
/* 234 */       eq_attrib = chara.level / 10 * 10;
/*     */     }
/* 236 */     List<ZhuangbeiInfo> byAttrib = GameData.that.baseZhuangbeiInfoService.findByAttrib(Integer.valueOf(eq_attrib));
/* 237 */     for (int j = 0; j < byAttrib.size(); j++) {
/* 238 */       if ((leixing == 1) && 
/* 239 */         (((ZhuangbeiInfo)byAttrib.get(j)).getMetal().intValue() == chara.menpai) && (((ZhuangbeiInfo)byAttrib.get(j)).getAmount().intValue() == leixing)) {
/* 240 */         return ((ZhuangbeiInfo)byAttrib.get(j)).getStr();
/*     */       }
/*     */       
/* 243 */       if (((leixing == 2) || (leixing == 3)) && 
/* 244 */         (((ZhuangbeiInfo)byAttrib.get(j)).getMaster().intValue() == chara.sex) && (((ZhuangbeiInfo)byAttrib.get(j)).getAmount().intValue() == leixing)) {
/* 245 */         return ((ZhuangbeiInfo)byAttrib.get(j)).getStr();
/*     */       }
/*     */       
/* 248 */       if ((leixing == 10) && 
/* 249 */         (((ZhuangbeiInfo)byAttrib.get(j)).getAmount().intValue() == leixing)) {
/* 250 */         return ((ZhuangbeiInfo)byAttrib.get(j)).getStr();
/*     */       }
/*     */     }
/*     */     
/* 254 */     return "";
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C45385_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */