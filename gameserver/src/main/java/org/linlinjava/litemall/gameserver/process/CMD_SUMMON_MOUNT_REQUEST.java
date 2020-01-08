/*     */ package org.linlinjava.litemall.gameserver.process;
/*     */ 
/*     */ import io.netty.buffer.ByteBuf;
/*     */ import io.netty.channel.ChannelHandlerContext;
/*     */ import java.util.ArrayList;
/*     */ import java.util.List;
/*     */ import java.util.Random;
/*     */ import org.linlinjava.litemall.db.domain.Pet;
/*     */ import org.linlinjava.litemall.gameserver.data.game.BasicAttributesUtils;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_12269_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_20480_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_40964_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41043_0;
/*     */ import org.linlinjava.litemall.gameserver.data.vo.Vo_41045_0;
/*     */ import org.linlinjava.litemall.gameserver.data.write.*;
/*     */
/*     */
/*     */
/*     */ import org.linlinjava.litemall.gameserver.domain.Chara;
/*     */ import org.linlinjava.litemall.gameserver.domain.PetShuXing;
/*     */ import org.linlinjava.litemall.gameserver.domain.Petbeibao;
/*     */ import org.linlinjava.litemall.gameserver.game.GameData;
/*     */ import org.linlinjava.litemall.gameserver.game.GameObjectChar;
/*     */

/**
 * CMD_SUMMON_MOUNT_REQUEST -- 请求召唤精怪
 */
/*     */ @org.springframework.stereotype.Service
/*     */ public class CMD_SUMMON_MOUNT_REQUEST implements org.linlinjava.litemall.gameserver.GameHandler
/*     */ {
/*     */   public void process(ChannelHandlerContext ctx, ByteBuf buff)
/*     */   {
/*  30 */     int flag = org.linlinjava.litemall.gameserver.data.GameReadTool.readByte(buff);
/*     */     
/*  32 */     Chara chara = GameObjectChar.getGameObjectChar().chara;
/*     */     
/*  34 */     if (flag == 1) {
/*  35 */       Vo_41043_0 vo_41043_0 = new Vo_41043_0();
/*  36 */       vo_41043_0.flag = 1;
/*  37 */       vo_41043_0.name = callMounts(true)[0];
/*  38 */       GameObjectChar.send(new M41043_0(), vo_41043_0);
/*  39 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12285_0(), Integer.valueOf(chara.id));
/*     */     }
/*     */     
/*  42 */     if (flag == 3) {
/*  43 */       int coin = 5000000;
/*  44 */       chara.balance -= coin;
/*  45 */       org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/*  46 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/*     */       
/*  48 */       GameUtil.removemunber(chara, "精怪诱饵", 1);
/*     */       
/*  50 */       String[] strings = callMounts(true);
/*     */       
/*  52 */       List<Petbeibao> list = new ArrayList();
/*  53 */       Pet pet = GameData.that.basePetService.findOneByName(strings[0]);
/*  54 */       Petbeibao petbeibao = new Petbeibao();
/*  55 */       petbeibao.petCreate(pet, chara, 10);
/*  56 */       ((PetShuXing)petbeibao.petShuXing.get(0)).penetrate = 2;
/*     */       
/*  58 */       ((PetShuXing)petbeibao.petShuXing.get(0)).polar_point = 4;
/*  59 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_life = ((PetShuXing)petbeibao.petShuXing.get(0)).def;
/*  60 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_mana = ((PetShuXing)petbeibao.petShuXing.get(0)).dex;
/*  61 */       ((PetShuXing)petbeibao.petShuXing.get(0)).enchant_nimbus = 0;
/*  62 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_enchant_nimbus = 0;
/*  63 */       ((PetShuXing)petbeibao.petShuXing.get(0)).suit_light_effect = 1;
/*  64 */       ((PetShuXing)petbeibao.petShuXing.get(0)).hide_mount = Integer.valueOf(strings[1]).intValue();
/*     */       
/*  66 */       ((PetShuXing)petbeibao.petShuXing.get(0)).phy_power = 1;
/*     */       
/*  68 */       ((PetShuXing)petbeibao.petShuXing.get(0)).mag_power = 1;
/*     */       
/*  70 */       ((PetShuXing)petbeibao.petShuXing.get(0)).life = 1;
/*     */       
/*  72 */       ((PetShuXing)petbeibao.petShuXing.get(0)).speed = 1;
/*  73 */       PetShuXing shuXing = new PetShuXing();
/*  74 */       shuXing.no = 23;
/*  75 */       shuXing.type1 = 2;
/*  76 */       shuXing.accurate = (4 * (Integer.valueOf(strings[1]).intValue() - 1));
/*  77 */       shuXing.mana = (4 * (Integer.valueOf(strings[1]).intValue() - 1));
/*  78 */       shuXing.wiz = (3 * (Integer.valueOf(strings[1]).intValue() - 1));
/*  79 */       shuXing.all_polar = 0;
/*  80 */       shuXing.upgrade_magic = 0;
/*  81 */       shuXing.upgrade_total = 0;
/*  82 */       petbeibao.petShuXing.add(shuXing);
/*  83 */       BasicAttributesUtils.petshuxing((PetShuXing)petbeibao.petShuXing.get(0));
/*  84 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_life = ((PetShuXing)petbeibao.petShuXing.get(0)).def;
/*  85 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_mana = ((PetShuXing)petbeibao.petShuXing.get(0)).dex;
/*  86 */       boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
/*  87 */       GameUtil.dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, petbeibao.id, chara);
/*  88 */       chara.pets.add(petbeibao);
/*  89 */       list.add(petbeibao);
/*  90 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*  91 */       Vo_12269_0 vo_12269_0 = new Vo_12269_0();
/*     */       
/*  93 */       vo_12269_0.id = petbeibao.id;
/*  94 */       vo_12269_0.owner_id = chara.id;
/*  95 */       GameObjectChar.send(new M12269_0(), vo_12269_0);
/*  96 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/*  97 */       vo_40964_0.type = 2;
/*  98 */       vo_40964_0.name = strings[0];
/*  99 */       vo_40964_0.param = String.valueOf(((PetShuXing)petbeibao.petShuXing.get(0)).type);
/* 100 */       vo_40964_0.rightNow = 0;
/* 101 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);
/* 102 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 103 */       vo_20480_0.msg = ("恭喜你召唤了一只" + strings[0]);
/* 104 */       vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 105 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/* 106 */       Vo_41045_0 vo_41045_0 = new Vo_41045_0();
/* 107 */       vo_41045_0.flag = 3;
/* 108 */       vo_41045_0.id = petbeibao.id;
/* 109 */       GameObjectChar.send(new M41045_0(), vo_41045_0);
/*     */     }
/*     */     
/* 112 */     if (flag == 2) {
/* 113 */       Vo_41043_0 vo_41043_0 = new Vo_41043_0();
/* 114 */       vo_41043_0.flag = 1;
/* 115 */       vo_41043_0.name = callMounts(true)[0];
/* 116 */       GameObjectChar.send(new M41043_0(), vo_41043_0);
/* 117 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M12285_0(), Integer.valueOf(chara.id));
/*     */     }
/*     */     
/* 120 */     if (flag == 4) {
/* 121 */       int coin = 50000000;
/* 122 */       chara.balance -= coin;
/* 123 */       org.linlinjava.litemall.gameserver.data.vo.ListVo_65527_0 listVo_65527_0 = GameUtil.a65527(chara);
/* 124 */       GameObjectChar.send(new MSG_UPDATE(), listVo_65527_0);
/* 125 */       String[] strings = callMounts(false);
/* 126 */       GameUtil.removemunber(chara, "精怪诱饵", 10);
/*     */       
/* 128 */       List<Petbeibao> list = new ArrayList();
/* 129 */       Pet pet = GameData.that.basePetService.findOneByName(strings[0]);
/* 130 */       Petbeibao petbeibao = new Petbeibao();
/* 131 */       petbeibao.petCreate(pet, chara, 10);
/* 132 */       ((PetShuXing)petbeibao.petShuXing.get(0)).penetrate = 2;
/*     */       
/* 134 */       ((PetShuXing)petbeibao.petShuXing.get(0)).polar_point = 4;
/* 135 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_life = ((PetShuXing)petbeibao.petShuXing.get(0)).def;
/* 136 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_mana = ((PetShuXing)petbeibao.petShuXing.get(0)).dex;
/* 137 */       ((PetShuXing)petbeibao.petShuXing.get(0)).enchant_nimbus = 0;
/*     */       
/* 139 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_enchant_nimbus = 0;
/* 140 */       ((PetShuXing)petbeibao.petShuXing.get(0)).suit_light_effect = 1;
/* 141 */       ((PetShuXing)petbeibao.petShuXing.get(0)).hide_mount = Integer.valueOf(strings[1]).intValue();
/*     */       
/*     */ 
/* 144 */       ((PetShuXing)petbeibao.petShuXing.get(0)).phy_power = 1;
/*     */       
/* 146 */       ((PetShuXing)petbeibao.petShuXing.get(0)).mag_power = 1;
/*     */       
/* 148 */       ((PetShuXing)petbeibao.petShuXing.get(0)).life = 1;
/*     */       
/* 150 */       ((PetShuXing)petbeibao.petShuXing.get(0)).speed = 1;
/*     */       
/*     */ 
/* 153 */       PetShuXing shuXing = new PetShuXing();
/* 154 */       shuXing.no = 23;
/* 155 */       shuXing.type1 = 2;
/*     */       
/*     */ 
/* 158 */       shuXing.accurate = (4 * (Integer.valueOf(strings[1]).intValue() - 1));
/* 159 */       shuXing.mana = (4 * (Integer.valueOf(strings[1]).intValue() - 1));
/* 160 */       shuXing.wiz = (3 * (Integer.valueOf(strings[1]).intValue() - 1));
/* 161 */       shuXing.all_polar = 0;
/* 162 */       shuXing.upgrade_magic = 0;
/* 163 */       shuXing.upgrade_total = 0;
/* 164 */       petbeibao.petShuXing.add(shuXing);
/*     */       
/*     */ 
/* 167 */       BasicAttributesUtils.petshuxing((PetShuXing)petbeibao.petShuXing.get(0));
/*     */       
/* 169 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_life = ((PetShuXing)petbeibao.petShuXing.get(0)).def;
/* 170 */       ((PetShuXing)petbeibao.petShuXing.get(0)).max_mana = ((PetShuXing)petbeibao.petShuXing.get(0)).dex;
/* 171 */       boolean isfagong = ((PetShuXing)petbeibao.petShuXing.get(0)).rank > ((PetShuXing)petbeibao.petShuXing.get(0)).pet_mag_shape;
/* 172 */       GameUtil.dujineng(1, ((PetShuXing)petbeibao.petShuXing.get(0)).metal, ((PetShuXing)petbeibao.petShuXing.get(0)).skill, isfagong, petbeibao.id, chara);
/* 173 */       chara.pets.add(petbeibao);
/* 174 */       list.add(petbeibao);
/* 175 */       GameObjectChar.send(new MSG_UPDATE_PETS(), list);
/*     */       
/* 177 */       Vo_12269_0 vo_12269_0 = new Vo_12269_0();
/*     */       
/* 179 */       vo_12269_0.id = petbeibao.id;
/* 180 */       vo_12269_0.owner_id = chara.id;
/* 181 */       GameObjectChar.send(new M12269_0(), vo_12269_0);
/* 182 */       Vo_40964_0 vo_40964_0 = new Vo_40964_0();
/* 183 */       vo_40964_0.type = 2;
/* 184 */       vo_40964_0.name = strings[0];
/* 185 */       vo_40964_0.param = String.valueOf(((PetShuXing)petbeibao.petShuXing.get(0)).type);
/* 186 */       vo_40964_0.rightNow = 0;
/* 187 */       GameObjectChar.send(new org.linlinjava.litemall.gameserver.data.write.M40964_0(), vo_40964_0);
/*     */       
/* 189 */       Vo_20480_0 vo_20480_0 = new Vo_20480_0();
/* 190 */       vo_20480_0.msg = ("恭喜你召唤了一只" + strings[0]);
/* 191 */       vo_20480_0.time = ((int)(System.currentTimeMillis() / 1000L));
/* 192 */       GameObjectChar.send(new M20480_0(), vo_20480_0);
/* 193 */       Vo_41045_0 vo_41045_0 = new Vo_41045_0();
/* 194 */       vo_41045_0.flag = 3;
/* 195 */       vo_41045_0.id = petbeibao.id;
/* 196 */       GameObjectChar.send(new M41045_0(), vo_41045_0);
/*     */     }
/*     */   }
/*     */   
/*     */ 
/*     */   public int cmd()
/*     */   {
/* 203 */     return 41044;
/*     */   }
/*     */   
/*     */   public int subtraction() {
/* 207 */     Random r = new Random();
/*     */     
/* 209 */     return r.nextInt(10);
/*     */   }
/*     */   
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */ 
/*     */   private static String[] callMounts(boolean isOrdinary)
/*     */   {
/* 220 */     int[] mounts_stage = { 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 8, 8 };
/* 221 */     String[] mounts_name = { "仙阳剑", "凌岩豹", "幻鹿", "赤焰葫芦", "玉豹", "仙葫芦", "无极熊", "岳麓剑", "古鹿", "北极熊", "筋斗云", "太极熊", "墨麒麟" };
/*     */     
/* 223 */     List<Integer> separates = new ArrayList();
/*     */     
/* 225 */     separates.add(Integer.valueOf(6));
/* 226 */     separates.add(Integer.valueOf(10));
/* 227 */     List<Integer> percents = new ArrayList();
/* 228 */     percents.add(Integer.valueOf(97 - (isOrdinary ? 0 : 4)));
/* 229 */     percents.add(Integer.valueOf(2 + (isOrdinary ? 0 : 3)));
/* 230 */     percents.add(Integer.valueOf(1 + (isOrdinary ? 0 : 1)));
/* 231 */     int number = org.linlinjava.litemall.gameserver.data.game.RateRandomNumber.produceRateRandomNumber(0, 12, separates, percents);
/*     */     
/* 233 */     String[] mounts = new String[2];
/* 234 */     mounts[0] = mounts_name[number];
/* 235 */     mounts[1] = String.valueOf(mounts_stage[number]);
/*     */     
/*     */ 
/* 238 */     return mounts;
/*     */   }
/*     */   
/*     */   private static int stageMounts(String name)
/*     */   {
/* 243 */     int[] mounts_stage = { 2, 3, 4, 4, 5, 5, 5, 6, 6, 6, 6, 8, 8 };
/* 244 */     String[] mounts_name = { "仙阳剑", "凌岩豹", "幻鹿", "赤焰葫芦", "玉豹", "仙葫芦", "无极熊", "岳麓剑", "古鹿", "北极熊", "筋斗云", "太极熊", "墨麒麟" };
/* 245 */     for (int i = 0; i < mounts_name.length; i++) {
/* 246 */       if (mounts_name[i].equalsIgnoreCase(name)) {
/* 247 */         return mounts_stage[i];
/*     */       }
/*     */     }
/* 250 */     return 0;
/*     */   }
/*     */ }


/* Location:              C:\Users\Administrator\Desktop\gameserver-0.1.0.jar!\org\linlinjava\litemall\gameserver\process\C41044_0.class
 * Java compiler version: 8 (52.0)
 * JD-Core Version:       0.7.1
 */